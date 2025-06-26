// pages/api/fontanelle/today.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import { countFontanelleToday } from '@controllers/fontanellaController';
import withCors from '@lib/withCors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  //#region GET /api/fontanelle/today
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET']);
    return res.status(405).end('Method Not Allowed');
  }
  //#endregion

  try {
    const count = await countFontanelleToday();
    return res.status(200).json({ count });
  } catch (err) {
    console.error('GET /fontanelle/today error:', err);
    return res.status(500).json({ error: 'Failed to count today\'s fontanelle' });
  }
}

export default withCors(handler);
