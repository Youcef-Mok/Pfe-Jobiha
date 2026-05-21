# WebSocket Setup Guide

## Overview
The backend now supports WebSocket connections for real-time messaging using Django Channels and Daphne.

## Installation

1. Install the required packages:
```bash
pip install -r requirements.txt
```

This will install:
- `channels==4.0.0` - Django Channels for WebSocket support
- `daphne==4.1.0` - ASGI server that supports WebSockets

## Running the Server

### Development Mode

**IMPORTANT:** You must use Daphne instead of the standard Django `runserver` command to enable WebSocket support.

```bash
# Navigate to the backend directory
cd backend

# Run with Daphne (supports WebSockets)
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

**Do NOT use:**
```bash
python manage.py runserver  # This does NOT support WebSockets
```

### Production Mode

For production, use Daphne with proper configuration:

```bash
daphne -b 0.0.0.0 -p 8000 config.asgi:application
```

Or use a process manager like systemd or supervisor to keep it running.

## Configuration

### Settings (config/settings.py)
- `ASGI_APPLICATION` is set to `'config.asgi.application'`
- `CHANNEL_LAYERS` uses in-memory backend (for development)
- `daphne` is added to `INSTALLED_APPS` (must be first)
- `channels` is added to `INSTALLED_APPS`

### ASGI Configuration (config/asgi.py)
- Routes HTTP requests to Django's ASGI application
- Routes WebSocket requests to `ChatConsumer` at `/ws/chat/<conversation_id>/`
- Uses JWT authentication middleware for WebSocket connections

## WebSocket Endpoints

### Chat WebSocket
**URL:** `ws://192.168.100.9:8000/ws/chat/<conversation_id>/?token=<jwt_token>`

**Authentication:** JWT token passed as query parameter

**Incoming Messages:**
```json
{"type": "send_message", "contenu": "Hello!"}
{"type": "mark_read"}
{"type": "typing_start"}
{"type": "typing_stop"}
```

**Outgoing Messages:**
```json
{"type": "new_message", "message": {...}}
{"type": "read_receipt", "reader_id": 123, "last_read_id": 456}
{"type": "typing", "user_id": 123, "is_typing": true}
{"type": "member_update", "action": "added", "user_id": 123}
```

## Testing WebSocket Connection

### Using Browser Console
```javascript
const token = 'your_jwt_token_here';
const ws = new WebSocket(`ws://192.168.100.9:8000/ws/chat/1/?token=${token}`);

ws.onopen = () => console.log('Connected');
ws.onmessage = (e) => console.log('Message:', JSON.parse(e.data));
ws.onerror = (e) => console.error('Error:', e);
ws.onclose = () => console.log('Closed');

// Send a message
ws.send(JSON.stringify({type: 'send_message', contenu: 'Hello!'}));
```

### Using Python
```python
import asyncio
import websockets
import json

async def test_websocket():
    token = 'your_jwt_token_here'
    uri = f'ws://192.168.100.9:8000/ws/chat/1/?token={token}'
    
    async with websockets.connect(uri) as websocket:
        # Send a message
        await websocket.send(json.dumps({
            'type': 'send_message',
            'contenu': 'Hello from Python!'
        }))
        
        # Receive response
        response = await websocket.recv()
        print(f"Received: {response}")

asyncio.run(test_websocket())
```

## Troubleshooting

### Connection Refused
- Make sure you're running the server with Daphne, not `runserver`
- Check that the server is listening on `0.0.0.0:8000`
- Verify firewall settings allow connections on port 8000

### Authentication Failed (4001)
- Verify the JWT token is valid and not expired
- Check that the token is passed correctly in the query string
- Ensure `TokenStorage.getAccessToken()` returns a valid token in Flutter

### Not a Member (4003)
- Verify the user is a member of the conversation
- Check `ConversationMember` table in the database

### WebSocket Closes Immediately
- Check server logs for errors
- Verify ASGI configuration is correct
- Ensure channels is installed and in INSTALLED_APPS

## Production Considerations

### Channel Layers
For production, replace the in-memory channel layer with Redis:

```python
# settings.py
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            'hosts': [('127.0.0.1', 6379)],
        },
    },
}
```

Install Redis support:
```bash
pip install channels-redis
```

### SSL/TLS
For production, use `wss://` (secure WebSocket) instead of `ws://`:
- Configure Nginx or another reverse proxy to handle SSL termination
- Update Flutter app to use `wss://` URLs

### Process Management
Use a process manager to keep Daphne running:
- systemd (Linux)
- supervisor
- Docker with restart policies

## References
- [Django Channels Documentation](https://channels.readthedocs.io/)
- [Daphne Documentation](https://github.com/django/daphne)
- [WebSocket Protocol](https://datatracker.ietf.org/doc/html/rfc6455)
