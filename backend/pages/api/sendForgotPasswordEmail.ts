import nodemailer from "nodemailer";
import { forgotPasswordTemplate } from "@lib/emailTemplates";
import { log } from "@/helpers/logger";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ message: "Method not allowed" });
  }

  const { to, name, resetLink } = req.body;

  if (!to || !name || !resetLink) {
    return res.status(400).json({ message: "Missing required fields" });
  }

  const emailContent = forgotPasswordTemplate({ email: to, name, resetLink });

  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: process.env.SMTP_SECURE === "true",
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

    log.info(`Email di recupero password inviata a ${to}`);

    return res.status(200).json({ message: "Email inviata", info });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Errore invio email", error });
  }
}
