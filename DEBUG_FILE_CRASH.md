# Debug File Send Crash - Instructions

## Changes Made

### 1. Added ErrorWidget.builder in main.dart
This will catch any widget build errors and print them to console instead of showing a red error screen.

### 2. Enhanced error logging in private_message_screen.dart
The try-catch in `_buildMessagesWithDateSeparators` now prints:
- `CRASH BUILDING MESSAGE: <error>`
- `MESSAGE DATA: id=... type=... content=... isMine=... isRead=...`
- `STACK: <full stack trace>`

## Next Steps

1. **Run the app:**
   ```bash
   cd frontend
   flutter run
   ```

2. **Send a file:**
   - Open a conversation
   - Tap the + button
   - Select "Fichier"
   - Choose any file
   - Send it

3. **Check Flutter console output:**
   - Look for lines starting with `CRASH BUILDING MESSAGE:`
   - Look for lines starting with `MESSAGE DATA:`
   - Look for lines starting with `WIDGET ERROR:`
   - Look for lines starting with `STACK:`

4. **Copy and paste the EXACT output here**

## What to Look For

The debug output will show:
- **Exact error message**: What exception was thrown
- **Message data**: What fields are null or invalid
- **Stack trace**: Which line of code crashed
- **Widget error**: If the error is in widget building

## Example Output

You should see something like:
```
CRASH BUILDING MESSAGE: Null check operator used on a null value
MESSAGE DATA: id=123 type=MessageType.file content=null isMine=true isRead=false
STACK: #0 _MessageBubble.build (package:job_app/features/messaging/screens/private_message_screen.dart:1234:56)
```

This will tell us:
- The error is "Null check operator used on a null value"
- The content field is null
- The crash is on line 1234 in _MessageBubble.build

**DO NOT make any code changes until you paste the debug output!**
