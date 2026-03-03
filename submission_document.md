# individual assignment — kigali city services directory

**course:** mobile application development
**student:** [your name here]
**date:** march 2026

---

## 1. app overview

this is a flutter mobile app that serves as a directory for services and places in kigali city. users can sign up, browse listings like hospitals, restaurants, parks, and police stations, and manage their own entries. the app uses firebase for authentication and data storage, and google maps for showing locations.

the main idea is simple — make it easy to find and share useful places around kigali. anyone can browse, but you need an account to add or edit listings.

## 2. setup and tools

- **flutter** as the framework (dart language)
- **firebase auth** for email/password login with email verification
- **cloud firestore** as the backend database with realtime listeners
- **google maps flutter** for map display and markers
- **provider** package for state management
- **geolocator** for device location
- **shared_preferences** for saving local settings like notification toggle

development was done in cursor ide, tested primarily on ios simulator (iphone 16 pro, ios 26 beta).

## 3. architecture and design decisions

i went with a **service layer pattern**:

```
firebase sdk → service class → provider (changenotifier) → ui
```

this keeps firebase logic out of the ui code. the two main services are `AuthService` (handles signup, login, signout, email verification) and `FirestoreService` (handles all crud operations on the listings collection).

providers sit between services and the ui — `AuthProvider` listens to auth state changes and exposes a status enum, while `ListingsProvider` manages two firestore streams (all listings + user's own listings) and handles search/filter logic in memory.

the root of the app uses a `_RootRouter` widget that watches `AuthProvider.status` and declaratively switches between the login screen and home screen. this means navigation after login/logout is fully automatic — no manual push/pop needed.

for the home screen i used `IndexedStack` with a `BottomNavigationBar` so all four tabs stay alive and don't rebuild when switching.

## 4. features implemented

| feature | description |
|---------|-------------|
| signup + login | email/password auth with form validation |
| email verification | polling timer checks verification status, blocks access until verified |
| directory | lists all places with search bar and horizontal category filter chips |
| listing detail | shows all info + embedded google map + get directions button |
| create listing | form with all fields, category dropdown, use-my-location button |
| edit listing | pre-fills existing data, updates in firestore |
| delete listing | confirmation dialog, removes from firestore |
| my listings | shows only the current user's listings |
| map view | full screen google map with markers for every listing, tap for preview |
| settings | shows user profile info, notification toggle (shared_preferences), sign out |

## 5. challenges and how i solved them

**cocoapods issues** — when setting up ios dependencies, pod install kept failing with cdn redirect errors and corrupted podspec files for grpc-core. had to clear the cocoapods trunk cache and delete corrupted spec files manually before it would work.

**simulator limitations** — the ios simulator can't access real gps, so geolocator would throw errors when trying to get location. solved this by adding a fallback that auto-fills kigali city center coordinates (-1.9441, 30.0619) when location fetch fails.

**form validation ux** — initially the form showed validation errors immediately on load because of how autovalidate worked. switched to `AutovalidateMode.onUserInteraction` so errors only show after the user actually touches a field.

**firestore composite index** — the "my listings" query uses both `where` (filter by user) and `orderBy` (sort by date), which firestore requires a composite index for. had to create this manually in the firebase console.

**double navigation bug** — the login screen was manually navigating to homescreen on success, but the root router was also doing it reactively. this caused a double-push. fixed by removing manual navigation and letting the router handle it.

## 6. reflection

this project helped me understand how flutter and firebase work together in practice. the provider pattern took some getting used to — especially understanding when to use `watch` vs `read` — but once it clicked, it made the data flow much cleaner than passing callbacks everywhere.

the biggest learning was around firestore's realtime streams. instead of fetching data once and refreshing manually, the app just listens to changes and the ui updates automatically. that's a nice pattern i'd use again.

if i had more time, i'd add image uploads for listings, better error states, and maybe a favorites system. the map could also benefit from clustering when there are many markers.

overall i'm happy with how the app turned out. it covers all the core requirements and the architecture is clean enough that adding new features wouldn't be painful.

---

*end of document*
