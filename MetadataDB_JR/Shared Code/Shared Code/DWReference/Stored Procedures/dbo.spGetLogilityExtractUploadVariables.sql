

-- =============================================
-- Author:	oszymczak
-- Create date: 13/09/2011
-- Description:	Get Logility Extract Upload Variables
-- =============================================
CREATE PROCEDURE [dbo].[spGetLogilityExtractUploadVariables]
	@CountryCode NVARCHAR(3)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FileDir           NVARCHAR(255)
	DECLARE @Email             NVARCHAR(255)
	DECLARE @MasterDataConnStr NVARCHAR(255)
	DECLARE @LogilityConnStr   NVARCHAR(255)
	DECLARE @SMTPServerConnStr NVARCHAR(255)

	SELECT @FileDir           = ConfiguredValue    FROM dbo.SSISConfiguration WHERE ConfigurationFilter = 'FileDir_Logility_Extract_Upload'
	SELECT @Email             = ConfiguredValue    FROM dbo.SSISConfiguration WHERE ConfigurationFilter = 'Email_Logility_Extract_Upload'
	SELECT @MasterDataConnStr = ConfiguredValue    FROM dbo.SSISConfiguration WHERE ConfigurationFilter = 'ConnStr_RegDistExtract_DB'
	SELECT @LogilityConnStr   = sc.ConfiguredValue FROM dbo.SSISConfiguration sc
	       INNER JOIN dbo.SSISConfiguration scCountry
	       ON scCountry.ConfiguredValue = sc.ConfigurationFilter
	 WHERE scCountry.ConfigurationFilter = ('Logility_' + @CountryCode)
	SELECT @SMTPServerConnStr = ConfiguredValue    FROM dbo.SSISConfiguration WHERE ConfigurationFilter = 'ConnStr_SMTP_Server'

	SELECT @FileDir           AS 'FileDir',
           @Email             AS 'Email',
           @MasterDataConnStr AS 'MasterDataConnStr',
           @LogilityConnStr   AS 'LogilityConnStr',
           @SMTPServerConnStr AS 'SMTPServerConnStr'
	
END

