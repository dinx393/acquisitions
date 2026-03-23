# Project Scripts Reference

## Available Scripts

### Development

**`scripts/dev.sh`** - Development environment startup
```bash
./scripts/dev.sh
```
- Starts development environment with SQLite
- Hot-reload enabled
- Debug logging
- Access: http://localhost:3001

### Production

**`scripts/deploy-prod.sh`** - Production deployment automation
```bash
./scripts/deploy-prod.sh
```
- Validates configuration
- Detects database mode (SQLite or Neon)
- Starts production container
- Performs health checks
- Shows deployment status and next steps

**Requirements:**
- `.env.production` file must exist
- Docker daemon must be running

## NPM Scripts

Available via `npm run` or inside Docker container:

```bash
npm run dev              # Start development server (hot-reload)
npm run lint            # Run ESLint (show errors)
npm run lint:fix        # Auto-fix linting errors
npm run format          # Format code with Prettier
npm run format:check    # Check formatting without modifying
```

## Docker Compose Commands

### Development

```bash
# Start
docker compose -f docker-compose.dev.yml up --build

# Stop
docker compose -f docker-compose.dev.yml down

# View logs
docker compose -f docker-compose.dev.yml logs -f app

# Rebuild
docker compose -f docker-compose.dev.yml build --no-cache
```

### Production

```bash
# Using deployment script (recommended)
./scripts/deploy-prod.sh

# Or manually
docker compose -f docker-compose.prod.yml up --build -d
docker compose -f docker-compose.prod.yml down
docker logs -f acquisitions-app-prod
```

## Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) | Complete development reference | Backend developers |
| [DEPLOYMENT_QUICK_START.md](./DEPLOYMENT_QUICK_START.md) | 2-minute setup guide | DevOps engineers |
| [DEPLOYMENT.md](./DEPLOYMENT.md) | Full deployment documentation | DevOps/Operations |

## Quick Start Paths

### I'm a Developer
1. Read: [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)
2. Start dev: `docker compose -f docker-compose.dev.yml up`
3. Test: `curl http://localhost:3001/health`

### I'm DevOps
1. Read: [DEPLOYMENT_QUICK_START.md](./DEPLOYMENT_QUICK_START.md) (2 min)
2. Configure: `nano .env.production`
3. Deploy: `./scripts/deploy-prod.sh`
4. Monitor: `docker logs -f acquisitions-app-prod`

### I Need Detailed Info
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Complete production guide
- [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md) - Complete development guide

## Troubleshooting

**Script not executable?**
```bash
chmod +x ./scripts/deploy-prod.sh
```

**Permission denied?**
```bash
# Try with bash explicitly
bash ./scripts/deploy-prod.sh
```

**Docker not found?**
```bash
# Install Docker or use system package manager
# Ubuntu/Debian: sudo apt-get install docker.io docker-compose
# macOS: brew install docker docker-compose
```

## File Structure

```
scripts/
├── dev.sh          # Development startup
└── deploy-prod.sh  # Production deployment

Documentation:
├── DEVELOPER_GUIDE.md           # For developers
├── DEPLOYMENT.md                # Detailed deployment guide
├── DEPLOYMENT_QUICK_START.md    # Quick reference (2 min)
└── SCRIPTS_README.md            # This file
```

## Environment Files

```
.env.development    # Dev environment (SQLite)
.env.production     # Prod environment (must be configured)
.env.exemple        # Template with defaults
```

## Container Names

- **Development:** `acquisitions-app-dev`
- **Production:** `acquisitions-app-prod`

## Ports

- **Development:** localhost:3001 → container:3000
- **Production:** localhost:3000 → container:3000

## Support

- Script help: Check inline comments in script files
- Development help: See [DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)
- Deployment help: See [DEPLOYMENT.md](./DEPLOYMENT.md)
