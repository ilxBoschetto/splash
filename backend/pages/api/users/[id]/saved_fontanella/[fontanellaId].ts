// /pages/api/users/[id]/saved_fontanella.ts
import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import SavedFontanella from '@models/SavedFontanella';
import withCors from '@lib/withCors';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const { id, fontanellaId } = req.query;

  if (typeof fontanellaId !== 'string' || typeof id !== 'string') {
    return res.status(400).json({ error: 'Errore nella richiesta' });
  }

  switch (req.method) {
    case 'DELETE':
      try {
        if (!fontanellaId || typeof fontanellaId !== 'string') {
          return res.status(400).json({ error: 'fontanellaId è richiesto per la cancellazione' });
        }

        const deleted = await SavedFontanella.findOneAndDelete({ userId: id, fontanellaId });
        if (!deleted) {
          return res.status(404).json({ error: 'Fontanella non trovata per questo utente' });
        }

        return res.status(200).json({ message: 'Fontanella rimossa' });
      } catch (err: any) {
        return res.status(500).json({ error: 'Errore nella rimozione della fontanella' });
      }

    default:
      return res.status(405).json({ error: 'Metodo non consentito' });
  }
}
export default withCors(handler);