import type { NextApiRequest, NextApiResponse } from "next";
import { OAuth2Client } from "google-auth-library";
import jwt from "jsonwebtoken";
import User from "@/models/User";
import dbConnect from "@/lib/mongodb";
import { mapToUserDto } from "@/dtos/userLoginDto";

const GOOGLE_CLIENT_IDS = process.env.GOOGLE_WEB_CLIENT_IDS!.split(",");
const JWT_SECRET = process.env.JWT_SECRET!;

const client = new OAuth2Client();

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

    await dbConnect();

    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: GOOGLE_CLIENT_IDS,
    });

    const payload = ticket.getPayload();
    if (!payload) {
      return res.status(401).json({ error: "Token Google non valido" });
    }

    const { sub: googleId, email, name } = payload;

    if (!email) {
      return res.status(400).json({ error: "Email non fornita da Google" });
    }

    let user = await User.findOne({ email });

    if (!user) {
      user = await User.create({
        googleId,
        email,
        name,
        isAdmin: false,
        isConfirmed: true,
        passwordHash: null,
      });
      console.log(`Nuovo utente creato: ${email}`);
    }

    const appToken = jwt.sign({ userId: user._id.toString() }, JWT_SECRET, {
      expiresIn: "7d",
    });

    const userDto = mapToUserDto(user._id.toString(), user);

    return res.status(200).json({
      token: appToken,
      user: userDto,
    });
  } catch (err) {
    console.error("Errore login Google:", err);
    return res.status(500).json({ error: "Errore interno durante il login" });
  }
}
