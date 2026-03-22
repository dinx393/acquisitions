#!/bin/bash

# Development startup script for Acquisition App using local SQLite
echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    echo "   Please copy .env.development from the template and update it."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi

# Create .local_db directory if it doesn't exist
mkdir -p .local_db

# Add .local_db to .gitignore if not already present
if ! grep -q ".local_db/" .gitignore 2>/dev/null; then
    echo ".local_db/" >> .gitignore
    echo "✅ Added .local_db/ to .gitignore"
fi

echo "📦 Building and starting development containers..."
docker compose -f docker-compose.dev.yml up --build -d

# Run local migrations with your migrate.mjs
echo "📜 Applying latest schema with local SQLite..."
docker compose -f docker-compose.dev.yml exec app node migrate.mjs

echo ""
echo "🎉 Development environment started!"
echo "   Application: http://localhost:5173"
echo "   Database: SQLite at ./db/dev.db"
echo ""
echo "To stop the environment, press Ctrl+C or run: docker compose down"