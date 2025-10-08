import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import User from "@models/User";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { sendRegistrationEmail } from "@lib/emailTemplates";
import withCors from "@lib/withCors";
import { sendMail } from "@lib/nodemailer";
import { generateCode } from "@/helpers/generator";
import withLastRequest from "@/lib/withLastRequest";

const BASE_URL = process.env.NEXT_PUBLIC_BASE_URL;

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST")
    return res.status(405).json({ error: "Metodo non consentito" });

  const { name, email, password } = req.body;

  // Validazione base
  if (!name || !email || !password) {
    return res.status(400).json({ error: "Tutti i campi sono obbligatori" });
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: "Email non valida" });
  }

  try {
    await dbConnect();

    const existingUser = await User.findOne({ email, isConfirmed: true });
    if (existingUser) {
      return res.status(409).json({ error: "Utente già registrato" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const code = generateCode(20);

    const user = await User.create({
      name,
      email,
      passwordHash,
      isConfirmed: false,
      isAdmin: false,
      confirmationCode: code,
    });

    const confirmationLink = `${BASE_URL}/confirm-email?token=${code}`;

    const emailContent = sendRegistrationEmail({
      email: user.email,
      name: user.name,
      confirmationLink,
    });

    await sendMail(emailContent);

    return res.status(201).json({
      message:
        "Registrazione completata. Controlla la tua email per confermare 'account.",
    });
  } catch (err) {
    console.error("Errore durante la registrazione:", err);
    return res.status(500).json({ error: "Errore interno del server" });
  }
}

export default withCors(withLastRequest(handler));
