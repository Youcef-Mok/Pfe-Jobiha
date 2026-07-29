# Bugfix Requirements Document

## Introduction

This document covers five bugs in the Flutter messaging feature, affecting three files:
`private_message_screen.dart`, `report_screen.dart`, and `message_actions_sheet.dart`.

**Bug 1 — RenderFlex overflow**: The `_ReportDetailSheet` (bottom sheet shown after tapping
"Envoyer le signalement") causes a massive RenderFlex overflow (99481 pixels on the bottom)
when the keyboard appears, crashing the layout.

**Bug 2 — Gallery and File pickers do nothing**: Tapping "Galerie" or "Fichier" in the
`_AttachmentOverlay` dismisses the dialog but never opens the image picker or file picker,
leaving the user unable to attach any file.

**Bug 3 — Attachment overlay too wide**: The `_AttachmentOverlay` container has a fixed width
of 178, which the user considers slightly too wide for the design.

**Bug 4 — Report detail sheet layout errors**: The `_ReportDetailSheet` uses `autofocus: true`
on its `TextField` combined with `isScrollControlled: true`, `mainAxisSize: MainAxisSize.min`,
and `Padding(bottom: MediaQuery.of(ctx).viewInsets.bottom)`. When the keyboard appears, this
combination causes assertion failures and layout errors because the sheet tries to shrink-wrap
its content while simultaneously being pushed up by the keyboard inset padding.

**Bug 5 — Overflow in message reply overlay**: The `messageActionsSheet` widget (in
`frontend/lib/features/messaging/widgets/message_actions_sheet.dart`) displays yellow/black
overflow stripes on the bottom every time it is opened via long-press on a message in
`private_message_screen.dart`. The overflow occurs consistently regardless of message length
or screen size.

---

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN the user opens the report detail sheet (`_ReportDetailSheet`) and the keyboard appears
    THEN the system overflows by ~99481 pixels on the bottom with a RenderFlex overflow error

1.2 WHEN the user opens the report detail sheet and the keyboard appears
    THEN the system throws an assertion failure in `framework.dart:6268`

1.3 WHEN the user taps "Galerie" in the `_AttachmentOverlay`
    THEN the system dismisses the overlay but does NOT open the image gallery picker

1.4 WHEN the user taps "Fichier" in the `_AttachmentOverlay`
    THEN the system dismisses the overlay but does NOT open the file picker

1.5 WHEN the `_AttachmentOverlay` is displayed
    THEN the system renders it with a width of 178, which is wider than desired

1.6 WHEN the `_ReportDetailSheet` is built with `mainAxisSize: MainAxisSize.min` inside a
    `showModalBottomSheet` with `isScrollControlled: true` and keyboard inset padding applied
    via `Padding(bottom: MediaQuery.of(ctx).viewInsets.bottom)` on the outer wrapper
    THEN the system produces layout errors because the Column cannot resolve its height
    constraints when the keyboard is visible

1.7 WHEN the user long-presses a message to open the `messageActionsSheet` overlay
    THEN the system displays yellow/black overflow stripes on the bottom of the sheet

### Expected Behavior (Correct)

2.1 WHEN the user opens the report detail sheet and the keyboard appears
    THEN the system SHALL display the sheet without any overflow or layout error, scrolling
    or resizing correctly to accommodate the keyboard

2.2 WHEN the user opens the report detail sheet and the keyboard appears
    THEN the system SHALL not throw any assertion failures

2.3 WHEN the user taps "Galerie" in the `_AttachmentOverlay`
    THEN the system SHALL dismiss the overlay AND successfully open the device image gallery
    picker

2.4 WHEN the user taps "Fichier" in the `_AttachmentOverlay`
    THEN the system SHALL dismiss the overlay AND successfully open the file picker

2.5 WHEN the `_AttachmentOverlay` is displayed
    THEN the system SHALL render it with a width slightly narrower than 178 (target: 160)

2.6 WHEN the `_ReportDetailSheet` is built inside `showModalBottomSheet` with
    `isScrollControlled: true`
    THEN the system SHALL apply keyboard inset padding correctly so the sheet resizes without
    layout errors when the keyboard appears or disappears

2.7 WHEN the user long-presses a message to open the `messageActionsSheet` overlay
    THEN the system SHALL display the sheet without any overflow stripes or layout errors

### Unchanged Behavior (Regression Prevention)

3.1 WHEN the user opens the report screen and selects a reason without tapping "Envoyer le
    signalement"
    THEN the system SHALL CONTINUE TO display the reason list correctly with no layout errors

3.2 WHEN the user taps "Envoyer le signalement" with a reason selected and the keyboard does
    NOT appear
    THEN the system SHALL CONTINUE TO show the `_ReportDetailSheet` correctly

3.3 WHEN the user taps the attachment icon (➕) in the message input bar
    THEN the system SHALL CONTINUE TO display the `_AttachmentOverlay` in the correct position
    above the input bar

3.4 WHEN the user dismisses the `_AttachmentOverlay` by tapping outside it
    THEN the system SHALL CONTINUE TO close the overlay without any side effects

3.5 WHEN the user sends a report by tapping "Envoyer le signalement" in the detail sheet
    THEN the system SHALL CONTINUE TO show the success snackbar and navigate back

3.6 WHEN the user interacts with the message list, reply, block, or restrict features
    THEN the system SHALL CONTINUE TO function without any regression

3.7 WHEN the user taps an action button (copy, reply, forward, report, delete) in the
    `messageActionsSheet`
    THEN the system SHALL CONTINUE TO execute the corresponding action correctly

3.8 WHEN the user taps an emoji reaction in the `messageActionsSheet`
    THEN the system SHALL CONTINUE TO handle the reaction correctly

---

## Bug Condition Derivation

### Bug 1 & 4 — Report Detail Sheet Layout

```pascal
FUNCTION isBugCondition_ReportSheet(X)
  INPUT: X of type ReportDetailSheetContext
  OUTPUT: boolean

  RETURN X.isScrollControlled = true
     AND X.outerPaddingUsesViewInsets = true
     AND X.columnMainAxisSize = MainAxisSize.min
     AND X.keyboardVisible = true
END FUNCTION
```

```pascal
// Property: Fix Checking — Report Sheet Layout
FOR ALL X WHERE isBugCondition_ReportSheet(X) DO
  result ← buildReportDetailSheet'(X)
  ASSERT no_overflow(result)
    AND no_assertion_failure(result)
    AND sheet_visible(result)
END FOR

// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition_ReportSheet(X) DO
  ASSERT buildReportDetailSheet(X) = buildReportDetailSheet'(X)
END FOR
```

### Bug 2 — Attachment Picker Not Launching

```pascal
FUNCTION isBugCondition_AttachmentPicker(X)
  INPUT: X of type AttachmentTapEvent
  OUTPUT: boolean

  RETURN X.dialogUsesShowDialog = true
     AND X.callbackCallsNavigatorPop = true
     AND X.pickerCalledAfterPop = true
     AND (X.button = Gallery OR X.button = File)
END FUNCTION
```

```pascal
// Property: Fix Checking — Attachment Picker Launch
FOR ALL X WHERE isBugCondition_AttachmentPicker(X) DO
  result ← handleAttachmentTap'(X)
  ASSERT picker_launched(result)
END FOR

// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition_AttachmentPicker(X) DO
  ASSERT handleAttachmentTap(X) = handleAttachmentTap'(X)
END FOR
```

### Bug 3 — Overlay Width

```pascal
FUNCTION isBugCondition_OverlayWidth(X)
  INPUT: X of type AttachmentOverlayRender
  OUTPUT: boolean

  RETURN X.containerWidth >= 178
END FUNCTION
```

```pascal
// Property: Fix Checking — Overlay Width
FOR ALL X WHERE isBugCondition_OverlayWidth(X) DO
  result ← buildAttachmentOverlay'(X)
  ASSERT result.containerWidth < 178
    AND result.containerWidth >= 150
END FOR

// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition_OverlayWidth(X) DO
  ASSERT buildAttachmentOverlay(X) = buildAttachmentOverlay'(X)
END FOR
```

### Bug 5 — Message Actions Sheet Overflow

```pascal
FUNCTION isBugCondition_ActionsSheetOverflow(X)
  INPUT: X of type MessageActionsSheetContext
  OUTPUT: boolean

  RETURN X.sheetOpened = true
END FUNCTION
```

```pascal
// Property: Fix Checking — Actions Sheet Overflow
FOR ALL X WHERE isBugCondition_ActionsSheetOverflow(X) DO
  result ← buildMessageActionsSheet'(X)
  ASSERT no_overflow(result)
    AND no_overflow_stripes(result)
    AND sheet_renders_correctly(result)
END FOR

// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition_ActionsSheetOverflow(X) DO
  ASSERT buildMessageActionsSheet(X) = buildMessageActionsSheet'(X)
END FOR
```
