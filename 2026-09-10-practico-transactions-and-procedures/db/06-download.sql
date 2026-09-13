-- C5: Trazabilidad de descargas — cada descarga de un estudiante queda en log

CREATE OR REPLACE FUNCTION sp_log_download(
    p_username CITEXT,
    p_document_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql AS $$
DECLARE
    v_user_id BIGINT;
    v_log_id BIGINT;
BEGIN
    SELECT id INTO v_user_id FROM users WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM documents WHERE id = p_document_id) THEN
        RAISE EXCEPTION 'documento % no existe', p_document_id;
    END IF;

    INSERT INTO log (user_id, document_id, action)
    VALUES (v_user_id, p_document_id, 'DOWNLOAD')
    RETURNING id INTO v_log_id;

    RETURN v_log_id;
END $$;
