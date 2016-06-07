iF OBJECT_ID('tempdb..#temp1') is not null drop table #temp1


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
into #temp1
FROM dbo.vTMP_HKGOrders_DB2
WHERE(Shipment_Date IS NOT NULL)
     AND ProcCenterOrderNo LIKE 'x%';

GO
select * from #temp1