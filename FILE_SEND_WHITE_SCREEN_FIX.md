# File Send White Screen Fix

## Analysis

The private_message_screen.dart already has comprehensive null safety and error handling:

### ✅ Already Implemented
1. **`_buildImageWidget` null safety**: Checks `if (content == null || content.isEmpty)` and shows loading indicator
2. **File message null safety**: Uses `(message.content?.isEmpty ?? true)` to check before displaying
3. **Text fallbacks**: Uses `message.content ?? ''` and `message.content?.split('/').last ?? 'Fichier'`
4. **Try-catch in message builder**: Wraps each message in try-catch with error placeholder
5. **`_openFile` null safety**: Checks `if (url == null || url.isEmpty)` before opening

## Potential Issue

The white screen might be caused by:
1. **State rebuild issue**: After file upload, the conversation state might be in an inconsistent state
2. **Async timing**: The file upload completes but the UI tries to render before the message is fully loaded
3. **Missing error boundary**: The error might be happening outside the message list

## Fix Applied

Added extra safety to `_buildImageWidget` to ensure `startsWith` is called safely (though this was already protected by the null check above it).

## Recommended Testing Steps

1. **Add debug logging** before sending file:
```dart
// In _showAttachmentOverlay, before sendFileMessage:
debugPrint('📎 Sending file: ${result.files.single.path}');
```

2. **Add debug logging** in message builder:
```dart
// In _buildMessagesWithDateSeparators:
debugPrint('📝 Building message: id=${msg.id}, type=${msg.type}, content=${msg.content}');
```

3. **Check Flutter console** for the exact error when white screen appears

4. **Test with different file types**:
   - Small text file (.txt)
   - PDF document
   - Image file (should use image path, not file path)

## If White Screen Persists

### Check 1: Verify message type is set correctly
When a file is uploaded, ensure the backend returns `type: 'file'` in the response.

### Check 2: Check if content is being set
The file message should have `content` set to the file URL after upload completes.

### Check 3: Add ErrorWidget.builder
In main.dart, add:
```dart
ErrorWidget.builder = (FlutterErrorDetails details) {
  return Material(
    child: Container(
      color: Colors.red,
      child: Center(
        child: Text(
          'Error: ${details.exception}',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
};
```

This will show the actual error instead of a white screen.

### Check 4: Verify conversation reload
After file upload, the conversation should reload to show the new message. Check if `loadConversationMessages` is being called.

## Code Safety Summary

The current code has these safety measures:

1. **Null-safe content access**: ✅
   - `message.content ?? ''`
   - `message.content?.isEmpty ?? true`
   - `message.content?.split('/').last ?? 'Fichier'`

2. **Null-safe URL checks**: ✅
   - `if (content == null || content.isEmpty)`
   - `if (url == null || url.isEmpty)`

3. **Error boundaries**: ✅
   - Try-catch around each message render
   - Error placeholder widget on failure

4. **Type safety**: ✅
   - Checks `message.type == MessageType.file`
   - Checks `message.type == MessageType.image`

## Next Steps

1. Run the app and send a file
2. Check Flutter console for error messages
3. If error appears, share the exact error message
4. If no error but white screen, add ErrorWidget.builder to see hidden errors
