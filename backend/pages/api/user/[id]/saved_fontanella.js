// /pages/api/user/[id]/saved_fontanella.js
import dbConnect from '../../../../lib/mongodb';
import SavedFontanella from '../../../../models/SavedFontanella';
import corsMiddleware from '../../../../lib/cors';

export default async function handler(req, res) {
  await corsMiddleware(req, res);
  await dbConnect();

  const { id } = req.query;

  switch (req.method) {
    case 'GET':
      try {
        const savedList = await SavedFontanella.find({ userId: id });
        return res.status(200).json({ count: savedList.length, saved: savedList });
      } catch (err) {
        return res.status(500).json({ error: 'Errore nel recupero delle fontanelle salvate' });
      }

    case 'POST':
      try {
        const { fontanellaId } = req.body;
        if (!fontanellaId) {
          return res.status(400).json({ error: 'fontanellaId è richiesto' });
        }

        const alreadyExists = await SavedFontanella.findOne({ userId: id, fontanellaId });
        if (alreadyExists) {
          return res.status(409).json({ error: 'Fontanella già salvata' });
        }

        const newSaved = await SavedFontanella.create({ userId: id, fontanellaId });
        return res.status(201).json({ message: 'Fontanella salvata', saved: newSaved });
      } catch (err) {
        return res.status(500).json({ error: 'Errore nel salvataggio della fontanella' });
      }

    case 'DELETE':
      try {
        const { fontanellaId } = req.body;
        if (!fontanellaId) {
          return res.status(400).json({ error: 'fontanellaId è richiesto per la cancellazione' });
        }

        const deleted = await SavedFontanella.findOneAndDelete({ userId: id, fontanellaId });
        if (!deleted) {
          return res.status(404).json({ error: 'Fontanella non trovata per questo utente' });
        }

        return res.status(200).json({ message: 'Fontanella rimossa' });
      } catch (err) {
        return res.status(500).json({ error: 'Errore nella rimozione della fontanella' });
      }

    default:
      return res.status(405).json({ error: 'Metodo non consentito' });
  }
}
