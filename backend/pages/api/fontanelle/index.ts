import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import { getUserFromRequest, verifyToken } from "@lib/auth";
import {
  getFontanelle,
  saveFontanella,
} from "@controllers/fontanellaController";
import withCors from "@lib/withCors";

//#region Handler principale per /api/fontanelle
async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const { method } = req;

  try {
    switch (method) {
      //#region GET /api/fontanelle
      case "GET": {
        let user = null;
        try {
          user = verifyToken(req);
        } catch {
          // Ignora token mancante o invalido
        }

        const result = await getFontanelle(req, user);
        return res.status(200).json(result);
      }
      //#endregion

      //#region POST /api/fontanelle
      case "POST": {
        const user = verifyToken(req);
        
        if (!user || !user.userId) {
          return res
            .status(401)
            .json({ error: "Unauthorized: Invalid or missing token" });
        }

        const userEntity = await getUserFromRequest(req);

        // check if user is old enough
        const createdAt = new Date(userEntity.createdAt);
        const now = new Date();
        const diffMs = now.getTime() - createdAt.getTime();
        const diffDays = diffMs / (1000 * 60 * 60 * 24);

        if (diffDays < 1) {
          return res
            .status(403)
            .json({ error: "Forbidden: l'account deve essere registrato da almeno 1 giorno" });
        }

        const { name, lat, lon } = req.body;

        if (name == null || lat == null || lon == null) {
          return res
            .status(400)
            .json({ error: "Unable to create fontanella: Missing fields" });
        }

        try {
          const fontanella = await saveFontanella(
            {
              name: name,
              lat: lat,
              lon: lon,
            },
            user
          );

          res.status(200).json(fontanella);
        } catch (e: any) {
          res.status(400).json({ error: e.message });
        }
        break;
      }
      //#endregion

      //#region Metodo non supportato
      default:
        res.setHeader("Allow", ["GET", "POST"]);
        return res.status(405).end(`Method ${method} Not Allowed`);
      //#endregion
    }
  } catch (err: any) {
    console.error(`Error ${method} /fontanelle:`, err);
    if (err.message === "Missing or invalid fields") {
      return res.status(400).json({ error: err.message });
    }
    return res.status(500).json({ error: "Internal server error" });
  }
}
//#endregion

export default withCors(handler);
