-- �������� ���� ������
CREATE DATABASE GamingPlatform;
GO

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

-- �������� ������� Games ��� �����������
CREATE TABLE Games (
    GameID INT IDENTITY(1,1),
    Title NVARCHAR(255),
    ReleaseDate DATE,
    Genre NVARCHAR(100),
    DeveloperID INT,
    MinSystemRequirements NVARCHAR(MAX)
);
GO

-- �������� ������� Reviews ��� �����������
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1),
    UserID INT,
    GameID INT,
    DeveloperID INT,
    ReviewText NVARCHAR(MAX),
    GameRating INT
);
GO