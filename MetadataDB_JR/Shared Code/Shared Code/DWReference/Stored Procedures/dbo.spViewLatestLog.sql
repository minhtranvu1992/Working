CREATE PROCEDURE [dbo].[spViewLatestLog]( @Suite AS varchar(50), @IsSuccess AS int)
AS

/***********************************************************************************************************
 * FUNCTION: To view the ExtractExecutionLog and DeliveryExecutionLog tables based on the Suite and Success Flag
 *           specified in the parameters order by the highest ExtractJobID and DeliveryJobID respectively.                  
 * PARAMETERS:
 *				@Suite varchar(50) Suite Name
 *              @IsSuccess int 1 for the success and 0 for fail, put 2 for all success and fail
 * CREATED BY: Irwan Iswadi
 * CREATED DATE: 27 Oct 2008
 * LAST MODIFIED DATE: 27 Oct 2008
 ***********************************************************************************************************/
DECLARE @ExtractQuery AS varchar(255)
DECLARE @DeliveryQuery AS varchar(255)

DECLARE @Clause AS varchar(25)

IF @IsSuccess < 2 AND @IsSuccess >= 0 
	SET @Clause = ' AND SuccessFlag = ' + CAST(@IsSuccess AS varchar(1))
ELSE
	SET @Clause = ''

SET @ExtractQuery = 'SELECT * FROM(
SELECT *
, RANK() OVER(PARTITION BY ExtractPackageName ORDER BY ExtractJobID DESC) AS rnk
FROM dbo.ExtractExecutionLog WHERE Suite = ''' +  @Suite + '''' + ') ext WHERE rnk = 1' + @Clause

SET @DeliveryQuery = 'SELECT * FROM(
SELECT *
, RANK() OVER(PARTITION BY DeliveryPackageName ORDER BY DeliveryJobID DESC) AS rnk
FROM dbo.DeliveryExecutionLog WHERE Suite = ''' +  @Suite + ''''  + ') ext WHERE rnk = 1' + @Clause

EXECUTE (@ExtractQuery)
EXECUTE (@DeliveryQuery)

RETURN -1
