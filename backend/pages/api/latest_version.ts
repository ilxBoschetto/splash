import type { NextApiRequest, NextApiResponse } from 'next';
import * as fs from 'fs';
import * as path from 'path';

//#region Handler per leggere versione da version.json
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const versionFilePath = path.join(process.cwd(), 'version.json');

  try {
    // Legge il file in modo sincrono (va bene qui perché è un file piccolo)
    const versionRaw = fs.readFileSync(versionFilePath, 'utf8');
    const versionData = JSON.parse(versionRaw);

    const latestVersion = versionData.latestVersion;
    const minSupportedVersion = versionData.minSupportedVersion;
    const playStoreUrl = versionData.playStoreUrl;

    return res.status(200).json({
      latestVersion,
      minSupportedVersion,
      playStoreUrl,
    });
  } catch (error) {
    console.error('Errore nella lettura del file JSON:', error);
    return res.status(500).json({ error: 'Errore interno del server.' });
  }
}
//#endregion
