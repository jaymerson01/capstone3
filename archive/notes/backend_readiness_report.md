# Backend Readiness Analysis & Implementation Checklist

Based on an analysis of the Data Layer and Presentation Layer of `clean_folder`, here is an assessment of the application's readiness for a live Firebase backend implementation.

## 📝 Implementation Progress Checklist
*This checklist tracks the ongoing progress of replacing mocked data with live Firebase integrations.*

- [x] **Incident Reporting Core**: Wired to Firestore (`incidents` collection) with offline Hive caching.
- [x] **AI Remote Triage**: Implements actual REST API calls via `IncidentAiRemoteDataSource`.
- [ ] **Authentication System**: Rewrite `AuthRepositoryImpl` to use `FirebaseAuth.instance.signInWithEmailAndPassword()` instead of returning `mock_uid_123`.
- [ ] **Admin Routing Logic**: Replace hardcoded `email == 'admin@safe.gov'` check in Login Page with Firebase Custom Claims or a Firestore `users` collection role check.
- [ ] **Resident Settings Page**: Remove hardcoded profile names/emails. Fetch current user from `AuthBloc`. Implement actual `deleteAccount` logic.
- [ ] **Admin Settings Page**: Remove dummy initial values (`Admin User`). Wire "Save Changes" button to actually update Firebase Auth profile/password.
- [ ] **Admin Dashboard - User Management**: Replace static table with real-time stream of registered users from Firestore.
- [ ] **Admin Dashboard - Area Management**: Replace static `_dummyAreas` list with a `StreamBuilder` connected to an `areas` Firestore collection.
- [ ] **Admin Dashboard - Incident Categories**: Replace static `_dummyCategories` list with a `StreamBuilder` connected to a `categories` Firestore collection.

---

## Detailed Analysis

### ✅ Ready for Live Backend
The following systems are correctly wired to standard data sources and are ready for you to plug in your live `google-services.json` and initialize Firebase:

1. **Incident Reporting Core (`IncidentRepositoryImpl`)**
   - **Firestore Syncing**: Actively uses `FirebaseFirestore.instance.collection('incidents')` to stream real-time incidents and submit new reports.
   - **Offline Caching**: Correctly intercepts network drops and falls back to a local `Hive` database box to cache incidents offline.
2. **AI Remote Triage (`IncidentAiRemoteDataSource`)**
   - Implements actual REST API calls (or SDK logic) with proper internet connection validation and ServerException error handling.

### ❌ Not Ready (Hardcoded / Mocked Data)
The following features will **not** interact with your live Firebase backend yet because they are entirely hardcoded or mocked out:

1. **Authentication System**
   - **Status**: Completely mocked (`AuthRepositoryImpl.dart`).
   - **Issue**: Registration and login do not use `FirebaseAuth`. They return a hardcoded `UserEntity` regardless of the email/password entered. 

2. **Resident Settings Page (`settings_page.dart`)**
   - **Status**: Hardcoded UI.
   - **Issue**: The profile header uses static strings for the name and email. The action buttons (Delete Account) just trigger local UI popups without deleting Auth credentials.

3. **Admin Settings Page (`profile_settings_page.dart`)**
   - **Status**: Hardcoded UI & Mock Actions.
   - **Issue**: The text fields are initialized with dummy values. The "Save Changes" button has a `TODO` comment and only triggers a snackbar.

4. **Admin Routing Logic**
   - **Status**: Insecure Bypass.
   - **Issue**: The Login Page routes to the Admin Portal based solely on a hardcoded string check.

5. **Admin Dashboard Modules**
   - **Status**: Missing BLoCs and DataSources.
   - **Issue**: Renders hardcoded tables and static grids for User Management, Area Management, and Incident Categories.
