# 🎓 SCHOLARSYNC — MASTER DEVELOPER & ARCHITECTURE HANDBOOK
> **Confidential & Proprietary** — Complete Platform Blueprint, Engineering Logic, Data Models, and Developer Onboarding Guide for ScholarSync.

---

## 📑 TABLE OF CONTENTS
1. [Executive Vision & Core Philosophy](#1-executive-vision--core-philosophy)
2. [Master Credentials & Quick Login](#2-master-credentials--quick-login)
3. [Technology Stack & Architectural Paradigm](#3-technology-stack--architectural-paradigm)
4. [Folder Structure & Clean Architecture Layers](#4-folder-structure--clean-architecture-layers)
5. [Database Architecture & PostgreSQL Schema (Supabase)](#5-database-architecture--postgresql-schema-supabase)
6. [Security, Auth & Role-Based Access Control (RBAC)](#6-security-auth--role-based-access-control-rbac)
7. [The 35-Module Admin Platform Specification](#7-the-35-module-admin-platform-specification)
8. [Module-by-Module Logic & Implementation Breakdown](#8-module-by-module-logic--implementation-breakdown)
9. [Smart Algorithms (Zero-Third-Party AI Logic)](#9-smart-algorithms-zero-third-party-ai-logic)
10. [Design System & AMOLED Luxury Theme](#10-design-system--amoled-luxury-theme)
11. [Setup, Execution & Testing Handbook](#11-setup-execution--testing-handbook)

---

## 1. EXECUTIVE VISION & CORE PHILOSOPHY

### 🎯 What is ScholarSync?
ScholarSync is an enterprise-grade, all-in-one student ecosystem and academic management platform tailored for MCA, Computer Science, and Engineering students. It centralizes curriculum tracking, timetable automation, attendance safe-bunk calculation, study notes peer-review, community doubt-solving, campus clubs, hackathons, and a student-to-student marketplace.

### 👑 The "Pure App Owner / Master DBA" Philosophy
* **Zero College-Admin Bottleneck**: Traditional academic ERPs require college administration approval, college logins, and bureaucracy. ScholarSync bypasses this completely.
* **App Owner (You) as Platform DBA**: You are the master administrator. Colleges are simply onboarding tags that students select.
* **Admin-First Engineering Strategy**: Everything that exists in the Student App is first architected, managed, provisioned, moderated, and verified inside the **Master Admin Platform** before being distributed to student interfaces.

---

## 2. MASTER CREDENTIALS & QUICK LOGIN

To access the Mission Control Admin Platform without needing Google Sign-In:

| Parameter | Value |
| :--- | :--- |
| **Admin Email** | `admin@scholarsync.com` |
| **Admin Password** | `Admin@123456` |
| **Firebase Auth UID** | `SQJRGQZkujOAIfFEetfaqPqtHbL2` |
| **Supabase Role** | `admin` / `super_admin` (`onboarding_completed: true`) |
| **1-Tap Quick Fill** | Available directly above the email field on the Login Screen (`⚡ Fill App Owner Admin`) |

---

## 3. TECHNOLOGY STACK & ARCHITECTURAL PARADIGM

* **Client Framework**: Flutter (Dart 3.x) with multi-platform support (Android, iOS, Web, Windows/macOS/Linux).
* **State Management**: Provider (`ChangeNotifier`) with atomic state notifications.
* **Routing & Guards**: `go_router` with declarative route hierarchies, redirection logic, and RBAC gatekeepers.
* **Cloud Database & Storage**: Supabase (PostgreSQL 17 on `ap-south-1`) with Row-Level Security (RLS) policies and Storage Buckets.
* **Authentication**: Hybrid architecture using Firebase Auth for token generation synced seamlessly to Supabase `public.profiles`.
* **Testing**: Comprehensive Flutter unit, widget, and state test suite (**54 / 54 tests passing, 100% pass rate**).

---

## 4. FOLDER STRUCTURE & CLEAN ARCHITECTURE LAYERS

The codebase follows strict **Clean Architecture & Feature-Driven Modularization**:

```
lib/
├── core/                              # Shared cross-cutting concerns
│   ├── constants/                     # App dimensions, strings, assets
│   ├── routing/                       # GoRouter configuration & route guards
│   ├── services/                      # Supabase, Firebase, Theme, Storage services
│   ├── theme/                         # AppColors (AMOLED Onyx), AppTypography, AppTheme
│   └── utils/                         # Validators, formatters, date utilities
│
├── features/                          # Feature modules (Clean Architecture)
│   ├── academic_catalog/              # Student subject directory & syllabus
│   ├── admin/                         # Master Admin Platform (13+ dedicated studios)
│   │   ├── data/repositories/         # SupabaseAdminRepository, MockAdminRepository
│   │   ├── domain/models/             # Analytics, Notes, Reports, Chat, Events, Clubs, etc.
│   │   ├── domain/repositories/       # AdminRepository contract interface
│   │   └── presentation/              # AdminProvider & 10+ Admin UI screens
│   │       └── screens/               # Dashboard, Notes, Moderation, Chat, Calendar, etc.
│   ├── auth/                          # Login, Register, Forgot/Reset Password, Verification
│   ├── dashboard/                     # Student modular dashboard with 10 draggable tiles
│   ├── notifications/                 # FCM Push Broadcaster & in-app alerts
│   ├── onboarding/                    # Step-by-step student onboarding wizard
│   ├── profile/                       # User profile, college picker, academic year
│   ├── search/                        # Multi-entity global search engine
│   ├── shell/                         # Persistent Bottom Navigation Shell for students
│   └── timetable/                     # Weekly schedule, period manager, time slots
```

---

## 5. DATABASE ARCHITECTURE & POSTGRESQL SCHEMA (SUPABASE)

Project Supabase Reference: `fnsyxmrnpjzshcrhhpfn` (Region: `ap-south-1`)

### 📋 Database Tables Summary:

| Table Name | Primary Key | Description & Key Columns |
| :--- | :--- | :--- |
| `public.profiles` | `id` (TEXT - Auth UID) | `full_name`, `email`, `role`, `college_id`, `branch`, `semester`, `roll_number`, `enrollment_number`, `is_suspended` |
| `public.colleges` | `id` (UUID) | `name`, `code`, `is_deleted` |
| `public.departments` | `id` (UUID) | `name`, `code`, `college_id`, `is_deleted` |
| `public.subjects` | `id` (UUID) | `branch`, `semester`, `subject_code`, `subject_name`, `short_name`, `credits`, `faculty_name`, `theory`, `practical` |
| `public.notes` | `id` (UUID) | `title`, `description`, `subject_id`, `uploader_id`, `file_url`, `status` (`pending`/`approved`/`rejected`), `rejection_reason` |
| `public.moderation_reports` | `id` (UUID) | `reporter_id`, `reported_user_id`, `entity_type`, `entity_id`, `reason`, `priority`, `status`, `resolution_action` |
| `public.announcements` | `id` (UUID) | `title`, `content`, `created_by`, `is_urgent`, `target_branch`, `target_semester` |
| `public.chat_rooms` | `id` (UUID) | `name`, `type` (`subject`/`batch`/`club`/`broadcast`), `subject_id`, `is_archived`, `is_deleted` |
| `public.messages` | `id` (UUID) | `room_id`, `sender_id`, `content`, `attachment_url`, `is_pinned`, `is_deleted` |
| `public.academic_calendar` | `id` (UUID) | `title`, `event_type` (`exam`/`holiday`/`semester_start`), `start_date`, `end_date`, `target_branch` |
| `public.events` | `id` (UUID) | `title`, `category` (`hackathon`/`workshop`/`seminar`), `location`, `event_date`, `status` (`pending`/`approved`) |
| `public.marketplace_listings` | `id` (UUID) | `seller_id`, `title`, `price`, `category` (`books`/`electronics`), `status` (`active`/`flagged`/`sold`) |
| `public.clubs` | `id` (UUID) | `name`, `description`, `category` (`technical`/`cultural`/`sports`), `member_count`, `status` |
| `public.community_posts` | `id` (UUID) | `author_id`, `title`, `content`, `category` (`doubt`/`notes_share`/`career`), `is_pinned`, `status` |
| `public.audit_logs` | `id` (UUID) | `admin_id`, `action`, `target_type`, `target_id`, `created_at` |

### ⚡ Atomic RPC Stored Procedures:
1. `get_admin_master_analytics()`: Computes total students, active count, subject/college counts, pending note queues, and open moderation tickets in a single database roundtrip.
2. `bulk_moderate_notes(note_ids, target_status, reason)`: Bulk approves or rejects study notes atomically.
3. `resolve_moderation_report(p_report_id, p_resolution_action, p_resolution_notes)`: Resolves moderation tickets and logs disciplinary action.

### 🗄️ Storage Buckets:
* `notes`: Uploaded PDF / DOCX study materials.
* `announcements`: Attached media for broadcasts.
* `marketplace`: Images of student textbook and hardware listings.
* `events`: Banners for hackathons and seminars.
* `avatars`: Student and admin profile photos.

---

## 6. SECURITY, AUTH & ROLE-BASED ACCESS CONTROL (RBAC)

### 🛡️ User Roles:
* `super_admin`: Platform owner with full master permissions.
* `admin`: Administrator with moderation, broadcast, and curriculum capabilities.
* `student`: Standard student user with restricted academic and community privileges.

### 🚦 Routing Gatekeeper Logic (`lib/core/routing/app_router.dart`):
* Unauthenticated users attempting to access protected routes are redirected to `/login`.
* Authenticated students attempting to access `/admin/*` are blocked and redirected to `/home`.
* Authenticated admins are routed directly into `/admin` (or can toggle to Student View at will).
* Suspended students (`is_suspended: true`) have their sessions locked with disciplinary reasons displayed.

---

## 7. THE 35-MODULE ADMIN PLATFORM SPECIFICATION

The 35 modules designed for ScholarSync are organized into a complete command structure:

1. **Dashboard** — Executive Mission Control, 6 KPI cards, real-time pulse, branch progress.
2. **Authentication & Security** — Admin credentials, 1-tap fill, session sync, token validation.
3. **Admin Profile** — App Owner identity, password change, preferences.
4. **Role & Permissions** — RBAC permission matrix (`canManageCurriculum`, `canModerate`, `canBroadcast`).
5. **User Management** — Student directory, filters, account suspension, role delegation.
6. **Academic Management** — Colleges, departments, curriculum subjects, credits, theory/lab tags.
7. **Academic Calendar** — University exam timetables, semester milestones, holidays.
8. **Attendance Management** — 75% attendance criteria rules, safe-bunk threshold configurations.
9. **Timetable Management** — Master schedule templates, working days, period slot configurations.
10. **Assignment Management** — Assignment categories, due date templates, priority matrix.
11. **Notes Management** — Peer-uploaded notes review queue, 1-tap approve/reject, storage metrics.
12. **Community Management** — Campus forum threads, Q&A doubts, polls, thread pinning.
13. **Chat Management** — Realtime subject channels, batch lounges, message stream inspector, deletion.
14. **Marketplace Management** — Campus buy/sell listings, price moderation, anti-scam flagging.
15. **Club Management** — Campus coding clubs, cultural societies, member tracking.
16. **Event Management** — Hackathons, workshops, seminars, campus event approval workflows.
17. **Notification Center** — FCM push broadcast engine with target audience filters.
18. **Announcement Management** — Pinned campus notices, markdown content, urgent alert tags.
19. **AI Management** — Heuristic rule thresholds and smart deterministic parameters.
20. **Search Management** — Global multi-entity search engine indexing.
21. **Analytics Center** — High-performance RPC analytics for platform growth and engagement.
22. **Moderation Center** — Unified violation review (Warn User, Suspend Account, Delete Content).
23. **Report Management** — Multi-entity report tracking across notes, marketplace, chat, and profiles.
24. **Review & Rating** — Study notes ratings and peer-review feedback scores.
25. **Feedback & Support** — Student bug reports, feature requests, and inquiries.
26. **File & Media Management** — Supabase storage bucket policies and upload limits.
27. **Audit Logs** — Immutable action audit trail logging admin actions and target entities.
28. **User Activity Logs** — Student event logs (sign-in, attendance update, notes upload).
29. **Platform Settings** — App configuration, version control, maintenance mode toggles.
30. **Feature Management** — Dynamic remote feature flags to toggle services on/off.
31. **Backup & Recovery** — PostgreSQL schema dumps and JSON data exporters.
32. **System Monitoring** — Live PostgreSQL 17 health pulse and connection latency.
33. **Security Center** — Active device inspection and session invalidation.
34. **Import & Export** — Bulk CSV/JSON import/export for subjects, colleges, and students.
35. **Content Management** — Onboarding carousel slides, FAQs, Terms of Service, Privacy Policy CMS.

---

## 8. MODULE-BY-MODULE LOGIC & IMPLEMENTATION BREAKDOWN

### 🖥️ 1. Executive Mission Control (`admin_dashboard_screen.dart`)
* **Live System Pulse**: Glowing animated pulse dot verifying PostgreSQL 17 uptime and connection health.
* **6 Glowing KPI Cards**: Displays real-time metrics for Students, Subjects, Colleges, Notes Queue, Moderation Tickets, and Broadcasts.
* **Quick Action Launchpad**: 10 obsidian launchpad chips with glowing borders linking directly to core studios.
* **Branch Progress Bars**: Visual breakdown of student enrollment across branches.
* **Recent Signups Feed**: Stream of newly registered students with branch/semester chips and role badges.

### 📚 2. Curriculum & Subjects Studio (`admin_subject_management_screen.dart`)
* Filter subjects by Branch, Semester, and Keyword search.
* Dark obsidian cards with monospaced code badges (`CS401`), Theory/Lab tags, and credits.
* Modal dialog to add and edit subjects with automatic display ordering.

### 🏛️ 3. Supported Colleges Studio (`admin_college_management_screen.dart`)
* List of partner institutions with university code pills (e.g., `CODE: MIT-WPU`).
* Quick CRUD dialog for registering new institutions.

### 📁 4. Study Notes Approval Queue (`admin_notes_screen.dart`)
* Tabs for `Pending Approval`, `Approved Catalog`, and `Rejected`.
* Review PDF/DOCX links, uploader information, and subject tags.
* 1-Tap **Approve** or **Reject with Reason Dialog**.

### ⚖️ 5. Unified Moderation Center (`admin_moderation_screen.dart`)
* Resolves student violation reports against notes, messages, marketplace listings, or profiles.
* Resolution actions: `Warn User`, `Suspend Account`, `Delete Content`, `Dismiss`.

### 💬 6. Chat Management Studio (`admin_chat_screen.dart`)
* Create Subject channels (`#cs401-daa`), Batch Lounges, and Club rooms.
* **Live Message Inspector Modal**: Real-time conversation stream inspection.
* **1-Tap Deletion**: Purge inappropriate messages and spam instantly.

### 📅 7. Academic Calendar & Exam Dates (`admin_calendar_screen.dart`)
* Visual date-card feed with month badges and category filters (`Exams`, `Holidays`, `Semesters`).
* Integrated date picker to schedule university milestones.

### 🚀 8. Campus Events & Hackathons (`admin_events_screen.dart`)
* Governance for hackathons, workshops, and seminars.
* Includes venue tags, date badges, and 1-tap event approval.

### 🛍️ 9. Campus Marketplace Oversight (`admin_marketplace_screen.dart`)
* Catalog of student listings (textbooks, drafters, hardware).
* 1-Tap **Flag Listing** and **Delete Listing** against fraudulent behavior.

### 👥 10. Student Clubs & Societies (`admin_clubs_screen.dart`)
* Register technical communities (GDSC, ACM, Coding Club) and cultural societies.
* Track active member counts and category tags.

### 🗣️ 11. Community Forum & Q&A Hub (`admin_community_screen.dart`)
* Moderate student discussions, doubts, and polls.
* **Pin Priority Topics** to the top of the feed and delete violating threads.

### 📢 12. Push Broadcast Alerts (`admin_announcements_screen.dart`)
* Create platform-wide or branch-specific announcements.
* Urgent alert tags and direct FCM broadcast integration.

### 👥 13. Student Directory & Role Delegation (`admin_students_screen.dart`)
* Searchable student directory with enrollment numbers and college tags.
* **Role Delegation**: Instantly promote students to `admin` or suspend accounts.

---

## 9. SMART ALGORITHMS (ZERO-THIRD-PARTY AI LOGIC)

ScholarSync uses **deterministic heuristics and offline algorithms** for reliability, privacy, zero API costs, and instant offline execution:

1. **Attendance Safe-Bunk Calculator**:
   $$\text{Safe Bunks} = \left\lfloor \frac{\text{Attended} - (0.75 \times \text{Total})}{0.75} \right\rfloor$$
   Calculates exact classes a student can safely skip while staying strictly above the mandatory 75% threshold.

2. **Classes Needed to Recover 75%**:
   $$\text{Classes Needed} = \lceil 3 \times \text{Total} - 4 \times \text{Attended} \rceil$$
   Calculates exact consecutive classes required to get out of the attendance danger zone.

3. **Dynamic Dashboard Greeting**:
   Adapts in real-time according to local device time (`Good morning`, `Good afternoon`, `Good evening`).

4. **Timetable Status Engine**:
   Determines whether a lecture is currently `Ongoing`, `Upcoming`, or `Completed` based on the real-time clock.

---

## 10. DESIGN SYSTEM & AMOLED LUXURY THEME

ScholarSync uses **Theme 6: Monochrome Obsidian & Electric Ice Blue Luxury Palette**:

* **AMOLED Pure Black (`#000000`)**: Deepest black base for battery saving and maximum OLED contrast.
* **Obsidian Surfaces (`#0F1218`)**: Elevated dark containers with `#27272A` subtle borders.
* **Electric Ice Blue (`#38BDF8`)**: Primary high-energy accent color.
* **Luxury Indigo (`#818CF8`)**: Secondary accent for academic tags and subject codes.
* **Emerald Green (`#34D399`)**: Success indicators, holidays, and active status pills.
* **Amber / Gold (`#FBBF24`)**: Warning tags, club badges, and college identifiers.
* **Ruby Red (`#F87171`)**: Urgent notices, exam tags, and disciplinary actions.

---

## 11. SETUP, EXECUTION & TESTING HANDBOOK

### 🛠️ Prerequisites
* Flutter SDK (Version 3.22.0 or higher)
* Dart SDK (Version 3.4.0 or higher)
* Android Studio / VS Code with Flutter extensions

### 🚀 Step-by-Step Running Guide
1. **Clone the repository**:
   ```bash
   git clone https://github.com/niks0-0/scholarsync.git
   cd scholarsync
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run Code Analysis**:
   ```bash
   flutter analyze
   ```
   *(Expected output: No issues found!)*

4. **Run Complete Unit & State Test Suite**:
   ```bash
   flutter test
   ```
   *(Expected output: 54 / 54 tests passed!)*

5. **Run App on Device / Emulator**:
   ```bash
   flutter run
   ```

6. **Log into Admin Console**:
   * On the login screen, click **`⚡ Fill App Owner Admin`** (or type `admin@scholarsync.com` / `Admin@123456`).
   * Click **Log In** to open the Mission Control Admin Platform.

---
*Document Version: 2.0 (Phase 3 Verified)*  
*Maintained by: App Owner & Platform DBA*
