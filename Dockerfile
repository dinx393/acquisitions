# === Базовая стадия ===
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

# === Development stage ===
FROM base AS development
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# === Production stage ===
FROM base AS production

# Создаем непривилегированного пользователя
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Устанавливаем только production зависимости
RUN npm ci --omit=dev --no-cache && npm cache clean --force

# Копируем исходный код
COPY --chown=nodejs:nodejs ./src ./src
COPY --chown=nodejs:nodejs ./db/prod.db ./db/prod.db
COPY --chown=nodejs:nodejs ./logger.js ./logger.js
COPY --chown=nodejs:nodejs ./database.js ./database.js

# Создаем папку для логов
RUN mkdir -p /app/logs && chmod 777 /app/logs

USER nodejs
EXPOSE 3000
CMD ["node", "src/index.js"]