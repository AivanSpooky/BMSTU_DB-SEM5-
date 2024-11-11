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
(1, 'Информатика', 'Факультет, отвечающий за обучение в области компьютерных наук и информационных технологий.'),
(2, 'Математика', 'Факультет, специализирующийся на математических науках и исследованиях.'),
(3, 'Физика', 'Факультет, занимающийся изучением физических явлений и теорий.'),
(4, 'Химия', 'Факультет, посвященный химическим наукам и исследованиям.'),
(5, 'Биология', 'Факультет, сфокусированный на изучении живых организмов и их взаимодействий.'),
(6, 'История', 'Факультет, изучающий события прошлого и их влияние на настоящее.'),
(7, 'Литература', 'Факультет, посвященный литературным исследованиям и творчеству.'),
(8, 'Экономика', 'Факультет, занимающийся экономическими теориями и практиками.'),
(9, 'Философия', 'Факультет, исследующий фундаментальные вопросы бытия и мышления.'),
(10, 'Психология', 'Факультет, изучающий поведение и умственные процессы человека.');
GO
INSERT INTO Professors (ID, FIO, Degree, Position, DepartmentID)
VALUES
(1, 'Александр Иванович Смирнов', 'Доктор наук', 'Профессор', 1),
(2, 'Мария Петровна Кузнецова', 'Кандидат наук', 'Доцент', 2),
(3, 'Сергей Викторович Лебедев', 'Доктор наук', 'Профессор', 3),
(4, 'Елена Сергеевна Новикова', 'Кандидат наук', 'Доцент', 4),
(5, 'Дмитрий Александрович Соколов', 'Доктор наук', 'Профессор', 5),
(6, 'Ольга Игоревна Морозова', 'Кандидат наук', 'Доцент', 6),
(7, 'Игорь Николаевич Волков', 'Доктор наук', 'Профессор', 7),
(8, 'Наталья Владимировна Васильева', 'Кандидат наук', 'Доцент', 8),
(9, 'Павел Юрьевич Козлов', 'Доктор наук', 'Профессор', 9),
(10, 'Анна Андреевна Дмитриева', 'Кандидат наук', 'Доцент', 10);
GO
INSERT INTO Subjects (ID, Name, Hours, Semester, Rating)
VALUES
(1, 'Программирование на Python', 60, 1, 5),
(2, 'Дифференциальное исчисление', 45, 1, 4),
(3, 'Механика', 50, 1, 4),
(4, 'Органическая химия', 40, 2, 3),
(5, 'Биология человека', 35, 2, 4),
(6, 'Всемирная история', 30, 2, 3),
(7, 'Анализ литературы', 25, 1, 5),
(8, 'Макроэкономика', 40, 2, 4),
(9, 'Этика и философия', 20, 1, 5),
(10, 'Психология развития', 30, 2, 4);
GO
INSERT INTO ProfessorSubjects (PSID, ProfessorID, SubjectID)
VALUES
(1, 1, 1),  -- Александр Смирнов преподает Программирование на Python
(2, 2, 2),  -- Мария Кузнецова преподает Дифференциальное исчисление
(3, 3, 3),  -- Сергей Лебедев преподает Механика
(4, 4, 4),  -- Елена Новикова преподает Органическая химия
(5, 5, 5),  -- Дмитрий Соколов преподает Биология человека
(6, 6, 6),  -- Ольга Морозова преподает Всемирная история
(7, 7, 7),  -- Игорь Волков преподает Анализ литературы
(8, 8, 8),  -- Наталья Васильева преподает Макроэкономику
(9, 9, 9),  -- Павел Козлов преподает Этику и философию
(10, 10, 10);-- Анна Дмитриева преподает Психологию развития
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