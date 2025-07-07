export function forgotPasswordEmailHtml(name: string, resetLink: string): string {
  return `
    <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
      <h2 style="color: #2c3e50;">Ciao ${name},</h2>
      <p>Hai richiesto il reset della password del tuo account.</p>
      <p>Per procedere, clicca sul pulsante qui sotto:</p>

      <div style="text-align: center; margin: 30px 0;">
        <a href="${resetLink}" style="background-color: #dc3545; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
          Reset Password
        </a>
      </div>

      <p>Se non hai richiesto il reset della password, puoi ignorare questa email. Nessuna azione verrà effettuata.</p>

      <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;" />

      <footer style="font-size: 12px; color: #999;">
        <p>Questa email è stata inviata automaticamente dal nostro sistema. Ti preghiamo di non rispondere a questo messaggio.</p>
        <p>&copy; ${new Date().getFullYear()} Splash. Tutti i diritti riservati.</p>
      </footer>
    </div>
  `
}

export function forgotPasswordEmailText(name: string, resetLink: string): string {
  return `
Ciao ${name},

Hai richiesto il reset della password del tuo account.

Per procedere, clicca sul seguente link:
${resetLink}

Se non hai richiesto il reset della password, puoi ignorare questa email. Nessuna azione verrà effettuata.

----------------------

Questa email è stata inviata automaticamente dal nostro sistema. Ti preghiamo di non rispondere a questo messaggio.

© ${new Date().getFullYear()} Splash. Tutti i diritti riservati.
  `.trim()
}
