# Edit Profile Screen Placeholder Fix - Complete

## Problem
The edit profile screen showed placeholders on first open. Data only loaded after leaving and coming back to the screen.

## Root Cause

**Location:** `edit_profile_screen.dart` lines 36-51 (initState method)

**Issue:** The initialization code used:
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    final userAsync = ref.read(candidateCurrentUserProvider);  // ❌ One-time read
    userAsync.whenData((user) {  // ❌ Only fires if data already available
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          // ... other fields
        });
      }
    });
  });
}
```

**Why it failed:**
1. `ref.read()` reads the provider state **once** at that moment
2. `candidateCurrentUserProvider` is a `StateNotifierProvider` that loads data asynchronously
3. When `initState` runs, the provider is in `AsyncLoading` state (no data yet)
4. `whenData()` callback never executes because there's no data available
5. Controllers remain empty, showing placeholders
6. When user leaves and returns, the provider has cached data, so it works

## Solution

**Strategy:** Use `ref.watch()` in `build()` to reactively initialize controllers when data arrives.

### Changes Made

#### 1. Added initialization flag
```dart
class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // ... existing fields
  bool _controllersInitialized = false;  // ← ADDED
```

#### 2. Removed initState initialization
Removed the entire `initState()` method that was trying to initialize controllers too early.

#### 3. Added reactive initialization in build()
```dart
@override
Widget build(BuildContext context) {
  final userAsync = ref.watch(candidateCurrentUserProvider);  // ← Watch, not read

  // Initialize controllers when data arrives (only once)
  userAsync.whenData((user) {
    if (!_controllersInitialized && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_controllersInitialized) {
          setState(() {
            _nameController.text = user.name;
            _usernameController.text = user.name.toLowerCase().replaceAll(' ', '_');
            _bioController.text = user.bio;
            _locationController.text = user.location;
            _selectedDomain = user.domain;
            _selectedDomainIcon = _getDomainIcon(user.domain);
            _controllersInitialized = true;  // ← Prevent re-initialization
          });
        }
      });
    }
  });

  return Scaffold(
    // ... rest of UI
  );
}
```

## How It Works Now

### First Open Flow:
1. Screen opens → `build()` called
2. `ref.watch(candidateCurrentUserProvider)` subscribes to provider
3. Provider is in `AsyncLoading` state → UI shows (but controllers will be filled soon)
4. Provider finishes loading → `build()` called again with `AsyncData`
5. `whenData()` callback fires with user data
6. `addPostFrameCallback` schedules controller initialization after current frame
7. Controllers filled with real data → UI updates
8. `_controllersInitialized = true` prevents re-initialization on subsequent rebuilds

### Subsequent Opens:
1. Screen opens → `build()` called
2. `ref.watch(candidateCurrentUserProvider)` returns cached `AsyncData`
3. `whenData()` fires immediately with cached user data
4. Controllers initialized in first frame
5. User sees data immediately

## Key Improvements

✅ **Reactive:** Uses `ref.watch()` to react to provider state changes
✅ **Safe:** Double-checks `mounted` and `_controllersInitialized` to prevent errors
✅ **Efficient:** Only initializes once using `_controllersInitialized` flag
✅ **Proper timing:** Uses `addPostFrameCallback` to avoid setState during build
✅ **No race conditions:** Works whether data is cached or needs to be fetched

## Testing Checklist

- [ ] Open edit profile screen for the first time
  - ✅ Should show real data immediately (not placeholders)
- [ ] Edit a field and save
  - ✅ Should update successfully
- [ ] Close and reopen edit profile screen
  - ✅ Should show updated data immediately
- [ ] Test with slow network
  - ✅ Should show loading state, then fill fields when data arrives
- [ ] Test rapid navigation (open/close/open quickly)
  - ✅ Should not crash or show stale data

## Technical Notes

### Why `addPostFrameCallback`?
Calling `setState()` inside `build()` is not allowed. `addPostFrameCallback` schedules the state update for after the current frame completes, avoiding the error:
```
setState() or markNeedsBuild() called during build
```

### Why double-check `_controllersInitialized`?
The `whenData` callback fires on every rebuild when data is available. Without the flag:
- Controllers would be reset on every rebuild
- User edits would be lost
- Performance would suffer

### Why `ref.watch()` instead of `ref.read()`?
- `ref.read()` = one-time snapshot (doesn't react to changes)
- `ref.watch()` = subscribes to changes (rebuilds when provider updates)

For loading async data, `ref.watch()` is essential to react when data arrives.

## Files Modified

- ✅ `frontend/lib/features/profile/screens/edit_profile_screen.dart`
  - Removed `initState()` initialization
  - Added `_controllersInitialized` flag
  - Added reactive initialization in `build()` using `ref.watch()`

## No Changes To

- ❌ Providers (no changes needed)
- ❌ Backend (no changes needed)
- ❌ UI layout (no visual changes)
- ❌ Other screens (isolated fix)
