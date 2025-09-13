#!/bin/bash

echo "🚀 Starting Multipanda ROS2 development container..."

# Check if devcontainer CLI is installed
if ! command -v devcontainer &> /dev/null; then
    echo "❌ devcontainer CLI not found!"
    echo "💡 Install it with: npm install -g @devcontainers/cli"
    exit 1
fi

# Start the devcontainer
echo "🔨 Building and starting devcontainer..."
devcontainer up --workspace-folder .

# Execute bash in the container
echo "🐚 Opening shell in container..."
devcontainer exec --workspace-folder . bash