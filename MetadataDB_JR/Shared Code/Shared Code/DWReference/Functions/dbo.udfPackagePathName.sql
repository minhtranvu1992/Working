CREATE FUNCTION [dbo].[udfPackagePathName](	@Environment VARCHAR(255), @Path VARCHAR(200), @PackageName VARCHAR(100))
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE	@PackagePath VARCHAR(500) = ''
	
	IF @Environment IS NOT NULL AND LEN(@Environment) > 0
	BEGIN
		SET @PackagePath = '\' + @Environment
	END
  
    IF @Path IS NOT NULL AND LEN(@Path) > 0
	BEGIN
		SET @PackagePath = @PackagePath + @Path + '\'
	END
	ELSE
    BEGIN
		SET @PackagePath = ''
	END
  
    SET @PackagePath = @PackagePath + @PackageName

	RETURN @PackagePath 
END;
