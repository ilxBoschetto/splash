import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';

// copy the .json file given from Firebase
const serviceAccountPath = path.join(process.cwd(), 'splash-firebase.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

export const firebaseAdmin = admin;
