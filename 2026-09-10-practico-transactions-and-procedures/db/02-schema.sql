-- C2: Estructura AAA — users, roles, users_roles, documents, log
-- Ejecutar como bibliotech_user contra DB bibliotech.
-- Decision C6: documents.owner_id ON DELETE CASCADE (borra docs del profesor),
-- log.user_id / log.document_id ON DELETE SET NULL (conserva auditoría).

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
