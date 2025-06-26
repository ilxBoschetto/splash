import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import User from '@models/User';
import * as bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import corsMiddleware from '@lib/cors';

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  await corsMiddleware(req, res);

  if (req.method !== 'POST') {
    return res.status(405).end('Method Not Allowed');
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email e password sono richiesti' });
  }

  await dbConnect();

  let isDevMode = false;
  let user = null;

  // Controllo DEV: bcrypt.compare è async, va awaitato
  if (
    email === process.env.ADMIN_USERNAME &&
    await bcrypt.compare(password, process.env.ADMIN_PASSWORD || '')
  ) {
    isDevMode = true;
  }

  if (!isDevMode) {
    user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: 'Email o password errati' });
    }
    const passwordMatch = await bcrypt.compare(password, user.passwordHash);
    if (!passwordMatch) {
      return res.status(401).json({ error: 'Email o password errati' });
    }
  } else {
    // In dev mode, carichiamo utente admin per avere _id
    user = await User.findOne({ email: process.env.ADMIN_USERNAME });
    if (!user) {
      return res.status(401).json({ error: 'Utente admin non trovato' });
    }
  }

  const token = jwt.sign({ userId: user._id.toString() }, JWT_SECRET, { expiresIn: '7d' });

  return res.status(200).json({
    token,
    user: { id: user._id, email: user.email, name: user.name },
  });
}
