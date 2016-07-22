/*VENTAS_OrderIntake_trade*/

WITH temp1(nr_auftrag,
           erfasst,
           abgerechnet_dat,
           betreff,
           nr_kunde,
           nr_liefnt,
           bez,
           industry,
           cty,
           department,
           nr_position_vpos,
           liefertermin,
           Merchandise,
           preis_ges_dm,
           preis_ges_wr,
           DB2,
           bu_id,
           currency,
           Backlogrelevant,
           office_reference)
     AS (SELECT a.nr_auftrag,
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
         WHERE(a.erfasst >= '2008-01-01')),
     temp2(nr_auftrag,
           erfasst,
           abgerechnet_dat,
           betreff,
           nr_kunde,
           nr_liefnt,
           bez,
           industry,
           cty,
           department,
           nr_position_vpos,
           liefertermin,
           Merchandise,
           preis_ges_dm,
           preis_ges_wr,
           DB2,
           bu_id,
           currency,
           Backlogrelevant,
           office_reference,
           Postcal_IntakeDB2,
           Postcal_IntakeDB2_currency,
           PostCal_Value_DB3,
           Precal_IntakeDB2,
           Precal_IntakeDB2_Currency,
           Precal_IntakeDB3,
           Postcal_IntakeDB3,
           Precal_IntakeValue_Currency,
           Precal_IntakeValue,
           Postcal_IntakeValue_Currency,
           Postcal_IntakeValue,
           Calculation_Status)
     AS (SELECT FAKT_OrderIntake.nr_auftrag,
                FAKT_OrderIntake.erfasst,
                FAKT_OrderIntake.abgerechnet_dat,
                FAKT_OrderIntake.betreff,
                FAKT_OrderIntake.nr_kunde,
                FAKT_OrderIntake.nr_liefnt,
                FAKT_OrderIntake.bez,
                FAKT_OrderIntake.industry,
                FAKT_OrderIntake.cty,
                FAKT_OrderIntake.department,
                FAKT_OrderIntake.nr_position_vpos,
                FAKT_OrderIntake.liefertermin,
                FAKT_OrderIntake.Merchandise,
                FAKT_OrderIntake.preis_ges_dm,
                FAKT_OrderIntake.preis_ges_wr,
                FAKT_OrderIntake.DB2,
                FAKT_OrderIntake.bu_id,
                FAKT_OrderIntake.currency,
                FAKT_OrderIntake.Backlogrelevant,
                FAKT_OrderIntake.office_reference,
                vTMP_VENTAS_OrderComplete_Trade_DB2pos.Postcal_IntakeDB2,
                '0' AS Postcal_IntakeDB2_currency,
                vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB3,
                vTMP_VENTAS_OrderComplete_Trade_DB2pos.Precal_IntakeDB2,
                '0' AS Precal_IntakeDB2_Currency,
                vTMP_VENTAS_OrderComplete_Trade_DB2pos.Precal_IntakeDB3,
                '0' AS Postcal_IntakeDB3,
                dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PreCal_Value_Currency AS Precal_IntakeValue_Currency,
                dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PreCal_Value AS Precal_IntakeValue,
                dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PostCal_Value_Currency AS Postcal_IntakeValue_Currency,
                dbo.vTMP_VENTAS_OrderComplete_Trade_Value.PostCal_Value AS Postcal_IntakeValue,
                dbo.vTMP_VENTAS_OrderComplete_Trade_Value.[Calculation_Status] AS Calculation_Status
         FROM temp1 AS FAKT_OrderIntake
              LEFT JOIN dbo.vTMP_VENTAS_OrderComplete_Trade_Value ON dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_auftrag = FAKT_OrderIntake.nr_auftrag
                                                                     AND dbo.vTMP_VENTAS_OrderComplete_Trade_Value.nr_position = FAKT_OrderIntake.nr_position_vpos
              LEFT JOIN
         (
             SELECT dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_auftrag,
                    dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_position,
                    SUM(CASE
                            WHEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_konto1 = '3730'
                                 AND dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.[Calculation_Status] = 1
                            THEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB2 / 2
                            ELSE dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB2
                        END) AS Postcal_IntakeDB2,
                    SUM(CAST(dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PostCal_Value_DB3 AS INT)) AS PostCal_Value_DB3,
                    SUM(CASE
                            WHEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_konto1 = '3730'
                                 AND dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.[Calculation_Status] = 0
                            THEN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PreCal_Value_DB2 / 2
                            ELSE dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PreCal_Value_DB2
                        END) AS Precal_IntakeDB2,
                    SUM(CAST(dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.PreCal_Value_DB3 AS INT)) AS Precal_IntakeDB3
             FROM dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos
             GROUP BY dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_auftrag,
                      dbo.vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_position
         ) AS vTMP_VENTAS_OrderComplete_Trade_DB2pos ON vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_auftrag = FAKT_OrderIntake.nr_auftrag
                                                        AND vTMP_VENTAS_OrderComplete_Trade_DB2pos.nr_position = FAKT_OrderIntake.nr_position_vpos)
     SELECT a.nr_auftrag,
            a.erfasst,
            a.abgerechnet_dat,
            a.betreff,
            a.nr_kunde,
            a.nr_liefnt,
            a.bez,
            a.industry,
            a.cty,
            a.department,
            a.nr_position_vpos,
            a.liefertermin,
            RTRIM(a.Merchandise) AS Merchandise,
            a.preis_ges_dm,
            a.preis_ges_wr,
            a.DB2,
            a.bu_id,
            a.currency,
            a.Backlogrelevant,
            a.office_reference,
            CASE
                WHEN ISNULL(a.Precal_IntakeValue, 0) = 0
                THEN ISNULL(a.preis_ges_dm, 0)
                ELSE ISNULL(a.Precal_IntakeValue, 0)
            END AS Precal_IntakeValue,
            CASE
                WHEN ISNULL(a.Precal_IntakeDB2, 0) = 0
                THEN ISNULL(a.DB2, 0)
                ELSE ISNULL(a.Precal_IntakeDB2, 0)
            END AS Precal_IntakeDB2,
            ISNULL(a.Precal_IntakeDB2_Currency, 0) AS Precal_IntakeDB2_Currency,
            CASE
                WHEN ISNULL(a.Precal_IntakeValue_Currency, 0) = 0
                THEN ISNULL(a.preis_ges_wr, 0)
                ELSE ISNULL(a.Precal_IntakeValue_Currency, 0)
            END AS Precal_IntakeValue_Currency,
            ISNULL(a.Postcal_IntakeValue, 0) AS Postcal_IntakeValue,
            ISNULL(a.Postcal_IntakeValue_Currency, 0) AS Postcal_IntakeValue_Currency,
            ISNULL(a.Postcal_IntakeDB2, 0) AS Postcal_IntakeDB2,
            ISNULL(a.Postcal_IntakeDB2_currency, 0) AS Postcal_IntakeDB2_currency,
            ISNULL(a.Precal_IntakeDB3, 0) AS Precal_IntakeDB3,
            ISNULL(a.Postcal_IntakeDB3, 0) AS Postcal_IntakeDB3,
            CASE
                WHEN a.[Calculation_Status] IS NULL
                THEN 0
                ELSE a.[Calculation_Status]
            END AS Calculation_Status
     FROM temp2 AS a;
     



-----------------------------------------------------------------------------------------------------

/*VENTAS_OrderIntake_commision*/


GO
IF OBJECT_ID('dbo.vTMPSourceLoadOderIntakeDB2_Post', 'V') IS NOT NULL
    DROP VIEW [dbo].[vTMPSourceLoadOderIntakeDB2_Post];
GO
CREATE VIEW [dbo].[vTMPSourceLoadOderIntakeDB2_Post]
AS
     SELECT dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt,
            dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position,
            dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.Calculation_Status,
            SUM(CASE
                    WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730'
                         AND dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status] = 0
                    THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB2 / 2
                    ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB2
                END) AS Precal_IntakeDB2,
            SUM(CAST(dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB3 AS INT)) AS Precal_IntakeDB3,
            SUM(CASE
                    WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730'
                         AND dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status] = 1
                    THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB2 / 2
                    ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB2
                END) AS Postcal_IntakeDB2,
            SUM(CAST(dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB3 AS INT)) AS Postcal_IntakeDB3
     FROM dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos
     GROUP BY dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt,
              dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position,
              dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.Calculation_Status;
GO
GO
IF OBJECT_ID('dbo.vTMPSourceLoadOderIntake', 'V') IS NOT NULL
    DROP VIEW [dbo].[vTMPSourceLoadOderIntake];
GO
CREATE VIEW [dbo].[vTMPSourceLoadOderIntake]
AS
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
GO
IF OBJECT_ID(N'dbo.TMPLoadVentas_Comm_OrderIntake', N'U') IS NOT NULL
    DROP TABLE dbo.TMPLoadVentas_Comm_OrderIntake;
CREATE TABLE [dbo].[TMPLoadVentas_Comm_OrderIntake]
(nr_position      [INT] NOT NULL,
 nr_kontrakt      [NVARCHAR](11) NULL,
 abgerechnet_dat  [DATETIME2](7) NULL,
 nr_liefnt        [NVARCHAR](8) NULL,
 nr_kunde         [NVARCHAR](8) NULL,
 industry         [NVARCHAR](4) NULL,
 erfasst          [DATETIME2](7) NULL,
 seriell          INT NULL,
 liefertermin     [DATETIME2](7) NULL,
 bez              [NVARCHAR](255) NULL,
 Merchandise      [NVARCHAR](1) NULL,
 nr_adress_k      [NVARCHAR](4) NULL,
 cty              [NVARCHAR](2) NULL,
 department       [NVARCHAR](10) NULL,
 preis_ges_dm     [MONEY] NULL,
 preis_ges_wr     [MONEY] NULL,
 DB2              [MONEY] NULL,
 bu_id            [NVARCHAR](3) NULL,
 currency         [NVARCHAR](3) NULL,
 Backlogrelevant  [VARCHAR](1) NULL,
 office_reference [NVARCHAR](30) NULL
)
ON [PRIMARY];
IF OBJECT_ID(N'dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post', N'U') IS NOT NULL
    DROP TABLE dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post;
CREATE TABLE dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post
(nr_kontrakt          [NVARCHAR](11) NULL,
 nr_position          [INT] NOT NULL,
 [Calculation_Status] [BIT] NULL,
 [Precal_IntakeDB2]   [MONEY] NULL,
 [Precal_IntakeDB3]   [MONEY] NULL,
 [Postcal_IntakeDB2]  [MONEY] NULL,
 [Postcal_IntakeDB3]  [MONEY] NULL,
)
ON [PRIMARY];
INSERT INTO dbo.TMPLoadVentas_Comm_OrderIntake
       SELECT *
       FROM vTMPSourceLoadOderIntake;
INSERT INTO dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post
       SELECT *
       FROM vTMPSourceLoadOderIntakeDB2_Post;
GO
WITH temp(nr_position,
          nr_kontrakt,
          abgerechnet_dat,
          nr_liefnt,
          nr_kunde,
          industry,
          erfasst,
          seriell,
          liefertermin,
          bez,
          Merchandise,
          nr_adress_k,
          cty,
          department,
          preis_ges_dm,
          preis_ges_wr,
          DB2,
          bu_id,
          currency,
          Backlogrelevant,
          office_reference,
          Precal_IntakeDB2,
          Precal_IntakeDB2_Currency,
          Precal_IntakeValue_Currency,
          Precal_IntakeValue,
          Precal_IntakeDB3,
          Postcal_IntakeDB2,
          Postcal_IntakeDB2_currency,
          Postcal_IntakeValue_Currency,
          Postcal_IntakeValue,
          Postcal_IntakeDB3,
          Calculation_Status)
     AS (SELECT FAKT_OrderIntake.nr_position,
                FAKT_OrderIntake.nr_kontrakt,
                FAKT_OrderIntake.abgerechnet_dat,
                FAKT_OrderIntake.nr_liefnt,
                FAKT_OrderIntake.nr_kunde,
                FAKT_OrderIntake.industry,
                FAKT_OrderIntake.erfasst,
                FAKT_OrderIntake.seriell,
                FAKT_OrderIntake.liefertermin,
                FAKT_OrderIntake.bez,
                FAKT_OrderIntake.Merchandise,
                FAKT_OrderIntake.nr_adress_k,
                FAKT_OrderIntake.cty,
                FAKT_OrderIntake.department,
                FAKT_OrderIntake.preis_ges_dm,
                FAKT_OrderIntake.preis_ges_wr,
                FAKT_OrderIntake.DB2,
                FAKT_OrderIntake.bu_id,
                FAKT_OrderIntake.currency,
                FAKT_OrderIntake.Backlogrelevant,
                FAKT_OrderIntake.office_reference,
                vTMP_VENTAS_OrderComplete_Comm_DB2pos.Precal_IntakeDB2,
                '0' AS Precal_IntakeDB2_Currency,
                dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PreCal_Value_Currency AS Precal_IntakeValue_Currency,
                dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PreCal_Value AS Precal_IntakeValue,
                vTMP_VENTAS_OrderComplete_Comm_DB2pos.Precal_IntakeDB3,
                vTMP_VENTAS_OrderComplete_Comm_DB2pos.Postcal_IntakeDB2,
                '0' AS Postcal_IntakeDB2_currency,
                dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PostCal_Value_Currency AS Postcal_IntakeValue_Currency,
                dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PostCal_Value AS Postcal_IntakeValue,
                vTMP_VENTAS_OrderComplete_Comm_DB2pos.Postcal_IntakeDB3,
                vTMP_VENTAS_OrderComplete_Comm_DB2pos.Calculation_Status
         FROM dbo.TMPLoadVentas_Comm_OrderIntake AS FAKT_OrderIntake
              LEFT JOIN dbo.vTMP_VENTAS_OrderComplete_Comm_Value ON dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_position = FAKT_OrderIntake.nr_position
                                                                    AND dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_kontrakt = FAKT_OrderIntake.nr_kontrakt
              LEFT JOIN dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post vTMP_VENTAS_OrderComplete_Comm_DB2pos ON vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt = FAKT_OrderIntake.nr_kontrakt
                                                                                                            AND vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position = FAKT_OrderIntake.nr_position)
     SELECT a.nr_position,
            a.nr_kontrakt,
            a.abgerechnet_dat,
            a.nr_liefnt,
            a.nr_kunde,
            a.industry,
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
            a.DB2,
            a.bu_id,
            a.currency,
            a.Backlogrelevant,
            a.office_reference,
            CASE
                WHEN ISNULL(a.Precal_IntakeValue, 0) = 0
                THEN ISNULL(a.preis_ges_dm, 0)
                ELSE ISNULL(a.Precal_IntakeValue, 0)
            END AS Precal_IntakeValue,
            CASE
                WHEN ISNULL(a.Precal_IntakeDB2, 0) = 0
                THEN ISNULL(a.DB2, 0)
                ELSE ISNULL(a.Precal_IntakeDB2, 0)
            END AS Precal_IntakeDB2,
            ISNULL(a.Precal_IntakeDB2_Currency, 0) AS Precal_IntakeDB2_Currency,
            CASE
                WHEN ISNULL(a.Precal_IntakeValue_Currency, 0) = 0
                THEN ISNULL(a.preis_ges_wr, 0)
                ELSE ISNULL(a.Precal_IntakeValue_Currency, 0)
            END AS Precal_IntakeValue_Currency,
            ISNULL(a.Postcal_IntakeValue, 0) AS Postcal_IntakeValue,
            ISNULL(a.Postcal_IntakeValue_Currency, 0) AS Postcal_IntakeValue_Currency,
            ISNULL(a.Postcal_IntakeDB2, 0) AS Postcal_IntakeDB2,
            ISNULL(a.Postcal_IntakeDB2_currency, 0) AS Postcal_IntakeDB2_currency,
            ISNULL(a.Precal_IntakeDB3, 0) AS Precal_IntakeDB3,
            ISNULL(a.Postcal_IntakeDB3, 0) AS Postcal_IntakeDB3,
            CASE
                WHEN a.[Calculation_Status] IS NULL
                THEN 0
                ELSE a.[Calculation_Status]
            END AS Calculation_Status
     FROM temp AS a;


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
       ord_no AS office_reference,
       ISNULL(OrderValue, 0) AS Precal_IntakeValue,
       ISNULL(DB2, 0) AS Precal_IntakeDB2,
       ISNULL(DB2_in_local_currency, 0) AS Precal_IntakeDB2_Currency,
       ISNULL(OrderValue_in_local_currency, 0) AS Precal_IntakeValue_Currency,
       '0' AS Postcal_IntakeValue,
       '0' AS Postcal_IntakeValue_Currency,
       '0' AS Postcal_IntakeDB2,
       '0' AS Postcal_IntakeDB2_currency,
       '0' AS Precal_IntakeDB3,
       '0' AS Postcal_IntakeDB3,
       '0' AS [Calculation_Status]
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
       Backlogrelevant,
       ISNULL(Wert_Wrg, 0) AS Precal_IntakeValue,
       ISNULL(DB2, 0) AS Precal_IntakeDB2,
       '0' AS Precal_IntakeDB2_Currency,
       '0' AS Precal_IntakeValue_Currency,
       '0' AS Postcal_IntakeValue,
       '0' AS Postcal_IntakeValue_Currency,
       '0' AS Postcal_IntakeDB2,
       '0' AS Postcal_IntakeDB2_currency,
       '0' AS Precal_IntakeDB3,
       '0' AS Postcal_IntakeDB3,
       '0' AS [Calculation_Status]
FROM dbo.vTMP_HKGOrders_DB2
WHERE ISNUMERIC(bu_id) = 1;
------------------------------------------------------------------------------------

/*LOD Order Intake*/

CREATE VIEW [dbo].[vTMP_LOD_OrderIntake_Before2013]
AS
     SELECT o.Industry,
            o.Merchandise,
            o.EstDeliveryDate,
            o.Currency,
            o.OrderIntakeDate,
            o.GoodDescription,
            o.OrderVal_EUR,
            o.DB2Val_EUR,
            o.OrderVal,
            o.DB2Val,
            o.LocalRef,
            c.CustomerID,
            s.SupplierID,
            o.GroupNo AS OrderNo_New,
            CAST('LOD' AS NVARCHAR(5)) AS source,
            tb.bu_id,
            CASE
                WHEN vl.source = 'HKG'
                THEN 'J'
                ELSE CASE
                         WHEN bs.ShippedDate IS NOT NULL
                         THEN 'N'
                         ELSE 'J'
                     END
            END AS backlogrelevant,
            '1' AS OrderPos,
            bs.ShippedDate,
            LEFT(o.BusinessType, 1) AS OrderType,
            CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter,
            ors.LabourDB3,
            ors.LabourDB3Post,
            o.OrderVal_EUR AS Precal_IntakeValue,
            o.DB2Val_EUR AS Precal_IntakeDB2,
            o.OrderVal AS Precal_IntakeValue_Currency,
            o.DB2Val AS Precal_IntakeDB2_Currency,
            ors.LabourDB3 AS Precal_IntakeDB3,
            CASE
                WHEN bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.OrderVal_EUR, 0)
                ELSE 0
            END AS Postcal_IntakeValue,
            CASE
                WHEN bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.OrderVal, 0)
                ELSE 0
            END AS Postcal_IntakeValue_Currency,
            CASE
                WHEN bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.DB2Amt_EUR, 0)
                ELSE 0
            END AS Postcal_IntakeDB2,
            CASE
                WHEN bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.DB2Amt, 0)
                ELSE 0
            END AS Postcal_IntakeDB2_currency,
            CASE
                WHEN bs.FinalizedDate IS NOT NULL
                THEN ISNULL(ors.LabourDB3Post, 0)
                ELSE 0
            END AS Postcal_IntakeDB3,
            CASE
                WHEN bs.FinalizedDate IS NOT NULL
                THEN 1
                ELSE 0
            END AS Calculation_Status
     FROM LZ_LOD_OrderReg o
          LEFT JOIN LZ_LOD_Customer c ON o.Customer = c.CustomerName
          LEFT JOIN LZ_LOD_Supplier s ON o.Supplier = s.SupplierName
          JOIN tmp_bu tb ON o.BusinessUnit = tb.bu_desc
          JOIN
     (
         SELECT OrderNo,
                'HKG' AS source
         FROM dbo.vLOD_HKGOrderNo
         UNION ALL
         SELECT OrderNo,
                'HKG'
         FROM dbo.vLOD_FOXPROOrderNo_Before2013
         UNION ALL
         SELECT OrderNo,
                'nonHKG'
         FROM dbo.vLOD_NonHKGOrderNo
     ) vl ON o.GroupNo = vl.OrderNo
          LEFT JOIN LZ_LOD_OrderBillingShipping bs ON o.OrderNo = bs.OrderNo
          LEFT JOIN ADM_ProcurementCenter pc ON pc.description = o.ProcCenter
          LEFT JOIN LZ_LOD_OrderRegService ors ON o.OrderNo = ors.OrderNo
                                                  AND o.Merchandise = 'S'
     WHERE ISNULL(ors.Chareable, 1) <> 0
           AND o.OrderIntakeDate >= '2008-01-01'
           AND YEAR(o.OrderIntakeDate) < 2013; -- filter out non-chargeable LOD service orders 
GO
CREATE VIEW [dbo].[vTMP_LOD_OrderIntake_Since2013]
AS
     SELECT o.Industry,
            o.Merchandise,
            o.EstDeliveryDate,
            o.Currency,
            o.OrderIntakeDate,
            o.GoodDescription,
            o.OrderVal_EUR,
            o.DB2Val_EUR,
            o.OrderVal,
            o.DB2Val,
            o.LocalRef,
            c.CustomerID,
            s.SupplierID,
            o.GroupNo AS OrderNo_New,
            CAST('LOD' AS NVARCHAR(5)) AS source,
            tb.bu_id,
            CASE
                WHEN vl.source = 'HKG'
                THEN 'J'
                ELSE CASE
                         WHEN bs.ShippedDate IS NOT NULL
                         THEN 'N'
                         ELSE 'J'
                     END
            END AS backlogrelevant,
            '1' AS OrderPos,
            bs.ShippedDate,
            LEFT(o.BusinessType, 1) AS OrderType,
            CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter,
            ors.LabourDB3,
            ors.LabourDB3Post,
            o.OrderVal_EUR AS Precal_IntakeValue,
            o.DB2Val_EUR AS Precal_IntakeDB2,
            o.OrderVal AS Precal_IntakeValue_Currency,
            o.DB2Val AS Precal_IntakeDB2_Currency,
            ors.LabourDB3 AS Precal_IntakeDB3,
            CASE
                WHEN vl.source = 'nonHKG'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.OrderVal_EUR, 0)
                WHEN o.Merchandise = 'S'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.OrderVal_EUR, 0)
                WHEN ss.active = 0
                     AND vl.source <> 'nonHKG'
                     AND o.Merchandise <> 'S'
                THEN ISNULL(sc.OrderCompleteValue, 0)
                ELSE 0
            END AS Postcal_IntakeValue,
            CASE
                WHEN vl.source = 'nonHKG'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.OrderVal, 0)
                WHEN o.Merchandise = 'S'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.OrderVal, 0)
                WHEN ss.active = 0
                     AND vl.source <> 'nonHKG'
                     AND o.Merchandise <> 'S'
                THEN ISNULL(o.OrderVal, 0)
                ELSE 0
            END AS Postcal_IntakeValue_Currency,
            CASE
                WHEN vl.source = 'nonHKG'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.DB2Amt_EUR, 0)
                WHEN o.Merchandise = 'S'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.DB2Amt_EUR, 0)
                WHEN ss.active = 0
                     AND vl.source <> 'nonHKG'
                     AND o.Merchandise <> 'S'
                THEN ISNULL(sd.OrderCompleteDB2, 0)
                ELSE 0
            END AS Postcal_IntakeDB2,
            CASE
                WHEN vl.source = 'nonHKG'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.DB2Amt, 0)
                WHEN o.Merchandise = 'S'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(bs.DB2Amt, 0)
                WHEN ss.active = 0
                     AND vl.source <> 'nonHKG'
                     AND o.Merchandise <> 'S'
                THEN 0
                ELSE 0
            END AS Postcal_IntakeDB2_currency,
            CASE
                WHEN vl.source = 'nonHKG'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(ors.LabourDB3Post, 0)
                WHEN o.Merchandise = 'S'
                     AND bs.FinalizedDate IS NOT NULL
                THEN ISNULL(ors.LabourDB3Post, 0)
                WHEN ss.active = 0
                     AND vl.source <> 'nonHKG'
                     AND o.Merchandise <> 'S'
                THEN 0
                ELSE 0
            END AS Postcal_IntakeDB3,
            CASE
                WHEN vl.source = 'nonHKG'
                     AND bs.FinalizedDate IS NOT NULL
                THEN 1
                WHEN o.Merchandise = 'S'
                     AND bs.FinalizedDate IS NOT NULL
                THEN 1
                WHEN ss.active = 0
                     AND vl.source <> 'nonHKG'
                     AND o.Merchandise <> 'S'
                THEN 1
                ELSE 0
            END AS Calculation_Status
     FROM LZ_LOD_OrderReg o
          LEFT JOIN LZ_LOD_Customer c ON o.Customer = c.CustomerName
          LEFT JOIN LZ_LOD_Supplier s ON o.Supplier = s.SupplierName
          JOIN tmp_bu tb ON o.BusinessUnit = tb.bu_desc
          JOIN
     (
         SELECT OrderNo,
                'HKG' AS source
         FROM dbo.vLOD_HKGOrderNo
         UNION ALL
         SELECT OrderNo,
                'HKG'
         FROM dbo.vLOD_FOXPROOrderNo_Since2013
         UNION ALL
         SELECT OrderNo,
                'nonHKG'
         FROM dbo.vLOD_NonHKGOrderNo
     ) vl ON o.GroupNo = vl.OrderNo
          LEFT JOIN LZ_LOD_OrderBillingShipping bs ON o.OrderNo = bs.OrderNo
          LEFT JOIN ADM_ProcurementCenter pc ON pc.description = o.ProcCenter
          LEFT JOIN LZ_LOD_OrderRegService ors ON o.OrderNo = ors.OrderNo
                                                  AND o.Merchandise = 'S'
          LEFT JOIN dbo.vTMP_Solomon_03_OrderComplete_Date_BusinessType_new sb ON o.GroupNo = sb.ord_no
          LEFT JOIN dbo.vTMP_Solomon_02_OrderComplete_value_new sc ON o.GroupNo = sc.ord_no
          LEFT JOIN
     (
         SELECT [ord_no],
                SUM([OrderCompleteDB2]) AS [OrderCompleteDB2]
         FROM [dbo].[vTMP_Solomon_02_OrderComplete_DB2_New]
         GROUP BY [ord_no]
     ) AS sd ON o.GroupNo = sd.ord_no
          LEFT JOIN dbo.TMP_Solomon_SubAcct ss ON o.GroupNo = ss.orderno
     WHERE ISNULL(ors.Chareable, 1) <> 0
           AND YEAR(o.OrderIntakeDate) >= 2013; -- filter out non-chargeable LOD service orders 




GO
SELECT *
FROM vTMP_LOD_OrderIntake_Since2013
UNION ALL
SELECT *
FROM vTMP_LOD_OrderIntake_Before2013;