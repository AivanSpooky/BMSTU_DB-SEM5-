-- =========================
-- Смирнов Иван Владимирович
-- ИУ7-52Б
-- РК2 Вариант 4
-- Запускать на MSSQL
-- =========================

-- Создание БД
CREATE DATABASE RK2;
GO
-- Использование БД
USE RK2;
GO

-- Создание таблицы Группа
CREATE TABLE CGroup (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100),
    TeacherFIO NVARCHAR(255),
	HoursAmount INT
);
GO

-- Создание таблицы Ребенок (Дети)
CREATE TABLE Child (
    ID INT PRIMARY KEY,
    FIO NVARCHAR(255),
    Birthday DATE,
	Sex NVARCHAR(100),
    Position NVARCHAR(255),
	Department NVARCHAR(255),
    CGroupID INT FOREIGN KEY REFERENCES CGroup(ID)
);
GO

-- Создание таблицы Родитель (и)
CREATE TABLE Parent (
    ID INT PRIMARY KEY,
    FIO NVARCHAR(255),
    Age INT,
    PType NVARCHAR(100)
);
GO

-- Создание таблицы-связки РОДИТЕЛЬ-РЕБЕНОК
CREATE TABLE ParentToChild (
	PCID INT PRIMARY KEY,
    ParentID INT FOREIGN KEY REFERENCES Parent(ID),
    ChildID INT FOREIGN KEY REFERENCES Child(ID),
);
GO

-- Вставка 10 записей в CGroup
INSERT INTO CGroup (ID, Name, TeacherFIO, HoursAmount) VALUES
	   (1,  'Group A', 'Alexander Odnodvorcev-1', 40),
       (2,  'Group B', 'Alexander Odnodvorcev-2', 35),
       (3,  'Group C', 'Alexander Odnodvorcev-3', 30),
       (4,  'Group D', 'Alexander Odnodvorcev-4', 25),
       (5,  'Group E', 'Alexander Odnodvorcev-5', 20),
       (6,  'Group F', 'Alexander Odnodvorcev-6', 45),
       (7,  'Group G', 'Alexander Odnodvorcev-7', 50),
       (8,  'Group H', 'Alexander Odnodvorcev-8', 55),
       (9,  'Group I', 'Alexander Odnodvorcev-9', 60),
       (10, 'Group J', 'Alexander Odnodvorcev-10', 65);
GO

-- Вставка 10 записей в Child
INSERT INTO Child (ID, FIO, Birthday, Sex, Position, Department, CGroupID) VALUES
	   (1,  'ChildFIO-1', '2020-04-05', 'Female', 'Student', 'IU7', 1),
       (2,  'ChildFIO-2', '2022-07-15', 'Male', 'Student', 'IU7', 1),
       (3,  'ChildFIO-3', '2001-09-10', 'Male', 'Student', 'IU7', 2),
       (4,  'ChildFIO-4', '2013-11-20', 'Female', 'Student', 'IU6', 2),
       (5,  'ChildFIO-5', '2010-01-22', 'Male', 'Student', 'IU6', 3),
       (6,  'ChildFIO-6', '2009-06-18', 'Female', 'Student', 'RK6', 4),
       (7,  'ChildFIO-7', '2011-03-30', 'Male', 'Student', 'RK6', 5),
       (8,  'ChildFIO-8', '2002-12-24', 'Female', 'Student', 'IU7', 6),
       (9,  'ChildFIO-9', '2010-05-15', 'Male', 'Student', 'RK6', 7),
       (10, 'ChildFIO-10', '2019-08-28', 'Female', 'Student', 'IU7', 8);
GO

-- Вставка 10 записей в Parent
INSERT INTO Parent (ID, FIO, Age, PType) VALUES
	   (1,  'ParentFIO-1', 35, 'Mother'),
       (2,  'ParentFIO-2', 40, 'Father'),
       (3,  'ParentFIO-3', 32, 'Mother'),
       (4,  'ParentFIO-4', 38, 'Father'),
       (5,  'ParentFIO-5', 34, 'Mother'),
       (6,  'ParentFIO-6', 41, 'Father'),
       (7,  'ParentFIO-7', 37, 'Mother'),
       (8,  'ParentFIO-8', 39, 'Father'),
       (9,  'ParentFIO-9', 36, 'Mother'),
       (10, 'ParentFIO-10', 42, 'Father');
GO

-- Вставка 10 записей в ParentToChild
INSERT INTO ParentToChild (PCID, ParentID, ChildID) VALUES
       (1, 1, 1),
       (2, 2, 1),
       (3, 3, 3),
       (4, 4, 2),
       (5, 5, 5),
       (6, 6, 3),
       (7, 7, 8),
       (8, 8, 8),
       (9, 9, 9),
       (10, 10, 10);
GO

-- ==================================================
-- 2.1) SELECT, использующая поисковое выражение CASE
-- Запрос возвращает табличку из двух атрибутов
-- -ФИО ребенка
-- -Возрастная группа ребенка
-- Возрастная группа ребенка узнается с помощью CASE
-- ==================================================
SELECT FIO AS ChildName,
    CASE 
		WHEN DATEDIFF(YEAR, Birthday, GETDATE()) < 5 THEN 'Toddler'
        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) BETWEEN 5 AND 12 THEN 'Young Child'
		WHEN DATEDIFF(YEAR, Birthday, GETDATE()) BETWEEN 13 AND 18 THEN 'Teenager'
        ELSE 'Adult'
    END AS AgeGroup
FROM Child;
GO

-- ===============================================================================================================
-- 2.2) UPDATE со скалярным подзапросом в предложении SET
-- Запрос переопределяет количество часов групп, в которых изначально меньше 30 часов, на среднее среди всех групп 
-- Скалярный подзапрос = SELECT AVG(HoursAmount) FROM CGroup
-- ===============================================================================================================
UPDATE CGroup
SET HoursAmount = (SELECT AVG(HoursAmount) FROM CGroup)
WHERE HoursAmount < 30;
GO

-- ==========================================================================================
-- 2.3) SELECT консолидирующий данные с помощью GROUP BY и HAVING
-- Запрос выводит информацию о группах, в которых состоят больше 1 ребенка, в следующем виде:
-- -CGroupID
-- -Количество детей в этой группе
-- -Средний возраст детей в этой группе
-- ==========================================================================================
SELECT CGroupID, COUNT(ID) AS TotalChildren, AVG(DATEDIFF(YEAR, Birthday, GETDATE())) AS AvgAge
FROM Child
GROUP BY CGroupID
HAVING COUNT(ID) > 1;
GO



-- ================================================================================================================================
-- 3) Хранимая процедура без параметров, которая осуществляет поиск ключевого слова 'EXEC' в тексте хранимых процедур в текущей БД.
--    Хранимая процедура выводит инструкцию 'EXEC' которая выполняет хранимую процедуру или скалярную пользовательскую функцию.
-- ================================================================================================================================
CREATE PROCEDURE SearchKeyword AS
BEGIN
    SELECT OBJECT_NAME(object_id) AS ProcedureName,
	-- Параметры SUBSTRING: строка, начало, длина
	-- Параметры CHARINDEX: что найти, где найти, начало откуда находить
	SUBSTRING(
            definition, 
            CHARINDEX('EXEC', definition), -- начальная позиция EXEC
            CHARINDEX(';', definition + ';', CHARINDEX('EXEC', definition)) -- начальная позиция ; после EXEC
			- CHARINDEX('EXEC', definition) + 1 -- из позиции ; вычитаем позицию EXEC и прибавляем 1, чтобы узнать длину инструкции EXEC внутри процедуры
        ) AS ExecInstruction
    FROM sys.sql_modules
    WHERE definition LIKE '%EXEC%' -- есть EXEC
      AND OBJECTPROPERTY(object_id, 'IsProcedure') = 1 -- хранимая процедура
	  AND OBJECT_NAME(object_id) != 'SearchKeyword'; -- исключаем себя
END;
GO

-- =====================================================================
-- Создаем тестовые 2 процедуры, одна из которых содержит EXEC на другую
-- Созданная по заданию хранимая процедура должна найти DUMMYPROCEXAMPLE
-- и вывести инструкцию EXEC DUMMYPROC;
-- =====================================================================
CREATE PROCEDURE DUMMYPROC AS
BEGIN
    RETURN 1;
END;
GO
CREATE PROCEDURE DUMMYPROCEXAMPLE AS
BEGIN
	EXEC DUMMYPROC;
    RETURN 'DUMMY-FUNC';
END;
GO

-- Тестирование хранимой процедуры
EXEC SearchKeyword;
GO