// lib/cors.js
import Cors from 'cors'

// Inizializza il middleware una sola volta
const cors = Cors({
  methods: ['GET', 'HEAD', 'POST', 'PUT', 'DELETE'],
  origin: '*', // oppure specifica un dominio
})

function runMiddleware(req, res, fn) {
  return new Promise((resolve, reject) => {
    fn(req, res, (result) => {
      return result instanceof Error ? reject(result) : resolve(result)
    })
  })
}

export default async function corsMiddleware(req, res) {
  await runMiddleware(req, res, cors)
}
