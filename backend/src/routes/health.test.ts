import request from 'supertest';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { createApp } from '../app.js';
import { pool } from '../db/pool.js';

describe('GET /api/v1/health', () => {
  afterEach(() => vi.restoreAllMocks());

  it('returns 200 when the database responds', async () => {
    vi.spyOn(pool, 'query').mockResolvedValue({} as never);
    const res = await request(createApp()).get('/api/v1/health');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: 'ok', db: 'up' });
  });

  // Uses the real pool pointed at a closed port (see vitest.config.ts) instead of a mocked rejection.
  it('returns 503 with the error shape when the database is unreachable', async () => {
    const res = await request(createApp()).get('/api/v1/health');
    expect(res.status).toBe(503);
    expect(res.body.error.code).toBe('DB_UNAVAILABLE');
  });
});
