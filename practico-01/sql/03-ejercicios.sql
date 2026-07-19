-- ============================================================
-- Ejercicios teóricos: EXISTS vs IN, NULL handling, subqueries
-- ============================================================

USE joins_db;

-- ============================================================
-- 1. EXISTS vs IN - ¿Cuál es más eficiente?
-- ============================================================

SELECT '=== EJERCICIO 1: EXISTS vs IN ===' as '';

-- Usando EXISTS
SELECT '--- Using EXISTS ---' as '';
SELECT u.username
FROM users u
WHERE EXISTS (
    SELECT 1 
    FROM user_games ug 
    WHERE ug.user_id = u.id
);

-- Usando IN
SELECT '--- Using IN ---' as '';
SELECT u.username
FROM users u
WHERE u.id IN (
    SELECT ug.user_id 
    FROM user_games ug
);

-- EXISTS con JOIN vs subquery correlacionada
SELECT '--- EXISTS con LEFT JOIN (optimizado) ---' as '';
SELECT DISTINCT u.username
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
WHERE ug.user_id IS NOT NULL;

-- ============================================================
-- 2. NULL handling - finding orphan records
-- ============================================================

SELECT '=== EJERCICIO 2: NULL handling (orphans) ===' as '';

-- Encontrar usuarios sin juegos (LEFT JOIN + IS NULL)
SELECT '--- Users without games (LEFT JOIN) ---' as '';
SELECT u.username
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
WHERE ug.user_id IS NULL;

-- Encontrar registros huérfanos (game_id NULL)
SELECT '--- Orphan records (game_id is NULL) ---' as '';
SELECT u.username, ug.game_id
FROM users u
JOIN user_games ug ON u.id = ug.user_id
WHERE ug.game_id IS NULL;

-- Encontrar user_games donde el juego ya no existe
SELECT '--- user_games with deleted games ---' as '';
SELECT ug.id, ug.user_id, ug.game_id
FROM user_games ug
WHERE ug.game_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM games g WHERE g.id = ug.game_id
);

-- Encontrar usuarios con email NULL
SELECT '--- Users with NULL email ---' as '';
SELECT username FROM users WHERE email IS NULL;

-- ============================================================
-- 3. Subqueries vs JOINs - Comparación práctica
-- ============================================================

SELECT '=== EJERCICIO 3: Subqueries vs JOINs ===' as '';

-- Subquery en WHERE (correlacionada)
SELECT '--- Subquery correlacionada ---' as '';
SELECT u.username
FROM users u
WHERE (
    SELECT COUNT(*) 
    FROM user_games ug 
    WHERE ug.user_id = u.id
) > 0;

-- Equivalent JOIN
SELECT '--- Equivalent JOIN ---' as '';
SELECT DISTINCT u.username
FROM users u
JOIN user_games ug ON u.id = ug.user_id;

-- Subquery en SELECT
SELECT '--- Subquery en SELECT (calculates per row) ---' as '';
SELECT 
    u.username,
    (SELECT COUNT(*) FROM user_games ug WHERE ug.user_id = u.id) AS game_count
FROM users u;

-- ============================================================
-- 4. LEFT JOIN con coalesce para manejo de NULL
-- ============================================================

SELECT '=== EJERCICIO 4: COALESCE y NULLIF ===' as '';

-- COALESCE: reemplazar NULL con valor por defecto
SELECT '--- COALESCE example ---' as '';
SELECT 
    u.username,
    COALESCE(g.title, 'No game assigned') AS game_title
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
LEFT JOIN games g ON ug.game_id = g.id;

-- IFNULL (MySQL specific)
SELECT '--- IFNULL example ---' as '';
SELECT 
    u.username,
    IFNULL(ug.hours_played, 0) AS hours_played
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id;

-- ============================================================
-- 5. Demonstrating NOT IN with NULL gotcha
-- ============================================================

SELECT '=== EJERCICIO 5: NOT IN vs NOT EXISTS (NULL behavior) ===' as '';

-- NOT IN falla si hay NULLs en la subquery
SELECT '--- NOT IN with NULL (empty result - gotcha!) ---' as '';
SELECT u.username
FROM users u
WHERE u.id NOT IN (
    SELECT ug.user_id FROM user_games ug WHERE ug.user_id IS NOT NULL OR ug.user_id IS NULL
);

-- NOT EXISTS funciona correctamente incluso con NULLs
SELECT '--- NOT EXISTS (correct behavior) ---' as '';
SELECT u.username
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM user_games ug WHERE ug.user_id = u.id
);