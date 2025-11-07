import type { NextApiRequest } from "next";
import mongoose from "mongoose";
import Fontanella, { IFontanella } from "@models/Fontanella";
import SavedFontanella from "@models/SavedFontanella";
import User, { IUser } from "@models/User";
import type { DecodedToken } from "@lib/auth";
import Vote, { IVote } from "@/models/Vote";
import { Potability } from "@/enum/potability_enum";

//#region Utility

/**
 * Restituisce il numero totale di fontanelle nel database.
 */
export const countFontanelle = async (): Promise<number> =>
  Fontanella.countDocuments({ deleted: { $ne: true } });

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
): Promise<number> =>
  Fontanella.countDocuments({
    createdBy: userId,
    deleted: { $ne: true },
  });

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
  const sortOrder =
    typeof req.query.sort === "string" && req.query.sort.toLowerCase() === "asc"
      ? 1
      : -1;

  // Ordinamento di default: createdAt discendente
  const fontanelle = await Fontanella.find({ deleted: { $ne: true } })
    .sort({ createdAt: sortOrder })
    .lean();

  // Salvataggi dell’utente (se autenticato)
  let savedFontanellaIds = new Set<string>();
  if (user?.userId) {
    const saved = await SavedFontanella.find({ userId: user.userId })
      .select("fontanellaId")
      .lean();
    savedFontanellaIds = new Set(saved.map((e) => e.fontanellaId.toString()));
  }

  // Recupera gli ID dei creatori
  const createdByIds = fontanelle.map((f) => f.createdBy!).map((id) => id);

  // Mappa utenti (per assegnare nome e id)
  let usersMap: Record<string, { id: string; name: string; email: string }> =
    {};
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
      ...f,
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
  const userObjectId = new mongoose.Types.ObjectId(user.userId);

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

    const newFontanella = await Fontanella.create(createData);
    return newFontanella;
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

    const updated = await doc.save();
    return updated;
  }
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
): Promise<IFontanella | null> =>
  Fontanella.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  }).lean();

/**
 * Elimina una fontanella dal database.
 */
export const deleteFontanella = async (
  id: string
): Promise<IFontanella | null> => Fontanella.findByIdAndDelete(id);

//#endregion
