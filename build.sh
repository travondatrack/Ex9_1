#!/bin/bash

# Build script for Render deployment
echo "Starting build process for Render..."

# Set Maven options for memory efficiency
export MAVEN_OPTS="-Xmx256m -XX:MaxPermSize=128m"

# Install curl for health checks if not available
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    apt-get update && apt-get install -y curl
fi

# Build the project using Docker multi-stage
echo "Building application with Docker..."
docker build -f Dockerfile.multi-stage -t ex9_1:latest .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Docker build successful!"
else
    echo "❌ Docker build failed!"
    exit 1
fi

echo "Build process completed successfully."
