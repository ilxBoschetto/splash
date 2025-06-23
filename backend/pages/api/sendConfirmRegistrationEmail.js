import nodemailer from 'nodemailer';
import { registrationTemplate } from '@/lib/emailTemplates';
import jwt from 'jsonwebtoken';

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  const { to } = req.body;

  if (!to) {
    return res.status(400).json({ message: 'Missing email' });
  }

  // Genera un codice di conferma (qui JWT firmato)
  const confirmationCode = jwt.sign(
    { email: to },
    process.env.JWT_SECRET,
    { expiresIn: '1d' } // 1 giorno di validità
  );

  // Crea il link di conferma che l’utente cliccherà
  const confirmationLink = `${process.env.NEXT_PUBLIC_BASE_URL}/confirm?code=${confirmationCode}`;

  // Se vuoi, recupera il nome utente dal DB in base a 'to'
  // Per ora mettiamo un valore generico o estrai dal token se vuoi
  const name = 'Utente'; // oppure ricava da DB

  const emailContent = registrationTemplate({ name, confirmationLink });

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  try {
    const info = await transporter.sendMail({
      from: `"Splash" <${process.env.SMTP_USER}>`,
      to,
      subject: emailContent.subject,
      html: emailContent.html,
    });

    return res.status(200).json({ message: 'Email inviata', info });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Errore invio email', error });
  }
}
