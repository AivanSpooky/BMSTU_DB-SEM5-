-- Используем базу данных 
USE GamingPlatform;
GO

--==========================
-- СЕКЦИЯ УСТАНОВКИ ФЛАГОВ
--==========================
-- Включение clr
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
-- Включение расширенных настроек
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
-- Отключение безопасности
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;


--==================
-- СЕКЦИЯ ЗАГРУЗКИ
--==================
-- ЗАГРУЗКА dll
CREATE ASSEMBLY MyAssembly 
FROM 'C:\Users\User\Desktop\учеба\бауманка\5-sem\DB\lab_04\ClassLibrary1\ClassLibrary1\obj\Debug\ClassLibrary1.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;

--==================
-- СЕКЦИЯ СОЗДАНИЯ
--==================
-- 1. СОЗДАНИЕ ФУНКЦИИ dbo.MyGetUserRegistrationDays
CREATE FUNCTION dbo.MyGetUserRegistrationDays(@UserID INT)
RETURNS INT
AS EXTERNAL NAME MyAssembly.[ClassLibrary1.SqlCLRFunctions].GetUserRegistrationDays;
-- 2. СОЗДАНИЕ АГГРЕГАТНОЙ ФУНКЦИИ dbo.MyGetMaxGamePrice
CREATE AGGREGATE dbo.MyGetMaxGamePrice(@price DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
EXTERNAL NAME MyAssembly.[ClassLibrary1.GetMaxGamePrice];
-- 3. СОЗДАНИЕ ТАБЛИЧНОЙ ФУНКЦИИ dbo.MyGetGamesByCategory
CREATE FUNCTION dbo.MyGetGamesByCategory (@Category NVARCHAR(255))
RETURNS TABLE (GameID INT, Title NVARCHAR(255), Price DECIMAL(10,2))
AS EXTERNAL NAME MyAssembly.[ClassLibrary1.SqlCLRTableFunctions].GetGamesByCategory;
-- 4. СОЗДАНИЕ ПРОЦЕДУРЫ 
CREATE PROCEDURE dbo.MyAddNewUser (
    @Username NVARCHAR(255),
    @Email NVARCHAR(255),
    @RegistrationDate DATETIME,
    @Country NVARCHAR(255),
    @AccountStatus BIT)
AS EXTERNAL NAME MyAssembly.[ClassLibrary1.SqlCLRProcedures].AddNewUser;
-- 5. СОЗДАНИЕ ТРИГГЕРА
CREATE TRIGGER trg_MyInsteadOfInsertOrders
ON Orders
INSTEAD OF INSERT
AS EXTERNAL NAME MyAssembly.[ClassLibrary1.SqlCLRTriggers].InsteadOfInsertOrders;
-- 6. СОЗДАНИЕ ПОЛЬЗОВАТЕЛЬСКОГО ТИПА
CREATE TYPE MyUserProfile
EXTERNAL NAME MyAssembly.[ClassLibrary1.UserProfile];
CREATE TABLE MyUsersWithProfile (
    UserID INT PRIMARY KEY,
    Profile MyUserProfile
);
GO

--==================
-- СЕКЦИЯ ВЫЗОВА
--==================
-- ВЫЗОВ dbo.MyGetUserRegistrationDays
SET STATISTICS TIME ON;
SELECT dbo.MyGetUserRegistrationDays(1) AS RegistrationDays;
SET STATISTICS TIME OFF;

-- ВЫЗОВ dbo.GetMaxGamePrice
SET STATISTICS TIME ON;
SELECT GameID, Title, Price
FROM Games
WHERE Price > (SELECT dbo.MyGetMaxGamePrice(Price) / 2 FROM Games);
SET STATISTICS TIME OFF;

-- ВЫЗОВ dbo.GetGamesByCategory
SET STATISTICS TIME ON;
SELECT * FROM dbo.MyGetGamesByCategory('Action');
SET STATISTICS TIME OFF;

-- ВЫЗОВ dbo.AddNewUser
EXEC dbo.MyAddNewUser 'Nisu', 'nisu@example.com', '2024-10-12', 'Russian Federation', 1;
-- удаление
DELETE FROM Users
WHERE Username = 'Nisu';

-- АКТИВАЦИЯ ТРИГГЕРА (НЕПРАВИЛЬНАЯ)
INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
VALUES (1, 1, -50.00, 2, '2024-10-12');

-- ВСТАВКА В ТАБЛИЦУ С ПОЛЬЗОВАТЕЛЬСКИМ ТИПОМ
INSERT INTO MyUsersWithProfile (UserID, Profile)
VALUES (1, CAST('Nisu,nisu@example.com' AS MyUserProfile));
GO
-- ВЫВОД ТАБЛИЦЫ
SELECT * FROM MyUsersWithProfile;
-- ВЫВОД ПОЛЬЗОВАТЕЛЬСКОГО ТИПА
SELECT UserID, Profile.ToString() AS ProfileString
FROM MyUsersWithProfile;
GO


--==================
-- СЕКЦИЯ УДАЛЕНИЯ
--==================
-- УДАЛЕНИЕ UsersWithProfile
DROP TABLE IF EXISTS MyUsersWithProfile
-- УДАЛЕНИЕ UserProfile
DROP TYPE IF EXISTS MyUserProfile
-- УДАЛЕНИЕ dbo.trg_InsteadOfInsertOrders
DROP TRIGGER IF EXISTS dbo.trg_MyInsteadOfInsertOrders
-- УДАЛЕНИЕ dbo.AddNewUser
DROP PROCEDURE IF EXISTS dbo.MyAddNewUser
-- УДАЛЕНИЕ dbo.GetUserRegistrationDays
DROP FUNCTION IF EXISTS dbo.MyGetUserRegistrationDays;
-- УДАЛЕНИЕ dbo.GetMaxGamePrice
DROP AGGREGATE IF EXISTS dbo.MyGetMaxGamePrice;
-- УДАЛЕНИЕ dbo.GetGamesByCategory
DROP FUNCTION IF EXISTS dbo.MyGetGamesByCategory;
-- УДАЛЕНИЕ MyAssembly
DROP ASSEMBLY IF EXISTS MyAssembly;



-- Regex func
DROP FUNCTION IF EXISTS dbo.CleanGameTitle;
GO
CREATE FUNCTION dbo.CleanGameTitle (@Title NVARCHAR(255))
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @CleanedTitle NVARCHAR(255) = @Title;
    -- Удаление символов - и _
    SET @CleanedTitle = REPLACE(@CleanedTitle, '-', ' ');
    SET @CleanedTitle = REPLACE(@CleanedTitle, '_', ' ');

    -- Удаление всех цифр
    DECLARE @i INT = 0;
    WHILE @i <= 9
    BEGIN
        SET @CleanedTitle = REPLACE(@CleanedTitle, CAST(@i AS NVARCHAR), ' ');
        SET @i = @i + 1;
    END

    RETURN @CleanedTitle;
END;
GO

-- vvvv
DROP FUNCTION IF EXISTS dbo.MyCleanGameTitle;
GO
CREATE FUNCTION dbo.MyCleanGameTitle(@Title NVARCHAR(255))
RETURNS NVARCHAR(255)
AS EXTERNAL NAME MyAssembly.[ClassLibrary1.SqlCLRFunctions].CleanGameTitle;


SET STATISTICS TIME ON;
SELECT 
    GameID, 
    dbo.CleanGameTitle(Title) AS CleanedTitle, 
    ReleaseDate, 
    Price
FROM 
    Games;
SET STATISTICS TIME OFF;
SET STATISTICS TIME ON;
SELECT 
    GameID, 
    dbo.MyCleanGameTitle(Title) AS CleanedTitle, 
    ReleaseDate, 
    Price
FROM 
    Games;
SET STATISTICS TIME OFF;

