# Requirements Document

## Introduction

This feature enhances the Profile CV Section UI in the Flutter mobile app by adding visual distinction for validated formations, enabling certificate viewing through clickable formation cards, and standardizing the background color for language cards. These enhancements improve the user experience by making validated credentials more prominent and accessible while maintaining visual consistency across the CV section.

## Glossary

- **CV_Section**: The profile component displaying formations, experiences, languages, and skills in an animated card stack interface
- **Formation_Card**: A UI card component displaying educational credentials (title, institution, location, year) within the CV section
- **Validated_Formation**: A formation entry where the `isActive` field is true, indicating the diploma has been verified
- **Certificate_Viewer**: A modal overlay (`CertificateViewerOverlay`) that displays certificate details including title, institution, and uploaded files
- **Language_Card**: A UI card component displaying language proficiency information within the Skills section
- **Gray_Background**: The color #EFEDF2 used for validated formations and language cards, matching the job card styling
- **Timeline_Content_Widget**: The Flutter widget responsible for rendering formation and experience cards in the CV section
- **Language_Card_Widget**: The Flutter widget (`_LanguageCard`) responsible for rendering language proficiency cards

## Requirements

### Requirement 1: Visual Distinction for Validated Formations

**User Story:** As a candidate viewing my profile, I want validated diplomas to stand out visually, so that I can quickly identify which credentials have been verified.

#### Acceptance Criteria

1. WHEN a Formation_Card has `isActive == true`, THE Timeline_Content_Widget SHALL render the card with Gray_Background (#EFEDF2)
2. WHEN a Formation_Card has `isActive == false`, THE Timeline_Content_Widget SHALL render the card with white background (#FFFFFF)
3. THE validated Formation_Card SHALL maintain all existing styling properties (border radius, border color, padding, text styles)
4. THE validated Formation_Card SHALL display the "VALIDE" badge with existing styling (purple icon, purple text, light purple background)

### Requirement 2: Interactive Certificate Viewing

**User Story:** As a candidate viewing my profile, I want to tap on validated diploma cards, so that I can view my certificate details in a modal overlay.

#### Acceptance Criteria

1. WHEN a Formation_Card has `isActive == true`, THE Timeline_Content_Widget SHALL make the card tappable
2. WHEN a user taps a validated Formation_Card, THE CV_Section SHALL open the Certificate_Viewer modal
3. WHEN the Certificate_Viewer opens, THE CV_Section SHALL pass the formation title to the Certificate_Viewer
4. WHEN the Certificate_Viewer opens, THE CV_Section SHALL pass the institution name to the Certificate_Viewer
5. WHEN a Formation_Card has `isActive == false`, THE Timeline_Content_Widget SHALL NOT respond to tap gestures
6. THE tappable Formation_Card SHALL provide visual feedback (ripple effect or opacity change) during tap interaction
7. THE Certificate_Viewer SHALL display using the existing `CertificateViewerOverlay` widget from `profile_add_overlays.dart`
8. THE Certificate_Viewer SHALL be presented as a bottom sheet modal with `isScrollControlled: true` and `backgroundColor: Colors.transparent`

### Requirement 3: Standardized Language Card Styling

**User Story:** As a candidate viewing my profile, I want language cards to have consistent styling with other card elements, so that the interface feels cohesive and professional.

#### Acceptance Criteria

1. THE Language_Card_Widget SHALL render with Gray_Background (#EFEDF2) instead of the current background color (#F8F9FB)
2. THE Language_Card_Widget SHALL maintain all existing styling properties (border radius of 12, padding, text styles)
3. THE Language_Card_Widget SHALL preserve the existing layout (language name in bold, level text below)
4. THE Language_Card_Widget SHALL maintain the existing grid layout (2 columns, 12px spacing, 70px height)

### Requirement 4: Design System Consistency

**User Story:** As a developer maintaining the app, I want all styling changes to follow the existing design system, so that the codebase remains consistent and maintainable.

#### Acceptance Criteria

1. THE CV_Section SHALL use the existing `_kJobCardGray` constant (Color(0xFFEFEDF2)) from `profile_add_overlays.dart` for gray backgrounds
2. THE CV_Section SHALL maintain the existing Plus Jakarta Sans font family for all text elements
3. THE CV_Section SHALL preserve all existing border radius values (12px for cards, 20px for main containers)
4. THE CV_Section SHALL maintain the existing color constants (_kViolet, _kVioletLight, _kLightBg, _kBlack)
5. THE CV_Section SHALL preserve the existing animation behavior for card stack interactions
