// src/config/database.js
import 'dotenv/config';
import sqlite3 from 'sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';
import logger from './logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Promise-based wrapper for sqlite3
class DatabaseAdapter {
  constructor(sqlitePath) {
    this.db = new (sqlite3.verbose()).Database(sqlitePath, (err) => {
      if (err) {
        logger.error('SQLite connection error:', err);
      } else {
        logger.info('✅ SQLite DB connected at', sqlitePath);
      }
    });
  }

  // Wrapper для SELECT queries
  get(query, params = []) {
    return new Promise((resolve, reject) => {
      this.db.get(query, params, (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
  }

  // Wrapper для INSERT/UPDATE/DELETE queries
  run(query, params = []) {
    return new Promise((resolve, reject) => {
      this.db.run(query, params, function (err) {
        if (err) reject(err);
        else resolve({ lastID: this.lastID, changes: this.changes });
      });
    });
  }

  // Wrapper для SELECT all
  all(query, params = []) {
    return new Promise((resolve, reject) => {
      this.db.all(query, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
  }

  // Wrapper для выполнения SQL-скриптов
  exec(sql) {
    return new Promise((resolve, reject) => {
      this.db.exec(sql, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }

  close() {
    return new Promise((resolve, reject) => {
      this.db.close((err) => {
        if (err) reject(err);
        else resolve();
      });
    });
  }
}

let db;

if (process.env.NODE_ENV === 'production') {
  // TODO: DevOps - Настроить подключение к облачной БД (Neon/PostgreSQL)
  // Требуется DATABASE_URL с параметром подключения
  // Пример: postgresql://user:password@host:5432/dbname
  const neonModule = await import('@neondatabase/serverless');
  const { neon } = neonModule;

  const drizzleModule = await import('drizzle-orm/neon-http');
  const { drizzle } = drizzleModule;

  const sql = neon(process.env.DATABASE_URL);
  db = drizzle(sql);
} else {
  // Development: SQLite
  const sqlitePath = path.resolve(__dirname, '../../db/dev.db');
  db = new DatabaseAdapter(sqlitePath);

  // Инициализация таблицы users
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role TEXT DEFAULT 'user',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `).catch(err => logger.error('Failed to create users table:', err));
}

export { db };
