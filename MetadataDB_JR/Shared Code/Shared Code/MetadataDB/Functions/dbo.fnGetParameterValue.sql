-- =============================================
-- Author:		Stephen Lawson
-- Create date: 2013-09-04
-- Description:	Returns the ParameterValue for a given ParameterName
-- =============================================
CREATE FUNCTION [dbo].[fnGetParameterValue] 
(
	-- Add the parameters for the function here
	@ParameterName VARCHAR(40)
)
RETURNS VARCHAR(4000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ParameterValue VARCHAR(4000)

	-- Add the T-SQL statements to compute the return value here
	SELECT @ParameterValue = (SELECT ParameterValue FROM dbo.Parameter WHERE ParameterName = @ParameterName)

	-- Return the result of the function
	RETURN @ParameterValue

END