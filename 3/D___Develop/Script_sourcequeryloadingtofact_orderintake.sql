/*VENTAS_OrderIntake_trade*/

WITH temp1(nr_auftrag,erfasst,abgerechnet_dat,betreff,nr_kunde,nr_liefnt,bez,industry,cty,department,nr_position_vpos,liefertermin,Merchandise,preis_ges_dm,preis_ges_wr,DB2,bu_id,currency,Backlogrelevant,office_reference)
AS
(SELECT a.nr_auftrag,
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
WHERE(a.erfasst >= '2008-01-01')
),

temp2(nr_auftrag,erfasst,abgerechnet_dat,betreff,nr_kunde,nr_liefnt,bez,industry,cty,department,nr_position_vpos,liefertermin,Merchandise,preis_ges_dm,preis_ges_wr,DB2,bu_id,currency,Backlogrelevant,office_reference,Postcal_IntakeDB2
,Postcal_IntakeDB2_currency,PostCal_Value_DB3,Precal_IntakeDB2,Precal_IntakeDB2_Currency,Precal_IntakeDB3,Postcal_IntakeDB3,
Precal_IntakeValue_Currency,Precal_IntakeValue,Postcal_IntakeValue_Currency,Postcal_IntakeValue,Calculation_Status)
AS 
(SELECT FAKT_OrderIntake.nr_auftrag,
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
           THEN ISNULL(a.preis_ges_dm,0)
           ELSE ISNULL(a.Precal_IntakeValue, 0)
       END AS Precal_IntakeValue,
       CASE
           WHEN ISNULL(a.Precal_IntakeDB2, 0) = 0
           THEN ISNULL(a.DB2,0)
           ELSE ISNULL(a.Precal_IntakeDB2, 0)
       END AS Precal_IntakeDB2,
       ISNULL(a.Precal_IntakeDB2_Currency, 0) AS Precal_IntakeDB2_Currency,
       CASE
           WHEN ISNULL(a.Precal_IntakeValue_Currency, 0) = 0
           THEN ISNULL(a.preis_ges_wr,0)
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
    DROP VIEW [dbo].[vTMPSourceLoadOderIntakeDB2_Post]
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
                      dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.Calculation_Status
GO
GO
IF OBJECT_ID('dbo.vTMPSourceLoadOderIntake', 'V') IS NOT NULL
    DROP VIEW [dbo].[vTMPSourceLoadOderIntake]
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
         WHERE(a.erfasst >= '2008-01-01')
GO


IF OBJECT_ID(N'dbo.TMPLoadVentas_Comm_OrderIntake', N'U') IS NOT NULL 
DROP TABLE dbo.TMPLoadVentas_Comm_OrderIntake
CREATE TABLE [dbo].[TMPLoadVentas_Comm_OrderIntake](
	nr_position [int] NOT NULL,
	nr_kontrakt [nvarchar](11) NULL,
	abgerechnet_dat [datetime2](7) null,
	nr_liefnt [nvarchar](8) NULL,
	nr_kunde [nvarchar](8) NULL,
	industry [nvarchar](4) NULL,
	erfasst [datetime2](7) NULL,
	seriell int null,
	liefertermin [datetime2](7) NULL,
	bez [nvarchar](255) NULL,
	Merchandise [nvarchar](1) NULL,
	nr_adress_k [nvarchar](4) null,
	cty [nvarchar](2) NULL,
	department [nvarchar](10) NULL,
	preis_ges_dm [money] NULL,
	preis_ges_wr [money] NULL,
	DB2 [money] NULL,
	bu_id [nvarchar](3) NULL,
	currency [nvarchar](3) NULL,
	Backlogrelevant [varchar](1) NULL,
	office_reference [nvarchar](30) NULL

) ON [PRIMARY]


IF OBJECT_ID(N'dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post', N'U') IS NOT NULL 
DROP TABLE dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post
CREATE TABLE dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post
(	nr_kontrakt [nvarchar](11) NULL,
	nr_position [int] NOT NULL,
	[Calculation_Status] [bit] NULL,
	[Precal_IntakeDB2] [money] NULL,
	[Precal_IntakeDB3] [money] NULL,
	[Postcal_IntakeDB2] [money] NULL,
	[Postcal_IntakeDB3] [money] NULL,	
)ON [PRIMARY]


INSERT INTO dbo.TMPLoadVentas_Comm_OrderIntake
SELECT *
FROM vTMPSourceLoadOderIntake

INSERT INTO dbo.TMPLoadVentas_Comm_OrderIntakeDB2_Post
SELECT * from vTMPSourceLoadOderIntakeDB2_Post
GO






WITH     temp(nr_position,
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
     AS 
(SELECT FAKT_OrderIntake.nr_position,
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
                THEN ISNULL(a.preis_ges_dm,0)
                ELSE ISNULL(a.Precal_IntakeValue, 0)
            END AS Precal_IntakeValue,
            CASE
                WHEN ISNULL(a.Precal_IntakeDB2, 0) = 0
                THEN ISNULL(a.DB2,0)
                ELSE ISNULL(a.Precal_IntakeDB2, 0)
            END AS Precal_IntakeDB2,
            ISNULL(a.Precal_IntakeDB2_Currency, 0) AS Precal_IntakeDB2_Currency,
            CASE
                WHEN ISNULL(a.Precal_IntakeValue_Currency, 0) = 0
                THEN ISNULL(a.preis_ges_wr,0)
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
     FROM temp AS a


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
       ISNULL(OrderValue,0) AS Precal_IntakeValue,
       ISNULL(DB2,0) AS Precal_IntakeDB2,
       ISNULL(DB2_in_local_currency,0) AS Precal_IntakeDB2_Currency,
       iSNULL(OrderValue_in_local_currency,0) AS Precal_IntakeValue_Currency,
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
       ISNULL(Wert_Wrg,0) AS Precal_IntakeValue,
       ISNULL(DB2,0) AS Precal_IntakeDB2,
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

SELECT *
FROM vTMP_LOD_OrderIntake;