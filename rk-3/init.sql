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
    Type INT CHECK(Type IN (0, 1)), -- 0 = ������, 1 = �����
    FOREIGN KEY (ID_Sputnik) REFERENCES satellites(ID_Sputnik)
);

INSERT INTO satellites (Name, ProductionDate, Country)
VALUES
(N'�-45', '2049-05-05', N'�������'),
(N'SIT-2086', '2050-01-01', N'������'),
(N'������ 16-02', '2049-12-01', N'�����'),
(N'�����������', '2049-12-06', N'�������'),
(N'���', '2050-05-05', N'������'),
(N'���-07', '2024-07-05', N'������'),
(N'UG-129', '2049-05-05', N'�������');
INSERT INTO flights (ID_Sputnik, LaunchDate, LaunchTime, DayOfWeek, Type)
VALUES
(5, '2024-10-10', '15:15:00', N'�����', 1),
(5, '2024-10-10', '15:45:00', N'�����', 0),
(4, '2024-10-09', '15:15:00', N'�����', 1),
(4, '2024-10-09', '15:45:00', N'�����', 0),
(6, '2024-08-09', '12:15:00', N'�����������', 0),
(6, '2024-12-12', '12:15:00', N'�����������', 1),
(1, '2050-05-11', '09:00:00', N'�����', 1),
(1, '2051-06-14', '23:05:00', N'�����', 0),
(1, '2051-10-10', '23:50:00', N'�������', 1),
(2, '2050-05-11', '15:15:00', N'�����', 1),
(1, '2052-01-01', '12:15:00', N'�����������', 0);

-- === 1.1 ===
-- ������ ���������� ��� ��������, ��� ������� � ������� flight ��� �� ����� ������ � ������.
-- �� ���� �� ���� ��������, �� ������������� � ������.
SELECT s.*
FROM satellites s
WHERE s.ID_Sputnik NOT IN (SELECT f.ID_Sputnik FROM flight f);
-- === 1.2 ===
-- ������ ������� ��� �������, � �������� ������������ ����� ������, � ���������� ������ ��� (���� ���������).
SELECT TOP 1 ID_Sputnik
FROM flights
GROUP BY ID_Sputnik
ORDER BY COUNT(*) DESC;

-- === 2.1 ===
-- ����� ������, � ������� ����������� �������� ������������ ������ � ���
SELECT Country
FROM satellites
GROUP BY Country
HAVING COUNT(*) > 0
  AND COUNT(CASE WHEN MONTH(ProductionDate)=5 THEN 1 END)=COUNT(*);

-- === 2.2 ===
-- ����� ��������, ������� �� ������������ � ������� ����� ������������ ����
SELECT s.ID_Sputnik, s.Name
FROM satellites s
WHERE s.ID_Sputnik NOT IN (
    SELECT f.ID_Sputnik
    FROM flights f
    WHERE f.Type = 1
      AND YEAR(f.LaunchDate) = YEAR(GETDATE())
);

-- === 2.3 ===
-- ����� ��� ������, � ������� ���� ���� �� ���� ����������� �������, ������ ������ �������� ��� ����� 2024-10-01
SELECT DISTINCT s.Country
FROM satellites s
WHERE s.ID_Sputnik IN (
    SELECT ID_Sputnik
    FROM flights
    GROUP BY ID_Sputnik
    HAVING MIN(LaunchDate) > '2024-10-01'
);