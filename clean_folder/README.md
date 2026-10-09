# ResQ — Community Safety App (Barangay Moonwalk)

One Flutter codebase, two apps:

| App | Entry file | Runs on | For |
|---|---|---|---|
| Resident app | `lib/main_resident.dart` | Android APK | Residents: report incidents, My Reports, map, hotlines, AI assistant |
| Admin portal | `lib/main_admin.dart` | Web (Firebase Hosting) | Barangay desk: reports desk, dispatch map, analytics, users, sirens |

Backend: **Firebase** (Auth, Firestore, Cloud Messaging, Cloud Functions) +
**Cloudinary** (evidence photos/videos) + **Gemini** (through a Cloud Function).

## Folder map

```
clean_folder/
├── lib/
│   ├── main_resident.dart / main_admin.dart / main.dart   app entry points
│   ├── core/            shared services, theme, config, widgets
│   └── features/        auth, incident, incident_reporting, admin_dashboard, chat, notifications
├── functions/           Cloud Functions: geminiAssist, pushOnBroadcast, pushOnNotification
├── firestore.rules      who can read/write what (security)
├── firestore.indexes.json
├── storage.rules
├── firebase.json        deploy config (rules, functions, hosting)
├── docs/                defense / architecture notes
└── test/                unit tests
```

## First-time setup (each teammate)

1. Install Flutter, Android Studio, Node.js 22, and the Firebase CLI:
   `npm install -g firebase-tools`
2. `firebase login`
3. In this folder: `flutter pub get`
4. In `functions/`: `npm install`

No `.env` file is needed anymore. The Gemini key lives on the server as a
Cloud Functions secret (see below). Cloudinary's public values are in
`lib/core/config/app_config.dart`.

## Run

```bash
flutter run -t lib/main_resident.dart            # resident app on phone/emulator
flutter run -d chrome -t lib/main_admin.dart     # admin portal in Chrome
```

## Deploy

The project must be on the Firebase **Blaze** plan (needed for Cloud Functions).

```bash
# once: store the Gemini key on the server (paste it when asked)
firebase functions:secrets:set GEMINI_API_KEY

# database rules + indexes + functions
firebase deploy --only firestore,functions

# admin web portal
flutter build web -t lib/main_admin.dart --release
firebase deploy --only hosting

# resident APK
flutter build apk -t lib/main_resident.dart --release
# → build/app/outputs/flutter-apk/app-release.apk
```

Deploy rules, functions, the web portal, and the new APK together. Older
APKs still write names/phone numbers into the public report, which the new
rules reject.

## Security model (short version)

- Residents can only read their **own** profile. Admins can read all.
- Nobody can make themselves admin, un-suspend themselves, or self-verify.
- Suspended accounts are signed out and can't file reports.
- Reports are public **without** contact details. Reporter name/email and
  victim name/phone are in `incidents/{id}/confidential/contact`, readable only
  by the reporter and admins.
- "Me Too" upvotes: exactly +1, once per person, never on your own report.
  Urgency escalation is computed from the upvote count.
- Audit logs: admin-only, can't be edited or deleted.
- Notifications: residents only see their own and shared ones; shared ones
  have per-person read/dismiss.
- Gemini: only the `geminiAssist` function holds the key; signed-in, active
  users only, 10 requests per minute each.

## Making someone an admin

In the Firebase console → Firestore → `users/{uid}` → set `role` to `admin`.
(Or have an existing admin do it.)
