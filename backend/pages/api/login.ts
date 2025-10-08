import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import User from "@models/User";
import * as bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import withCors from "@lib/withCors";
import withLastRequest from "@/lib/withLastRequest";

const JWT_SECRET = process.env.JWT_SECRET || "super-secret-key";

async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") {
    return res.status(405).end("Method Not Allowed");
  }

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email e password sono richiesti" });
  }

  await dbConnect();

  let user = await User.findOne({ email });

  if (!user) {
    return res.status(401).json({ error: "Email o password errati" });
  }
  if (!user.isConfirmed) {
    return res.status(403).json({
      error:
        "Account non confermato. Controlla la tua email per completare la registrazione.",
    });
  }
  const passwordMatch = await bcrypt.compare(password, user.passwordHash);
  if (!passwordMatch) {
    return res.status(401).json({ error: "Email o password errati" });
  }

  const token = jwt.sign({ userId: user._id.toString() }, JWT_SECRET, {
    expiresIn: "7d",
  });

  return res.status(200).json({
    token,
    user: {
      id: user._id,
      email: user.email,
      name: user.name,
      isAdmin: user.isAdmin,
    },
  });
}

export default withCors(withLastRequest(handler));
