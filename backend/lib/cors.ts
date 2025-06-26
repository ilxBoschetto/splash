// lib/cors.ts
import Cors from 'cors'
import type { NextApiRequest, NextApiResponse } from 'next'

// Inizializza il middleware una sola volta
const cors = Cors({
  methods: ['GET', 'HEAD', 'POST', 'PUT', 'DELETE'],
  origin: process.env.CORS_ORIGIN || '*', // usa variabile .env se presente
})

// Funzione che adatta il middleware CORS alle API route Next.js
function runMiddleware(
  req: NextApiRequest,
  res: NextApiResponse,
  fn: Function
): Promise<void> {
  return new Promise((resolve, reject) => {
    fn(req, res, (result: unknown) => {
      return result instanceof Error ? reject(result) : resolve()
    })
  })
}

// Funzione finale da chiamare nelle API route
export default async function corsMiddleware(
  req: NextApiRequest,
  res: NextApiResponse
): Promise<void> {
  await runMiddleware(req, res, cors)
}
