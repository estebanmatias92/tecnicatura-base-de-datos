-- ============================================
-- Prototipo: Alta de "Propuesta Pedagógica Combinada"
-- y asignación al Course "Base de Datos"
-- ============================================

-- 1. Nuevo valor en el catálogo
INSERT INTO OptionValue (ID, Active, Value)
VALUES (2, 1, 'Propuesta Pedagógica Combinada');

-- 2. Vinculación al grupo "ModalidadCursada"
INSERT INTO ValidOption (ID, OptionValueID, OptionGroupID)
VALUES (2, 2, 1);

-- 3. Reemplazo del valor anterior.
--    UNIQUE(EntityID, OptionGroupID) impide tener dos filas
--    para el mismo (entidad, grupo). Se UPDATEA en lugar de
--    insertar una nueva.
UPDATE EntityUniqueOption
SET ValidOptionID = 2
WHERE EntityID = 1 AND OptionGroupID = 1;

-- 4. Verificación
SELECT
    e.ID AS EntityID,
    og.Name AS Grupo,
    ov.Value AS ValorAsignado
FROM Entity e
JOIN EntityUniqueOption euo ON e.ID = euo.EntityID
JOIN ValidOption vo ON euo.ValidOptionID = vo.ID
JOIN OptionValue ov ON vo.OptionValueID = ov.ID
JOIN OptionGroup og ON vo.OptionGroupID = og.ID
WHERE e.ID = 1;
