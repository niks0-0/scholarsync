# ScholarSync — Master Production Architecture & Implementation Plan

This is the definitive implementation plan for the complete restructure of ScholarSync, synthesizing all agreed architectural decisions, data models, and service lifecycles.

---

## 1. Core Services & System Blueprint

```
                                [ 1. IDENTITY & ONBOARDING GATE ]
                  ┌─────────────────────────────────────────────────────────────┐
                  │ • Roles: Admin (admin@scholarsync.com / adminss123)         │
                  │          Student (student@scholarsync.com / studentss123)   │
                  │ • Quick 1-Tap Demo Auto-Fill Chips on Login Form            │
                  │ • Mandatory Complete Data Gate: College, Branch, Semester,  │
                  │   Roll # / Student ID, Section, Legal Terms Agreement       │
                  └──────────────────────────────┬──────────────────────────────┘
                                                 │
                           ┌─────────────────────┴─────────────────────┐
                           ▼                                           ▼
              [ ADMIN VERIFICATION QUEUE ]                 [ STUDENT READ-ONLY PREVIEW ]
              • Dean / Faculty verifies Roll #             • View Timetable & Personal Att.
              • Status: Pending -> Verified                • Public Chat & Uploads Locked
                           │                                           │
                           └─────────────────────┬─────────────────────┘
                                                 ▼ (Upon Approval)
     ┌───────────────────────────────────────────────────────────────────────────────────────────┐
     │                             2. ACADEMIC DATA & SCHEDULE FOUNDATION                        │
     ├──────────────────────────┬──────────────────────────┬─────────────────────────────────────┤
     │  A. Curriculum Engine    │  B. Timetable Builder    │  C. Academic Calendar & Alarms      │
     │  • Manual Admin Subject  │  • Student builds weekly │  • Official Exams, Vivas, Holidays  │
     │    Form (Codes, Credits, │    schedule from enrolled│  • Admin Weekly Quizzes Auto-Synced │
     │    Branch, Semester)     │    curriculum courses    │  • Native Closed-App EXACT_ALARM    │
     │  • Auto-creates Subject  │  • Real-time room,       │    (Fires when app is killed or     │
     │    Discussion Rooms      │    faculty & period track│    phone is in Android Doze mode)   │
     └─────────────┬────────────┴─────────────┬────────────┴───────────────────┬─────────────────┘
                   │                          │                                │
                   ▼                          ▼                                ▼
     ┌───────────────────────────────────────────────────────────────────────────────────────────┐
     │                       3. OPERATIVE INTELLIGENCE & EVALUATION                              │
     ├─────────────────────────────────────────┬─────────────────────────────────────────────────┤
     │  D. Smart Attendance Insights Assistant │  E. Flexible Weekly Quizzes (Admin Engine)      │
     │  • Rule-Based Offline Assistant (NO AI) │  • Admin selects Subject, Stream, Timer, Q-Count│
     │  • Configurable Target % (Default 75%)  │  • Push Alert to phone + Auto-Calendar Sync     │
     │  • Dynamic Natural Language Q&A Cards   │  • Student Quiz Hub + Score Progress Report     │
     │    (Recovery, Leave Planning, Future    ├─────────────────────────────────────────────────┤
     │    Predictions, Streaks, Warnings)      │  F. Academic Chat & Doubt Rooms (NO DMs)        │
     ├─────────────────────────────────────────┤  • Subject Q&A, Past Papers, Assignment Debates │
     │  G. Cloudinary Notes & Safety Scanner   │  • Comprehensive Audit Logs & Full Admin Control│
     │  • Hybrid Cloudinary / Supabase Storage │  • Anti-Spam & Inappropriate Content Moderator  │
     │  • Client-side File Signature & Anti-   │                                                 │
     │    Malware pre-upload security scanner  │                                                 │
     └─────────────────────────────────────────┴───────────────┬─────────────────────────────────┘
                                                               │
                                                               ▼
     ┌───────────────────────────────────────────────────────────────────────────────────────────┐
     │                       4. PRODUCTION LEADERBOARD & GAMIFICATION (RP)                       │
     ├───────────────────────────────────────────────────────────────────────────────────────────┤
     │  • Configurable Reputation Points (RP) Engine (Quizzes, Streaks, Verified Notes, Answers) │
     │  • 6 Leaderboard Categories: Academic, Productivity, Community, Notes, Attendance, Impr.  │
     │  • 8-Tier Badges (Bronze ➔ Legend) + Anti-Cheat Engine (Spam prevention, daily caps)       │
     │  • Top 3 Podium UI + Sticky User Rank Card (Responsive Mobile & Laptop)                   │
     └─────────────────────────────────────────────────────────┬─────────────────────────────────┘
                                                               │
                                                               ▼
     ┌───────────────────────────────────────────────────────────────────────────────────────────┐
     │                       5. TIME-ADAPTIVE STUDENT COMMAND DECK                               │
     ├───────────────────────────────────────────────────────────────────────────────────────────┤
     │  • Top Activity Capsule: Live Class Countdown / Bunk Safety Pill                          │
     │  • Omnidirectional Priority Deck: Daytime Lectures/Check-In ⇄ Nighttime Notes/Deadlines    │
     │  • Bento Analytics Hub: Real-Time Attendance Speedometer & Task Counters                  │
     │  • Floating Glass Bottom Dock: [ Home ] [ Timetable ] [ Attendance ] [ Notes ]            │
     │  • Fixed Command Bar: ScholarSync Branding, Global Search, Notification Bell, Profile     │
     └───────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Mathematical Engine: Smart Attendance Insights

$$T = \frac{\text{User Selected Target \%}}{100} \quad (\text{Default } 0.75)$$

$$\text{Current Attendance \%} = \frac{\text{Present Lectures}}{\text{Held Lectures}} \times 100$$
*(Held Lectures = Regular + Proxy + Extra. Excludes Cancelled Lectures & Holidays)*

### Core Calculations:
1. **Safe Bunks Remaining** (when $\text{Attendance} \ge T$):
   $$\text{Safe Bunks} = \left\lfloor \frac{\text{Present}}{T} - \text{Held} \right\rfloor$$
2. **Consecutive Classes Required to Recover** (when $\text{Attendance} < T$):
   $$\text{Required Classes} = \left\lceil \frac{T \times \text{Held} - \text{Present}}{1 - T} \right\rceil$$
3. **Future Prediction (If Attend Next $K$ Classes)**:
   $$\text{Predicted \%} = \frac{\text{Present} + K}{\text{Held} + K} \times 100$$
4. **Future Prediction (If Miss Next $M$ Classes)**:
   $$\text{Predicted \%} = \frac{\text{Present}}{\text{Held} + M} \times 100$$

---

## 3. Phased Execution Roadmap

### Phase 1: Identity, Roles & The Mandatory Onboarding Gate
- Implement Demo Auto-Fill chips on Login (`admin@scholarsync.com` / `adminss123` & `student@scholarsync.com` / `studentss123`).
- Create mandatory `OnboardingGateScreen`: enforces College, Branch, Semester (1-8), Roll # / Student ID, Section, and Legal Terms agreement.
- Implement `Read-Only Preview` state with verification lock banner for unapproved students.

### Phase 2: Admin Student Verification & Curriculum Management
- Admin Student Verification Queue screen (`/admin/students/verification`) with 1-tap Approve / Reject.
- Admin Curriculum Subjects screen (`/admin/subjects`) with deterministic manual form (Code, Name, Credits, Faculty, Theory/Lab).

### Phase 3: Smart Attendance Insights Engine & Personalization
- Build `SmartAttendanceInsightsService` implementing all recovery, leave planning, prediction, and streak formulas.
- Build `SmartAttendanceInsightsSheet` with dynamic question cards (Recovery, Leave Planning, Future Predictions) and configurable target % picker.
- Connect real-time updates without internet dependency.

### Phase 4: Academic Calendar, Weekly Quizzes & Native Closed-App Alarms
- Admin Flexible Quiz Creator (Subject, Stream, Question Count, Timer, Deadline).
- Auto-sync scheduled quizzes to Academic Calendar.
- Native `NativeAlarmService` with `SCHEDULE_EXACT_ALARM` & `WAKE_LOCK` for class & quiz alarms when the app is closed.
- Student Quiz Hub with execution timer and score progress report.

### Phase 5: Cloudinary Document Storage & Client-Side Safety Scanner
- Hybrid Cloudinary uploader with fallback to Supabase Storage.
- Client-side File Signature & Heuristic Scanner (magic bytes, whitelist `.pdf, .png, .jpg, .docx`, size limit, anti-malware pre-upload check).
- Admin Study Notes Review Queue with peer 5-star ratings.

### Phase 6: Academic Chat Rooms & Moderation Engine
- Admin-provisioned subject study rooms (strictly NO DMs).
- Audit logging, message deletion, and user muting by Admin.

### Phase 7: Production Leaderboard & Reputation (RP) Engine
- Supabase tables (`leaderboards`, `point_transactions`, `badges`, `anti_cheat_logs`).
- Configurable RP calculations (Quizzes, Consistency, Verified Notes, Solutions).
- 8-Tier Badges (Bronze to Legend) + Streaks engine.
- Top 3 Podium UI + Sticky User Rank Card.

### Phase 8: Time-Adaptive Student Command Deck & Floating Dock
- 4-way gesture priority card stack on Home with Day/Night adaptive ordering.
- Floating Glass Bottom Dock (`[Home]`, `[Timetable]`, `[Attendance]`, `[Notes]`) + Fixed Top Command Bar.
- Customizable gestures and alert preferences in Settings.

---

## 4. Verification Plan
- **Unit & Widget Tests**: Continuous automated tests across every service (`flutter test`).
- **Zero Diagnostics**: Strict `analyze_files` pass with 0 errors.
- **Cross-Platform Compilation**: `flutter build web --profile` verification at each milestone.
