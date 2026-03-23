#!/bin/bash

# Production deployment script for Acquisition App
# This script starts the application in production mode with SQLite or Neon Cloud Database

echo "🚀 Starting Acquisition App in Production Mode"
echo "=============================================="

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "❌ Error: .env.production file not found!"
    echo "   Please create .env.production with your production environment variables."
    echo "   Example:"
    echo "     cp .env.production .env.production"
    echo "     # Edit .env.production with your actual DATABASE_URL and secrets"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi

# Determine database mode from .env.production
if grep -q "^DATABASE_URL=postgresql://" .env.production; then
    DB_MODE="Neon Cloud Database (PostgreSQL)"
else
    DB_MODE="SQLite (local file-based)"
fi

echo "📦 Building and starting production container..."
echo "   - Using $DB_MODE"
echo "   - Running in optimized production mode"
echo "   - Container: acquisitions-app-prod"
echo ""

# Create db directory if it doesn't exist (for SQLite)
mkdir -p ./db

# Start production environment with docker compose
docker compose -f docker-compose.prod.yml up --build -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start production environment!"
    echo "   Check Docker and .env.production settings."
    exit 1
fi

# Wait for application to be ready
echo "⏳ Waiting for application to be ready..."
sleep 5

# Check health endpoint
MAX_ATTEMPTS=15
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:3000/health > /dev/null 2>&1; then
        echo "✅ Application is healthy!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "   Waiting... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "⚠️  Warning: Could not verify application health after $MAX_ATTEMPTS attempts"
    echo "   Check logs: docker logs -f acquisitions-app-prod"
fi

echo ""
echo "🎉 Production environment started successfully!"
echo ""
echo "📋 Service Information:"
echo "   API Endpoint: http://localhost:3000"
echo "   Health Check: http://localhost:3000/health"
echo "   Database Mode: $DB_MODE"
echo ""
echo "🔧 Useful Commands:"
echo "   View logs:        docker logs -f acquisitions-app-prod"
echo "   Stop app:         docker compose -f docker-compose.prod.yml down"
echo "   Stop & remove DB: docker compose -f docker-compose.prod.yml down -v"
echo "   Restart:          docker compose -f docker-compose.prod.yml restart"
echo ""
echo "📝 Next Steps:"
echo "   1. Test the API: curl http://localhost:3000/health"
echo "   2. Sign up: curl -X POST http://localhost:3000/api/auth/sign-up -H 'Content-Type: application/json' -d '{\"name\":\"Test\",\"email\":\"test@example.com\",\"password\":\"123456\"}'"
echo "   3. Monitor logs for errors: docker logs -f acquisitions-app-prod"
