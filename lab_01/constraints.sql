-- Используем базу данных
USE GamingPlatform;
GO

-- Добавление ограничений к таблице Users
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

-- Добавление ограничений к таблице Developers
ALTER TABLE Developers
    ADD CONSTRAINT PK_Developers PRIMARY KEY (DeveloperID);
GO

-- Добавление ограничений к таблице Games
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
	ADD CONSTRAINT FK_Games_Developers FOREIGN KEY (DeveloperID) 
	REFERENCES Developers(DeveloperID);
GO

-- Добавление ограничений к таблице Reviews
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
    ALTER COLUMN DeveloperID INT NOT NULL;
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Users FOREIGN KEY (UserID) 
	REFERENCES Users(UserID);
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Games FOREIGN KEY (GameID) 
	REFERENCES Games(GameID);
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Developers FOREIGN KEY (DeveloperID) 
	REFERENCES Developers(DeveloperID);
GO
ALTER TABLE Reviews
	ADD CONSTRAINT CHK_Reviews_GameRating CHECK (GameRating BETWEEN 1 AND 10);
GO






ALTER TABLE Reviews
	DROP CONSTRAINT FK_Reviews_Games;
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Games FOREIGN KEY (GameID)
	REFERENCES Games(GameID)
	ON DELETE CASCADE;
GO
ALTER TABLE Reviews
	DROP CONSTRAINT FK_Reviews_Users;
GO
ALTER TABLE Reviews
	ADD CONSTRAINT FK_Reviews_Users FOREIGN KEY (UserID)
	REFERENCES Users(UserID)
	ON DELETE CASCADE;
GO