export function registrationEmailHtml(name: string, confirmationLink: string): string {
  return `
    <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
      <h2 style="color: #2c3e50;">Ciao ${name},</h2>
      <p>Grazie per esserti registrato alla nostra piattaforma.</p>
      <p>Per completare la registrazione e attivare il tuo account, clicca sul pulsante qui sotto:</p>
      
      <div style="text-align: center; margin: 30px 0;">
        <a href="${confirmationLink}" style="background-color: #007bff; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;">
          Conferma registrazione
        </a>
      </div>
      
      <p>Se non hai richiesto questa registrazione, puoi ignorare questa email.</p>

      <hr style="margin: 40px 0; border: none; border-top: 1px solid #ccc;" />

      <footer style="font-size: 12px; color: #999;">
        <p>Questa email è stata inviata automaticamente dal nostro sistema. Ti preghiamo di non rispondere a questo messaggio.</p>
        <p>&copy; ${new Date().getFullYear()} Splash. Tutti i diritti riservati.</p>
      </footer>
    </div>
  `
}

export function registrationEmailText(name: string, confirmationLink: string): string {
  return `
Ciao ${name},

Grazie per esserti registrato alla nostra piattaforma.

Per completare la registrazione e attivare il tuo account, clicca sul seguente link:
${confirmationLink}

Se non hai richiesto questa registrazione, puoi ignorare questa email.

----------------------

Questa email è stata inviata automaticamente dal nostro sistema. Ti preghiamo di non rispondere a questo messaggio.

© ${new Date().getFullYear()} Splash. Tutti i diritti riservati.
  `.trim()
}
