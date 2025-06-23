export async function sendRegistrationEmail(email, name, confirmationCode) {
  return {
    subject: 'Conferma la tua registrazione',
    html: `
      <h1>Ciao ${name}!</h1>
      <p>Grazie per esserti registrato. Clicca qui per confermare il tuo account:</p>
      <a href="${confirmationCode}">Conferma registrazione</a>
      <p>Se non hai richiesto questa registrazione, ignora questa email.</p>
    `
  };
}

export function forgotPasswordTemplate(user) {
  return {
    subject: 'Reset della password',
    html: `
      <h1>Ciao ${user.name}!</h1>
      <p>Hai richiesto il reset della password. Clicca qui per procedere:</p>
      <a href="${user.resetLink}">Reset Password</a>
      <p>Se non hai richiesto il reset, ignora questa email.</p>
    `
  };
}
