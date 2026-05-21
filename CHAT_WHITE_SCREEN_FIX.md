# Chat White Screen Fix - Complete

## Problem
Chat screen goes white after sending image/file, then recovers after sending a text message.

## Root Cause
Message bubble rendering crash when attempting to display media messages with null or incomplete data:
- The `content` field could be null for media messages during upload
- The widget tried to access `message.content` without null safety checks
- This caused a crash that made the entire screen go white
- Sending a text message "fixed" it because the list rebuilt and the media message now had complete data from the server

## Solution - Two Targeted Fixes

### Fix 1: Null-Safe Message Bubble Rendering

**Files Modified:**
- `frontend/lib/features/messaging/screens/private_message_screen.dart`
- `frontend/lib/features/messaging/widgets/message_actions_sheet.dart`

**Changes:**
1. Made `_buildImageWidget()` accept nullable `String?` content parameter
2. Added null/empty check at the start of `_buildImageWidget()` - shows loading placeholder if content is null or empty
3. Added null safety to file message rendering - shows "Envoi en cours..." with spinner if content is null/empty
4. Added null safety to text message rendering - uses `message.content ?? ''`
5. Made `_openFile()` accept nullable URL and return early if null/empty
6. Fixed reply preview to use `_replyingTo!.content ?? ''`
7. Fixed file name display to use `message.content?.split('/').last ?? 'Fichier'`
8. Fixed message actions sheet to use `message.content ?? ''` for preview and copy

### Fix 2: Nullable Content Throughout the Data Layer

**Files Modified:**
- `frontend/lib/features/messaging/domain/message_entity.dart`
- `frontend/lib/features/messaging/data/models/chat_model.dart`
- `frontend/lib/features/messaging/data/models/message_dto.dart`

**Changes:**
1. Changed `MessageEntity.content` from `String` to `String?` (nullable)
2. Changed `MessageModel.content` from `String` to `String?` (nullable)
3. Changed `MessageDto.contenu` from `String` to `String?` (nullable)
4. Updated `MessageDto.fromJson()` to cast as `String?` instead of `String`
5. Removed `required` keyword from content parameters in all constructors

## Why This Works

### Before:
1. User sends image/file
2. Message might briefly appear in list with null content (from WebSocket or optimistic update)
3. Widget tries to render: `Text(message.content)` → **CRASH** (null is not a String)
4. Screen goes white
5. User sends text message → list rebuilds → media message now has URL from server → renders successfully

### After:
1. User sends image/file
2. Message might briefly appear in list with null content
3. Widget checks: `if (content == null || content.isEmpty)` → shows loading spinner
4. No crash, smooth experience
5. When server responds with URL, widget automatically shows the image/file

## Testing Checklist

- [ ] Send an image in chat - should show loading spinner, then image
- [ ] Send a file in chat - should show "Envoi en cours...", then file name
- [ ] Send a text message - should work as before
- [ ] Reply to a message with null content - should show empty string
- [ ] Copy a message with null content - should copy empty string
- [ ] Long-press a message to see actions - should show preview even if content is null

## Files Changed Summary

1. **private_message_screen.dart** - Added null safety to all message rendering paths
2. **message_actions_sheet.dart** - Added null safety to message preview and copy
3. **message_entity.dart** - Made content nullable
4. **chat_model.dart** - Made content nullable
5. **message_dto.dart** - Made contenu nullable

## No Breaking Changes

All changes are backward compatible:
- Existing messages with content continue to work
- New messages with null content are handled gracefully
- No API changes required
- No database migration needed
