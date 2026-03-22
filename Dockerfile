# Многоэтапная сборка для оптимизации размера образа
FROM node:20-alpine AS base

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# === Development stage ===
FROM base AS development

# Устанавливаем все зависимости (включая devDependencies)
RUN npm ci

# Копируем весь код проекта
COPY . .

# Экспонируем порт для разработки
EXPOSE 3000

# Команда для запуска в режиме разработки
CMD ["npm", "run", "dev"]

# === Production stage ===
FROM base AS production

# Создаем пользователя для безопасности
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Устанавливаем только production зависимости
RUN npm ci --only=production --no-cache && \
    npm cache clean --force

# Копируем исходный код
COPY --chown=nodejs:nodejs ./src ./src
COPY --chown=nodejs:nodejs ./drizzle ./drizzle
COPY --chown=nodejs:nodejs ./database.js ./database.js
COPY --chown=nodejs:nodejs ./drizzle.config.js ./drizzle.config.js

# Переключаемся на непривилегированного пользователя
USER nodejs

# Экспонируем порт
EXPOSE 3000

# Команда для запуска в продакшене
CMD ["node", "src/index.js"]
