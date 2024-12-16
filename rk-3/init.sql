CREATE DATABASE RK3;
GO
ALTER DATABASE RK3 SET TRUSTWORTHY ON;
GO
USE RK3;
GO

CREATE TABLE satellites (
    ID_Sputnik INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL,
    ProductionDate DATE NOT NULL,
    Country NVARCHAR(100) NOT NULL
);

CREATE TABLE flights (
	ID_Flight INT PRIMARY KEY IDENTITY,
    ID_Sputnik INT NOT NULL,
    LaunchDate DATE NOT NULL,
    LaunchTime TIME NOT NULL,
    DayOfWeek NVARCHAR(20),
    Type INT CHECK(Type IN (0, 1)), -- 0 = прилет, 1 = вылет
    FOREIGN KEY (ID_Sputnik) REFERENCES satellites(ID_Sputnik)
);

INSERT INTO satellites (Name, ProductionDate, Country)
VALUES
(N'Я-45', '2049-05-05', N'Абхазия'),
(N'SIT-2086', '2050-01-01', N'Россия'),
(N'Шицзян 16-02', '2049-12-01', N'Китай'),
(N'КозырновКАС', '2049-12-06', N'Абхазия'),
(N'КАС', '2050-05-05', N'Сомали'),
(N'КАС-07', '2024-07-05', N'Россия'),
(N'UG-129', '2049-05-05', N'Уругвай');
INSERT INTO flights (ID_Sputnik, LaunchDate, LaunchTime, DayOfWeek, Type)
VALUES
(5, '2024-10-10', '15:15:00', N'Среда', 1),
(5, '2024-10-10', '15:45:00', N'Среда', 0),
(4, '2024-10-09', '15:15:00', N'Среда', 1),
(4, '2024-10-09', '15:45:00', N'Среда', 0),
(6, '2024-08-09', '12:15:00', N'Понедельник', 0),
(6, '2024-12-12', '12:15:00', N'Понедельник', 1),
(1, '2050-05-11', '09:00:00', N'Среда', 1),
(1, '2051-06-14', '23:05:00', N'Среда', 0),
(1, '2051-10-10', '23:50:00', N'Вторник', 1),
(2, '2050-05-11', '15:15:00', N'Среда', 1),
(1, '2052-01-01', '12:15:00', N'Понедельник', 0);

-- === 1.1 ===
-- Запрос возвращает все спутники, для которых в таблице flight нет ни одной записи о полётах.
-- То есть мы ищем спутники, не участвовавшие в полётах.
SELECT s.*
FROM satellites s
WHERE s.ID_Sputnik NOT IN (SELECT f.ID_Sputnik FROM flight f);
-- === 1.2 ===
-- Запрос находит тот спутник, у которого максимальное число полётов, и возвращает только его (один результат).
SELECT TOP 1 ID_Sputnik
FROM flights
GROUP BY ID_Sputnik
ORDER BY COUNT(*) DESC;

-- === 2.1 ===
-- Найти страны, в которых космические аппараты производятся только в мае
SELECT Country
FROM satellites
GROUP BY Country
HAVING COUNT(*) > 0
  AND COUNT(CASE WHEN MONTH(ProductionDate)=5 THEN 1 END)=COUNT(*);

-- === 2.2 ===
-- Найти спутники, которые не возвращались в течение этого календарного года
SELECT s.ID_Sputnik, s.Name
FROM satellites s
WHERE s.ID_Sputnik NOT IN (
    SELECT f.ID_Sputnik
    FROM flights f
    WHERE f.Type = 1
      AND YEAR(f.LaunchDate) = YEAR(GETDATE())
);

-- === 2.3 ===
-- Найти все страны, в которых есть хотя бы один космический аппарат, первый запуск которого был после 2024-10-01
SELECT DISTINCT s.Country
FROM satellites s
WHERE s.ID_Sputnik IN (
    SELECT ID_Sputnik
    FROM flights
    GROUP BY ID_Sputnik
    HAVING MIN(LaunchDate) > '2024-10-01'
);