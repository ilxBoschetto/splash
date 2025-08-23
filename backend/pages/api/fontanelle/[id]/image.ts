import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import { saveFontanella } from "@controllers/fontanellaController";
import formidable from "formidable";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import withCors from "@lib/withCors";
import { verifyToken } from "@/lib/auth";

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

        const form = formidable({
          multiples: false,
          uploadDir: "./public/uploads",
          keepExtensions: true,
        });

        form.parse(req, async (err, files) => {
          if (err)
            return res.status(500).json({ error: "Errore durante il parsing" });

          const imageFiles = files.image as formidable.File[];
          const imageFile = Array.isArray(imageFiles)
            ? imageFiles[0]
            : imageFiles;

          let finalFilename: string | null = null;
          try {
            if (imageFile) {
              const filepath = imageFile.filepath || "";
              if (typeof filepath === "string" && filepath !== "") {
                const ext = path.extname(imageFile.originalFilename);
                const randomName = crypto.randomBytes(16).toString("hex");
                finalFilename = `${randomName}${ext}`;

                const finalPath = path.join(
                  process.cwd(),
                  "public/uploads",
                  finalFilename
                );
                fs.copyFileSync(imageFile.filepath, finalPath);
                fs.unlinkSync(imageFile.filepath);
              }
            }

            const fontanella = await saveFontanella(
              {
                id: id,
                imageUrl: finalFilename,
              },
              user
            );

            res.status(200).json(fontanella);
          } catch (e: any) {
            res.status(400).json({ error: e.message });
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

export default withCors(handler);
