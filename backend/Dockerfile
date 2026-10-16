# ─── Dev Stage (compose.yml) ─────────────────────────────────────────
FROM node:20-alpine AS dev
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
EXPOSE 8080
CMD ["npm", "run", "dev"]

# ─── Build Stage ─────────────────────────────────────────────────────
FROM node:20-alpine AS build

WORKDIR /app

# Install dependencies first (leverage Docker layer caching)
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Compile (fails the image build on error), then drop dev dependencies
RUN npm run build && npm prune --omit=dev

# ─── Production Stage ────────────────────────────────────────────────
FROM node:20-alpine AS production

# Add non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production dependencies from build stage
COPY --from=build /app/package.json ./
COPY --from=build /app/node_modules ./node_modules

# Copy application source
COPY --from=build /app/dist ./dist

ENV NODE_ENV=production
ENV PORT=8080

EXPOSE 8080

# Run as non-root user
USER appuser

CMD ["node", "dist/server.js"]