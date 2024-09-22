-- Используем базу данных
USE GamingPlatform;
GO

--1. Инструкция SELECT, использующая предикат сравнения
--выбирает все игры, созданные тем же разработчиком, что и игра с названием 'Game-5', за исключением самой 'Game-5'
SELECT Games.Title, Games.ReleaseDate
FROM Games 
JOIN Games G2 ON Games.DeveloperID = G2.DeveloperID
WHERE Games.GameID <> G2.GameID
  AND G2.Title = 'Game-900'
ORDER BY Games.ReleaseDate;

--2. Инструкция SELECT, использующая предикат BETWEEN
--выбирает все игры, которые были выпущены в 2020 году
SELECT Title, ReleaseDate
FROM Games
WHERE ReleaseDate BETWEEN '2024-09-18' AND '2024-09-19'
ORDER BY ReleaseDate;

--3. Инструкция SELECT, использующая предикат LIKE
--находит все игры, в жанре которых присутствует слово "Action"
SELECT g.Title, g.CategoryID
FROM Games g
JOIN Categories c ON g.CategoryID = c.CategoryID
WHERE c.CategoryName LIKE '%Action%';

--4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом
--находит все отзывы на игры, разработанные японскими разработчиками
SELECT r.ReviewID, r.ReviewText, r.GameRating
FROM Reviews r
JOIN Games g ON r.GameID = g.GameID
JOIN Developers d ON g.DeveloperID = d.DeveloperID
WHERE d.Country = 'Japan';

--5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом
--выводит список разработчиков, у которых есть хотя бы одна выпущенная игра
SELECT DeveloperID, Name
FROM Developers
WHERE EXISTS (SELECT 1
              FROM Games
              WHERE Games.DeveloperID = Developers.DeveloperID);

--6. Инструкция SELECT, использующая предикат сравнения с квантором
--Получение игр, цена которых выше всех игр в одной категории (например, Rhythm Action (для Game-1))
SELECT GameID, Title, Price
FROM Games
WHERE Price > ALL (SELECT Price
                   FROM Games
                   WHERE CategoryID = 173);

--7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов
--Получение средней стоимости всех игр и вручную подсчитанного среднего значения
SELECT AVG(Price) AS 'Actual AVG',
       SUM(Price) / COUNT(GameID) AS 'Calc AVG'
FROM Games;

--8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов
--Получение средней и минимальной цены на игру по конкретным заказам для каждой игры
SELECT GameID, Price,
       (SELECT AVG(Price) 
        FROM Orders
        WHERE Orders.GameID = Games.GameID) AS AvgPrice,
       (SELECT MIN(Price) 
        FROM Orders
        WHERE Orders.GameID = Games.GameID) AS MinPrice,
       Title
FROM Games
WHERE CategoryID = 748;

--9. Инструкция SELECT, использующая простое выражение CASE
--Получение всех заказов с меткой о том, в каком году они были сделаны (в этом году, прошлом или ранее)
SELECT UserName, OrderID,
       CASE YEAR(OrderDate)
            WHEN YEAR(GETDATE()) THEN 'This Year'
            WHEN YEAR(GETDATE()) - 1 THEN 'Last Year'
            ELSE CAST(DATEDIFF(year, OrderDate, GETDATE()) AS VARCHAR(5)) + ' years ago'
       END AS 'When'
FROM Orders JOIN Users ON Orders.UserID = Users.UserID;

--10. Инструкция SELECT, использующая поисковое выражение CASE
--Классификация игр по ценам: дешевые, средние, дорогие
SELECT Title,
       CASE
            WHEN Price < 10 THEN 'Cheap'
            WHEN Price < 50 THEN 'Affordable'
            WHEN Price < 100 THEN 'Expensive'
            ELSE 'Luxury'
       END AS PriceCategory
FROM Games;

--11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
--Создание таблицы с наиболее продаваемыми играми
SELECT GameID, SUM(Quantity) AS TotalQuantity,
       SUM(Price * Quantity) AS TotalRevenue
INTO #TopSellingGames
FROM Orders
GROUP BY GameID;
SELECT * FROM #TopSellingGames
DROP TABLE IF EXISTS #TopSellingGames

--12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM
--Получение игр с наибольшими продажами по количеству и по доходам
SELECT 'By Units' AS Criteria, Title AS 'Top Selling'
FROM Games G
JOIN (SELECT TOP 1 GameID, SUM(Quantity) AS TotalQuantity
      FROM Orders
      GROUP BY GameID
      ORDER BY TotalQuantity DESC) AS BestByUnits
ON G.GameID = BestByUnits.GameID

UNION

SELECT 'By Revenue' AS Criteria, Title AS 'Top Selling'
FROM Games G
JOIN (SELECT TOP 1 GameID, SUM(Price * Quantity) AS TotalRevenue
      FROM Orders
      GROUP BY GameID
      ORDER BY TotalRevenue DESC) AS BestByRevenue
ON G.GameID = BestByRevenue.GameID;

--13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3
--Получение самой продаваемой игры по количеству
SELECT Title
FROM Games
WHERE GameID = (SELECT GameID
                FROM Orders
                GROUP BY GameID
                HAVING SUM(Quantity) = (SELECT MAX(TotalQuantity)
                                        FROM (SELECT SUM(Quantity) AS TotalQuantity
                                              FROM Orders
                                              GROUP BY GameID) AS Quantities));

--14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING
--Получение средней и минимальной цены игр в категории
SELECT G.GameID, G.Price, G.Title,
       AVG(O.Price) AS AvgPrice, MIN(O.Price) AS MinPrice
FROM Games G
LEFT JOIN Orders O ON G.GameID = O.GameID
WHERE G.CategoryID = 19
GROUP BY G.GameID, G.Price, G.Title;

--15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING
--Получение списка категорий, где средняя цена игр выше общей средней цены
SELECT CategoryID, AVG(Price) AS 'Average Price'
FROM Games
GROUP BY CategoryID
HAVING AVG(Price) > (SELECT AVG(Price) FROM Games);

--16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений
--Добавление новой игры в таблицу
INSERT INTO Games (Title, DeveloperID, CategoryID, Price, ReleaseDate, Discontinued)
VALUES ('SuperGame', 2, 1, 29.99, '2024-01-01', DEFAULT);

--17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса
--Добавление записи о покупке игры "Tofu Game" для заказа конкретного пользователя
INSERT INTO Orders (UserID, GameID, Price, Quantity, OrderDate)
SELECT (SELECT MAX(UserID) FROM Users WHERE UserName = 'Donald Edwards'),
       GameID, Price, 2, '2024-01-01'
FROM Games
WHERE Title = 'Game-228';

--18. Простая инструкция UPDATE
--Обновление цены конкретной игры
UPDATE Games
SET Price = Price * 1.5
WHERE GameID = 5;

--19. Инструкция UPDATE со скалярным подзапросом в предложении SET
--Обновление цены игры на основе средней цены в заказах
UPDATE Games
SET Price = (SELECT AVG(Price) FROM Orders WHERE GameID = 7)
WHERE GameID = 7;

--20. Простая инструкция DELETE
--Удаление всех заказов с неопределенными пользователями
DELETE FROM Orders
WHERE UserID IS NULL;

--21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE
--Удаление игр, которые никогда не были куплены
DELETE FROM Games
WHERE GameID IN (SELECT G.GameID
                 FROM Games G
                 LEFT JOIN Orders O ON G.GameID = O.GameID
                 WHERE O.GameID IS NULL);

--22. Инструкция SELECT, использующая простое обобщенное табличное выражение (CTE)
--Получение среднего количества продаж для каждого разработчика
WITH SalesByDeveloper AS (
    SELECT DeveloperID, COUNT(*) AS TotalSales
    FROM Games G
    JOIN Orders O ON G.GameID = O.GameID
    GROUP BY DeveloperID
)
SELECT AVG(TotalSales) AS 'Average Sales'
FROM SalesByDeveloper;


--23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
--Создание таблицы UserReferrals для хранения реферальных связей между пользователями
CREATE TABLE UserReferrals (
    UserID INT,
    ReferredByUserID INT,
    PRIMARY KEY (UserID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),             -- Ссылка на существующего пользователя
    FOREIGN KEY (ReferredByUserID) REFERENCES Users(UserID)     -- Ссылка на пригласившего пользователя
);
GO
-- Вставка данных о реферальных связях пользователей
INSERT INTO UserReferrals (UserID, ReferredByUserID)
VALUES
(2, 1),  -- Пользователь 2 (Bob) был приглашён пользователем 1 (Alice)
(3, 1),  -- Пользователь 3 (Charlie) был приглашён пользователем 1 (Alice)
(4, 2),  -- Пользователь 4 (Dave) был приглашён пользователем 2 (Bob)
(5, 3);  -- Пользователь 5 (Eve) был приглашён пользователем 3 (Charlie)
GO
WITH ReferralHierarchy (UserID, ReferredByUserID, Level) AS (
    -- Начальное выражение: выбираем пользователей, которых никто не пригласил
    SELECT U.UserID, UR.ReferredByUserID, 1 AS Level
    FROM Users U
    LEFT JOIN UserReferrals UR ON U.UserID = UR.UserID
    WHERE UR.ReferredByUserID IS NULL

    UNION ALL

    -- Рекурсивное выражение: выбираем всех пользователей, приглашённых другими
    SELECT U.UserID, UR.ReferredByUserID, RH.Level + 1
    FROM Users U
    JOIN UserReferrals UR ON U.UserID = UR.UserID
    JOIN ReferralHierarchy RH ON UR.ReferredByUserID = RH.UserID
)
-- Выводим результат
SELECT UserID, ReferredByUserID, Level
FROM ReferralHierarchy
ORDER BY Level;
DROP TABLE IF EXISTS UserReferrals


--24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--вывод всех заказов со средним, минимальным, максимальным прайсом
SELECT G.GameID, G.Price, G.Title,
       AVG(O.Price) OVER(PARTITION BY G.GameID) AS AvgPrice,
       MIN(O.Price) OVER(PARTITION BY G.GameID) AS MinPrice,
       MAX(O.Price) OVER(PARTITION BY G.GameID) AS MaxPrice
FROM Games G
LEFT JOIN Orders O ON G.GameID = O.GameID;


--25. Оконные функции для устранения дубликатов
--Удаление дублирующихся строк с использованием ROW_NUMBER()
WITH GameDuplicates AS (
    SELECT GameID, Title, Price, ROW_NUMBER() OVER(PARTITION BY Title, Price ORDER BY GameID) AS RowNum
    FROM Games
)
DELETE FROM Games
WHERE GameID IN (SELECT GameID FROM GameDuplicates WHERE RowNum > 1);
