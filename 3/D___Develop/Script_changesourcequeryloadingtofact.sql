/*Script- Source Query VENTAS_OrderComplete_trade_DB2*/

SELECT CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_konto1 = '3730'
           THEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.DB2
       END AS DB2,
       CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_konto1 = '3730'
                AND dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.[Calculation_Status] = 1
           THEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB2
       END AS PostCal_Value_DB2,
       dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB3,
       CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_konto1 = '3730'
                AND dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.[Calculation_Status] = 0
           THEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PreCal_Value_DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PreCal_Value_DB2
       END AS PreCal_Value_DB2,
       dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PreCal_Value_DB3,
       dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.[Calculation_Status],
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_auftrag,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_position,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.preis_ges_wr,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.preis_ges_dm,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.Liefertermin,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.belegdatum,
       dbo.FAKT_OrderIntake.bu_id,
       dbo.FAKT_OrderIntake.industry,
       dbo.FAKT_OrderIntake.merchandise,
       dbo.FAKT_OrderIntake.orderdate,
       dbo.FAKT_OrderIntake.estdeliverydate,
       dbo.FAKT_OrderIntake.deliverydate,
       dbo.FAKT_OrderIntake.customer,
       dbo.FAKT_OrderIntake.supplier,
       dbo.FAKT_OrderIntake.currency,
       dbo.FAKT_OrderIntake.country,
       dbo.FAKT_OrderIntake.ordertype,
       dbo.FAKT_OrderIntake.source,
       dbo.FAKT_OrderIntake.department,
       dbo.FAKT_OrderIntake.descriptionofgoods,
       dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_konto1
FROM dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos
     INNER JOIN dbo.vTMP_VENTAS_OrderComplete_Trade_Value ON dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_auftrag = dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_auftrag
                                                             AND dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_position = dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_position
     INNER JOIN dbo.FAKT_OrderIntake ON dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_auftrag = dbo.FAKT_OrderIntake.orderno
                                        AND dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_position = dbo.FAKT_OrderIntake.orderpos
WHERE(fakt_orderintake.source = 'HBG')
     AND (fakt_orderintake.ordertype = 'T');

------------------------------------------------------------------------------------------------------------------

/*VENTAS_OrderComplete_trade_Value*/

SELECT dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_auftrag,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_position,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.preis_ges_wr,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.preis_ges_dm,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.belegdatum,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.liefertermin,
       dbo.FAKT_OrderIntake.bu_id,
       dbo.FAKT_OrderIntake.industry,
       dbo.FAKT_OrderIntake.merchandise,
       dbo.FAKT_OrderIntake.orderdate,
       dbo.FAKT_OrderIntake.estdeliverydate,
       dbo.FAKT_OrderIntake.deliverydate,
       dbo.FAKT_OrderIntake.customer,
       dbo.FAKT_OrderIntake.supplier,
       dbo.FAKT_OrderIntake.currency,
       dbo.FAKT_OrderIntake.country,
       dbo.FAKT_OrderIntake.ordertype,
       dbo.FAKT_OrderIntake.source,
       dbo.FAKT_OrderIntake.department,
       dbo.FAKT_OrderIntake.descriptionofgoods,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PreCal_Value_Currency AS PreCal_Value_Currency,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PreCal_Value AS PreCal_Value,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PostCal_Value_Currency AS PostCal_Value_Currency,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PostCal_Value AS PostCal_Value,
       dbo.vTMP_VENTAS_OrderComplete_Trade_Value.[Calculation_Status] AS [Calculation_Status]
FROM dbo.vTMP_VENTAS_OrderComplete_Trade_Value
     INNER JOIN dbo.FAKT_OrderIntake ON dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_auftrag = dbo.FAKT_OrderIntake.orderno
                                        AND dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_position = dbo.FAKT_OrderIntake.orderpos
WHERE(fakt_orderintake.source = 'HBG')
     AND (fakt_orderintake.ordertype = 'T');
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*VENTAS_OrderComplete_commision_DB2*/

SELECT CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730'
           THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.DB2
       END AS DB2,
       CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730'
                AND dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status] = 0
           THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB2
       END AS PreCal_Value_DB2,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB3,
       CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730'
                AND dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status] = 1
           THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB2
       END AS PostCal_Value_DB2,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB3,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status],
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.belegdatum,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto,
       dbo.FAKT_OrderIntake.bu_id,
       dbo.FAKT_OrderIntake.industry,
       dbo.FAKT_OrderIntake.merchandise,
       dbo.FAKT_OrderIntake.orderdate,
       dbo.FAKT_OrderIntake.estdeliverydate,
       dbo.FAKT_OrderIntake.deliverydate,
       dbo.FAKT_OrderIntake.customer,
       dbo.FAKT_OrderIntake.supplier,
       dbo.FAKT_OrderIntake.currency,
       dbo.FAKT_OrderIntake.country,
       dbo.FAKT_OrderIntake.ordertype,
       dbo.FAKT_OrderIntake.source,
       dbo.FAKT_OrderIntake.department,
       dbo.FAKT_OrderIntake.descriptionofgoods,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position
FROM dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos
     INNER JOIN dbo.FAKT_OrderIntake ON dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt = dbo.FAKT_OrderIntake.orderno
                                        AND dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position = dbo.FAKT_OrderIntake.orderpos;

----------------------------------------------------------------------------------------------------------------------------------------

/*VENTAS_OrderComplete_commision_Value*/

SELECT dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_position,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_kontrakt,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.belegdatum,
       dbo.FAKT_OrderIntake.bu_id,
       dbo.FAKT_OrderIntake.industry,
       dbo.FAKT_OrderIntake.merchandise,
       dbo.FAKT_OrderIntake.orderdate,
       dbo.FAKT_OrderIntake.estdeliverydate,
       dbo.FAKT_OrderIntake.customer,
       dbo.FAKT_OrderIntake.supplier,
       dbo.FAKT_OrderIntake.currency,
       dbo.FAKT_OrderIntake.country,
       dbo.FAKT_OrderIntake.ordertype,
       dbo.FAKT_OrderIntake.source,
       dbo.FAKT_OrderIntake.department,
       dbo.FAKT_OrderIntake.descriptionofgoods,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.preis_ges_wr,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.preis_ges_dm,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PreCal_Value_Currency AS PreCal_Value_Currency,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PreCal_Value AS PreCal_Value,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PostCal_Value_Currency AS PostCal_Value_Currency,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PostCal_Value AS PostCal_Value,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.[Calculation_Status],
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_waehrung,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.belegdatum AS deliverydate
FROM dbo.vTMP_VENTAS_OrderComplete_Comm_Value
     INNER JOIN dbo.FAKT_OrderIntake ON dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_position = dbo.FAKT_OrderIntake.orderpos
                                        AND dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_kontrakt = dbo.FAKT_OrderIntake.orderno
WHERE(dbo.FAKT_OrderIntake.source = N'HBG')
     AND (dbo.FAKT_OrderIntake.ordertype = N'C');

----------------------------------------------------------------------------------------------------------------------------------------------

/*Local Orders_OrderComplete_Value*/




SELECT ID,
       ProcCenterOrderNo,
       Order_Date,
       Shipment_Date,
       bu_id,
       OfficeLocation,
       AbtAusBuchKz,
       LandAusBuchKz,
       Industriebereich,
       Vorgang,
       KdNr,
       Kurs,
       LieferantNr,
       Warenbez,
       DB2,
       EK_Preis,
       VK_Wrg,
       Wert_Wrg,
       Wert_Wrg AS PreCal_Value,
       '0' AS PreCal_Value_Currency,
       '0' AS PostCal_Value,
       '0' AS PostCal_Value_Currency,
       '0' AS [Calculation_Status],
       MakerComm,
       Customs,
       SubAgent,
       Freight,
       Banking,
       TravellingExp,
       Commissioning,
       Service,
       Contingencies,
       bu_type,
       LieferterminDat,
       Zahlungsbed,
       [User],
       ArtikelAusGA,
       source,
       orderpos,
       Shipment_Date AS invoicedate
FROM dbo.vTMP_HKGOrders_DB2
WHERE(Shipment_Date IS NOT NULL)
     AND ProcCenterOrderNo LIKE 'x%';

-------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Local Orders_OrderComplete_DB2*/


SELECT ID,
       ProcCenterOrderNo,
       Order_Date,
       Shipment_Date,
       bu_id,
       OfficeLocation,
       AbtAusBuchKz,
       LandAusBuchKz,
       Industriebereich,
       Vorgang,
       KdNr,
       Kurs,
       LieferantNr,
       Warenbez,
       DB2,
       DB2 AS PreCal_Value_DB2,
       '0' AS PreCal_Value_DB3,
       '0' AS PostCal_Value_DB2,
       '0' AS PostCal_Value_DB3,
       '0' AS [Calculation_Status],
       EK_Preis,
       VK_Wrg,
       Wert_Wrg,
       MakerComm,
       Customs,
       SubAgent,
       Freight,
       Banking,
       TravellingExp,
       Commissioning,
       Service,
       Contingencies,
       bu_type,
       LieferterminDat,
       Zahlungsbed,
       [User],
       ArtikelAusGA,
       source,
       orderpos,
       Shipment_Date AS invoicedate
FROM dbo.vTMP_HKGOrders_DB2
WHERE(Shipment_Date IS NOT NULL)
     AND ProcCenterOrderNo LIKE 'x%';



---------------------------------------------------------------------------------------------------------------------------------------------------------------

/*Non HKG orders and FOXPRO orders before 2013 - Fact Order Complete*/


SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       bs.ShippedDate AS InvoiceDate,
       bs.ShippedDate AS DeliveryDate,
       LEFT(o.BusinessType, 1) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
       bs.Currency AS currency,
       CASE
           WHEN bs.FinalizedDate IS NULL
           THEN o.OrderVal_EUR
           ELSE bs.OrderVal_EUR
       END AS ordercomplete_value,
       CASE
           WHEN bs.FinalizedDate IS NULL
           THEN o.OrderVal
           ELSE bs.OrderVal
       END AS ordercomplete_value_currency,
       o.OrderVal_EUR AS PreCal_Value,
       o.OrderVal AS PreCal_Value_Currency,
       CASE
           WHEN bs.FinalizedDate IS NOT NULL
           THEN ISNULL(bs.OrderVal_EUR, 0)
           ELSE 0
       END AS PostCal_Value,
       CASE
           WHEN bs.FinalizedDate IS NOT NULL
           THEN ISNULL(bs.OrderVal, 0)
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








-----------------------------------------------------------------------------------------------------------------------------------------------------------

/*Non HKG orders and FOXPRO orders before 2013 - Fact Order Complete DB2*/

--- source query
SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       bs.ShippedDate AS InvoiceDate,
       bs.ShippedDate AS DeliveryDate,
       LEFT(o.BusinessType, 1) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
       bs.Currency AS currency,
       CASE
           WHEN bs.FinalizedDate IS NULL
           THEN o.DB2Val_EUR
           ELSE bs.DB2Amt_EUR
       END AS ordercomplete_db2,
       CASE
           WHEN bs.FinalizedDate IS NULL
           THEN vtl.LabourDB3
           ELSE vtl.LabourDB3Post
       END AS ordercomplete_db3,
       o.DB2Val_EUR AS PreCal_Value_DB2,
       vtl.LabourDB3 AS PreCal_Value_DB3,
       CASE
           WHEN bs.FinalizedDate IS NOT NULL
           THEN ISNULL(bs.DB2Amt_EUR, 0)
           ELSE 0
       END AS PostCal_Value_DB2,
       CASE
           WHEN bs.FinalizedDate IS NOT NULL
           THEN ISNULL(vtl.LabourDB3Post, 0)
           ELSE 0
       END AS PostCal_Value_DB3,
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

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*HKG orders and FOXPRO orders since 2013 - Fact Order Complete*/

--- source query
SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       o.EstDeliveryDate,
       sb.OrderCompleteDateSolomon AS InvoiceDate,
       CAST(sb.BusinessType AS NVARCHAR(10)) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
       CASE
           WHEN(ss.active = 0)
           THEN sc.OrderCompleteValue
           ELSE o.OrderVal_EUR
       END AS ordercomplete_value,
       o.OrderVal AS ordercomplete_value_currency,
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



--------------------------------------------------------------------------------------------------------------------------------------------------------

/*HKG orders and FOXPRO orders since 2013 - Fact Order Complete DB2*/

--- source query

SELECT o.Industry,
       o.Merchandise,
       o.OrderIntakeDate AS OrderDate,
       o.EstDeliveryDate,
       sb.OrderCompleteDateSolomon AS InvoiceDate,
       CAST(sb.BusinessType AS NVARCHAR(10)) AS OrderType,
       o.GoodDescription AS descriptionofgoods,
       '0' AS PreCal_Value_DB2,
       '0' AS PreCal_Value_DB3,
       ISNULL(sc.OrderCompleteDB2, 0) AS PostCal_Value_DB2,
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
       sc.OrderCompleteDB2 AS ordercomplete_db2,
       CAST(sc.Acct AS NVARCHAR(10)) AS Acct,
       CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter,
       NULL AS ordercomplete_db3
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
       ISNULL(vtl.LabourDB3, 0) AS PreCal_Value_DB3,
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
       o.DB2Val_EUR AS ordercomplete_db2,
       CAST('' AS NVARCHAR(1)) AS Acct,
       CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter,
       vtl.LabourDB3 AS ordercomplete_db3
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
      AND ss.active >= 1;