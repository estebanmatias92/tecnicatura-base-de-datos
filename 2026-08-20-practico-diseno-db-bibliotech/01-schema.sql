-- Bibliotech v4 — DDL Postgres 18
-- Consigna: Practico 07 Diseno DB Bibliotech — nucleo 3FN + DDEAV acotado, solo digital.
-- Decision v4: un rol unico por user via user_has_unique_roles; user_has_many_roles queda como stub de expansion.
-- Motor: PostgreSQL. Ejecutar en orden: 01-schema.sql -> 02-seed.sql -> 03-views-functions.sql

CREATE EXTENSION IF NOT EXISTS citext;

-- =============================================
-- Consigna: Users + Roles (rol unico, expansion futura)
-- =============================================

CREATE TABLE roles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name CITEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username CITEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Tabla canonica de la app: 1 fila por user = 1 rol. PK(user_id) impone unicidad.
CREATE TABLE user_has_unique_roles (
    user_id BIGINT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles (id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_unique_roles_role ON user_has_unique_roles (role_id);

-- Stub de expansion futura (reemplazo de user_role). Hoy sin uso por la app.
-- Cuando se necesite multirrol: migrar con INSERT INTO ... SELECT ... y cambiar lecturas.
CREATE TABLE user_has_many_roles (
    user_id BIGINT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles (id) ON DELETE RESTRICT,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id)
);
CREATE INDEX ix_many_roles_role ON user_has_many_roles (role_id);

-- =============================================
-- Consigna: Resources digitales + subtipos extensibles (CTI)
-- =============================================

CREATE TABLE resources (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type TEXT NOT NULL CHECK (type IN ('libro', 'apunte_tesis', 'multimedia')),
    title TEXT NOT NULL,
    display_title TEXT,
    file_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_resources_type ON resources (type);

-- Un recurso nuevo tipo = una tabla hija nueva, cero ALTER al nucleo.
CREATE TABLE book_details (
    resource_id BIGINT PRIMARY KEY REFERENCES resources (id) ON DELETE CASCADE,
    isbn TEXT UNIQUE,
    publisher TEXT,
    pub_year INT CHECK (pub_year IS NULL OR (pub_year BETWEEN 1400 AND 2100)),
    edition TEXT
);

CREATE TABLE thesis_details (
    resource_id BIGINT PRIMARY KEY REFERENCES resources (id) ON DELETE CASCADE,
    career TEXT,
    tutor TEXT,
    defended_on DATE
);

CREATE TABLE media_details (
    resource_id BIGINT PRIMARY KEY REFERENCES resources (id) ON DELETE CASCADE,
    mime TEXT,
    duration_sec INT CHECK (duration_sec IS NULL OR duration_sec >= 0),
    external_url TEXT
);

CREATE TABLE authors (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name TEXT NOT NULL
);

CREATE TABLE resource_author (
    resource_id BIGINT NOT NULL REFERENCES resources (id) ON DELETE CASCADE,
    author_id BIGINT NOT NULL REFERENCES authors (id) ON DELETE RESTRICT,
    PRIMARY KEY (resource_id, author_id)
);

-- =============================================
-- Consigna: Subjects jerarquicos + homologacion por materia
-- =============================================

-- Arbol unico: sirve a taller barrial (Fomento) y a materia escolar (Educativa).
CREATE TABLE subjects (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parent_id BIGINT REFERENCES subjects (id) ON DELETE RESTRICT,
    name CITEXT NOT NULL,
    description TEXT,
    UNIQUE (parent_id, name)
);
CREATE INDEX ix_subjects_parent ON subjects (parent_id);

-- Equivalente a "categories": M2M recurso <-> materia/tema.
CREATE TABLE subject_resource (
    subject_id BIGINT NOT NULL REFERENCES subjects (id) ON DELETE CASCADE,
    resource_id BIGINT NOT NULL REFERENCES resources (id) ON DELETE CASCADE,
    is_recommended BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (subject_id, resource_id)
);
CREATE INDEX ix_subject_resource_resource ON subject_resource (resource_id);

-- Desdoble curricular opcional: carrera > materia curricula homologada a un subject.
CREATE TABLE careers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    institution_type TEXT NOT NULL CHECK (institution_type IN ('fomento', 'educativa')),
    name CITEXT NOT NULL UNIQUE
);

CREATE TABLE course_subjects (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    career_id BIGINT NOT NULL REFERENCES careers (id) ON DELETE CASCADE,
    subject_id BIGINT NOT NULL REFERENCES subjects (id) ON DELETE RESTRICT,
    name CITEXT NOT NULL,
    UNIQUE (career_id, name)
);

CREATE TABLE resource_curriculum (
    resource_id BIGINT NOT NULL REFERENCES resources (id) ON DELETE CASCADE,
    course_subject_id BIGINT NOT NULL REFERENCES course_subjects (id) ON DELETE CASCADE,
    is_recommended BOOLEAN NOT NULL DEFAULT TRUE,
    homologado_por TEXT,
    PRIMARY KEY (resource_id, course_subject_id)
);

-- =============================================
-- Consigna: DDEAV acotado solo para metadatos discretos variables
-- Fijos (titulo, ISBN, autor) quedan en columnas. Nunca auth.
-- =============================================

CREATE TABLE option_groups (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name CITEXT NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE option_values (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    value CITEXT NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE valid_options (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    option_value_id BIGINT NOT NULL REFERENCES option_values (id) ON DELETE RESTRICT,
    group_id BIGINT NOT NULL REFERENCES option_groups (id) ON DELETE RESTRICT,
    UNIQUE (option_value_id, group_id),
    UNIQUE (group_id, id)
);

-- 1 valor por grupo por recurso (ej: un libro tiene exactamente UN NivelLector activo).
-- FK compuesta garantiza que valid_option_id pertenezca al group_id declarado.
CREATE TABLE entity_unique_options (
    entity_id BIGINT NOT NULL REFERENCES resources (id) ON DELETE CASCADE,
    valid_option_id BIGINT NOT NULL,
    group_id BIGINT NOT NULL,
    UNIQUE (entity_id, group_id),
    FOREIGN KEY (group_id, valid_option_id) REFERENCES valid_options (group_id, id) ON DELETE RESTRICT
);

-- N valores del mismo grupo (ej: un apunte en varios Idiomas/Formatos).
CREATE TABLE entity_multiple_options (
    entity_id BIGINT NOT NULL REFERENCES resources (id) ON DELETE CASCADE,
    valid_option_id BIGINT NOT NULL REFERENCES valid_options (id) ON DELETE RESTRICT,
    UNIQUE (entity_id, valid_option_id)
);
CREATE INDEX ix_emo_valid ON entity_multiple_options (valid_option_id);
