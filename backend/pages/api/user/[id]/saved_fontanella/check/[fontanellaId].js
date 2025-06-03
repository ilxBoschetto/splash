// pages/api/user/[id]/saved_fontanelle/check/[fontanellaId].js
import dbConnect from '../../../../../../lib/mongodb';
import SavedFontanella from '../../../../../../models/SavedFontanella';
import corsMiddleware from '../../../../../../lib/cors';

export default async function handler(req, res) {
  await corsMiddleware(req, res);
  await dbConnect();

  const {
    query: { id, fontanellaId },
    method,
  } = req;

  switch (method) {
    case 'GET':
      try {
        const savedEntry = await SavedFontanella.findOne({ userId: id, fontanellaId });

        if (savedEntry) {
          res.status(200).json({ success: true, isSaved: true });
        } else {
          res.status(200).json({ success: true, isSaved: false });
        }
      } catch (error) {
        res.status(400).json({ success: false, error: error.message });
      }
      break;
    default:
      res.status(405).json({ success: false, error: 'Metodo non permesso' });
      break;
  }
}
