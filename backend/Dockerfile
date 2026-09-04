FROM node:22-alpine AS dependencies

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

# =========================
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

COPY --from=dependencies /app .

COPY . .

EXPOSE 5000

CMD ["node", "server.js"]