import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import withCors from '@lib/withCors';
import Fontanella from '@models/Fontanella';
import { voteFontanella } from '@controllers/fontanellaController';
import { getUserFromRequest } from '@/lib/auth';

const handler = async (req: NextApiRequest, res: NextApiResponse) => {

    await dbConnect();
    const { id } = req.query;
    const { voteType } = req.body;

    if (!id || typeof id !== 'string') {
        return res.status(400).json({ message: 'ID fontanella mancante o non valido' });
    }

    if (!['up', 'down'].includes(voteType)) {
        return res.status(400).json({ message: 'Tipo di voto non valido' });
    }

    const user = await getUserFromRequest(req);
    if (!user) {
      return res.status(401).json({ message: 'Non autorizzato' });
    }

    const fontanella = await Fontanella.findById(id);
    if (!fontanella) {
      return res.status(404).json({ message: 'Fontanella non trovata' });
    }

    try{
        await voteFontanella(fontanella, user, voteType as 'up' | 'down');
        return res.status(200).json({ message: 'Fontanella votata' });
    } catch (error: any) {
        console.error(error);
        return res.status(500).json({ message: 'Errore interno', error: error.message });
    }
  
};

export default withCors(handler);
