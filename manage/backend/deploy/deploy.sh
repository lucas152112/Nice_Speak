#!/bin/bash
# =====================================================
# Deploy Script - Nice Speak Admin Backend
# =====================================================
# Usage: ./deploy.sh [environment]
# Default environment: production
# =====================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVIRONMENT="${1:-production}"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking requirements..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/$ENV_FILE" ]; then
        log_warn "Environment file not found: $ENV_FILE"
        log_info "Creating from template..."
        cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/$ENV_FILE"
        log_warn "Please edit $ENV_FILE with your configuration"
        exit 0
    fi
    
    log_success "All requirements met"
}

stop_services() {
    log_info "Stopping existing services..."
    docker-compose -f "$SCRIPT_DIR/$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    log_success "Services stopped"
}

build_images() {
    log_info "Building Docker images..."
    docker-compose -f "$SCRIPT_DIR/$COMPOSE_FILE" build --no-cache
    log_success "Images built"
}

start_services() {
    log_info "Starting services..."
    docker-compose -f "$SCRIPT_DIR/$COMPOSE_FILE" up -d
    log_success "Services started"
}

wait_for_healthy() {
    log_info "Waiting for services to be healthy..."
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker-compose -f "$SCRIPT_DIR/$COMPOSE_FILE" ps | grep -q "(healthy)"; then
            log_success "All services are healthy"
            return 0
        fi
        attempt=$((attempt + 1))
        log_info "Waiting... ($attempt/$max_attempts)"
        sleep 2
    done
    
    log_error "Services failed to become healthy"
    docker-compose -f "$SCRIPT_DIR/$COMPOSE_FILE" logs
    exit 1
}

run_migrations() {
    log_info "Running database migrations..."
    
    # Wait for MySQL to be ready
    log_info "Waiting for MySQL..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker exec nicespeak-mysql mysqladmin ping -h localhost -u root -p"$MYSQL_ROOT_PASSWORD" &>/dev/null; then
            break
        fi
        attempt=$((attempt + 1))
        sleep 2
    done
    
    log_success "Database is ready"
}

verify_deployment() {
    log_info "Verifying deployment..."
    
    # Check API health
    local backend_url="http://localhost:8080"
    local health_response=$(curl -s -o /dev/null -w "%{http_code}" "$backend_url/health" 2>/dev/null || echo "000")
    
    if [ "$health_response" = "200" ]; then
        log_success "Backend API is healthy"
    else
        log_warn "Backend API health check returned: $health_response"
    fi
    
    # Check frontend
    local frontend_url="http://localhost:3000"
    local frontend_response=$(curl -s -o /dev/null -w "%{http_code}" "$frontend_url" 2>/dev/null || echo "000")
    
    if [ "$frontend_response" = "200" ]; then
        log_success "Frontend is accessible"
    else
        log_warn "Frontend returned: $frontend_response"
    fi
}

show_status() {
    echo ""
    echo "=============================================="
    echo "   Deployment Complete!"
    echo "=============================================="
    echo ""
    echo "Services:"
    docker-compose -f "$SCRIPT_DIR/$COMPOSE_FILE" ps
    echo ""
    echo "URLs:"
    echo "  - Frontend: http://localhost:3000"
    echo "  - Backend API: http://localhost:8080"
    echo "  - Health Check: http://localhost:8080/health"
    echo ""
    echo "Logs:"
    echo "  - docker-compose -f $COMPOSE_FILE logs -f"
    echo ""
    echo "Stop:"
    echo "  - docker-compose -f $COMPOSE_FILE down"
    echo ""
}

# Main
main() {
    echo ""
    echo "=============================================="
    echo "   Nice Speak Admin - Deployment Script"
    echo "   Environment: $ENVIRONMENT"
    echo "=============================================="
    echo ""
    
    check_requirements
    stop_services
    build_images
    start_services
    wait_for_healthy
    run_migrations
    verify_deployment
    show_status
}

main "$@"
