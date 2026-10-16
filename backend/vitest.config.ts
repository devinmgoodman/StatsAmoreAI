import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/**/*.test.ts'],
    env: { DB_HOST: '127.0.0.1', DB_PORT: '1', DB_NAME: 'test', DB_USER: 'test', DB_PASSWORD: 'test' },
  },
});
