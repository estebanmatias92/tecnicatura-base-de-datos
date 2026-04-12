-- ============================================================
-- NULL Handling Patterns - Deep dive
-- ============================================================

USE joins_db;

-- ============================================================
-- 1. IS NULL vs IS NOT NULL
-- ============================================================

SELECT '=== NULL Pattern 1: IS NULL / IS NOT NULL ===' as '';

-- Find users without email
SELECT username FROM users WHERE email IS NULL;

-- Find users with email
SELECT username FROM users WHERE email IS NOT NULL;

-- ============================================================
-- 2. NULL in JOINs
-- ============================================================

SELECT '=== NULL Pattern 2: NULL in JOINs ===' as '';

-- NULL does NOT match in JOINs (orphan record)
SELECT 
    u.username,
    ug.game_id
FROM users u
JOIN user_games ug ON u.id = ug.user_id;

-- Use LEFT JOIN + IS NULL to find orphans
SELECT 
    u.username,
    ug.game_id
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
WHERE ug.game_id IS NULL;

-- ============================================================
-- 3. NULLIF and division by zero
-- ============================================================

SELECT '=== NULL Pattern 3: NULLIF ===' as '';

-- Avoid division by zero
SELECT 
    title,
    price,
    NULLIF(price, 0) AS safe_price
FROM games;

-- ============================================================
-- 4. IFNULL / COALESCE in calculations
-- ============================================================

SELECT '=== NULL Pattern 4: IFNULL in calculations ===' as '';

SELECT 
    u.username,
    SUM(IFNULL(ug.hours_played, 0)) AS total_hours
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
GROUP BY u.username;

-- ============================================================
-- 5. Composite NULL conditions
-- ============================================================

SELECT '=== NULL Pattern 5: Composite conditions ===' as '';

-- Find records where BOTH user_id AND game_id are NULL
SELECT * FROM user_games 
WHERE user_id IS NULL AND game_id IS NULL;

-- Find records where EITHER is NULL (using OR)
SELECT * FROM user_games 
WHERE user_id IS NULL OR game_id IS NULL;