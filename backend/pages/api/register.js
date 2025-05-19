import dbConnect from '../../lib/mongodb';
import User from '../../models/User';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key';

export default async function handler(req, res) {

  if (req.method === 'OPTIONS') {
    return res.status(200).end(); // Risposta CORS preflight OK
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

  const user = await User.create({
    name,
    email,
    passwordHash,
  });

  const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' });

  return res.status(200).json({
    token,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
    },
  });
}
