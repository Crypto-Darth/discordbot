# syntax=docker/dockerfile:1

FROM node:20-alpine AS builder
WORKDIR /app

# Install deps first (better layer caching)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist

USER node

CMD ["node", "dist/bot.js"]
