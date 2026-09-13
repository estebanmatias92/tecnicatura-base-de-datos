-- 99: Verificación punta a punta (Fases 1-3)
-- Falla con EXCEPTION si alguna consigna no se cumple.
-- Uso: make verify

DO $$
DECLARE
    v_hash TEXT;
    v_doc BIGINT;
    v_dl BIGINT;
    v_n INT;
BEGIN
    -- C2: 3 roles base
    SELECT COUNT(*) INTO v_n FROM roles WHERE name IN ('admin', 'professor', 'student');
    IF v_n <> 3 THEN RAISE EXCEPTION 'C2 falló: roles=%', v_n; END IF;

    -- C3a / C3b
    v_hash := sp_get_password_hash('profa');
    IF v_hash IS NULL THEN RAISE EXCEPTION 'C3a falló'; END IF;
    IF NOT sp_has_role('profa', 'professor') THEN RAISE EXCEPTION 'C3b falló'; END IF;
    IF sp_has_role('est1', 'professor') THEN RAISE EXCEPTION 'C3b falso positivo'; END IF;

    -- C4: upload atómico (documents + log UPLOAD)
    v_doc := sp_upload_document('profa', 'Doc verify', '/repo/verify.pdf');
    SELECT COUNT(*) INTO v_n FROM log WHERE document_id = v_doc AND action = 'UPLOAD';
    IF v_n <> 1 THEN RAISE EXCEPTION 'C4 falló: sin log UPLOAD'; END IF;

    -- C4 rollback: displayname vacío no debe dejar ni doc ni log
    BEGIN
        PERFORM sp_upload_document('profa', '   ', '/repo/bad.pdf');
        RAISE EXCEPTION 'C4 falló: debió rechazar displayname vacío';
    EXCEPTION WHEN OTHERS THEN
        -- esperado
    END;
    SELECT COUNT(*) INTO v_n FROM documents WHERE file_path = '/repo/bad.pdf';
    IF v_n <> 0 THEN RAISE EXCEPTION 'C4 falló: sin ROLLBACK'; END IF;

    -- C5: 3 descargas de estudiantes sobre el doc verify (lo vuelve "popular")
    PERFORM sp_log_download('est1', v_doc);
    PERFORM sp_log_download('est2', v_doc);
    PERFORM sp_log_download('est3', v_doc);
    SELECT COUNT(*) INTO v_n FROM log WHERE document_id = v_doc AND action = 'DOWNLOAD';
    IF v_n <> 3 THEN RAISE EXCEPTION 'C5 falló'; END IF;

    -- C7: rename + cambio de rol (luego se revierte)
    PERFORM sp_rename_document(v_doc, 'Doc verify v2');
    PERFORM sp_set_user_role('est1', 'professor');
    IF NOT sp_has_role('est1', 'professor') THEN RAISE EXCEPTION 'C7 falló'; END IF;
    PERFORM sp_set_user_role('est1', 'student');

    -- C8a: profa tiene >1 documento
    SELECT COUNT(*) INTO v_n FROM v_prolific_professors WHERE username = 'profa';
    IF v_n <> 1 THEN RAISE EXCEPTION 'C8a falló'; END IF;

    -- C8b: doc verify tiene >2 descargas
    SELECT COUNT(*) INTO v_n FROM v_popular_documents WHERE document_id = v_doc;
    IF v_n <> 1 THEN RAISE EXCEPTION 'C8b falló'; END IF;

    -- Limpieza del doc de verificación (conserva logs por SET NULL)
    DELETE FROM documents WHERE id = v_doc;

    RAISE NOTICE 'VERIFY OK: C1-C8 cumplen';
END $$;
