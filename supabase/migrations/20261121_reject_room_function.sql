CREATE OR REPLACE FUNCTION public.reject_chatroom_request(
    p_request_id UUID,
    p_reviewer_id TEXT,
    p_reviewer_remarks TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_req RECORD;
BEGIN
    SELECT * INTO v_req 
    FROM public.chatroom_creation_requests 
    WHERE id = p_request_id 
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Request not found';
    END IF;

    UPDATE public.chatroom_creation_requests
    SET status = 'rejected',
        assigned_reviewer_id = p_reviewer_id,
        reviewer_remarks = p_reviewer_remarks,
        reviewed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_request_id;

    INSERT INTO public.notifications (
        user_id, title, body, module, priority, deep_link
    ) VALUES (
        v_req.requester_id,
        'Study Lounge Request Update',
        'Your room request "' || v_req.name || '" was rejected: ' || p_reviewer_remarks,
        'chat',
        'normal',
        '/community'
    );

    RETURN jsonb_build_object('success', true);
END;
$$;
