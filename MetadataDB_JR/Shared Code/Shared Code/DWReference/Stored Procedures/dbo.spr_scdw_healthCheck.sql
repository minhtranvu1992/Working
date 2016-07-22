
CREATE PROCEDURE [dbo].[spr_scdw_healthCheck] AS 

CREATE TABLE #Messages  
 (  
  RowNumber  INT,  
  MessageText  VARCHAR(255)  ,
  ErrorNumber INT
  
 )

DECLARE @message varchar(255)
set @message = 'SCDW Health Check for ' + convert(varchar,getdate(), 106)


INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
values(1,@Message,0)

INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
SELECT 2 as RowNumber,'Package ' +  [DeliveryPackageName] + ' has generated an error. Please see Delivery Execution Log for details.' as MessageText,1 as errorNumber
FROM [dbo].[DeliveryExecutionLog]
WHERE successflag = 0 and convert(varchar,starttime, 106) = convert(varchar,getdate(), 106)

IF @@ROWCOUNT <> 0
   BEGIN
   INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
   VALUES(2,'Errors In Delivery Execution ' + convert(varchar,getdate(), 106),0)
   END
-------------------------------------------------------------------------------
-- Refactoring required as the statement below will not work due to RowsErrored column
-- been removed
-------------------------------------------------------------------------------
--INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
--SELECT 3 as RowNumber
--      ,'Package ' +  [DeliveryPackageName] + ' has sent rows to Error. Rows Delivered: ' + Cast([RowsDelivered] as varchar)
--      + ' Error Rows: ' + cast([RowsErrored] as varchar)  as MessageText
--      ,2 as ErrorNumber
--  FROM [dbo].[DeliveryExecutionLog]
--  WHERE RowsErrored > 0 and convert(varchar,starttime, 106) = convert(varchar,getdate(), 106)
IF @@ROWCOUNT <> 0
   BEGIN
   INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
   VALUES(3,'Error Rows Generated In Delivery Execution ' + convert(varchar,getdate(), 106),0)
   END

INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
SELECT
4 as RowNumber,'Package ' +  [ExtractPackageName] + ' has generated an error. Please see Extract Execution Log for details.' as MessageText,3 as errorNumber
  FROM [dbo].[ExtractExecutionLog]
WHERE convert(varchar,starttime, 106) = convert(varchar,getdate(), 106) and SuccessFlag = 0

IF @@ROWCOUNT <> 0
   BEGIN
   INSERT INTO #Messages(RowNumber,MessageText,ErrorNumber)
   VALUES(4,'Errors Generated In Extract Execution ' + convert(varchar,getdate(), 106),0)
   END

SELECT MessageText
FROM #Messages 
ORDER BY ROWNUMBER,ErrorNumber

