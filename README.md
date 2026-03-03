# kigali city services directory

flutter app for finding and managing local services and places around kigali. you can browse hospitals, restaurants, police stations, parks, and more — search, filter by category, view them on a map, and manage your own listings.

## what it does

- email signup/login with verification
- browse all listings with search bar and category filters
- tap any listing to see details + location on map
- get directions via google maps
- add, edit, delete your own listings
- see all places on a full map with markers
- settings page with profile info and notification toggle

## tech used

- flutter + dart
- firebase auth (email/password)
- cloud firestore (realtime database)
- google maps flutter plugin
- provider for state management
- geolocator for getting user location
- shared_preferences for local settings

## project structure

```
lib/
├── models/          # listing and user profile models
├── services/        # auth and firestore service classes
├── providers/       # changenotifier providers for state
├── screens/
│   ├── auth/        # login, signup, email verification
│   ├── home/        # bottom nav host
│   ├── directory/   # listing browse + detail
│   ├── my_listings/ # user's listings + create/edit form
│   ├── map/         # map view with all markers
│   └── settings/    # profile and preferences
└── widgets/         # reusable listing card
```

## how to run

1. set up a firebase project, enable email/password auth and cloud firestore
2. run `flutterfire configure` to generate `firebase_options.dart`
3. add your google maps api key to android manifest and ios appdelegate
4. `flutter pub get`
5. `flutter run`

## firestore collections

**users** — uid, email, displayName, createdAt

**listings** — name, category, address, contactNumber, description, latitude, longitude, createdBy, createdAt

## state management

uses provider with a service layer pattern:

```
firebase → service class → provider (changenotifier) → ui widgets
```

auth state is handled reactively — the root widget watches auth status and swaps between login and home screen automatically. listings stream from firestore in realtime through the provider so the ui always stays in sync.
