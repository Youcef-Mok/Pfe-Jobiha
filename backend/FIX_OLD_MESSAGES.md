# Fix Old Message Types

## Problem
Messages created before the image/file upload fix have `type='text'` in the database, even if they contain image/file URLs. This causes them to display as raw URLs instead of image bubbles.

## Solution
Run the management command to automatically fix all old messages:

```bash
python manage.py fix_message_types
```

## What It Does

The command:
1. Finds all messages with `type='text'` that contain image URLs
2. Updates them to `type='image'`
3. Finds all messages with `type='text'` that contain file URLs
4. Updates them to `type='file'`

### Detection Logic

**Image Messages:**
- Messages with URLs containing `/media/chat_images/`
- Messages with URLs ending in: `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.bmp`, `.svg`

**File Messages:**
- Messages with URLs containing `/media/chat_files/`
- Messages with URLs ending in: `.pdf`, `.doc`, `.docx`, `.xls`, `.xlsx`, `.txt`, `.zip`, `.rar`

## Example Output

```
Fixing message types...
  Updated 1 messages with .jpg to type="image"
  Updated 2 messages with .png to type="image"
  Updated 1 messages with .pdf to type="file"

✅ Fixed 3 image messages and 1 file messages
```

## When to Run

Run this command:
- ✅ After deploying the image upload fix
- ✅ If users report seeing raw URLs instead of images
- ✅ After importing old messages from another system
- ✅ Anytime you suspect message types are incorrect

## Safe to Run Multiple Times

The command is idempotent - it only updates messages that need fixing. Running it multiple times won't cause any issues.

## Manual Alternative

If you prefer to fix messages manually in Django shell:

```python
from apps.messaging.models import Message

# Fix image messages
Message.objects.filter(
    contenu__icontains='/media/chat_images/',
    type='text'
).update(type='image')

# Fix file messages
Message.objects.filter(
    contenu__icontains='/media/chat_files/',
    type='text'
).update(type='file')
```

## Verification

After running the command, check a few messages in the database:

```python
from apps.messaging.models import Message

# Show recent messages with their types
for msg in Message.objects.order_by('-date_envoi')[:10]:
    print(f"ID: {msg.id}, Type: {msg.type}, Content: {msg.contenu[:50]}...")
```

All image URLs should have `type='image'` and file URLs should have `type='file'`.
