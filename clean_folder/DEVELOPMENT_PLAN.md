# ResQ Clean Architecture: Production-Ready Development & Multi-Platform Deployment Roadmap

This document outlines the systematic, phased engineering roadmap to transition the **ResQ** community safety platform from its current prototype state into a production-ready, multi-platform ecosystem with a live Firebase backend.

It is structured specifically for **pair programming, groupmates, and AI agent task execution**, ensuring each phase builds cleanly on top of the previous one without breaking existing UI components or violating Clean Architecture principles.

---

## 1. Dual-Target Deployment Model (Resident APK vs. Admin Web Portal)

The platform targets two distinct user personas with separate deployment artifacts built from a single unified codebase:

```
                               ┌──────────────────────────────────────────────┐
                               │             Shared Core Codebase             │
                               │  - Clean Architecture (Domain, Data, Core)   │
                               │  - Firebase Auth, Firestore, Storage, Gemini │
                               └──────────────┬────────────────┬──────────────┘
                                              │                │
                      ┌───────────────────────┘                └────────────────────────┐
                      ▼                                                                 ▼
      ┌────────────────────────────────┐                               ┌─────────────────────────────────┐
      │     lib/main_resident.dart     │                               │       lib/main_admin.dart       │
      │   (Target: Mobile Android APK) │                               │   (Target: Desktop Web Portal)  │
      ├────────────────────────────────┤                               ├─────────────────────────────────┤
      │ • Citizen Welcome & Sign-up    │                               │ • Dedicated Browser Landing     │
      │ • Incident Reporting & GPS     │                               │ • Barangay Moonwalk Opcen Desk  │
       │ • Incident Reporting & GPS     │                               │ • Dispatch Incident Management  │
       │ • Interactive Safety Map       │                               │ • Tactical GIS Dispatch Map     │
       │ • Emergency Hotlines & Dialing │                               │ • Analytics, Reports & Directory │
      │ • Personal "My Reports" & AI   │                               │ • Municipal Emergency Broadcast │
      │ • NO Admin Links or Gateways   │                               │ • Hosted on Firebase Hosting    │
      └────────────────────────────────┘                               └─────────────────────────────────┘
```

* **Resident Experience:** Citizens download and install `resq.apk` on their mobile devices. The app opens strictly into the Citizen Welcome / Login / Dashboard flow with no admin buttons.
* **Admin Experience:** Desk officers, Tanods, and the Barangay Captain access a web URL in their desktop browser (e.g. `https://resq-moonwalk.web.app`) deployed via **Firebase Hosting**.

---

## 2. System Baseline & Comprehensive Gap Matrix

| Feature / Module | Current Codebase State | Target Production State |
| :--- | :--- | :--- |
| **App Entry Points** | Single `main.dart` with combined routing | Decoupled `main_resident.dart` (APK) and `main_admin.dart` (Web) |
| **Resident Welcome Page** | Has "Access Admin Portal" bottom button | Strictly citizen-focused; admin link removed completely |
| **Admin Web Landing** | Shared welcome screen | Dedicated browser landing & login at `https://resq-moonwalk.web.app` |
| **Resident Authentication** | FirebaseAuth connected to `AuthBloc` (Phase 1) | Session preservation, profile data binding in Firestore `users/{uid}` |
| **Admin Access Security** | Substring check (`email.contains('admin')`) | Cryptographic role verification (`user.role == 'admin'`) |
| **Incident Reporting** | Hardware GPS & Camera active; hardcoded `user123` | Dual reporting mode (Myself with phone GPS vs. On Behalf of Someone with draggable pin map) & "Other" specification (Phase 8.7) |
| **My Reports Directory** | Shows ALL incidents; tiles non-clickable | Filtered by `currentUser.id`; tapping card opens `IncidentDetailPage` |
| **Incident Detail Tracking** | Light-theme styling; missing dispatcher notes | OLED Dark Theme; displays official dispatcher remarks, live timeline, and Dispatch ETA (Phase 8.7) |
| **Emergency Hotlines** | Standard dialer requiring secondary call tap | 1-Tap Direct Telephony Calling (`CALL_PHONE` via `flutter_phone_direct_caller`; Phase 8.7) |
| **Settings & Edit Profile** | Hardcoded strings (`John David Echano`) | Real-time fetch and update from Firestore `users/{uid}` |
| **Security & Biometrics** | Disconnected toggle; no package | Functional local biometric gateway (`local_auth`) with anti-prank report verification & post-login enrollment (Phase 8.7) |
| **Admin Incident Table** | Status dropdown shows dummy snackbar | Live BLoC event (`UpdateIncidentStatusRequested`), ETA input, and Sticky Frozen Actions Column (Phase 8.7) |
| **Incident Urgency & Triage** | Dependent on speculative AI text description analysis | Deterministic Category Baseline Matrix (`IncidentTriageHelper`) + Dynamic Crowdsourced Upvote Escalation (0 latency, 0 hallucination; Phase 8.6) |
| **Admin Reports Desk Sorting** | Chronological list without multi-criteria queue | Multi-criteria priority queue (`Latest`, `Urgency`, `Corroborated / Affected`, `Oldest Pending`) with interactive sortable headers (Phase 8.6) |
| **Admin Overview Stats** | Hardcoded numbers (`248`, `14`, `185`) | Dynamic calculations from Firestore collections |
| **Admin Sub-Modules** | In-memory dummy lists; no BLoCs/Entities | Dedicated Reports & Analytics Hub (with CSV/PDF exports), Live Citizen Directory (Emergency Dossier & Moderation), and Clean Architecture Audit Logs |
| **Emergency Broadcast** | Missing from header | Button & modal in `AdminHeader` dispatching push siren (Completed Phase 7) |
| **Admin Logout** | Navigates without signing out | Dispatches `LogoutRequested` and invalidates Firebase token (Completed Phase 7) |
| **In-App Notifications** | Static 'R' avatar in top bar; no alert center | Reactive Bell Icon with unread badge in top bar; slide-over notification drawer with 1-tap incident navigation (Completed Phase 7) |
| **System Push Notifications (FCM)** | Non-existent | 100% Free Firebase Cloud Messaging background notifications when app is closed / phone locked (Completed Phase 7) |
| **Report Export** | Non-existent | 1-Click Blotter CSV Export and Official Barangay Moonwalk PDF Report with Official Seal and Signatures (Phase 8.2) |
| **AI Emergency Chatbot** | Static keyword matching | Gemini 1.5 Flash conversational civil defense & 1-tap emergency dialer (Phase 9) |

---

## 3. Production Roadmap (10 Execution Phases)

### Phase 1: Dual-Platform Architecture & Authentication Foundation
**Goal:** Decouple the Resident APK from the Admin Web Portal and secure role-based access.

#### 1.1 Multi-Entry Architecture
- [ ] Create `lib/main_resident.dart`:
  - Registers resident routes (`/welcome`, `/login`, `/sign-up`, `/dashboard`, `/report-incident`, `/maps`, `/my-reports`, `/emergency-hotlines`, `/settings`).
  - Sets `WelcomePage` as root for unauthenticated users.
- [ ] Create `lib/main_admin.dart`:
  - Registers admin routes (`/admin/login`, `/admin/dashboard`).
  - Sets dedicated `AdminLoginPage` as root.
- [ ] Update `welcome_page.dart`:
  - Remove the *"Access Admin Portal"* footer button.
- [ ] Add missing packages to `pubspec.yaml`:
  - `shared_preferences: ^2.3.2`
  - `local_auth: ^2.3.0`
  - `csv: ^6.0.0`
  - `pdf: ^3.11.1`
  - `printing: ^5.13.2`

#### 1.2 User Profile & Role-Based Access Control
- [ ] Expand `UserEntity` & `UserModel`:
  - Fields: `id`, `email`, `displayName`, `role` (`resident`, `tanod`, `officer`, `admin`), `phoneNumber`, `address`, `barangayArea`, `emergencyContactName`, `emergencyContactNumber`, `photoUrl`, `isVerified`, `isActive`, `createdAt`.
- [ ] Secure `admin_login_page.dart` and `AuthWrapper`:
  - Enforce `user.role == 'admin'` assertion against Firestore `users/{uid}`. Reject unauthorized accounts with explicit error dialog.

---

### Phase 2: Live Resident Reporting & Dynamic Fields
**Goal:** Eliminate hardcoded reporter IDs and connect dynamic dropdowns to real data.

#### 2.1 Domain & Entity Enhancements
- [ ] Expand `IncidentEntity` and `IncidentModel`:
  - Fields: `areaSector`, `isAnonymous`, `dispatcherNotes`, `reporterName`, `reporterEmail`.
  - Update Hive `IncidentModelAdapter` (`typeId: 1`) to preserve backward compatibility.

#### 2.2 Report Incident Page Updates
- [ ] In `report_incident_page.dart`:
  - Replace `'user123'` fallback with actual `AuthBloc.state.user.id`.
  - Populate Complainant dropdown dynamically (`Self: [User Full Name]` vs `Submit Anonymously`).
  - Populate Barangay Sector dropdown from Firestore `areas` collection.
  - Preserve device GPS coordinates capture via `LocationService` (accuracy to 6 decimal places).
  - Add offline image queuing and retry handling if network drops during upload.

---

### Phase 3: Resident "My Reports" & Incident Tracking Detail
**Goal:** Make the personal report history fully functional and link report cards to reactive detail tracking.

#### 3.1 Personal Report Filtering & Sync Status Architecture
- [x] In `IncidentEntity` & `IncidentModel`:
  - Added `isSynced` boolean populated reactively from `!doc.metadata.hasPendingWrites`.
- [x] In `IncidentRepository` and `IncidentRepositoryImpl`:
  - Added `streamUserIncidents(String userId)` returning all reports where `reporterId == userId`.
  - Added `includeMetadataChanges: true` and included resolved/closed reports so historical data displays properly.
- [x] In `my_reports_page.dart`:
  - Wired list to `streamUserIncidents(currentUserId)`.
  - Displayed live Sync Badges (`Live at Dispatch` vs `Stored Locally`).
  - Connected filter chips (`ALL`, `Pending`, `In Progress`, `Resolved`).

#### 3.2 Report Card Interaction & Detail Page Modernization
- [x] In `_AnimatedReportCard`:
  - Wrapped tile in `GestureDetector` navigating to `IncidentDetailPage(initialIncident: incident)`.
  - Added sector tags, exact location addresses, and sync badge.
- [x] In `incident_detail_page.dart` & `incident_status_timeline.dart`:
  - Restyled page to ResQ OLED Dark Theme (`AppColors.background`, `AppColors.surface`, cyan gradients).
  - Added official **Dispatcher Remarks & Action Notes** container displaying `incident.dispatcherNotes`.
  - Added **Sync Status Banner** and **Pinch-to-Zoom Evidence Photo Dialog**.
  - Added reactive 3-step resolution timeline (Pending ➔ In Progress ➔ Solved).

---

### Phase 4: Resident Settings Streamlining, Profile Wiring, & Emergency Dialers
**Goal:** Eliminate bloat from `settings_page.dart` (hotlines grid, fake dark mode switch, notification toggle, language dropdown) and connect the remaining core features to live backend services.

#### 4.1 UI Cleanup & Simplification
- [x] In `settings_page.dart`:
  - **Remove duplicate Emergency Hotlines Grid (200+ lines of clutter):** Emergency contacts are already dedicated to `/emergency-hotlines` and reporting quick-actions.
  - **Remove "Night Mode Dynamic Range" Switch:** The app is permanently OLED dark; an in-app switch is redundant.
  - **Remove "Incident Report History" Tile:** Residents already access "My Reports" directly from the navigation drawer.
  - **Remove In-App "Push Notifications" Switch:** Avoid app-breaking complexity; notification permissions are managed at the Android/iOS OS level by the user.
  - **Remove Spanish from Language Selector:** Kept only English (PH) and Filipino (Tagalog).
  - **Clean Up Techno-Babble Text:** Replaced sci-fi jargon (*"structural verification input matrices"*, *"ENGAGE SECURITY OVERRIDE"*) with clean, natural community terms (*"Confirm Password"*, *"Update Password"*).

#### 4.2 Live Profile & Feedback Data Wiring
- [x] In `settings_page.dart`:
  - Dynamically render user full name, email, avatar, and verified badge from `AuthBloc.state.user`.
  - Wire `Submit App Feedback / Bug` modal with clean civic form dialog.
- [x] In `EditProfilePage`:
  - Pre-fill fields with user's existing profile data (`displayName`, `phoneNumber`, `emergencyContactNumber`, `address`, `barangayArea`).
  - Wire avatar photo tap to `CameraService.pickImageFromGallery()` / `pickImageFromCamera()`.
  - Wire `SAVE PROFILE CHANGES` to dispatch `UpdateProfileRequested(updatedUser)` to `AuthBloc` with local Hive demo caching fallback.

#### 4.3 Real Native Emergency Dialers & Security
- [x] In `emergency_hotlines_page.dart` and `report_incident_page.dart`:
  - Replaced simulated call snackbar with native `url_launcher` phone dialer:
    ```dart
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
    ```
  - Ensured emergency hotlines (911, Fire 112, Red Cross 143, Barangay Desk) trigger system dialer directly.

#### 4.4 Account Security, Biometrics, & Session Management
- [x] In `PrivacySecurityPage`:
  - Wired password change form directly to `AuthRepository.changePassword` with input validation.
  - Wired Biometric App Lock to `local_auth` (`LocalAuthentication.authenticate()`) with hardware sensor check and persisted state in `SharedPreferences`.
- [x] In `settings_page.dart`:
  - Wired `Log Out` button to dispatch `LogoutRequested` to `AuthBloc` and navigate cleanly to `WelcomePage`.
  - Wired `Delete Account` to invoke account deletion with confirmation dialog.

---

### Phase 5: Interactive Community Incident Map & "Me Too" Incident Framework
**Goal:** Build a live, interactive map displaying active community incidents across Barangay Moonwalk, enabling citizens to stay informed, view incident callouts, and upvote existing incidents via the "Me Too" framework to prevent duplicate emergency reports.

#### 5.1 Interactive Incident Map & Live Pin Markers
- [x] In `maps_page.dart`:
  - Connected to `IncidentBloc` / `streamActiveIncidents()` to render real-time pins for all active community incidents across Barangay Moonwalk.
  - Applied custom OLED dark JSON map styling.
  - Color-coded map pin markers by incident category (Fire = Red, Theft = Orange, Medical = Azure, Flood = Cyan, Accident = Yellow, Violence = Violet).
  - Added horizontal category filter chips (`All`, `Fire`, `Medical`, `Flood`, `Theft`, `Accident`, `Violence`).
  - Centered map on Barangay Moonwalk with zoom and GPS "My Location" controls.
- [x] Incident Callout & Bottom Sheet Preview:
  - Tapping a map pin displays an interactive **Incident Bottom Sheet**:
    - Incident category & priority badge.
    - Relative timestamp & sector badge.
    - Resident description snippet.
    - **Affected Community Counter:** Displays *"X residents corroborated this emergency"*.
    - Quick-action button: *"View Details"* (opens `IncidentDetailPage`).

#### 5.2 "Me Too" Upvote & Urgency Escalation Framework
- [x] In `IncidentRepository` and `IncidentRepositoryImpl`:
  - Added `Future<void> upvoteIncident(String incidentId, String userId)`:
    - Atomically increments `upvoteCount` by 1.
    - Adds `userId` to `validatedUserIds` array in Firestore (and local Hive storage).
    - If `validatedUserIds` already contains `userId`, prevents duplicate upvoting.
    - Automatically elevates incident urgency level based on affected threshold (e.g. 3+ upvotes ➔ `HIGH`, 5+ upvotes ➔ `CRITICAL`).
- [x] In `IncidentBloc`:
  - Added `UpvoteIncidentRequested(String incidentId, String userId)` event and handler.
- [x] In `maps_page.dart`:
  - Added prominent **"Me Too / Affected"** button.
  - If user already upvoted, button displays **"✓ Corroborated"**.

#### 5.3 Smart Duplicate Interceptor at Report Submission
- [x] In `report_incident_page.dart`:
  - When the user taps **"Submit Incident"**:
    - Calculates proximity (`Geolocator.distanceBetween`) between coordinates and active incidents of the **same category** reported within the last 2 hours.
    - If an active match is found within **250 meters**:
      - Intercepts submission and displays the **Smart Duplicate Interceptor Dialog**:
        - ⚠️ *"Similar Incident Reported Nearby!"*
        - Shows snippet of the existing report (distance in meters, report time, description).
        - Displays current affected count (*"X citizens already corroborated"*).
        - **Action 1: "Me Too / Corroborate Incident"** ➔ Dispatches `UpvoteIncidentRequested`, elevates ticket urgency, and opens `IncidentDetailPage` without creating a redundant ticket.
        - **Action 2: "Submit as Separate Incident"** ➔ Confirms and proceeds with submitting a new ticket.

---

### Phase 6: Live Firebase Backend Activation & Dual-App Real-Time Cloud Sync
**Goal:** Connect production Firebase credentials (Firestore, Authentication, and Firebase Storage) so citizen reports, camera evidence, and live status updates sync seamlessly across resident mobile devices and the admin web portal.

#### 6.1 Firebase Project Configuration & Credentials
- [x] Configure `google-services.json` in `android/app/` and update `lib/firebase_options.dart` with valid project credentials (`resq-community-safety`).
- [x] Enable Firebase Authentication (Email/Password & Google), Cloud Firestore in Firebase Console.
- [x] Configure Maps SDK for Android API key & RECORD_AUDIO permission in `AndroidManifest.xml`.
- [x] Integrate Cloudinary 100% free media pipeline (`g45cmboy` / `crkjnmhd`) for zero-card evidence photo & video storage.
- [ ] Verify that citizen reports submitted from physical Android phone genuinely appear in the live Firestore console.

#### 6.2 Google Sign-In Authentication Integration
- [x] In Firebase Console:
  - Enabled Google Sign-In provider under Firebase Authentication.
  - Keystore SHA-1 / SHA-256 fingerprints retrieved and documented.
- [x] In `AuthRepository` & `AuthRepositoryImpl`:
  - Implemented `signInWithGoogle()` using `google_sign_in` and `FirebaseAuth.signInWithCredential()`.
  - Automatically creates or links citizen profile document in Firestore `users/{uid}` on first Google sign-in.
- [x] In `AuthBloc`:
  - Added `GoogleSignInRequested` event, `SignInWithGoogleUseCase`, and state transitions (`AuthLoading` ➔ `Authenticated`).
- [x] In `login_page.dart` & `sign_up_page.dart`:
  - Connected "Continue with Google" action buttons to dispatch `GoogleSignInRequested`.

#### 6.3 Video Evidence Submission with Strict Size & Duration Caps (Low-Latency Emergency Pipeline)
- [x] In `CameraService` & `CameraServiceImpl`:
  - Added video recording (`pickVideoFromCamera(maxDuration: 30s)`) and gallery picker (`pickVideoFromGallery()`).
  - Added `uploadVideo()` uploading to Cloudinary `resq_videos` folder with secure HTTPS URL generation.
  - Added `getFileSizeInMB()` file size checker.
- [x] In `report_incident_page.dart`:
  - **Enforced Strict Emergency Limits:** hard size cap at ≤ 20 MB, recording duration capped at 30 seconds.
  - Client-side pre-check dialog blocks high-latency videos over 20 MB from clogging emergency dispatch.
  - Displays dynamic video attachment preview with live size badge (`X.X MB • Emergency low-latency verified`).
- [x] In `IncidentEntity`, `IncidentModel`, and `IncidentRepositoryImpl`:
  - Added `videoUrl` field serialized to Firestore and local Hive cache (`IncidentModelAdapter`).
- [x] In `incident_detail_page.dart`:
  - Added verified emergency video stream card with direct playback via `url_launcher`.

#### 6.4 Real-Time Cloud Sync & State Transition Testing
- [ ] Test the live sync indicator: verify that newly submitted reports switch automatically from **"Stored Locally"** to **"Live at Dispatch"** once confirmed by Firestore.
- [ ] Verify that status updates made in Firestore (Pending ➔ In Progress ➔ Solved) immediately reflect on the resident's `IncidentDetailPage` timeline without app restart.

---

### Phase 7: Admin Incident Management & Emergency Broadcast
**Goal:** Enable dispatchers to update incident statuses, log notes, broadcast sirens, and securely sign out.

#### 7.1 Repository & IncidentBloc Extensions
- [x] In `IncidentRepository` and `IncidentRepositoryImpl`:
  - Added `updateIncidentStatus(String id, String status, {String? dispatcherNotes})`.
  - Added `archiveIncident(String id)`.
  - Added `streamAllIncidents()` streaming live Firestore snapshot collection.
- [x] In `IncidentBloc`:
  - Added `UpdateIncidentStatusRequested`, `ArchiveIncidentRequested`, and `StreamAllIncidentsRequested`.

#### 7.2 Admin Incident Reports UI Wiring
- [x] In `incident_reports_page.dart`:
  - Wired `Save Status` dialog button to dispatch `UpdateIncidentStatusRequested(id, newStatus, dispatcherNotes: notes)`.
  - Added Dispatcher Notes text area allowing dispatchers to record operational notes.
  - Wired `Mark as Spam` button to update status to `'spam'`.
  - Wired search input and active vs archived filter toggle.
  - Displayed dispatcher notes on incident detail modal.

#### 7.3 Emergency Broadcast & Secure Sign Out
- [x] In `admin_header.dart`:
  - Added glowing crimson **Emergency Broadcast Siren** button with live active siren counter (`🚨 X ACTIVE SIREN • MANAGE`).
  - Clicking button opens **Municipal Emergency Siren Modal** with dual tabs:
    - **Active Sirens (X):** Live listing of sounding sirens with **`SILENCE & CLEAR SIREN`** (`isActive: false`) and permanent Delete record action.
    - **Transmit New:** Form to broadcast new sirens to citizens.
  - Submitting writes live broadcast document to Firestore `broadcasts` collection.
- [x] In `admin_panel_shell.dart`:
  - Wired logout confirmation to dispatch `LogoutRequested` to `AuthBloc` to clear Firebase session credentials before routing to `/admin/login`.
- [x] In `emergency_broadcast_listener.dart` & `dashboard_page.dart`:
  - Real-time resident listener triggers heavy haptics & alert modal upon broadcast.
  - Automatically dismisses active dialog and removes top dashboard banner in real time when siren is silenced by admin.

#### 7.4 In-App Notification Center & Real-Time Event Bus
- [x] Resident Notification Hub:
  - Replace static `'R'` initial avatar in `_PremiumAppBar` (`dashboard_page.dart`) with a reactive Notification Bell icon (`StreamBuilder`).
  - Badge counter display showing unread notifications (`1`, `2`, `9+`).
  - Build `ResidentNotificationsSheet` (OLED Dark slide-over / bottom sheet):
    - "Mark all as read" batch action.
    - Notification card items with color-coded type badges (`status_change`, `upvote`, `siren`, `announcement`).
    - One-tap direct navigation: Tapping an alert with `incidentId` marks it as read and opens `IncidentDetailPage` directly.
- [x] Admin Notification Hub:
  - Add a Notification Bell icon in `admin_header.dart`.
  - Stream alerts for new incoming citizen reports, AI urgency classifications, and community corroboration spikes (3+ or 5+ upvotes).
- [x] Automatic Event Triggers:
  - In `IncidentRepositoryImpl.updateIncidentStatus()`: Automatically write a notification document to the reporter's UID with the updated status and dispatcher notes.
  - In `IncidentRepositoryImpl.upvoteIncident()`: Automatically write a notification document to the original author when a neighbor corroborates their report.
  - In `admin_header.dart`: Automatically write a notification document for all residents when an emergency broadcast is transmitted.

#### 7.5 Background Push Notifications (Firebase Cloud Messaging - FCM)
- [x] Integrate `firebase_messaging` and `flutter_local_notifications` in `pubspec.yaml`.
- [x] Configure Android notification channels in `AndroidManifest.xml` with high importance, custom siren sound, and vibration pattern.
- [x] Register device FCM tokens on citizen login and persist to Firestore `users/{uid}/fcmTokens`.
- [x] Implement background message handler (`@pragma('vm:entry-point') firebaseMessagingBackgroundHandler`) to deliver system heads-up notifications when the app is completely closed, killed in background, or the device is locked.
- [x] **Cost / Policy:** 100% Free with unlimited push messages via Firebase Cloud Messaging.

---

### Phase 8: Admin Command Center Analytics, Municipal Reports & Citizen Directory
**Goal:** Transform the Admin Command Center into a fully dynamic operational hub powered by real Firestore streams. Eliminate redundant mock CRUD screens, launch the dedicated **Reports & Analytics Hub** with 1-click CSV blotter and official PDF municipal reports, stream live registered citizens with emergency contacts, and establish administrative audit logs.

#### Architectural Rationale & Simplification Decisions
1. **Deprecation of Area Management CRUD:**
   - In Philippine Local Government Units (specifically Barangay Moonwalk, Parañaque City), territorial jurisdictions and subdivisions (*e.g., Moonwalk Proper, San Agustin, San Jose, Multinational Village*) are legally established administrative boundaries that do not change dynamically.
   - Resident mobile incident reports automatically reverse-geocode GPS coordinates into standardized `areaSector` and `resolvedAddress` fields.
   - Allowing arbitrary creation/deletion of "Areas" by desk admins creates taxonomy divergence and breaks spatial filtering between the mobile app and admin desk. Thus, manual Area CRUD is removed.
2. **Deprecation of Incident Categories CRUD:**
   - Incident categorization must remain strictly synchronized across the resident reporting dropdown, Gemini AI classification, push notifications, map markers, and municipal analytics.
   - ResQ uses a standardized, exhaustive 10-category emergency taxonomy (`AppConstants.incidentCategories`: *Fire Incident, Theft / Robbery, Medical Emergency, Violence / Physical Fight, Road Accident, Suspicious Activity, Flood / Calamity, Lost Item / Missing Person, Noise Complaint, Other Emergency*).
   - Dynamic category creation by an admin causes taxonomy bloat and invalidates historical reporting models. Manual Category CRUD is removed.
3. **Replacement with Reports & Analytics Hub:**
   - In place of redundant Area and Category CRUD items, the admin sidebar navigation introduces the **Reports & Analytics Hub** (`reports_analytics_page.dart`), integrating deep operational metrics with the municipal export tools previously scheduled for Phase 9.2.
4. **Strict Security Rule for User Management:**
   - **No Client-Side Role Dropdown:** Client-side role editing is prohibited to prevent privilege escalation vulnerabilities. Role assignments (`role: 'admin'`) must only be provisioned via the secure Firebase Console / Firestore backend.
   - User Management is refactored into the **Live Citizen Directory**, focusing on identity verification, emergency contact dossier retrieval during crises, and moderation (suspending accounts that submit fake or spam emergency reports).

---

#### 8.1 Real Analytics in Dashboard Overview
- [x] In `admin_dashboard_page.dart`:
  - Calculate KPI counters dynamically from Firestore collections:
    - `Total Incidents`: Total live documents in `incidents` collection.
    - `Active Sirens`: Live count of active broadcasts (`broadcasts` where `isActive == true`).
    - `Solved Cases`: Total incidents with `status == 'solved'`.
    - `Registered Citizens`: Total registered users from Firestore `users` collection.
  - Calculate weekly frequency curve in `CustomLineChart` dynamically from real incident `createdAt` timestamps.
  - Upgrade `CustomPieChart` to an interactive Dual-View Distribution Card (`[By Category] | [By Sector]` toggle pill):
    - **By Category View:** Calculates real-time percentage breakdown across the 10 standardized emergency categories.
    - **By Sector View:** Groups and calculates real-time incident distribution across auto-detected reverse-geocoded map sectors (*San Jose, Moonwalk Proper, San Agustin, etc.*).
    - Restyle donut chart to ResQ OLED Dark Command Center aesthetic with glassmorphism, percentage callouts, and glowing indicators.
  - Stream the 5 latest incoming urgent reports in the Recent Incidents table with live status pills, urgency indicators, and direct modal view.

---

#### 8.2 Dedicated Reports & Analytics Hub (with Municipal Exports)
- [x] In `admin_sidebar.dart` & `admin_panel_shell.dart`:
  - Replace redundant "Area Management" and "Incident Categories" navigation items with **"Reports & Analytics"** (icon: `Icons.analytics_outlined`).
- [x] Create `lib/features/admin_dashboard/presentation/pages/reports_analytics_page.dart`:
  - **Interactive Timeframe Selector:** Filter all metrics by `[All Time] | [This Month] | [Last 30 Days] | [This Week] | [Custom Date Range]`.
  - **Operational KPI Cards:**
    - Total Incidents within period.
    - Resolution Rate (% of reports marked `solved`).
    - Average Incident Response Time.
    - Top Emergency Hotspot Sector (highest incident volume).
    - High / Critical Priority Case Count.
  - **Visual Analytical Charts:**
    - **Incident Frequency Curve:** High-resolution multi-point line chart showing daily/weekly incident trends over the selected timeframe.
    - **Sector Incident Ranking:** Horizontal bar chart comparing incident loads across all Barangay Moonwalk sectors to assist Tanod patrol deployment.
    - **Category Breakdown Donut Chart:** Visual breakdown of emergency types during the selected period.
  - **1-Click Raw Blotter Export (CSV / Excel):**
    - Uses `csv` package to compile and trigger immediate browser download of the complete incident blotter ledger.
    - Includes: Incident ID, Timestamp, Category, Priority Level, Status, Barangay Sector, GPS Latitude/Longitude, Resolved Address, Reporter Name, Contact Details, and Official Dispatcher Remarks.
    - Ready for official submission to Local Government Unit (LGU) and Department of the Interior and Local Government (DILG) auditors.
  - **Official Barangay Moonwalk Printable PDF Report Generator:**
    - Uses `pdf` and `printing` packages to compile a formatted, high-resolution printable municipal document.
    - **Document Header:** Official Republic of the Philippines letterhead, City of Parañaque, Barangay Moonwalk Official Seal logo, and formal report title (*"BARANGAY MOONWALK DISPATCH COMMAND INCIDENT BLOTTER REPORT"*).
    - **Executive Summary:** Formal summary table detailing report timeframe, total reported incidents, resolved count, active count, and dominant emergency category.
    - **Category & Sector Statistics Table:** Detailed tabular breakdown of incidents by category and sector.
    - **Certified Blotter Ledger:** Structured table listing incidents with dates, locations, categories, and resolution outcomes.
    - **Sign-off Block:** Official attestation signatures for:
      - *Prepared by:* Dispatch Officer On Duty (Name, Badge #, Date)
      - *Noted & Approved by:* Barangay Captain / Punong Barangay (Signature line)
    - Triggers instant in-browser print preview and PDF download.

---

#### 8.3 Live User Management & Citizen Directory
- [x] In `user_management_page.dart`:
  - Stream real registered citizens directly from Firestore `users` collection.
  - **Search & Filtering:**
    - Search field by Citizen Name, Email, Phone Number, or Registered Address.
    - Filter chips by Account Status (`All`, `Active`, `Suspended`).
  - **Citizen Directory Table:**
    - Columns: Citizen Name, Email, Phone Number, Sector/Address, Joined Date, Status Badge, and Actions.
  - **Read-Only Role Badge:**
    - Display role clearly as `Citizen Resident` (cyan badge) or `Barangay Admin` (purple badge).
    - *Security Rule:* No client-side role modification dropdown to prevent privilege escalation.
  - **Citizen Dossier Modal (`View Details`):**
    - Displays full citizen profile (Name, Email, Phone, Home Address, Barangay Sector, Account Created Date).
    - Displays **Emergency Contact Person & Phone Number** *(critical operational data for dispatchers during life-safety emergencies)*.
    - Displays citizen incident history summary (Total submitted incident reports count, upvoted incidents count).
  - **Moderation Actions:**
    - **`Suspend / Reactivate Account`** toggle (`isActive: false/true` in Firestore `users/{uid}`):
      - Confirmation dialog with mandatory reason entry.
      - Suspended accounts are immediately blocked from logging in or submitting emergency reports (curbing spam/prank calls).
    - **`Verify Citizen`** toggle (`isVerified: true/false`):
      - Marks citizen as verified with barangay proof of residency.

---

#### 8.4 Full Clean Architecture for Administrative Audit Logs
- [x] Create `AuditLogEntity`, `AuditLogModel`, `AuditLogRemoteDataSource`, and register in `injection_container.dart`.
- [x] In `admin_audit_logs_page.dart`:
  - Stream immutable activity records from Firestore `audit_logs` collection.
  - Automatically log an audit record whenever:
    - An admin updates an incident status or saves dispatcher notes.
    - An admin transmits or silences an emergency siren broadcast.
    - An admin suspends or reactivates a citizen account.
    - An admin exports a municipal blotter report.
  - Filter audit logs by Action Type (`All`, `Status Update`, `Siren Broadcast`, `User Moderation`).
  - Provide 1-Click CSV export for administrative accountability.

---

#### 8.5 Admin Tactical GIS Dispatch Map
**Goal:** Deliver a dedicated, military/civic-grade Live GIS Dispatch Map for the Command Center. Give desk dispatchers instant spatial awareness of clustering emergencies across Barangay Moonwalk without client-side upvoting, equipped with dynamic active hotspot chips, tactical pin triage, and direct dispatcher action drawers.

- [x] Add **"Dispatch Map"** (icon: `Icons.map_outlined`) to `admin_sidebar.dart` and register in `admin_panel_shell.dart`.
- [x] Create `lib/features/admin_dashboard/presentation/pages/admin_dispatch_map_page.dart`:
  - **Full-Screen OLED Dark Command Map:** Styled with ResQ dark palette (`#0D1627`), optimized for desktop command monitors.
  - **Dynamic Active Hotspot Chips (Option A):**
    - Automatically streams active incidents from Firestore and generates quick-focus chips only for sectors with active reports (e.g. `[ 🌐 All Moonwalk ]`, `[ 🎯 Simplicio Cruz Compound (3) ]`, `[ 🎯 Multinational Village (1) ]`).
    - *Zero Hardcoded Coordinates:* Tapping any chip dynamically calculates the bounding box / center of the real GPS coordinates in that sector and smoothly animates the camera to frame them.
  - **Tactical Marker Pins with Urgency & Status Triage:**
    - Pulsing Crimson Red for `Critical / Urgent` tickets (Fire, Medical, Armed Violence).
    - Amber/Yellow for `Pending` unacknowledged tickets.
    - Cyan/Blue for `In Progress` (Tanods dispatched / on scene).
    - Emerald Green for `Solved / Cleared` cases.
    - Category icons on markers (Flame for Fire, Cross for Medical, etc.).
  - **Dispatcher Action Drawer (On Pin Tap):**
    - *Replaces citizen upvote button with command controls.*
    - Displays full case brief: Category, urgency, exact street address, landmark note, reporter identity, and **Emergency Contact Person & Phone Number**.
    - Evidence preview for photos and videos.
    - **1-Tap Dispatch Controls:**
      - `[Dispatch / In Progress]`: Sets status to `in_progress`, stamps `respondedAt` (driving real-time response speed analytics), and triggers push notification to the resident.
      - `[Mark Solved]`: Closes the incident once cleared on the ground.
      - Dispatcher Notes field to record real-time operational remarks.
      - 1-Tap Google Maps External Directions link for patrol vehicle navigation.
  - **Tactical Filtering Toolbar:**
    - Status Filter Pills: `[All] | [Pending] | [In Progress] | [Solved]`.
    - Urgency Toggle: `[🚨 Critical Only]` — Instantly strips out noise to display only severe life-safety threats.
  - **Emergency Siren Broadcast Visualizer:**
    - Streams active broadcasts from `broadcasts` collection and renders a glowing translucent perimeter overlay over the targeted sector.

---

#### 8.6 Deterministic Incident Triage Matrix & Admin Reports Hierarchy
**Goal:** Implement the client-endorsed deterministic urgency matrix based on incident type, dynamic crowdsourced upvote escalation, and multi-criteria sorting hierarchy in the Admin Incident Reports Desk.

##### Client Consultation Alignment & Triage Rationale:
- **Consultation Feedback:** During client review, barangay stakeholders emphasized that in real-world emergencies, panicked citizens submit very brief, fragmented descriptions (e.g. *"sunog"*, *"tulong po"*, or bare minimum words) or report while running to safety.
- **AI Text Risk:** Relying strictly on AI LLM text narrative analysis to assign urgency introduces dangerous life-safety risks (e.g. an AI downgrading a fatal house fire to "Low" because the description lacked details).
- **Client-Endorsed Solution:** 
  1. Base urgency deterministically on the **Incident Category** (instant, 0 latency, 100% predictable).
  2. Elevate urgency dynamically through **Community Upvotes / Corroboration** (as multiple neighbors confirm an active incident, its urgency escalates automatically).
  3. Empower dispatchers with an **Admin Sorting Hierarchy** to prioritize by urgency weight, corroborated impact, or oldest pending cases.

---

##### Step 1: Deterministic Category-Based Urgency Baseline Matrix & Dynamic Upvote Escalation
- [x] Create centralized helper `lib/core/utils/incident_triage_helper.dart`:
  - Deterministic category baselines:
    - 🔴 **CRITICAL:** *Fire Incident*, *Medical Emergency* (Immediate life threat)
    - 🟠 **HIGH:** *Violence / Physical Fight*, *Flood / Calamity*, *Theft / Robbery*
    - 🔵 **MEDIUM:** *Road Accident*, *Suspicious Activity*, *Other Emergency*
    - ⚪ **LOW:** *Noise Complaint*, *Lost Item / Missing Person*
  - Numerical priority weights for sorting: `CRITICAL (4) > HIGH (3) > MEDIUM (2) > LOW (1) > UNKNOWN (0)`.
- [x] Integrate baseline assignment into `report_incident_page.dart`:
  - When citizen submits an incident, automatically assign `effectiveUrgency = IncidentTriageHelper.getBaselineUrgency(_selectedIncidentCategory)`.
  - Zero latency, guaranteed urgency categorization even with 1-word descriptions.
- [x] Standardize dynamic upvote escalation in `IncidentRepositoryImpl.upvoteIncident()`:
  - 3+ corroboration upvotes: Escalates `MEDIUM` ➔ `HIGH` (or `HIGH` ➔ `CRITICAL`).
  - 5+ corroboration upvotes: Escalates ANY report ➔ `CRITICAL` (signals massive neighborhood-scale hazard).
  - Automatically updates Firestore and Hive with new `urgencyStatus`.
- [x] Fallback baseline safeguarding in `IncidentRepositoryImpl.submitIncidentReport()`:
  - Automatically resolves baseline urgency if report payload lacks explicit urgency.

---

##### Step 2: Admin Reports Desk Sorting Hierarchy & Corroboration Metrics
- [x] In `incident_reports_page.dart`:
  - **Quick-Triage Sort Toolbar:** Add dedicated priority chips above the table:
    - `[ ⏱️ Latest First ]` (Default chronological view)
    - `[ 🚨 Critical & Urgent First ]` (Sorts by urgency weight: `CRITICAL > HIGH > MEDIUM > LOW`)
    - `[ 👥 Most Corroborated / Affected ]` (Sorts by community upvote count)
    - `[ ⏳ Oldest Pending Backlog ]` (Highlights aging unaddressed tickets)
  - **Interactive Table Header Sorting:**
    - Wire `onSort` callbacks on `DataTable` columns: `Urgency`, `Corroborated / Affected`, and `Date`.
    - Support bi-directional ascending / descending toggles with Flutter's native sort arrows.
  - **Corroborated / Affected Column:**
    - Display dedicated table column with community icon (`Icons.people_alt_outlined`) and pill badge `👥 N Corroborated`.
  - **High-Contrast Tactical Urgency Badges:**
    - Restyle `_getUrgencyColor` for command-center visibility:
      - `CRITICAL`: Crimson Red (`#FF3B30`)
      - `HIGH`: Amber Orange (`#FF9500`)
      - `MEDIUM`: Electric Cyan (`#00E5FF`)
      - `LOW`: Slate Gray (`#8E8E93`)

---

##### Step 3: Corroboration Integrity & Proximity De-duplication Refinements
- [x] **Elimination of Self-Upvoting:**
  - In `maps_page.dart`: Enforced `incident.reporterId == currentUserId` verification. Authors see `[ 📍 Your Report ]` and are blocked from inflating their own ticket priority.
- [x] **Smart Proximity Duplicate Interception (Author vs. Neighbor):**
  - In `report_incident_page.dart`: When a 250m duplicate is detected, check if the submitter is the original author:
    - **Original Author:** Informs citizen their report is already live and dispatched. Offers **`[ 📋 View My Active Report & Notes ]`** as primary action, and **`[ Submit New Separate Report Anyway ]`** as secondary option.
    - **Neighbor:** Prompts **`"Me Too / Corroborate Incident"`** to elevate urgency without creating duplicate tickets.
- [x] **Accurate Affected User Counting (`affectedCount = 1 + upvoteCount`):**
  - Replaced misleading "0 Affected" displays with `upvoteCount + 1` (original author counts as 1st affected person).
  - Synchronized across Admin Reports Desk (`👥 N Affected`), Resident Map stats, and `IncidentTriageHelper` escalation math.

---

### Phase 8.7: Capstone Adviser Consultation Enhancements
**Goal:** Implement key architectural and usability refinements suggested during Capstone Adviser consultation to strengthen disaster response realism, reporting accuracy, hotline efficiency, and anti-spam verification.

#### 8.7.1 Reporting on Behalf of Someone Else & Interactive Draggable Pin
- [x] In `report_incident_page.dart`:
  - **Reporting Mode Selector:** Provided clear dual toggle:
    - `[ 🙋 Myself (At Scene) ]`: Captures current phone hardware GPS coordinates automatically.
    - `[ 👥 On Behalf of Someone Else ]`: Designed for off-site family/friends reporting an emergency inside Barangay Moonwalk.
  - **Victim Details (When On Behalf):**
    - Input fields for `Affected Person Name` and optional `Affected Person Contact Number` with required name validation.
  - **Interactive Draggable Pin Map:**
    - Embedded OLED dark Google Map with high-contrast draggable marker and tap-to-pin navigation.
    - On pin drop/drag end or tap: dynamically updates latitude/longitude and triggers high-precision reverse-geocoding for the street/sector via OpenStreetMap Nominatim and native placemarks.
    - Quick Moonwalk Sector Jump bar (Proper, San Jose, Airborne, Multinational, San Agustin, Simplicio Cruz) allowing instant camera alignment.
- [x] In `IncidentDetailPage`, `IncidentReportsPage`, and `AdminDispatchMapPage`:
  - Rendered dedicated On-Behalf victim contact badges, off-site indicators, and 1-tap telephony dialer for emergency responders.

#### 8.7.2 Admin Dispatch Estimated Time of Arrival (ETA)
- [x] Expand `IncidentEntity` & `IncidentModel`:
  - Add optional field: `String? estimatedResponseTime` (e.g., `"5-10 mins"`, `"15 mins"`).
- [x] In `incident_reports_page.dart` & `admin_dispatch_map_page.dart`:
  - When updating ticket status to `In Progress` (dispatching Tanods/responders):
    - Present quick ETA chips: `[ 5-10 mins ]`, `[ 10-15 mins ]`, `[ 20-30 mins ]`, and custom input.
    - Persist `estimatedResponseTime` to Firestore.
- [x] In resident `IncidentDetailPage` & `IncidentTrackingSheet`:
  - Display prominent arrival estimate banner:
    `⏱️ Responders Dispatched • Estimated Arrival: 10-15 mins` alongside dispatcher operational notes.

#### 8.7.3 Admin Reports Desk Sticky/Frozen Actions Column
- [x] In `incident_reports_page.dart`:
  - Freeze the **Actions** column on the far right of the table using a synchronized dual-table layout with vertical scrolling, custom shadow boundary, and horizontal scrollbar.
  - Ensures desk officers can immediately trigger `[ View Details ]` and `[ Update Status / Dispatch ]` without having to scroll horizontally across all metadata columns.

#### 8.7.4 Instant Direct Telephony Dialing for Emergency Hotlines
- [x] Add `flutter_phone_direct_caller` package to `pubspec.yaml`.
- [x] Add `<uses-permission android:name="android.permission.CALL_PHONE" />` to `android/app/src/main/AndroidManifest.xml`.
- [x] In `emergency_hotlines_page.dart`:
  - When tapping hotline cards or glowing CALL button on Android, immediately initiate the telephone call via `FlutterPhoneDirectCaller.callNumber()`, zero extra button clicks required.
  - Fall back gracefully to `url_launcher` (`ACTION_DIAL`) on Web and unsupported environments.
  - Added tooltip and long-press confirmation option.

#### 8.7.5 "Other Emergency" Custom Type Specification
- [x] In `report_incident_page.dart`:
  - When `"Other Emergency"` category is selected, dynamically reveal a 3D specification text field:
    `"Specify Emergency Type (e.g. Fallen Electric Wire, Gas Leak, Sinkhole, Oil Spill)"`.
  - Validate that custom specification is not empty when "Other Emergency" is chosen.
  - Formatted final category label as `"Other Emergency ($customOther)"` so it renders accurately across map markers, admin tables, analytics, and LGU blotter exports.
  - Enhanced `IncidentTriageHelper` to auto-triage hazards (e.g. gas leak, explosion, electrical wire, sinkhole) to `CRITICAL` or `HIGH`.

#### 8.7.6 Biometric Verification & Anti-Spam Gate
- [x] Integrate `local_auth` package:
  - **BiometricService Clean Architecture Integration:** Created `BiometricService` in `core/services/` and registered in GetIt container.
  - **Anti-Prank Submission Verification:** In `report_incident_page.dart`, authenticates citizen's fingerprint/face before dispatching emergency reports with device PIN/passcode fallback.
  - **First-Time Biometric Enrollment Modal:** In `dashboard_page.dart`, gracefully prompts post-login citizens once with an OLED dark modal to enable quick biometric access for emergency reporting and app access.
  - **Android Native Bridge:** Updated `MainActivity.kt` to extend `FlutterFragmentActivity` and registered `USE_BIOMETRIC` permission in `AndroidManifest.xml` for biometric prompt reliability.

#### 8.7.7 Human-Readable Geocoding & Interactive Pin Dragging Polish
- [x] **Moonwalk Offline Centroid & Human-Readable Geocoding Fallback:**
  - Added recognized sector centroids and `findClosestSector(lat, lng)` in `BarangaySectorHelper`.
  - Replaced raw `"Pinned Location (lat, lng)"` with intelligent neighborhood address resolution (e.g. `"San Jose (Area 1), Barangay Moonwalk, Parañaque City"`).
  - Sanitized location displays in `IncidentDetailPage`, `IncidentReportsPage`, and `DashboardPage` so raw coordinate strings are never shown in place of readable addresses.
- [x] **Non-Interfering Minimap Pin Dragging:**
  - Attached `EagerGestureRecognizer` to the compact mini-map in `report_incident_page.dart` so pin dragging never causes the parent incident report form to scroll.
  - Added real-time dragging callbacks (`onDragStart`, `onDrag`, `onDragEnd`) with dynamic coordinate updating and an active dragging guide badge.

#### 8.7.8 Resident Experience, Safety Navigation & Dashboard Personalization
- [x] **Discard / Back Navigation Guard:**
  - Integrated `PopScope` with `_isFormDirty` evaluation in `report_incident_page.dart` to prevent accidental loss of draft reports.
  - Clean forms pop immediately; dirty forms prompt an OLED dark confirmation modal (`Keep Editing` / `Discard`).
- [x] **Personal Report Metrics on Resident Dashboard:**
  - Aligned dashboard status counters to adviser recommendation: updated header to **`MY REPORTS STATUS`** with **`My Filings`** badge.
  - Filtered `Pending`, `Active`, and `Solved` metric counters to the resident's own filings (`reporterId == currentUserId`), with tap-to-view navigation to `MyReportsPage`.
  - Preserved community-wide transparency on the live **Community Incidents** feed below.
- [x] **Interactive Community Incident to Map Pin Navigation:**
  - Tapping any community incident card on the resident dashboard navigates to `MapsPage(focusedIncident: incident)`.
  - MapsPage centers camera at zoom 16.5 directly on the incident pin and summons the bottom sheet incident dossier.

---

### Phase 8.8: Resident Settings & Civic Communication Suite
**Goal:** Perfect the resident account settings, hotline dialing, privacy alignment, feedback persistence, and legal compliance, while establishing a future roadmap for official barangay ground-truth data and bilingual support.

#### 8.8.1 Immediate Implementations (Ready to Build)
- [x] **Telephony Runtime Permission for Instant Direct Calling:**
  - Added `<uses-permission android:name="android.permission.CALL_PHONE" />` to `AndroidManifest.xml`.
  - Configured `FlutterPhoneDirectCaller.callNumber()` in `EmergencyHotlinesPage`, which natively manages `ActivityCompat.requestPermissions()` on Android to initiate the call directly without dropping the resident into the numeric dial pad.
  - Added fallback to `url_launcher` (`ACTION_DIAL`) for emergency-restricted numbers (911/112), denied permissions, and web platforms.
- [x] **Privacy & Security Hardening (Anti-Spam Alignment, Password Change & Email Reset):**
  - Removed the "Biometric App Lock" toggle in `PrivacySecurityPage` (as biometrics serves as the non-bypassable incident submission anti-spam gate).
  - Added informational security badge: `"🛡️ Biometric Verification: Active by municipal policy to prevent prank and spam filings."`
  - **In-App Password Change:** Standard 3-field credential update (`Current Password`, `New Password`, `Confirm New Password`) for logged-in residents via Firebase Auth re-authentication.
  - **Forgot Password Email Reset Link (`sendPasswordResetEmail`):** Provided a 1-tap fallback inside the dialog (`"Forgot current password? Send reset link to email"`). Firebase provides and hosts the secure reset web page automatically.
- [x] **Barangay Administrative Help Desk Modal:**
  - Upgraded `Barangay Help Desk` in `settings_page.dart` into an informative contact sheet with Moonwalk Hall address, office hours (Mon-Fri 8AM-5PM), 1-tap phone dialer, and 1-tap email compose (`mailto:`).
  - Explicitly separates administrative inquiries from emergency incident reporting.
- [x] **In-App Citizen Feedback & Bug Reporting (Firestore Persistence):**
  - Connected the feedback modal to a dedicated Firestore collection (`app_feedback`) storing `{ userId, userName, userEmail, category, message, createdAt, appVersion }`.
  - Added category selector chips (`General Feedback`, `Bug Report`, `Feature Suggestion`).
- [x] **Account Deletion & Right to Erasure (RA 10173 Compliance):**
  - Implemented permanent account deletion flow (`user.delete()` in Firebase Auth and user profile cleanup in Firestore `users`) with high-severity confirmation dialog and `requires-recent-login` re-auth handling.
  - Preserved "Log Out" button at the bottom of settings as standard mobile UX convention.
- [x] **Citizen Profile Picture High-Resolution Lightbox in Admin Dossier & Table:**
  - Upgraded the Citizen Dossier header avatar with an interactive cyan accent ring, zoom badge (`zoom_in_rounded`), hover tooltip, and explicit `"Click avatar to enlarge"` indicator.
  - Implemented `_showEnlargedPhotoDialog`: an OLED dark lightbox modal with `InteractiveViewer` (pinch/scroll-wheel zoom and drag-to-pan), loading indicator, broken-image fallback, and 1-tap `"Open Original"` external link.
  - Made the citizen table row avatar also clickable to immediately view full-size photo.

#### 8.8.2 Future / Scheduled Roadmap Items
- [ ] **Official Barangay Moonwalk Ground-Truth Sector Mapping:**
  - *Scheduled after consultation with Barangay Moonwalk officials.*
  - Update `BarangaySectorHelper.recognizedSectors` with local colloquial street/compound names obtained directly from Tanods and barangay administration.
  - Propagate official sector names across profile settings dropdown, minimap quick-jump bar, geocoding fallback, and admin filters.
- [ ] **Bilingual Translation & Localization (English / Filipino Tagalog):**
  - *Scheduled for Phase 9 & Capstone Polish.*
  - Target bilingual translation primarily on the Gemini 1.5 Flash Emergency Chatbot & civil defense first-aid guidance where it offers maximum life-saving utility.
  - Evaluate full-app localization based on Capstone Adviser / Panelist recommendations.
- [ ] **About ResQ Community Safety Comprehensive Dossier:**
  - *Scheduled for Final Pre-Deployment Phase.*
  - Document platform guidelines, emergency mandates, version metadata, capstone developer credits, and institutional acknowledgments.

---

### Phase 9: AI Precautionary Measures & Civil Defense Assistant (Gemini 1.5 Flash)
**Goal:** Empower residents with instant situational safety precautions post-report submission and conversational civil defense triage via Gemini 1.5 Flash, backed by deterministic rule-based urgency classification and 0ms offline fallbacks.

#### 9.1 Incident Submission Loading & AI Precautionary Measures Modal
- [x] **Deterministic Urgency Resolution (Replace "Pending Evaluation"):**
  - Pass the baseline urgency calculated by `IncidentTriageHelper.getBaselineUrgency(category)` directly into `_showPostSubmitSafetyWindow()`.
  - Replace the static `"Priority Level: Pending Evaluation"` badge with color-coded, active urgency tags:
    - 🔴 **`CRITICAL PRIORITY`** (Fire, Medical Trauma, Gas Leak, Explosion)
    - 🟠 **`HIGH PRIORITY`** (Live Electrical Hazard, Flood, Calamity, Violence, Sinkhole)
    - 🔵 **`MEDIUM PRIORITY`** (Road Accidents, Suspicious Activity, Other Emergencies)
    - ⚪ **`LOW PRIORITY`** (Noise Ordinance, Lost Items)
  - *Rationale:* Eliminates reliance on speculative AI text description parsing for life-and-death triage; emergency reports from panicking residents who type brief 2-word narratives are immediately and reliably classified with zero hallucination.
- [x] **Dispatch-Priority Submission Loading UX:**
  - Introduce an OLED dark modal loading overlay (`"Submitting Emergency Report to Responders..."`) during biometric authentication and Firestore persistence.
  - Prioritize immediate database dispatch (~500ms) so emergency tickets are confirmed and received by the Barangay Moonwalk desk without waiting on LLM round-trips.
- [x] **Hybrid Precautionary Measures (Instant Local Checklist + Gemini AI Advisory):**
  - Immediately render the local baseline safety checklist (`_getSafetyGuidelines`) so the resident has actionable first-aid/safety procedures with 0ms latency.
  - Concurrently trigger Gemini 1.5 Flash via `IncidentAiRemoteDataSource` to generate situational, tailored safety advice based on the incident category, description, and location.
  - Render dynamic advice inside an interactive, expandable card (`"🤖 AI Situational Safety Advisory"`) with shimmer loading state.
  - Resilient Fallback: If network is offline or AI request times out, the baseline checklist and 1-tap direct hotline buttons remain active with zero user-facing errors.

#### 9.2 Conversational Civil Defense Emergency Chatbot (`floating_chat_bot.dart`)
- [x] Connect resident chat input to Gemini 1.5 Flash via `IncidentAiRemoteDataSource.askCivilDefenseAssistant()`.
- [x] System prompt engineering: instructs Gemini to act as a Barangay Moonwalk civil defense officer, prioritize life safety, recommend evacuation/authorities first, and give concise, numbered first-aid steps.
- [x] Maintain instant local civil defense procedures as offline/quick fallback for common keywords (Fire, Flood, CPR, Severe Bleeding, Heatstroke).
- [x] Include dynamic one-tap hotline dialer pills (`[ Call 911 ]`, `[ Call 112 ]`, `[ Call 143 ]`, `[ Call Barangay Desk ]`, `[ All Hotlines ]`) inside chatbot responses whenever hazards are detected, powered by reusable `DirectCallerHelper`.


---

### Phase 10: Security Architecture, Credential Governance, & Deployment
**Goal:** Harden database permissions with strict RBAC, isolate API secrets, prevent credential leaks, comply with RA 10173 (Data Privacy Act), clean orphan routes, and produce production release builds.

#### 10.1 Route Registration & Orphan Code Cleanup
- [x] **Route Registration:**
  - Registered all named routes across `main.dart`, `main_resident.dart` (resident routes), and `main_admin.dart` (admin routes) to eliminate unhandled routing exceptions.
- [x] **Orphan Code Pruning:**
  - Removed deprecated duplicate directories `lib/features/admin/` and `lib/features/resident/`.

#### 10.2 Credential Governance & Multi-Layered Security Architecture
- [x] **10.2.1 Source Control Hardening & Secret Isolation:**
  - Untracked `.env` from Git index and enforced strict exclusion in `.gitignore`.
  - Created `.env.example` template with dummy placeholders for safe open-source/repository distribution.
- [x] **10.2.2 Google Cloud Console Key Restrictions:**
  - **Google Maps API Key:** Locked in Google Cloud Console using Android Application Restrictions: restricted exclusively to package name `com.example.community_safety_app` and signing Keystore SHA-1 certificate fingerprint (`F6:7B:A3:92:12:44:94:88:44:09:F7:E6:19:17:08:DE:17:7F:F4:51`).
  - **Gemini API Key:** Restrict in Google Cloud Console to `Generative Language API`.
- [x] **10.2.3 Cloudinary Unsigned Preset Governance:**
  - Audited codebase: Verified zero Cloudinary API Secrets reside in client mobile/web code; strictly utilizes public Cloud Name and unsigned preset `crkjnmhd`.
  - Configured unsigned preset governance: whitelisted media types (`image/jpeg`, `image/png`, `video/mp4`), enforced size caps (10MB photos / 20MB videos), isolated upload targets to `resq_photos/` and `resq_videos/`, and applied automatic on-the-fly H.264 MP4 transcoding (`vc_h264,f_mp4`).
- [x] **10.2.4 Firestore & Storage Role-Based Security Rules (`firestore.rules` & `storage.rules`):**
  - **`firestore.rules` (RBAC Firewall):**
    - Citizens (`role != 'admin'`): Can read verified public community incidents and create new incident reports. Can only view and edit their own `users/{uid}` document.
    - Admins (`role == 'admin'`): Sole authorized role permitted to mutate incident statuses (`Pending` ➔ `In Progress` ➔ `Resolved` ➔ `Declined`), assign responder dispatch ETAs, delete/archive incidents, and review user accounts.
    - Immutable Audit Logs (`/audit_logs/{id}`): Admin-only write, non-deletable (`allow update, delete: if false;`).
  - **`storage.rules`:**
    - Authenticated users can upload evidence photos up to 10MB and video evidence up to 20MB.
- [x] **10.2.5 Data Privacy Act of 2012 (RA 10173) Compliance & Data Masking:**
  - Enforced Privacy by Design in `incident_detail_page.dart`:
    - Public Citizen View: Off-site victim names (`_maskName`: e.g. `J••• D••• C•••`) and contact phone numbers (`_maskPhone`: e.g. `0917 ••• ••67`) are dynamically masked; direct phone dialer is disabled and locked behind an official RA 10173 compliance card.
    - Filing Resident (Reporter) View: Unmasked access preserved with a clear `Your Filing` badge.
    - Municipal Dispatcher View: Unmasked operational dossier retained in the Admin Command Center for emergency field dispatch.
- [x] **10.2.6 Enterprise Roadmap Defense (Serverless Cloud Function Proxy):**
  - Authored comprehensive specification document `docs/ENTERPRISE_ARCHITECTURE_DEFENSE.md` covering:
    - Serverless Firebase Cloud Function proxy architecture with Google Cloud Secret Manager and IAM.
    - Firebase App Check hardware attestation (Play Integrity / DeviceCheck).
    - Distributed token-bucket rate limiting (Redis/MemoryStore) to prevent LLM cost exhaustion.
    - Formal Capstone Defense Panel Q&A cheatsheet defending prototype vs. enterprise scaling choices.
- [x] **10.2.7 Production Admin Authentication & Demo Deprecation:**
  - Deprecated hardcoded `admin@safe.gov` / `admin123` demo bypass from `auth_repository_impl.dart`.
  - Provisioned authentic municipal administrator account in Firebase Authentication and assigned verified `role: 'admin'` in Firestore `users/{uid}`.
  - Enforced strict RBAC Gatekeeper in `admin_login_page.dart`: verifies `role == 'admin'` post-auth and rejects unauthorized citizen logins.
  - Purged demo credential chips and shortcuts from `admin_login_page.dart` and replaced with Municipal Security Notice.
  - Connected Admin Top-Right Header and Profile Settings Page to live authenticated Firestore data with real-time audit logging and desk speaker chime testing.

#### 10.3 Multimedia Evidence & Audio Infrastructure (Completed)
- [x] **Universal H.264 Codec Transcoding & Built-in Admin Media Viewers:**
  - Solved Windows Media Player / Microsoft Edge HEVC (H.265) video black-screen issue via Cloudinary on-the-fly H.264 transcode (`vc_h264,f_mp4`).
  - Built and integrated `InAppEvidencePlayerDialog` (play/pause, seek scrubber, timestamp, volume, popout) and `InAppImageViewerDialog` (interactive pan & zoom) across Incident Reports, Dispatch Map drawer, and Quick Review modal.
- [x] **Custom Emergency Alert Sound Infrastructure:**
  - Synthesized dual-harmonic emergency alert chime (`android/app/src/main/res/raw/resq_alert.wav` & `assets/sounds/resq_alert.wav`).
  - Registered `resq_emergency_alerts_v2` high-importance notification channel with `RawResourceAndroidNotificationSound('resq_alert')` in `FCMService`.

#### 10.4 Physical Device & Web Deployment Validation
- [x] **Build Android Resident APK:**
  ```bash
  flutter build apk -t lib/main_resident.dart --release
  ```
  - Generated production release binary: `build\app\outputs\flutter-apk\app-release.apk` (58.9MB).
  - Verify camera capture, hardware GPS coordinates, and offline caching on physical Android device.
- [x] **Build & Deploy Admin Web Portal:**
  ```bash
  flutter build web -t lib/main_admin.dart --release
  firebase deploy --only hosting
  ```
  - Production Hosting Live URL: [https://resq-community-safety.web.app](https://resq-community-safety.web.app).
  - Verified municipal desk access on desktop browser with full Firebase Auth, Firestore real-time synchronization, and dispatch capabilities.

---

### Phase 11: Dark & Light Mode Theme Adaptability, UI De-Cluttering, & Visual Polish
**Goal:** Deliver a seamless dual-theme experience (Dark & Light Mode), eliminate visual clutter ("badge fatigue"), personalize the citizen interface, enhance report directory search capabilities, and ensure premium typography and layout standards across the app.

#### 11.1 Reactive Dual-Theme Engine & Visual Contrast Audit
- [x] **Theme-Adaptive Surface System (`AppColors` & `Custom3dCard`):**
  - Integrated reactive `ValueListenableBuilder<bool>` listening to `AppColors.isDarkModeNotifier`.
  - Replaced harsh neon box shadows with subtle, elevation-based ambient lighting (8px blur in Light Mode, 12px blur in Dark Mode).
- [x] **Navigation Drawer (`SideMenu`):**
  - Resolved dark mode lock: implemented theme-adaptive background gradients, borders, divider tones, icon contrasts, and typography.
- [x] **Report Incident Page Form & Modal Contrast:**
  - Standardized AppBar with adaptive border and `AppColors.surface`.
  - Fixed white-on-white text readability in Complainant Identity and Incident Category dropdowns.
  - Corrected GPS address text contrast and adapted the discard confirmation dialog for both themes.
- [x] **Barangay Emergency Hotlines Page:**
  - Eliminated harsh black top banner overlay in light mode by implementing an adaptive crimson gradient header.
- [x] **Dashboard Header & Hero Card State Sync:**
  - Removed stale `const` blocks from `_PremiumAppBar` and `_WelcomeHeroCard`.
  - Connected components directly to `AppColors.isDarkModeNotifier` to prevent theme toggling lockups.
- [x] **Resident Notification Sheet (`ResidentNotificationsSheet`):**
  - Adapted notification modal background, container borders, and text contrasts for seamless switching.

#### 11.2 Resident Personalization & Real Identity Integration
- [x] **Dynamic First-Name Extraction:**
  - Extracted resident's authentic first name reactively from `AuthBloc` (`fullName` or `displayName`, e.g. "Jaymerson"), with fallback to email username.
  - Dynamically reflected the personalized greeting across `_PremiumAppBar` ("Hello, Jaymerson") and `_WelcomeHeroCard` ("Welcome back, Jaymerson").

#### 11.3 My Reports Directory & Real-Time Search Filtering
- [x] **Scroll View Boundary & Overlap Fix:**
  - Removed `clipBehavior: Clip.none` from the reports directory list view to prevent list items from overflowing into the upper headers during bouncing scrolls.
  - Balanced vertical list paddings and card margin heights.
- [x] **Integrated Live Search Engine:**
  - Implemented an animated, toggleable search bar in `MyReportsPage`.
  - Connected real-time search queries to filter by incident category, description text, resolved address, area sector, and report ID concurrently with status tab filters (`All`, `Pending`, `In Progress`, `Resolved`).

#### 11.4 Comprehensive Badge De-Cluttering & Information Hierarchy
- [x] **My Reports Incident Cards (`_AnimatedReportCard`):**
  - Merged area sector directly into the location row (`📍 Address • Sector`).
  - Converted bulky `Live at Dispatch` / `Stored Locally` pill badges into clean, subtle inline timestamp metadata (`🕒 Date/Time • ☁️ Live/Local`).
  - Retained primary status badge (`PENDING`, `IN PROGRESS`, `RESOLVED`) on the upper right as the sole prominent card tag.
  - Sifted contextual chips (`For: Relative`, `ETA: X mins`) to only appear when actively applicable.
- [x] **Dashboard Hero Card & Section Headers:**
  - Replaced gamer/server-like `[🟢 Barangay Moonwalk — Online]` badge in the Hero Card with clean civic metadata: `📍 Barangay Moonwalk • Resident`.
  - Removed redundant `[My Filings]` badge beside "MY REPORTS STATUS", properly aligning "View All >" in the top row.
  - Replaced boxed `[4 Active]` badge beside "Community Incidents" with clean header typography.
- [x] **Report Incident Page Location Header:**
  - Removed redundant `[GPS PINNED] / [PIN ADJUSTED]` badge above the pinned location summary card to eliminate visual noise.
- [x] **Settings Page Profile Header:**
  - Transferred verified status to an inline verified shield icon (`✓`) beside the user's name.
  - Merged area sector and verification into a clean location string (`📍 Area • Verified Resident`).
  - Purged two separate boxy pill badges.
  - Removed temporary developer-only "Alerts & Notification Diagnostics" section (`Test Emergency Alert & Chime` tile) and cleaned unused FCM imports.
  - Resolved Flutter SDK `activeThumbColor` deprecation on the theme switch.

---

### Phase 12: Unified Bottom Navigation Architecture, TopBar Standardization, & Gemini AI Chatbot Optimization
**Goal:** Introduce a modern persistent bottom navigation shell with an elevated center emergency action button, standardize topbar dimensions and branding across all resident tabs for seamless navigation continuity, and optimize the ResQ Civil Defense Gemini AI chatbot for mobile ergonomics and complete, high-speed responses.

#### 12.1 Persistent Bottom Navigation Shell (`ResidentNavShell`)
- [x] **Core Multi-Tab Architecture:**
  - Implemented `ResidentNavShell` hosting an `IndexedStack` preserving state across 4 core tabs:
    - **Tab 0:** Home / Dashboard (`DashboardPage`)
    - **Tab 1:** My Reports Directory (`MyReportsPage`)
    - **Tab 2:** Interactive Community Map (`MapsPage`)
    - **Tab 3:** Settings & Civic Support (`SettingsPage`)
  - Added `ResidentNavShell.switchTab(context, index)` enabling programmatic tab switching from any child widget, banner, or drawer.
- [x] **Elevated Center Emergency Quick-Action:**
  - Integrated a center emergency button (`🚨 REPORT`) launching the complete `ReportIncidentPage` flow with haptic feedback.
- [x] **UI De-Duplication:**
  - Removed redundant large 3D "Report Incident" card from Dashboard body to prevent interface duplication.
  - Wired `/dashboard` route and root auth wrapper in `main_resident.dart` and `main.dart` directly to `ResidentNavShell`.

#### 12.2 Unified TopBar Metrics & Visual Continuity Across All Pages
- [x] **Universal 64px Metric Standard:**
  - Standardized topbar height across all resident screens to `64.0 + MediaQuery.padding.top`:
    - `DashboardPage` (`_PremiumAppBar`)
    - `MyReportsPage` (`_MyReportsAppBar`)
    - `MapsPage` (PreferredSize AppBar)
    - `SettingsPage` (PreferredSize AppBar)
  - Fixed squashed/mini topbar bug in `MyReportsPage` caused by missing explicit container height.
- [x] **Consistent Brand Crest & Typography:**
  - Standardized left-side branding: glowing 36x36 circular ResQ shield crest with cyan gradient title (`RESQ`, `MY REPORTS`, `COMMUNITY MAP`, `SETTINGS`) at 18px / FontWeight 900 / letterSpacing 1.5.
  - Implemented theme-adaptive ambient drop shadows (`Colors.black` with 8px/12px blur) reacting to `AppColors.isDarkModeNotifier`.
  - Preserved right-side contextual widgets: Notification bell & profile badge (Home), report history badge (My Reports), live municipal telemetry pulsing badge (Map), and tune/config icon (Settings).
- [x] **Drawer / Hamburger Menu Elimination:**
  - Removed redundant `drawer: const SideMenu()` and hamburger `IconButton(Icons.menu)` from the Dashboard topbar now that the persistent bottom navigation shell handles all primary destinations.

#### 12.3 Gemini AI Civil Defense Chatbot Optimization & Mobile Ergonomics
- [x] **Global Duplicate Chatbot Removal:**
  - Removed root `MaterialApp.builder` wrapper injecting the legacy mock `FloatingChatBot` from `lib/core/widgets/floating_chat_bot.dart` across all pages in `main_resident.dart` and `main.dart`.
  - Preserved the genuine Gemini AI assistant housed exclusively on the Dashboard.
- [x] **Keyboard-Adaptive Dynamic Window Scaling:**
  - Replaced rigid 540px `OverflowBox` with adaptive layout reacting to `MediaQuery.viewInsets.bottom`:
    - Dynamically scales window height down to `(screenHeight - topPadding - keyboardHeight - 24).clamp(240, 440)` when virtual keyboard opens.
    - Repositions bottom offset to `keyboardHeight + 10.0` so the chat window sits directly above the keyboard.
    - Temporarily collapses suggestion chips during keyboard focus to maximize message visibility.
    - Ensures header with Close (`X`) and Reset buttons remains **100% visible on screen at all times**.
- [x] **Chat History Reset Confirmation Dialog:**
  - Added `_confirmResetChat` modal alert preventing accidental session wipes on refresh button tap.
- [x] **Elimination of Message Truncation & Thinking Overhead (`gemini-3.5-flash`):**
  - Configured `"thinkingConfig": {"thinkingBudget": 0}` in `IncidentAiRemoteDataSourceImpl`, disabling hidden reasoning tokens and reducing response generation latency from ~10s to **~1 second**.
  - Increased `maxOutputTokens` from 500 to **2048**, completely eliminating premature `finishReason: MAX_TOKENS` mid-sentence cut-offs.
  - Increased network timeout to 25s for reliable mobile cellular operation.
- [x] **Rich Text & Markdown Formatting in Message Bubbles:**
  - Built `_FormattedMessageText` custom rich text parser in `floating_chat_bot.dart`:
    - Parses Markdown bold (`**text**`) into crisp `FontWeight.w800` spans without raw asterisk artifacts.
    - Formats markdown section titles (`#`, `##`, `###`) into styled cyan headings.
    - Converts bullet markers (`*`, `-`) into clean unicode bullets (`• `).

---

## 4. Team Collaboration & Quality Standards

1. **Strict Clean Architecture:** Never import presentation widgets into data or domain layers. Route all mutations through BLoC events.
2. **No Placeholders or Dead Controls:** Every button, toggle, and input must either connect to a functional service or be cleanly removed.
3. **Dual-Target Verification:** When adding shared features, verify that both the Mobile APK and Web Portal build cleanly without platform conflicts.

