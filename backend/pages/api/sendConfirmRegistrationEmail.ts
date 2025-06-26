import nodemailer from 'nodemailer';
import { sendRegistrationEmail } from '@lib/emailTemplates';
import jwt from 'jsonwebtoken';

export default async function handler(req, res) {
  // TODO: make this work
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  const { to, name = 'Utente' } = req.body;

  if (!to) {
    return res.status(400).json({ message: 'Missing email' });
  }

  const confirmationCode = jwt.sign(
    { email: to },
    process.env.JWT_SECRET,
    { expiresIn: '1d' }
  );

  const confirmationLink = `${process.env.NEXT_PUBLIC_BASE_URL}/confirm?code=${confirmationCode}`;

  const emailContent = sendRegistrationEmail({ name, email: to, confirmationLink });

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT),
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
      text: emailContent.text,
    });

    return res.status(200).json({ message: 'Email inviata', info });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Errore invio email', error });
  }
}
