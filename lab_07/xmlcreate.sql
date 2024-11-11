USE GamingPlatform;
GO

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

-- Check if stored procedure exists and drop it
IF OBJECT_ID('dbo.GetGamesByCategoryByID', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetGamesByCategoryByID;
GO

-- Create the stored procedure
CREATE PROCEDURE dbo.GetGamesByCategoryByID
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT g.GameID, g.Title, g.ReleaseDate, g.Price
    FROM Games g
    WHERE g.CategoryID = @CategoryID;
END;
GO