// auth.services.js
import logger from '#config/logger.js';
import bcrypt from 'bcrypt';
import db from '#db/db.js'; // твоя SQLite база

export const hashPassword = async (password) => {
  try {
    return await bcrypt.hash(password, 10);
  } catch (e) {
    logger.error(`Error hashing the password: ${e}`);
    throw new Error('Error hashing password');
  }
};

export const comparePassword = async (password, hashedPassword) => {
  try {
    return await bcrypt.compare(password, hashedPassword);
  } catch (e) {
    logger.error(`Error comparing password: ${e}`);
    throw new Error('Error comparing password');
  }
};

export const createUser = ({ name, email, password, role = 'user' }) => {
  return new Promise(async (resolve, reject) => {
    try {
      db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, row) => {
        if (err) {
          logger.error(`Error checking existing user: ${err}`);
          return reject(err);
        }

        if (row) {
          return reject(new Error('User already exists'));
        }

        const password_hash = await hashPassword(password);

        db.run(
          `INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)`,
          [name, email, password_hash, role],
          function (err) {
            if (err) {
              logger.error(`Error inserting new user: ${err}`);
              return reject(err);
            }

            logger.info(`User ${email} created successfully`);
            resolve({
              id: this.lastID,
              name,
              email,
              role
            });
          }
        );
      });
    } catch (e) {
      logger.error(`Error in createUser: ${e}`);
      reject(e);
    }
  });
};

export const authenticateUser = ({ email, password }) => {
  return new Promise((resolve, reject) => {
    try {
      db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, user) => {
        if (err) {
          logger.error(`Error fetching user: ${err}`);
          return reject(err);
        }

        if (!user) {
          return reject(new Error('User not found'));
        }

        const isPasswordValid = await comparePassword(password, user.password);
        if (!isPasswordValid) {
          return reject(new Error('Invalid password'));
        }

        logger.info(`User ${email} authenticated successfully`);
        resolve({
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
        });
      });
    } catch (e) {
      logger.error(`Error in authenticateUser: ${e}`);
      reject(e);
    }
  });
};