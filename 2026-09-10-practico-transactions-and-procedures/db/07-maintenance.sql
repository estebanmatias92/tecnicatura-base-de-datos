-- C6 + C7: Mantenimiento y actualizaciones (transaccionales)
-- C6: baja de usuarios. El CASCADE/SET NULL ya está en el DDL (02-schema.sql):
--   - users -> documents: ON DELETE CASCADE (docs del profesor se borran)
--   - users/documents -> log: ON DELETE SET NULL (historial se conserva)
-- C7: renombrar displayname + (re)asignar rol en forma atómica.

CREATE OR REPLACE FUNCTION sp_delete_user(p_username CITEXT)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE v_user_id BIGINT;
BEGIN
    SELECT id INTO v_user_id FROM users WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;
    DELETE FROM users WHERE id = v_user_id;
END $$;

CREATE OR REPLACE FUNCTION sp_rename_document(
    p_document_id BIGINT,
    p_new_displayname TEXT
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    IF p_new_displayname IS NULL OR btrim(p_new_displayname) = '' THEN
        RAISE EXCEPTION 'displayname no puede ser vacío';
    END IF;
    UPDATE documents SET displayname = p_new_displayname WHERE id = p_document_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'documento % no existe', p_document_id;
    END IF;
END $$;

-- Reemplaza todos los roles del usuario por uno nuevo, atómicamente.
CREATE OR REPLACE FUNCTION sp_set_user_role(
    p_username CITEXT,
    p_role CITEXT
)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE v_user_id BIGINT; v_role_id BIGINT;
BEGIN
    SELECT id INTO v_user_id FROM users WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;
    SELECT id INTO v_role_id FROM roles WHERE name = p_role;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'rol % no existe', p_role;
    END IF;

    DELETE FROM users_roles WHERE user_id = v_user_id;
    INSERT INTO users_roles (user_id, role_id) VALUES (v_user_id, v_role_id);
END $$;
