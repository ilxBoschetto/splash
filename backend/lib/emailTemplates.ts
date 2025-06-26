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
  return {
    to: email,
    subject: 'Conferma la tua registrazione',
    html: `
      <h1>Ciao ${sanitize(name)}!</h1>
      <p>Grazie per esserti registrato. Clicca qui per confermare il tuo account:</p>
      <a href="${confirmationLink}">Conferma registrazione</a>
      <p>Se non hai richiesto questa registrazione, ignora questa email.</p>
    `,
    text: `Ciao ${sanitize(name)}!\n\nGrazie per esserti registrato. Conferma il tuo account qui: ${confirmationLink}\n\nSe non hai richiesto questa registrazione, ignora questa email.`
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
