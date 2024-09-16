USE GamingPlatform;
GO

--  опирование данных в таблицу Users
BULK INSERT dbo.Users
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Users.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    KEEPNULLS
);
SELECT * FROM Users;

--  опирование данных в таблицу Developers
BULK INSERT dbo.Developers
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Developers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Developers;

--  опирование данных в таблицу Games
BULK INSERT dbo.Games
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_01\Games.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Games;

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
