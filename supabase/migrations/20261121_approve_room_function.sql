CREATE OR REPLACE FUNCTION public.approve_chatroom_request(
    p_request_id UUID,
    p_reviewer_id TEXT,
    p_reviewer_remarks TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_req RECORD;
    v_new_room_id UUID;
BEGIN
    SELECT * INTO v_req 
    FROM public.chatroom_creation_requests 
    WHERE id = p_request_id 
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Request not found';
    END IF;

    IF v_req.status != 'pending' THEN
        RAISE EXCEPTION 'Request is already in status %', v_req.status;
    END IF;

    -- 1. Create the room in chat_rooms
    INSERT INTO public.chat_rooms (
        name, description, type, category, college_id, branch, semester, subject_id,
        joining_policy, created_by, is_locked, room_status
    ) VALUES (
        v_req.name, v_req.description, v_req.category, v_req.category, v_req.college_id, 
        v_req.branch, v_req.semester, v_req.subject_id, v_req.joining_policy, 
        v_req.requester_id, false, 'active'
    ) RETURNING id INTO v_new_room_id;

    -- 2. Add requester as Owner in chatroom_members
    INSERT INTO public.chatroom_members (room_id, user_id, role, membership_status)
    VALUES (v_new_room_id, v_req.requester_id, 'owner', 'active');

    -- 3. Update the request status
    UPDATE public.chatroom_creation_requests
    SET status = 'approved',
        assigned_reviewer_id = p_reviewer_id,
        reviewer_remarks = p_reviewer_remarks,
        reviewed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_request_id;

    -- 4. Notify the requester
    INSERT INTO public.notifications (
        user_id, title, body, module, priority, deep_link
    ) VALUES (
        v_req.requester_id,
        'Study Lounge Approved!',
        'Your room "' || v_req.name || '" has been approved and is now active.',
        'chat',
        'high',
        '/community'
    );

    RETURN jsonb_build_object('success', true, 'room_id', v_new_room_id);
END;
$$;
