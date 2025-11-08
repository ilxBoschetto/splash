// /pages/api/auth/google.ts

import type { NextApiRequest, NextApiResponse } from "next";
import { OAuth2Client } from "google-auth-library";
import jwt from "jsonwebtoken";

// --- Config ---
const GOOGLE_CLIENT_ID = process.env.GOOGLE_WEB_CLIENT_ID!;
const JWT_SECRET = process.env.JWT_SECRET!;

const client = new OAuth2Client(GOOGLE_CLIENT_ID);

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Metodo non consentito" });
  }

  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: "Token mancante" });
    }

    // Verifica token Google
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload) {
      return res.status(401).json({ error: "Token Google non valido" });
    }

    const { sub: googleId, email, name, picture } = payload;

    // Qui puoi cercare o creare l'utente nel tuo DB
    const user = {
      id: googleId,
      email,
      name,
      picture,
      isAdmin: false, // oppure in base al DB
    };

    // Crea un token JWT interno della tua app
    const appToken = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: "7d",
    });

    return res.status(200).json({
      token: appToken,
      user,
    });
  } catch (err: any) {
    console.error("Errore login Google:", err);
    return res.status(500).json({ error: "Errore interno durante il login" });
  }
}
