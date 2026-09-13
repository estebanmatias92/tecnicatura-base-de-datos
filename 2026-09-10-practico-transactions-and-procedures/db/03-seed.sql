-- C2: Carga — roles fundamentales + datos de prueba
-- Qué: inserta los 3 roles de la consigna (admin, professor, student) y usuarios +
--   documentos de ejemplo para poder probar las consignas 3 a 8 sin cargar nada a mano.
-- Cómo se ejecuta: como bibliotech_user contra bibliotech, vía `make seed`.
-- Idempotente: ON CONFLICT DO NOTHING / WHERE NOT EXISTS permiten re-ejecutarlo
--   sin duplicar filas.
-- Diseño del seed (a propósito, para que C8 tenga qué reportar):
--   - 'profa' (professor) sube 2 documentos → aparece en el reporte C8a (>1 doc).
--   - 'profb' (professor) sube 1 documento → NO aparece en C8a (sirve de contraejemplo).
--   - 'est1/est2/est3' (student) existen para registrar descargas (C5) y alimentar C8b.
-- Nota: los password_hash son valores ficticios ('hash-...'). En un sistema real
--   aquí iría el resultado de bcrypt/scrypt, nunca la clave en claro.

INSERT INTO roles (name, description) VALUES
    ('admin', 'Administra usuarios y roles'),
    ('professor', 'Sube documentos al repositorio'),
    ('student', 'Lee y descarga documentos')
ON CONFLICT (name) DO NOTHING;

INSERT INTO users (username, password_hash) VALUES
    ('admin1', 'hash-admin1'),
    ('profa', 'hash-profa'),
    ('profb', 'hash-profb'),
    ('est1', 'hash-est1'),
    ('est2', 'hash-est2'),
    ('est3', 'hash-est3')
ON CONFLICT (username) DO NOTHING;

-- Asignación de roles (M2M, puede tener varios; seed usa uno por usuario)
INSERT INTO users_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'admin1' AND r.name = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO users_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'profa' AND r.name = 'professor'
ON CONFLICT DO NOTHING;

INSERT INTO users_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username = 'profb' AND r.name = 'professor'
ON CONFLICT DO NOTHING;

INSERT INTO users_roles (user_id, role_id)
SELECT u.id, r.id FROM users u, roles r
WHERE u.username IN ('est1', 'est2', 'est3') AND r.name = 'student'
ON CONFLICT DO NOTHING;

-- Documentos de prueba: profa sube 2 (para C8a), profb sube 1
INSERT INTO documents (owner_id, displayname, file_path)
SELECT u.id, x.displayname, x.file_path
FROM users u, (VALUES
    ('Guía SQL', '/repo/guia-sql.pdf'),
    ('Apunte Transacciones', '/repo/apunte-tx.pdf')
) AS x(displayname, file_path)
WHERE u.username = 'profa'
AND NOT EXISTS (
    SELECT 1 FROM documents d
    WHERE d.owner_id = u.id AND d.displayname = x.displayname
);

INSERT INTO documents (owner_id, displayname, file_path)
SELECT u.id, 'Manual Bibliotech', '/repo/manual.pdf'
FROM users u
WHERE u.username = 'profb'
AND NOT EXISTS (
    SELECT 1 FROM documents d
    WHERE d.owner_id = u.id AND d.displayname = 'Manual Bibliotech'
);
