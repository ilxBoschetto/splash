// lib/auth.js
import jwt from 'jsonwebtoken'

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key'

export function verifyToken(req) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Token mancante o non valido')
  }

  const token = authHeader.split(' ')[1]
  const decoded = jwt.verify(token, JWT_SECRET)
  return decoded
}
