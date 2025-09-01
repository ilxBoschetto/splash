import type { NextApiRequest, NextApiResponse } from 'next';
import dbConnect from '@lib/mongodb';
import User from '@models/User';
import crypto from 'crypto';
import withCors from '@/lib/withCors';
import nodemailer from 'nodemailer';
import { forgotPasswordTemplate } from '@lib/emailTemplates';

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Metodo non consentito' });
  }

  const { email } = req.body;

  if (!email || typeof email !== 'string') {
    return res.status(400).json({ message: 'Email non valida' });
  }

  await dbConnect();

  const user = await User.findOne({ email });

  if (!user) {
    return res.status(404).json({ message: 'Utente non trovato' });
  }

  const token = crypto.randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 1000 * 60 * 60);

  user.resetPasswordToken = token;
  user.resetPasswordExpires = expires;
  await user.save();

  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'http://localhost:3000';
  const resetLink = `${baseUrl}/reset-password?token=${token}`;

  const emailContent = forgotPasswordTemplate({
    email,
    name: user.name || 'utente',
    resetLink,
  });

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
      to: emailContent.to,
      subject: emailContent.subject,
      html: emailContent.html,
      text: emailContent.text,
    });

    return res.status(200).json({ message: 'Email inviata', info });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Errore invio email', error });
  }
};

export default withCors(handler);
