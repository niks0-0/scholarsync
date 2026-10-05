# 📘 SCHOLARSYNC — COMPLETE SYSTEM STATE, ARCHITECTURE & ROADMAP

> **Comprehensive Status Report & Technical Blueprint**  
> **Repository:** `https://github.com/niks0-0/scholarsync.git` (Branch: `master`)  
> **System Health:** 0 Analyzer Issues (`flutter analyze`), 82/82 Tests Passing (`flutter test`)  
> **Last Synced Commit:** `f206a83`  

---

## 📑 TABLE OF CONTENTS
1. [Executive Overview & Platform Philosophy](#1-executive-overview--platform-philosophy)
2. [Completed Work & Feature Inventory](#2-completed-work--feature-inventory)
3. [Architecture, Directory Structure & State Management](#3-architecture-directory-structure--state-management)
4. [Database Schema & Stored Procedures (Supabase & Firebase)](#4-database-schema--stored-procedures-supabase--firebase)
5. [Core Business Logics & Mathematical Formulations](#5-core-business-logics--mathematical-formulations)
6. [Existing Mock & Live Data Inventory](#6-existing-mock--live-data-inventory)
7. [Next Planning & Roadmap: Perfect Timetable & Attendance Integration](#7-next-planning--roadmap-perfect-timetable--attendance-integration)

---

## 1. EXECUTIVE OVERVIEW & PLATFORM PHILOSOPHY

### 🎯 What is ScholarSync?
ScholarSync is an enterprise-grade academic companion and student management ecosystem built specifically for engineering and computer applications students (MCA, B.Tech, CS, IT). It centralizes:
- **Curriculum & Academic Catalog**: Subjects, syllabus, credits, and faculty directory.
- **Weekly Timetable Engine**: Dynamic day-by-day lecture scheduler and status tracker.
- **Attendance & Safe Bunk Analytics**: Mathematical bunk forecasting and daily class attendance logs.
- **Academic Calendar**: University exam dates, holidays, and semester milestones.
- **Personalized Modular Dashboard**: Customizable dashboard cards and widgets.
- **Community, Notes & Marketplace**: Peer-to-peer study notes, campus marketplace, and clubs.
- **Master Admin Mission Control**: 35-module platform administration system.

### 👑 App Owner / Master DBA Model
- **Zero Administrative Bottleneck**: The app does not depend on university IT approval.
- **Platform DBA**: The app owner has total autonomy over curriculum data, colleges, and content moderation via the built-in Master Admin Platform.
- **Deterministic Offline-First Logic**: Algorithms for safe bunks, schedule status, and greetings run deterministically on-device without third-party API dependencies.

---

## 2. COMPLETED WORK & FEATURE INVENTORY

### ✅ 1. Authentication & Security Layer (`lib/features/auth`)
- **Dual Engine Auth**: Firebase Authentication integrated with Supabase `public.profiles`.
- **Google Sign-In & Email/Password**: Full onboarding, sign-in, registration, and password recovery.
- **Guest Access**: Immediate exploration with restricted write permissions.
- **Master Admin 1-Tap Quick Fill**: One-tap pre-fill on login screen (`admin@scholarsync.com` / `Admin@123456`) for platform owner access.
- **Session & Role Persistence**: Cached user state, auth token refresh, and role verification (`student`, `admin`, `super_admin`).

### ✅ 2. 7-Step Student Onboarding Wizard (`lib/features/onboarding`)
- **Step 1: Welcome**: Value proposition, feature highlights, and animated banners.
- **Step 2: Profile Setup**: Full name, username handle, avatar selection with live preview.
- **Step 3: College Selection**: Searchable college picker with University Classification Badges (`Tier 1 / Autonomous / Central / State University`).
- **Step 4: Academic Details**: Degree program (MCA, B.Tech, etc.), branch, current semester (1–8), division/section, and roll number.
- **Step 5: Preferences**: Attendance cutoff goal (default 75%), notification preferences, theme selection.
- **Step 6: Legal Verification**: Terms of Service and Privacy Policy consent.
- **Step 7: Completion & Launch**: Summary review card and transition into the Main App Shell.

### ✅ 3. Core App Shell & Dynamic Routing (`lib/core/routing`, `lib/features/shell`)
- **Declarative Navigation**: Built on `go_router 14.x`.
- **Persistent Bottom Navigation Shell**: Home / Dashboard, Academic Catalog, Timetable, Attendance, and Calendar.
- **RBAC Gatekeeper**: Automatic redirects:
  - Unauthenticated users -> `/welcome` or `/login`.
  - Non-onboarded users -> `/onboarding`.
  - Authenticated students -> `/home` (access to `/admin` blocked).
  - Authenticated admins -> `/admin` (with instant toggle to Student View).
  - Suspended users -> Locked screen with reason.

### ✅ 4. Student Modular Dashboard (`lib/features/dashboard`)
- **10 Independent Modular Summary Widgets**:
  1. Quick Greeting & Academic Status Banner
  2. Quick Actions Grid (1-tap shortcuts)
  3. Today's Schedule Card (with live ongoing/upcoming class countdown)
  4. Attendance Overview Card (overall percentage & danger alert)
  5. Upcoming Assignments Tile
  6. Recent Campus Announcements
  7. Academic Calendar Events Snippet
  8. Study Notes Quick Access
  9. Campus Clubs & Events Banner
  10. Marketplace Highlights
- **Personalization Engine (`DashboardPersonalizationProvider`)**:
  - Reordering, pinning tiles to top, hiding unwanted tiles, and 1-tap reset to defaults.
  - Persistent layout preferences in `SharedPreferences`.

### ✅ 5. Academic Catalog (`lib/features/academic_catalog`)
- Branch and semester-based subject registry.
- Theory vs. Practical vs. Tutorial classification, credits, and faculty attribution.
- Syllabus outline and subject detail modal sheets.

### ✅ 6. Personal Timetable (`lib/features/timetable`)
- Weekly schedule view (Monday through Sunday) with interactive day chips.
- Real-time lecture status badges: `Ongoing`, `Upcoming`, `Completed`.
- Class cards displaying Subject, Room, Building, Faculty, and Time range.
- `AddEditClassSheet` for creating/updating individual periods.
- `ClassDetailModal` with quick actions (reschedule, notes, reminders).

### ✅ 7. Attendance Tracker & Smart Bunk Calculator (`lib/features/attendance`)
- Subject-by-subject attendance progress bars.
- Overall attendance metric and danger/safe badges.
- **Safe Bunk Calculator Modal**: Displays exact classes safe to bunk without breaching 75%.
- **Attendance Recovery Calculator**: Shows required consecutive classes to escape risk.
- **Smart Insights Sheet**: Contextual warnings on high-risk subjects.

### ✅ 8. Academic Calendar (`lib/features/calendar`)
- Monthly and day-timeline views.
- Color-coded categories: Examinations, Holidays, Semester Dates, Campus Festivals.
- Date filters and add personal event bottom sheet.

### ✅ 9. Master Admin Platform (Mission Control) (`lib/features/admin`)
- **Executive Mission Control Dashboard** with live database pulse, 6 KPI cards, branch analytics.
- **13+ Dedicated Operational Studios**:
  - Curriculum & Subject Studio
  - Supported College Registry
  - Notes Moderation Studio (Approve/Reject PDF/DOCX)
  - Unified Moderation Center (Warn, Suspend, Purge)
  - Realtime Chat & Channel Inspector
  - Academic Calendar & Exam Scheduler
  - Campus Events & Hackathon Approvals
  - Marketplace Listing Oversight
  - Clubs & Societies Directory
  - Community Forum Moderation
  - Push Broadcast Notification Engine
  - Student Directory & Role Delegation Studio

---

## 3. ARCHITECTURE, DIRECTORY STRUCTURE & STATE MANAGEMENT

### 🏗️ Clean Architecture Layout
```
lib/
├── core/                                  # Cross-cutting foundational layer
│   ├── config/                            # App config provider & remote parameters
│   ├── constants/                         # Spacing, typography, assets, strings
│   ├── routing/                           # AppRouter, AppRoutes, guards & redirects
│   ├── services/                          # Supabase, Firebase, Preferences, ImagePicker
│   ├── theme/                             # AMOLED Onyx Luxury Theme (AppColors, AppTheme)
│   └── utils/                             # Validators, DateUtils, Math helpers
│
├── features/                              # Feature Modules (Domain-Driven Clean Architecture)
│   ├── academic_catalog/                  # Subjects directory & course syllabus
│   │   ├── data/repositories/
│   │   ├── domain/models/
│   │   └── presentation/
│   ├── admin/                             # Master Admin Platform (35 modules / 13 screens)
│   │   ├── data/repositories/
│   │   ├── domain/models/
│   │   └── presentation/screens/
│   ├── attendance/                        # Attendance tracker & bunk calculator
│   │   ├── data/repositories/
│   │   ├── domain/models/
│   │   └── presentation/
│   ├── auth/                              # Authentication & identity management
│   │   ├── data/services/
│   │   └── presentation/screens/
│   ├── calendar/                          # Academic calendar & personal events
│   ├── dashboard/                         # Modular student dashboard
│   ├── notifications/                     # FCM push alerts & notification history
│   ├── onboarding/                        # 7-step student onboarding wizard
│   ├── profile/                           # User profile, college & academic info
│   ├── search/                            # Universal multi-entity search engine
│   ├── shell/                             # Persistent navigation scaffold
│   └── timetable/                         # Timetable engine & period scheduler
│
└── main.dart                              # Multi-provider initialization & app boot
```

### ⚡ State Management Graph
All providers extend `ChangeNotifier` and are wired at the root in `main.dart`:
- `AuthProvider`: Firebase Auth + Supabase user session bridge.
- `ProfileProvider`: Student personal & academic details.
- `OnboardingProvider`: Onboarding wizard navigation and validation state.
- `AppConfigProvider`: System configuration, feature flags, maintenance mode.
- `DashboardPersonalizationProvider`: Dashboard tile order, pinned and hidden sets.
- `DashboardProvider`: Aggregate data fetcher for home summary cards.
- `TimetableProvider`: Weekly schedule, day filter, search query, period operations.
- `AttendanceProvider`: Subject attendance list, marks, safe-bunk numbers.
- `AcademicCatalogProvider`: Course subjects, filters by branch/semester.
- `CalendarProvider`: Events, filters by category and date.
- `NotificationProvider`: Unread badge count, notifications stream.
- `AdminProvider`: Master analytics, pending queues, moderation actions.

---

## 4. DATABASE SCHEMA & STORED PROCEDURES (SUPABASE & FIREBASE)

### 🗄️ Supabase PostgreSQL 17 Tables

| Table Name | Primary Key | Description & Key Fields |
| :--- | :--- | :--- |
| `public.profiles` | `id` (TEXT) | Auth UID, `email`, `full_name`, `role`, `college_id`, `branch`, `semester`, `division`, `roll_number`, `avatar_url`, `is_suspended` |
| `public.colleges` | `id` (UUID) | `name`, `code`, `classification` (Tier-1, Autonomous, etc.), `city`, `state` |
| `public.departments` | `id` (UUID) | `name`, `code`, `college_id` |
| `public.subjects` | `id` (UUID) | `subject_code`, `subject_name`, `short_name`, `branch`, `semester`, `credits`, `faculty_name`, `is_elective` |
| `public.timetable_entries` | `id` (UUID) | `user_id`, `subject_id`, `weekday` (1–7), `start_time` (HH:mm), `end_time` (HH:mm), `room`, `building`, `faculty_name`, `mode`, `class_type`, `is_active` |
| `public.attendance_records` | `id` (UUID) | `user_id`, `subject_id`, `attended_classes`, `total_classes`, `last_updated` |
| `public.academic_calendar` | `id` (UUID) | `title`, `event_type` (`exam`, `holiday`, `semester_start`), `start_date`, `end_date`, `target_branch` |
| `public.notes` | `id` (UUID) | `title`, `description`, `subject_id`, `uploader_id`, `file_url`, `status` (`pending`, `approved`, `rejected`) |
| `public.moderation_reports` | `id` (UUID) | `reporter_id`, `reported_user_id`, `entity_type`, `entity_id`, `reason`, `priority`, `status`, `resolution_action` |
| `public.announcements` | `id` (UUID) | `title`, `content`, `created_by`, `is_urgent`, `target_branch`, `target_semester` |
| `public.chat_rooms` | `id` (UUID) | `name`, `type` (`subject`, `batch`, `club`), `subject_id`, `is_archived` |
| `public.messages` | `id` (UUID) | `room_id`, `sender_id`, `content`, `attachment_url`, `is_deleted` |
| `public.marketplace_listings` | `id` (UUID) | `seller_id`, `title`, `price`, `category`, `status` (`active`, `sold`) |
| `public.clubs` | `id` (UUID) | `name`, `description`, `category`, `member_count`, `status` |
| `public.audit_logs` | `id` (UUID) | `admin_id`, `action`, `target_type`, `target_id`, `created_at` |

---

## 5. CORE BUSINESS LOGICS & MATHEMATICAL FORMULATIONS

### 🧮 1. Attendance Percentage Formula
$$\text{Percentage} = \begin{cases} 100.0 & \text{if } \text{Total} = 0 \\ \left( \frac{\text{Attended}}{\text{Total}} \right) \times 100 & \text{if } \text{Total} > 0 \end{cases}$$

### 🛡️ 2. Safe Bunk Calculator (Classes Safe to Miss)
To remain at or above the required threshold $T = 0.75$ (75%):
$$\frac{\text{Attended}}{\text{Total} + B} \ge 0.75 \implies B \le \frac{\text{Attended} - (0.75 \times \text{Total})}{0.75}$$
$$\text{Safe Bunks} = \max\left(0, \, \left\lfloor \frac{\text{Attended} - (0.75 \times \text{Total})}{0.75} \right\rfloor\right)$$

### 🚨 3. Attendance Recovery Formula (Classes Needed to Recover 75%)
When $\text{Percentage} < 75\%$, how many consecutive classes $C$ must be attended:
$$\frac{\text{Attended} + C}{\text{Total} + C} \ge 0.75 \implies C \ge \frac{0.75 \times \text{Total} - \text{Attended}}{0.25} = 3 \times \text{Total} - 4 \times \text{Attended}$$
$$\text{Classes Needed} = \max\left(0, \, \lceil 3 \times \text{Total} - 4 \times \text{Attended} \rceil\right)$$

### ⏰ 4. Real-Time Period Status Calculation
Given slot start time $T_{\text{start}}$ and end time $T_{\text{end}}$ in format `HH:mm`:
$$M_{\text{now}} = \text{hour}_{\text{now}} \times 60 + \text{minute}_{\text{now}}$$
$$M_{\text{start}} = H_{\text{start}} \times 60 + M_{\text{start}}, \quad M_{\text{end}} = H_{\text{end}} \times 60 + M_{\text{end}}$$
- If $\text{weekday}_{\text{now}} \ne \text{weekday}_{\text{entry}}$:
  - If $\text{weekday}_{\text{now}} > \text{weekday}_{\text{entry}} \implies \text{Completed}$
  - Else $\implies \text{Upcoming}$
- If $\text{weekday}_{\text{now}} = \text{weekday}_{\text{entry}}$:
  - If $M_{\text{now}} < M_{\text{start}} \implies \text{Upcoming}$
  - Else if $M_{\text{start}} \le M_{\text{now}} \le M_{\text{end}} \implies \text{Ongoing / Current}$
  - Else $\implies \text{Completed}$

### ☀️ 5. Dynamic Dashboard Greeting Logic
- $05:00 \le \text{Hour} < 12:00 \implies$ `"Good morning"`
- $12:00 \le \text{Hour} < 17:00 \implies$ `"Good afternoon"`
- Else $\implies$ `"Good evening"`

---

## 6. EXISTING MOCK & LIVE DATA INVENTORY

1. **Preloaded Colleges**:
   - `MIT World Peace University (MIT-WPU)` (Code: `MIT-WPU`, Tier 1 / Autonomous)
   - `College of Engineering Pune (COEP)` (Code: `COEP`, Autonomous State University)
   - `Pune Institute of Computer Technology (PICT)` (Code: `PICT`, Affiliated)
   - `Vishwakarma Institute of Technology (VIT)` (Code: `VIT`, Autonomous)
2. **Preloaded Academic Subjects**:
   - MCA Semester 4:
     - `CS401`: Design and Analysis of Algorithms (Theory + Lab, 4 credits)
     - `CS402`: Cloud Computing & DevOps (Theory + Lab, 4 credits)
     - `CS403`: Machine Learning & Pattern Recognition (Theory, 3 credits)
     - `CS404`: Full Stack Web Engineering (Theory + Lab, 4 credits)
     - `CS405`: Cyber Security & Ethical Hacking (Theory, 3 credits)
3. **Timetable Slots**:
   - Monday to Friday 09:00 – 16:30 schedule slots pre-populated in `MockTimetableRepository`.
4. **Attendance Trackers**:
   - Default subjects registered with attended / total ratios (e.g. 18/20 = 90%, 14/20 = 70% danger state).

---

## 7. NEXT PLANNING & ROADMAP: PERFECT TIMETABLE & ATTENDANCE INTEGRATION

### 🎯 Primary Objective
Transform the Timetable into the **active operational backbone** of ScholarSync, seamlessly driving:
1. Daily Attendance Tracking
2. "Mark All for Today" rapid attendance logging
3. Transparent adjustments (Proxy, Cancelled, Altered/Extra classes)
4. Dynamic Bunk Simulator projections

```
┌─────────────────────────────────────────────────────────────┐
│                      TIMETABLE HUB                          │
│   ┌───────────────────────────┐ ┌───────────────────────┐   │
│   │ 1. Manual Day Scheduler   │ │ 2. Upload Wizard      │   │
│   │    (Day-by-Day Mon-Sun)   │ │    (Image/PDF Parser) │   │
│   └─────────────┬─────────────┘ └───────────┬───────────┘   │
└─────────────────┼───────────────────────────┼───────────────┘
                  │                           │
                  ▼                           ▼
┌─────────────────────────────────────────────────────────────┐
│                 MASTER TIMETABLE ENGINE                     │
│        (Subject, Slot, Room, Faculty, Weekday, Type)        │
└──────────────────────────────┬──────────────────────────────┘
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
┌───────────────────────────────┐   ┌─────────────────────────┐
│     ATTENDANCE SERVICE        │   │     BUNK SIMULATOR      │
│ • Daily Timetable Stream      │   │ • Calculates safe bunks │
│ • 1-Tap "Mark All Present"    │   │   based on scheduled    │
│ • Cancel Class (No penalty)   │   │   future sessions       │
│ • Proxy Class (Credits proxy) │   │ • Accurate threshold    │
│ • Alter/Extra Class on the fly│   │   risk forecasting      │
│ • Full Verifiable Audit Log   │   │                         │
└───────────────────────────────┘   └─────────────────────────┘
```

### 📋 Feature-by-Feature Implementation Plan

#### 1. Timetable Setup Engine
- **Manual Day-by-Day Entry**:
  - Intuitive weekly grid (Mon–Sat/Sun).
  - Slot builder with start/end time pickers, subject selector (with quick "+ New Subject" creation), room/hall, and faculty name.
  - Multi-class batch copy (e.g., duplicate Mon schedule to Wed).
- **Upload Timetable Mode**:
  - Image picker (`image_picker`) to select a photo of the printed or digital timetable.
  - **Editable Preview Staging Sheet**: Displays extracted/pre-filled slots so the student can review, edit any mistakes, and tap **"Confirm & Import Timetable"** in one transaction.

#### 2. Timetable-Driven Attendance Service
- **Today's Dynamic Lecture Stream**:
  - Attendance screen features a **"Today's Schedule"** card populated directly from the student's timetable for the current weekday.
- **"Mark All for Today"**:
  - 1-tap confirmation marking all scheduled classes today as **Present**.
  - Individual class toggles (**Present**, **Absent**).
- **Transparent Daily Overrides (Date-Specific)**:
  - **🚫 Cancel Lecture**: If professor is on leave, student marks it "Cancelled".
    - *Impact:* Class count does not increment in the denominator. Attendance percentage is not penalized!
  - **🔄 Proxy / Substitute Lecture**: Another professor or subject took this hour.
    - *Impact:* Attendance is credited to the substitute subject, leaving the scheduled subject unaffected.
  - **➕ Extra / Altered Lecture**: An extra lecture was scheduled today.
    - *Impact:* Adds an extra slot to today's date and updates the subject tracker accordingly.
- **Complete Attendance Transparency Log**:
  - An audit history sheet showing each date, the class attended/missed/proxied/cancelled, so the student knows with 100% certainty why their attendance is at that exact percentage.

#### 3. Bunk Simulator Alignment
- Feeds off the timetable's actual remaining classes in the week/month.
- Tells the student: *"If you skip tomorrow's 2 lectures of Cloud Computing, your attendance will drop from 78.5% to 74.1% (Risk Alert)."*

---
*Generated & Verified: 2026-10-05*  
*ScholarSync Core Architecture Team*
