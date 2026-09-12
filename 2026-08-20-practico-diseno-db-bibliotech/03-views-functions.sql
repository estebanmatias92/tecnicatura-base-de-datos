-- Bibliotech v4 — Vistas y funciones (Postgres)
-- Consigna: 1 vista por tipo + 1 funcion por tipo + consultas de homologacion.
-- Ejecutar despues de 02-seed.sql

-- Vista plana de libros (reconstruccion sin EAV para lo fijo)
CREATE OR REPLACE VIEW v_book AS
SELECT r.id, r.title, r.display_title, r.file_path, r.created_at,
       b.isbn, b.publisher, b.pub_year, b.edition,
       string_agg(a.full_name, ', ' ORDER BY a.full_name) AS authors
FROM resources r
JOIN book_details b ON b.resource_id = r.id
LEFT JOIN resource_author ra ON ra.resource_id = r.id
LEFT JOIN authors a ON a.id = ra.author_id
GROUP BY r.id, r.title, r.display_title, r.file_path, r.created_at,
         b.isbn, b.publisher, b.pub_year, b.edition;

-- Vista de recomendados por materia (cores de busqueda: homologados segun materia)
CREATE OR REPLACE VIEW v_resource_by_subject AS
SELECT s.name AS subject, r.id AS resource_id, r.type, r.title,
       sr.is_recommended, r.file_path
FROM subject_resource sr
JOIN subjects s ON s.id = sr.subject_id
JOIN resources r ON r.id = sr.resource_id;

-- Vista DDEAV legible: recurso + grupo + valor asignado (unique + multiple)
CREATE OR REPLACE VIEW v_resource_options AS
SELECT r.id AS resource_id, r.title, g.name AS grupo, v.value AS valor, 'unique' AS cardinalidad
FROM entity_unique_options euo
JOIN resources r ON r.id = euo.entity_id
JOIN valid_options vo ON vo.id = euo.valid_option_id
JOIN option_groups g ON g.id = vo.group_id
JOIN option_values v ON v.id = vo.option_value_id
UNION ALL
SELECT r.id, r.title, g.name, v.value, 'multiple'
FROM entity_multiple_options emo
JOIN resources r ON r.id = emo.entity_id
JOIN valid_options vo ON vo.id = emo.valid_option_id
JOIN option_groups g ON g.id = vo.group_id
JOIN option_values v ON v.id = vo.option_value_id;

-- Funcion: asignar (o cambiar) rol unico de forma atomica. 1 rol => UPDATE/UPSERT.
CREATE OR REPLACE FUNCTION fn_assign_unique_role(p_username CITEXT, p_role CITEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE v_user BIGINT; v_role BIGINT;
BEGIN
    SELECT id INTO v_user FROM users WHERE username = p_username;
    IF NOT FOUND THEN RAISE EXCEPTION 'user % no existe', p_username; END IF;
    SELECT id INTO v_role FROM roles WHERE name = p_role;
    IF NOT FOUND THEN RAISE EXCEPTION 'rol % no existe', p_role; END IF;
    INSERT INTO user_has_unique_roles (user_id, role_id)
    VALUES (v_user, v_role)
    ON CONFLICT (user_id) DO UPDATE SET role_id = EXCLUDED.role_id, assigned_at = now();
END $$;

-- Funcion: alta de libro con firma estricta (el RDBMS impide atributos incorrectos).
CREATE OR REPLACE FUNCTION fn_add_book(
    p_title TEXT, p_file_path TEXT, p_isbn TEXT,
    p_publisher TEXT, p_year INT, p_author TEXT)
RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE v_res BIGINT; v_author BIGINT;
BEGIN
    INSERT INTO resources (type, title, file_path) VALUES ('libro', p_title, p_file_path)
    RETURNING id INTO v_res;
    INSERT INTO book_details (resource_id, isbn, publisher, pub_year)
    VALUES (v_res, p_isbn, p_publisher, p_year);
    IF p_author IS NOT NULL THEN
        INSERT INTO authors (full_name) VALUES (p_author)
        ON CONFLICT DO NOTHING;
        SELECT id INTO v_author FROM authors WHERE full_name = p_author LIMIT 1;
        INSERT INTO resource_author (resource_id, author_id) VALUES (v_res, v_author)
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN v_res;
END $$;

-- Prueba de fuego: FK compuesta rechaza valor de grupo incorrecto.
-- Ejemplo (debe FALLAR): asignar a NivelLector un valid_option de Formato:
-- INSERT INTO entity_unique_options (entity_id, valid_option_id, group_id)
-- SELECT 1, vo.id, (SELECT id FROM option_groups WHERE name='NivelLector')
-- FROM valid_options vo JOIN option_groups g ON g.id = vo.group_id
-- WHERE g.name = 'Formato' LIMIT 1;
-- => ERROR: (group_id, valid_option_id) no existe en valid_options.
