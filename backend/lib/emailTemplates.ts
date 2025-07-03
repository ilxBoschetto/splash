import { registrationEmailHtml, registrationEmailText } from "@/templates/registrationEmailTemplate"

export interface EmailTemplate {
  to: string
  subject: string
  html: string
  text: string
}

interface RegistrationParams {
  email: string
  name: string
  confirmationLink: string
}

interface ForgotPasswordParams {
  email: string
  name: string
  resetLink: string
}

export function sendRegistrationEmail({
  email,
  name,
  confirmationLink
}: RegistrationParams): EmailTemplate {
  const safeName = sanitize(name)

  return {
    to: email,
    subject: 'Conferma la tua registrazione',
    html: registrationEmailHtml(safeName, confirmationLink),
    text: registrationEmailText(safeName, confirmationLink)
  }
}

export function forgotPasswordTemplate({
  email,
  name,
  resetLink
}: ForgotPasswordParams): EmailTemplate {
  return {
    to: email,
    subject: 'Reset della password',
    html: `
      <h1>Ciao ${sanitize(name)}!</h1>
      <p>Hai richiesto il reset della password. Clicca qui per procedere:</p>
      <a href="${resetLink}">Reset Password</a>
      <p>Se non hai richiesto il reset, ignora questa email.</p>
    `,
    text: `Ciao ${sanitize(name)}!\n\nHai richiesto il reset della password. Procedi qui: ${resetLink}\n\nSe non hai richiesto il reset, ignora questa email.`
  }
}

// Sanitizza il nome per evitare HTML injection
function sanitize(str: string): string {
  return str.replace(/[&<>"']/g, (char) =>
    ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;'
    }[char] || '')
  )
}
