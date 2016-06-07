USE [Staging]
iF OBJECT_ID('tempdb..#temp1') is not null drop table #temp1

iF OBJECT_ID('tempdb..#temp2') is not null drop table #temp2


--- source query

select *  into #temp1 from 
(SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       o.EstDeliveryDate,
       sb.OrderCompleteDateSolomon AS InvoiceDate,
       CAST(sb.BusinessType AS NVARCHAR(10)) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
	  o.DB2Val_EUR AS PreCal_Value_DB2,
	  ISNULL(vtl.LabourDB3,0) AS PreCal_Value_DB3,
	  ISNULL(sc.OrderCompleteDB2,0) AS PostCal_Value_DB2,
	  '0' AS PostCal_Value_DB3,
	  '1' AS [Calculation_Status],
       c.CustomerID,
       s.SupplierID,
       o.GroupNo AS OrderNo,
       CAST('LOD' AS NVARCHAR(5)) AS source,
       tb.bu_id,
       '1' AS OrderPos,
       o.HistoricalSource AS HistoricalSource,
       o.GroupNo,
       bs.ShippedDate,
       CAST(sc.Acct AS NVARCHAR(10)) AS Acct,
       CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter
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
    FROM vLOD_FOXPROOrderNo_Since2013
) vl ON o.GroupNo = vl.OrderNo
     JOIN dbo.vTMP_Solomon_03_OrderComplete_Date_BusinessType_new sb ON o.GroupNo = sb.ord_no
     JOIN dbo.vTMP_Solomon_02_OrderComplete_DB2_new sc ON o.GroupNo = sc.ord_no
     JOIN dbo.TMP_Solomon_SubAcct ss ON o.GroupNo = ss.orderno
     LEFT JOIN ADM_ProcurementCenter pc ON o.ProcCenter = pc.description
     JOIN vTMP_LOD_OrderIntake vtl ON vtl.OrderNo_New = o.GroupNo
WHERE o.OrderIntakeDate >= '2008-01-01'
      AND ss.active = 0
UNION ALL
SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       o.EstDeliveryDate,
       sb.OrderCompleteDateSolomon AS InvoiceDate,
       CAST(sb.BusinessType AS NVARCHAR(10)) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
	  o.DB2Val_EUR AS PreCal_Value_DB2,
	  ISNULL(vtl.LabourDB3,0) AS PreCal_Value_DB3,
	  '0' AS PostCal_Value_DB2,
	  '0' AS PostCal_Value_DB3,
	  '0' AS [Calculation_Status],
       c.CustomerID,
       s.SupplierID,
       o.GroupNo AS OrderNo,
       CAST('LOD' AS NVARCHAR(5)) AS source,
       tb.bu_id,
       '1' AS OrderPos,
       o.HistoricalSource AS HistoricalSource,
       o.GroupNo,
       bs.ShippedDate,
       CAST('' AS NVARCHAR(1)) AS Acct,
       CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter
       
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
    FROM vLOD_FOXPROOrderNo_Since2013
) vl ON o.GroupNo = vl.OrderNo
     JOIN dbo.vTMP_Solomon_03_OrderComplete_Date_BusinessType_new sb ON o.GroupNo = sb.ord_no
     JOIN dbo.TMP_Solomon_SubAcct ss ON o.GroupNo = ss.orderno
     LEFT JOIN ADM_ProcurementCenter pc ON o.ProcCenter = pc.description
     JOIN vTMP_LOD_OrderIntake vtl ON vtl.OrderNo_New = o.GroupNo
WHERE o.OrderIntakeDate >= '2008-01-01'
      AND ss.active >= 1
	 ) v

select * from #temp1 t 
where t.Calculation_Status=1

