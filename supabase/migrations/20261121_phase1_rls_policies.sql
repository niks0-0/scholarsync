-- ============================================================================
-- SCHOLARSYNC: PHASE 1 ROW LEVEL SECURITY POLICIES
-- ============================================================================

-- Enable RLS across all new & enhanced tables
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chatroom_creation_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chatroom_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chatroom_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_downloads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chatroom_operation_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chatroom_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.backup_manifests ENABLE ROW LEVEL SECURITY;

-- 1. chat_rooms Policies
DROP POLICY IF EXISTS "chat_rooms_select" ON public.chat_rooms;
CREATE POLICY "chat_rooms_select" ON public.chat_rooms
FOR SELECT USING (
  is_deleted = false AND room_status != 'soft_deleted' AND (
    public.current_user_role() = 'admin'
    OR (
      joining_policy = 'public_academic'
      OR college_id = (SELECT college_id FROM public.profiles WHERE id = public.current_user_id())
      OR id IN (SELECT room_id FROM public.chatroom_members WHERE user_id = public.current_user_id() AND membership_status = 'active')
    )
  )
);

DROP POLICY IF EXISTS "chat_rooms_insert" ON public.chat_rooms;
CREATE POLICY "chat_rooms_insert" ON public.chat_rooms
FOR INSERT WITH CHECK (
  public.current_user_role() = 'admin'
);

DROP POLICY IF EXISTS "chat_rooms_update" ON public.chat_rooms;
CREATE POLICY "chat_rooms_update" ON public.chat_rooms
FOR UPDATE USING (
  public.current_user_role() = 'admin'
);

-- 2. chatroom_creation_requests Policies
DROP POLICY IF EXISTS "room_req_select" ON public.chatroom_creation_requests;
CREATE POLICY "room_req_select" ON public.chatroom_creation_requests
FOR SELECT USING (
  requester_id = public.current_user_id()
  OR public.current_user_role() IN ('admin', 'moderator')
);

DROP POLICY IF EXISTS "room_req_insert" ON public.chatroom_creation_requests;
CREATE POLICY "room_req_insert" ON public.chatroom_creation_requests
FOR INSERT WITH CHECK (
  requester_id = public.current_user_id()
);

-- 3. chatroom_members Policies
DROP POLICY IF EXISTS "room_members_select" ON public.chatroom_members;
CREATE POLICY "room_members_select" ON public.chatroom_members
FOR SELECT USING (
  user_id = public.current_user_id()
  OR public.current_user_role() = 'admin'
  OR EXISTS (
    SELECT 1 FROM public.chatroom_members m2
    WHERE m2.room_id = chatroom_members.room_id
      AND m2.user_id = public.current_user_id()
      AND m2.membership_status = 'active'
  )
);

DROP POLICY IF EXISTS "room_members_insert" ON public.chatroom_members;
CREATE POLICY "room_members_insert" ON public.chatroom_members
FOR INSERT WITH CHECK (
  public.current_user_role() = 'admin'
  OR user_id = public.current_user_id()
);

-- 4. chat_messages Policies
DROP POLICY IF EXISTS "chat_messages_select" ON public.chat_messages;
CREATE POLICY "chat_messages_select" ON public.chat_messages
FOR SELECT USING (
  status != 'purged' AND (
    public.current_user_role() = 'admin'
    OR EXISTS (
      SELECT 1 FROM public.chatroom_members m
      WHERE m.room_id = chat_messages.room_id
        AND m.user_id = public.current_user_id()
        AND m.membership_status IN ('active', 'muted')
    )
  )
);

DROP POLICY IF EXISTS "chat_messages_insert" ON public.chat_messages;
CREATE POLICY "chat_messages_insert" ON public.chat_messages
FOR INSERT WITH CHECK (
  sender_id = public.current_user_id()
  AND status = 'sent'
  AND EXISTS (
    SELECT 1 FROM public.chatroom_members m
    WHERE m.room_id = chat_messages.room_id
      AND m.user_id = public.current_user_id()
      AND m.membership_status = 'active'
      AND m.is_muted = false
  )
  AND EXISTS (
    SELECT 1 FROM public.chat_rooms r
    WHERE r.id = chat_messages.room_id
      AND r.is_locked = false
      AND r.room_status = 'active'
      AND r.is_deleted = false
  )
);

-- 5. saved_resources Policies
DROP POLICY IF EXISTS "saved_resources_all" ON public.saved_resources;
CREATE POLICY "saved_resources_all" ON public.saved_resources
FOR ALL USING (
  user_id = public.current_user_id()
);

-- 6. notifications Policies
DROP POLICY IF EXISTS "notifications_select" ON public.notifications;
CREATE POLICY "notifications_select" ON public.notifications
FOR SELECT USING (
  user_id = public.current_user_id()
  OR public.current_user_role() = 'admin'
);

DROP POLICY IF EXISTS "notifications_update" ON public.notifications;
CREATE POLICY "notifications_update" ON public.notifications
FOR UPDATE USING (
  user_id = public.current_user_id()
);

-- 7. audit_events Policies
DROP POLICY IF EXISTS "audit_events_select" ON public.audit_events;
CREATE POLICY "audit_events_select" ON public.audit_events
FOR SELECT USING (
  public.current_user_role() = 'admin'
);

DROP POLICY IF EXISTS "audit_events_insert" ON public.audit_events;
CREATE POLICY "audit_events_insert" ON public.audit_events
FOR INSERT WITH CHECK (
  public.current_user_role() = 'admin'
);
