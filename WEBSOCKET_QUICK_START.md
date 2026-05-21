# WebSocket Quick Start Guide

## 🚀 Quick Start (3 Steps)

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Start Server with WebSocket Support
```bash
# Windows
run_websocket_server.bat

# Linux/Mac
./run_websocket_server.sh

# Or manually:
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

### 3. Test in Flutter App
- Open the messaging screen
- Send a message
- Check logs for: `[ChatWebSocketService] WebSocket connected successfully`

## ⚠️ Important

### ❌ DON'T Use This (No WebSocket Support)
```bash
python manage.py runserver
```

### ✅ DO Use This (WebSocket Support)
```bash
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

## 🔍 Verify It's Working

### Backend Logs Should Show:
```
INFO     Starting server at tcp:port=8000:interface=0.0.0.0
INFO     HTTP/2 support enabled
INFO     Configuring endpoint tcp:port=8000:interface=0.0.0.0
INFO     Listening on TCP address 0.0.0.0:8000
```

### Flutter Logs Should Show:
```
[ChatWebSocketService] Connecting to: ws://192.168.100.9:8000/ws/chat/1/?token=...
[ChatWebSocketService] WebSocket connected successfully
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection not upgraded" | Use `daphne` instead of `runserver` |
| "Code 4001" (Auth failed) | Check JWT token is valid |
| "Code 4003" (Not member) | Verify user is conversation member |
| "Connection refused" | Check server is running on correct IP/port |

## 📚 More Info

- Full setup guide: `backend/WEBSOCKET_SETUP.md`
- Complete fix summary: `WEBSOCKET_FIX_SUMMARY.md`

## 🎯 What Was Fixed

1. ✅ Backend configured for WebSocket support (Django Channels + Daphne)
2. ✅ JWT authentication for WebSocket connections
3. ✅ Token passed from Flutter to backend
4. ✅ Proper error handling and reconnection logic
5. ✅ Debug logging for troubleshooting

## 📝 Key Files Changed

**Backend:**
- `config/asgi.py` - WebSocket routing
- `config/settings.py` - Channels configuration
- `apps/users/middleware.py` - JWT auth for WebSockets (NEW)
- `requirements.txt` - Added channels & daphne

**Frontend:**
- `private_message_screen.dart` - Pass JWT token to WebSocket
- `websocket_service.dart` - Better error logging

## 🔗 WebSocket URL Format

```
ws://192.168.100.9:8000/ws/chat/<conversation_id>/?token=<jwt_token>
```

Example:
```
ws://192.168.100.9:8000/ws/chat/1/?token=eyJ0eXAiOiJKV1QiLCJhbGc...
```

## 💡 Pro Tips

1. **Always use Daphne** - `runserver` doesn't support WebSockets
2. **Check logs** - Both backend and Flutter logs show connection status
3. **Token expiry** - WebSocket will reconnect with new token automatically
4. **Production** - Use Redis for channel layers and WSS for secure connections

---

**Need help?** Check the full documentation in `WEBSOCKET_FIX_SUMMARY.md`
