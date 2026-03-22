#!/bin/bash

# Docker Helper Script for Acquisitions Application
# Usage: ./docker-helper.sh [command] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "Docker Helper Script for Acquisitions Application"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  dev                 Start development environment with Neon Local"
    echo "  dev-full           Start development with all tools (Drizzle Studio)"
    echo "  prod               Start production environment"
    echo "  prod-proxy         Start production with nginx proxy"
    echo "  prod-monitor       Start production with monitoring"
    echo "  stop-dev           Stop development environment"
    echo "  stop-prod          Stop production environment"
    echo "  logs-dev           Show development logs"
    echo "  logs-prod          Show production logs"
    echo "  build              Build Docker images"
    echo "  clean              Clean Docker resources"
    echo "  migrate-dev        Run database migrations in development"
    echo "  migrate-prod       Run database migrations in production"
    echo "  studio             Start Drizzle Studio"
    echo "  health             Check application health"
    echo "  help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 dev             # Start development environment"
    echo "  $0 prod            # Start production environment"
    echo "  $0 logs-dev        # View development logs"
    echo "  $0 clean           # Clean all Docker resources"
}

# Development commands
start_dev() {
    print_info "Starting development environment with Neon Local..."
    docker-compose -f docker-compose.dev.yml up --build -d
    print_success "Development environment started!"
    print_info "Application: http://localhost:3000"
    print_info "Database: localhost:5432"
}

start_dev_full() {
    print_info "Starting development environment with all tools..."
    docker-compose -f docker-compose.dev.yml --profile tools up --build -d
    print_success "Development environment with tools started!"
    print_info "Application: http://localhost:3000"
    print_info "Drizzle Studio: http://localhost:4983"
    print_info "Database: localhost:5432"
}

# Production commands
start_prod() {
    if [ ! -f ".env.production.local" ]; then
        print_warning "No .env.production.local file found!"
        print_info "Creating template from .env.production..."
        cp .env.production .env.production.local
        print_warning "Please edit .env.production.local with your actual values before running production!"
        exit 1
    fi
    
    print_info "Starting production environment..."
    docker-compose -f docker-compose.prod.yml --env-file .env.production.local up --build -d
    print_success "Production environment started!"
    print_info "Application: http://localhost:3000"
}

start_prod_proxy() {
    if [ ! -f ".env.production.local" ]; then
        print_error "No .env.production.local file found! Run 'start_prod' first."
        exit 1
    fi
    
    print_info "Starting production environment with nginx proxy..."
    docker-compose -f docker-compose.prod.yml --env-file .env.production.local --profile proxy up -d
    print_success "Production environment with proxy started!"
    print_info "Application: http://localhost:80"
    print_info "HTTPS: http://localhost:443"
}

start_prod_monitor() {
    if [ ! -f ".env.production.local" ]; then
        print_error "No .env.production.local file found! Run 'start_prod' first."
        exit 1
    fi
    
    print_info "Starting production environment with monitoring..."
    docker-compose -f docker-compose.prod.yml --env-file .env.production.local --profile monitoring up -d
    print_success "Production environment with monitoring started!"
}

# Stop commands
stop_dev() {
    print_info "Stopping development environment..."
    docker-compose -f docker-compose.dev.yml down
    print_success "Development environment stopped!"
}

stop_prod() {
    print_info "Stopping production environment..."
    docker-compose -f docker-compose.prod.yml down
    print_success "Production environment stopped!"
}

# Log commands
logs_dev() {
    print_info "Showing development logs..."
    docker-compose -f docker-compose.dev.yml logs -f "${@:2}"
}

logs_prod() {
    print_info "Showing production logs..."
    docker-compose -f docker-compose.prod.yml logs -f "${@:2}"
}

# Build commands
build_images() {
    print_info "Building Docker images..."
    docker-compose -f docker-compose.dev.yml build
    docker-compose -f docker-compose.prod.yml build
    print_success "Docker images built successfully!"
}

# Clean commands
clean_resources() {
    print_warning "This will remove all stopped containers, unused networks, images, and build cache."
    read -p "Are you sure? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cleaning Docker resources..."
        docker-compose -f docker-compose.dev.yml down --volumes --remove-orphans
        docker-compose -f docker-compose.prod.yml down --volumes --remove-orphans
        docker system prune -a -f
        print_success "Docker resources cleaned!"
    else
        print_info "Cleanup cancelled."
    fi
}

# Migration commands
migrate_dev() {
    print_info "Running database migrations in development..."
    docker-compose -f docker-compose.dev.yml exec app npm run db:migrate
    print_success "Development database migrations completed!"
}

migrate_prod() {
    print_info "Running database migrations in production..."
    docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
    print_success "Production database migrations completed!"
}

# Studio command
start_studio() {
    print_info "Starting Drizzle Studio..."
    docker-compose -f docker-compose.dev.yml --profile tools up drizzle-studio -d
    print_success "Drizzle Studio started!"
    print_info "Access at: http://localhost:4983"
}

# Health check
check_health() {
    print_info "Checking application health..."
    
    # Check if development is running
    if docker-compose -f docker-compose.dev.yml ps -q app >/dev/null 2>&1; then
        if curl -f http://localhost:3000/health >/dev/null 2>&1; then
            print_success "Development environment is healthy!"
        else
            print_warning "Development environment is running but not responding to health checks"
        fi
    fi
    
    # Check if production is running
    if docker-compose -f docker-compose.prod.yml ps -q app >/dev/null 2>&1; then
        if curl -f http://localhost:3000/health >/dev/null 2>&1; then
            print_success "Production environment is healthy!"
        else
            print_warning "Production environment is running but not responding to health checks"
        fi
    fi
    
    if ! docker-compose -f docker-compose.dev.yml ps -q app >/dev/null 2>&1 && ! docker-compose -f docker-compose.prod.yml ps -q app >/dev/null 2>&1; then
        print_info "No environments are currently running"
    fi
}

# Main command handler
case "$1" in
    dev)
        start_dev
        ;;
    dev-full)
        start_dev_full
        ;;
    prod)
        start_prod
        ;;
    prod-proxy)
        start_prod_proxy
        ;;
    prod-monitor)
        start_prod_monitor
        ;;
    stop-dev)
        stop_dev
        ;;
    stop-prod)
        stop_prod
        ;;
    logs-dev)
        logs_dev "$@"
        ;;
    logs-prod)
        logs_prod "$@"
        ;;
    build)
        build_images
        ;;
    clean)
        clean_resources
        ;;
    migrate-dev)
        migrate_dev
        ;;
    migrate-prod)
        migrate_prod
        ;;
    studio)
        start_studio
        ;;
    health)
        check_health
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        print_error "No command provided!"
        echo ""
        show_help
        exit 1
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac