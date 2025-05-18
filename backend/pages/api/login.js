import dbConnect from '../../lib/mongodb'
import User from '../../models/User'
import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import corsMiddleware from '../../lib/cors'

const JWT_SECRET = process.env.JWT_SECRET || 'super-secret-key'

export default async function handler(req, res) {
  await corsMiddleware(req, res)

  if (req.method !== 'POST') return res.status(405).end()

  const { email, password } = req.body

  await dbConnect()

  let isDevMode = false;

  if(email === process.env.ADMIN_USERNAME && bcrypt.compare(password, process.env.ADMIN_PASSWORD))
    isDevMode = true;

  if(!isDevMode){
    const user = await User.findOne({ email })
    if (!user) return res.status(401).json({ error: 'Email o password errati' })

    const match = await bcrypt.compare(password, user.passwordHash)
    if (!match) return res.status(401).json({ error: 'Email o password errati' })
  }
  
  const token = jwt.sign({ userId: user._id }, JWT_SECRET, { expiresIn: '7d' })

  return res.status(200).json({
    token,
    user: { id: user._id, email: user.email, name: user.name }
  })
}
