// lib/withAuth.ts
import type { NextApiRequest, NextApiResponse, NextApiHandler } from 'next'
import { verifyToken } from './auth'

export function withAuth(handler: NextApiHandler): NextApiHandler {
  return async (req: NextApiRequest, res: NextApiResponse) => {
    try {
      const user = verifyToken(req)
      ;(req as any).user = user
      return handler(req, res)
    } catch (error) {
      return res.status(401).json({ message: 'Token non valido' })
    }
  }
}
