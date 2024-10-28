/*-- Найти виновника (подключение)
SELECT 
    spid, 
    dbid, 
    loginame, 
    status 
FROM sys.sysprocesses
WHERE dbid = DB_ID('GamingPlatform');
GO
-- Убить существующее подключение
KILL 51;
GO
KILL 52;
GO
KILL 53;
GO
KILL 54;
GO
KILL 55;
GO
KILL 56;
GO
KILL 57;
GO
KILL 58;
GO
KILL 59;
GO
KILL 60;
GO
KILL 61;
GO
KILL 64;
GO
KILL 66;
GO
KILL 67;
GO
KILL 68;
GO
KILL 69;
GO
KILL 71;
GO
KILL 73;
GO
KILL 74;
GO
KILL 75;
GO
KILL 76;
GO
KILL 77;
GO
KILL 79;
GO
KILL 83;
GO
KILL 84;
GO
KILL 86;
GO



*/

-- Убиваем все подключения к базе данных
/*ALTER DATABASE GamingPlatform SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO*/

SELECT * 
FROM sys.tables
WHERE name = 'Reviews';


DROP DATABASE IF EXISTS GamingPlatform;
GO





-- Удалить таблицу Reviews
DROP TABLE IF EXISTS dbo.reviews;
GO
-- Удалить таблицу Orders
DROP TABLE IF EXISTS dbo.orders;
GO
-- Удалить таблицу Games
DROP TABLE IF EXISTS dbo.games;
GO
-- Удалить таблицу Categories
DROP TABLE IF EXISTS dbo.categories;
GO
-- Удалить таблицу Developers
DROP TABLE IF EXISTS dbo.developers;
GO
-- Удалить таблицу Users
DROP TABLE IF EXISTS dbo.users;
GO



USE GamingPlatform;
GO
DELETE FROM Orders;
DELETE FROM Reviews;
DELETE FROM Users;
DELETE FROM Games;
DELETE FROM Developers;
DELETE FROM Categories;
USE GamingPlatform;
GO
TRUNCATE TABLE Orders;
TRUNCATE TABLE Reviews;
TRUNCATE TABLE Games;
TRUNCATE TABLE Users;
TRUNCATE TABLE Developers;
TRUNCATE TABLE Categories;



USE GamingPlatform;
GO
DELETE FROM Games
WHERE GameID = 7;
