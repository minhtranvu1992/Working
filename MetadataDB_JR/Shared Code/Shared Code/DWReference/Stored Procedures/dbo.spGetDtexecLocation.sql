-- =============================================
-- Author:		Olof Szymczak
-- Create date: 2014/05/09
-- Description:	get location of dtexec
-- =============================================
CREATE PROCEDURE [dbo].[spGetDtexecLocation]
@RunAs32Bit BIT 
AS
BEGIN
	SET NOCOUNT ON;
	IF (@RunAs32Bit = 0)
	BEGIN
		SELECT ConfiguredValue AS 'LocationDtexec' FROM [dbo].[SSISConfiguration] WHERE [ConfigurationFilter] = 'Location_DTEXEC_64Bit'
	END
	ELSE
	BEGIN
		SELECT ConfiguredValue AS 'LocationDtexec' FROM [dbo].[SSISConfiguration] WHERE [ConfigurationFilter] = 'Location_DTEXEC_32Bit'
	END
END