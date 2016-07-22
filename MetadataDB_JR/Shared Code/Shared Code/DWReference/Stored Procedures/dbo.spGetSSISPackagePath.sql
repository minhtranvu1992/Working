CREATE PROCEDURE [dbo].[spGetSSISPackagePath] 
	-- Add the parameters for the stored procedure here
	@SSISPackageName varchar(100),
	@FolderName varchar(100) = 'ETL-RegionalReporting'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CurrentFolder as varchar(100)
	DECLARE @FolderPath as varchar(500)
	--declare @SSISPackageName varchar(100)
	IF NOT EXISTS (SELECT top 1 Name FROM msdb.dbo.sysssispackages WHERE Name = @SSISPackageName) 
		SELECT ''
	ELSE
	BEGIN
		 SET @CurrentFolder = (SELECT top 1 pf.FolderName FROM msdb.dbo.sysssispackages p
				INNER JOIN 	msdb.dbo.sysssispackagefolders pf ON p.folderid = pf.folderid 
				WHERE p.Name = @SSISPackageName AND pf.foldername=@FolderName)	
		SET @FolderPath = @CurrentFolder + '\' + @SSISPackageName
		SET @CurrentFolder = (SELECT top 1 f2.foldername 
				FROM msdb.dbo.sysssispackagefolders f1 
				INNER JOIN msdb.dbo.sysssispackagefolders f2 ON f1.parentfolderid = f2.folderID
				WHERE f1.foldername = @CurrentFolder)
				
		print @CurrentFolder
		WHILE (@CurrentFolder IS NOT NULL AND @CurrentFolder <> '')
		BEGIN
			SET @FolderPath = @CurrentFolder + '\' + @FolderPath 
			SET @CurrentFolder = (SELECT top 1 f2.foldername 
				FROM msdb.dbo.sysssispackagefolders f1 
				INNER JOIN msdb.dbo.sysssispackagefolders f2 ON f1.parentfolderid = f2.folderID
				WHERE f1.foldername = @CurrentFolder)
		END		
	SET @FolderPath = '\' + @FolderPath
	SELECT @FolderPath
	END
END

