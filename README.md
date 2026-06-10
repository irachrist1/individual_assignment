# individual_assignment

Kigali City Services Directory — Flutter + Firebase class project for discovering local services.

## The problem

Citizens in Kigali need a searchable directory of hospitals, restaurants, police stations, parks, and other services — with directions, not phone-book guesswork.

## What it does

Flutter app with auth, browse/filter listings, map view, CRUD for your own listings, and Google Maps directions.

## Install

```bash
git clone https://github.com/irachrist1/individual_assignment.git && cd individual_assignment
flutterfire configure   # Firebase project required
flutter pub get && flutter run
```

Requires Firebase project and Google Maps API keys.

## How it works

- **Provider state management.** Auth and listing state via Provider — standard Flutter pattern for class-scale apps.
- **Firestore collections.** `users` and `listings` — realtime sync for community-submitted services.
- **Geolocator integration.** Location-aware browse and map pins — find services near you.
- **Google Maps directions.** Tap a listing → open directions — closes the loop from search to visit.

ALU class project · [Christian Tonny](https://github.com/irachrist1)
