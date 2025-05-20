import dbConnect from '../../lib/mongodb';
import User from '../../models/User';
import corsMiddleware from '../../lib/cors';
import jwt from 'jsonwebtoken';

export default async function handler(req, res) {
  await corsMiddleware(req, res);

  if (req.method !== 'GET') {
    return res.status(405).json({ message: 'Metodo non consentito' });
  }

  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token mancante' });
  }

  try {
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    await dbConnect();

    const user = await User.findById(decoded.userId).select('name email createdAt');

    if (!user) {
      return res.status(404).json({ message: 'Utente non trovato' });
    }

    return res.status(200).json({
      name: user.name,
      email: user.email,
      created_at: user.createdAt,
    });
  } catch (err) {
    console.error(err);
    return res.status(401).json({ message: 'Token non valido' });
  }
}
