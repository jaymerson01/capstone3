# ResQ: Comprehensive System Architecture, UI, & Interaction Specification Guide

> **Document Version:** 1.0.0  
> **Target Directory:** `c:\YckoVon\Documents\capstone3\clean_folder`  
> **Target Codebase Architecture:** Clean Architecture (Domain, Data, Presentation) + BLoC State Management  
> **Target Audience:** Future AI Coding Agents, Developers, QA Engineers, and System Architects.

---

## Table of Contents
1. [Executive Summary & System Architecture](#1-executive-summary--system-architecture)
2. [Design System, Theming, & UI Foundations](#2-design-system-theming--ui-foundations)
3. [Citizen / Resident Portal Walkthrough](#3-citizen--resident-portal-walkthrough)
   - 3.1 [Landing & Welcome Page](#31-landing--welcome-page)
   - 3.2 [Resident Authentication Suite](#32-resident-authentication-suite)
   - 3.3 [Resident Dashboard](#33-resident-dashboard)
   - 3.4 [Incident Reporting Flow & AI Triage](#34-incident-reporting-flow--ai-triage)
   - 3.5 [Interactive Safety Map](#35-interactive-safety-map)
   - 3.6 [My Reports Directory & Real-time Timeline](#36-my-reports-directory--real-time-timeline)
   - 3.7 [Emergency Hotlines Portal](#37-emergency-hotlines-portal)
   - 3.8 [Settings, Profile, & Security Center](#38-settings-profile--security-center)
   - 3.9 [Floating AI Emergency Assistant (Chatbot)](#39-floating-ai-emergency-assistant-chatbot)
   - 3.10 [Resident Navigation Drawer](#310-resident-navigation-drawer)
4. [Admin Command Center Walkthrough](#4-admin-command-center-walkthrough)
   - 4.1 [Admin Authentication Gateway](#41-admin-authentication-gateway)
   - 4.2 [Command Center Shell & Navigation](#42-command-center-shell--navigation)
   - 4.3 [Admin Overview Dashboard](#43-admin-overview-dashboard)
   - 4.4 [Incident Reports Management](#44-incident-reports-management)
   - 4.5 [User Management & Access Control](#45-user-management--access-control)
   - 4.6 [Area & Barangay Zone Management](#46-area--barangay-zone-management)
   - 4.7 [Incident Categories Management](#47-incident-categories-management)
   - 4.8 [Administrative Audit Logs](#48-administrative-audit-logs)
   - 4.9 [Admin Profile & Security Settings](#49-admin-profile--security-settings)
5. [Hardware & Diagnostic Test Harness](#5-hardware--diagnostic-test-harness)
6. [Comprehensive Interactive UI Matrix](#6-comprehensive-interactive-ui-matrix)
7. [Data Architecture, AI Integration, & Offline Resilience](#7-data-architecture-ai-integration--offline-resilience)
8. [Backend Integration Readiness & Next Steps](#8-backend-integration-readiness--next-steps)

---

## 1. Executive Summary & System Architecture

The **ResQ** platform is a mission-critical community safety, incident reporting, and crisis dispatch ecosystem designed specifically for Philippine local government units (LGUs), initially localized for **Barangay Moonwalk, Parañaque City**.

The system utilizes Uncle Bob’s **Clean Architecture** principles decoupled into three distinct tiers across both user personas (Resident and Admin):

```
                       ┌──────────────────────────────────────┐
                       │          Presentation Layer          │
                       │  (Pages, Widgets, BLoCs, State, UI)  │
                       └──────────────────┬───────────────────┘
                                          │ depends on
                                          ▼
                       ┌──────────────────────────────────────┐
                       │             Domain Layer             │
                       │  (Entities, Use Cases, Repositories) │
                       └──────────────────▲───────────────────┘
                                          │ implemented by
                                          │
                       ┌──────────────────┴───────────────────┐
                       │              Data Layer              │
                       │   (Models, Remote/Local Data Sources)│
                       │   - Firebase Firestore & Storage     │
                       │   - Hive Offline Local Boxes         │
                       │   - Gemini 1.5 Flash AI Service      │
                       └──────────────────────────────────────┘
```

### Dependency Injection & Service Locator
All core dependencies are initialized in [injection_container.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/core/services/injection_container.dart) using `get_it`:
- **Core Services:** `LocationServiceImpl`, `CameraServiceImpl`, `SharedPreferences`.
- **Offline Storage:** `Hive` initialization for local incident caching (`incidents` box) and user session preservation (`auth` box).
- **External Clients:** `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `http.Client`.
- **Feature BLoCs:** `AuthBloc`, `IncidentBloc`.

---

## 2. Design System, Theming, & UI Foundations

The application enforces a custom high-contrast dark aesthetic built with glassmorphism, responsive spring animations, dynamic glow shadows, and tactile 3D interactive controls.

### 2.1 Color Palettes

#### Resident Design Tokens (`AppColors`)
- **Primary / Accent:** Electric Blue (`0xFF0A84FF`), Cyan Glow (`0xFF00D4FF`)
- **Backgrounds:** Ultra Deep Dark (`0xFF060D1A`), Surface Container (`0xFF0D1627`), Surface Raised (`0xFF132038`), Glass Stroke (`0x2600D4FF`)
- **Emergency Crimson:** (`0xFFFF3B30`) - Hotlines, High Urgency alerts, Discard/Logout
- **Warning / Pending:** Amber (`0xFFFF9F0A`)
- **Resolved / Success:** Solved Green (`0xFF30D158`)
- **Typography:** Text Primary (`0xFFFFFFFF`), Text Muted (`0xFF8E9BAE`)

#### Admin Design Tokens (`AdminColors`)
- **Primary:** Admin Cyan (`0xFF00D4FF`), Blue Accent (`0xFF0A84FF`)
- **Backgrounds:** Command Dark (`0xFF060D1A`), Sidebar Dark (`0xFF0B1424`), Card Dark (`0xFF0F1B2E`)
- **Borders & Dividers:** Subtle Border (`0xFF1A2A42`), Active Highlight (`0x3300D4FF`)
- **Status Badges:** Red (`0xFFFF453A`), Orange (`0xFFFF9F0A`), Green (`0xFF30D158`), Purple (`0xFFBF5AF2`)

### 2.2 Reusable 3D Components
1. **`Custom3dButton`** ([custom_3d_button.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/core/presentation/widgets/custom_3d_button.dart)):
   - Physics-based spring down-scale (`0.96`) on press.
   - Dual-layered 3D beveled shadow giving realistic physical depth.
   - Haptic feedback trigger on click.
   - Optional animated glowing radial aura.
   - Integrated loading spinner indicator state.
2. **`Custom3dCard`** ([custom_3d_card.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/core/presentation/widgets/custom_3d_card.dart)):
   - Hover scale/elevation lift for desktop and tablet pointers.
   - Top-edge glass gradient highlight line.
   - Deep ambient drop shadow with customizable glow tint.
3. **`Custom3dTextField`** ([custom_3d_text_field.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/core/presentation/widgets/custom_3d_text_field.dart)):
   - Inset 3D border with dynamic neon focus glow.
   - Floating label animation, prefix icons, and suffix eye toggles for password fields.

---

## 3. Citizen / Resident Portal Walkthrough

### 3.1 Landing & Welcome Page
*File:* [welcome_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/auth/presentation/pages/welcome_page.dart)  
*Route:* `/welcome`

#### Visual Elements:
- **Atmospheric Background:** Animated canvas grid with floating radial glow particles.
- **Header Bar:** Brand title `ResQ` with emergency beacon logo.
- **Top Navigation Actions:** `Log In` button (navigates to Resident Login) and `Sign Up` button (navigates to Citizen Registration).
- **Hero Centerpiece:** Pulsing radar-ring shield logo accompanied by the headline: *"Instant Emergency Response & Incident Reporting"*.
- **Sub-caption:** *"Empowering citizens of Barangay Moonwalk to report incidents in real time."*

#### Interactive Elements & Clickable Actions:
1. **`Report an Incident` (Main 3D CTA Button):**
   - Evaluates authentication status via `AuthBloc`.
   - If authenticated: Transitions straight to `/report-incident`.
   - If unauthenticated guest: Displays a stylish bottom modal sheet offering:
     - *Proceed as Anonymous/Guest* (routes to `/report-incident`).
     - *Sign in for Verified Report* (routes to `/login`).
2. **`Emergency Hotlines` (Secondary Outlined 3D Button):**
   - Directly opens the unauthenticated Emergency Hotlines directory (`/emergency-hotlines`).
3. **`Access Admin Portal` (Discreet Bottom Footer Text Button):**
   - Direct shortcut opening the Command Center Login (`/admin/login`).

---

### 3.2 Resident Authentication Suite
*Files:* [login_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/auth/presentation/pages/login_page.dart), [sign_up_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/auth/presentation/pages/sign_up_page.dart), [auth_modals.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/auth/presentation/widgets/auth_modals.dart)

#### 3.2.1 Resident Login Page
- **Input Fields:**
  - *Email Address:* Enforces strict email format verification (specifically tested with `@gmail.com`).
  - *Password:* Obfuscated with interactive show/hide toggle eye icon.
- **Toggles & Links:**
  - *Remember Me:* Checkbox toggle that preserves session tokens in Hive storage.
  - *Forgot Password?:* Opens email recovery instruction dialog.
- **Actions:**
  - *`Log In` 3D Button:* Emits `LoginWithEmailSubmitted` to `AuthBloc`. Displays animated loading state.
  - *Social Login Row:* Quick login icons for **Google**, **Facebook**, and **Apple** (launches secure authentication intent).
  - *Switch to Sign Up:* Deep link to `/sign-up`.
- **Security & Error Modals:**
  - *Invalid Credentials Modal:* Glassmorphism popup with retry prompt.
  - *Account Locked Modal:* Triggered on 5 consecutive failed attempts. Features an animated **15-minute countdown ring painter** preventing brute-force attacks.

#### 3.2.2 Resident Sign-Up Page
- **Input Fields & Validation Rules:**
  - *Full Name:* Alpha characters only (regex: `^[a-zA-Z\s]+$`).
  - *Email:* Valid email address format.
  - *Password:* Enforces high-security policy (8–20 chars, at least 1 uppercase letter, 1 lowercase letter, 1 number, 1 special character). Includes live checkmark requirement indicators.
  - *Confirm Password:* Real-time matching validation against primary password.
  - *Terms & Conditions Checkbox:* Must be checked to enable submission.
- **Actions:**
  - *`Create Resident Account` Button:* Emits `SignUpSubmitted` to `AuthBloc`.
  - *Success Dialog:* Animated green shield modal confirming registration before auto-redirecting to `/dashboard`.

---

### 3.3 Resident Dashboard
*File:* [dashboard_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/dashboard_page.dart)  
*Route:* `/dashboard`

#### Visual Structure & Sections:
1. **AppBar & Header:**
   - Left: Drawer Hamburger menu icon (opens [side_menu.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/side_menu.dart)).
   - Center: `ResQ Moonwalk` brand title with live pulse indicator dot.
   - Right: Notification Bell icon (with unread badge counter) and Profile Avatar shortcut (navigates to `/settings`).
2. **Resident Hero Status Card:**
   - Displays: *"Welcome back, [Resident Name]"*.
   - Community safety status badge: `Normal Alert Level - Moonwalk Safe`.
   - Direct button: `View Safe Zones & Evacuation Centers`.
3. **Quick Stats Metric Strip (`QuickStatsRow`):**
   - *Pending Review:* Count of reports awaiting triage.
   - *Active Response:* Count of incidents currently being dispatched.
   - *Resolved Today:* Count of closed/verified incidents.
4. **Interactive Video Instruction Banner:**
   - Beveled video preview thumbnail depicting Barangay Moonwalk safety orientation.
   - Centered glowing Play Button that triggers an in-app video modal dialog.
5. **Primary Quick Action:**
   - Large pulsing `Report an Incident Now` 3D card button with camera icon (routes to `/report-incident`).
6. **Live Community Incidents Feed:**
   - Real-time reactive stream (`BlocBuilder<IncidentBloc, IncidentState>`).
   - Cards display category badge, urgency pill (`LOW`, `MEDIUM`, `HIGH`), timestamp, address snippet, and brief description.
   - Tapping any card opens [incident_detail_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident/presentation/pages/incident_detail_page.dart).
7. **Floating Safety Chatbot:**
   - Docked floating avatar on the bottom right (see [Section 3.9](#39-floating-ai-emergency-assistant-chatbot)).

---

### 3.4 Incident Reporting Flow & AI Triage
*Files:* [report_incident_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/report_incident_page.dart), [incident_ai_remote_data_source.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident/data/datasources/incident_ai_remote_data_source.dart), [safety_kits_provider.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident/presentation/widgets/safety_kits_provider.dart)  
*Route:* `/report-incident`

#### UI Components & Form Fields:
1. **Reporter Identity Dropdown:**
   - Options: `Report under my Name (Verified Resident)` vs `Submit Anonymously`.
2. **Barangay Sector / Area Selector:**
   - Dropdown options: `Area 1 - Phase 1 / Daang Batang`, `Area 2 - Phase 2 / Armstrong`, `Area 3 - San Agustin / E. Rodriguez`, `Area 4 - Multinational / Extension`.
3. **Geographic Location Pinning (Device GPS Coordinates):**
   - Coordinates field (`Latitude, Longitude`): Populated with the exact real-time physical coordinates of the user's device when the app fetches device location.
   - `Pin Current Device Location` / `Pin Exact Location` Button:
     - Directly queries `LocationServiceImpl` using the device's hardware GPS sensor via `geolocator`.
     - Captures the device's exact latitude and longitude at that moment (formatted to 6 decimal places, e.g. `14.599512, 120.984222`).
     - Automatically updates the form state (`_latitude`, `_longitude`) with the physical device position and resolves the street address for accurate emergency dispatch.
4. **Incident Category Dropdown (10 Standard Categories):**
   - `Fire Outbreak`, `Flood / Rising Water`, `Medical Emergency`, `Physical Altercation / Violence`, `Theft / Robbery`, `Road Accident / Collision`, `Suspicious Activity`, `Power Outage / Fallen Wires`, `Noise / Public Disturbance`, `Vandalism / Property Damage`.
5. **Incident Narrative Text Area:**
   - Multi-line `Custom3dTextField` with character counter and speech-to-text microphone helper icon.
6. **Evidence Attachment Section:**
   - `Take Photo` button: Triggers native device camera via `CameraServiceImpl`.
   - `Select from Gallery` button: Opens system media picker.
   - Media Preview Container: Displays thumbnail of captured image with an `X` delete button.
7. **Emergency Quick-Call Action Card:**
   - Highlighted crimson banner with two direct dispatch buttons:
     - *Call 911:* Opens system dialer with 911.
     - *Call Moonwalk Desk:* Opens system dialer with `(02) 8888-MOON`.

#### Hidden AI & Automated Triage Features:
- **Hidden Gemini AI Trigger (`HiddenAiTrigger`):**
  - Tapping the ResQ logo in the AppBar **5 times within 2 seconds** activates the AI Triage Assistant.
  - Automatically dispatches the narrative to Gemini 1.5 Flash API endpoint with the prompt:
    ```
    "Analyze the following incident report narrative. Determine urgency (LOW, MEDIUM, HIGH) 
     and extract key safety threats: [Incident Narrative]"
    ```
  - Displays a neon AI Triage Card previewing the extracted urgency level and safety suggestions.
- **Post-Submission Safety Action Kit Modal (`SafetyKitsProvider`):**
  - Upon successful submission, a customized emergency protocol popup appears before returning to Dashboard:
    - *Fire:* Evacuation route instructions, stop-drop-and-roll guide, electrical isolation.
    - *Flood:* Turn off main breaker, head to designated Moonwalk multistory evacuation center.
    - *Medical:* Basic bleeding control instructions, CPR advisory while medics are in transit.

---

### 3.5 Interactive Safety Map
*File:* [maps_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/maps_page.dart)  
*Route:* `/maps`

#### UI Components & Interactions:
1. **Google Maps Canvas:**
   - Centered on Barangay Moonwalk default coordinates: `14.4851° N, 121.0116° E`.
   - Custom dark-mode map styling with cyan road vectors.
2. **Dynamic Incident Markers:**
   - Colored pin markers dynamically placed based on active incident coordinates.
   - Marker color-coded by category:
     - Fire: Red pin
     - Flood: Cyan/Blue pin
     - Medical: Green pin
     - Crime/Violence: Purple pin
     - Road Accident: Orange pin
3. **Marker Tap Interaction (`IncidentTrackingSheet`):**
   - Tapping any marker animates the camera and presents a `DraggableScrollableSheet` modal at the bottom showing:
     - Incident Category & Urgency badge.
     - Formatted address and time elapsed.
     - Incident photo thumbnail (if attached).
     - Current status (`Pending`, `In Progress`, `Resolved`).
     - **"Me Too / I am also affected" Community Validation Button:** Allows nearby residents to upvote/verify the incident, boosting dispatch priority.
4. **Floating Map Controls:**
   - *Search Bar:* Autocomplete search for streets and landmarks within Barangay Moonwalk.
   - *Category Filter Action Chip Button:* Toggle visibility for specific incident types (e.g., only show Floods).
   - *Zoom In (+) / Zoom Out (-) 3D buttons.*
   - *Locate Me Button:* Recenters map camera on user's current GPS position with blue pulsing accuracy circle.
5. **Bottom Legend Strip:** Color-coded pills explaining marker severity and status meanings.

---

### 3.6 My Reports Directory & Real-time Timeline
*Files:* [my_reports_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/my_reports_page.dart), [incident_detail_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident/presentation/pages/incident_detail_page.dart), [incident_status_timeline.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident/presentation/widgets/incident_status_timeline.dart)  
*Route:* `/my-reports`

#### UI Components & Actions:
1. **Status Filter Chips:**
   - Horizontal scrolling strip with 4 filter chips: `ALL`, `PENDING`, `IN PROGRESS`, `RESOLVED`.
   - Active chip highlighted with cyan border and electric blue fill.
2. **Pull-to-Refresh Gesture:**
   - Pulling down re-emits `StreamActiveIncidentsRequested` to pull latest status changes from Firestore.
3. **Animated Report Cards List:**
   - Card features: Category icon, Reference ID (e.g., `#INC-8921`), submission date/time, current status pill, and brief description snippet.
4. **Detailed Incident Tracking View (`IncidentDetailPage`):**
   - Accessible by tapping any report card.
   - *Full Evidence Viewer:* Tap image to view full-screen zoomable modal.
   - *Dispatcher Note Box:* Displays official remarks from Barangay Moonwalk desk.
   - *3-Node Reactive Timeline (`IncidentStatusTimeline`):*
     - Node 1: `Report Submitted` (Green checkmark with timestamp).
     - Node 2: `Dispatched / In Progress` (Pulsing amber beacon when active).
     - Node 3: `Resolved & Verified` (Green shield completion state).

---

### 3.7 Emergency Hotlines Portal
*File:* [emergency_hotlines_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart)  
*Route:* `/emergency-hotlines`

Designed to function with zero friction, accessible even for unauthenticated users in distress.

#### UI Cards & One-Tap Actions:
1. **National Emergency Hotline (911):**
   - Red accent card with police siren badge.
   - Button: `CALL 911 NOW`. Confirms with modal: *"Connect immediately to National Police & Rescue Dispatch?"*
2. **Bureau of Fire Protection - Moonwalk Substation:**
   - Flame icon, direct number: `(02) 8824-3473` / `112`.
   - Button: `CALL FIRE DISPATCH`.
3. **Philippine Red Cross / Paramedics:**
   - Medical cross icon, hotline: `143`.
   - Button: `CALL AMBULANCE`.
4. **Barangay Moonwalk Operations Center (Opcen):**
   - Barangay seal icon, local 24/7 desk: `(02) 8888-MOON (6666)`.
   - Button: `CALL BARANGAY DESK`.
5. **Moonwalk Tanod Security Patrol:**
   - Direct radio dispatch mobile hotline.

---

### 3.8 Settings, Profile, & Security Center
*File:* [settings_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/settings_page.dart)  
*Route:* `/settings`

Contains over 1,600 lines of modular citizen self-service and security configuration.

#### 3.8.1 Main Settings Page
1. **Resident Profile Card:**
   - Resident avatar picture with `Verified Citizen` badge.
   - Displays full name, registered email, and resident sector.
   - Button: `Edit Profile` (navigates to `EditProfilePage`).
2. **Emergency Hotlines Quick Grid:**
   - 4-button horizontal matrix for instant dispatch dialing.
3. **Preference Toggles & Sliders:**
   - *Push Notification Alerts:* Switch toggle for critical community broadcast sirens.
   - *Dark Mode Enforcement:* Switch toggle for custom OLED high-contrast dark theme.
   - *Offline Incident Sync:* Switch toggle for auto-syncing cached reports when network resumes.
4. **Information & Support Modals:**
   - *About ResQ App:* Bottom sheet displaying app version `v1.0.0 (Clean Architecture)`, LGU partnership credentials, and developer credits.
   - *Barangay Help Desk Modal:* Contact info for Moonwalk administrative offices.
   - *Submit Bug / Feedback Dialog:* Text form modal to submit app issues.
5. **Destructive Security Actions:**
   - *Log Out 3D Button:* Emits `LogoutSubmitted` to `AuthBloc`.
   - *Delete Account Request:* Crimson dialog with 2-step confirmation warning about permanent data deletion.

#### 3.8.2 Sub-Page: Edit Profile (`EditProfilePage`)
- **Avatar Photo Picker:** Camera/Gallery selection with instant preview.
- **Form Fields:**
  - *Full Legal Name* (Text field).
  - *Email Address* (Read-only verified badge).
  - *Mobile Contact Number* (Format: `+63 9XX XXX XXXX`).
  - *Emergency Contact Person & Number* (Next-of-kin alert contact).
  - *Home / Street Address* (Within Barangay Moonwalk).
  - *Barangay Sector Dropdown* (`Phase 1`, `Phase 2`, `San Agustin`, `Multinational`).
  - *Language Locale Selector* (`English`, `Filipino / Tagalog`).
- **Action:** `Save Profile Changes` 3D button with confirmation toast.

#### 3.8.3 Sub-Page: Privacy & Security (`PrivacySecurityPage`)
- **Password Management Modal:**
  - Inset fields: *Current Password*, *New Password*, *Confirm New Password*.
  - Show/Hide visibility eye toggles on all fields.
  - Button: `Update Secret Password`.
- **Biometric Authentication:**
  - Switch toggle: *Enable Biometric ID Gateway Lock* (Fingerprint / FaceID prompt on app launch).
- **Two-Factor Authentication (2FA):**
  - Switch toggle: *Require SMS OTP on Login*.

---

### 3.9 Floating AI Emergency Assistant (Chatbot)
*File:* [floating_chat_bot.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/chat/presentation/widgets/floating_chat_bot.dart)

#### Widget Architecture & Visual Presentation:
- Floating draggable/dockable Floating Action Button (FAB) featuring a robotic assistant badge and pulsing cyan glow ring.
- Tapping expands an elegant **340px × 520px frosted glass container** overlaying the current screen without unmounting page context.
- Top Header: Title `ResQ AI Safety Assistant`, status `Online (Moonwalk Protocol)`, Minimize (`-`) icon, and Reset/Clear (`trash`) icon.

#### Interactive Features:
1. **Quick Question Suggestion Chips:**
   - Tap-to-ask chips:
     - *"What should I do during a fire?"*
     - *"What if someone is following me?"*
     - *"What to prepare during a flood?"*
     - *"Where is the nearest Moonwalk evacuation center?"*
2. **Chat Message Stream:**
   - User messages styled in Electric Blue right-aligned bubbles.
   - Assistant responses styled in Dark Slate left-aligned bubbles with AI avatar.
3. **Interactive 3-Dot Animated Typing Indicator:**
   - Displays animated pulsing dots while processing responses.
4. **Safety Rule Engine & Dispatch Integration:**
   - Analyzes user keywords (e.g., "fire", "bleeding", "suspicious", "evacuate") to provide verified Philippine civil defense procedures.
   - Automatically provides a one-tap `CALL 911 NOW` button inside the chat bubble when high-risk emergency terms are detected.
5. **Text Input & Audio Icon:**
   - Rounded text box with send arrow button and microphone placeholder icon.

---

### 3.10 Resident Navigation Drawer
*File:* [side_menu.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/incident_reporting/presentation/pages/side_menu.dart)

- **Drawer Header:** Shield logo with cyan glow, current app title `ResQ Citizen`, and resident email badge.
- **Navigation Tiles:**
  - `Dashboard` (Home icon -> `/dashboard`).
  - `Report Incident` (Camera alert icon -> `/report-incident`).
  - `Incident Map` (Location map pin icon -> `/maps`).
  - `My Submissions` (Clipboard checklist icon -> `/my-reports`).
  - `Emergency Hotlines` (Phone broadcast icon -> `/emergency-hotlines`).
  - `Settings & Profile` (Gear icon -> `/settings`).
- **Footer Tile:**
  - `Log Out` (Crimson exit door icon -> triggers logout dialog).

---

## 4. Admin Command Center Walkthrough

The Admin Command Center is an enterprise web/tablet-first portal intended for Barangay Moonwalk desk officers, Tanod supervisors, and municipal dispatchers.

### 4.1 Admin Authentication Gateway
*File:* [admin_login_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/admin_login_page.dart)  
*Route:* `/admin/login`

#### UI Components & Actions:
- **Visual Design:** Animated mesh gradient background with custom geometric grid lines, central glowing Admin Shield badge.
- **Access Credentials:**
  - Form validated for official admin email (`admin@safe.gov`) and password (`admin123`).
- **Security Check:** CAPTCHA verification placeholder badge.
- **Action:** `Enter Command Center` 3D Cyan Button. Emits loading sequence and redirects to `/admin/dashboard`.
- **Shortcut:** `Return to Citizen App` footer button.

---

### 4.2 Command Center Shell & Navigation
*Files:* [admin_panel_shell.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/admin_panel_shell.dart), [admin_sidebar.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/widgets/admin_sidebar.dart), [admin_header.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/widgets/admin_header.dart)  
*Route:* `/admin/dashboard`

#### Layout Structure:
- **Collapsible Sidebar (Desktop 270px width / Mobile Drawer):**
  - Toggle collapse button (`80px` compact icon-only mode for small screens).
  - 7 Administrative Modules:
    1. `Overview Dashboard` (Bar chart icon)
    2. `Incident Reports` (Alert triangle icon)
    3. `User Management` (Users group icon)
    4. `Area Management` (Map layers icon)
    5. `Incident Categories` (Folder grid icon)
    6. `Audit Logs` (Document shield icon)
    7. `Profile Settings` (User gear icon)
  - Bottom: `Logout` button with glowing red highlight.
- **Top Header Bar (`AdminHeader`):**
  - Left: Hamburger drawer toggle (on mobile/tablet) and current page breadcrumbs.
  - Center: Global administrative search input field.
  - Right:
    - Live System Status pill: `Opcen Dispatch Online` (Green dot).
    - Emergency Broadcast Alert button (Triggers municipality broadcast modal).
    - Notification bell with badge count.
    - Admin Profile Pill with avatar and `Barangay Captain / Officer` label.

---

### 4.3 Admin Overview Dashboard
*File:* [admin_dashboard_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart)

#### UI Cards & Analytics Widgets:
1. **4 KPI Metric Cards:**
   - *Total Incident Reports:* Cumulative reports received (with +12% weekly indicator).
   - *Active Monitoring Areas:* Count of active sectors (Moonwalk Areas 1–4).
   - *Solved / Closed Cases:* Total verified resolved incidents.
   - *Registered Citizens:* Total verified resident accounts in the barangay.
2. **Interactive Incident Analytics Graph (`CustomLineChart`):**
   - Displays weekly frequency curve (Monday through Sunday) comparing reported vs resolved incidents.
3. **Category Breakdown Chart (`CustomPieChart`):**
   - Proportional circular slice breakdown of incidents (Fire, Flood, Medical, Altercation, etc.).
4. **Recent Urgent Incidents Table:**
   - Displays the 5 latest incoming incidents with real-time urgency indicators.
   - Columns: `Incident ID`, `Category`, `Reported By`, `Location`, `Urgency`, `Status`, `Action`.
   - Action: `View Quick Details` button.

---

### 4.4 Incident Reports Management
*File:* [incident_reports_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/incident_reports_page.dart)

#### Interactive Features:
1. **Search & Filter Controls:**
   - Search input: Live filtering by Incident ID, Category, Reporter Name, or Street.
   - Category Filter dropdown (`All`, `Fire`, `Flood`, etc.).
   - Status Filter dropdown (`All`, `Pending`, `In Progress`, `Resolved`).
   - `Active Incidents` vs `Archived Incidents` toggle switch.
2. **Real-time Incident Data Table:**
   - Columns: `ID`, `Photo`, `Category`, `Reporter`, `Area / Address`, `Timestamp`, `Status`, `Actions`.
3. **Action Modals & Dialogs:**
   - **`View Details` Modal:**
     - High-resolution evidence photo viewer.
     - Full incident narrative and GPS coordinates.
     - Reverse-geocoded location map preview.
     - Citizen contact number with direct call action.
   - **`Edit Status` Modal Dialog:**
     - Radio group options: `Mark as Pending`, `Dispatch Units (In Progress)`, `Mark as Resolved`.
     - Official Dispatcher Notes text area.
     - `Save Status Update` button.
   - **`Mark as Spam / False Alarm` Quick Action:**
     - Flags report and downgrades user credibility score.
   - **`Export CSV / PDF Report` Button:**
     - Generates formatted municipal incident summary.

---

### 4.5 User Management & Access Control
*File:* [user_management_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/user_management_page.dart)

#### Features & Controls:
1. **Resident & Staff Data Table:**
   - Columns: `User ID`, `Avatar`, `Full Name`, `Email`, `Assigned Sector`, `Role`, `Account Status`, `Actions`.
2. **Filters & Search:**
   - Search by name, email, or contact number.
   - Filter by Role (`Citizen Reporter`, `Barangay Tanod`, `Desk Officer`, `Admin`).
   - `Show Archived Users` checkbox toggle.
3. **Interactive Modals:**
   - **`Edit User Role & Permissions` Dialog:**
     - Dropdown to promote or demote user permissions.
   - **`Deactivate / Suspend Account` Dialog:**
     - Sets account status to `Disabled` with customizable suspension duration.
   - **`Archive User Record` Confirmation:**
     - Soft-deletes user from active resident directory.

---

### 4.6 Area & Barangay Zone Management
*File:* [area_management_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/area_management_page.dart)

#### Features & Controls:
1. **Barangay Sectors Grid / Table:**
   - Lists Moonwalk sub-jurisdictions (e.g., `Area 1 - Daang Batang`, `Area 2 - Armstrong`, `Area 3 - San Agustin`, `Area 4 - Multinational`).
   - Displays active population, assigned Tanod patrol teams, and active incident count badge.
2. **Action Buttons & Modals:**
   - **`+ Add New Area / Zone` 3D Button:**
     - Modal: Area Name, Sector Code, Patrol Leader Name, Emergency Evacuation Center Address.
   - **`Edit Sector Details` Modal:**
     - Modify boundaries and contact hotlines.
   - **`Archive Zone` Dialog:**
     - Soft-archives sector when redistricting.

---

### 4.7 Incident Categories Management
*File:* [incident_categories_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/incident_categories_page.dart)

#### Features & Controls:
1. **Categories Card Grid:**
   - Visual cards showing category name, associated icon, default urgency rating, and total incidents logged under this category.
2. **Action Buttons & Modals:**
   - **`+ Add Category` 3D Button:**
     - Modal fields: Category Name, Icon Picker, Default Urgency (`LOW`, `MEDIUM`, `HIGH`), Evacuation Protocol Checklist.
   - **`Edit Category` Modal:**
     - Update safety checklist and response guidelines.
   - **`Archive Category` Action Dialog.**

---

### 4.8 Administrative Audit Logs
*File:* [admin_audit_logs_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/admin_audit_logs_page.dart)

#### Features & Controls:
1. **Immutable Audit Trail Table:**
   - Columns: `Timestamp`, `Admin Operator`, `Action Type Badge`, `Target Entity ID`, `IP Address / Terminal`, `Details`.
2. **Action Badges:**
   - `STATUS_CHANGE` (Blue)
   - `USER_SUSPENDED` (Red)
   - `CATEGORY_CREATED` (Green)
   - `EMERGENCY_BROADCAST` (Purple)
3. **Export & Filter:**
   - Date range picker (`From Date` - `To Date`).
   - `Download Audit Log (CSV)` button.

---

### 4.9 Admin Profile & Security Settings
*File:* [profile_settings_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/admin_dashboard/presentation/pages/profile_settings_page.dart)

#### Features & Controls:
- Display Name, Official Title, and Read-Only Login Email (`admin@safe.gov`).
- Simulated Avatar Upload with camera badge.
- `Change Password` Form: Current Password, New Password, Confirm Password.
- `Save Changes` 3D Button.
- `Logout Portal` Button.

---

## 5. Hardware & Diagnostic Test Harness
*File:* [test_sandbox_page.dart](file:///c:/YckoVon/Documents/capstone3/clean_folder/lib/features/test_sandbox_page.dart)

A standalone developer and QA sandbox for verifying real device hardware APIs:
1. **Location GPS Test Harness:**
   - Button: `Get Current GPS Coordinates`.
   - Invokes `LocationServiceImpl.getCurrentLocation()` and displays raw Latitude, Longitude, Accuracy, and Reverse-Geocoded Address.
2. **Camera Hardware Test Harness:**
   - Button: `Capture Photo via Camera`.
   - Button: `Select Image from Gallery`.
   - Renders selected image file with byte size verification.

---

## 6. Comprehensive Interactive UI Matrix

| Page / Component | Element Name | Type | Action / Trigger | Target / Outcome |
| :--- | :--- | :--- | :--- | :--- |
| **Welcome Page** | `Log In` Header | Outlined Button | Tap | Navigates to `/login` |
| **Welcome Page** | `Sign Up` Header | Outlined Button | Tap | Navigates to `/sign-up` |
| **Welcome Page** | `Report an Incident` | Custom3dButton | Tap | Checks auth -> `/report-incident` or Guest modal |
| **Welcome Page** | `Emergency Hotlines` | Custom3dButton | Tap | Navigates to `/emergency-hotlines` |
| **Welcome Page** | `Access Admin Portal` | Text Button | Tap | Navigates to `/admin/login` |
| **Login Page** | Email Input | Custom3dTextField | Text Entry | Validates email format |
| **Login Page** | Password Input | Custom3dTextField | Text Entry | Obfuscated input with Eye toggle |
| **Login Page** | Remember Me | Checkbox | Toggle | Persists auth token in Hive box |
| **Login Page** | `Log In` Button | Custom3dButton | Tap | Emits `LoginWithEmailSubmitted` to `AuthBloc` |
| **Login Page** | Social Icons (3x) | Icon Buttons | Tap | Launches Google, Facebook, Apple Auth |
| **Sign-Up Page** | Form Fields (4x) | Custom3dTextField | Text Entry | Name, Email, Complex Password, Confirm |
| **Sign-Up Page** | Terms Checkbox | Custom Checkbox | Toggle | Enables `Create Resident Account` button |
| **Sign-Up Page** | `Create Account` | Custom3dButton | Tap | Emits `SignUpSubmitted` to `AuthBloc` |
| **Dashboard** | Hamburger Menu | Icon Button | Tap | Opens `SideMenu` navigation drawer |
| **Dashboard** | Notification Bell | Icon Button | Tap | Opens Notifications bottom sheet modal |
| **Dashboard** | User Avatar | Tap Target | Tap | Navigates to `/settings` |
| **Dashboard** | Safe Zones Button | Text 3D Button | Tap | Highlights evacuation centers on Map |
| **Dashboard** | Video Play Button | Pulsing Icon | Tap | Opens Moonwalk safety video modal |
| **Dashboard** | `Report Incident` | Custom3dButton | Tap | Navigates to `/report-incident` |
| **Dashboard** | Incident Card | Custom3dCard | Tap | Opens `IncidentDetailPage` |
| **Report Page** | Reporter Selector | Dropdown | Select | Toggles Verified vs Anonymous report |
| **Report Page** | Sector Selector | Dropdown | Select | Selects Moonwalk Area 1 to 4 |
| **Report Page** | `Pin Device Location` | Button | Tap | Fetches device's real-time GPS coordinates & street address |
| **Report Page** | Category Selector | Dropdown | Select | Chooses from 10 emergency categories |
| **Report Page** | `Take Photo` | 3D Button | Tap | Launches native camera |
| **Report Page** | `Select Gallery` | 3D Button | Tap | Launches system image picker |
| **Report Page** | Image Delete `X` | Floating Icon | Tap | Clears selected image preview |
| **Report Page** | `Call 911` Card | Crimson Button | Tap | Triggers 911 phone dialer modal |
| **Report Page** | `Call Desk` Card | Crimson Button | Tap | Triggers Moonwalk Desk phone dialer |
| **Report Page** | ResQ Logo (AppBar) | Hidden Gesture | 5 Taps in 2s | Activates Gemini AI Triage feature |
| **Report Page** | `Submit Report` | Custom3dButton | Tap | Saves report -> Shows Safety Action Kit |
| **Maps Page** | Incident Map Pin | Marker | Tap | Opens `IncidentTrackingSheet` bottom modal |
| **Maps Page** | `Me Too / Affected` | 3D Button | Tap | Increments incident verification counter |
| **Maps Page** | Search Field | Custom3dTextField | Text Entry | Geocodes and pans camera to landmark |
| **Maps Page** | Filter Action Chip | Chip Button | Tap | Toggles category visibility |
| **Maps Page** | Zoom In / Out | Icon Buttons | Tap | Increments/decrements map zoom level |
| **Maps Page** | Locate Me | Floating Button | Tap | Re-centers camera on current GPS location |
| **My Reports** | Status Filter Chips | Choice Chips | Tap | Filters list by All, Pending, Active, Solved |
| **My Reports** | List Pull-to-refresh | Pull Gesture | Drag down | Refreshes incident list from Firestore |
| **My Reports** | Report Tile | Custom3dCard | Tap | Navigates to `IncidentDetailPage` |
| **Detail Page** | Evidence Thumbnail | Image Widget | Tap | Opens full-screen zoomable lightbox |
| **Detail Page** | Timeline Nodes | Timeline Widget | View | Displays 3-step reactive progress states |
| **Hotlines Page** | 911 Call Button | Crimson Button | Tap | Launches phone intent to `911` |
| **Hotlines Page** | Fire 112 Button | Crimson Button | Tap | Launches phone intent to Moonwalk Fire |
| **Hotlines Page** | Ambulance 143 | Crimson Button | Tap | Launches phone intent to Red Cross |
| **Hotlines Page** | Barangay Opcen | Crimson Button | Tap | Launches phone intent to Moonwalk Opcen |
| **Settings Page** | `Edit Profile` | Outlined Button | Tap | Navigates to `EditProfilePage` |
| **Settings Page** | Emergency Buttons | Grid Buttons (4x) | Tap | Immediate dialer access |
| **Settings Page** | Notification Switch | CupertinoSwitch | Toggle | Enables/disables push alert banners |
| **Settings Page** | Dark Mode Switch | CupertinoSwitch | Toggle | Enforces high-contrast OLED dark theme |
| **Settings Page** | Offline Sync Switch | CupertinoSwitch | Toggle | Toggles background Hive cache syncing |
| **Settings Page** | About App Tile | List Tile | Tap | Opens Version & LGU credits sheet modal |
| **Settings Page** | Help Desk Tile | List Tile | Tap | Opens Moonwalk Desk contact sheet modal |
| **Settings Page** | Bug Report Tile | List Tile | Tap | Opens Bug/Feedback text entry modal |
| **Settings Page** | `Log Out` Tile | List Tile | Tap | Confirms and logs out resident |
| **Settings Page** | `Delete Account` | Crimson Tile | Tap | 2-step account deletion warning modal |
| **Edit Profile** | Avatar Edit Icon | Circle Icon | Tap | Uploads new resident profile photo |
| **Edit Profile** | `Save Changes` | Custom3dButton | Tap | Updates resident profile record |
| **Privacy Page** | Password Update | List Tile | Tap | Opens Current/New/Confirm password modal |
| **Privacy Page** | Biometrics Switch | CupertinoSwitch | Toggle | Enables FaceID / Fingerprint gateway |
| **Chatbot** | Floating Robot FAB | FAB Button | Tap | Expands/collapses 340x520 glass window |
| **Chatbot** | Suggestion Chips | Action Chips (4x) | Tap | Auto-sends pre-built emergency questions |
| **Chatbot** | Reset / Clear Icon | Icon Button | Tap | Clears chat history back to greeting |
| **Chatbot** | Emergency Call Pill | Crimson Button | Tap | In-chat shortcut calling 911 |
| **Side Menu** | Route Tiles (6x) | List Tiles | Tap | Direct drawer navigation to core pages |
| **Admin Login** | Email & Password | Text Fields | Text Entry | Authenticates `admin@safe.gov` / `admin123` |
| **Admin Login** | `Enter Portal` | Custom3dButton | Tap | Validates credentials -> `/admin/dashboard` |
| **Admin Shell** | Sidebar Toggle | Icon Button | Tap | Toggles 270px full vs 80px compact sidebar |
| **Admin Shell** | Nav Items (7x) | List Tiles | Tap | Switches active admin module view |
| **Admin Shell** | Broadcast Alert | Neon Button | Tap | Opens municipality push siren modal |
| **Admin Reports** | Search Field | Search Bar | Text Entry | Live filtering of incident data table |
| **Admin Reports** | Status Dropdown | Dropdown | Select | Filters by All, Pending, In Progress, Solved |
| **Admin Reports** | Archive Switch | Switch | Toggle | Toggles active vs archived incident records |
| **Admin Reports** | `View Details` | Icon Button | Tap | Opens comprehensive incident detail modal |
| **Admin Reports** | `Edit Status` | Icon Button | Tap | Opens Status Update & Notes radio dialog |
| **Admin Reports** | `Mark Spam` | Icon Button | Tap | Flags report as false alarm |
| **Admin Users** | Role Editor | Action Button | Tap | Opens User Role & Permissions modal |
| **Admin Users** | Suspend User | Action Button | Tap | Sets account status to `Disabled` |
| **Admin Areas** | `+ Add Area` | Custom3dButton | Tap | Opens Add Zone / Sector modal dialog |
| **Admin Categories**| `+ Add Category`| Custom3dButton | Tap | Opens Add Category & Protocol modal |
| **Admin Audit** | Date Range Picker | Date Selector | Tap | Filters logs by start and end timestamps |
| **Admin Audit** | `Download CSV` | Outlined Button | Tap | Exports immutable audit log to CSV file |

---

## 7. Data Architecture, AI Integration, & Offline Resilience

### 7.1 Firestore Schema

#### Collection: `incidents`
```json
{
  "id": "STRING (UUID / Auto-generated)",
  "category": "STRING (e.g., 'Fire Outbreak', 'Flood / Rising Water')",
  "description": "STRING (Full resident narrative)",
  "latitude": 14.4851,
  "longitude": 121.0116,
  "address": "STRING (Reverse geocoded street name)",
  "areaSector": "STRING (e.g., 'Area 2 - Phase 2 / Armstrong')",
  "photoUrl": "STRING (Firebase Storage HTTPS download URL)",
  "status": "STRING ('Pending' | 'In Progress' | 'Resolved')",
  "urgency": "STRING ('LOW' | 'MEDIUM' | 'HIGH')",
  "isAnonymous": false,
  "reportedBy": "STRING (User ID or 'Anonymous Citizen')",
  "dispatcherNotes": "STRING (Official resolution notes)",
  "affectedCount": 14,
  "timestamp": "TIMESTAMP"
}
```

### 7.2 Hive Offline Local Storage
- **Box `incidents`:** Implements offline-first caching via `Box<IncidentModel>`.
  - When reports are created while offline, they are appended locally.
  - The reactive stream emits cached records immediately, and synchronizes with Firestore once the internet connection is re-established.
- **Box `auth`:** Preserves resident session tokens and `Remember Me` preferences.

### 7.3 Google Gemini 1.5 Flash AI Integration
- **Endpoint:** REST call to Gemini 1.5 Flash API endpoint via `http.Client`.
- **Payload:**
  - Strict JSON schema enforcement:
    ```json
    {
      "urgency": "LOW | MEDIUM | HIGH",
      "threats": ["list of detected hazards"],
      "recommended_actions": ["immediate instructions for dispatcher"]
    }
    ```
- **Trigger:** Accessible via the 5-tap gesture on the ResQ logo in `ReportIncidentPage`.

---

## 8. Backend Integration Readiness & Next Steps

Based on the [backend_readiness_report.md](file:///c:/YckoVon/Documents/capstone3/clean_folder/backend_readiness_report.md) audit:

| Module / Service | Current State | Production Path |
| :--- | :--- | :--- |
| **Incident Reporting & Stream** | ✅ Live Firestore + Hive Cache | Fully wired to `IncidentBloc` and Firebase. |
| **Geolocation & Geocoding** | ✅ Live Geolocator | Operational device GPS and reverse geocoding. |
| **Camera & Image Storage** | ✅ Live Camera / Storage | Camera hardware capture with Firebase Storage upload. |
| **Gemini AI Triage** | ✅ Live Remote API | Operational REST call to Gemini 1.5 Flash. |
| **Resident Authentication** | ⚠️ Mock Repository | Switch `AuthRepositoryImpl` from simulated delay to `FirebaseAuth`. |
| **Admin Command Center** | ⚠️ Local Widget State | Wire Admin tables and dialogs to `IncidentBloc` and Admin User BLoC. |

---

*This guide provides a comprehensive specification of the ResQ application within `clean_folder`. Use this document across subsequent agent sessions to guide feature extensions, backend wiring, automated testing, and UI enhancements.*
