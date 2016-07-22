CREATE PROCEDURE [dbo].[spGetSourceControl] 
@SourceName VARCHAR(50)

AS
BEGIN
	SET NOCOUNT ON;

	SELECT scon.ConfiguredValue FROM dbo.SourceControl sc
	INNER JOIN dbo.SSISConfiguration scon ON sc.SSISConfigurationID = scon.SSISConfigurationID
	WHERE sc.SourceName = @SourceName
END

