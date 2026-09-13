-- Fase 4: variante Soft Delete (borrado lógico)
-- Qué: ALTERNATIVA al borrado físico de C6. En vez de DELETE, se marca deleted_at
--   (cuándo se dio de baja); NULL = activo. Nada se pierde: users, documents y log
--   se conservan, por eso en producción se prefiere al CASCADE físico.
-- Cómo se ejecuta: vía `make soft-delete` (o `make all`). Re-ejecutable.
-- Ejemplo:
--   SELECT sp_soft_delete_user('est3');          -- da de baja lógica
--   SELECT * FROM v_active_users;                -- ya no lista a 'est3'
--   SELECT sp_restore_user('est3');              -- revierte la baja
--   SELECT sp_soft_delete_document(1);           -- da de baja un documento
-- Notas:
--   - Esto NO reemplaza a C6: ambos conviven para comparar. C6 = DELETE real
--     (didáctico); Fase 4 = UPDATE de deleted_at (productivo).
--   - La app debería leer las vistas v_active_* en lugar de las tablas crudas, para
--     no mostrar dados de baja. Los SPs de Fases 1-3 no filtran deleted_at: si tu
--     app usa soft delete, esos SPs habría que ajustarlos (ejercicio natural siguiente).
--   - Los SPs de borrado aquí solo hacen UPDATE + validación FOUND (mismo patrón de C3).

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
