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
KILL 58;
GO
KILL 59;
GO
KILL 60;
GO
KILL 69;
GO
KILL 71;
GO
KILL 74;
GO
KILL 75;
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

-- Удалить таблицу Users
DROP TABLE IF EXISTS dbo.users;
GO
-- Удалить таблицу Developers
DROP TABLE IF EXISTS dbo.developers;
GO
-- Удалить таблицу Categories
DROP TABLE IF EXISTS dbo.categories;
GO
-- Удалить таблицу Games
DROP TABLE IF EXISTS dbo.games;
GO
-- Удалить таблицу Orders
DROP TABLE IF EXISTS dbo.orders;
GO
-- Удалить таблицу Reviews
DROP TABLE IF EXISTS dbo.reviews;
GO



USE GamingPlatform;
GO
DELETE FROM Games
WHERE GameID = 7;
