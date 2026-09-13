-- C2: Estructura AAA — users, roles, users_roles, documents, log
-- Qué: crea las 5 tablas del modelo AAA (Autenticación, Autorización y Auditoría).
-- Cómo se ejecuta: como bibliotech_user contra la DB bibliotech, vía `make schema`.
-- Mapeo AAA (a qué letra sirve cada tabla):
--   - Autenticación (quién sos): users (guarda username + password_hash).
--   - Autorización (qué podés hacer): roles + users_roles (qué rol tiene cada usuario).
--   - Auditoría/Accounting (qué hiciste): documents + log (qué se subió/descargó, cuándo, quién).
-- Decision C6 (borrado en cascada didáctico):
--   - documents.owner_id ON DELETE CASCADE: al borrar un usuario se borran SUS documentos.
--   - log.user_id / log.document_id ON DELETE SET NULL: el historial se conserva, con las
--     columnas del borrado en NULL (queda el registro de que la acción existió).
--   - users_roles.role_id ON DELETE RESTRICT: no se puede borrar un rol que sigue asignado.
-- Notas:
--   - CITEXT es un tipo "texto insensible a mayúsculas": 'Profa' y 'profa' se consideran
--     el mismo username (requiere la extensión citext).
--   - GENERATED ALWAYS AS IDENTITY es el sucesor moderno de SERIAL para IDs autoincrementales.
--   - Los índices ix_* aceleran los JOINs de autorización y auditoría (C3 y C8 los usan).

CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS roles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name CITEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username CITEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Intermedia M2M: un usuario puede tener varios roles (el seed usa uno por usuario).
CREATE TABLE IF NOT EXISTS users_roles (
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles (id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id)
);
CREATE INDEX IF NOT EXISTS ix_users_roles_role ON users_roles (role_id);

CREATE TABLE IF NOT EXISTS documents (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id BIGINT REFERENCES users (id) ON DELETE CASCADE,
    displayname TEXT NOT NULL,
    file_path TEXT NOT NULL,
    mime TEXT NOT NULL DEFAULT 'application/pdf',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_documents_owner ON documents (owner_id);

-- action solo admite 'UPLOAD' o 'DOWNLOAD' (el CHECK lo impone a nivel de tabla).
CREATE TABLE IF NOT EXISTS log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT REFERENCES users (id) ON DELETE SET NULL,
    document_id BIGINT REFERENCES documents (id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN ('UPLOAD', 'DOWNLOAD')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_log_user ON log (user_id);
CREATE INDEX IF NOT EXISTS ix_log_document ON log (document_id);
CREATE INDEX IF NOT EXISTS ix_log_action ON log (action);
