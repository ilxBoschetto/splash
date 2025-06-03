// /pages/api/user/[id]/saved_fontanella_count.js
import dbConnect from '../../../../lib/mongodb';
import SavedFontanella from '../../../../models/SavedFontanella';
import corsMiddleware from '../../../../lib/cors';

export default async function handler(req, res) {
  await corsMiddleware(req, res);
  await dbConnect();

  const { id } = req.query;

  if (req.method !== 'GET') {
    return res.status(405).end('Method Not Allowed');
  }

  try {
    const count = await SavedFontanella.countDocuments({ userId: id });
    res.status(200).json({ count });
  } catch (err) {
    res.status(500).json({ error: 'Failed to count user\'s saved fontanelle' });
  }
}
