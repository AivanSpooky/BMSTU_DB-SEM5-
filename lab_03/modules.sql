-- Используем базу данных
USE GamingPlatform;
GO

-- 1. Скалярная функция
-- =============================================
-- Функция: dbo.GetUserRegistrationDays
-- Назначение: Возвращает количество дней, прошедших с даты регистрации пользователя.
-- Параметры:
--     @UserID INT - Идентификатор пользователя
-- Возвращаемое значение:
--     INT - Количество дней с даты регистрации
-- =============================================
IF OBJECT_ID('dbo.GetUserRegistrationDays', 'F') IS NOT NULL
    DROP FUNCTION dbo.GetUserRegistrationDays;
GO
CREATE FUNCTION dbo.GetUserRegistrationDays (@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Days INT;
    
    SELECT @Days = DATEDIFF(DAY, RegistrationDate, GETDATE())
    FROM Users
    WHERE UserID = @UserID;
    
    RETURN ISNULL(@Days, 0);
END;
GO

-- ВЫЗОВ
SET STATISTICS TIME ON;
SELECT dbo.GetUserRegistrationDays(1) AS RegistrationDays;
SET STATISTICS TIME OFF;



-- 2. Подставляемая табличная функция
-- =============================================
-- Функция: dbo.GetGamesByCategory
-- Назначение: Возвращает список игр, принадлежащих указанной категории.
-- Параметры:
--     @CategoryName NVARCHAR(100) - Название категории
-- Возвращаемая таблица:
--     GameID, Title, ReleaseDate, Price
-- =============================================
IF OBJECT_ID('dbo.GetGamesByCategory', 'F') IS NOT NULL
    DROP FUNCTION dbo.GetGamesByCategory;
GO
CREATE FUNCTION dbo.GetGamesByCategory (@CategoryName NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT g.GameID, g.Title, g.ReleaseDate, g.Price
    FROM Games g
    INNER JOIN Categories c ON g.CategoryID = c.CategoryID
    WHERE c.CategoryName = @CategoryName
);
GO


-- ВЫЗОВ
SET STATISTICS TIME ON;
SELECT *
FROM dbo.GetGamesByCategory(N'Action');
SET STATISTICS TIME OFF;

--=== ЗАЩИТА ===
-- Вывести все заказы, в которых купили игру с именем @GameTitle
-- Сделал как подставляемую табличную функцию
-- =============================================
-- Функция: dbo.GetGamesByGameTitle
-- Назначение: Возвращает список заказов, в которых купили игру с заданным названием.
-- Параметры:
--     @GameTitle NVARCHAR(255) - Название игры
-- Возвращаемая таблица:
--     OrderID, UserID, GameID
-- =============================================
IF OBJECT_ID('dbo.GetOrdersByGameTitle', 'F') IS NOT NULL
    DROP FUNCTION dbo.GetGamesByGameTitle;
GO
CREATE FUNCTION dbo.GetGamesByGameTitle (@GameTitle NVARCHAR(255))
RETURNS TABLE
AS
RETURN
(
	SELECT o.OrderID, o.UserID, o.GameID
	FROM Orders o
	JOIN Games g ON o.GameID = g.GameID
	WHERE g.Title = @GameTitle
);
GO

--ВЫЗОВ
SELECT *
FROM dbo.GetGamesByGameTitle(N'Game-110')
--===


-- 3. Многооператорная табличная функция
-- =============================================
-- Функция: dbo.GetUserOrderSummary
-- Назначение: Возвращает сводную информацию о заказах пользователя.
-- Параметры:
--     @UserID INT - Идентификатор пользователя
-- Возвращаемая таблица:
--     TotalOrders INT, TotalAmount DECIMAL(10,2)
-- =============================================
IF OBJECT_ID('dbo.GetUserOrderSummary', 'F') IS NOT NULL
    DROP FUNCTION dbo.GetUserOrderSummary;
GO
CREATE FUNCTION dbo.GetUserOrderSummary (@UserID INT)
RETURNS @Summary TABLE
(
    TotalOrders INT,
    TotalAmount DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @Summary
    SELECT 
        COUNT(*) AS TotalOrders,
        SUM(Price * Quantity) AS TotalAmount
    FROM Orders
    WHERE UserID = @UserID;
    
    RETURN;
END;
GO

-- ВЫЗОВ
SELECT *
FROM dbo.GetUserOrderSummary(5);

-- 4. Рекурсивная функция
-- =============================================
-- Функция: dbo.CalculateFactorial
-- Назначение: Рекурсивно вычисляет факториал заданного числа.
-- Параметры:
--     @Number INT - Число, факториал которого нужно вычислить
-- Возвращаемое значение:
--     BIGINT - Факториал числа
-- =============================================
IF OBJECT_ID('dbo.CalculateFactorial', 'F') IS NOT NULL
    DROP FUNCTION dbo.CalculateFactorial;
GO
CREATE FUNCTION dbo.CalculateFactorial (@Number INT)
RETURNS BIGINT
AS
BEGIN
    IF (@Number <= 1)
        RETURN 1;
    RETURN @Number * dbo.CalculateFactorial(@Number - 1);
END;
GO

-- ВЫЗОВ
SELECT dbo.CalculateFactorial(6) AS FactorialResult;

-- 5. Хранимая процедура с параметрами
-- =============================================
-- Процедура: dbo.AddNewUser
-- Назначение: Добавляет нового пользователя в таблицу Users.
-- Параметры:
--     @Username NVARCHAR(100),
--     @Email NVARCHAR(255),
--     @RegistrationDate DATE,
--     @Country NVARCHAR(100),
--     @AccountStatus BIT
-- =============================================
IF OBJECT_ID('dbo.AddNewUser', 'P') IS NOT NULL
    DROP PROCEDURE dbo.AddNewUser;
GO
CREATE PROCEDURE dbo.AddNewUser
    @Username NVARCHAR(100),
    @Email NVARCHAR(255),
    @RegistrationDate DATE,
    @Country NVARCHAR(100),
    @AccountStatus BIT = 0 -- Значение по умолчанию: неактивный аккаунт
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Users (Username, Email, RegistrationDate, Country, AccountStatus)
    VALUES (@Username, @Email, @RegistrationDate, @Country, @AccountStatus);
END;
GO

-- ВЫЗОВ
DECLARE @U NVARCHAR(100);
SET @U = N'Nisuev';
EXEC dbo.AddNewUser 
    @Username = @U,
    @Email = N'deadcool22@example.com',
    @RegistrationDate = '2024-10-12',
    @Country = N'Palestine',
    @AccountStatus = 1;
-- ЕСЛИ НУЖНО УДАЛИТЬ
DELETE FROM Users
WHERE Username = @U;

-- 6. Рекурсивная хранимая процедура
-- =============================================
-- Процедура: dbo.CalculateFactorialProc
-- Назначение: Рекурсивно вычисляет факториал заданного числа.
-- Параметры:
--     @Number INT - Число, факториал которого нужно вычислить
--     @Result BIGINT OUTPUT - Результат вычисления факториала
-- =============================================
IF OBJECT_ID('dbo.CalculateFactorialProc', 'P') IS NOT NULL
    DROP PROCEDURE dbo.CalculateFactorialProc;
GO
CREATE PROCEDURE dbo.CalculateFactorialProc
    @Number INT,
    @Result BIGINT OUTPUT
AS
BEGIN
    -- Проверка на отрицательное число
    IF @Number < 0
		BEGIN
			RAISERROR ('Число не может быть отрицательным.', 16, 1);
			RETURN;
		END

    ELSE IF @Number <= 1
		BEGIN
			SET @Result = 1;
		END
    ELSE
		BEGIN
			DECLARE @Temp BIGINT;
			DECLARE @PrevNum INT;
			SET @PrevNum = @Number - 1;
			-- Рекурсивный вызов процедуры
			EXEC dbo.CalculateFactorialProc @PrevNum, @Temp OUTPUT;
			SET @Result = @Number * @Temp;
		END
END;
GO

-- ВЫЗОВ ФАКТОРИАЛА ОТ 5
DECLARE @FactorialResult BIGINT;
EXEC dbo.CalculateFactorialProc @Number = 0, @Result = @FactorialResult OUTPUT;
SELECT @FactorialResult AS 'Factorial = ';


-- 7. Хранимая процедура с курсором
-- =============================================
-- Процедура: dbo.UpdateUserAccountStatus
-- Назначение: Обновляет статус аккаунтов пользователей на основе определенных условий.
-- Пример: Активирует всех пользователей из определенной страны.
-- Параметры:
--     @Country NVARCHAR(100) - Страна пользователей, статус которых нужно обновить
-- =============================================
IF OBJECT_ID('dbo.UpdateUserAccountStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.UpdateUserAccountStatus;
GO
CREATE PROCEDURE dbo.UpdateUserAccountStatus
    @Country NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserID INT;
    
    DECLARE UserCursor CURSOR FOR
    SELECT UserID
    FROM Users
    WHERE Country = @Country AND AccountStatus = 1;
    
    OPEN UserCursor;
    FETCH NEXT FROM UserCursor INTO @UserID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Users
        SET AccountStatus = 0
        WHERE UserID = @UserID;
        
        FETCH NEXT FROM UserCursor INTO @UserID;
    END
    
    CLOSE UserCursor;
    DEALLOCATE UserCursor;
END;
GO

-- ВЫЗОВ
EXEC dbo.UpdateUserAccountStatus @Country = N'Ukraine';



-- 8. Хранимая процедура доступа к метаданным
-- =============================================
-- Процедура: dbo.GetDatabaseTables
-- Назначение: Возвращает список всех таблиц в текущей базе данных.
-- Параметры: Отсутствуют
-- =============================================
IF OBJECT_ID('dbo.GetDatabaseTables', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetDatabaseTables;
GO
CREATE PROCEDURE dbo.GetDatabaseTables
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE';
END;
GO

-- ВЫЗОВ
EXEC dbo.GetDatabaseTables;



-- 9. AFTER-триггер
-- =============================================
-- Триггер: trg_AfterDeleteUsers
-- Назначение: Логирует удаленные записи из таблицы Users в таблицу UserDeletions.
-- =============================================
CREATE TABLE UserDeletions (
    DeletionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Username NVARCHAR(100),
    Email NVARCHAR(255),
    DeletionDate DATETIME DEFAULT GETDATE()
);
GO

DROP TRIGGER IF EXISTS trg_AfterDeleteUsers;
GO
CREATE TRIGGER trg_AfterDeleteUsers
ON Users
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO UserDeletions (UserID, Username, Email)
    SELECT d.UserID, d.Username, d.Email
    FROM deleted d;
END;
GO

-- ДОБАВЛЯЕМ
INSERT INTO Users (Username, Email, RegistrationDate, Country, AccountStatus)
VALUES (N'Kozyrnov', N'cas@example.com', '2024-01-01', N'Russian Federation', 1);
-- УДАЛЯЕМ, ЧТОБЫ СРАБОТАЛ ТРИГГЕР
DELETE FROM Users
WHERE Username = N'Kozyrnov';
-- ПРОВЕРЯЕМ ТАБЛИЦУ
SELECT * FROM UserDeletions;


-- УДАЛЕНИЕ ТАБЛИЦЫ И ТРИГГЕРА
DROP TABLE IF EXISTS UserDeletions;


-- 10. INSTEAD OF триггер
-- =============================================
-- Триггер: trg_InsteadOfInsertOrders
-- Назначение: Выполняет валидацию перед вставкой записей в таблицу Orders.
-- Если данные валидны, вставка выполняется, иначе - отменяется.
-- =============================================
DROP TRIGGER IF EXISTS trg_InsteadOfInsertOrders;
GO
CREATE TRIGGER trg_InsteadOfInsertOrders
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Пример валидации: Цена заказа должна быть неотрицательной
    IF EXISTS (SELECT 1 FROM inserted WHERE Price < 0)
    BEGIN
        RAISERROR ('Цена заказа не может быть отрицательной.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Если все проверки пройдены, выполняем вставку
    INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
    SELECT UserID, GameID, Price, Quantity, OrderDate
    FROM inserted;
END;
GO

-- ВЫЗОВ
INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
VALUES (1, 1, 500.00, 2, GETDATE());
-- очистка
DELETE FROM Orders WHERE Price = 500.00;

-- НЕУДАЧНЫЙ ВЫЗОВ
INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
VALUES (1, 1, -10.00, 2, GETDATE());
