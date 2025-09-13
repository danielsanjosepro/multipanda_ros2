#!/bin/bash

set -e

echo "🚀 Setting up ROS2 workspace..."

# Source ROS2 environment
source /opt/ros/humble/setup.bash

# Navigate to workspace
cd ~/humble_ws

# Install dependencies using rosdep
echo "📦 Installing dependencies with rosdep..."
rosdep install -i --from-path src --rosdistro humble -y --skip-keys="libfranka"

# Build the workspace
echo "🔨 Building ROS2 workspace..."
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON --symlink-install

# Add workspace sourcing to bashrc if not already there
if ! grep -q "source ~/humble_ws/install/setup.bash" ~/.bashrc; then
    echo "source ~/humble_ws/install/setup.bash" >> ~/.bashrc
    echo "✅ Added workspace sourcing to ~/.bashrc"
fi

echo "🎉 Development environment setup complete!"
echo "💡 Run 'source ~/.bashrc' or restart your terminal to load the workspace."