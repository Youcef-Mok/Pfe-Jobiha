#!/bin/bash
# WebSocket-enabled Django server startup script
# This script runs the Django backend with Daphne to support WebSocket connections

echo "========================================"
echo "Starting Django Backend with WebSocket Support"
echo "========================================"
echo ""

# Check if virtual environment exists
if [ ! -f "venv/bin/activate" ]; then
    echo "ERROR: Virtual environment not found!"
    echo "Please create a virtual environment first:"
    echo "  python -m venv venv"
    echo "  source venv/bin/activate"
    echo "  pip install -r requirements.txt"
    echo ""
    exit 1
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Check if channels and daphne are installed
echo "Checking dependencies..."
python -c "import channels, daphne" 2>/dev/null
if [ $? -ne 0 ]; then
    echo ""
    echo "WARNING: channels or daphne not installed!"
    echo "Installing dependencies..."
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo ""
        echo "ERROR: Failed to install dependencies"
        exit 1
    fi
fi

echo ""
echo "========================================"
echo "Starting Daphne ASGI Server"
echo "========================================"
echo "Server will be available at:"
echo "  HTTP: http://0.0.0.0:8000"
echo "  WebSocket: ws://0.0.0.0:8000/ws/chat/<conversation_id>/?token=<jwt_token>"
echo ""
echo "Press Ctrl+C to stop the server"
echo "========================================"
echo ""

# Start Daphne
daphne -b 0.0.0.0 -p 8000 config.asgi:application

# If Daphne exits, show message
echo ""
echo "Server stopped."
