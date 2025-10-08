import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import User from "@models/User";
import withCors from "@/lib/withCors";
import withLastRequest from "@/lib/withLastRequest";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Metodo non consentito" });
  }

  const { token } = req.body;

  if (!token || typeof token !== "string") {
    return res.status(400).json({ error: "Token non valido" });
  }

  await dbConnect();

  const user = await User.findOne({ confirmationCode: token });

  if (!user) {
    return res
      .status(404)
      .json({ error: "Codice di conferma non valido o già usato" });
  }

  user.isConfirmed = true;
  user.confirmationCode = null;
  await user.save();

  return res.status(200).json({ message: "Email confermata con successo" });
};

export default withCors(withLastRequest(handler));
