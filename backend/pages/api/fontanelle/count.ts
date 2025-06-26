import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import { countFontanelle } from '@controllers/fontanellaController';
import withCors from '@lib/withCors';

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  if (req.method !== 'GET') {
    res.setHeader('Allow', ['GET']);
    return res.status(405).end('Method Not Allowed');
  }

  await dbConnect();

  try {
    const count = await countFontanelle();
    res.status(200).json({ count });
  } catch (error) {
    res.status(500).json({ error: 'Failed to count fontanelle' });
  }
};

export default withCors(handler);
