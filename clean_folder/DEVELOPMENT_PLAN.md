# ResQ Clean Architecture: Comprehensive Development & Live Integration Roadmap

This document outlines the systematic, phased engineering roadmap to transition the **ResQ** community safety application from its current UI/Mock prototype state into a fully connected, production-ready Firebase backend.

It is structured specifically for **pair programming, team collaboration (groupmates), and AI agent task execution**, ensuring each phase builds cleanly on top of the previous one without breaking existing UI components or violating Clean Architecture principles.

---

## 1. System Baseline & Gap Matrix

| Feature / Module | Current Implementation | Target Production State |
| :--- | :--- | :--- |
| **Incident Stream & Caching** | ✅ Live Firestore + Hive box | Add status updates, dispatcher notes, and archiving |
| **Location GPS & Camera** | ✅ Real hardware geolocator & camera | Add offline media upload retry queue |
| **Gemini 1.5 Flash AI Triage** | ✅ Live REST API endpoint | Wire into floating safety assistant and auto-tagging |
| **Resident Authentication** | ⚠️ Mock repo (`user@safe.gov` / `user123`) | Real `FirebaseAuth` + Firestore `users/{uid}` |
| **Incident Report Coordinates** | ✅ Real device GPS on fetch | Pull real logged-in UID (eliminate hardcoded `'user123'`) |
| **Settings & Edit Profile** | ⚠️ Hardcoded strings (`John David Echano`) | Real-time fetch/update from Firestore `users/{uid}` |
| **Admin Incident Management** | ⚠️ UI mockup actions (`// TODO: Trigger BLoC`) | Live status update BLoC events wired to Firestore |
| **Admin Dashboard Stats/Charts** | ⚠️ Hardcoded numbers (`248`, `14`, `185`) | Dynamic calculations from Firestore collections |
| **Admin User/Area/Category Pages** | ⚠️ Static in-memory lists | Dedicated BLoCs + real-time Firestore collection streams |
| **Admin Login Gateway** | ⚠️ Hardcoded string check (`admin@safe.gov`) | Secure role-based authentication check (`role == 'admin'`) |

---

## 2. Engineering Phases Roadmap

### Phase 1: Authentication & User Profile Foundation (Clean Architecture) (Done -ycko)
**Goal:** Replace the mocked authentication with live `FirebaseAuth` and create the foundational Firestore `users` collection.

#### 1.1 Dependency & Entity Updates
- [ ] Add `firebase_auth: ^5.0.0` to `pubspec.yaml`.
- [ ] Expand `UserEntity` ([user_entity.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/auth/domain/entities/user_entity.dart)):
  - Fields: `id` (UID), `email`, `fullName`, `role` (`citizen`, `tanod`, `officer`, `admin`), `phoneNumber`, `address`, `barangayArea` / `sector`, `emergencyContactName`, `emergencyContactNumber`, `photoUrl`, `isVerified`, `isActive`, `createdAt`.
- [ ] Create `UserModel` in `lib/features/auth/data/models/user_model.dart` with `fromFirestore` and `toFirestore` serialization.

#### 1.2 Remote Data Source & Repository Implementation
- [ ] Create `AuthRemoteDataSource` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`:
  - `signInWithEmailAndPassword(email, password)`
  - `signUpWithEmailAndPassword(email, password, fullName)` -> writes initial document to `users/{uid}`
  - `signOut()`
  - `getCurrentUser()` & `streamAuthState()`
  - `updateUserProfile(UserModel model)`
  - `changePassword(currentPassword, newPassword)`
  - `deleteAccount()`
- [ ] Update `AuthRepositoryImpl` to delegate to `AuthRemoteDataSource` using `Either<Failure, UserEntity>`.
- [ ] Register new auth dependencies in [injection_container.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/core/services/injection_container.dart).

#### 1.3 Presentation & Gateways
- [ ] Update `AuthBloc` to expose the active user state (`Authenticated(UserEntity user)`).
- [ ] Connect `login_page.dart` and `sign_up_page.dart` to live `AuthBloc` states.
- [ ] Update `admin_login_page.dart`: Verify credentials against `FirebaseAuth` and assert `user.role == 'admin'` in Firestore.

---

### Phase 2: Live Resident Reporting & Dynamic Fields
**Goal:** Remove hardcoded values in `ReportIncidentPage` and link reports to authenticated residents.

#### 2.1 Domain & Data Entity Extensions
- [ ] Expand `IncidentEntity` and `IncidentModel`:
  - Fields: `areaSector`, `isAnonymous`, `dispatcherNotes`, `reporterName`, `reporterEmail`.
  - Update Hive TypeAdapter (`typeId: 1`) to preserve backward compatibility.

#### 2.2 Report Incident Page Updates
- [ ] In `report_incident_page.dart`:
  - Replace `'user123'` fallback with actual `AuthBloc.state.user.id`.
  - Populate Complainant dropdown dynamically (`Self: [User Full Name]` vs `Anonymous`).
  - Keep device GPS coordinate retrieval via `LocationService` (capturing real-time device coordinates upon location fetch).
  - Add offline image queuing and retry handling if network connectivity drops during report creation.

---

### Phase 3: Resident Profile & Settings Live Data
**Goal:** Connect the 1,600+ line `settings_page.dart` and sub-pages to live user profile data.

#### 3.1 Main Settings Page
- [ ] Replace hardcoded `"John David Echano"` and `"johnechano@gmail.com"` with active user data from `AuthBloc`.
- [ ] Wire the `Logout` tile to dispatch `LogoutSubmitted` to `AuthBloc`.
- [ ] Wire `Delete Account` to invoke `FirebaseAuth` delete user + soft-delete in Firestore `users/{uid}`.

#### 3.2 Edit Profile Subpage (`EditProfilePage`)
- [ ] Pre-fill fields with user's existing Firestore profile data (Full Name, Phone, Address, Sector, Emergency Contact).
- [ ] Avatar image picker upload to Firebase Storage `avatars/{uid}.jpg`.
- [ ] Wire `SAVE PROFILE CHANGES` button to dispatch update event to Firestore.

#### 3.3 Privacy & Security Subpage (`PrivacySecurityPage`)
- [ ] Implement real password update via `FirebaseAuth.instance.currentUser?.updatePassword()`.
- [ ] Connect biometric lock toggle to `SharedPreferences`.

---

### Phase 4: Admin Incident Management & Dispatch Actions
**Goal:** Enable administrative dispatchers to update statuses, write dispatcher notes, and mark spam.

#### 4.1 Repository & Use Case Enhancements
- [ ] In `IncidentRepository` and `IncidentRepositoryImpl`:
  - Add `updateIncidentStatus(String id, String status, {String? dispatcherNotes})`
  - Add `upvoteIncident(String id, String userId)`
  - Add `archiveIncident(String id)`

#### 4.2 IncidentBloc Extensions
- [ ] In `IncidentEvent` and `IncidentBloc`:
  - Add `UpdateIncidentStatusRequested`
  - Add `UpvoteIncidentRequested`
  - Add `ArchiveIncidentRequested`
  - Handle real-time status change execution in Firestore.

#### 4.3 Admin Reports UI Wiring
- [ ] In `incident_reports_page.dart`:
  - Replace dummy `// TODO: Trigger BLoC event` with `context.read<IncidentBloc>().add(UpdateIncidentStatusRequested(...))`.
  - Connect `Mark as Spam` button to update status to `Spam` in Firestore.
  - Connect `Me Too / Affected` button on map and details to `UpvoteIncidentRequested`.

---

### Phase 5: Admin Dashboard Analytics & Modules (Live Data)
**Goal:** Replace static lists and hardcoded charts in the Admin Portal with dynamic Firestore streams.

#### 5.1 Real Analytics in Dashboard Overview
- [ ] In `admin_dashboard_page.dart`:
  - Compute KPI counters dynamically from `IncidentBloc` stream (`Total Incidents`, `Solved Cases`, `Active Areas`).
  - Calculate weekly report counts for `CustomLineChart` from incident timestamps.
  - Calculate category percentages dynamically for `CustomPieChart`.
  - Stream real urgent incidents in the Recent Incidents table.

#### 5.2 Admin User Management Page
- [ ] In `user_management_page.dart`:
  - Replace `_dummyUsers` with a real-time stream from Firestore `users` collection.
  - Wire Role change modal to update `users/{uid}.role` in Firestore.
  - Wire Suspend/Disable toggle to update `users/{uid}.isActive`.

#### 5.3 Area Management & Incident Categories
- [ ] In `area_management_page.dart`:
  - Stream areas from Firestore `areas` collection.
  - Implement Add/Edit/Archive Area modals writing to Firestore.
- [ ] In `incident_categories_page.dart`:
  - Stream categories from Firestore `categories` collection.
  - Implement Add/Edit/Archive Category modals writing to Firestore.

#### 5.4 Audit Logs
- [ ] In `admin_audit_logs_page.dart`:
  - Stream audit events from Firestore `audit_logs` collection.
  - Automatically log an audit record whenever an admin updates an incident status, changes a user role, or archives an area.

---

### Phase 6: AI Chatbot & Real Emergency Enhancements
**Goal:** Polish the emergency assistant and broadcast sirens.
- [ ] In `floating_chat_bot.dart`:
  - Integrate with `IncidentAiRemoteDataSource` for dynamic natural language triage while preserving fast offline safety kit fallback.
- [ ] Prepare municipal push broadcast architecture.

---

### Phase 7: Firestore Security Rules & End-to-End Validation
**Goal:** Harden database permissions and verify end-to-end flows.
- [ ] Create `firestore.rules`:
  - Citizens can read verified incidents and create reports.
  - Citizens can only read and write their own `users/{uid}` document.
  - Only users with `role == 'admin'` can change incident statuses and modify `areas`, `categories`, and `audit_logs`.
- [ ] Verification on physical devices (Android/iOS) using `test_sandbox_page.dart`.

---

## 3. Team Collaboration Guidelines

1. **Clean Architecture Adherence:** Never import presentation widgets into domain or data layers. Always route state changes through BLoC events.
2. **Offline-First Resilience:** Always preserve local Hive caching fallback so incidents are never lost if the device loses connection.
3. **Phased Execution:** Complete and verify each phase before moving on to the next one to avoid regression.
