USE RK2;
GO

DROP TABLE Region;
GO
DROP TABLE Sanatory;
GO
DROP TABLE Guest;
GO
DROP TABLE GuestSanatory;
GO

CREATE TABLE Region (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100),
    Description NVARCHAR(255)
);
GO

CREATE TABLE Sanatory (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100),
	Year INT,
    Description NVARCHAR(255),
	RegionID INT FOREIGN KEY REFERENCES Region(ID)
);
GO

CREATE TABLE Guest (
    ID INT PRIMARY KEY,
    FIO NVARCHAR(100),
	Birthday DATE,
	Location NVARCHAR(100),
    Email NVARCHAR(255)
);
GO

CREATE TABLE GuestSanatory (
    ID INT PRIMARY KEY,
    GuestID INT FOREIGN KEY REFERENCES Guest(ID),
	SanatoryID INT FOREIGN KEY REFERENCES Sanatory(ID),
);
GO

-- Заполнение таблицы Region
INSERT INTO Region (ID, Name, Description)
VALUES
(1, 'Калужская область', 'Регион с богатыми природными ресурсами и лечебными источниками.'),
(2, 'Московская область', 'Столица и её окрестности, развитая инфраструктура.'),
(3, 'Свердловская область', 'Промышленный центр с разнообразными климатическими условиями.'),
(4, 'Краснодарский край', 'Тёплый климат и прекрасные пляжи Черноморского побережья.'),
(5, 'Новосибирская область', 'Центральная Азия России с холодным климатом и уникальной природой.'),
(6, 'Республика Татарстан', 'Культурно-разнообразный регион с богатой историей.'),
(7, 'Приморский край', 'Дальний Восток с доступом к Тихому океану.'),
(8, 'Башкортостан', 'Регион с развитой промышленностью и живописными горами.'),
(9, 'Ставропольский край', 'Тёплый регион с благоприятным климатом для отдыха.'),
(10, 'Алтайский край', 'Горный регион с уникальными ландшафтами и чистым воздухом.');
GO
-- Заполнение таблицы Sanatory
INSERT INTO Sanatory (ID, Name, Year, Description, RegionID)
VALUES
(1, 'Санаторий "Здоровье"', 1995, 'Уютный санаторий с современными лечебными программами.', 1),
(2, 'Санаторий "Лазурный берег"', 2005, 'Санаторий у моря с панорамным видом.', 2),
(3, 'Санаторий "Северное сияние"', 2010, 'Специализируется на лечении заболеваний дыхательных путей.', 1),
(4, 'Санаторий "Березовая роща"', 1980, 'Традиционный санаторий с экологическим подходом.', 2),
(5, 'Санаторий "Росинка"', 1990, 'Разнообразные оздоровительные процедуры и спа.', 4),
(6, 'Санаторий "Вита"', 2000, 'Современные медицинские услуги и комфортное размещение.', 5),
(7, 'Санаторий "Солнечный остров"', 2015, 'Новейшие технологии в лечении и отдыхе.', 1),
(8, 'Санаторий "Морская сказка"', 1998, 'Отдых на берегу моря с лечебными программами.', 7),
(9, 'Санаторий "Горная прохлада"', 1985, 'Лечение в горных условиях с чистым воздухом.', 6),
(10, 'Санаторий "Эдельвейс"', 2008, 'Высокие стандарты обслуживания и индивидуальный подход.', 9);
GO
-- Заполнение таблицы Guest
INSERT INTO Guest (ID, FIO, Birthday, Location, Email)
VALUES
(1, 'Иванов Сергей Петрович', '1980-05-15', 'Москва', 'sergey.ivanov@example.com'),
(2, 'Петрова Анна Ивановна', '1990-07-22', 'Санкт-Петербург', 'anna.petrova@example.com'),
(3, 'Сидоров Алексей Николаевич', '1985-03-10', 'Новосибирск', 'aleksey.sidorov@example.com'),
(4, 'Кузнецова Мария Сергеевна', '1992-11-05', 'Екатеринбург', 'maria.kuznetsova@example.com'),
(5, 'Лебедев Дмитрий Андреевич', '1978-09-30', 'Казань', 'dmitry.lebedev@example.com'),
(6, 'Новикова Елена Викторовна', '1988-12-12', 'Нижний Новгород', 'elena.novikova@example.com'),
(7, 'Соколов Михаил Павлович', '1995-01-25', 'Челябинск', 'mikhail.sokolov@example.com'),
(8, 'Морозова Ольга Юрьевна', '1983-04-18', 'Самара', 'olga.morozova@example.com'),
(9, 'Волков Александр Игоревич', '1975-08-08', 'Ростов-на-Дону', 'alexander.volkov@example.com'),
(10, 'Васильева Наталья Александровна', '1991-06-17', 'Уфа', 'natalia.vasileva@example.com');
GO
-- Заполнение таблицы GuestSanatory
INSERT INTO GuestSanatory (ID, GuestID, SanatoryID)
VALUES
(1, 1, 1),  -- Иванов Сергей посещает "Здоровье"
(2, 2, 2),  -- Петрова Анна посещает "Лазурный берег"
(3, 3, 3),  -- Сидоров Алексей посещает "Северное сияние"
(4, 4, 1),  -- Кузнецова Мария посещает "Здоровье"
(5, 5, 4),  -- Лебедев Дмитрий посещает "Березовая роща"
(6, 6, 2),  -- Новикова Елена посещает "Лазурный берег"
(7, 7, 5),  -- Соколов Михаил посещает "Росинка"
(8, 8, 3),  -- Морозова Ольга посещает "Северное сияние"
(9, 9, 6),  -- Волков Александр посещает "Вита"
(10, 10, 2); -- Васильева Наталья посещает "Лазурный берег"
GO

-- 2.1
SELECT g.ID, CASE
	WHEN g.Birthday < '1980-01-01' THEN 'Oldman'
	WHEN g.Birthday >= '1980-01-01' THEN 'Freshman' END AS Type
FROM Guest g;
--WHERE g.Birthday >= '1980-01-01';
GO

-- 2.2
SELECT * FROM Guest;
UPDATE Guest
SET Birthday = (SELECT MAX(g.Birthday)
				  FROM Guest g
				  )
WHERE Birthday >= '1980-01-01';
SELECT * FROM Guest;
-- 2.3
SELECT g.FIO, MAX(g.Birthday)
FROM Guest g
GROUP BY g.FIO
HAVING MAX(g.Birthday) > '1980-01-01';
GO
-- 2.3
SELECT RegionID,
       COUNT(ID) AS NumberOfSanatoriums,
       AVG(Year) AS AvgFoundationYear
FROM Sanatory S
GROUP BY RegionID
HAVING AVG(Year) > 1990;

-- 3
SELECT * FROM sys.views;
GO

CREATE PROCEDURE DeleteAllViews
@cnt INT OUTPUT
AS
BEGIN
	SET @cnt = 0;
	DECLARE @name NVARCHAR(150);

	DECLARE cur CURSOR FOR
	SELECT name FROM sys.views;
	OPEN cur
	FETCH NEXT FROM cur INTO @name;

	DECLARE @SQL NVARCHAR(MAX);
	WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @SQL = 'DROP VIEW ' + @name;
        EXEC sp_executesql @SQL;
        SET @cnt = @cnt + 1;

		FETCH NEXT FROM cur INTO @name;
	END
	CLOSE cur;
	DEALLOCATE cur;
END;
GO


DECLARE @c INT;
EXEC DeleteAllViews @c OUTPUT;
SELECT @c;

CREATE VIEW A1112AAVIEW AS
SELECT *
FROM Sanatory;
GO

