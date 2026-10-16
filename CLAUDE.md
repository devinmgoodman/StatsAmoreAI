# StatsAmoreAI — Project Instructions

Amateur hockey league site: stats entry + analytics.

## Stack (fixed)
- Backend: Node.js + Express (TypeScript), REST/JSON only
- DB: PostgreSQL 15
- Frontend: React + TypeScript + Tailwind CSS (Vite)
- Frontend and backend talk **only** via REST over HTTP. No shared runtime code, no server-rendered pages. Shared types live in `packages/shared` (or are generated from the API schema).
- Everything runs in Docker via Docker Compose.

## Environments
| | Dev (MacBook Pro) | Prod (Mac Mini) |
|---|---|---|
| Run | `docker compose up` (hot reload, bind mounts) | `docker compose -f compose.yml -f compose.prod.yml up -d` |
| DB | local Postgres container, seeded | Postgres container, named volume, nightly `pg_dump` |
| Config | `.env.dev` (committed example: `.env.example`) | `.env.prod` on the Mac Mini only, never committed |

- Prod is exposed publicly; the domain/site is on SiteGround. Frontend is served from the Mac Mini stack unless noted otherwise. SiteGround handles DNS/domain only; no app code runs on it.
- TLS and public routing: reverse proxy container (Caddy) in prod.

## Deploy
- Repo: `~/Documents/Github/StatsAmoreAI` (local). Work on feature branches; PR into `main`.
- GitHub Actions:
  - On PR: lint, typecheck, test, build images.
  - On merge to `main`: deploy to Mac Mini via self-hosted runner (no inbound SSH exposure), run `docker compose pull/build`, run migrations, restart, health check, auto-rollback on failure.
- Secrets live in GitHub Actions secrets / Mac Mini `.env.prod`. Never in the repo.

## Repo layout
```
/backend      Express API (src/routes, src/services, src/db, migrations/)
/frontend     React app (src/pages, src/components, src/api)
/packages/shared  shared TS types (optional)
/.github/workflows
compose.yml  compose.prod.yml  .env.example
```

## Conventions
- TypeScript strict everywhere. ESLint + Prettier. No `any` without a comment.
- API: `/api/v1/...`, JSON, consistent error shape `{ error: { code, message } }`, input validation with zod, pagination on list endpoints.
- DB: SQL migrations only (node-pg-migrate), never edit applied migrations. Parameterized queries only. snake_case in DB, camelCase in API.
- Analytics: compute in SQL (views/materialized views) where practical, not in React.
- Auth: stat entry requires login (roles: admin, scorekeeper); public read-only analytics.
- Tests: Vitest (+ Supertest for API, Testing Library for UI). New endpoints need at least one test.
- Frontend: Tailwind utility classes, mobile-first (scorekeepers enter stats on phones/tablets at the rink). Data fetching via TanStack Query.

## Domain notes
- Core entities: seasons, teams, players, rosters, games, goals, assists, penalties, goalie stats, standings.
- Stat entry must be fast and forgiving: edit/correct after the fact, audit who changed what.

## How to work with me (Claude)
- Code first. No preambles, recaps, or "here's what I did" summaries.
- Editing existing code: edit the file directly or show only changed lines. Never reprint whole files.
- Explain only when something is non-obvious or a tradeoff matters.
- Ambiguous request: ask one short question, don't guess.
- Batch related changes into one response.
- Boilerplate, formatting, renaming, docstrings, simple CRUD: delegate to the local LLM tool if connected, then review its output.
- Don't re-read files already in context; ask for specific files/snippets.
- Don't add dependencies, change the stack, or alter deploy/CI behavior without asking.
- Never touch `.env.prod`, secrets, or production data. Destructive DB/migration changes: flag first.
- When a change affects dev/prod parity, Docker, or the workflow file, say so in one line.

## Open decisions (ask me before assuming)
- Auth method (sessions vs JWT), user accounts for players?
- Public domain/subdomain and whether the frontend and API share one origin.
- Backup retention and where backups are stored.
