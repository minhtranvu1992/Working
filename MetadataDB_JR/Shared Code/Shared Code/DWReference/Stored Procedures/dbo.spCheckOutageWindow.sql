CREATE PROCEDURE [dbo].[spCheckOutageWindow] 
@CheckDate DATETIME
AS
BEGIN

SELECT COUNT(DISTINCT 1) AS 'IsOutageWindowActive'
FROM [dbo].[ScheduleOutageWindow]
WHERE @CheckDate BETWEEN [StartDateTime] AND [EndDateTime]

END
