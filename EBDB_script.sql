USE master
GO

IF DB_ID('EBDB') IS NOT NULL
	DROP DATABASE EBDB
GO

CREATE DATABASE EBDB
GO

USE EBDB
GO

CREATE TABLE tblUsers(
	IdUser int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	Email varchar(50) NOT NULL,
	UserName varchar(50) NOT NULL,
	UserHandle varchar(50) NOT NULL,
	Password varchar(50) NOT NULL

)
GO

CREATE TABLE tblPeople(
	IdPerson int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL,
	LastName varchar(50) NOT NULL,
	Initials varchar(10)
)
GO

CREATE TABLE tblHookup(
	IdHookup int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	IdUser int FOREIGN KEY REFERENCES tblUsers(IdUser),
	IdPerson int FOREIGN KEY REFERENCES tblPeople(idPerson), 
	UserName varchar(50) NOT NULL,
	HookupInitials varchar(50) NOT NULL
)
GO

--Adds users to database
CREATE PROCEDURE [dbo].[spAddUser]
	@UserName varchar(50),
	@UserHandle varchar(50),
	@Name varchar(50),
	@LastName varchar(50),
	@Email varchar(50),
	@Password varchar(50)

	
AS
	IF NOT EXISTS (SELECT NULL
						FROM tblUsers
						WHERE UserName = @UserName AND
								UserHandle = @UserHandle
						) BEGIN
						INSERT INTO tblUsers(UserName, UserHandle, Name, LastName, Email, Password)
						VALUES (@UserName, @UserHandle, @Name, @LastName, @Email, @Password)
						SELECT @@IDENTITY AS newID
						RETURN
	END
GO

--Add person to database
CREATE PROCEDURE [dbo].[spAddPerson]
	@Name varchar(50),
	@LastName varchar(50),
	@Initials varchar(10)

AS
	IF NOT EXISTS (SELECT NULL
						FROM tblPeople
						WHERE Name = @Name AND
								LastName = @LastName
						) BEGIN
						INSERT INTO tblPeople(Name, LastName, Initials)
						VALUES (@Name, @LastName, @Initials)
						SELECT @@IDENTITY AS newID
						RETURN
	END
GO

--Get a user from the Database
CREATE PROCEDURE [dbo].[getUserID]
	@UserHandle varchar(50)
AS
	SELECT IdUser
	FROM tblUsers
	WHERE UserHandle = @UserHandle

RETURN
GO

--Get a person from the Database
CREATE PROCEDURE [dbo].[getPersonID]
	@Initials varchar(10)
AS
	SELECT IdPerson
	FROM tblPeople
	WHERE Initials = @Initials
RETURN
GO


--TODO: Make it so that the IdUser and IdPerson are automatically pulled from their respective tables instead of having to input them manually
--Add a hookup to database. User must exist and adds a new person if needed
CREATE PROCEDUre [dbo].[spAddHookup]
	@UserName varchar(50),
	@UserHandle varchar(50),
	@Name varchar(50), 
	@LastName varchar(50),
	@initials varchar(10), 
	@IdUser int,
	@IdPerson int
AS
	--Check if the person exists, if not add them
	IF NOT EXISTS (SELECT NULL
						FROM tblPeople
						WHERE Name = @Name AND
								LastName = @LastName
					) BEGIN EXEC spAddPerson @Name, @LastName, @initials
					END
	--Check if the hookup exists
	IF NOT EXISTS (SELECT NULL
						FROM tblHookup
						WHERE UserName = @UserName AND
								HookupInitials = @initials
					) BEGIN --Add hookup
					INSERT INTO tblHookup(IdUser, IdPerson, UserName, HookupInitials)
					VALUES (@IdUser, @IdPerson, @UserName, @initials)
					SELECT @@IDENTITY AS newID
					RETURN
								
					END
GO
--spGetPersonId
--spGetUserID