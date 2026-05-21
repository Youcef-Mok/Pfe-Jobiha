# 📱 Message Types - Visual Guide

## All Message Types Supported

### 1️⃣ Text Messages

**Appearance:**
```
┌─────────────────────────────┐
│ Hello! How are you?         │
│                       10:30 │
└─────────────────────────────┘
```

**Backend Response:**
```json
{
  "type": "text",
  "contenu": "Hello! How are you?"
}
```

**Flutter Rendering:**
```dart
Text(message.content)
```

---

### 2️⃣ Image Messages

**Appearance:**
```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │    [Image Thumbnail]    │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                       10:31 │
└─────────────────────────────┘
```

**Backend Response:**
```json
{
  "type": "image",
  "contenu": "http://localhost:8000/media/chat_images/photo.jpg"
}
```

**Flutter Rendering:**
```dart
Image.network(
  message.content,
  loadingBuilder: (context, child, progress) {
    // Shows CircularProgressIndicator while loading
  },
  errorBuilder: (context, error, stack) {
    // Shows 📷 Image placeholder if fails
  },
)
```

**States:**
- 🔄 Loading: Shows circular progress indicator
- ✅ Loaded: Shows image thumbnail (max 200px height)
- ❌ Error: Shows 📷 Image placeholder

---

### 3️⃣ File Messages (NEW ENHANCEMENT)

**Appearance:**
```
┌─────────────────────────────┐
│ 📄 document.pdf        ⬇️   │
│    ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾      │
│                       10:32 │
└─────────────────────────────┘
     ↑ Underlined (clickable)
```

**Backend Response:**
```json
{
  "type": "file",
  "contenu": "http://localhost:8000/media/chat_files/document.pdf"
}
```

**Flutter Rendering:**
```dart
GestureDetector(
  onTap: () => _openFile(message.content),
  child: Row(
    children: [
      Icon(Icons.insert_drive_file), // 📄
      Text(
        message.content.split('/').last, // "document.pdf"
        decoration: TextDecoration.underline,
      ),
      Icon(Icons.download), // ⬇️
    ],
  ),
)
```

**Interaction:**
- 👆 Tap → Opens file in external app
- 📱 OS handles file type (PDF reader, browser, etc.)
- ⬇️ Download icon indicates it's tappable

---

## Color Schemes

### Sent Messages (isMine = true)
- Background: `#401E66` (Purple)
- Text: `#FFFFFF` (White)
- Icons: `#FFFFFF` (White)

### Received Messages (isMine = false)
- Background: `#F6F3F8` (Light Gray)
- Text: `#1D1B1F` (Dark Gray)
- Icons: `#401E66` (Purple)

---

## Message Flow Comparison

### Text Message Flow
```
User types text
    ↓
POST /conversations/123/messages
    body: { "contenu": "Hello!" }
    ↓
Backend creates Message:
    type: "text"
    contenu: "Hello!"
    ↓
Flutter displays:
    Text("Hello!")
```

### Image Message Flow
```
User picks image
    ↓
POST /conversations/123/messages/image
    multipart: { file: image.jpg }
    ↓
Backend saves to media/chat_images/
Backend creates Message:
    type: "image"
    contenu: "http://.../media/chat_images/image.jpg"
    ↓
Flutter displays:
    Image.network("http://.../image.jpg")
```

### File Message Flow
```
User picks file
    ↓
POST /conversations/123/messages/file
    multipart: { file: document.pdf }
    ↓
Backend saves to media/chat_files/
Backend creates Message:
    type: "file"
    contenu: "http://.../media/chat_files/document.pdf"
    ↓
Flutter displays:
    📄 document.pdf ⬇️ (tappable)
    ↓
User taps
    ↓
Opens in external app
```

---

## Error States

### Image Loading Error
```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │  📷 Image               │ │
│ └─────────────────────────┘ │
│                       10:31 │
└─────────────────────────────┘
```

### File Display (Always Works)
```
┌─────────────────────────────┐
│ 📄 unknown_file.xyz    ⬇️   │
│                       10:32 │
└─────────────────────────────┘
```
Even if file type is unknown, it still displays with filename.

### Message Render Error (Crash Prevention)
```
┌─────────────────────────────┐
│ ⚠️ Erreur d'affichage       │
│    du message               │
└─────────────────────────────┘
```
If a message fails to render, shows error placeholder instead of crashing.

---

## Supported File Types

### Documents
- 📄 PDF, DOC, DOCX, TXT, RTF
- 📊 XLS, XLSX, CSV
- 📑 PPT, PPTX

### Archives
- 📦 ZIP, RAR, 7Z, TAR, GZ

### Code
- 💻 PY, JS, DART, JAVA, CPP, etc.

### Media (as files, not images)
- 🎵 MP3, WAV, OGG
- 🎬 MP4, AVI, MKV

### Other
- ✅ Any file type supported
- ✅ OS handles opening based on MIME type

---

## Implementation Details

### Message Type Detection

**Backend (Django):**
```python
# In SendImageMessageView
message.type = 'image'

# In SendFileMessageView
message.type = 'file'

# In ConvSendMessageView (text)
message.type = 'text'  # default
```

**Flutter (Parsing):**
```dart
switch (dto.type.toLowerCase()) {
  case 'image':
    messageType = MessageType.image;
    break;
  case 'file':
    messageType = MessageType.file;
    break;
  default:
    messageType = MessageType.text;
}
```

### Rendering Logic

**Flutter (Display):**
```dart
if (message.type == MessageType.image)
  _buildImageWidget(message.content, isMine)
else if (message.type == MessageType.file)
  _buildFileWidget(message.content, isMine)
else
  _buildTextWidget(message.content, isMine)
```

---

## Testing Scenarios

### ✅ Happy Path
1. Send text → ✅ Displays as text
2. Send image → ✅ Displays as thumbnail
3. Send PDF → ✅ Displays as file bubble
4. Tap PDF → ✅ Opens in PDF reader
5. Reopen chat → ✅ All messages still display

### ✅ Error Handling
1. Send image with bad network → ✅ Shows error snackbar
2. Image URL returns 404 → ✅ Shows placeholder
3. Tap file with no app → ✅ OS shows error
4. Malformed message → ✅ Shows error placeholder, doesn't crash

### ✅ Edge Cases
1. Very long filename → ✅ Ellipsis truncation
2. File with no extension → ✅ Still displays
3. Image with query params in URL → ✅ Still loads
4. Multiple files in quick succession → ✅ All upload correctly

---

## Platform Behavior

### Android
- Files open in default app for MIME type
- Downloads go to Downloads folder
- Can share files from chat

### iOS
- Files open in default app for MIME type
- Can save to Files app
- Can share files from chat

### Web (if supported)
- Files download to browser's download folder
- Opens in new tab if browser can display
- Falls back to download if not displayable
