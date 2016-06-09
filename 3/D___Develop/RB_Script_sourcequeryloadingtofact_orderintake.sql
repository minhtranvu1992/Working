/*VENTAS_OrderIntake_trade*/

SELECT a.nr_auftrag,
       a.erfasst,
       a.abgerechnet_dat,
       a.betreff,
       a.nr_kunde,
       a.nr_liefnt,
       a.bez,
       a.nr_gart AS industry,
       a.cty,
       a.department,
       a.nr_position_vpos,
       a.liefertermin,
       RTRIM(a.Merchandise) AS Merchandise,
       a.preis_ges_dm,
       a.preis_ges_wr,
       b.DB2,
       a.bu_id,
       a.currency,
       a.Backlogrelevant,
       a.office_reference
FROM dbo.vTMP_VENTAS_OrderIntake_Trade_02_BU AS a
     INNER JOIN dbo.vTMP_VENTAS_OrderIntake_Trade_03_DB2pos AS b ON a.nr_auftrag = b.nr_auftrag
                                                                    AND a.nr_position_vpos = b.nr_position_vpos
WHERE(a.erfasst >= '2008-01-01');
-----------------------------------------------------------------------------------------------------

/*VENTAS_OrderIntake_commision*/

SELECT b.nr_position,
       a.nr_kontrakt,
       a.abgerechnet_dat,
       a.nr_liefnt,
       a.nr_kunde,
       a.nr_gart AS industry,
       a.erfasst,
       a.seriell,
       a.liefertermin,
       a.bez,
       RTRIM(a.Merchandise) AS Merchandise,
       a.nr_adress_k,
       a.cty,
       a.department,
       a.preis_ges_dm,
       a.preis_ges_wr,
       b.DB2,
       a.bu_id,
       a.currency,
       a.Backlogrelevant,
       a.office_reference
FROM dbo.vTMP_VENTAS_OrderIntake_Comm_02_BU AS a
     INNER JOIN dbo.vTMP_VENTAS_OrderIntake_Comm_03_DB2pos AS b ON a.nr_kontrakt = b.nr_kontrakt
                                                                   AND a.nr_position = b.nr_position
WHERE(a.erfasst >= '2008-01-01');
----------------------------------------------------------------------------------------------------

/*FOXPRO_Order_Intake*/

SELECT ord_date,
       ord_no,
       division,
       industry_code,
       bu_id,
       cty,
       merchandise_id,
       descriptionofgoods,
       Salesman,
       sp_centre,
       CASE
           WHEN direct_ord = 1
           THEN 'C'
           ELSE 'T'
       END AS ordertype,
       service,
       contr_no,
       shp_date,
       contr_date,
       customer,
       province,
       pro_centre,
       maker AS supplyer,
       commodity,
       OrderValue_currency_type,
       OrderValue_in_local_currency,
       OrderValue,
       DB2_currency_type,
       DB2_in_local_currency,
       DB2,
       1 AS orderpos,
       shipped,
       'J' AS backlogrelevant,
       ord_no AS office_reference
FROM dbo.vTMP_Foxpro_OrderIntake
WHERE ord_date >= '2008-01-01'
      AND NOT(OrderValue = 1
              AND DB2 = 0); -- no canceled orders
------------------------------------------------------------------------------------

/*Local Orders_OrderIntake*/

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
       vorgang AS office_reference,
       Backlogrelevant
FROM dbo.vTMP_HKGOrders_DB2
WHERE ISNUMERIC(bu_id) = 1;
------------------------------------------------------------------------------------

/*LOD Order Intake*/

SELECT *
FROM vTMP_LOD_OrderIntake;