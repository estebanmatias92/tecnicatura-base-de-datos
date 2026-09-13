-- C3: Procedimientos de seguridad (Auth)
-- Qué:
--   a) sp_get_password_hash: dado un username, retorna su password hash para que el
--      BACKEND lo verifique (la DB nunca compara claves, solo las entrega al backend).
--   b) sp_has_role: verifica si un usuario posee un rol específico (puerta de autorización).
-- Cómo se ejecuta: vía `make procs` (o `make all`).
-- Ejemplo:
--   SELECT sp_get_password_hash('profa');          -- devuelve 'hash-profa'
--   SELECT sp_has_role('profa', 'professor');      -- devuelve true
--   SELECT sp_has_role('est1', 'professor');       -- devuelve false
-- Notas:
--   - STABLE significa "no modifica la DB y con los mismos argumentos devuelve lo mismo
--     dentro de una consulta": Postgres puede optimizar su uso. (Por contraste, las
--     funciones de C4–C7 que INSERTAN/UPDATEAN no llevan STABLE.)
--   - FOUND es una variable implícita de plpgsql: es true si el SELECT/UPDATE anterior
--     encontró al menos una fila. Aquí la usamos para fallar con error claro si el
--     usuario no existe, en vez de devolver NULL silenciosamente.

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
