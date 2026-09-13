-- C3: Procedimientos de seguridad (Auth)
-- a) dado username, retorna password hash para verificación en backend
-- b) verifica si un usuario posee un rol específico

CREATE OR REPLACE FUNCTION sp_get_password_hash(p_username CITEXT)
RETURNS TEXT
LANGUAGE plpgsql STABLE AS $$
DECLARE v_hash TEXT;
BEGIN
    SELECT password_hash INTO v_hash FROM users WHERE username = p_username;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'usuario % no existe', p_username;
    END IF;
    RETURN v_hash;
END $$;

CREATE OR REPLACE FUNCTION sp_has_role(p_username CITEXT, p_role CITEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql STABLE AS $$
DECLARE v_found BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM users u
        JOIN users_roles ur ON ur.user_id = u.id
        JOIN roles r ON r.id = ur.role_id
        WHERE u.username = p_username AND r.name = p_role
    ) INTO v_found;
    RETURN v_found;
END $$;
