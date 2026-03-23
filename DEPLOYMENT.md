# Production Deployment Guide

## Overview

This project supports production deployment via Docker Compose with two database options:
- **SQLite** (file-based, for single-server deployments)
- **Neon Cloud Database** (PostgreSQL, for distributed deployments)

## Prerequisites

- Docker and Docker Compose installed
- `.env.production` file configured with your environment variables

## Quick Start

### 1. Prepare Environment Variables

```bash
# Copy the production environment template
cp .env.production .env.production

# Edit with your settings
nano .env.production
```

**For SQLite deployment:**
```env
PORT=3000
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=sqlite:./db/prod.db
JWT_SECRET=your-super-secure-jwt-secret-change-this-32-chars
CORS_ORIGIN=https://yourdomain.com
```

**For Neon Cloud deployment:**
```env
PORT=3000
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=postgresql://neondb_owner:PASSWORD@ENDPOINT.c-3.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
JWT_SECRET=your-super-secure-jwt-secret-change-this-32-chars
CORS_ORIGIN=https://yourdomain.com
```

### 2. Deploy Application

```bash
# Run the deployment script
./scripts/deploy-prod.sh

# Or manually with Docker Compose
docker compose -f docker-compose.prod.yml up --build -d
```

The script will:
- ✅ Check for `.env.production`
- ✅ Verify Docker is running
- ✅ Auto-detect database mode (SQLite vs Neon)
- ✅ Build and start the production container
- ✅ Wait for application health check
- ✅ Display useful commands and next steps

## Deployment Details

### Container Configuration

**Image:** Node.js 20 Alpine (minimal, optimized for production)

**Security:**
- Non-root user (`nodejs` with UID 1001)
- Dropped all Linux capabilities except `NET_BIND_SERVICE`
- Read-only filesystem with temporary writable mounts
- No new privileges allowed

**Resources:**
- CPU: 0.5-1.0 cores
- Memory: 256M-512M

**Health Check:**
- Endpoint: `GET /health`
- Interval: 30 seconds
- Timeout: 10 seconds
- Start period: 40 seconds

### Database Modes

#### SQLite Mode (Default)
- Database file: `./db/prod.db` (mounted as volume)
- Suitable for: Single-server, read-light applications
- Backup: Copy `./db/prod.db` file
- Limitations: Not suitable for high concurrency

#### Neon Cloud Mode
- Database: Managed PostgreSQL on Neon
- Suitable for: Distributed deployments, high availability
- Connection: Requires valid `DATABASE_URL` from Neon
- Backup: Managed by Neon (automatic)

## Operations

### View Logs

```bash
# Real-time logs
docker logs -f acquisitions-app-prod

# Last 100 lines
docker logs --tail 100 acquisitions-app-prod

# With timestamps
docker logs -f --timestamps acquisitions-app-prod
```

### Stop Application

```bash
# Stop without removing data
docker compose -f docker-compose.prod.yml stop

# Stop and remove containers (keep volumes)
docker compose -f docker-compose.prod.yml down

# Stop and remove everything including data
docker compose -f docker-compose.prod.yml down -v
```

### Restart Application

```bash
# Soft restart
docker compose -f docker-compose.prod.yml restart

# Full rebuild and restart
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up --build -d
```

### Database Operations

#### SQLite Backup

```bash
# Backup database
cp ./db/prod.db ./db/prod.db.backup

# Restore from backup
cp ./db/prod.db.backup ./db/prod.db
docker compose -f docker-compose.prod.yml restart
```

#### Neon Cloud
- Backups are managed automatically by Neon
- Use Neon Dashboard for restore operations
- See: https://neon.tech/docs/manage/backups

## Testing Deployment

### Health Check

```bash
# Should return 200 OK
curl http://localhost:3000/health

# Response example:
# {"status":"OK","timestamp":"2026-03-23T18:00:00.000Z","uptime":123.45}
```

### API Test

```bash
# Sign up
curl -X POST http://localhost:3000/api/auth/sign-up \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "secure123"
  }'

# Sign in
curl -X POST http://localhost:3000/api/auth/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "secure123"
  }'
```

## Troubleshooting

### Container won't start

```bash
# Check logs for errors
docker logs acquisitions-app-prod

# Common issues:
# 1. Missing .env.production → Create the file
# 2. Invalid DATABASE_URL → Verify in .env.production
# 3. Port 3000 in use → Change in docker-compose.prod.yml and .env.production
```

### Health check failing

```bash
# Wait longer and retry
sleep 10
curl http://localhost:3000/health

# Or check logs
docker logs acquisitions-app-prod | tail -50
```

### Database connection error

**SQLite:**
- Ensure `./db/` directory is writable
- Check disk space

**Neon:**
- Verify DATABASE_URL format
- Check network connectivity to Neon endpoint
- Ensure SSL/TLS is configured correctly

### Performance issues

```bash
# Check container resource usage
docker stats acquisitions-app-prod

# Check logs for slow queries or errors
docker logs -f acquisitions-app-prod
```

## Security Considerations

1. **JWT Secret:** Use a strong, randomly generated secret (min 32 characters)
2. **CORS Origin:** Set to your actual domain, not wildcard (`*`)
3. **Environment Variables:** Never commit `.env.production` to git
4. **Database Credentials:** Use Neon's secure connection strings
5. **Port Access:** Only expose port 3000 if needed; consider reverse proxy (nginx)

## Monitoring

### Log Files

Logs are stored in:
- Container: `/app/logs/` (tmpfs 50MB, ephemeral)
- Host: Consider mounting `./logs:/app/logs` for persistence

### Health Monitoring

Set up external monitoring:
```bash
# Cron job for periodic health checks (every 5 minutes)
*/5 * * * * curl -s http://localhost:3000/health || notify-admin
```

## Rolling Updates

```bash
# With zero downtime (if using reverse proxy):
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d  # Auto-recreates container
```

## Next Steps

1. Configure your reverse proxy (nginx) if needed
2. Set up SSL/TLS certificates
3. Configure monitoring and alerting
4. Plan backup strategy for SQLite
5. Document your deployment in team wiki
