# Deployment Quick Start

## TL;DR - 2 Minute Setup

```bash
# 1. Edit production config (replace placeholders with your values)
nano .env.production

# 2. Run deployment script
./scripts/deploy-prod.sh

# 3. Test API
curl http://localhost:3000/health
```

## What the Script Does

✅ Checks `.env.production` exists  
✅ Validates Docker is running  
✅ Auto-detects database mode (SQLite or PostgreSQL)  
✅ Builds & starts production container  
✅ Waits for application health  
✅ Shows you next steps  

## Configuration Examples

### Option 1: SQLite (Simple)

```env
# .env.production
PORT=3000
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=sqlite:./db/prod.db
JWT_SECRET=generate-a-long-random-string-here-minimum-32-chars
CORS_ORIGIN=https://yourdomain.com
```

**Pros:** Simple, single file backup  
**Cons:** Not for high concurrency  
**Backup:** `cp ./db/prod.db ./db/prod.db.backup`

### Option 2: Neon Cloud (Scalable)

```env
# .env.production
PORT=3000
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=postgresql://user:password@endpoint.neon.tech/dbname?sslmode=require
JWT_SECRET=generate-a-long-random-string-here-minimum-32-chars
CORS_ORIGIN=https://yourdomain.com
```

**Pros:** Managed, auto-backups, scalable  
**Cons:** Requires Neon account  
**Backup:** Automatic (see Neon Dashboard)

## Common Commands

```bash
# Deploy
./scripts/deploy-prod.sh

# View logs (live)
docker logs -f acquisitions-app-prod

# Stop
docker compose -f docker-compose.prod.yml down

# Restart
docker compose -f docker-compose.prod.yml restart

# Remove everything including database
docker compose -f docker-compose.prod.yml down -v
```

## Testing After Deploy

```bash
# Health check (should return 200)
curl http://localhost:3000/health

# Sign up (new user)
curl -X POST http://localhost:3000/api/auth/sign-up \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "pass123"
  }'

# Sign in
curl -X POST http://localhost:3000/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "pass123"
  }'
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "No such file or directory: .env.production" | Run `cp .env.production .env.production` and fill it |
| "Docker is not running" | Start Docker daemon |
| "Port 3000 already in use" | Change port in `.env.production` and `docker-compose.prod.yml` |
| Container exits immediately | Check: `docker logs acquisitions-app-prod` |
| Health check fails | Wait 10 seconds, app may still be starting |

## Details

For complete deployment guide, see: [DEPLOYMENT.md](./DEPLOYMENT.md)
