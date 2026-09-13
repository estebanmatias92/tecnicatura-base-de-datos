-- Fase 4: variante Soft Delete (borrado lógico)
-- En producción se prefiere a CASCADE físico: se conserva users/documents/log.
-- Re-ejecutable. Los SPs de borrado aquí solo marcan deleted_at.

ALTER TABLE users ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

CREATE OR REPLACE VIEW v_active_users AS
SELECT * FROM users WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW v_active_documents AS
SELECT * FROM documents WHERE deleted_at IS NULL;

CREATE OR REPLACE FUNCTION sp_soft_delete_user(p_username CITEXT)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE users SET deleted_at = now() WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;
END $$;

CREATE OR REPLACE FUNCTION sp_restore_user(p_username CITEXT)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE users SET deleted_at = NULL WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;
END $$;

CREATE OR REPLACE FUNCTION sp_soft_delete_document(p_document_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE documents SET deleted_at = now() WHERE id = p_document_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'documento % no existe', p_document_id;
    END IF;
END $$;
