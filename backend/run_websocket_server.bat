@echo off
REM WebSocket-enabled Django server startup script
REM This script runs the Django backend with Daphne to support WebSocket connections

echo ========================================
echo Starting Django Backend with WebSocket Support
echo ========================================
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo Please create a virtual environment first:
    echo   python -m venv venv
    echo   venv\Scripts\activate
    echo   pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if channels and daphne are installed
echo Checking dependencies...
python -c "import channels, daphne" 2>nul
if errorlevel 1 (
    echo.
    echo WARNING: channels or daphne not installed!
    echo Installing dependencies...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo Starting Daphne ASGI Server
echo ========================================
echo Server will be available at:
echo   HTTP: http://0.0.0.0:8000
echo   WebSocket: ws://0.0.0.0:8000/ws/chat/^<conversation_id^>/?token=^<jwt_token^>
echo.
echo Press Ctrl+C to stop the server
echo ========================================
echo.

REM Start Daphne
daphne -b 0.0.0.0 -p 8000 config.asgi:application

REM If Daphne exits, show message
echo.
echo Server stopped.
pause
