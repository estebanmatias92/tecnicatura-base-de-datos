-- C8: Reportes analíticos (JOIN + GROUP BY + HAVING COUNT)
-- Qué: dos reportes de auditoría de uso intensivo, como piden las consignas:
--   a) profesores que subieron MÁS DE UN documento → HAVING COUNT(d.id) > 1.
--   b) documentos "populares" con MÁS DE 2 descargas → HAVING COUNT(l.id) > 2.
--      (Los `> 1` y `> 2` salen literales del texto de la consigna 8.)
-- Cómo se ejecuta: vía `make reports` (o `make all`).
-- Ejemplo:
--   SELECT * FROM v_prolific_professors;          -- o SELECT sp_report_prolific_professors();
--   SELECT * FROM v_popular_documents;            -- o SELECT sp_report_popular_documents();
-- Notas:
--   - Cada reporte existe DOS veces a propósito: como VISTA (v_*) para consultarla
--     directo, y como FUNCIÓN (sp_report_*) que la envuelve, porque la consigna pide
--     "crear consultas (y encapsularlas en procedimientos)". Ambas devuelven lo mismo.
--   - HAVING filtra DESPUÉS de agrupar (a diferencia de WHERE, que filtra antes):
--     GROUP BY junta filas por profesor/documento, COUNT las cuenta, HAVING descarta
--     los grupos que no superan el umbral.
--   - El seed ya deja a 'profa' con 2 docs para que C8a devuelva al menos una fila;
--     C8b devuelve filas cuando un documento acumula 3+ 'DOWNLOAD' (ver 99-verify.sql).

CREATE OR REPLACE VIEW v_prolific_professors AS
SELECT u.username, COUNT(d.id) AS doc_count
FROM users u
JOIN users_roles ur ON ur.user_id = u.id
JOIN roles r ON r.id = ur.role_id AND r.name = 'professor'
JOIN documents d ON d.owner_id = u.id
GROUP BY u.username
HAVING COUNT(d.id) > 1;

CREATE OR REPLACE VIEW v_popular_documents AS
SELECT d.id AS document_id, d.displayname, COUNT(l.id) AS download_count
FROM documents d
JOIN log l ON l.document_id = d.id AND l.action = 'DOWNLOAD'
GROUP BY d.id, d.displayname
HAVING COUNT(l.id) > 2;

CREATE OR REPLACE FUNCTION sp_report_prolific_professors()
RETURNS TABLE (username CITEXT, doc_count BIGINT)
LANGUAGE sql STABLE AS $$
    SELECT * FROM v_prolific_professors;
$$;

CREATE OR REPLACE FUNCTION sp_report_popular_documents()
RETURNS TABLE (document_id BIGINT, displayname TEXT, download_count BIGINT)
LANGUAGE sql STABLE AS $$
    SELECT * FROM v_popular_documents;
$$;
