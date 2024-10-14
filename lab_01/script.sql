-- �������� ���� ������
CREATE DATABASE GamingPlatform;
GO
ALTER DATABASE GamingPlatform SET TRUSTWORTHY ON;
-- ������������� ���� ������
USE GamingPlatform;
GO

-- �������� ������� Users ��� �����������
CREATE TABLE Users (
    UserID INT IDENTITY(1,1),
    Username NVARCHAR(100),
    Email NVARCHAR(255),
    RegistrationDate DATE,
    Country NVARCHAR(100),
    AccountStatus BIT
);
GO

-- �������� ������� Developers ��� �����������
CREATE TABLE Developers (
    DeveloperID INT IDENTITY(1,1),
    Name NVARCHAR(255),
    Country NVARCHAR(100),
    Founded DATE,
    Website NVARCHAR(255),
    EmployeeCount INT
);
GO

-- �������� ������� Categories ��� �����������
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1),
    CategoryName NVARCHAR(100),
    Description NVARCHAR(255)
);
GO

-- �������� ������� Games ��� �����������
CREATE TABLE Games (
    GameID INT IDENTITY(1,1),
    Title NVARCHAR(255),
    ReleaseDate DATE,
    Description NVARCHAR(100),
	CategoryID INT,
    DeveloperID INT,
	Price DECIMAL(10, 2),
    MinSystemRequirements NVARCHAR(MAX),
	Discontinued BIT
);
GO

-- �������� ������� Orders ��� �����������
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1),
    UserID INT,
    GameID INT,
    Price DECIMAL(10, 2),
    Quantity INT,
    OrderDate DATE
);
GO

-- �������� ������� Reviews ��� �����������
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1),
    UserID INT,
    GameID INT,
    ReviewText NVARCHAR(MAX),
    GameRating INT
);
GO