CREATE DATABASE RK2;
GO

USE RK2;
GO

DROP TABLE IF EXISTS Departments;
GO
DROP TABLE IF EXISTS Professors;
GO
DROP TABLE IF EXISTS Subjects;
GO
DROP TABLE IF EXISTS ProfessorSubjects;
GO

-- Departments
CREATE TABLE Departments (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Description NVARCHAR(255)
);
GO

-- Professors
CREATE TABLE Professors (
    ID INT PRIMARY KEY,
    FIO NVARCHAR(100),
    Degree NVARCHAR(50),
    Position NVARCHAR(50),
    DepartmentID INT FOREIGN KEY REFERENCES Departments(ID)
);
GO

-- Subjects
CREATE TABLE Subjects (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Hours INT,
    Semester INT,
    Rating INT
);
GO

-- ProfessorsSubjects
CREATE TABLE ProfessorSubjects (
	PSID INT PRIMARY KEY,
    ProfessorID INT FOREIGN KEY REFERENCES Professors(ID),
    SubjectID INT FOREIGN KEY REFERENCES Subjects(ID),
);
GO

INSERT INTO Departments (ID, Name, Description)
VALUES
(1, '�����������', '���������, ���������� �� �������� � ������� ������������ ���� � �������������� ����������.'),
(2, '����������', '���������, ������������������ �� �������������� ������ � �������������.'),
(3, '������', '���������, ������������ ��������� ���������� ������� � ������.'),
(4, '�����', '���������, ����������� ���������� ������ � �������������.'),
(5, '��������', '���������, ��������������� �� �������� ����� ���������� � �� ��������������.'),
(6, '�������', '���������, ��������� ������� �������� � �� ������� �� ���������.'),
(7, '����������', '���������, ����������� ������������ ������������� � ����������.'),
(8, '���������', '���������, ������������ �������������� �������� � ����������.'),
(9, '���������', '���������, ����������� ��������������� ������� ����� � ��������.'),
(10, '����������', '���������, ��������� ��������� � ���������� �������� ��������.');
GO
INSERT INTO Professors (ID, FIO, Degree, Position, DepartmentID)
VALUES
(1, '��������� �������� �������', '������ ����', '���������', 1),
(2, '����� �������� ���������', '�������� ����', '������', 2),
(3, '������ ���������� �������', '������ ����', '���������', 3),
(4, '����� ��������� ��������', '�������� ����', '������', 4),
(5, '������� ������������� �������', '������ ����', '���������', 5),
(6, '����� �������� ��������', '�������� ����', '������', 6),
(7, '����� ���������� ������', '������ ����', '���������', 7),
(8, '������� ������������ ���������', '�������� ����', '������', 8),
(9, '����� ������� ������', '������ ����', '���������', 9),
(10, '���� ��������� ���������', '�������� ����', '������', 10);
GO
INSERT INTO Subjects (ID, Name, Hours, Semester, Rating)
VALUES
(1, '���������������� �� Python', 60, 1, 5),
(2, '���������������� ����������', 45, 1, 4),
(3, '��������', 50, 1, 4),
(4, '������������ �����', 40, 2, 3),
(5, '�������� ��������', 35, 2, 4),
(6, '��������� �������', 30, 2, 3),
(7, '������ ����������', 25, 1, 5),
(8, '��������������', 40, 2, 4),
(9, '����� � ���������', 20, 1, 5),
(10, '���������� ��������', 30, 2, 4);
GO
INSERT INTO ProfessorSubjects (PSID, ProfessorID, SubjectID)
VALUES
(1, 1, 1),  -- ��������� ������� ��������� ���������������� �� Python
(2, 2, 2),  -- ����� ��������� ��������� ���������������� ����������
(3, 3, 3),  -- ������ ������� ��������� ��������
(4, 4, 4),  -- ����� �������� ��������� ������������ �����
(5, 5, 5),  -- ������� ������� ��������� �������� ��������
(6, 6, 6),  -- ����� �������� ��������� ��������� �������
(7, 7, 7),  -- ����� ������ ��������� ������ ����������
(8, 8, 8),  -- ������� ��������� ��������� ��������������
(9, 9, 9),  -- ����� ������ ��������� ����� � ���������
(10, 10, 10);-- ���� ��������� ��������� ���������� ��������
GO

SELECT * FROM Departments

-- 1.1
SELECT *
FROM Subjects S
WHERE S.Hours >= ALL (SELECT Hours FROM Subjects);
GO
-- 2.2
SELECT S.Name, SUM(S.Hours)
FROM Subjects S
GROUP BY S.Name;
GO
-- 2.2
SELECT DepartmentID,
       COUNT(P.ID) AS ProfessorCount,
       AVG(Rating) AS AverageSubjectRating
FROM Professors AS P
JOIN ProfessorSubjects AS PS ON P.ID = PS.ProfessorID
JOIN Subjects AS S ON PS.SubjectID = S.ID
GROUP BY DepartmentID;
GO
-- 2.3
WITH NewTable(ID, AAA, BBB, CCX, DDD) AS (
SELECT *
FROM Subjects
) SELECT * FROM NewTable;
GO

-- 3
--SELECT * FROM sys.indexes;

--CREATE INDEX AAAA
--ON Subjects (Name, Rating);
--GO

CREATE PROCEDURE GetTableIndexes
    @TableName NVARCHAR(128)
AS
BEGIN
    SELECT ind.name AS IndexName
    FROM sys.indexes ind
    JOIN sys.tables t ON ind.object_id = t.object_id
    WHERE t.name = @TableName
    ORDER BY ind.name;
END;
GO

-- DROP PROCEDURE GetTableIndexes;

-- Testing the stored procedure
EXEC GetTableIndexes @TableName = 'Subjects';