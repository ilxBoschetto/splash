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
        const user = verifyToken(req);
        var fontanelle = null;
        if (!user || !user.userId) {
          res.status(200).json(fontanelle);
        } else {
          const savedEntries = await SavedFontanella.find({ userId: user.userId }).select('fontanellaId').lean();
          const savedFontanellaIds = savedEntries.map(e => e.fontanellaId.toString());

          const result = fontanelle.map(f => ({
            ...f,
            isSaved: savedFontanellaIds.includes(f._id.toString()),
          }));

          res.status(200).json(result);
        }
      } catch (err) {
        console.log(err);
        res.status(500).json({ error: 'Failed to fetch fontanelle' });
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
