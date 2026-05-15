# Design Document: Messaging UI Enhancements

## Overview

This design document specifies the technical implementation for four UI enhancements to the messaging feature in the Flutter mobile application. These enhancements improve user experience through:

1. **Transparent Invitation Overlay Background** - Removing the dimming overlay to allow users to preview conversation context before accepting invitations
2. **Image and File Sending** - Enabling users to share images and files through the messaging interface
3. **Contextual Message Actions Overlay Positioning** - Repositioning the message actions overlay to appear near the selected message for better context
4. **Streamlined Message Actions Interface** - Removing the message preview from the actions overlay for a cleaner interface

The implementation leverages Flutter's existing modal components, the Riverpod state management pattern already in use, and the established messaging architecture with minimal disruption to existing functionality.

## Architecture

### High-Level Component Structure

```
PrivateMessageScreen (Conversation UI)
├── Header (Contact info, navigation)
├── Message List (Scrollable messages)
│   ├── Text Messages
│   ├── Image Messages (NEW)
│   └── File Messages (NEW)
├── Message Actions Overlay (MODIFIED)
│   ├── Contextual Positioning (NEW)
│   └── Streamlined Interface (MODIFIED)
├── Invitation Overlay (MODIFIED)
│   └── Transparent Background (NEW)
└── Input Footer
    ├── Attachment Button
    └── Text Input
```

### State Management Architecture

The existing Riverpod-based state management will be extended to support new message types:

```
MessagingController (StateNotifier)
├── MessagingState
│   ├── conversations: List<ConversationEntity>
│   ├── invitations: List<ConversationEntity>
│   ├── uploadProgress: Map<String, double> (NEW)
│   └── uploadErrors: Map<String, String> (NEW)
└── Methods
    ├── sendMessage(conversationId, content)
    ├── sendImage(conversationId, imagePath) (NEW)
    ├── sendFile(conversationId, filePath) (NEW)
    └── retryUpload(messageId) (NEW)
```

### Data Flow

```mermaid
graph TD
    A[User Action] --> B{Action Type}
    B -->|Select Image| C[ImagePicker]
    B -->|Select File| D[FilePicker]
    B -->|Long Press Message| E[Show Actions Overlay]
    B -->|Open Invitation| F[Show Transparent Overlay]
    
    C --> G[Upload Service]
    D --> G
    G --> H[Backend API]
    H --> I[Update State]
    I --> J[Render Message]
    
    E --> K[Calculate Position]
    K --> L[Render Overlay at Position]
    
    F --> M[Render with barrierColor: transparent]
