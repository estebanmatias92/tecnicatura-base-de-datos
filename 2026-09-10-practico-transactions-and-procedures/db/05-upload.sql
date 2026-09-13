-- C4: Transacción crítica de carga — documents + log 'UPLOAD' atómicos
-- ROLLBACK explícito ante cualquier error (bloque EXCEPTION).

CREATE OR REPLACE FUNCTION sp_upload_document(
    p_username CITEXT,
    p_displayname TEXT,
    p_file_path TEXT,
    p_mime TEXT DEFAULT 'application/pdf'
)
RETURNS BIGINT
LANGUAGE plpgsql AS $$
DECLARE
    v_user_id BIGINT;
    v_doc_id BIGINT;
BEGIN
    SELECT id INTO v_user_id FROM users WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;

    IF p_displayname IS NULL OR btrim(p_displayname) = '' THEN
        RAISE EXCEPTION 'displayname no puede ser vacío';
    END IF;
    IF p_file_path IS NULL OR btrim(p_file_path) = '' THEN
        RAISE EXCEPTION 'file_path no puede ser vacío';
    END IF;

    BEGIN
        INSERT INTO documents (owner_id, displayname, file_path, mime)
        VALUES (v_user_id, p_displayname, p_file_path, p_mime)
        RETURNING id INTO v_doc_id;

        INSERT INTO log (user_id, document_id, action)
        VALUES (v_user_id, v_doc_id, 'UPLOAD');

        RETURN v_doc_id;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'sp_upload_document falló, ROLLBACK: %', SQLERRM;
    END;
END $$;
