// pages/api/reports/index.ts
import type { NextApiRequest, NextApiResponse } from "next";
import dbConnect from "@lib/mongodb";
import withCors from "@lib/withCors";
import { getReports, createReport } from "@controllers/reportController";
import { getUserFromRequest, verifyToken } from "@lib/auth";
import formidable from "formidable";
import fs from "fs";
import path from "path";
import crypto from "crypto";

export const config = {
  api: {
    bodyParser: false, // Disabilita il body parser di Next per usare formidable
  },
};

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  await dbConnect();

  try {
    const currentUser = await getUserFromRequest(req);
    if (!currentUser) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    switch (req.method) {
      //#region GET /api/reports
      case "GET": {
        let user = verifyToken(req);
        if (!user || !user.userId) {
          return res
            .status(401)
            .json({ error: "Unauthorized: Invalid or missing token" });
        }
        const reports = await getReports(currentUser);
        return res.status(200).json({ reports });
      }
      //#endregion

      //#region POST /api/reports
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
            console.error("Errore parsing form:", err);
            return res.status(500).json({ error: "Errore parsing form" });
          }

          try {
            const fontanellaId = fields.fontanellaId?.toString();
            const type = Number(fields.type);
            const description = fields.description?.toString() || null;
            const value = fields.value?.toString() || null;

            if (!fontanellaId || isNaN(type)) {
              return res.status(400).json({ error: "Missing required fields" });
            }

            let imageFilename: string | null = null;
            const file = Array.isArray(files.image)
              ? files.image[0]
              : files.image;

            if (file) {
              const ext = path.extname(file.originalFilename || "");
              const randomName = crypto.randomBytes(16).toString("hex");
              imageFilename = `${randomName}${ext}`;
              const finalPath = path.join(uploadDir, imageFilename);

              await fs.promises.copyFile(file.filepath, finalPath);
              await fs.promises.unlink(file.filepath);
            }

            // Se c’è un’immagine, il value diventa il nome del file
            const finalValue = imageFilename ?? value;

            await createReport(
              fontanellaId,
              currentUser,
              type,
              finalValue,
              imageFilename,
              description
            );

            return res.status(200).json({
              message: "Report created successfully",
              image: imageFilename,
            });
          } catch (e: any) {
            console.error("Errore salvataggio report:", e);
            return res.status(500).json({ error: e.message });
          }
        });

        break;
      }
      //#endregion

      default: {
        res.setHeader("Allow", ["GET", "POST"]);
        return res.status(405).end("Method Not Allowed");
      }
    }
  } catch (err) {
    console.error(`/${req.method} /reports error:`, err);
    return res.status(500).json({
      error: `Failed to ${req.method === "GET" ? "fetch" : "create"} reports`,
    });
  }
};

export default withCors(handler);
