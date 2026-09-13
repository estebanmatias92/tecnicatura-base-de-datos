-- C8: Reportes analíticos (JOIN + GROUP BY + HAVING COUNT)
-- a) profesores con más de un documento
-- b) documentos populares con más de 2 descargas

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
