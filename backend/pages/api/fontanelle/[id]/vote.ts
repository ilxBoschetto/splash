import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import Fontanella from "@models/Fontanella";
import {
  getFontanellaVotes,
  voteFontanella,
} from "@controllers/fontanellaController";
import { getUserFromRequest, verifyToken } from "@/lib/auth";
import Vote from "@/models/Vote";
import withLastRequest from "@/lib/withLastRequest";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  await dbConnect();

  const { id } = req.query;

  if (req.method === "POST") {
    const { vote } = req.body;

    if (!id || typeof id !== "string") {
      return res
        .status(400)
        .json({ message: "ID fontanella mancante o non valido" });
    }

    if (!["up", "down"].includes(vote)) {
      return res.status(400).json({ message: "Tipo di voto non valido" });
    }

    const user = await getUserFromRequest(req);
    if (!user) {
      return res.status(401).json({ message: "Non autorizzato" });
    }

    const fontanella = await Fontanella.findById(id);
    if (!fontanella) {
      return res.status(404).json({ message: "Fontanella non trovata" });
    }

    try {
      await voteFontanella(fontanella, user, vote as "up" | "down");
      return res.status(200).json({ message: "Fontanella votata" });
    } catch (error: any) {
      console.error(error);
      return res
        .status(500)
        .json({ message: "Errore interno", error: error.message });
    }
  }

  if (req.method === "GET") {
    const response = await getFontanellaVotes(id);
    if (response == null) {
      return res.status(500).json({ message: "Errore interno" });
    }
    let userVote = null;
    try {
      const user = await getUserFromRequest(req);
      if (user) {
        const existingVote = await Vote.findOne({
          userId: user._id,
          fontanellaId: id,
        });
        if (existingVote) {
          userVote = existingVote.value;
        }
      }
    } catch (err) {}
    return res.status(200).json({
      ...response,
      userVote,
    });
  }

  return res.status(405).json({ error: "Metodo non supportato" });
};

export default withCors(withLastRequest(handler));
