import { createApp } from './app.js';
import { pool } from './db/pool.js';

const port = Number(process.env.PORT ?? 8080);
const server = createApp().listen(port, '0.0.0.0', () => {
  console.log(`API listening on :${port}`);
});

function shutdown() {
  server.close(() => {
    void pool.end().finally(() => process.exit(0));
  });
}
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
