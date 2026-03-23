// auth.services.js
import logger from '#config/logger.js';
import bcrypt from 'bcrypt';
import { db } from '#config/database.js';

// Хеширование пароля
export const hashPassword = async (password) => {
  try {
    return await bcrypt.hash(password, 10);
  } catch (e) {
    logger.error(`Error hashing the password: ${e}`);
    throw new Error('Error hashing password');
  }
};

// Проверка пароля
export const comparePassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (e) {
    logger.error(`Error comparing password: ${e}`);
    throw new Error('Error comparing password');
  }
};

// Создание пользователя
export const createUser = async ({ name, email, password, role = 'user' }) => {
  try {
    logger.info('👉 createUser START', { name, email });

    // Проверяем существование пользователя
    const existingUser = await db.get('SELECT * FROM users WHERE email = ?', [email]);
    logger.info('👉 existingUser:', existingUser);

    if (existingUser) {
      throw new Error('User already exists');
    }

    const password_hash = await hashPassword(password);
    logger.info('👉 password hashed');

    const result = await db.run(
      `INSERT INTO users (name, email, password, role)
       VALUES (?, ?, ?, ?)`,
      [name, email, password_hash, role]
    );

    logger.info('👉 insert result:', result);

    // Получаем нового пользователя
    const newUser = await db.get(
      'SELECT id, name, email, role, created_at FROM users WHERE id = ?',
      [result.lastID]
    );

    logger.info('👉 newUser:', newUser);

    return newUser;
  } catch (e) {
    logger.error('❌ CREATE USER ERROR:', e);
    throw e; // контроллер обработает ошибку
  }
};

// Аутентификация пользователя
export const authenticateUser = async ({ email, password }) => {
  try {
    const user = await db.get('SELECT * FROM users WHERE email = ?', [email]);

    if (!user) {
      throw new Error('User not found');
    }

    const isPasswordValid = await comparePassword(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid password');
    }

    logger.info(`User ${email} authenticated successfully`);

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    };
  } catch (e) {
    logger.error('❌ AUTHENTICATE USER ERROR:', e);
    throw e;
  }
};