# demo video script (~7 min)

> this file is not committed to git — it's just a guide for recording the demo video.

---

## intro (30 sec)

"hey, so this is my kigali city services directory app. it's built with flutter and firebase. i'll walk through all the features real quick."

## 1. signup and login (1 min)

- open the app, show the login screen
- "let me create a new account first"
- tap sign up, fill in name, email, password
- "it uses firebase auth with email verification"
- show the verification screen, check email, verify
- "once verified it takes me straight to the home screen"

## 2. directory and search (1 min)

- show the directory tab with listings
- "this is the main directory — it shows all listings from firestore in realtime"
- type something in the search bar
- "search works on name and address"
- tap a few category filter chips
- "and you can filter by category — hospitals, restaurants, parks, etc"
- clear filters

## 3. listing detail (45 sec)

- tap on a listing
- "each listing has a detail page with all the info"
- scroll to show the map
- "there's an embedded google map showing the location"
- tap get directions
- "and this button opens google maps for navigation"
- go back

## 4. create a listing (1 min)

- go to my listings tab
- tap the add button
- "let me add a new place"
- fill in name, pick a category, add address, phone, description
- tap use my location (or manually enter coords)
- "i can use my current location or type in coordinates manually"
- tap create
- "and it saves to firestore — you can see it appear right away"

## 5. edit and delete (45 sec)

- tap the three dots on the listing just created
- tap edit
- "i can edit any of my listings"
- change something small, save
- "and the changes show up immediately because of the realtime stream"
- tap three dots again, delete
- confirm delete
- "delete works too — with a confirmation dialog so you don't accidentally remove stuff"

## 6. map view (45 sec)

- switch to map tab
- "this is the map view — every listing shows up as a marker"
- tap on a marker
- "tapping a marker shows a preview card at the bottom"
- zoom around a bit
- "you can zoom and pan around kigali to find places"

## 7. settings (30 sec)

- switch to settings tab
- "settings shows my profile info from firebase"
- toggle the notification switch
- "this notification toggle is saved locally with shared preferences"
- tap sign out
- "and sign out takes me back to login"

## wrap up (15 sec)

- show login screen
- "that's pretty much it. flutter with firebase auth, firestore for crud with realtime updates, google maps, provider for state management, and a clean service layer architecture. thanks for watching."

---

**total: ~6.5 min**

tips:
- keep it casual, don't read word for word
- make sure the simulator is zoomed in enough to see the ui
- if something loads slow blame the simulator lol
