import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import { saveFontanella } from "@controllers/fontanellaController";
import formidable from "formidable";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import withCors from "@lib/withCors";
import { verifyToken } from "@/lib/auth";
import withLastRequest from "@/lib/withLastRequest";

export const config = {
  api: {
    bodyParser: false,
  },
};

//#region Handler principale per /api/fontanelle/[id]/image
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
      //#region GET /api/fontanelle/[id]/image

      //#endregion

      //#region PUT /api/fontanelle/[id]/image
      case "POST": {
        const user = verifyToken(req);
        if (!user || !user.userId) {
          return res
            .status(401)
            .json({ error: "Unauthorized: Invalid or missing token" });
        }

        const uploadDir = path.join(process.cwd(), "public/uploads");
        if (!fs.existsSync(uploadDir)) {
          fs.mkdirSync(uploadDir, { recursive: true });
        }

        const form = formidable({
          multiples: false,
          uploadDir,
          keepExtensions: true,
        });

        form.parse(req, async (err, fields, files) => {
          if (err) {
            return res.status(500).json({ error: "Errore durante il parsing" });
          }

          const file = Array.isArray(files.image)
            ? files.image[0]
            : files.image;
          let finalFilename: string | null = null;

          try {
            if (file) {
              const ext = path.extname(file.originalFilename || "");
              const randomName = crypto.randomBytes(16).toString("hex");
              finalFilename = `${randomName}${ext}`;

              const finalPath = path.join(uploadDir, finalFilename);

              await fs.promises.copyFile(file.filepath, finalPath);
              await fs.promises.unlink(file.filepath);
            }

            const fontanella = await saveFontanella(
              {
                id,
                imageUrl: finalFilename ? `${finalFilename}` : undefined,
              },
              user
            );

            return res.status(200).json(fontanella);
          } catch (e: any) {
            console.error("Errore salvataggio immagine:", e);
            return res.status(400).json({ error: e.message });
          }
        });

        break;
      }

      //#endregion

      //#region Metodo non supportato
      default:
        res.setHeader("Allow", ["GET", "POST", "DELETE"]);
        return res.status(405).end(`Method ${method} Not Allowed`);
      //#endregion
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
};
//#endregion

export default withCors(withLastRequest(handler));
