import { createServer } from 'http';

const server = createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/html' });
  res.end('<h1>🎉 Il port forwarding funziona con TypeScript!</h1>');
});

const PORT = 3000;

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server in ascolto su http://0.0.0.0:${PORT}`);
});
