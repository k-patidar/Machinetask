#!/bin/bash

echo "Stopping existing PHP application container..."

# Stop the container if it's running
if docker ps -q --filter "name=php-app" | grep -q .; then
    echo "Stopping php-app container..."
    docker stop php-app
    echo "Container stopped"
else
    echo "No running php-app container found"
fi

# Remove the container if it exists
if docker ps -aq --filter "name=php-app" | grep -q .; then
    echo "Removing php-app container..."
    docker rm php-app
    echo "Container removed"
else
    echo "No php-app container found to remove"
fi

# Clean up unused images (optional)
echo "Cleaning up unused Docker images..."
docker image prune -f

echo "Stop container script completed"