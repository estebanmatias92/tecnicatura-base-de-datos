-- Bibliotech v4 — Seed minimo verificable (Postgres)
-- Consigna: demostrar rol unico + arbol subjects + homologacion + DDEAV sin DDL.
-- Ejecutar despues de 01-schema.sql

-- Roles base (data, no DDL para un rol nuevo)
INSERT INTO roles (name, description) VALUES
    ('lector', 'Lee y descarga recursos digitales'),
    ('docente', 'Recomienda y homologa recursos por materia'),
    ('bibliotecario', 'Administra catalogo y subjects'),
    ('admin', 'Administra usuarios y roles')
ON CONFLICT (name) DO NOTHING;

-- Users + asignacion unica canonica
INSERT INTO users (username, password_hash) VALUES
    ('vecina_ana', 'hash-no-real'),
    ('docente_beto', 'hash-no-real'),
    ('biblio_celi', 'hash-no-real')
ON CONFLICT (username) DO NOTHING;

-- 1 rol por user (PK user_id lo impone; segundo INSERT para mismo user fallaria)
INSERT INTO user_has_unique_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'vecina_ana' AND r.name = 'lector'
ON CONFLICT (user_id) DO UPDATE SET role_id = EXCLUDED.role_id;

INSERT INTO user_has_unique_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'docente_beto' AND r.name = 'docente'
ON CONFLICT (user_id) DO UPDATE SET role_id = EXCLUDED.role_id;

INSERT INTO user_has_unique_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'biblio_celi' AND r.name = 'bibliotecario'
ON CONFLICT (user_id) DO UPDATE SET role_id = EXCLUDED.role_id;

-- NOTA: user_has_many_roles queda intencionalmente vacia (stub de expansion v4).

-- Subjects en arbol: raiz barrial + raiz educativa comparten tabla.
-- NOTA: UNIQUE(parent_id, name) no deduplica raices (parent_id NULL => NULLs distintos),
-- por eso se usa WHERE NOT EXISTS para idempotencia en re-ejecuciones.
INSERT INTO subjects (parent_id, name, description)
SELECT NULL, x.name, x.description
FROM (VALUES
    ('Talleres Barriales', 'Oferta de sociedad de fomento'),
    ('Ciencias', 'Rama educativa')
) AS x(name, description)
WHERE NOT EXISTS (SELECT 1 FROM subjects s WHERE s.parent_id IS NULL AND s.name = x.name);

INSERT INTO subjects (parent_id, name, description)
SELECT p.id, 'Matematica', 'Materia homologable'
FROM subjects p WHERE p.name = 'Ciencias' AND p.parent_id IS NULL
AND NOT EXISTS (SELECT 1 FROM subjects s WHERE s.parent_id = p.id AND s.name = 'Matematica');

INSERT INTO subjects (parent_id, name, description)
SELECT p.id, 'Carpinteria Inicial', 'Taller barrial'
FROM subjects p WHERE p.name = 'Talleres Barriales' AND p.parent_id IS NULL
AND NOT EXISTS (SELECT 1 FROM subjects s WHERE s.parent_id = p.id AND s.name = 'Carpinteria Inicial');

INSERT INTO subjects (parent_id, name, description)
SELECT p.id, 'Algebra', 'Unidad de Matematica'
FROM subjects p WHERE p.name = 'Matematica' AND p.parent_id IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM subjects s WHERE s.parent_id = p.id AND s.name = 'Algebra');

-- Authors + resources (1 libro + 1 apunte: prueba CTI)
INSERT INTO authors (full_name) VALUES ('Adela Basch'), ('Equipo Fomento') ON CONFLICT DO NOTHING;

INSERT INTO resources (type, title, display_title, file_path) VALUES
    ('libro', 'Algebra Elemental', 'Álgebra Elemental (Ed. escolar)', '/repo/algebra-elemental.pdf'),
    ('apunte_tesis', 'Apunte Carpinteria Inicial', 'Apunte Carpintería Inicial — Fomento', '/repo/carpinteria-inicial.pdf')
ON CONFLICT DO NOTHING;

INSERT INTO book_details (resource_id, isbn, publisher, pub_year, edition)
SELECT r.id, '978-950-00-0001-1', 'Eudeba', 2021, '3ra'
FROM resources r WHERE r.title = 'Algebra Elemental'
ON CONFLICT (resource_id) DO NOTHING;

INSERT INTO thesis_details (resource_id, career, tutor)
SELECT r.id, 'Taller Fomento', 'Equipo Fomento'
FROM resources r WHERE r.title = 'Apunte Carpinteria Inicial'
ON CONFLICT (resource_id) DO NOTHING;

INSERT INTO resource_author (resource_id, author_id)
SELECT r.id, a.id FROM resources r, authors a
WHERE r.title = 'Algebra Elemental' AND a.full_name = 'Adela Basch'
ON CONFLICT DO NOTHING;

INSERT INTO resource_author (resource_id, author_id)
SELECT r.id, a.id FROM resources r, authors a
WHERE r.title = 'Apunte Carpinteria Inicial' AND a.full_name = 'Equipo Fomento'
ON CONFLICT DO NOTHING;

-- Homologacion: libro recomendado en Algebra; apunte en Carpinteria
INSERT INTO subject_resource (subject_id, resource_id, is_recommended)
SELECT s.id, r.id, TRUE FROM subjects s, resources r
WHERE s.name = 'Algebra' AND r.title = 'Algebra Elemental'
ON CONFLICT DO NOTHING;

INSERT INTO subject_resource (subject_id, resource_id, is_recommended)
SELECT s.id, r.id, TRUE FROM subjects s, resources r
WHERE s.name = 'Carpinteria Inicial' AND r.title = 'Apunte Carpinteria Inicial'
ON CONFLICT DO NOTHING;

-- Carreras de ambos dominios + homologacion curricular
INSERT INTO careers (institution_type, name) VALUES
    ('fomento', 'Centro de Fomento Los Amigos'),
    ('educativa', 'ISFT 151')
ON CONFLICT (name) DO NOTHING;

INSERT INTO course_subjects (career_id, subject_id, name)
SELECT c.id, s.id, 'Matematica I'
FROM careers c, subjects s WHERE c.name = 'ISFT 151' AND s.name = 'Algebra'
ON CONFLICT DO NOTHING;

INSERT INTO resource_curriculum (resource_id, course_subject_id, is_recommended, homologado_por)
SELECT r.id, cs.id, TRUE, 'docente_beto'
FROM resources r, course_subjects cs
WHERE r.title = 'Algebra Elemental' AND cs.name = 'Matematica I'
ON CONFLICT DO NOTHING;

-- DDEAV: catalogos + asignacion sin DDL
INSERT INTO option_groups (name) VALUES
    ('NivelLector'), ('Idioma'), ('Formato'), ('Licencia')
ON CONFLICT (name) DO NOTHING;

INSERT INTO option_values (value) VALUES
    ('Inicial'), ('Intermedio'), ('Espanol'), ('PDF'), ('CC-BY')
ON CONFLICT (value) DO NOTHING;

INSERT INTO valid_options (option_value_id, group_id)
SELECT v.id, g.id FROM option_values v, option_groups g
WHERE (v.value = 'Inicial' AND g.name = 'NivelLector')
   OR (v.value = 'Espanol' AND g.name = 'Idioma')
   OR (v.value = 'PDF' AND g.name = 'Formato')
   OR (v.value = 'CC-BY' AND g.name = 'Licencia')
ON CONFLICT DO NOTHING;

-- Libro: 1 NivelLector (unique: 1 valor por grupo por recurso)
INSERT INTO entity_unique_options (entity_id, valid_option_id, group_id)
SELECT r.id, vo.id, vo.group_id
FROM resources r, valid_options vo
JOIN option_groups g ON g.id = vo.group_id AND g.name = 'NivelLector'
JOIN option_values v ON v.id = vo.option_value_id AND v.value = 'Inicial'
WHERE r.title = 'Algebra Elemental'
ON CONFLICT DO NOTHING;

-- Apunte: Formato + Licencia como multiples (N valores posibles)
INSERT INTO entity_multiple_options (entity_id, valid_option_id)
SELECT r.id, vo.id
FROM resources r, valid_options vo
JOIN option_groups g ON g.id = vo.group_id AND g.name IN ('Formato', 'Licencia')
WHERE r.title = 'Apunte Carpinteria Inicial'
ON CONFLICT DO NOTHING;
