// /pages/api/users/[id]/saved_fontanella_count.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import SavedFontanella from '@models/SavedFontanella';
import withCors from '@lib/withCors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const { id } = req.query;

  if (req.method !== 'GET') {
    return res.status(405).end('Method Not Allowed');
  }

  try {
    const count = await SavedFontanella.countDocuments({ userId: id as string });
    res.status(200).json({ count });
  } catch (err: any) {
    res.status(500).json({ error: "Failed to count user's saved fontanelle" });
  }
}
export default withCors(handler);