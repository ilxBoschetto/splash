import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import User from "@models/User";
import bcrypt from "bcryptjs";
import withCors from "@/lib/withCors";
import withLastRequest from "@/lib/withLastRequest";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  if (req.method !== "POST") {
    return res.status(405).json({ message: "Metodo non consentito" });
  }

  const { token, password } = req.body;

  if (!token || typeof token !== "string") {
    return res.status(400).json({ message: "Token mancante o non valido" });
  }

  if (!password || typeof password !== "string") {
    return res.status(400).json({ message: "Password non valida" });
  }

  await dbConnect();

  const user = await User.findOne({
    resetPasswordToken: token,
    resetPasswordExpires: { $gt: new Date() },
  });

  if (!user) {
    return res.status(400).json({ message: "Token non valido o scaduto" });
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  user.passwordHash = hashedPassword;
  user.resetPasswordToken = null;
  user.resetPasswordExpires = null;
  await user.save();

  return res.status(200).json({ message: "Password aggiornata con successo" });
};

export default withCors(withLastRequest(handler));
