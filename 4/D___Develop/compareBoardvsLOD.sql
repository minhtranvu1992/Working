IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
    DROP TABLE #temp1;
IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
    DROP TABLE #temp2;
IF OBJECT_ID('tempdb..#temp3') IS NOT NULL
    DROP TABLE #temp3;

--- this is all orders which to be extract Board on 17/6/2016
SELECT [Order Number pos#]
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
       [Order Intake Date],
       [PCPurchase],
       [Merchandise],
       [Historical Source],
       [Updated By],
       [Updated Date],
       [OrderNo],
       [DB3Pre],
       [DB3Post],
       [Finalized Date],
       [Procurement center],
       [Created By],
       [Confirmed],
       [Status],
       [Product],
       [Division],
       [Calc# Status LOD] AS Calc_Status_LOD
INTO #temp3
FROM [test].[dbo].[LODSource]
ORDER BY [OrderNo];

------------------------------------------------------------------------------------------------------------------------------
--- Compare data between LOD and Board on Calculation status, DB3pre vs Pre service order complete db3,DB3Post vs service order complete db3
SELECT t3.*,
       t1.*,
       CASE
           WHEN t3.[Created By] = 'FOXPRO'
                AND (t3.DB3Pre IS NULL
                     AND t3.DB3Post IS NULL) and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'Foxpro order but order complete db3 values are zero so Board filtered out by default'
           WHEN t3.[Created By] = 'FOXPRO'
                AND t3.Confirmed = 0 and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'Foxpro order but not confirmed'
           WHEN t3.[Created By] = 'FOXPRO'
                AND t3.[Procurement center] LIKE '%Rieckermann GmbH%' and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'Foxpro order but not confirmed'
           WHEN t3.[Created By] = 'FOXPRO'
                AND t3.[Finalized Date] IS NULL
                AND t3.[Updated Date] IS NOT NULL and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'user updated  values in LOD after the last ETL refreshed in test server so the values are different'
           WHEN t3.[Historical Source] <> 'FOXPRO'
                AND t3.[Finalized Date] IS NULL
                AND t3.[Updated Date] IS NOT NULL and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'user updated  values in LOD after the last ETL refreshed in test server so the values are different'
           WHEN t3.[Historical Source] IS NULL
                AND t3.[Finalized Date] IS NULL
                AND t3.[Updated Date] IS NOT NULL and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'user updated  values in LOD after the last ETL refreshed in test server so the values are different'
           WHEN t3.[Historical Source] IS NULL
                AND (t3.DB3Pre IS NULL
                     AND t3.DB3Post IS NULL) and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 'order complete db3 values are zero so Board filtered out by default'
           WHEN t3.[Historical Source] IS NULL
                AND t3.PCPurchase <> 1 and RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN null
           ELSE NULL
       END AS Remarks,
       CASE
           WHEN RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
           THEN 1
           ELSE 0
       END AS IsDifference
FROM #temp3 t3
     INNER JOIN #temp1 t1 ON t3.[OrderNo] = t1.OrderNo
WHERE 
---find out all order differently calculation Status
RTRIM(LTRIM(t3.Calc_Status_LOD)) <> RTRIM(LTRIM(t1.[Calculation Status]))
--and 
--t3.[OrderNo] in ('A1702','A2172','A2219','A2277','A2315','A2340','A2359','A2376','A2503','A2567','A2601','A2606','A2719','A2758','A3433')

---find out all order differently Values of DB3Pre
--Or  round(t3.DB3pre,2) <>round(t1.[Pre service order complete db3],2)
---find out all order differently Values of DB3Post
--OR  round(t3.DB3Post,2) <> round(t1.[service order complete db3],2)
ORDER BY t3.[OrderNo]


