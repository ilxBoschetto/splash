import { registrationEmailHtml, registrationEmailText } from "@/templates/registrationEmailTemplate"
import { forgotPasswordEmailHtml, forgotPasswordEmailText } from "@/templates/forgotPasswordEmailTemplate"

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
  const safeName = sanitize(name)

  return {
    to: email,
    subject: 'Reset della password',
    html: forgotPasswordEmailHtml(safeName, resetLink),
    text: forgotPasswordEmailText(safeName, resetLink)
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
