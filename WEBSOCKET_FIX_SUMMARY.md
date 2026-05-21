# WebSocket Connection Fix Summary

## Problem
WebSocket connections were failing with the error: "Connection to 'http://192.168.100.9:8000/ws/chat/1/#' was not upgraded to WebSocket"

## Root Causes

1. **Backend Not Configured for WebSockets**
   - Django Channels was not installed
   - ASGI application was not configured for WebSocket routing
   - Server was running with `python manage.py runserver` which doesn't support WebSockets

2. **Missing JWT Authentication for WebSockets**
   - WebSocket connections need JWT token authentication
   - Token was not being passed from Flutter to backend

## Changes Made

### Backend Changes

#### 1. Updated `backend/config/settings.py`
- Added `daphne` to `INSTALLED_APPS` (must be first for WebSocket support)
- Added `channels` to `INSTALLED_APPS`
- Added `ASGI_APPLICATION = 'config.asgi.application'`
- Added `CHANNEL_LAYERS` configuration (in-memory for development)

#### 2. Updated `backend/config/asgi.py`
- Configured `ProtocolTypeRouter` to handle both HTTP and WebSocket connections
- Added WebSocket routing for `/ws/chat/<conversation_id>/`
- Integrated JWT authentication middleware for WebSocket connections

#### 3. Created `backend/apps/users/middleware.py`
- New `JWTAuthMiddleware` class for WebSocket authentication
- Extracts JWT token from query parameters or headers
- Validates token and attaches user to WebSocket scope
- Rejects unauthenticated connections with code 4001

#### 4. Updated `backend/requirements.txt`
- Added `channels==4.0.0`
- Added `daphne==4.1.0`

#### 5. Created `backend/WEBSOCKET_SETUP.md`
- Comprehensive guide for WebSocket setup and usage
- Instructions for running server with Daphne
- Testing examples and troubleshooting tips

### Frontend Changes

#### 1. Updated `frontend/lib/features/messaging/screens/private_message_screen.dart`
- Added import for `TokenStorage`
- Modified `_initWebSocket()` to be async
- Added JWT token retrieval before WebSocket connection
- Token is now passed as query parameter: `?token=<jwt_token>`
- Added error handling for missing token

#### 2. Updated `frontend/lib/features/messaging/data/services/websocket_service.dart`
- Added debug logging for connection attempts
- Added debug logging for connection errors
- Added debug logging for reconnection attempts
- Better visibility into WebSocket lifecycle

### No Changes Needed

#### `frontend/lib/core/api/api_endpoints.dart`
- Already correctly configured with `ws://` scheme ✓
- No trailing `/#` in the WebSocket URL ✓

## Installation Steps

### Backend
```bash
cd backend
pip install -r requirements.txt
```

### Running the Server
**IMPORTANT:** Must use Daphne instead of runserver:
```bash
# Correct way (supports WebSockets)
daphne -b 0.0.0.0 -p 8000 config.asgi:application

# Wrong way (does NOT support WebSockets)
python manage.py runserver  # ❌ Don't use this
```

## How It Works Now

1. **Flutter App:**
   - Retrieves JWT token from secure storage
   - Constructs WebSocket URL: `ws://192.168.100.9:8000/ws/chat/<id>/?token=<jwt>`
   - Connects using `WebSocketChannel.connect()`

2. **Django Backend:**
   - Daphne receives WebSocket upgrade request
   - ASGI router directs to `ChatConsumer`
   - `JWTAuthMiddleware` validates token from query parameter
   - If valid, user is authenticated and connection is accepted
   - If invalid, connection is rejected with code 4001

3. **Real-time Communication:**
   - Messages sent via WebSocket are instantly delivered
   - Read receipts, typing indicators work in real-time
   - Automatic reconnection on connection loss

## Testing

### Check Server is Running with WebSocket Support
```bash
# Should see Daphne output, not Django runserver
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

### Test WebSocket Connection (Browser Console)
```javascript
const token = 'your_jwt_token';
const ws = new WebSocket(`ws://192.168.100.9:8000/ws/chat/1/?token=${token}`);
ws.onopen = () => console.log('✓ Connected');
ws.onerror = (e) => console.error('✗ Error:', e);
```

### Check Flutter Logs
Look for these log messages:
```
[ChatWebSocketService] Connecting to: ws://192.168.100.9:8000/ws/chat/1/?token=...
[ChatWebSocketService] WebSocket connected successfully
```

## Troubleshooting

### "Connection not upgraded to WebSocket"
- **Cause:** Server running with `runserver` instead of Daphne
- **Fix:** Stop server and restart with `daphne -b 0.0.0.0 -p 8000 config.asgi:application`

### "WebSocket closed with code 4001"
- **Cause:** JWT token is missing or invalid
- **Fix:** Check that `TokenStorage.getAccessToken()` returns a valid token

### "WebSocket closed with code 4003"
- **Cause:** User is not a member of the conversation
- **Fix:** Verify `ConversationMember` record exists in database

### Connection Refused
- **Cause:** Server not running or firewall blocking
- **Fix:** Check server is running and accessible at `192.168.100.9:8000`

## Production Considerations

1. **Use Redis for Channel Layers**
   - Replace in-memory backend with Redis for multi-server support
   - Install `channels-redis`

2. **Use WSS (Secure WebSocket)**
   - Configure SSL/TLS with Nginx or similar
   - Update Flutter URLs to use `wss://` instead of `ws://`

3. **Process Management**
   - Use systemd, supervisor, or Docker to keep Daphne running
   - Configure automatic restart on failure

4. **Monitoring**
   - Monitor WebSocket connection count
   - Track message delivery latency
   - Alert on connection failures

## Files Modified

### Backend
- `backend/config/settings.py` - Added Channels configuration
- `backend/config/asgi.py` - Configured WebSocket routing
- `backend/apps/users/middleware.py` - Created JWT auth middleware (NEW)
- `backend/requirements.txt` - Added channels and daphne
- `backend/WEBSOCKET_SETUP.md` - Setup documentation (NEW)

### Frontend
- `frontend/lib/features/messaging/screens/private_message_screen.dart` - Added token to WebSocket URL
- `frontend/lib/features/messaging/data/services/websocket_service.dart` - Added debug logging

## Next Steps

1. Install dependencies: `pip install -r requirements.txt`
2. Stop current server if running
3. Start server with Daphne: `daphne -b 0.0.0.0 -p 8000 config.asgi:application`
4. Test WebSocket connection from Flutter app
5. Verify real-time messaging works
6. Check logs for any errors

## References
- [Django Channels Documentation](https://channels.readthedocs.io/)
- [Daphne ASGI Server](https://github.com/django/daphne)
- [WebSocket Protocol RFC 6455](https://datatracker.ietf.org/doc/html/rfc6455)
