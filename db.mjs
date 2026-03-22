// db.mjs
import sqlite3 from 'sqlite3';
import { open } from 'sqlite';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dbPath = path.resolve(__dirname, '../db/dev.db');

export const db = await open({
  filename: dbPath,
  driver: sqlite3.Database
});

console.log('✅ SQLite DB connected at', dbPath);