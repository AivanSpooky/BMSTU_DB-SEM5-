-- �������� ���� ������
CREATE DATABASE RK2;
GO

USE RK2;
GO

DROP TABLE ������������������������;
GO
DROP TABLE ��������������;
GO
DROP TABLE ����������;
GO
DROP TABLE ���������;
GO


-- �������� ������� ���������� ��������� ������
CREATE TABLE ������������������������ (
    ID INT PRIMARY KEY,
    ��� NVARCHAR(100),
    ����������� DATE,
    ��������� NVARCHAR(50)
);
GO

-- �������� ������� �������� ������
CREATE TABLE �������������� (
    ID INT PRIMARY KEY,
    ��������� INT FOREIGN KEY REFERENCES ������������������������(ID),
    ������ NVARCHAR(3),
    ����� DECIMAL(18, 2)
);
GO

-- �������� ������� ����� �����
CREATE TABLE ���������� (
    ������ NVARCHAR(3) PRIMARY KEY,
    ������� DECIMAL(10, 2),
    ������� DECIMAL(10, 2)
);
GO

-- �������� ������� ���� �����
CREATE TABLE ��������� (
    ID INT PRIMARY KEY,
    ������ NVARCHAR(3) UNIQUE
);
GO

-- ���������� ������ ��������� �������
INSERT INTO ������������������������ (ID, ���, �����������, ���������)
VALUES 
(1, N'������ ���� ��������', '1985-05-15', N'������'),
(2, N'������ ���� ��������', '1990-11-22', N'��������'),
(3, N'������� ����� ���������', '1983-08-01', N'��������');


-- =====================================================
-- ������ SELECT-������� � �������������� ��������� CASE
SELECT *,
       CASE 
           WHEN ����� > 10000 THEN '������� ������'
           ELSE '������ ������'
       END AS ���������
FROM ��������������;
-- ������ SELECT-������� � �������������� ������� �������
SELECT ID, 
       ������, 
       �����,
       SUM(�����) OVER (PARTITION BY ������) AS �������������
FROM ��������������;
-- ������ SELECT-������� � �������������� GROUP BY � HAVING
SELECT ������, 
       COUNT(*) AS ������������������, 
       AVG(�����) AS ������������
FROM ��������������
GROUP BY ������
HAVING AVG(�����) > 5000;

CREATE PROCEDURE ���������������������
AS
BEGIN
    DECLARE @backupPath NVARCHAR(255) = N'C:\SQLBackups\'; -- ������� ���� � ����� ��� ��������� �����
    DECLARE @databaseName NVARCHAR(255);
    DECLARE @backupFileName NVARCHAR(255);
    DECLARE @backupDate NVARCHAR(8) = CONVERT(NVARCHAR, GETDATE(), 112); -- ���� � ������� YYYYMMDD

    DECLARE db_cursor CURSOR FOR
    SELECT name
    FROM sys.databases
    WHERE database_id > 4; -- ��������� ��������� ���� ������

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @databaseName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @backupFileName = @backupPath + @databaseName + '_' + @backupDate + '.bak';

        DECLARE @sql NVARCHAR(MAX) = N'BACKUP DATABASE [' + @databaseName + '] TO DISK = ''' + @backupFileName + '''';
        EXEC sp_executesql @sql;

        FETCH NEXT FROM db_cursor INTO @databaseName;
    END;

    CLOSE db_cursor;
    DEALLOCATE db_cursor;
END;
GO

-- ������������ �������� ���������
EXEC ���������������������;