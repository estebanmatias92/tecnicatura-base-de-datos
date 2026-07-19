-- ============================================================
-- JOIN Queries - Testing all types
-- ============================================================

USE joins_db;

-- ============================================================
-- 1. INNER JOIN
-- Only matching records from both tables
-- ============================================================

SELECT '=== 1. INNER JOIN ===' as '';
SELECT 
    u.username,
    g.title AS game_title,
    ug.hours_played
FROM users u
INNER JOIN user_games ug ON u.id = ug.user_id
INNER JOIN games g ON ug.game_id = g.id;

-- ============================================================
-- 2. LEFT JOIN
-- All users, even without games
-- ============================================================

SELECT '=== 2. LEFT JOIN ===' as '';
SELECT 
    u.username,
    g.title AS game_title,
    ug.hours_played
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
LEFT JOIN games g ON ug.game_id = g.id;

-- ============================================================
-- 3. RIGHT JOIN
-- All games, even without users
-- ============================================================

SELECT '=== 3. RIGHT JOIN ===' as '';
SELECT 
    u.username,
    g.title AS game_title,
    ug.hours_played
FROM users u
RIGHT JOIN user_games ug ON u.id = ug.user_id
RIGHT JOIN games g ON ug.game_id = g.id;

-- ============================================================
-- 4. FULL OUTER JOIN (MySQL workaround with UNION)
-- All records from both tables
-- ============================================================

SELECT '=== 4. FULL OUTER JOIN (via UNION) ===' as '';
SELECT 
    u.username,
    g.title AS game_title,
    ug.hours_played
FROM users u
LEFT JOIN user_games ug ON u.id = ug.user_id
LEFT JOIN games g ON ug.game_id = g.id
UNION
SELECT 
    u.username,
    g.title AS game_title,
    ug.hours_played
FROM users u
RIGHT JOIN user_games ug ON u.id = ug.user_id
RIGHT JOIN games g ON ug.game_id = g.id
WHERE u.id IS NULL;

-- ============================================================
-- 5. CROSS JOIN
-- Cartesian product (all combinations)
-- ============================================================

SELECT '=== 5. CROSS JOIN (first 5 rows) ===' as '';
SELECT 
    u.username,
    g.title AS game_title
FROM users u
CROSS JOIN games g
LIMIT 5;

-- ============================================================
-- 6. NATURAL JOIN (automatic column matching)
-- ============================================================

SELECT '=== 6. NATURAL JOIN ===' as '';
SELECT 
    u.username,
    g.title AS game_title
FROM users u
NATURAL JOIN user_games ug
NATURAL JOIN games g;

-- ============================================================
-- 7. SELF JOIN example
-- ============================================================

SELECT '=== 7. Self join (users with same email domain) ===' as '';
SELECT 
    u1.username AS user1,
    u2.username AS user2,
    u1.email
FROM users u1
JOIN users u2 ON u1.email = u2.email AND u1.id < u2.id
WHERE u1.email IS NOT NULL;