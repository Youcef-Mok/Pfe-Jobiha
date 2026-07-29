# Requirements Document

## Introduction

This document specifies the requirements for redesigning the notifications page in a Flutter job application. The redesign introduces a modern, categorized notification system with three distinct notification types (Jobs, Applications, Messages), visual state indicators, expandable cards, and contextual action buttons. The design emphasizes visual hierarchy through colored borders, clear read/unread states, and temporal grouping.

## Glossary

- **Notification_System**: The Flutter-based notification display and management system
- **Notification_Card**: A single notification UI component displaying notification content
- **Notification_Type**: Category of notification (Jobs, Applications, or Messages)
- **Read_State**: Boolean indicator of whether a notification has been viewed
- **Expansion_State**: Boolean indicator of whether a notification card is expanded or collapsed
- **Filter_Tab**: UI control for filtering notifications by type
- **Section_Header**: Temporal grouping label (TODAY, YESTERDAY)
- **Action_Button**: Interactive button within expanded notification for user actions
- **Unread_Indicator**: Visual purple dot showing unread status
- **Border_Accent**: Colored left border identifying notification type
- **Avatar_Component**: Circular or rounded square image representing user or job
- **Badge_Icon**: Small icon overlay on avatar indicating notification context

## Requirements

### Requirement 1: Notification Type Classification

**User Story:** As a user, I want notifications categorized by type, so that I can quickly identify the context of each notification.

#### Acceptance Criteria

1. THE Notification_System SHALL support three Notification_Types: Jobs (grey border #545665), Applications (black border #000000), and Messages (violet border #401E66)
2. WHEN a notification is displayed, THE Notification_Card SHALL render a 3px wide Border_Accent on the left edge matching its Notification_Type color
3. THE Border_Accent SHALL have rounded corners matching the card's 12px border radius
4. WHEN a Jobs notification is displayed, THE Border_Accent SHALL use a gradient from #545665 to a lighter shade
5. FOR ALL Notification_Cards, the Border_Accent color SHALL uniquely identify the Notification_Type without requiring text labels

### Requirement 2: Read/Unread State Management

**User Story:** As a user, I want to see which notifications I haven't read yet, so that I can prioritize my attention.

#### Acceptance Criteria

1. WHEN a notification has Read_State = false, THE Notification_Card SHALL display an Unread_Indicator as an 8x8px purple circle (#3A1B5E) in the top-right corner
2. WHEN a notification has Read_State = true, THE Notification_Card SHALL NOT display an Unread_Indicator
3. WHEN a user taps a notification with Read_State = false, THE Notification_System SHALL update Read_State to true
4. WHEN a user taps "Mark all as read", THE Notification_System SHALL update Read_State to true for all notifications
5. FOR ALL notifications, the Read_State SHALL persist across app sessions

### Requirement 3: Notification Card Expansion

**User Story:** As a user, I want to expand notifications to see full details and available actions, so that I can interact with them efficiently.

#### Acceptance Criteria

1. WHEN Expansion_State = false, THE Notification_Card SHALL display only title, timestamp, and Avatar_Component
2. WHEN Expansion_State = true, THE Notification_Card SHALL display title, timestamp, Avatar_Component, full message content, and Action_Buttons
3. WHEN a user taps a collapsed Notification_Card, THE Notification_System SHALL set Expansion_State to true
4. WHEN a user taps an expanded Notification_Card header, THE Notification_System SHALL set Expansion_State to false
5. THE Notification_System SHALL animate the transition between Expansion_States with a smooth height animation

### Requirement 4: Page Header and Global Actions

**User Story:** As a user, I want to see a clear page title and mark all notifications as read at once, so that I can manage notifications efficiently.

#### Acceptance Criteria

1. THE Notification_System SHALL display "Notifications" as the page title using Inter font, 20px, weight 700
2. THE Notification_System SHALL display a "Mark all as read" link in the header aligned to the right
3. WHEN a user taps "Mark all as read", THE Notification_System SHALL update Read_State to true for all visible notifications
4. THE header SHALL have a white background (#FFFFFF) with bottom border or shadow for visual separation
5. THE "Mark all as read" link SHALL use violet color (#401E66) and Inter font, 14px, weight 600

### Requirement 5: Filter Tabs

**User Story:** As a user, I want to filter notifications by type, so that I can focus on specific categories.

#### Acceptance Criteria

1. THE Notification_System SHALL display four Filter_Tabs: "Toutes" (All), "jobs", "messagerie" (Messages), and "candidatures" (Applications)
2. WHEN a Filter_Tab is selected, THE Notification_System SHALL display only notifications matching that Notification_Type
3. WHEN "Toutes" Filter_Tab is selected, THE Notification_System SHALL display all notifications regardless of type
4. THE active Filter_Tab SHALL use violet color (#401E66) with bottom border indicator
5. THE inactive Filter_Tabs SHALL use grey color (#64748B) without bottom border

### Requirement 6: Temporal Grouping

**User Story:** As a user, I want notifications grouped by time, so that I can understand when events occurred.

#### Acceptance Criteria

1. THE Notification_System SHALL display Section_Headers for temporal groups: "TODAY" and "YESTERDAY"
2. WHEN notifications exist from today, THE Notification_System SHALL display "TODAY" Section_Header above them
3. WHEN notifications exist from yesterday, THE Notification_System SHALL display "YESTERDAY" Section_Header above them
4. THE Section_Headers SHALL use uppercase text, grey color (#94A3B8), Inter font, 12px, weight 700
5. THE Section_Headers SHALL have 16px top margin and 8px bottom margin for visual separation

### Requirement 7: Notification Card Visual Design

**User Story:** As a user, I want notifications to have a clean, modern appearance, so that the interface is pleasant to use.

#### Acceptance Criteria

1. THE Notification_Card SHALL have white background (#FFFFFF), 12px border radius, and 1px border (#F8FAFC)
2. THE Notification_Card SHALL have shadow: 0px 1px 2px rgba(0, 0, 0, 0.05)
3. THE Notification_Card SHALL have 12px internal padding on all sides
4. WHEN multiple Notification_Cards are displayed, THE Notification_System SHALL add 8px vertical spacing between them
5. THE page background SHALL use color #F7F6F8

### Requirement 8: Avatar Display

**User Story:** As a user, I want to see relevant images or icons with notifications, so that I can quickly identify the source.

#### Acceptance Criteria

1. THE Avatar_Component SHALL be 48x48px in size
2. WHEN Notification_Type = Messages, THE Avatar_Component SHALL display a circular user photo with a message Badge_Icon overlay
3. WHEN Notification_Type = Jobs, THE Avatar_Component SHALL display a square image with 8px rounded corners and a job Badge_Icon overlay
4. WHEN Notification_Type = Applications, THE Avatar_Component SHALL display a circular icon with colored background
5. THE Badge_Icon SHALL be 16x16px, positioned at bottom-right of Avatar_Component with white border for contrast

### Requirement 9: Typography and Text Hierarchy

**User Story:** As a user, I want text to be clearly readable with proper hierarchy, so that I can scan notifications quickly.

#### Acceptance Criteria

1. THE notification title SHALL use Inter font, 16px, weight 600, color #0F172A
2. THE timestamp SHALL use Inter font, 10px, weight 400, color #94A3B8
3. THE message content SHALL use Inter font, 14px, weight 400, color #475569
4. THE font family SHALL be Inter or Plus Jakarta Sans as fallback
5. THE text SHALL have proper line height for readability: title 1.4, message 1.43, timestamp 1.5

### Requirement 10: Action Buttons

**User Story:** As a user, I want to perform actions directly from notifications, so that I can respond quickly without navigating away.

#### Acceptance Criteria

1. WHEN Expansion_State = true, THE Notification_Card SHALL display relevant Action_Buttons based on Notification_Type
2. THE primary Action_Buttons ("Répondre", "Fixer rdv") SHALL have violet background (#401E66) and white text
3. THE secondary Action_Buttons ("Voir les profils", "Modifier", "Prolonger", "Valider") SHALL have light backgrounds (#F1F5F9) and dark text (#334155)
4. THE Action_Buttons SHALL use Inter font, 14px, weight 600
5. THE Action_Buttons SHALL have 8px horizontal spacing between them and 12px top margin from message content

### Requirement 11: Scrollable Notification List

**User Story:** As a user, I want to scroll through all my notifications, so that I can access older items.

#### Acceptance Criteria

1. THE Notification_System SHALL display notifications in a vertically scrollable list
2. THE scrollable area SHALL start below the Filter_Tabs and extend to the bottom of the screen
3. WHEN the notification list exceeds viewport height, THE Notification_System SHALL enable vertical scrolling
4. THE scroll behavior SHALL be smooth with momentum scrolling on mobile devices
5. THE Notification_System SHALL maintain scroll position when returning from other screens

### Requirement 12: Empty State

**User Story:** As a user, I want to see a helpful message when I have no notifications, so that I understand the page is working correctly.

#### Acceptance Criteria

1. WHEN no notifications exist for the selected Filter_Tab, THE Notification_System SHALL display an empty state message
2. THE empty state SHALL include an icon, heading "Aucune notification", and descriptive text
3. THE empty state SHALL be vertically and horizontally centered in the available space
4. THE empty state text SHALL use Inter font with appropriate sizing and grey color (#64748B)
5. THE empty state SHALL adapt its message based on the active Filter_Tab

### Requirement 13: Notification Timestamp Display

**User Story:** As a user, I want to see when each notification was received, so that I can understand the timeline of events.

#### Acceptance Criteria

1. THE Notification_Card SHALL display a timestamp in the format "Xh" for hours, "Xmin" for minutes, or "Xj" for days
2. WHEN a notification is less than 1 hour old, THE timestamp SHALL display minutes (e.g., "5min")
3. WHEN a notification is less than 24 hours old, THE timestamp SHALL display hours (e.g., "3h")
4. WHEN a notification is 1 or more days old, THE timestamp SHALL display days (e.g., "2j")
5. THE timestamp SHALL be positioned in the top-right area of the Notification_Card, adjacent to the Unread_Indicator

### Requirement 14: Notification Type Icons

**User Story:** As a user, I want to see contextual icons on notification avatars, so that I can quickly identify the notification purpose.

#### Acceptance Criteria

1. WHEN Notification_Type = Messages, THE Badge_Icon SHALL display a message/chat icon
2. WHEN Notification_Type = Jobs, THE Badge_Icon SHALL display a briefcase or job-related icon
3. WHEN Notification_Type = Applications, THE Badge_Icon SHALL display a document or application-related icon
4. THE Badge_Icon SHALL have a white background circle for contrast against the Avatar_Component
5. THE Badge_Icon SHALL use the appropriate Notification_Type color for the icon itself

### Requirement 15: Responsive Layout

**User Story:** As a user, I want the notifications page to work well on different screen sizes, so that I can use it on any device.

#### Acceptance Criteria

1. THE Notification_System SHALL adapt layout for screen widths from 320px to 1024px
2. WHEN screen width is less than 600px, THE Notification_Card SHALL use single-column layout for Action_Buttons
3. WHEN screen width is 600px or greater, THE Notification_Card SHALL use horizontal layout for Action_Buttons
4. THE Filter_Tabs SHALL remain horizontally scrollable on narrow screens
5. THE page margins SHALL be 16px on mobile and 24px on tablet/desktop

### Requirement 16: Notification Card Interaction Feedback

**User Story:** As a user, I want visual feedback when I interact with notifications, so that I know my actions are registered.

#### Acceptance Criteria

1. WHEN a user taps a Notification_Card, THE Notification_System SHALL provide visual feedback with a subtle background color change
2. WHEN a user hovers over an Action_Button (on desktop), THE Action_Button SHALL darken slightly
3. WHEN a user taps an Action_Button, THE Action_Button SHALL show a pressed state with scale animation
4. THE interaction feedback SHALL complete within 150ms for responsive feel
5. THE Notification_Card SHALL have a ripple effect on tap (Material Design standard)

### Requirement 17: Notification Content Truncation

**User Story:** As a user, I want long notification messages to be handled gracefully, so that the interface remains clean.

#### Acceptance Criteria

1. WHEN Expansion_State = false AND message length exceeds 100 characters, THE Notification_Card SHALL NOT display message content
2. WHEN Expansion_State = true, THE Notification_Card SHALL display the full message content without truncation
3. WHEN a notification title exceeds 2 lines, THE Notification_System SHALL truncate with ellipsis (...)
4. THE message content SHALL support line breaks and maintain formatting
5. THE Notification_Card SHALL expand vertically to accommodate full message content when expanded

### Requirement 18: Notification Persistence and Sync

**User Story:** As a user, I want my notification states to sync across devices, so that I have a consistent experience.

#### Acceptance Criteria

1. WHEN Read_State changes, THE Notification_System SHALL persist the change to the backend API
2. WHEN the app launches, THE Notification_System SHALL fetch the latest notification states from the backend
3. WHEN new notifications arrive, THE Notification_System SHALL update the display in real-time
4. THE Notification_System SHALL handle network failures gracefully with retry logic
5. THE Notification_System SHALL cache notifications locally for offline viewing

### Requirement 19: Accessibility

**User Story:** As a user with accessibility needs, I want the notifications page to be fully accessible, so that I can use it effectively.

#### Acceptance Criteria

1. THE Notification_Card SHALL have semantic labels for screen readers describing notification type and read state
2. THE Action_Buttons SHALL have descriptive labels and sufficient touch target size (minimum 44x44px)
3. THE color contrast between text and backgrounds SHALL meet WCAG AA standards (minimum 4.5:1 for normal text)
4. THE Notification_System SHALL support keyboard navigation for all interactive elements
5. THE Unread_Indicator SHALL have a text alternative for screen readers ("unread notification")

### Requirement 20: Performance

**User Story:** As a user, I want the notifications page to load quickly and scroll smoothly, so that I have a responsive experience.

#### Acceptance Criteria

1. THE Notification_System SHALL render the initial viewport of notifications within 500ms of page load
2. WHEN scrolling through 100+ notifications, THE Notification_System SHALL maintain 60fps scroll performance
3. THE Notification_System SHALL implement lazy loading for notifications beyond the initial viewport
4. THE Notification_System SHALL cache rendered notification cards for smooth re-expansion
5. THE expansion animation SHALL complete within 300ms with smooth easing curve
