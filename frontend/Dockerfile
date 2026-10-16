# ─── Dev Stage (compose.yml) ─────────────────────────────────────────
FROM node:20-alpine AS dev
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000"]

# ─── Build Stage ─────────────────────────────────────────────────────
FROM node:20-alpine AS build

WORKDIR /app

# Install dependencies first (leverage Docker layer caching)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the Vite application
RUN npm run build

# ─── Production Stage ────────────────────────────────────────────────
FROM nginx:alpine AS production

# Copy custom nginx config (optional, for SPA routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]