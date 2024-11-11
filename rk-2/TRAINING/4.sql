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

-- ���������� ������� Region
INSERT INTO Region (ID, Name, Description)
VALUES
(1, '��������� �������', '������ � �������� ���������� ��������� � ��������� �����������.'),
(2, '���������� �������', '������� � � �����������, �������� ��������������.'),
(3, '������������ �������', '������������ ����� � �������������� �������������� ���������.'),
(4, '������������� ����', 'Ҹ���� ������ � ���������� ����� ������������� ���������.'),
(5, '������������� �������', '����������� ���� ������ � �������� �������� � ���������� ��������.'),
(6, '���������� ���������', '���������-������������� ������ � ������� ��������.'),
(7, '���������� ����', '������� ������ � �������� � ������ ������.'),
(8, '������������', '������ � �������� ��������������� � ����������� ������.'),
(9, '�������������� ����', 'Ҹ���� ������ � ������������� �������� ��� ������.'),
(10, '��������� ����', '������ ������ � ����������� ����������� � ������ ��������.');
GO
-- ���������� ������� Sanatory
INSERT INTO Sanatory (ID, Name, Year, Description, RegionID)
VALUES
(1, '��������� "��������"', 1995, '������ ��������� � ������������ ��������� �����������.', 1),
(2, '��������� "�������� �����"', 2005, '��������� � ���� � ���������� �����.', 2),
(3, '��������� "�������� ������"', 2010, '���������������� �� ������� ����������� ����������� �����.', 1),
(4, '��������� "��������� ����"', 1980, '������������ ��������� � ������������� ��������.', 2),
(5, '��������� "�������"', 1990, '������������� ��������������� ��������� � ���.', 4),
(6, '��������� "����"', 2000, '����������� ����������� ������ � ���������� ����������.', 5),
(7, '��������� "��������� ������"', 2015, '�������� ���������� � ������� � ������.', 1),
(8, '��������� "������� ������"', 1998, '����� �� ������ ���� � ��������� �����������.', 7),
(9, '��������� "������ ��������"', 1985, '������� � ������ �������� � ������ ��������.', 6),
(10, '��������� "���������"', 2008, '������� ��������� ������������ � �������������� ������.', 9);
GO
-- ���������� ������� Guest
INSERT INTO Guest (ID, FIO, Birthday, Location, Email)
VALUES
(1, '������ ������ ��������', '1980-05-15', '������', 'sergey.ivanov@example.com'),
(2, '������� ���� ��������', '1990-07-22', '�����-���������', 'anna.petrova@example.com'),
(3, '������� ������� ����������', '1985-03-10', '�����������', 'aleksey.sidorov@example.com'),
(4, '��������� ����� ���������', '1992-11-05', '������������', 'maria.kuznetsova@example.com'),
(5, '������� ������� ���������', '1978-09-30', '������', 'dmitry.lebedev@example.com'),
(6, '�������� ����� ����������', '1988-12-12', '������ ��������', 'elena.novikova@example.com'),
(7, '������� ������ ��������', '1995-01-25', '���������', 'mikhail.sokolov@example.com'),
(8, '�������� ����� �������', '1983-04-18', '������', 'olga.morozova@example.com'),
(9, '������ ��������� ��������', '1975-08-08', '������-��-����', 'alexander.volkov@example.com'),
(10, '��������� ������� �������������', '1991-06-17', '���', 'natalia.vasileva@example.com');
GO
-- ���������� ������� GuestSanatory
INSERT INTO GuestSanatory (ID, GuestID, SanatoryID)
VALUES
(1, 1, 1),  -- ������ ������ �������� "��������"
(2, 2, 2),  -- ������� ���� �������� "�������� �����"
(3, 3, 3),  -- ������� ������� �������� "�������� ������"
(4, 4, 1),  -- ��������� ����� �������� "��������"
(5, 5, 4),  -- ������� ������� �������� "��������� ����"
(6, 6, 2),  -- �������� ����� �������� "�������� �����"
(7, 7, 5),  -- ������� ������ �������� "�������"
(8, 8, 3),  -- �������� ����� �������� "�������� ������"
(9, 9, 6),  -- ������ ��������� �������� "����"
(10, 10, 2); -- ��������� ������� �������� "�������� �����"
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

