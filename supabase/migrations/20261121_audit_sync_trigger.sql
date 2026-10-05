CREATE OR REPLACE FUNCTION public.sync_audit_events_to_logs()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.audit_logs (
        admin_id, action, target_type, target_id, metadata, created_at
    ) VALUES (
        NEW.actor_id,
        NEW.action_type,
        NEW.module,
        NEW.entity_id,
        jsonb_build_object('details', NEW.details, 'result', NEW.execution_result),
        NEW.created_at
    );
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_audit_events_to_logs ON public.audit_events;
CREATE TRIGGER trg_audit_events_to_logs
AFTER INSERT ON public.audit_events
FOR EACH ROW EXECUTE FUNCTION public.sync_audit_events_to_logs();
