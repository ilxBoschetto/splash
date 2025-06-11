import fs from 'fs';
import path from 'path';

export default async function handler(req, res) {
  const versionFilePath = path.join(process.cwd(), 'version.json');

  try {
    const versionData = JSON.parse(fs.readFileSync(versionFilePath, 'utf8'));

    const latestVersion = versionData.latestVersion;
    const minSupportedVersion = versionData.minSupportedVersion;
    const playStoreUrl = versionData.playStoreUrl;

    return res.status(200).json({
      latestVersion,
      minSupportedVersion,
      playStoreUrl
    });
  } catch (error) {
    console.error('Errore nella lettura del file JSON:', error);
    return res.status(500).json({ error: 'Errore interno del server.' });
  }
}
