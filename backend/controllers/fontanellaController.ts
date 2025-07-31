import type { NextApiRequest } from 'next';
import mongoose from 'mongoose';
import Fontanella, { IFontanella } from '@models/Fontanella';
import SavedFontanella from '@models/SavedFontanella';
import User, { IUser }  from '@models/User';
import type { DecodedToken } from '@lib/auth';
import Vote, { IVote } from '@/models/VOte';


//#region Utility

/**
 * Restituisce il numero totale di fontanelle nel database.
 */
export const countFontanelle = async (): Promise<number> =>
  Fontanella.countDocuments();

/**
 * Restituisce il numero di fontanelle create da mezzanotte di oggi.
 */
export const countFontanelleToday = async (): Promise<number> => {
  const startOfToday = new Date();
  startOfToday.setHours(0, 0, 0, 0);

  return await Fontanella.countDocuments({ createdAt: { $gte: startOfToday } });
};

export const voteFontanella = async ( 
  fontanella: IFontanella,
  user: IUser,
  voteType: 'up' | 'down'
) : Promise<void> => {
  if (!['up', 'down'].includes(voteType)) {
    throw new Error('Tipo di voto non valido');
  }

  const fontanellaId = fontanella.id;
  const userId = user.id;

  if (!mongoose.Types.ObjectId.isValid(fontanellaId)) {
    throw new Error('ID fontanella non valido');
  }

  const existingVote = await Vote.findOne({
    userId: userId,
    fontanellaId: fontanellaId,
  });

  if (existingVote) {
    if (existingVote.value === voteType) {
      existingVote.deleteOne();
      return;
    }

    
    if (existingVote.value === 'up') fontanella.votes.positive--;
    else fontanella.votes.negative--;

    if (voteType === 'up') fontanella.votes.positive++;
    else fontanella.votes.negative++;
    
    existingVote.value = voteType;
    await existingVote.save();
    await fontanella.save();
    return;
  }

  await Vote.create({
    userId: userId,
    fontanellaId: fontanellaId,
    vote: voteType,
  });

  
  if (voteType === 'up') fontanella.votes.positive++;
  else fontanella.votes.negative++;

  await fontanella.save();
}

//#endregion


//#region GET /fontanelle + utenti e salvataggi

/**
 * Recupera tutte le fontanelle, includendo:
 * - Dati del creatore (se presente)
 * - Stato "isSaved" se l'utente ha salvato la fontanella
 */
export const getFontanelle = async (req: NextApiRequest, user: DecodedToken | null) => {
  const fontanelle = await Fontanella.find().lean();

  // Salvataggi dell’utente (se autenticato)
  let savedFontanellaIds = new Set<string>();
  if (user?.userId) {
    const saved = await SavedFontanella.find({ userId: user.userId })
      .select('fontanellaId')
      .lean();
    savedFontanellaIds = new Set(saved.map((e) => e.fontanellaId.toString()));
  }

  // Recupera gli ID dei creatori
  const createdByIds = fontanelle
    .map(f => f.createdBy!)
    .map(id => id);

  // Mappa utenti (per assegnare nome e id)
  let usersMap: Record<string, { id: string; name: string }> = {};
  if (createdByIds.length > 0) {
    const users = await User.find({ _id: { $in: createdByIds } }).lean();
    usersMap = users.reduce((acc, user) => {
      acc[user._id.toString()] = {
        id: user._id.toString(),
        name: user.name ?? '-',
      };
      return acc;
    }, {} as Record<string, { id: string; name: string }>);
  }

  // Ritorna fontanelle con info arricchite
  return fontanelle.map((f) => {
    const createdByUser = f.createdBy
      ? usersMap[f.createdBy.toString()] ?? { id: f.createdBy.toString(), name: '-' }
      : { id: '-', name: '-' };

    return {
      ...f,
      imageUrl: f.imageUrl ?? '',
      isSaved: savedFontanellaIds.has(f._id.toString()),
      createdBy: createdByUser,
    };
  });
};

//#endregion


//#region POST /fontanelle

export const createFontanella = async (
  {
    name,
    lat,
    lon,
    imageUrl,
  }: { name: string; lat: number; lon: number; imageUrl: string | null },
  user: DecodedToken
) => {
  const trimmedName = name.trim();

  const existingByName = await Fontanella.findOne({
    name: { $regex: `^${trimmedName}$`, $options: 'i' },
  });
  if (existingByName) {
    throw new Error('Esiste già una fontanella con lo stesso nome');
  }

  const existingNearby = await Fontanella.findOne({
    location: {
      $near: {
        $geometry: {
          type: 'Point',
          coordinates: [lon, lat],
        },
        $maxDistance: 10,
      },
    },
  });

  if (existingNearby) {
    throw new Error('Esiste già una fontanella vicina (<10m)');
  }

  const userObjectId = new mongoose.Types.ObjectId(user.userId);

  const newFontanella = await Fontanella.create({
    name: trimmedName,
    lat,
    lon,
    location: {
      type: 'Point',
      coordinates: [lon, lat],
    },
    imageUrl,
    createdBy: userObjectId,
  });

  return newFontanella;
};

//#endregion


//#region Operazioni su singola fontanella (GET, PUT, DELETE)

/**
 * Trova una fontanella tramite il suo ID e popola il campo createdBy.
 */
export const getFontanellaById = async (id: string): Promise<IFontanella | null> =>
  Fontanella.findById(id).populate('createdBy').lean();

/**
 * Aggiorna una fontanella (solo name, lat, lon). Valida automaticamente.
 */
export const updateFontanella = async (
  id: string,
  data: Partial<Pick<IFontanella, 'name' | 'lat' | 'lon'>>
): Promise<IFontanella | null> =>
  Fontanella.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  }).lean();

/**
 * Elimina una fontanella dal database.
 */
export const deleteFontanella = async (id: string): Promise<IFontanella | null> =>
  Fontanella.findByIdAndDelete(id);

//#endregion
