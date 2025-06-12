import dbConnect from '../../../lib/mongodb';
import Fontanella from '../../../models/Fontanella';
import SavedFontanella from '../../../models/SavedFontanella';
import User from '../../../models/User';
import corsMiddleware from '../../../lib/cors';
import { verifyToken } from '../../../lib/auth';
import mongoose from 'mongoose';

export default async function handler(req, res) {
  await corsMiddleware(req, res);
  await dbConnect();

  const { method } = req;

  switch (method) {
    case 'GET':
      try {
        const fontanelle = await Fontanella.find().lean();
        

        let user = null;
        try {
          user = verifyToken(req);
        } catch (e) {
          // Ignora errori se non c'è token
        }

        let savedFontanellaIds = new Set();
        if (user && user.userId) {
          const savedEntries = await SavedFontanella.find({ userId: user.userId }).select('fontanellaId').lean();
          savedFontanellaIds = new Set(savedEntries.map(e => e.fontanellaId.toString()));
        }

        // Raccogli tutti i createdBy validi (solo stringhe)
        const createdByIds = fontanelle
          .map(f => f.createdBy)
          .filter(id => id);

        // Converte gli ID in ObjectId
        const objectIds = createdByIds.map(id => new mongoose.Types.ObjectId(id));

        let usersMap = {};
        if (objectIds.length > 0) {

          const users = await User.find({ _id: { $in: objectIds } }).lean();

          usersMap = users.reduce((acc, user) => {
            acc[user._id.toString()] = { id: user._id.toString(), name: user.name ?? '-' };
            return acc;
          }, {});
        }

        const result = fontanelle.map(f => {
          let createdByUser = { id: '-', name: '-' };

          if (f.createdBy) {
            createdByUser = usersMap[f.createdBy] ?? { id: f.createdBy, name: '-' };
          } else if (f.createdBy) {
            createdByUser = {
              id: f.createdBy._id?.toString() ?? '-',
              name: f.createdBy.name ?? '-',
            };
          }

          console.log(f);

          return {
            ...f,
            imageUrl: f.imageUrl ?? '',
            isSaved: savedFontanellaIds.has(f._id.toString()),
            createdBy: createdByUser,
          };
        });

        return res.status(200).json(result);
      } catch (err) {
        console.error('GET /fontanelle error:', err);
        return res.status(500).json({ error: 'Errore nel recupero delle fontanelle' });
      }

      break;

     case 'POST':
      try {
        const user = verifyToken(req);
        if (!user || !user.userId) {
          return res.status(401).json({ error: 'Unauthorized: Invalid or missing token' });
        }

        const { name, lat, lon } = req.body;

        if (
          !name || typeof name !== 'string' || name.trim() === '' ||
          typeof lat !== 'number' || isNaN(lat) ||
          typeof lon !== 'number' || isNaN(lon)
        ) {
          return res.status(400).json({ error: 'Missing or invalid fields' });
        }

        const userObjectId = new mongoose.Types.ObjectId(user.userId);

        const newFontanella = await Fontanella.create({
          name: name.trim(),
          lat,
          lon,
          createdBy: userObjectId,
        });

        return res.status(201).json(newFontanella);
      } catch (err) {
        console.error('POST /fontanelle error:', err);
        return res.status(500).json({ error: 'Failed to create fontanella' });
      }

    default:
      res.setHeader('Allow', ['GET', 'POST']);
      res.status(405).end(`Method ${method} Not Allowed`);
  }
}
