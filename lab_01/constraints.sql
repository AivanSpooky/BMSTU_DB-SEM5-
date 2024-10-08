-- ���������� ���� ������
USE GamingPlatform;
GO

-- ���������� ����������� � ������� Users
ALTER TABLE Users
	ADD CONSTRAINT PK_Users PRIMARY KEY (UserID);
GO
ALTER TABLE Users
	ALTER COLUMN Username NVARCHAR(100) NOT NULL;
GO
ALTER TABLE Users
	ALTER COLUMN Email NVARCHAR(255) NOT NULL;
GO
ALTER TABLE Users
	ADD CONSTRAINT UQ_Users_Email UNIQUE (Email);
GO
ALTER TABLE Users
	ALTER COLUMN RegistrationDate DATE NOT NULL;
GO
ALTER TABLE Users
	ALTER COLUMN AccountStatus BIT NOT NULL;
GO
ALTER TABLE Users
    ADD CONSTRAINT D_AccountStatus DEFAULT 0 FOR AccountStatus;
GO

-- ���������� ����������� � ������� Developers
ALTER TABLE Developers
    ADD CONSTRAINT PK_Developers PRIMARY KEY (DeveloperID);
GO
ALTER TABLE Developers
    ALTER COLUMN Name NVARCHAR(255) NOT NULL;
GO

-- ���������� ����������� � ������� Categories
ALTER TABLE Categories
	ADD CONSTRAINT PK_Categories PRIMARY KEY (CategoryID);
GO
ALTER TABLE Categories
	ALTER COLUMN CategoryName NVARCHAR(100) NOT NULL;
GO



-- ���������� ����������� � ������� Games
ALTER TABLE Games
    ADD CONSTRAINT PK_Games PRIMARY KEY (GameID);
GO
ALTER TABLE Games
    ALTER COLUMN Title NVARCHAR(255) NOT NULL;
GO
ALTER TABLE Games
    ALTER COLUMN ReleaseDate DATE NOT NULL;
GO
ALTER TABLE Games
	ALTER COLUMN CategoryID INT NOT NULL;
GO
ALTER TABLE Games
	ALTER COLUMN DeveloperID INT NOT NULL;
GO
ALTER TABLE Games
	ALTER COLUMN Price DECIMAL(10, 2) NOT NULL;
GO
ALTER TABLE Games
	ADD CONSTRAINT FK_Games_Developers FOREIGN KEY (DeveloperID) 
	REFERENCES Developers(DeveloperID);
GO
ALTER TABLE Games
	ADD CONSTRAINT FK_Games_Categories FOREIGN KEY (CategoryID)
	REFERENCES Categories(CategoryID)
GO

-- ���������� ����������� � ������� Orders
ALTER TABLE Orders
    ADD CONSTRAINT PK_Orders PRIMARY KEY (OrderID);
GO
ALTER TABLE Orders
    ALTER COLUMN UserID NVARCHAR(255) NOT NULL;
GO
ALTER TABLE Orders
    ALTER COLUMN GameID NVARCHAR(255) NOT NULL;
GO
ALTER TABLE Orders
    ALTER COLUMN Price DECIMAL(10, 2) NOT NULL;
GO
ALTER TABLE Orders
    ALTER COLUMN Quantity INT NOT NULL;
GO
ALTER TABLE Orders
    ALTER COLUMN OrderDate DATE NOT NULL;
GO
ALTER TABLE Orders
    ALTER COLUMN UserID INT;
GO

ALTER TABLE Orders
    ALTER COLUMN GameID INT;
GO
ALTER TABLE Orders
	ADD CONSTRAINT FK_Orders_Users FOREIGN KEY (UserID)
	REFERENCES Users(UserID)
	ON DELETE CASCADE;
GO
ALTER TABLE Orders
	ADD CONSTRAINT FK_Orders_Games FOREIGN KEY (GameID)
	REFERENCES Games(GameID)
	ON DELETE CASCADE;
GO


-- ���������� ����������� � ������� Reviews
ALTER TABLE Reviews
    ADD CONSTRAINT PK_Reviews PRIMARY KEY (ReviewID);
GO
ALTER TABLE Reviews
    ALTER COLUMN UserID INT NOT NULL;
GO
ALTER TABLE Reviews
    ALTER COLUMN GameID INT NOT NULL;
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Users FOREIGN KEY (UserID)
	REFERENCES Users(UserID)
	ON DELETE CASCADE;
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Games FOREIGN KEY (GameID)
	REFERENCES Games(GameID)
	ON DELETE CASCADE;
GO
ALTER TABLE Reviews
	ADD CONSTRAINT CHK_Reviews_GameRating CHECK (GameRating BETWEEN 1 AND 10);
GO