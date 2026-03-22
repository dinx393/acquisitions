# Используем официальный Node.js образ
FROM node:20

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm install

# Копируем весь код проекта
COPY ./src ./src

ENV DATABASE_URL=${DATABASE_URL}

# Экспонируем порт
EXPOSE 3000

# Команда для запуска сервера
CMD ["node", "--watch", "src/index.js"]