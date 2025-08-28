import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import {
  getFontanellaById,
  updateFontanella,
  deleteFontanella,
} from "@controllers/fontanellaController";
import withCors from "@lib/withCors";
import { getUserFromRequest } from "@/lib/auth";

//#region Handler principale per /api/fontanelle/[id]
const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  // Connessione al DB
  await dbConnect();

  // Estrazione dati da request
  const {
    query: { id },
    method,
  } = req;

  // Validazione id
  if (typeof id !== "string") {
    return res.status(400).json({ error: "Invalid id" });
  }

  try {
    switch (method) {
      //#region GET /api/fontanelle/[id]
      case "GET": {
        const fontanella = await getFontanellaById(id);
        if (!fontanella) return res.status(404).json({ error: "Not found" });
        // eventuali modifiche a fontanella qui
        return res.status(200).json(fontanella);
      }
      //#endregion

      //#region PUT /api/fontanelle/[id]
      case "PUT": {
        const { name, lat, lon } = req.body;
        if (
          !name ||
          typeof name !== "string" ||
          typeof lat !== "number" ||
          typeof lon !== "number"
        ) {
          return res.status(400).json({ error: "Missing or invalid fields" });
        }
        const updated = await updateFontanella(id, { name, lat, lon });
        if (!updated) return res.status(404).json({ error: "Not found" });
        return res.status(200).json(updated);
      }
      //#endregion

      //#region DELETE /api/fontanelle/[id]
      case "DELETE": {
        const user = await getUserFromRequest(req);
        if (!user.isAdmin)
          return res
            .status(403)
            .json({ error: "Forbidden: do not have permissions" });
        const deleted = await deleteFontanella(id);
        if (!deleted) return res.status(404).json({ error: "Not found" });
        return res.status(200).json({ success: true });
      }
      //#endregion

      //#region Metodo non supportato
      default:
        res.setHeader("Allow", ["GET", "PUT", "DELETE"]);
        return res.status(405).end(`Method ${method} Not Allowed`);
      //#endregion
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
};
//#endregion

export default withCors(handler);
