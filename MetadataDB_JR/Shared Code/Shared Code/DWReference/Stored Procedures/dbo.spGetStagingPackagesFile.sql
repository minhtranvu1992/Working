
CREATE PROCEDURE [dbo].[spGetStagingPackagesFile]
	@SuiteName VARCHAR(50),
	@Packages varchar(max)
AS
BEGIN
	SET NOCOUNT ON;
   
   DECLARE @sql varchar(max)
   SET @sql =' SELECT DISTINCT StagingControlID, StagingPackageName '+
		' FROM dbo.StagingControl sc'+
        ' INNER JOIN dbo.Suite s ON sc.SuiteID = s.SuiteID'+
        ' WHERE s.SuiteName = '''+@SuiteName +''''+
            ' AND sc.StagingPackageName IN ('+@Packages+')'+
            ' AND s.Status = ''S'' '+  
            ' AND sc.Status = ''S'' '+
			' AND sc.ProcessType = ''BULKFILE''';


	EXEC sys.sp_sqlexec @sql
END