IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
    DROP TABLE #temp1;
IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
    DROP TABLE #temp2;
IF OBJECT_ID('tempdb..#temp3') IS NOT NULL
    DROP TABLE #temp3;

--- this is all orders which to be extract Board on 17/6/2016
SELECT [Order Number Pos#]
      ,[OrderNo]
      ,[Pre service order intake db3]
      ,[Pre service order complete db3]
      ,[service order intake db3]
      ,[service order complete db3]
      ,[Order Intake DB3]
      ,[Order Complete DB3]
      ,[Calculation Status]
      ,[Data Source]
      ,[Order chargeable]
INTO #temp1
FROM [test].[dbo].[BoardLayout] b
--WHERE b.[Data Source] = 'LOD'
ORDER BY b.[OrderNo];

-----This is All Order which to be extracted from LOD on 20/6/2016
SELECT [OrderNo],
       [Confirmed],
       [ProcCenter],
       [Product],
       [CreatedBy],
       [Status],
       [Remarks],
       [F8]
INTO #temp2
FROM [test].[dbo].[RemarksQuoc]
ORDER BY [OrderNo];
SELECT 
       [Order Intake Date]
      ,[PCPurchase]
      ,[Merchandise]
      ,[Historical Source]
      ,[Updated By]
      ,[Updated Date]
      ,[OrderNo]
      ,[DB3Pre]
      ,[DB3Post]
      ,[Finalized Date]
      ,[Shipped Date]
      ,[Procurement center]
      ,[Created By]
      ,[Confirmed]
      ,[Status]
      ,[Product]
      ,[Division]
      ,[Calc# Status LOD] AS Calc_Status_LOD
INTO #temp3
FROM [test].[dbo].[LODSource]
WHERE [Merchandise]='S'
ORDER BY [OrderNo];

------------------------------------------------------------------------------------------------------------------------------
--- Compare data between LOD and Board on Calculation status, DB3pre vs Pre service order complete db3,DB3Post vs service order complete db3
--SELECT t3.*,
--       t1.*,
--       CASE
--           WHEN t3.[Created By] = 'FOXPRO'
--                AND (t3.DB3Pre IS NULL
--                     AND t3.DB3Post IS NULL) and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'Foxpro order but order complete db3 values are zero so Board filtered out by default'
--           WHEN t3.[Created By] = 'FOXPRO'
--                AND t3.Confirmed = 0 and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'Foxpro order but not confirmed'
--           WHEN t3.[Created By] = 'FOXPRO'
--                AND t3.[Procurement center] LIKE '%Rieckermann GmbH%' and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'Foxpro order but not confirmed'
--           WHEN t3.[Created By] = 'FOXPRO'
--                AND t3.[Finalized Date] IS NULL
--                AND t3.[Updated Date] IS NOT NULL and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'user updated  values in LOD after the last ETL refreshed in test server so the values are different'
--           WHEN t3.[Historical Source] <> 'FOXPRO'
--                AND t3.[Finalized Date] IS NULL
--                AND t3.[Updated Date] IS NOT NULL and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'user updated  values in LOD after the last ETL refreshed in test server so the values are different'
--           WHEN t3.[Historical Source] IS NULL
--                AND t3.[Finalized Date] IS NULL
--                AND t3.[Updated Date] IS NOT NULL and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'user updated  values in LOD after the last ETL refreshed in test server so the values are different'
--           WHEN t3.[Historical Source] IS NULL
--                AND (t3.DB3Pre IS NULL
--                     AND t3.DB3Post IS NULL) and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 'order complete db3 values are zero so Board filtered out by default'
--           WHEN t3.[Historical Source] IS NULL
--                AND t3.PCPurchase <> 1 and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN null
--           ELSE NULL
--       END AS Remarks,
--       CASE
--           WHEN RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--           THEN 1
--           ELSE 0
--       END AS IsDifference
--FROM #temp3 t3
--     INNER JOIN #temp1 t1 ON t3.[OrderNo] = t1.OrderNo
--WHERE 
-----find out all order differently calculation Status
--RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))

--ORDER BY t3.[OrderNo]


---------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp4') IS NOT NULL
    DROP TABLE #temp4;
select t3.OrderNo AS OrderNo_LOD
,t3.DB3Pre
,t3.DB3Post
,t3.[Updated Date]
,t3.[Finalized Date] AS FinalizedDate
,t3.[Shipped Date] AS ShippedDate
,t3.[Procurement center] AS Procurementcenter
,t3.[Created By] AS CreatedBy
,t3.Calc_Status_LOD
,t1.[Calculation Status] AS Calculation_Status_Board
, Case 
WHEN t3.Calc_Status_LOD <> t1.[Calculation Status] THEN 0
ELSE 1
END AS [Calc_Status_LOD VS Calculation_Status_Board]
,t1.[Order Number Pos#]
,t1.OrderNo AS OrderNo_Board
,t1.[Pre service order intake db3]
,case 
when ROUND(t1.[Pre service order intake db3]-t3.DB3Pre,0)=0 then 1
else 0
END AS [DB3Pre VS Pre service order intake db3]
,t1.[Pre service order complete db3]
, case 
when t3.[Shipped Date] is not null and (t1.[Pre service order complete db3]-t3.DB3Pre)=0 then 1
ELSE 0 END AS [DB3Pre VS Pre service order complete db3]
,t1.[service order intake db3]
,case 
when t1.[Calculation Status]='Pre-calc.' and ROUND((t1.[service order intake db3]-t3.DB3Pre),0)=0 then 1
WHEN t1.[Calculation Status]='Post-calc.' and ROUND((t1.[service order intake db3]-t3.DB3Post),0)=0 then 1
ELSE 0 END AS [service order intake db3 VS DB3 LOD]
,t1.[service order complete db3]
,case 
when t1.[Calculation Status]='Pre-calc.' and ROUND((t1.[service order complete db3]-t3.DB3Pre),0)=0 then 1
WHEN t1.[Calculation Status]='Post-calc.' and ROUND((t1.[service order complete db3]-t3.DB3Post),0)=0 then 1
ELSE 0 END AS [service order complete db3 VS DB3 LOD]
,t1.[Order Intake DB3]
,case 
when t1.[Pre service order intake db3]-t1.[Order Intake DB3]=0 then 1
ELSE 0 END as [Order Intake DB3 VS Pre service order intake db3]
,t1.[Order Complete DB3]
,Case
when t1.[Order Complete DB3] is not null and t1.[Calculation Status]='Pre-calc.' and t1.[Pre service order complete db3]-t1.[Order Complete DB3]=0 then 1
when t1.[Order Complete DB3] is not null and t1.[Calculation Status]='Post-calc.' and t1.[service order complete db3]-t1.[Order Complete DB3]=0 then 1
ELSE 0 end as [service order complete db3 VS Order Complete DB3]
,t1.[Order chargeable]
INTO #temp4
from #temp3 t3
INNER JOIN #temp1 t1 ON t3.[OrderNo] = t1.OrderNo

ORDER BY t3.[OrderNo]
-----------------------------------------------------------------------
IF OBJECT_ID('tempdb..#temp5') IS NOT NULL
    DROP TABLE #temp5;
select o.GroupNo
,s.LabourDB3
,s.LabourDB3Post
--INTO #temp5
from [StagingLive23062016]..LZ_LOD_OrderReg o 
inner join [StagingLive23062016]..LZ_LOD_OrderBillingShipping bs on o.OrderNo=bs.OrderNo
inner join [StagingLive23062016]..LZ_LOD_OrderRegService s on o.OrderNo=s.OrderNo
where o.Merchandise='S' and 

o.GroupNo in 
('40141',
'40196',
'49A47',
'49B39',
'49C16',
'49C62',
'49E69',
'4A722',
'4B114',
'4P643',
'4P652',
'4P713',
'4P728',
'4P729',
'4P759',
'4P867',
'4PC29'

)
----------------------------------------------------------------------
select *
from #temp4 t4 
left join #temp5 t5 on t4.OrderNo_LOD COLLATE DATABASE_DEFAULT=t5.GroupNo COLLATE DATABASE_DEFAULT
where t4.[service order complete db3 VS DB3 LOD]=0 