# Requirements Document

## Introduction

This document specifies the requirements for four UI enhancements to the messaging feature in the mobile application. These enhancements improve the user experience by providing better visual feedback, enabling file sharing functionality, improving overlay positioning, and streamlining the message actions interface.

## Glossary

- **Invitation_Overlay**: The modal sheet displayed when a user opens a discussion from an invitation, prompting them to accept or decline the message request
- **Message_Actions_Overlay**: The bottom sheet displayed when a user long-presses a message, showing options like reply, copy, forward, delete, and react
- **Attachment_Overlay**: The dialog displayed when a user taps the attachment button, offering options to select images from gallery or files from storage
- **Message_List**: The scrollable list of messages displayed in a conversation
- **Conversation_Screen**: The screen displaying a private message conversation between two users
- **Background_Dimming**: The semi-transparent dark overlay that appears behind modal sheets to focus user attention

## Requirements

### Requirement 1: Transparent Invitation Overlay Background

**User Story:** As a user, I want to see the conversation content behind the invitation overlay, so that I can preview the discussion context before deciding to accept or decline the invitation.

#### Acceptance Criteria

1. WHEN the Invitation_Overlay is displayed, THE Conversation_Screen SHALL remain fully visible behind the overlay without Background_Dimming
2. THE Invitation_Overlay SHALL maintain its white background and visual styling
3. THE Invitation_Overlay SHALL remain interactive with accept and decline buttons functional
4. THE Message_List SHALL be visible but not scrollable while the Invitation_Overlay is displayed

### Requirement 2: Image and File Sending

**User Story:** As a user, I want to send images and files in my conversations, so that I can share visual content and documents with my contacts.

#### Acceptance Criteria

1. WHEN a user selects an image from the Attachment_Overlay gallery option, THE Conversation_Screen SHALL display the selected image in the Message_List
2. WHEN a user selects a file from the Attachment_Overlay file option, THE Conversation_Screen SHALL display the selected file in the Message_List
3. WHEN an image is displayed in the Message_List, THE Conversation_Screen SHALL send the image to the backend messaging service
4. WHEN a file is displayed in the Message_List, THE Conversation_Screen SHALL send the file to the backend messaging service
5. THE Message_List SHALL display image messages with a preview thumbnail
6. THE Message_List SHALL display file messages with a file icon and filename
7. WHEN an image or file send operation fails, THE Conversation_Screen SHALL display an error indicator on the message
8. THE Conversation_Screen SHALL support common image formats including JPEG, PNG, and GIF
9. THE Conversation_Screen SHALL support common file types including PDF, DOC, DOCX, XLS, XLSX, and TXT

### Requirement 3: Contextual Message Actions Overlay Positioning

**User Story:** As a user, I want the message actions overlay to appear near the message I long-pressed, so that I can clearly see which message I'm acting upon and have a more intuitive interaction.

#### Acceptance Criteria

1. WHEN a user long-presses a message, THE Message_Actions_Overlay SHALL appear directly below the selected message
2. THE Message_Actions_Overlay SHALL have a fixed width of 200 logical pixels
3. WHEN a message near the bottom of the screen is long-pressed, THE Message_Actions_Overlay SHALL appear above the message if insufficient space exists below
4. THE Message_Actions_Overlay SHALL maintain its white background and rounded corners
5. THE Message_Actions_Overlay SHALL display all action options (react, copy, reply, forward, report, delete) in the same order as the current implementation
6. WHEN the Message_Actions_Overlay is displayed, THE Conversation_Screen SHALL apply Background_Dimming to the rest of the screen
7. THE Message_Actions_Overlay SHALL dismiss when the user taps outside the overlay or selects an action

### Requirement 4: Streamlined Message Actions Interface

**User Story:** As a user, I want a cleaner message actions overlay without the message preview, so that I can focus on the available actions and have a less cluttered interface.

#### Acceptance Criteria

1. THE Message_Actions_Overlay SHALL NOT display the message content preview section
2. THE Message_Actions_Overlay SHALL display the react emoji row as the first element
3. THE Message_Actions_Overlay SHALL display action options (copy, reply, forward, report, delete) below the react row
4. THE Message_Actions_Overlay SHALL maintain consistent spacing between action elements
5. THE Message_Actions_Overlay SHALL maintain the purple background for emoji buttons

## Non-Functional Requirements

### Performance

1. WHEN a user selects an image from gallery, THE Conversation_Screen SHALL display the image preview within 500 milliseconds
2. WHEN a user opens the Message_Actions_Overlay, THE overlay SHALL appear within 100 milliseconds of the long-press gesture completion
3. THE Invitation_Overlay SHALL render without Background_Dimming within 200 milliseconds of conversation screen load

### Usability

1. THE Message_Actions_Overlay SHALL be positioned to avoid obscuring the selected message when possible
2. THE Attachment_Overlay SHALL provide clear visual feedback when an image or file is being processed
3. THE Invitation_Overlay transparency SHALL not reduce the readability of the overlay content

### Compatibility

1. THE image and file sending feature SHALL work on both iOS and Android platforms
2. THE overlay positioning SHALL adapt to different screen sizes and orientations
3. THE transparent background feature SHALL work with Flutter's modal bottom sheet implementation

### Accessibility

1. THE Message_Actions_Overlay SHALL maintain sufficient contrast ratios for all text and icons
2. THE Invitation_Overlay SHALL remain readable against any conversation background content
3. THE image and file messages SHALL include appropriate semantic labels for screen readers

## Constraints and Assumptions

### Constraints

1. The implementation SHALL use Flutter's existing modal and dialog components
2. The file upload SHALL use the existing backend messaging API endpoints
3. The overlay positioning SHALL work within Flutter's layout constraints
4. The transparent background SHALL be achieved through Flutter's modal configuration parameters

### Assumptions

1. The backend messaging service supports image and file uploads
2. The device has sufficient storage for temporary file caching during upload
3. Users have granted necessary permissions for gallery and file access
4. The existing message entity model can be extended to support image and file message types
5. Network connectivity is available for file uploads
6. The Flutter image_picker and file_picker packages are already integrated in the project
