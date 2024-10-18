-- ���������� ���� ������
USE GamingPlatform;
GO

-- 1. ��������� �������
-- =============================================
-- �������: dbo.GetUserRegistrationDays
-- ����������: ���������� ���������� ����, ��������� � ���� ����������� ������������.
-- ���������:
--     @UserID INT - ������������� ������������
-- ������������ ��������:
--     INT - ���������� ���� � ���� �����������
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

-- �����
SET STATISTICS TIME ON;
SELECT dbo.GetUserRegistrationDays(1) AS RegistrationDays;
SET STATISTICS TIME OFF;



-- 2. ������������� ��������� �������
-- =============================================
-- �������: dbo.GetGamesByCategory
-- ����������: ���������� ������ ���, ������������� ��������� ���������.
-- ���������:
--     @CategoryName NVARCHAR(100) - �������� ���������
-- ������������ �������:
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


-- �����
SET STATISTICS TIME ON;
SELECT *
FROM dbo.GetGamesByCategory(N'Action');
SET STATISTICS TIME OFF;

--=== ������ ===
-- ������� ��� ������, � ������� ������ ���� � ������ @GameTitle
-- ������ ��� ������������� ��������� �������
-- =============================================
-- �������: dbo.GetGamesByGameTitle
-- ����������: ���������� ������ �������, � ������� ������ ���� � �������� ���������.
-- ���������:
--     @GameTitle NVARCHAR(255) - �������� ����
-- ������������ �������:
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

--�����
SELECT *
FROM dbo.GetGamesByGameTitle(N'Game-110')
--===


-- 3. ���������������� ��������� �������
-- =============================================
-- �������: dbo.GetUserOrderSummary
-- ����������: ���������� ������� ���������� � ������� ������������.
-- ���������:
--     @UserID INT - ������������� ������������
-- ������������ �������:
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

-- �����
SELECT *
FROM dbo.GetUserOrderSummary(5);

-- 4. ����������� �������
-- =============================================
-- �������: dbo.CalculateFactorial
-- ����������: ���������� ��������� ��������� ��������� �����.
-- ���������:
--     @Number INT - �����, ��������� �������� ����� ���������
-- ������������ ��������:
--     BIGINT - ��������� �����
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

-- �����
SELECT dbo.CalculateFactorial(6) AS FactorialResult;

-- 5. �������� ��������� � �����������
-- =============================================
-- ���������: dbo.AddNewUser
-- ����������: ��������� ������ ������������ � ������� Users.
-- ���������:
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
    @AccountStatus BIT = 0 -- �������� �� ���������: ���������� �������
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Users (Username, Email, RegistrationDate, Country, AccountStatus)
    VALUES (@Username, @Email, @RegistrationDate, @Country, @AccountStatus);
END;
GO

-- �����
DECLARE @U NVARCHAR(100);
SET @U = N'Nisuev';
EXEC dbo.AddNewUser 
    @Username = @U,
    @Email = N'deadcool22@example.com',
    @RegistrationDate = '2024-10-12',
    @Country = N'Palestine',
    @AccountStatus = 1;
-- ���� ����� �������
DELETE FROM Users
WHERE Username = @U;

-- 6. ����������� �������� ���������
-- =============================================
-- ���������: dbo.CalculateFactorialProc
-- ����������: ���������� ��������� ��������� ��������� �����.
-- ���������:
--     @Number INT - �����, ��������� �������� ����� ���������
--     @Result BIGINT OUTPUT - ��������� ���������� ����������
-- =============================================
IF OBJECT_ID('dbo.CalculateFactorialProc', 'P') IS NOT NULL
    DROP PROCEDURE dbo.CalculateFactorialProc;
GO
CREATE PROCEDURE dbo.CalculateFactorialProc
    @Number INT,
    @Result BIGINT OUTPUT
AS
BEGIN
    -- �������� �� ������������� �����
    IF @Number < 0
		BEGIN
			RAISERROR ('����� �� ����� ���� �������������.', 16, 1);
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
			-- ����������� ����� ���������
			EXEC dbo.CalculateFactorialProc @PrevNum, @Temp OUTPUT;
			SET @Result = @Number * @Temp;
		END
END;
GO

-- ����� ���������� �� 5
DECLARE @FactorialResult BIGINT;
EXEC dbo.CalculateFactorialProc @Number = 0, @Result = @FactorialResult OUTPUT;
SELECT @FactorialResult AS 'Factorial = ';


-- 7. �������� ��������� � ��������
-- =============================================
-- ���������: dbo.UpdateUserAccountStatus
-- ����������: ��������� ������ ��������� ������������� �� ������ ������������ �������.
-- ������: ���������� ���� ������������� �� ������������ ������.
-- ���������:
--     @Country NVARCHAR(100) - ������ �������������, ������ ������� ����� ��������
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

-- �����
EXEC dbo.UpdateUserAccountStatus @Country = N'Ukraine';



-- 8. �������� ��������� ������� � ����������
-- =============================================
-- ���������: dbo.GetDatabaseTables
-- ����������: ���������� ������ ���� ������ � ������� ���� ������.
-- ���������: �����������
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

-- �����
EXEC dbo.GetDatabaseTables;



-- 9. AFTER-�������
-- =============================================
-- �������: trg_AfterDeleteUsers
-- ����������: �������� ��������� ������ �� ������� Users � ������� UserDeletions.
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

-- ���������
INSERT INTO Users (Username, Email, RegistrationDate, Country, AccountStatus)
VALUES (N'Kozyrnov', N'cas@example.com', '2024-01-01', N'Russian Federation', 1);
-- �������, ����� �������� �������
DELETE FROM Users
WHERE Username = N'Kozyrnov';
-- ��������� �������
SELECT * FROM UserDeletions;


-- �������� ������� � ��������
DROP TABLE IF EXISTS UserDeletions;


-- 10. INSTEAD OF �������
-- =============================================
-- �������: trg_InsteadOfInsertOrders
-- ����������: ��������� ��������� ����� �������� ������� � ������� Orders.
-- ���� ������ �������, ������� �����������, ����� - ����������.
-- =============================================
DROP TRIGGER IF EXISTS trg_InsteadOfInsertOrders;
GO
CREATE TRIGGER trg_InsteadOfInsertOrders
ON Orders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ������ ���������: ���� ������ ������ ���� ���������������
    IF EXISTS (SELECT 1 FROM inserted WHERE Price < 0)
    BEGIN
        RAISERROR ('���� ������ �� ����� ���� �������������.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- ���� ��� �������� ��������, ��������� �������
    INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
    SELECT UserID, GameID, Price, Quantity, OrderDate
    FROM inserted;
END;
GO

-- �����
INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
VALUES (1, 1, 500.00, 2, GETDATE());
-- �������
DELETE FROM Orders WHERE Price = 500.00;

-- ��������� �����
INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
VALUES (1, 1, -10.00, 2, GETDATE());
