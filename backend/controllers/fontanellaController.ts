import type { NextApiRequest } from "next";
import mongoose from "mongoose";
import Fontanella, { IFontanella } from "@models/Fontanella";
import SavedFontanella from "@models/SavedFontanella";
import User, { IUser } from "@models/User";
import type { DecodedToken } from "@lib/auth";
import Vote, { IVote } from "@/models/Vote";
import { Potability } from "@/enum/potability_enum";
import { log } from "@/helpers/logger";
import redis from "@lib/redis";

const CACHE_KEY_COUNT = "fontanelle:count";
const CACHE_KEY_LIST = "fontanelle:all";

async function invalidateFontanelleCache() {
  await redis.del(CACHE_KEY_COUNT, CACHE_KEY_LIST);
}

//#region Utility

/**
 * Restituisce il numero totale di fontanelle nel database.
 */
export const countFontanelle = async (): Promise<number> => {
  const cachedCount = await redis.get(CACHE_KEY_COUNT);
  if (cachedCount) {
    return parseInt(cachedCount, 10);
  }

  const count = await Fontanella.countDocuments({ deleted: { $ne: true } });
  await redis.set(CACHE_KEY_COUNT, count.toString(), "EX", 3600); // Cache for 1 hour
  return count;
};

/**
 * Restituisce il numero di fontanelle create da mezzanotte di oggi.
 */
export const countFontanelleToday = async (): Promise<number> => {
  const startOfToday = new Date();
  startOfToday.setHours(0, 0, 0, 0);

  return await Fontanella.countDocuments({
    createdAt: { $gte: startOfToday },
    deleted: { $ne: true },
  });
};

/**
 * Returns the number of fontanelle created by a specific user.
 * @param userId
 * @returns
 */
export const countUserCreatedFontanella = async (
  userId: string
): Promise<number> => {
  const count = await Fontanella.countDocuments({
    createdBy: userId,
    deleted: { $ne: true },
  });
  return count;
};

export const getFontanellaVotes = async (
  fontanellaId: string | string[]
): Promise<object> => {
  try {
    const fontanella = await Fontanella.findById(fontanellaId).select("votes");
    if (!fontanella) {
      return null;
    }

    const { positive = 0, negative = 0 } = fontanella.votes || {};

    return {
      total: positive - negative,
      positive,
      negative,
    };
  } catch (error: any) {
    console.error(error);
    return null;
  }
};

export const voteFontanella = async (
  fontanella: IFontanella,
  user: IUser,
  vote: "up" | "down"
): Promise<void> => {
  if (!["up", "down"].includes(vote)) {
    throw new Error("Tipo di voto non valido");
  }

  log.info(`Utente ${user.id} vota fontanella ${fontanella.id} con ${vote}`);

  const fontanellaId = fontanella.id;
  const userId = user.id;

  if (!mongoose.Types.ObjectId.isValid(fontanellaId)) {
    throw new Error("ID fontanella non valido");
  }

  const existingVote = await Vote.findOne({
    userId: userId,
    fontanellaId: fontanellaId,
  });

  if (!fontanella.votes) {
    fontanella.votes = { positive: 0, negative: 0 };
  }

  fontanella.votes.positive = fontanella.votes.positive ?? 0;
  fontanella.votes.negative = fontanella.votes.negative ?? 0;

  if (existingVote) {
    if (existingVote.value === vote) {
      if (existingVote.value === "up") fontanella.votes.positive--;
      else fontanella.votes.negative--;
      await existingVote.deleteOne();
      await fontanella.save();
      return;
    }

    if (existingVote.value === "up") fontanella.votes.positive--;
    else fontanella.votes.negative--;

    if (vote === "up") fontanella.votes.positive++;
    else fontanella.votes.negative++;

    existingVote.value = vote;
    await existingVote.save();
    await fontanella.save();
    return;
  }

  await Vote.create({
    userId: userId,
    fontanellaId: fontanellaId,
    value: vote,
  });

  if (vote === "up") fontanella.votes.positive++;
  else fontanella.votes.negative++;

  await fontanella.save();
  return;
};

//#endregion

//#region GET /fontanelle + utenti e salvataggi

/**
 * Recupera tutte le fontanelle, includendo:
 * - Dati del creatore (se presente)
 * - Stato "isSaved" se l'utente ha salvato la fontanella
 */

export const getFontanelle = async (
  req: NextApiRequest,
  user: DecodedToken | null
) => {
  log.info(`Recupero fontanelle per utente ${user?.userId ?? "anonimo"}`);
  const sortOrder =
    typeof req.query.sort === "string" && req.query.sort.toLowerCase() === "asc"
      ? 1
      : -1;

  // Parametri di paginazione
  const page = req.query.page ? parseInt(req.query.page as string, 10) : null;
  const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : null;

  let fontanelle: any[];

  if (page !== null && limit !== null) {
    const skip = (page - 1) * limit;
    fontanelle = await Fontanella.find({ deleted: { $ne: true } })
      .sort({ createdAt: sortOrder })
      .skip(skip)
      .limit(limit)
      .lean();
  } else {
    const cachedList = await redis.get(CACHE_KEY_LIST);
    if (cachedList) {
      fontanelle = JSON.parse(cachedList);
      if (sortOrder === 1) {
        fontanelle.sort((a: any, b: any) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
      } else {
        fontanelle.sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
      }
    } else {
      fontanelle = await Fontanella.find({ deleted: { $ne: true } })
        .sort({ createdAt: -1 })
        .lean();
      await redis.set(CACHE_KEY_LIST, JSON.stringify(fontanelle), "EX", 3600);
      if (sortOrder === 1) {
        fontanelle.sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
      }
    }
  }

  // Salvataggi dell’utente (solo per gli ID presenti nella risposta corrente per efficienza)
  let savedFontanellaIds = new Set<string>();
  if (user?.userId && fontanelle.length > 0) {
    const currentIds = fontanelle.map(f => f._id);
    const saved = await SavedFontanella.find({ 
        userId: user.userId,
        fontanellaId: { $in: currentIds } 
      })
      .select("fontanellaId")
      .lean();
    savedFontanellaIds = new Set(saved.map((e) => e.fontanellaId.toString()));
  }

  // Get creators
  const createdByIds = fontanelle.map((f) => f.createdBy!).filter(Boolean);
  let usersMap: Record<string, { id: string; name: string; email: string }> = {};
  
  if (createdByIds.length > 0) {
    const users = await User.find({ _id: { $in: createdByIds } })
      .select("_id name email")
      .lean();
    usersMap = users.reduce((acc, user) => {
      acc[user._id.toString()] = {
        id: user._id.toString(),
        name: user.name ?? "-",
        email: user.email ?? "-",
      };
      return acc;
    }, {} as Record<string, { id: string; name: string; email: string }>);
  }

  // Ritorna fontanelle con info arricchite
  return fontanelle.map((f) => {
    const createdByUser = f.createdBy
      ? usersMap[f.createdBy.toString()] ?? {
          id: f.createdBy.toString(),
          name: "-",
          email: "-",
        }
      : { id: "-", name: "-", email: "-" };

    return {
      _id: f._id,
      name: f.name,
      lat: f.lat,
      lon: f.lon,
      // app reads status as potability
      status: f.status,
      createdAt: f.createdAt,
      imageUrl: f.imageUrl ?? "",
      isSaved: savedFontanellaIds.has(f._id.toString()),
      createdBy: createdByUser,
    };
  });
};

//#endregion

//#region saveFontanella
export const saveFontanella = async (
  {
    id,
    name,
    lat,
    lon,
    imageUrl,
    potability,
  }: {
    id?: string;
    name?: string;
    lat?: number;
    lon?: number;
    imageUrl?: string | null;
    potability?: Potability;
  },
  user: DecodedToken
) => {
  log.info(
    `${id ? "Aggiornamento" : "Creazione"} fontanella da utente ${user.userId}`
  );
  const userObjectId = new mongoose.Types.ObjectId(user.userId);

  let result;
  if (!id) {
    // Creazione
    const createData: any = { createdBy: userObjectId };

    if (name) {
      const trimmedName = name.trim();

      const existingByName = await Fontanella.findOne({
        name: { $regex: `^${trimmedName}$`, $options: "i" },
      });
      if (existingByName) {
        throw new Error("Esiste già una fontanella con lo stesso nome");
      }
      createData.name = trimmedName;
    }

    if (lat != null && lon != null) {
      // Controllo vicinanza solo se vengono passati lat/lon
      const existingNearby = await Fontanella.findOne({
        location: {
          $near: {
            $geometry: {
              type: "Point",
              coordinates: [lon, lat],
            },
            $maxDistance: 10,
          },
        },
      });
      if (existingNearby) {
        throw new Error("Esiste già una fontanella vicina (<10m)");
      }
      createData.lat = lat;
      createData.lon = lon;
      createData.status = potability;
      createData.location = {
        type: "Point",
        coordinates: [lon, lat],
      };
    }

    if (imageUrl !== undefined) createData.imageUrl = imageUrl;

    result = await Fontanella.create(createData);
  } else {
    // Aggiornamento
    const doc = await Fontanella.findById(id);
    if (!doc) throw new Error("Fontanella non trovata");

    if (name) doc.name = name.trim();
    if (lat != null && lon != null) {
      doc.lat = lat;
      doc.lon = lon;
      doc.location = {
        type: "Point",
        coordinates: [lon, lat],
      };
    }
    if (imageUrl !== undefined) doc.imageUrl = imageUrl;

    result = await doc.save();
  }

  await invalidateFontanelleCache();
  return result;
};

//#endregion

//#region Operazioni su singola fontanella (GET, PUT, DELETE)

/**
 * Trova una fontanella tramite il suo ID e popola il campo createdBy.
 */
export const getFontanellaById = async (
  id: string
): Promise<IFontanella | null> =>
  Fontanella.findById(id).populate("createdBy").lean();

/**
 * Aggiorna una fontanella (solo name, lat, lon). Valida automaticamente.
 */
export const updateFontanella = async (
  id: string,
  data: Partial<Pick<IFontanella, "name" | "lat" | "lon">>
): Promise<IFontanella | null> => {
  const updated = await Fontanella.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  }).lean();
  if (updated) {
    await invalidateFontanelleCache();
  }
  return updated;
};

/**
 * Elimina una fontanella dal database.
 */
export const deleteFontanella = async (
  id: string
): Promise<IFontanella | null> => {
  log.info(`Eliminazione fontanella ${id} richiesta da utente amministratore`);
  const deleted = await Fontanella.findByIdAndDelete(id);
  if (deleted) {
    await invalidateFontanelleCache();
  }
  return deleted;
};
//#endregion
