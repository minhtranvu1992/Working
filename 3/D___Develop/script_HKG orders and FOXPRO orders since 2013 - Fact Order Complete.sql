USE Staging;
iF OBJECT_ID('tempdb..#temp1') is not null drop table #temp1

iF OBJECT_ID('tempdb..#temp2') is not null drop table #temp2



--- source query
SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       o.EstDeliveryDate,
       sb.OrderCompleteDateSolomon AS InvoiceDate,
       CAST(sb.BusinessType AS NVARCHAR(10)) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
       o.OrderVal_EUR AS PreCal_Value,
       o.OrderVal AS PreCal_Value_Currency,
       CASE
           WHEN(ss.active = 0)
           THEN ISNULL(sc.OrderCompleteValue, 0)
           ELSE 0
       END AS PostCal_Value,
       CASE
           WHEN(ss.active = 0)
           THEN ISNULL(o.OrderVal, 0)
           ELSE 0
       END AS PostCal_Value_Currency,
       CASE
           WHEN(ss.active = 0)
           THEN 1
           ELSE 0
       END AS [Calculation_Status],
       c.CustomerID,
       s.SupplierID,
       o.GroupNo AS OrderNo,
       CAST('LOD' AS NVARCHAR(5)) AS source,
       tb.bu_id,
       '1' AS OrderPos,
       o.HistoricalSource AS HistoricalSource,
       o.GroupNo,
       bs.ShippedDate,
       CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter
into #temp1
FROM LZ_LOD_OrderBillingShipping bs
     JOIN LZ_LOD_OrderReg o ON o.OrderNo = bs.OrderNo
     LEFT JOIN LZ_LOD_Customer c ON o.Customer = c.CustomerName
     LEFT JOIN LZ_LOD_Supplier s ON o.Supplier = s.SupplierName
     JOIN tmp_bu tb ON o.BusinessUnit = tb.bu_desc
     JOIN
(
    SELECT orderno
    FROM vLOD_HKGOrderNo
    UNION
    SELECT orderno
    FROM dbo.vLOD_FOXPROOrderNo_Since2013
) vl ON o.GroupNo = vl.OrderNo
     JOIN dbo.vTMP_Solomon_03_OrderComplete_Date_BusinessType_new sb ON o.GroupNo = sb.ord_no
     JOIN dbo.vTMP_Solomon_02_OrderComplete_value_new sc ON o.GroupNo = sc.ord_no
     LEFT JOIN dbo.TMP_Solomon_SubAcct ss ON o.GroupNo = ss.orderno
     LEFT JOIN ADM_ProcurementCenter pc ON o.ProcCenter = pc.description
     JOIN vTMP_LOD_OrderIntake vtl ON vtl.OrderNo_New = o.GroupNo
WHERE o.OrderIntakeDate >= '2008-01-01';


select * from #temp1