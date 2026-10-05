-- ============================================================================
-- SCHOLARSYNC: PHASE 1 CHATROOM & COMMUNITY SCHEMA MIGRATION (TYPE-ALIGNED)
-- ============================================================================

-- 1. Helper function: Firebase UID extraction from Supabase JWT
CREATE OR REPLACE FUNCTION public.current_user_id() 
RETURNS TEXT 
LANGUAGE sql 
STABLE 
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
  SELECT NULLIF(TRIM(auth.jwt() ->> 'sub'), '');
$$;

REVOKE ALL ON FUNCTION public.current_user_id() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_user_id() TO authenticated, anon;

-- 2. Helper function: Authoritative role extraction
CREATE OR REPLACE FUNCTION public.current_user_role() 
RETURNS TEXT 
LANGUAGE plpgsql 
STABLE 
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_role TEXT;
BEGIN
  SELECT role INTO v_role 
  FROM public.profiles 
  WHERE id = public.current_user_id();
  
  RETURN COALESCE(v_role, 'student');
END;
$$;

REVOKE ALL ON FUNCTION public.current_user_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_user_role() TO authenticated, anon;

-- 3. Enhance existing chat_rooms table (non-destructive)
ALTER TABLE public.chat_rooms 
  ADD COLUMN IF NOT EXISTS category TEXT NOT NULL DEFAULT 'academic',
  ADD COLUMN IF NOT EXISTS joining_policy TEXT NOT NULL DEFAULT 'public_academic',
  ADD COLUMN IF NOT EXISTS assigned_moderator_id TEXT REFERENCES public.profiles(id),
  ADD COLUMN IF NOT EXISTS is_official BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS room_status TEXT NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS description TEXT;

DO $$
BEGIN
  ALTER TABLE public.chat_rooms 
    DROP CONSTRAINT IF EXISTS chk_chat_rooms_category,
    ADD CONSTRAINT chk_chat_rooms_category CHECK (
      category IN ('academic', 'project_study', 'interest_skill', 'events_activities', 'official_announcements')
    );
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER TABLE public.chat_rooms 
    DROP CONSTRAINT IF EXISTS chk_chat_rooms_joining_policy,
    ADD CONSTRAINT chk_chat_rooms_joining_policy CHECK (
      joining_policy IN ('public_academic', 'college_verified', 'department_semester', 'approval_required', 'restricted_official')
    );
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

-- 4. Table: chatroom_creation_requests
CREATE TABLE IF NOT EXISTS public.chatroom_creation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id TEXT NOT NULL REFERENCES public.profiles(id),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('academic', 'project_study', 'interest_skill', 'events_activities', 'official_announcements')),
    college_id UUID REFERENCES public.colleges(id),
    branch TEXT,
    semester INTEGER,
    subject_id UUID REFERENCES public.subjects(id),
    joining_policy TEXT NOT NULL DEFAULT 'public_academic',
    community_guidelines TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'cancelled')),
    assigned_reviewer_id TEXT REFERENCES public.profiles(id),
    reviewer_remarks TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_room_requests_status ON public.chatroom_creation_requests(status);
CREATE INDEX IF NOT EXISTS idx_room_requests_requester ON public.chatroom_creation_requests(requester_id);

-- 5. Table: chatroom_members
CREATE TABLE IF NOT EXISTS public.chatroom_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'owner')),
    membership_status TEXT NOT NULL DEFAULT 'active' CHECK (membership_status IN ('active', 'muted', 'removed', 'left', 'banned')),
    is_muted BOOLEAN NOT NULL DEFAULT FALSE,
    muted_until TIMESTAMPTZ,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    left_at TIMESTAMPTZ,
    removed_at TIMESTAMPTZ,
    removed_by TEXT REFERENCES public.profiles(id),
    removal_reason TEXT,
    UNIQUE(room_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_members_user_status ON public.chatroom_members(user_id, membership_status);
CREATE INDEX IF NOT EXISTS idx_members_room ON public.chatroom_members(room_id);

-- 6. Table: chat_messages
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id TEXT PRIMARY KEY, -- Client-generated UUID string for idempotency
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL REFERENCES public.profiles(id),
    content TEXT NOT NULL,
    reply_to_id TEXT REFERENCES public.chat_messages(id),
    status TEXT NOT NULL DEFAULT 'sent' CHECK (status IN ('sent', 'flagged', 'removed', 'purged')),
    has_attachment BOOLEAN NOT NULL DEFAULT FALSE,
    is_announcement BOOLEAN NOT NULL DEFAULT FALSE,
    has_legal_hold BOOLEAN NOT NULL DEFAULT FALSE,
    removed_by TEXT REFERENCES public.profiles(id),
    removed_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_created ON public.chat_messages(room_id, created_at DESC);

-- 7. Table: chatroom_attachments
CREATE TABLE IF NOT EXISTS public.chatroom_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id TEXT NOT NULL REFERENCES public.chat_messages(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    mime_type TEXT NOT NULL,
    checksum_sha256 TEXT NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    uploaded_by TEXT NOT NULL REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_attachments_room ON public.chatroom_attachments(room_id);

-- 8. Table: saved_resources
CREATE TABLE IF NOT EXISTS public.saved_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    attachment_id UUID NOT NULL REFERENCES public.chatroom_attachments(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES public.subjects(id),
    tags TEXT[],
    notes TEXT,
    saved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, attachment_id)
);
CREATE INDEX IF NOT EXISTS idx_saved_resources_user ON public.saved_resources(user_id);

-- 9. Table: resource_downloads
CREATE TABLE IF NOT EXISTS public.resource_downloads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    attachment_id UUID NOT NULL REFERENCES public.chatroom_attachments(id) ON DELETE CASCADE,
    download_status TEXT NOT NULL DEFAULT 'completed' CHECK (download_status IN ('started', 'completed', 'failed')),
    client_verified_checksum BOOLEAN NOT NULL DEFAULT FALSE,
    downloaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. Table: chatroom_operation_requests
CREATE TABLE IF NOT EXISTS public.chatroom_operation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id TEXT NOT NULL REFERENCES public.profiles(id),
    requester_role TEXT NOT NULL,
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    operation_type TEXT NOT NULL CHECK (operation_type IN ('freeze_room', 'unfreeze_room', 'close_room', 'appoint_moderator', 'remove_content', 'delete_room')),
    target_user_id TEXT REFERENCES public.profiles(id),
    target_record_id TEXT,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'executing', 'completed', 'failed', 'cancelled')),
    reviewer_id TEXT REFERENCES public.profiles(id),
    reviewer_remarks TEXT,
    execution_result JSONB,
    reviewed_at TIMESTAMPTZ,
    executed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. Table: chatroom_reports
CREATE TABLE IF NOT EXISTS public.chatroom_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id TEXT NOT NULL REFERENCES public.profiles(id),
    room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    target_type TEXT NOT NULL CHECK (target_type IN ('message', 'attachment', 'room', 'member')),
    target_id TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('harassment', 'hate_speech', 'sexual_content', 'spam', 'illegal', 'copyright', 'misinformation', 'privacy', 'other')),
    details TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'resolved', 'dismissed')),
    assigned_moderator_id TEXT REFERENCES public.profiles(id),
    moderator_action TEXT,
    resolution_notes TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. Table: notifications
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.profiles(id),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    module TEXT NOT NULL CHECK (module IN ('chat', 'resource', 'attendance', 'calendar', 'timetable', 'profile', 'admin', 'system')),
    priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'critical')),
    deep_link TEXT,
    payload JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    fcm_status TEXT NOT NULL DEFAULT 'pending' CHECK (fcm_status IN ('pending', 'sent', 'failed', 'suppressed')),
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read ON public.notifications(user_id, is_read, created_at DESC);

-- 13. Table: audit_events
CREATE TABLE IF NOT EXISTS public.audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT REFERENCES public.profiles(id),
    actor_role TEXT NOT NULL,
    action_type TEXT NOT NULL,
    module TEXT NOT NULL,
    entity_id TEXT,
    request_id TEXT,
    correlation_id TEXT,
    previous_state JSONB,
    new_state JSONB,
    execution_result JSONB,
    ip_address TEXT,
    details JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_audit_module_created ON public.audit_events(module, created_at DESC);

-- 14. Table: backup_manifests
CREATE TABLE IF NOT EXISTS public.backup_manifests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    archive_name TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    checksum_sha256 TEXT NOT NULL,
    coverage TEXT[] NOT NULL,
    status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('started', 'completed', 'failed')),
    initiated_by TEXT REFERENCES public.profiles(id),
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. Realtime Publication
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_rooms;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
EXCEPTION WHEN OTHERS THEN NULL;
END $$;
