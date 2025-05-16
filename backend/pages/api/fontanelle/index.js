import dbConnect from '../../../lib/mongodb';
import Fontanella from '../../../models/Fontanella';

export default async function handler(req, res) {
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
      const { name, lat, lon } = req.body;

      if (
        !name || typeof name !== 'string' ||
        typeof lat !== 'number' ||
        typeof lon !== 'number'
      ) {
        return res.status(400).json({ error: 'Missing or invalid fields' });
      }

      try {
        const newFontanella = await Fontanella.create({ name, lat, lon });
        res.status(201).json(newFontanella);
      } catch (err) {
        res.status(400).json({ error: 'Failed to create fontanella' });
      }
      break;

    default:
      res.setHeader('Allow', ['GET', 'POST']);
      res.status(405).end(`Method ${method} Not Allowed`);
  }
}
