-- ============================================================
-- Schema: Users and Games (based on ISFT151 manual)
-- ============================================================

DROP DATABASE IF EXISTS joins_db;
CREATE DATABASE joins_db;
USE joins_db;

-- Table: Users
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Table: Games (videojuegos)
CREATE TABLE games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    release_year INT,
    price DECIMAL(10, 2)
);

-- Table: User_Games (relación muchos a muchos - pivot table)
CREATE TABLE user_games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    game_id INT,
    hours_played INT DEFAULT 0,
    last_played DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE SET NULL
);

-- ============================================================
-- Sample Data
-- ============================================================

-- Users
INSERT INTO users (username, email) VALUES
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('charlie', 'charlie@example.com'),
('dave', NULL),
('eve', 'eve@example.com');

-- Games
INSERT INTO games (title, genre, release_year, price) VALUES
('The Legend of Zelda', 'Adventure', 1986, 59.99),
('Super Mario Bros', 'Platformer', 1985, 49.99),
('Tetris', 'Puzzle', 1984, 9.99),
('Chess', 'Strategy', 1970, 0.00),
('Doom', 'Shooter', 1993, 29.99),
('Minecraft', 'Sandbox', 2011, 26.99);

-- User_Games (intentional gaps for JOIN demonstration)
-- Alice: 3 games
INSERT INTO user_games (user_id, game_id, hours_played) VALUES
(1, 1, 100),
(1, 2, 50),
(1, 3, 200);

-- Bob: 2 games (but one with NULL game_id for demonstration)
INSERT INTO user_games (user_id, game_id, hours_played) VALUES
(2, 4, 10),
(2, NULL, 0);

-- Charlie: 1 game
INSERT INTO user_games (user_id, game_id, hours_played) VALUES
(3, 6, 500);

-- Dave: no games (user without any game - LEFT JOIN showcase)
INSERT INTO user_games (user_id, game_id, hours_played) VALUES
(4, NULL, NULL);

-- Eve: has game but game was deleted (orphan record for NULL demo)
INSERT INTO user_games (user_id, game_id, hours_played) VALUES
(5, 99, 0);

-- Delete game_id=99 to simulate orphan
DELETE FROM games WHERE id = 99;

-- ============================================================
-- Verify setup
-- ============================================================

SELECT '=== USERS ===' as '';
SELECT * FROM users;

SELECT '=== GAMES ===' as '';
SELECT * FROM games;

SELECT '=== USER_GAMES ===' as '';
SELECT * FROM user_games;