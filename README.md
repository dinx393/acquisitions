# Acquisitions Application

A Node.js application using Express.js with comprehensive Docker support for both development and production environments.

## 🏗️ Architecture

- **Backend**: Node.js with Express.js
- **Database (Development)**: SQLite
- **Database (Production)**: PostgreSQL via Neon (serverless)
- **Containerization**: Docker with multi-stage builds

## 📋 Prerequisites

- Docker and Docker Compose installed
- Node.js 20+ (for local development without Docker)
- Neon account and database setup

## 🚀 Quick Start

### Development Environment (SQLite)

1. **Clone and setup**:
   ```bash
   git clone <your-repo-url>
   cd acquisitions
   npm install
   ```

2. **Start development environment**:
   ```bash
   # With Docker (recommended)
   docker-compose -f docker-compose.dev.yml up --build
   
   # Or locally with Node.js
   npm run dev
   ```

3. **Access the application**:
   - Application: http://localhost:3001 (Docker) or http://localhost:3000 (local)

### Production Environment

1. **Configure production environment**:
   ```bash
   cp .env.production .env.production.local
   # Edit .env.production.local with your Neon PostgreSQL connection string
   # Example: postgresql://user:password@host.neon.tech/dbname
   ```

2. **Start production environment**:
   ```bash
   # TODO: DevOps - Setup and start production environment
   # - Configure DATABASE_URL environment variable with Neon PostgreSQL connection
   # - Deploy using docker-compose.prod.yml
   # - Configure nginx reverse proxy if needed
   # - Setup monitoring and health checks
   ```

## 🛍️ Project Structure

```
acquisitions/
├── src/                          # Application source code
│   ├── config/                   # Configuration files
│   │   └── database.js          # Database connection (SQLite/PostgreSQL)
│   ├── controllers/              # Route controllers
│   ├── middleware/               # Express middleware
│   ├── routes/                   # API routes
│   ├── services/                 # Business logic services
│   ├── utils/                    # Utility functions
│   ├── validations/              # Input validation schemas
│   ├── app.js                    # Express app configuration
│   ├── index.js                  # Application entry point
│   └── server.js                 # Server setup
├── db/                           # SQLite database (development)
├── logs/                         # Application logs
├── Dockerfile                    # Multi-stage Docker build
├── docker-compose.dev.yml        # Development with SQLite
├── docker-compose.prod.yml       # Production setup (PostgreSQL)
├── .env.development             # Development environment vars
├── .env.production              # Production environment template
└── package.json                 # Node.js dependencies
```

## 🔧 Environment Variables

### Development (.env.development)
```bash
# Server Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug

# Database configuration - Neon Local
DATABASE_URL=postgresql://postgres:postgres@neon-local:5432/acquisitions

# JWT Configuration
JWT_SECRET=supersecretkey123
```

### Production (.env.production)
```bash
# Server Configuration
PORT=3000
NODE_ENV=production
LOG_LEVEL=info

# Database configuration - Neon Cloud Database
DATABASE_URL=postgresql://neondb_owner:YOUR_PASSWORD@YOUR_ENDPOINT.c-3.eu-central-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require

# JWT Configuration (Use strong secret in production!)
JWT_SECRET=your-super-secure-jwt-secret-change-this-in-production-minimum-32-chars

# Production settings
CORS_ORIGIN=https://yourdomain.com
RATE_LIMIT_ENABLED=true
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 🗃️ Database Management

### Development with Neon Local

Neon Local automatically creates a local PostgreSQL-compatible database that mimics your Neon Cloud environment:

```bash
# Run database migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Generate new migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml --profile tools up drizzle-studio
```

### Production with Neon Cloud

The production setup connects directly to your Neon Cloud database:

```bash
# Run migrations in production (one-time setup)
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

## 🐛 Development Workflow

1. **Hot Reload**: The development setup includes volume mounting for hot reloading
2. **Logs**: Check logs with `docker-compose -f docker-compose.dev.yml logs -f app`
3. **Database Access**: Use Drizzle Studio or connect directly to localhost:5432
4. **Environment Switching**: Simply switch compose files for different environments

## 🚀 Production Deployment

### Docker Deployment

1. **Build for production**:
   ```bash
   docker build --target production -t acquisitions:latest .
   ```

2. **Run with environment variables**:
   ```bash
   docker run -d \\
     -p 3000:3000 \\
     -e DATABASE_URL="your-neon-cloud-url" \\
     -e JWT_SECRET="your-secure-secret" \\
     -e NODE_ENV=production \\
     --name acquisitions-prod \\
     acquisitions:latest
   ```

### Container Orchestration (Kubernetes/Docker Swarm)

The production compose file includes:
- Health checks
- Resource limits
- Security hardening
- Non-root user execution
- Read-only filesystem

## 📊 Monitoring and Health Checks

### Health Check Endpoint
The application should expose a health check endpoint at `/health`:

```javascript
// Add this to your Express app if not already present
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    database: 'connected' // Add DB connection check
  });
});
```

### Monitoring
- Application logs are mounted to `./logs`
- Health checks run every 30 seconds in production
- Optional monitoring container included in production setup

## 🔒 Security Considerations

### Development
- Uses default credentials (safe for local development)
- Debug logging enabled
- Hot reloading for rapid development

### Production
- Non-root user execution
- Read-only filesystem
- Security capabilities dropped
- Strong JWT secrets required
- Environment variable injection
- CORS and rate limiting configured

## 🛠️ Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   # Check what's using the port
   lsof -i :3000
   # Stop conflicting services or change port in compose file
   ```

2. **Database connection issues**:
   ```bash
   # Check Neon Local is running
   docker-compose -f docker-compose.dev.yml logs neon-local
   
   # Test database connection
   docker-compose -f docker-compose.dev.yml exec neon-local psql -U postgres -d acquisitions
   ```

3. **Build issues**:
   ```bash
   # Clean build
   docker-compose -f docker-compose.dev.yml down --volumes
   docker system prune -a
   docker-compose -f docker-compose.dev.yml up --build
   ```

### Logs

```bash
# Development logs
docker-compose -f docker-compose.dev.yml logs -f app

# Production logs
docker-compose -f docker-compose.prod.yml logs -f app

# All services
docker-compose -f docker-compose.dev.yml logs -f
```

## 📚 Additional Resources

- [Neon Database Documentation](https://neon.com/docs)
- [Neon Local Setup Guide](https://neon.com/docs/local/neon-local)
- [Drizzle ORM Documentation](https://orm.drizzle.team)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes using the development environment
4. Test with both development and production setups
5. Submit a pull request

---

**Note**: Always use strong, unique secrets in production environments and never commit them to version control.