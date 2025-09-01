// pages/api/users/[id]/saved_fontanelle/check/[fontanellaId].ts
import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import SavedFontanella from '@models/SavedFontanella';
import withCors from '@lib/withCors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const {
    query: { id, fontanellaId },
    method,
  } = req;

  switch (method) {
    case 'GET':
      try {
        const savedEntry = await SavedFontanella.findOne({
          userId: id as string,
          fontanellaId: fontanellaId as string,
        });

        res.status(200).json({ success: true, isSaved: !!savedEntry });
      } catch (error: any) {
        res.status(400).json({ success: false, error: error.message });
      }
      break;

    default:
      res.status(405).json({ success: false, error: 'Metodo non permesso' });
      break;
  }
}
export default withCors(handler);