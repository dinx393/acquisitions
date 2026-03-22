// src/config/database.js
import 'dotenv/config';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

let db;

if (process.env.NODE_ENV === 'development') {
    // SQLite через динамический import
    const sqliteModule = await import('sqlite3');
    const sqlite3 = sqliteModule.default.verbose();

    const sqlitePath = path.resolve(__dirname, '../../db/dev.db');
    db = new sqlite3.Database(sqlitePath, (err) => {
        if (err) console.error('DB connection error:', err);
        else console.log('SQLite DB connected at', sqlitePath);
    });

} else {
    // Neon + Drizzle для prod
    const neonModule = await import('@neondatabase/serverless');
    const { neon, neonConfig } = neonModule;

    const drizzleModule = await import('drizzle-orm/neon-http');
    const { drizzle } = drizzleModule;

    const sql = neon(process.env.DATABASE_URL);
    db = drizzle(sql);
}

export { db };