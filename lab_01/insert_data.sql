USE GamingPlatform;
GO
SELECT * 
FROM tempdb.sys.tables 
WHERE name LIKE '#TempTable%';
DROP TABLE IF EXISTS #TempTable;

--  опирование данных в таблицу Users
CREATE TABLE #TempTable
(
    UserID INT IDENTITY(1,1),
    Username NVARCHAR(100),
    Email NVARCHAR(255),
    RegistrationDate DATE,
    Country NVARCHAR(100),
    AccountStatus NVARCHAR(100)  -- временно используем строковый тип
);
BULK INSERT #TempTable
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Users.csv'
WITH
(
    FIELDTERMINATOR = '%',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (UserID, Username, Email, RegistrationDate, Country, AccountStatus)
SELECT 
    tt.UserID,  -- ќбращаемс€ через алиас, чтобы избежать возможных проблем с именами столбцов
    tt.Username,
    tt.Email,
    tt.RegistrationDate,
    tt.Country,
    CASE 
        WHEN tt.AccountStatus = '1\n' THEN 1
        WHEN tt.AccountStatus = '0\n' THEN 0
        ELSE 0  -- ћожно добавить ELSE дл€ обработки непредвиденных значений
    END
FROM #TempTable tt;
SET IDENTITY_INSERT Users OFF;
DROP TABLE IF EXISTS #TempTable;

--  опирование данных в таблицу Developers
BULK INSERT Developers
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Developers.csv'
WITH (
    FIELDTERMINATOR = '%',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Developers;

--  опирование данных в таблицу Categories
BULK INSERT Categories
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Categories.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Categories;

--  опирование данных в таблицу Games
SELECT * 
FROM tempdb.sys.tables 
WHERE name LIKE '#TempTable%';
DROP TABLE IF EXISTS #TempTable;
CREATE TABLE #TempTable
(
    GameID INT IDENTITY(1,1),
    Title NVARCHAR(255),
    ReleaseDate DATE,
    Description NVARCHAR(100),
	CategoryID INT,
    DeveloperID INT,
	Price DECIMAL(10, 2),
    MinSystemRequirements NVARCHAR(MAX),
	Discontinued NVARCHAR(100)  -- временно используем строковый тип
);
BULK INSERT #TempTable
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Games.csv'
WITH
(
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
SET IDENTITY_INSERT Games ON;
INSERT INTO Games (GameID,Title,ReleaseDate,Description,CategoryID,DeveloperID,Price,MinSystemRequirements,Discontinued)
SELECT 
    GameID,Title,ReleaseDate,Description,CategoryID,DeveloperID,Price,MinSystemRequirements,
    CASE 
        WHEN Discontinued = '1' THEN 1
        WHEN Discontinued = '0' THEN 0
    END
FROM #TempTable;
SET IDENTITY_INSERT Games OFF;
DROP TABLE #TempTable;



--  опирование данных в таблицу Reviews
BULK INSERT dbo.Reviews
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Reviews.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Reviews;

--  опирование данных в таблицу Orders
BULK INSERT dbo.Orders
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Orders;

