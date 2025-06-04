import dbConnect from '../../../lib/mongodb';
import Fontanella from '../../../models/Fontanella';
import corsMiddleware from '../../../lib/cors';
import { verifyToken } from '../../../lib/auth';

export default async function handler(req, res) {
  await corsMiddleware(req, res);
  await dbConnect();

  const { method } = req;

  switch (method) {
    case 'GET':
      try {
        const all = await Fontanella.find({});
        res.status(200).json(all);
      } catch (err) {
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

        const newFontanella = await Fontanella.create({
          name: name.trim(),
          lat,
          lon,
          createdBy: user.userId,
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
