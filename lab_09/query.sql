USE GamingPlatform
GO

SELECT TOP 10
    G.Title,
    COUNT(O.OrderID) AS PurchaseCount
FROM
    Orders O
    INNER JOIN Games G ON O.GameID = G.GameID
GROUP BY
    G.Title
ORDER BY
    PurchaseCount DESC;