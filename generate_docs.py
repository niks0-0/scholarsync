import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def create_documentation():
    doc = docx.Document()

    # Set standard margins (1 inch)
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(1)
        section.bottom_margin = Inches(1)
        section.left_margin = Inches(1)
        section.right_margin = Inches(1)

    # Styles helper
    def set_cell_background(cell, fill_hex):
        tcPr = cell._tc.get_or_add_tcPr()
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
        tcPr.append(shd)

    def add_title(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run(text)
        run.font.size = Pt(26)
        run.font.bold = True
        run.font.name = 'Calibri'
        run.font.color.rgb = RGBColor(0x3B, 0x82, 0xF6) # Primary Blue
        p.paragraph_format.space_after = Pt(4)
        return p

    def add_subtitle(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run(text)
        run.font.size = Pt(14)
        run.font.italic = True
        run.font.name = 'Calibri'
        run.font.color.rgb = RGBColor(0x64, 0x74, 0x8B) # Slate 500
        p.paragraph_format.space_after = Pt(24)
        return p

    def add_h1(text):
        p = doc.add_paragraph()
        run = p.add_run(text)
        run.font.size = Pt(18)
        run.font.bold = True
        run.font.name = 'Calibri'
        run.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A) # Deep Navy Blue
        p.paragraph_format.space_before = Pt(16)
        p.paragraph_format.space_after = Pt(6)
        return p

    def add_h2(text):
        p = doc.add_paragraph()
        run = p.add_run(text)
        run.font.size = Pt(14)
        run.font.bold = True
        run.font.name = 'Calibri'
        run.font.color.rgb = RGBColor(0x25, 0x63, 0xEB) # Blue
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(4)
        return p

    def add_h3(text):
        p = doc.add_paragraph()
        run = p.add_run(text)
        run.font.size = Pt(12)
        run.font.bold = True
        run.font.name = 'Calibri'
        run.font.color.rgb = RGBColor(0x0F, 0x17, 0x2A) # Dark
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(2)
        return p

    def add_p(text, bold_prefix=None):
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_bold = p.add_run(bold_prefix)
            r_bold.font.bold = True
            r_bold.font.name = 'Calibri'
            r_bold.font.size = Pt(11)
            r_bold.font.color.rgb = RGBColor(0x1E, 0x29, 0x3B)
        run = p.add_run(text)
        run.font.name = 'Calibri'
        run.font.size = Pt(11)
        run.font.color.rgb = RGBColor(0x33, 0x41, 0x55)
        return p

    def add_bullet(text, bold_prefix=None):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_bold = p.add_run(bold_prefix)
            r_bold.font.bold = True
            r_bold.font.name = 'Calibri'
            r_bold.font.size = Pt(11)
            r_bold.font.color.rgb = RGBColor(0x1E, 0x29, 0x3B)
        run = p.add_run(text)
        run.font.name = 'Calibri'
        run.font.size = Pt(11)
        run.font.color.rgb = RGBColor(0x33, 0x41, 0x55)
        return p

    # ── DOCUMENT HEADER ──
    add_title("ScholarSync — System Architecture & Module Specification")
    add_subtitle("Comprehensive Technical Viva & Project Evaluation Manual\nModules: Admin Controller & User (Student) Ecosystem")

    # ── SECTION 1: SYSTEM OVERVIEW ──
    add_h1("1. Executive Summary & Application Overview")
    add_p("ScholarSync is a next-generation academic operating system and campus collaboration platform designed specifically for university students, faculty, and institutional administrators. The system eliminates administrative silos by synchronizing real-time curriculum schedules, dynamic attendance calculations, legal identity verification (KYC), community collaboration, and institutional oversight into a unified mobile application.")
    
    add_p("The platform is engineered using modern software architectural principles: Clean Architecture (Domain, Data, Presentation layers), Feature-First modular folder layout, reactive State Management via Provider, and a dual-cloud backend architecture integrating Firebase and Supabase.")

    # ── SECTION 2: TECHNOLOGY STACK ──
    add_h1("2. Technology Stack & Architectural Engineering")
    add_bullet(" Client Framework: Flutter 3.x with Dart 3.x (Cross-platform compilation to Android APK, iOS, Web).", bold_prefix="•")
    add_bullet(" State Management: ChangeNotifier & Provider pattern for reactive, decoupled, and testable UI updates.", bold_prefix="•")
    add_bullet(" Routing & Navigation: GoRouter with declarative URL routing, deep-linking, and automated RBAC (Role-Based Access Control) route guards.", bold_prefix="•")
    add_bullet(" Authentication: Firebase Authentication (Email/Password, Google OAuth2 Single Sign-On, Password Reset, and Verification Tokens).", bold_prefix="•")
    add_bullet(" Relational Database & Real-Time Sync: Supabase PostgreSQL (Row-Level Security, Real-Time WebSockets, foreign keys, and indexes).", bold_prefix="•")
    add_bullet(" Cloud Object Storage: Supabase Storage for secure student college ID cards, institutional documents, and profile avatars.", bold_prefix="•")
    add_bullet(" Push Notification Engine: Firebase Cloud Messaging (FCM) with device token registration for instant academic alerts.", bold_prefix="•")
    add_bullet(" Offline-First Caching: Shared Preferences & In-memory resilient repository fallback mechanisms for uninterrupted offline access.", bold_prefix="•")

    # ── SECTION 3: CORE MODULE 1 - ADMIN MODULE ──
    add_h1("3. Module 1: Admin Module (Platform Controller)")
    add_p("The Admin Module is the administrative brain and controller of the ScholarSync platform. It is not an ordinary user role; administrators do not enroll in classes, submit homework, or upload student ID cards. Instead, administrators oversee students, approve verification documents, maintain university catalogs, broadcast announcements, and enforce safety and academic integrity.")

    add_h2("3.1 Fixed Administrator Credentials & Access Logic")
    add_bullet(" Official Admin Email: admin@scholarsync.com (alias: admin)", bold_prefix="•")
    add_bullet(" Default System Password: adminss123 (or Admin@123456)", bold_prefix="•")
    add_bullet(" Immediate Authentication Bypass: Upon authentication, the system recognizes the administrator credentials instantly. The admin account is pre-verified (verificationStatus: 'verified') and has onboarding completed (onboardingCompleted: true). Admins NEVER see the 7-step onboarding process or email verification delays.", bold_prefix="•")
    add_bullet(" RBAC Route Guard: If an admin user ever attempts to access student routes or /onboarding, GoRouter automatically redirects them straight to the Master Console at /admin.", bold_prefix="•")

    add_h2("3.2 Admin Key Features & Capabilities")
    add_bullet(" Executive KPI Dashboard: Real-time telemetry displaying total enrolled students, pending verification requests, active courses, total colleges, system load, and attendance compliance rates.", bold_prefix="1.")
    add_bullet(" Student Verification Queue (KYC): Real-time document inspection tool where administrators examine uploaded college identity cards, match student roll numbers and institutional emails, and approve or reject student academic identities with a single click.", bold_prefix="2.")
    add_bullet(" College & University Directory Management: Full CRUD capability to add, edit, or deactivate affiliated universities and engineering/polytechnic colleges.", bold_prefix="3.")
    add_bullet(" Curriculum & Subject Management: Creation and allocation of semesters, syllabus schemes, subject codes, faculty assignments, and credit structures.", bold_prefix="4.")
    add_bullet(" Institutional Announcement Broadcast Engine: Multi-tier notification system allowing admins to publish urgent exam schedules, campus closures, and event notices with real-time push dispatch.", bold_prefix="5.")
    add_bullet(" Content Moderation & Chat Oversight: Automated and manual auditing tools to monitor community discussions and enforce student safety.", bold_prefix="6.")

    add_h2("3.3 Admin Files & Folder Directory Breakdown")
    table_admin = doc.add_table(rows=1, cols=3)
    table_admin.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr_cells = table_admin.rows[0].cells
    hdr_cells[0].text = "Directory / File Path"
    hdr_cells[1].text = "Architectural Layer"
    hdr_cells[2].text = "Functional Purpose & Logic"
    for cell in hdr_cells:
        set_cell_background(cell, "1E3A8A")
        for p in cell.paragraphs:
            for run in p.runs:
                run.font.bold = True
                run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    admin_files = [
        ("lib/features/admin/presentation/screens/admin_shell_screen.dart", "Presentation", "Master responsive layout with persistent navigation drawer, quick stats banner, and top app bar."),
        ("lib/features/admin/presentation/screens/admin_dashboard_screen.dart", "Presentation", "Executive KPI dashboard displaying active metrics, quick actions, pending KYC alerts, and system health."),
        ("lib/features/admin/presentation/screens/admin_students_screen.dart", "Presentation", "Interactive verification queue with search, filtering by branch/semester, ID preview modal, and Approve/Reject triggers."),
        ("lib/features/admin/presentation/screens/admin_college_management_screen.dart", "Presentation", "Colleges catalog manager supporting additions, updates, university affiliations, and campus locations."),
        ("lib/features/admin/presentation/screens/admin_subject_management_screen.dart", "Presentation", "Syllabus controller to assign subjects to semesters, specify lecture/lab credits, and set evaluation schemes."),
        ("lib/features/admin/presentation/screens/admin_announcements_screen.dart", "Presentation", "Broadcast publishing interface with priority tagging (Urgent, Event, Academic) and target audience filters."),
        ("lib/features/admin/presentation/screens/admin_moderation_screen.dart", "Presentation", "Audit desk to review flagged student messages, enforce community rules, and mute bad actors."),
        ("lib/features/admin/presentation/admin_provider.dart", "State Management", "ChangeNotifier maintaining student queues, loading states, catalog caches, and dispatching async actions."),
        ("lib/features/admin/domain/repositories/admin_repository.dart", "Domain", "Abstract contract defining all administrative operations (getStudents, verifyStudent, addCollege, etc.)."),
        ("lib/features/admin/data/repositories/resilient_admin_repository.dart", "Data Layer", "Resilient implementation combining Supabase live queries with in-memory fallback for offline continuity."),
    ]

    for path, layer, desc in admin_files:
        row_cells = table_admin.add_row().cells
        row_cells[0].text = path
        row_cells[1].text = layer
        row_cells[2].text = desc

    # ── SECTION 4: CORE MODULE 2 - USER (STUDENT) MODULE ──
    add_h1("4. Module 2: User (Student) Module (Academic Ecosystem)")
    add_p("The Student Module is an end-to-end companion designed to manage an undergraduate's day-to-day academic life. From initial registration and verified institutional enrollment to real-time attendance calculation, timetable tracking, dynamic calendar deadlines, and peer study hubs, every feature is tailored to optimize student success.")

    add_h2("4.1 The 7-Step Academic Onboarding Flow")
    add_p("Before students can access their personalized schedule or community hub, they complete a structured 7-step academic identity setup:")
    add_bullet(" Step 0 - Welcome & Identity Setup: Greeting, profile picture setup, and overview of ScholarSync features.", bold_prefix="•")
    add_bullet(" Step 1 - Institution Selection: Dynamic filtering to select their official state, university (e.g. GTU), and affiliated college.", bold_prefix="•")
    add_bullet(" Step 2 - Curriculum & Academic Stream: Selection of degree branch (e.g. Computer Science & Engineering), semester (1-8), division, and roll number.", bold_prefix="•")
    add_bullet(" Step 3 - Profile, Bio & Interests: Personal bio, academic domain interests (AI, Web, Cloud, IoT), and technical skills.", bold_prefix="•")
    add_bullet(" Step 4 - Learning Preferences: Dark/Light AMOLED theme, notification frequencies, and schedule display settings.", bold_prefix="•")
    add_bullet(" Step 5 - Verification & Legal Undertaking: Upload of physical college student ID card image or institutional email OTP verification, plus legal confirmation of academic integrity.", bold_prefix="•")
    add_bullet(" Step 6 - Completion & Automated Enrollment: Master profile generation and auto-enrollment in the active semester's catalog subjects.", bold_prefix="•")

    add_h2("4.2 Student Key Features & Capabilities")
    add_bullet(" Home Dashboard: Personalized welcome header with current date, real-time attendance radial gauge, upcoming lecture countdown card, and quick action shortcuts.", bold_prefix="1.")
    add_bullet(" Dynamic Attendance Tracker: Interactive subject-by-subject attendance logger. Displays required minimum attendance (75%), computes exact lectures required to reach targets ('Bunk Calculators'), and highlights shortage warnings.", bold_prefix="2.")
    add_bullet(" Interactive Timetable: Daily schedule view with day-of-week switching, period timestamps, classroom numbers, and faculty names.", bold_prefix="3.")
    add_bullet(" Academic Calendar & Events: Unified timeline of upcoming exams, submission deadlines, holidays, and campus workshops.", bold_prefix="4.")
    add_bullet(" Leaderboard & Gamification: Ranking system rewarding consistency, attendance excellence, and community contributions with badges.", bold_prefix="5.")
    add_bullet(" Chat Hub & Collaboration: Real-time peer messaging, class group discussions, and shared resource channels.", bold_prefix="6.")
    add_bullet(" Student Profile & Digital ID: Secure view of academic credentials, PRN enrollment number, verified badge, and settings.", bold_prefix="7.")

    add_h2("4.3 Student Files & Folder Directory Breakdown")
    table_user = doc.add_table(rows=1, cols=3)
    table_user.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr_cells_u = table_user.rows[0].cells
    hdr_cells_u[0].text = "Directory / File Path"
    hdr_cells_u[1].text = "Architectural Layer"
    hdr_cells_u[2].text = "Functional Purpose & Logic"
    for cell in hdr_cells_u:
        set_cell_background(cell, "2563EB")
        for p in cell.paragraphs:
            for run in p.runs:
                run.font.bold = True
                run.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    user_files = [
        ("lib/features/onboarding/presentation/screens/onboarding_screen.dart", "Presentation", "7-step PageView container managing step progress, validation, and auto-dispatch."),
        ("lib/features/onboarding/presentation/onboarding_provider.dart", "State Management", "Controls step state, validation errors, ID upload bytes, and completeOnboarding API dispatch."),
        ("lib/features/dashboard/presentation/screens/home_screen.dart", "Presentation", "Student primary dashboard featuring schedule cards, attendance quick-gauges, and notices."),
        ("lib/features/attendance/presentation/screens/attendance_screen.dart", "Presentation", "Attendance analytics screen with percentage circles, Present/Absent buttons, and criteria warnings."),
        ("lib/features/attendance/presentation/attendance_provider.dart", "State Management", "Maintains attendance records, computes overall percentages, and persists local and cloud records."),
        ("lib/features/timetable/presentation/screens/timetable_screen.dart", "Presentation", "Day-by-day timetable grid with period slots, teacher names, and laboratory indicators."),
        ("lib/features/calendar/presentation/screens/calendar_screen.dart", "Presentation", "Interactive calendar with month view, event dots, and exam deadline lists."),
        ("lib/features/leaderboard/presentation/screens/leaderboard_screen.dart", "Presentation", "Gamified ranking board displaying top performers, XP points, and streak badges."),
        ("lib/features/chat/presentation/screens/chat_hub_screen.dart", "Presentation", "Real-time chat screen with class group channels, direct messaging, and message timestamps."),
        ("lib/features/profile/presentation/screens/profile_screen.dart", "Presentation", "Student profile interface displaying verified status, roll number, college name, and settings."),
        ("lib/features/profile/data/repositories/supabase_profile_repository.dart", "Data Layer", "Bridges Firebase UID with Supabase profiles table, sets roles, and manages onboarding status."),
    ]

    for path, layer, desc in user_files:
        row_cells = table_user.add_row().cells
        row_cells[0].text = path
        row_cells[1].text = layer
        row_cells[2].text = desc

    # ── SECTION 5: ROUTING & SECURITY ──
    add_h1("5. Routing, Security Guards & Session Control")
    add_p("ScholarSync employs a strict declarative routing architecture defined in lib/core/routing/app_router.dart using GoRouter. Authentication state and Role-Based Access Control (RBAC) are verified before every route transition:")
    add_bullet(" Unauthenticated Guard: Any user not signed in is automatically restricted from protected routes and redirected to /welcome.", bold_prefix="1.")
    add_bullet(" Admin Fast-Path Guard: If an authenticated user is an administrator (either by role.isAdmin or email admin@scholarsync.com), they are immediately routed to /admin. They are strictly barred from /onboarding.", bold_prefix="2.")
    add_bullet(" Student Onboarding Guard: If an authenticated student has onboardingCompleted == false, any attempt to access /home or other features redirects them directly to /onboarding.", bold_prefix="3.")
    add_bullet(" Student Onboarding Completion Guard: Once a student has finished onboarding (onboardingCompleted == true), accessing login or onboarding routes automatically forwards them to /home.", bold_prefix="4.")
    add_bullet(" Admin Route RBAC Protection: Non-administrator users attempting to access /admin or any administrative subroute are immediately deflected back to /home.", bold_prefix="5.")

    # ── SECTION 6: VIVA / PRESENTATION QUESTIONS ──
    add_h1("6. Viva & Project Presentation Defense Guide")
    add_p("Below are common project evaluation questions and precise answers you can deliver to your professors or evaluators:")

    add_h3("Q1: What is the architectural design pattern used in the project?")
    add_p("Answer: The project follows Clean Architecture with a Feature-First modular structure. Each feature (auth, profile, admin, attendance, timetable, onboarding) is encapsulated into Presentation (UI & Providers), Domain (Models & Repository Interfaces), and Data (Supabase & Firebase implementations). This ensures separation of concerns, testability, and maintainability.")

    add_h3("Q2: Why did you use both Firebase and Supabase?")
    add_p("Answer: We leveraged the best strengths of both platforms. Firebase is used for robust, world-class Authentication (OAuth, Google Sign-In, token refresh) and Firebase Cloud Messaging (FCM) for push notifications. Supabase provides an open-source PostgreSQL relational database with complex SQL queries, Row-Level Security (RLS), and high-speed object storage for student ID card uploads.")

    add_h3("Q3: How does the Admin module differ from regular student users?")
    add_p("Answer: The Admin module is an oversight controller. Administrators do not participate in student onboarding or course enrollment. Their role is to approve or reject student KYC identity submissions, manage curriculum catalogs, publish institutional announcements, and monitor system metrics. Dedicated RBAC guards prevent students from accessing admin tools and prevent admins from seeing student onboarding.")

    add_h3("Q4: How does the attendance calculation logic work?")
    add_p("Answer: Attendance is tracked per enrolled course. The system computes the current percentage (Present / Total Lectures * 100). If the percentage drops below 75%, an alert badge is triggered along with a mathematical prediction calculation informing the student exactly how many consecutive lectures they must attend to regain compliance.")

    # Save document
    output_path = r"c:\Users\ASUS\AndroidStudioProjects\ScholarSync\ScholarSync_Complete_Project_Documentation.docx"
    doc.save(output_path)
    print(f"Documentation successfully created at: {output_path}")

if __name__ == '__main__':
    create_documentation()
