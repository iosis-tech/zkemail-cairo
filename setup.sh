#!/bin/bash

VENV_PATH=${1:-venv}
PYTHON_VERSION=${2:-3.9}

echo "Setting up virtual environment at $VENV_PATH with Python $PYTHON_VERSION"

# Check Python version compatibility
if ! command -v python"$PYTHON_VERSION" >/dev/null; then
    echo "Python $PYTHON_VERSION is not installed. Please install it and try again."
    exit 1
fi

# Create virtual environment
echo "Creating virtual environment..."
python"$PYTHON_VERSION" -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"

# Update dependencies
echo "Installing dependencies"
pip install cairo-lang || {
    echo "Failed to install cairo-lang."
    exit 1
}
