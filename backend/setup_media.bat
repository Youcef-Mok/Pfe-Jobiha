@echo off
echo ============================================
echo Jobiha Media Setup Script
echo ============================================
echo.

echo [1/3] Checking Pillow installation...
pip show Pillow >nul 2>&1
if errorlevel 1 (
    echo Pillow not found. Installing...
    pip install Pillow
) else (
    echo Pillow is already installed.
)
echo.

echo [2/3] Creating media directories...
if not exist "media\avatars" mkdir media\avatars
if not exist "media\logos" mkdir media\logos
if not exist "media\jobs" mkdir media\jobs
if not exist "media\missions" mkdir media\missions
echo Directories created.
echo.

echo [3/3] Generating placeholder images...
python create_placeholder_images.py
echo.

echo ============================================
echo Setup Complete!
echo ============================================
echo.
echo Next steps:
echo 1. Run the seed_data.sql file in your database
echo 2. Start Django: python manage.py runserver
echo 3. Test media access: http://localhost:8000/media/avatars/user_7.jpg
echo.
pause
