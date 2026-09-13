-- C4: Transacción crítica de carga — documents + log 'UPLOAD' atómicos
-- Qué: sube un documento (INSERT en documents) e inmediatamente registra 'UPLOAD'
--   en log. Las dos escrituras son ATÓMICAS: o quedan ambas o ninguna (ROLLBACK).
-- Cómo se ejecuta: vía `make procs` (o `make all`).
-- Ejemplo:
--   SELECT sp_upload_document('profa', 'Apunte Nuevo', '/repo/nuevo.pdf');
--   -- devuelve el id del documento creado; un SELECT a log muestra el 'UPLOAD'.
-- Notas:
--   - En Postgres TODO el cuerpo de una función ya corre dentro de UNA transacción:
--     si algo falla, se revierte todo lo que la función hizo. El bloque interno
--     BEGIN ... EXCEPTION WHEN OTHERS sirve para interceptar el error y re-lanzarlo
--     con un mensaje claro ('... falló, ROLLBACK: ...'); el ROLLBACK en sí lo hace
--     el motor al propagarse la excepción.
--   - RETURNING id INTO v_doc_id: el INSERT devuelve el id generado y lo guarda en
--     la variable, para poder usarlo en el INSERT siguiente (log) y como retorno.
--   - btrim() recorta espacios: así '   ' se trata como vacío y se rechaza.

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
