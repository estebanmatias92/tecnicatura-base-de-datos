-- ============================================
-- Consulta 1: Cursos con su modalidad vigente
-- ============================================
SELECT
    c.Name AS CourseName,
    og.Name AS Grupo,
    ov.Value AS ValorAsignado
FROM Course c
JOIN Entity e ON c.EntityID = e.ID
JOIN EntityUniqueOption euo ON e.ID = euo.EntityID
JOIN ValidOption vo ON euo.ValidOptionID = vo.ID
JOIN OptionValue ov ON vo.OptionValueID = ov.ID
JOIN OptionGroup og ON vo.OptionGroupID = og.ID
ORDER BY c.Name;

-- ============================================
-- Consulta 2: Todos los atributos dinámicos
-- de una entidad específica (EntityID = 1)
-- ============================================
SELECT
    og.Name AS Attributo,
    ov.Value AS Valor
FROM Entity e
LEFT JOIN EntityUniqueOption euo ON e.ID = euo.EntityID
LEFT JOIN ValidOption vo ON euo.ValidOptionID = vo.ID
LEFT JOIN OptionValue ov ON vo.OptionValueID = ov.ID
LEFT JOIN OptionGroup og ON vo.OptionGroupID = og.ID
WHERE e.ID = 1

UNION ALL

SELECT
    og.Name AS Attributo,
    ov.Value AS Valor
FROM Entity e
LEFT JOIN EntityMultipleOption emo ON e.ID = emo.EntityID
LEFT JOIN ValidOption vo ON emo.ValidOptionID = vo.ID
LEFT JOIN OptionValue ov ON vo.OptionValueID = ov.ID
LEFT JOIN OptionGroup og ON vo.OptionGroupID = og.ID
WHERE e.ID = 1;

-- ============================================
-- Consulta 3: Catálogo completo — grupos y valores disponibles
-- ============================================
SELECT
    og.Name AS Grupo,
    ov.Value AS ValorDisponible
FROM OptionGroup og
JOIN ValidOption vo ON og.ID = vo.OptionGroupID
JOIN OptionValue ov ON vo.OptionValueID = ov.ID
ORDER BY og.Name, ov.Value;

-- ============================================
-- Consulta 4: Entidades que NO tienen asignado
-- un valor para un grupo específico
-- (ej: cursos sin modalidad definida)
-- ============================================
SELECT
    c.Name AS CourseName
FROM Course c
JOIN Entity e ON c.EntityID = e.ID
WHERE e.ID NOT IN (
    SELECT EntityID
    FROM EntityUniqueOption euo
    JOIN ValidOption vo ON euo.ValidOptionID = vo.ID
    WHERE vo.OptionGroupID = 1
);
