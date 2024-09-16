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
KILL 60;
GO*/

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

-- Удалить таблицу Users
DROP TABLE IF EXISTS dbo.users;
GO
-- Удалить таблицу Developers
DROP TABLE IF EXISTS dbo.developers;
GO
-- Удалить таблицу Games
DROP TABLE IF EXISTS dbo.games;
GO
-- Удалить таблицу Reviews
DROP TABLE IF EXISTS dbo.reviews;
GO


USE GamingPlatform;
GO
DELETE FROM Games
WHERE GameID = 7;
