/*-- ����� ��������� (�����������)
SELECT 
    spid, 
    dbid, 
    loginame, 
    status 
FROM sys.sysprocesses
WHERE dbid = DB_ID('GamingPlatform');
GO
-- ����� ������������ �����������
KILL 60;
GO*/

-- ������� ��� ����������� � ���� ������
/*ALTER DATABASE GamingPlatform SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO*/

SELECT * 
FROM sys.tables
WHERE name = 'Reviews';


DROP DATABASE IF EXISTS GamingPlatform;
GO

-- ������� ������� Users
DROP TABLE IF EXISTS dbo.users;
GO

-- ������� ������� Users
DROP TABLE IF EXISTS dbo.users;
GO
-- ������� ������� Developers
DROP TABLE IF EXISTS dbo.developers;
GO
-- ������� ������� Games
DROP TABLE IF EXISTS dbo.games;
GO
-- ������� ������� Reviews
DROP TABLE IF EXISTS dbo.reviews;
GO


USE GamingPlatform;
GO
DELETE FROM Games
WHERE GameID = 7;
