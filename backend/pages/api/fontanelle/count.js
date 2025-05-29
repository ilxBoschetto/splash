// /pages/api/fontanelle/count.js
import dbConnect from '../../../lib/mongodb';
import Fontanella from '../../../models/Fontanella';

export default async function handler(req, res) {
  await dbConnect();

  if (req.method !== 'GET') {
    return res.status(405).end('Method Not Allowed');
  }

  try {
    const count = await Fontanella.countDocuments();
    res.status(200).json({ count });
  } catch (err) {
    res.status(500).json({ error: 'Failed to count fontanelle' });
  }
}
