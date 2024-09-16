USE GamingPlatform;
GO

-- ����������� ������ � ������� Users
BULK INSERT dbo.Users
FROM 'C:\Users\User\Desktop\�����\��������\5-sem\DB\lab_01\Users.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, 
    KEEPNULLS
);
SELECT * FROM Users;

-- ����������� ������ � ������� Developers
BULK INSERT dbo.Developers
FROM 'C:\Users\User\Desktop\�����\��������\5-sem\DB\lab_01\Developers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Developers;

-- ����������� ������ � ������� Games
BULK INSERT dbo.Games
FROM 'C:\Users\User\Desktop\�����\��������\5-sem\DB\lab_01\Games.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Games;

-- ����������� ������ � ������� Reviews
BULK INSERT dbo.Reviews
FROM 'C:\Users\User\Desktop\�����\��������\5-sem\DB\lab_01\Reviews.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    KEEPNULLS
);
SELECT * FROM Reviews;
