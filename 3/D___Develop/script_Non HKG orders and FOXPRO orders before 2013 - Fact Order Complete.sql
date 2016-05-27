

iF OBJECT_ID('tempdb..#temp1') is not null drop table #temp1

iF OBJECT_ID('tempdb..#temp2') is not null drop table #temp2


SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       bs.ShippedDate AS InvoiceDate,
       bs.ShippedDate AS DeliveryDate,
       LEFT(o.BusinessType, 1) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
       bs.Currency AS currency,
	  o.OrderVal_EUR AS PreCal_Value,
	  o.OrderVal AS PreCal_Value_Currency,
       CASE
           WHEN bs.FinalizedDate IS NOT NULL
           THEN ISNULL(bs.OrderVal_EUR,0)
           ELSE 0
       END AS PostCal_Value,
	  CASE
           WHEN bs.FinalizedDate IS NOT NULL
           THEN ISNULL(bs.OrderVal,0)
           ELSE 0
       END AS PostCal_Value_Currency,
       CASE
           WHEN bs.FinalizedDate IS NOT NULL 
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
       CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter
into #temp1
FROM LZ_LOD_OrderBillingShipping bs
     JOIN LZ_LOD_OrderReg o ON o.OrderNo = bs.OrderNo
     LEFT JOIN LZ_LOD_Customer c ON o.Customer = c.CustomerName
     LEFT JOIN LZ_LOD_Supplier s ON o.Supplier = s.SupplierName
     JOIN tmp_bu tb ON o.BusinessUnit = tb.bu_desc
     JOIN
(
    SELECT OrderNo
    FROM dbo.vLOD_NonHKGOrderNo
    UNION ALL
    SELECT OrderNo
    FROM dbo.[vLOD_FOXPROOrderNo_Before2013]
) vl ON o.GroupNo = vl.OrderNo
     LEFT JOIN ADM_ProcurementCenter pc ON o.ProcCenter = pc.description
     JOIN vTMP_LOD_OrderIntake vtl ON vtl.OrderNo_New = o.GroupNo
WHERE bs.ShippedDate IS NOT NULL;






select * from #temp1