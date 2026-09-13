-- C6 + C7: Mantenimiento y actualizaciones (transaccionales)
-- Qué:
--   - C6: sp_delete_user da de baja un usuario por username (borrado FÍSICO didáctico).
--   - C7: sp_rename_document cambia el displayname; sp_set_user_role reemplaza el/los
--     roles de un usuario por uno nuevo, todo atómicamente.
-- Cómo se ejecuta: vía `make procs` (o `make all`).
-- Ejemplo:
--   SELECT sp_rename_document(1, 'Guía SQL v2');
--   SELECT sp_set_user_role('est1', 'professor');   -- ojo: quita 'student', pone 'professor'
--   SELECT sp_delete_user('usuario_temporal');      -- borra user + sus docs (CASCADE)
-- C6: el CASCADE/SET NULL ya está declarado en el DDL (02-schema.sql), no aquí:
--   - users -> documents: ON DELETE CASCADE (los docs del profesor se borran solos).
--   - users/documents -> log: ON DELETE SET NULL (el historial se conserva en NULL).
--   Por eso sp_delete_user es un simple DELETE: el motor se encarga del resto.
--   Ver la NOTA de la consigna 6: en producción esto sería mala práctica de auditoría
--   (Fase 4 propone el borrado lógico como alternativa); aquí es a propósito didáctico.

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
-- Nota junior: DELETE + INSERT dentro de la misma función = misma transacción:
-- si el INSERT fallara (rol inexistente ya validado arriba, pero por ejemplo),
-- el DELETE también se revierte y el usuario no queda sin roles.
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
