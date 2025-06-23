import dbConnect from '../../lib/mongodb';
import User from '../../models/User';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import sendRegistrationEmail from '@/lib/emailTemplates';

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    return res.status(200).end(); // CORS preflight OK
  }
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Metodo non consentito' });
  }

  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Tutti i campi sono obbligatori' });
  }

  await dbConnect();

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return res.status(409).json({ error: 'Utente già registrato' });
  }

  const passwordHash = await bcrypt.hash(password, 10);

  // Creazione account NON confermato
  const user = await User.create({
    name,
    email,
    passwordHash,
    isConfirmed: false,
  });

  // Genera codice di conferma (token JWT con email e userId)
  const confirmationCode = jwt.sign(
    { userId: user._id, email: user.email },
    JWT_SECRET,
    { expiresIn: '1d' } // il codice scade in 1 giorno
  );

  try {
    // Manda email di conferma con nome e link con codice
    await sendRegistrationEmail(user.email, user.name, confirmationCode);
  } catch (err) {
    console.error('Errore invio email conferma:', err);
    // Se vuoi, puoi eliminare l’utente creato o lasciare la registrazione così
    // Qui decidiamo di rispondere comunque OK ma con warning
    return res.status(500).json({ error: 'Registrazione riuscita ma errore invio email conferma' });
  }

  // NON mandiamo token di sessione, aspettiamo conferma via mail
  return res.status(201).json({
    message: 'Utente registrato con successo. Controlla la tua email per confermare l’account.',
  });
}
