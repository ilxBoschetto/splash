import User, { IUser } from '@/models/User'
import jwt from 'jsonwebtoken'
import type { NextApiRequest } from 'next'

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key'

export interface DecodedToken {
  userId: string
  email?: string
}

export function verifyToken(req: NextApiRequest): DecodedToken {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Missing or invalid token')
  }

  const token = authHeader.split(' ')[1]
  const decoded = jwt.verify(token, JWT_SECRET)

  return decoded as DecodedToken
}

export async function getUserFromRequest(req: NextApiRequest): Promise<IUser | null> {
  let user = verifyToken(req);
  const userModel = await User.findById(user.userId).select('-password')
  if (!userModel) return null

  return userModel;
}

export { IUser }
