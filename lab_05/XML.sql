USE GamingPlatform;
GO

-- === 1 Выгрузка данных в XML ===

-- 1.1 RAW
SELECT *
FROM Games
FOR XML RAW;

-- 1.2 AUTO
SELECT g.GameID, g.Title, d.Name AS DeveloperName
FROM Games g
JOIN Developers d ON g.DeveloperID = d.DeveloperID
FOR XML AUTO;

-- 1.3 PATH
SELECT 
    g.GameID AS [@GameID],
    g.Title AS [Title],
    (
        SELECT 
            d.Name AS [Name],
            d.Country AS [Country]
        FROM Developers d
        WHERE d.DeveloperID = g.DeveloperID
        FOR XML PATH('Developer'), TYPE
    ) AS [DeveloperInfo]
FROM Games g
FOR XML PATH('Game');

-- 1.4 EXPLICIT
SET FMTONLY OFF;
GO

SELECT
    1 AS Tag,
    NULL AS Parent,
    g.GameID AS [Game!1!GameID],
    g.Title AS [Game!1!Title],
    NULL AS [Developer!2!Name],
    NULL AS [Developer!2!Country]
FROM Games g
UNION ALL
SELECT
    2 AS Tag,
    1 AS Parent,
    g.GameID,
    NULL,
    d.Name,
    d.Country
FROM Games g
JOIN Developers d ON g.DeveloperID = d.DeveloperID
ORDER BY [Game!1!GameID], Tag
FOR XML EXPLICIT;


-- === 2 Загрузка и сохранение XML в таблицу ===
-- Создание новой таблицы
CREATE TABLE ImportedGames (
    GameID INT PRIMARY KEY,
    Title NVARCHAR(255) NOT NULL,
    ReleaseDate DATE NOT NULL,
	Description NVARCHAR(100) NOT NULL,
	CategoryID INT NOT NULL,
    DeveloperID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    MinSystemRequirements NVARCHAR(MAX) NOT NULL,
	Discontinued BIT
);
ALTER TABLE ImportedGames
	ADD CONSTRAINT FK_ImportedGames_Developers FOREIGN KEY (DeveloperID) 
	REFERENCES Developers(DeveloperID);
GO
ALTER TABLE ImportedGames
	ADD CONSTRAINT FK_ImportedGames_Categories FOREIGN KEY (CategoryID)
	REFERENCES Categories(CategoryID)
GO


-- Загрузка XML
DECLARE @xmlData XML;
SET @xmlData = (
    SELECT 
        g.GameID,
        g.Title,
        g.ReleaseDate,
		g.Description, --
		g.CategoryID, --
        g.DeveloperID,
        g.Price,
		g.MinSystemRequirements,
		g.Discontinued
    FROM Games g
    FOR XML PATH('Game'), ROOT('Games')
);
--SELECT @xmlData;
-- Сохранение XML в таблицу
INSERT INTO ImportedGames (GameID, Title, ReleaseDate, Description, CategoryID, DeveloperID, Price, MinSystemRequirements, Discontinued)
SELECT
    T.C.value('(GameID)[1]', 'INT') AS GameID,
    T.C.value('(Title)[1]', 'NVARCHAR(255)') AS Title,
    T.C.value('(ReleaseDate)[1]', 'DATE') AS ReleaseDate,
	T.C.value('(Description)[1]', 'NVARCHAR(100)') AS Description,
	T.C.value('(CategoryID)[1]', 'INT') AS CategoryID,
    T.C.value('(DeveloperID)[1]', 'INT') AS DeveloperID,
    T.C.value('(Price)[1]', 'DECIMAL(10,2)') AS Price,
	T.C.value('(MinSystemRequirements)[1]', 'NVARCHAR(MAX)') AS MinSystemRequirements,
	T.C.value('(Discontinued)[1]', 'BIT') AS Discontinued
FROM
    @xmlData.nodes('/Games/Game') AS T(C);
 
-- ВЫВОД
SELECT * FROM ImportedGames;
SELECT * FROM Games
-- Удалить таблицу ImportedGames
DROP TABLE IF EXISTS dbo.ImportedGames;
GO

-- === 3. === 
ALTER TABLE ImportedGames
ADD ExtraInfo XML;
GO

UPDATE ImportedGames
SET ExtraInfo = '
<Details>
    <Storage>2GB</Storage>
    <Platform>PC</Platform>
</Details>'
WHERE GameID = 10;

-- === 4. ===
-- 4.1 Извлечь XML фрагмент из XML документа
SELECT
    GameID,
    ExtraInfo.query('/Details/Platform') AS PlatformFragment
FROM ImportedGames;
-- 4.2 Извлечь значения конкретных узлов или атрибутов XML документа
SELECT
    GameID,
    ExtraInfo.value('(/Details/Storage)[1]', 'NVARCHAR(50)') AS Storage,
    ExtraInfo.value('(/Details/Platform)[1]', 'NVARCHAR(50)') AS Platform
FROM ImportedGames;
-- 4.3 Выполнить проверку существования узла/атрибута
SELECT
    GameID,
    Title
FROM ImportedGames
WHERE ExtraInfo.exist('/Details/Genre') = 1;
SELECT
    GameID,
    Title
FROM ImportedGames
WHERE ExtraInfo.exist('/Details/Storage') = 1;
-- 4.4 Изменить XML документ
UPDATE ImportedGames
SET ExtraInfo.modify('
    insert <Publisher>Publisher Name</Publisher> as last
    into (/Details)[1]
')
WHERE GameID = 1;
--
SELECT
    ExtraInfo.query('/Details') AS UpdatedDetails
FROM ImportedGames
WHERE GameID = 1;
-- 4.5 Разделить XML документ на несколько строк по узлам
UPDATE ImportedGames
SET ExtraInfo = '
<Details>
    <Features>
        <Feature>Multiplayer</Feature>
        <Feature>High Resolution</Feature>
        <Feature>Open World</Feature>
    </Features>
</Details>'
WHERE GameID = 1;
--
SELECT
    GameID,
    Feature.value('.', 'NVARCHAR(50)') AS Feature
FROM ImportedGames
CROSS APPLY ExtraInfo.nodes('/Details/Features/Feature') AS T(Feature)
WHERE GameID = 1;
-- ДЛЯ STORAGE и PLATFORM
SELECT
    GameID,
    Feature.value('local-name(.)', 'NVARCHAR(50)') AS FeatureName,
    Feature.value('.', 'NVARCHAR(50)') AS FeatureValue
FROM ImportedGames
CROSS APPLY ExtraInfo.nodes('/Details/*') AS T(Feature)
WHERE GameID = 1;