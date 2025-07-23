import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import { verifyToken } from '@lib/auth';
import { getFontanelle, createFontanella } from '@controllers/fontanellaController';
import withCors from '@lib/withCors';
import formidable from 'formidable';
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

export const config = {
  api: {
    bodyParser: false,
  },
};

//#region Handler principale per /api/fontanelle
async function handler(req: NextApiRequest, res: NextApiResponse) {
  await dbConnect();

  const { method } = req;

  try {
    switch (method) {
      //#region GET /api/fontanelle
      case 'GET': {
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
      case 'POST': {
        const user = verifyToken(req);
        if (!user || !user.userId) {
          return res.status(401).json({ error: 'Unauthorized: Invalid or missing token' });
        }

        const form = formidable({
          multiples: false,
          uploadDir: './public/uploads',
          keepExtensions: true,
        });

        form.parse(req, async (err, fields, files) => {
          if (err) return res.status(500).json({ error: 'Errore durante il parsing' });

          const { name, lat, lon } = fields;
          const imageFiles = files.image as formidable.File[];
          const imageFile = Array.isArray(imageFiles) ? imageFiles[0] : imageFiles;
          console.log(imageFile);

          let finalFilename: string | null = null;
          try {
            if (imageFile) {
              const originalFilename = imageFile.originalFilename || 'immagine.jpg';
              const filepath = imageFile.filepath || '';
              if (typeof filepath === 'string' && filepath !== '') {
                const ext = path.extname(imageFile.originalFilename);
                const randomName = crypto.randomBytes(16).toString('hex');
                finalFilename = `${randomName}${ext}`;

                const finalPath = path.join(process.cwd(), 'public/uploads', finalFilename);
                fs.renameSync(imageFile.filepath, finalPath);
              }
            }

            const fontanella = await createFontanella(
              {
                name: name as string,
                lat: parseFloat(lat as string),
                lon: parseFloat(lon as string),
                imageUrl: finalFilename,
              },
              user
            );

            res.status(201).json(fontanella);
          } catch (e: any) {
            res.status(400).json({ error: e.message });
          }
        });
        break;
      }
      //#endregion

      //#region Metodo non supportato
      default:
        res.setHeader('Allow', ['GET', 'POST']);
        return res.status(405).end(`Method ${method} Not Allowed`);
      //#endregion
    }
  } catch (err: any) {
    console.error(`Error ${method} /fontanelle:`, err);
    if (err.message === 'Missing or invalid fields') {
      return res.status(400).json({ error: err.message });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
}
//#endregion

export default withCors(handler);
