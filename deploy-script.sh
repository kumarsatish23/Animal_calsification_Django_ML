#!/bin/bash

# EC2 Deployment Script for Animal Classifier Django ML App
# This script should be run on your EC2 instance

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="animal-classifier"
APP_DIR="/opt/${APP_NAME}"
DOCKER_IMAGE="${DOCKERHUB_USERNAME}/${APP_NAME}:latest"
COMPOSE_FILE="docker-compose.prod.yml"

echo -e "${GREEN}🚀 Starting deployment of ${APP_NAME}...${NC}"

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
   echo -e "${YELLOW}⚠️  Running as root. This is not recommended for production.${NC}"
fi

# Function to install Docker
install_docker() {
    echo -e "${YELLOW}📦 Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl start docker
    sudo systemctl enable docker
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker installed successfully${NC}"
}

# Function to install Docker Compose
install_docker_compose() {
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose installed successfully${NC}"
}

# Update system packages
echo -e "${YELLOW}📦 Updating system packages...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    install_docker
else
    echo -e "${GREEN}✅ Docker is already installed${NC}"
fi

# Install Docker Compose if not present
if ! command -v docker-compose &> /dev/null; then
    install_docker_compose
else
    echo -e "${GREEN}✅ Docker Compose is already installed${NC}"
fi

# Create application directory
echo -e "${YELLOW}📁 Setting up application directory...${NC}"
sudo mkdir -p ${APP_DIR}
sudo chown -R $USER:$USER ${APP_DIR}
cd ${APP_DIR}

# Create necessary directories
mkdir -p media static logs ssl

# Download or copy production files
if [ -f "${COMPOSE_FILE}" ]; then
    echo -e "${GREEN}✅ Production compose file found${NC}"
else
    echo -e "${YELLOW}⚠️  Production compose file not found. Using default configuration.${NC}"
    # Create a basic production compose file
    cat > ${COMPOSE_FILE} << EOF
version: '3.8'
services:
  web:
    image: ${DOCKER_IMAGE}
    ports:
      - "80:8000"
    volumes:
      - ./media:/app/media
      - ./static:/app/staticfiles
      - ./logs:/app/logs
    environment:
      - DEBUG=0
      - DJANGO_SETTINGS_MODULE=dog_cat_classifier.settings
      - ALLOWED_HOSTS=*
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import requests; requests.get('http://localhost:8000', timeout=10)"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
EOF
fi

# Set up environment variables
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  Creating default environment file. Please update with your settings.${NC}"
    cat > .env << EOF
DEBUG=0
SECRET_KEY=$(openssl rand -base64 32)
ALLOWED_HOSTS=*
DJANGO_SETTINGS_MODULE=dog_cat_classifier.settings
DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}
EOF
fi

# Login to Docker Hub (if credentials provided)
if [ ! -z "${DOCKERHUB_USERNAME}" ] && [ ! -z "${DOCKERHUB_TOKEN}" ]; then
    echo -e "${YELLOW}🔐 Logging into Docker Hub...${NC}"
    echo "${DOCKERHUB_TOKEN}" | sudo docker login -u "${DOCKERHUB_USERNAME}" --password-stdin
fi

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
sudo docker-compose -f ${COMPOSE_FILE} down || true

# Pull latest image
echo -e "${YELLOW}📥 Pulling latest Docker image...${NC}"
sudo docker pull ${DOCKER_IMAGE}

# Start new containers
echo -e "${YELLOW}🚀 Starting new containers...${NC}"
sudo docker-compose -f ${COMPOSE_FILE} up -d

# Wait for containers to be healthy
echo -e "${YELLOW}⏳ Waiting for containers to be ready...${NC}"
sleep 30

# Run Django management commands
echo -e "${YELLOW}🔧 Running Django management commands...${NC}"
sudo docker-compose -f ${COMPOSE_FILE} exec -T web python manage.py migrate
sudo docker-compose -f ${COMPOSE_FILE} exec -T web python manage.py collectstatic --noinput

# Clean up unused images
echo -e "${YELLOW}🧹 Cleaning up unused Docker images...${NC}"
sudo docker image prune -af

# Display status
echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Application should be running on http://$(curl -s http://checkip.amazonaws.com/)${NC}"

# Display container status
echo -e "${YELLOW}📊 Container Status:${NC}"
sudo docker-compose -f ${COMPOSE_FILE} ps

echo -e "${GREEN}🎉 Deployment script finished!${NC}"
