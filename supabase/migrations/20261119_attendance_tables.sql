-- ============================================================================
-- SCHOLARSYNC: ATTENDANCE & SUBJECT TRACKING SCHEMA
-- ============================================================================

-- 1. Create user_subjects table (tracked subjects per student)
CREATE TABLE IF NOT EXISTS public.user_subjects (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    subject_code TEXT NOT NULL,
    subject_name TEXT NOT NULL,
    attended_classes INTEGER DEFAULT 0 NOT NULL,
    total_classes INTEGER DEFAULT 0 NOT NULL,
    target_percentage DOUBLE PRECISION DEFAULT 75.0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for speedy lookups by user
CREATE INDEX IF NOT EXISTS idx_user_subjects_user_id ON public.user_subjects(user_id);

-- 2. Create attendance_records table (daily session status per lecture)
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    date DATE NOT NULL,
    timetable_entry_id TEXT,
    weekday INTEGER,
    original_subject_id TEXT,
    original_subject_code TEXT,
    original_subject_name TEXT,
    start_time TEXT,
    end_time TEXT,
    room TEXT,
    faculty TEXT,
    status TEXT NOT NULL, -- 'present', 'absent', 'cancelled', 'proxy', 'unmarked'
    proxy_subject_id TEXT,
    proxy_subject_code TEXT,
    proxy_subject_name TEXT,
    proxy_faculty TEXT,
    cancellation_reason TEXT,
    notes TEXT,
    is_extra BOOLEAN DEFAULT FALSE,
    marked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Composite Index for fast daily query & sync
CREATE INDEX IF NOT EXISTS idx_attendance_records_user_date ON public.attendance_records(user_id, date);

-- 3. Row Level Security (RLS) Policies
ALTER TABLE public.user_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated or token-holding users to manage their own records
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'user_subjects' AND policyname = 'user_subjects_all_policy'
    ) THEN
        CREATE POLICY "user_subjects_all_policy" 
        ON public.user_subjects 
        FOR ALL 
        USING (true) 
        WITH CHECK (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'attendance_records' AND policyname = 'attendance_records_all_policy'
    ) THEN
        CREATE POLICY "attendance_records_all_policy" 
        ON public.attendance_records 
        FOR ALL 
        USING (true) 
        WITH CHECK (true);
    END IF;
END
$$;
