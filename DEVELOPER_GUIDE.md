# Developer Guide - Acquisitions App

## Project Overview

Backend API for user acquisition management built with Node.js, Express, and SQLite/PostgreSQL.

**Tech Stack:**
- **Runtime:** Node.js 20 (via Docker)
- **Framework:** Express.js 5.x
- **Database:** SQLite (development) / PostgreSQL Neon (production)
- **Authentication:** JWT + bcrypt
- **Validation:** Zod
- **Logging:** Winston
- **Security:** Helmet, CORS, rate limiting (Arcjet)

## Development Setup

### Prerequisites
- Docker & Docker Compose
- (Optional) Local Node.js 20+ if developing outside Docker

### Quick Start

```bash
# 1. Clone & install
git clone <repo>
cd acquisitions
npm install  # or skip if using Docker only

# 2. Start development environment
docker compose -f docker-compose.dev.yml up --build

# 3. Test API
curl http://localhost:3001/health
```

### Environment Variables

**Development (.env.development):**
```env
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug
DATABASE_FILE=./db/dev.db
JWT_SECRET=supersecretkey123
ARCJET_KEY=<your_arcjet_key>
```

**Production (.env.production):**
See [DEPLOYMENT_QUICK_START.md](./DEPLOYMENT_QUICK_START.md)

## Project Structure

```
acquisitions/
├── src/
│   ├── config/           # App configuration
│   │   ├── database.js   # DB adapter (SQLite/Neon)
│   │   ├── logger.js     # Winston logger setup
│   │   └── arcjet.js     # Rate limiting/security
│   │
│   ├── controllers/      # HTTP request handlers
│   │   └── auth.controller.js
│   │
│   ├── services/         # Business logic
│   │   └── auth.services.js (signup, signin, password hashing)
│   │
│   ├── routes/          # API endpoints
│   │   └── auth.routes.js
│   │
│   ├── middleware/      # Express middleware
│   │   └── security.middleware.js
│   │
│   ├── validations/     # Input validation schemas (Zod)
│   │   └── auth.validation.js
│   │
│   ├── utils/          # Helper functions
│   │   ├── jwt.js
│   │   ├── cookies.js
│   │   └── format.js
│   │
│   ├── app.js          # Express app setup
│   ├── server.js       # Server startup
│   └── index.js        # Entry point
│
├── db/                 # Database files (SQLite)
│   └── dev.db         # Development database
│
├── scripts/
│   ├── dev.sh         # Development startup script
│   └── deploy-prod.sh # Production deployment script
│
├── logs/              # Application logs
│
├── docker-compose.dev.yml    # Development environment
├── docker-compose.prod.yml   # Production environment
├── Dockerfile               # Multi-stage build
│
├── DEPLOYMENT.md            # Detailed deployment guide
├── DEPLOYMENT_QUICK_START.md # Quick 2-minute setup
└── DEVELOPER_GUIDE.md       # This file
```

## API Endpoints

### Authentication

**POST /api/auth/sign-up** - Register new user
```bash
curl -X POST http://localhost:3001/api/auth/sign-up \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "secure123"
  }'
```

**POST /api/auth/sign-in** - Login user
```bash
curl -X POST http://localhost:3001/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "secure123"
  }'
```

**POST /api/auth/sign-out** - Logout user
```bash
curl -X POST http://localhost:3001/api/auth/sign-out
```

### System

**GET /health** - Health check
```bash
curl http://localhost:3001/health
```

## Database Architecture

### Development (SQLite)

**Location:** `./db/dev.db`  
**Adapter:** `src/config/database.js` (DatabaseAdapter class)

**Features:**
- Promise-based wrapper around sqlite3
- Methods: `get()`, `run()`, `all()`, `exec()`
- Auto-creates tables on startup

**Schema:**
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT DEFAULT 'user',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### Production (PostgreSQL - Neon)

**Configuration:** `DATABASE_URL` in `.env.production`  
**ORM:** Drizzle ORM (prepared for future use)

**Current Status:**
- Adapter ready: `src/config/database.js` (production path)
- Uses `@neondatabase/serverless` + `drizzle-orm/neon-http`
- TODO: Full Drizzle migration system (currently manual SQL)

## Common Development Tasks

### Add New Route

1. Create controller method in `src/controllers/`
2. Add validation schema in `src/validations/`
3. Create business logic in `src/services/`
4. Define route in `src/routes/`
5. Register route in `src/app.js`

### Add New Database Table

1. Update `src/config/database.js` → `db.exec()` for auto-initialization
2. Or create manual migration (for Neon setup)

### Run Linter

```bash
# Inside or outside Docker
npm run lint      # Show errors
npm run lint:fix  # Auto-fix
```

### Format Code

```bash
npm run format         # Write formatted files
npm run format:check   # Check without writing
```

## Environment Switching

**Development (SQLite, hot reload, debug logs):**
```bash
docker compose -f docker-compose.dev.yml up
```

**Production (PostgreSQL, optimized, info logs):**
```bash
./scripts/deploy-prod.sh
```

## Troubleshooting

### Container won't start
```bash
docker compose -f docker-compose.dev.yml logs app
```

### Port 3001 already in use
```bash
# Check what's using it
lsof -i :3001

# Change in docker-compose.dev.yml: "3001:3000" → "3002:3000"
```

### Database file locked
```bash
# Stop all containers and remove volume
docker compose -f docker-compose.dev.yml down -v
```

### Hot reload not working
```bash
# Restart with --build
docker compose -f docker-compose.dev.yml up --build
```

## Security Notes

1. **Never commit `.env.production`** to git
2. **JWT_SECRET:** Use strong random string (min 32 chars)
3. **Passwords:** Always hashed with bcrypt (10 rounds)
4. **CORS:** Configured for your domain (not wildcard)
5. **Rate limiting:** Arcjet configured for auth endpoints
6. **Helmet:** Security headers automatically added

## Performance Tips

1. **Enable gzip compression** in production nginx
2. **Use database indexes** on email field (unique constraint already set)
3. **Cache tokens** in memory if many concurrent requests
4. **Monitor logs** in production (`docker logs -f acquisitions-app-prod`)

## Useful Docker Commands

```bash
# Development
docker compose -f docker-compose.dev.yml up          # Start
docker compose -f docker-compose.dev.yml down        # Stop
docker compose -f docker-compose.dev.yml logs -f app  # Logs

# Production
docker compose -f docker-compose.prod.yml up --build -d
docker logs -f acquisitions-app-prod

# General
docker stats acquisitions-app-dev   # Resource usage
docker exec acquisitions-app-dev npm run lint  # Run inside container
```

## Git Workflow

1. Create feature branch: `git checkout -b feature/name`
2. Make changes and test locally
3. Commit with clear messages: `git commit -m "feat: description"`
4. Push and create PR
5. After merge, pull main: `git pull origin main`

## Resources

- [Express.js Docs](https://expressjs.com/)
- [SQLite Docs](https://www.sqlite.org/docs.html)
- [Drizzle ORM](https://orm.drizzle.team/)
- [Neon Database](https://neon.tech/docs/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc7519)

## Contact & Support

For deployment questions: See [DEPLOYMENT.md](./DEPLOYMENT.md)  
For quick setup: See [DEPLOYMENT_QUICK_START.md](./DEPLOYMENT_QUICK_START.md)  
For code questions: Check inline comments or open issue
