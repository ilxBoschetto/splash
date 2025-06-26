import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import User from '@models/User';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { sendRegistrationEmail } from '@lib/emailTemplates';
import withCors from '@lib/withCors';

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'OPTIONS') {
    // CORS preflight request
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Metodo non consentito' });
  }

  const { name, email, password } = req.body;

  // Validazione base dei campi
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Tutti i campi sono obbligatori' });
  }

  await dbConnect();

  // Controlla se l’utente esiste già
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return res.status(409).json({ error: 'Utente già registrato' });
  }

  // Hash della password con bcryptjs
  const passwordHash = await bcrypt.hash(password, 10);

  // Crea utente NON confermato
  const user = await User.create({
    name,
    email,
    passwordHash,
    isConfirmed: false,
  });

  // Genera codice di conferma JWT (con scadenza 1 giorno)
  const confirmationCode = jwt.sign(
    { userId: user._id, email: user.email },
    JWT_SECRET,
    { expiresIn: '1d' }
  );

  try {
    // Invia email di conferma con il token
    await sendRegistrationEmail({
      email: user.email,
      name: user.name,
      confirmationLink: confirmationCode
    });
  } catch (err) {
    console.error('Errore invio email conferma:', err);
    // Decide di rispondere con errore ma mantiene l’utente creato
    return res.status(500).json({ error: 'Registrazione riuscita ma errore invio email conferma' });
  }

  // Non si invia token di sessione, si aspetta conferma email
  return res.status(201).json({
    message: 'Utente registrato con successo. Controlla la tua email per confermare l’account.',
  });
}

export default withCors(handler);
