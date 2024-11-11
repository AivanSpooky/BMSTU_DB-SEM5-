-- Создание базы данных
CREATE DATABASE RK2;
GO

USE RK2;
GO

DROP TABLE СотрудникОбменногоПункта;
GO
DROP TABLE ОперацияОбмена;
GO
DROP TABLE КурсыВалют;
GO
DROP TABLE ВидыВалют;
GO


-- Создание таблицы Сотрудники обменного пункта
CREATE TABLE СотрудникОбменногоПункта (
    ID INT PRIMARY KEY,
    ФИО NVARCHAR(100),
    ГодРождения DATE,
    Должность NVARCHAR(50)
);
GO

-- Создание таблицы Операции обмена
CREATE TABLE ОперацияОбмена (
    ID INT PRIMARY KEY,
    Сотрудник INT FOREIGN KEY REFERENCES СотрудникОбменногоПункта(ID),
    Валюта NVARCHAR(3),
    Сумма DECIMAL(18, 2)
);
GO

-- Создание таблицы Курсы валют
CREATE TABLE КурсыВалют (
    Валюта NVARCHAR(3) PRIMARY KEY,
    Продажа DECIMAL(10, 2),
    Покупка DECIMAL(10, 2)
);
GO

-- Создание таблицы Виды валют
CREATE TABLE ВидыВалют (
    ID INT PRIMARY KEY,
    Валюта NVARCHAR(3) UNIQUE
);
GO

-- Заполнение таблиц тестовыми данными
INSERT INTO СотрудникОбменногоПункта (ID, ФИО, ГодРождения, Должность)
VALUES 
(1, N'Иванов Иван Иванович', '1985-05-15', N'Кассир'),
(2, N'Петров Петр Петрович', '1990-11-22', N'Менеджер'),
(3, N'Сидоров Сидор Сидорович', '1983-08-01', N'Директор');


-- =====================================================
-- Пример SELECT-запроса с использованием выражения CASE
SELECT *,
       CASE 
           WHEN Сумма > 10000 THEN 'Крупная сделка'
           ELSE 'Мелкая сделка'
       END AS ТипСделки
FROM ОперацияОбмена;
-- Пример SELECT-запроса с использованием оконной функции
SELECT ID, 
       Валюта, 
       Сумма,
       SUM(Сумма) OVER (PARTITION BY Валюта) AS СуммаПоВалюте
FROM ОперацияОбмена;
-- Пример SELECT-запроса с использованием GROUP BY и HAVING
SELECT Валюта, 
       COUNT(*) AS КоличествоОпераций, 
       AVG(Сумма) AS СредняяСумма
FROM ОперацияОбмена
GROUP BY Валюта
HAVING AVG(Сумма) > 5000;

CREATE PROCEDURE СоздатьРезервныеКопии
AS
BEGIN
    DECLARE @backupPath NVARCHAR(255) = N'C:\SQLBackups\'; -- Укажите путь к папке для резервных копий
    DECLARE @databaseName NVARCHAR(255);
    DECLARE @backupFileName NVARCHAR(255);
    DECLARE @backupDate NVARCHAR(8) = CONVERT(NVARCHAR, GETDATE(), 112); -- Дата в формате YYYYMMDD

    DECLARE db_cursor CURSOR FOR
    SELECT name
    FROM sys.databases
    WHERE database_id > 4; -- Исключаем системные базы данных

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

-- Тестирование хранимой процедуры
EXEC СоздатьРезервныеКопии;