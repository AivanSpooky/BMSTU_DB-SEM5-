-- Создание логина
CREATE LOGIN nifi_user WITH PASSWORD = '1';

-- Создание пользователя в базе данных
USE GamingPlatform;
CREATE USER nifi_user FOR LOGIN nifi_user;

-- Назначение ролей и прав
ALTER ROLE db_datareader ADD MEMBER nifi_user;
ALTER ROLE db_datawriter ADD MEMBER nifi_user;