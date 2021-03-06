/*
Run this script on:

        10.124.101.6.Staging    -  This database will be modified

to synchronize it with:

        10.124.101.6.StagingTest

You are recommended to back up your database before running this script

Script created by SQL Compare version 11.5.2 from Red Gate Software Ltd at 6/6/2016 4:11:39 PM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Comm_Value]'
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Comm_Value]
AS
     SELECT dbo.LZ_VENTAS_akpos.nr_kontrakt,
            dbo.LZ_VENTAS_akpos.nr_position,
            dbo.LZ_VENTAS_akpos.preis_ges_wr,
            dbo.LZ_VENTAS_akpos.preis_ges_dm,
            dbo.LZ_VENTAS_akpos.preis_ges_wr AS PreCal_Value_Currency,
            dbo.LZ_VENTAS_akpos.preis_ges_dm AS PreCal_Value,
            '0' AS PostCal_Value,
            '0' AS PostCal_Value_Currency,
            '0' AS [Calculation_Status],
            dbo.LZ_VENTAS_akontr.nr_waehrung,
            dbo.LZ_VENTAS_rgko.kurs,
            MIN(dbo.LZ_VENTAS_rgko.belegdatum) AS belegdatum
     FROM dbo.LZ_VENTAS_apos
          INNER JOIN dbo.LZ_VENTAS_akontr INNER JOIN dbo.LZ_VENTAS_akpos ON dbo.LZ_VENTAS_akontr.[database] = dbo.LZ_VENTAS_akpos.[database]
                                                                            AND dbo.LZ_VENTAS_akontr.nr_kontrakt = dbo.LZ_VENTAS_akpos.nr_kontrakt ON dbo.LZ_VENTAS_apos.join_akpos = dbo.LZ_VENTAS_akpos.seriell
                                                                                                                                                      AND dbo.LZ_VENTAS_apos.[database] = dbo.LZ_VENTAS_akpos.[database]
          INNER JOIN dbo.LZ_VENTAS_rgpo INNER JOIN dbo.LZ_VENTAS_rgko ON dbo.LZ_VENTAS_rgpo.join_feld = dbo.LZ_VENTAS_rgko.seriell
                                                                         AND dbo.LZ_VENTAS_rgpo.[database] = dbo.LZ_VENTAS_rgko.[database] ON dbo.LZ_VENTAS_apos.seriell = dbo.LZ_VENTAS_rgpo.join_apos
                                                                                                                                              AND dbo.LZ_VENTAS_apos.[database] = dbo.LZ_VENTAS_rgpo.[database]
     WHERE(dbo.LZ_VENTAS_rgko.satzart = N'RECH'
           AND dbo.LZ_VENTAS_rgko.join_storno IS NULL)
     --and dbo.LZ_VENTAS_akpos.nr_kontrakt = 202252

     GROUP BY dbo.LZ_VENTAS_akpos.nr_kontrakt,
              dbo.LZ_VENTAS_akpos.nr_position,
              dbo.LZ_VENTAS_akpos.preis_ges_wr,
              dbo.LZ_VENTAS_akpos.preis_ges_dm,
              dbo.LZ_VENTAS_akontr.nr_waehrung,
              dbo.LZ_VENTAS_rgko.kurs;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Trade_Value]'
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Trade_Value]
AS
     SELECT a.nr_Auftrag,
            a.nr_position,
            a.belegdatum,
            a.liefertermin,
            a.preis_ges_wr AS PreCal_Value_Currency,
            a.preis_ges_dm AS PreCal_Value,
            CASE
                WHEN a.abgerechnet_dat IS NOT NULL
                THEN b.preis_ges_wr
                ELSE 0
            END AS PostCal_Value_Currency,
            CASE
                WHEN a.abgerechnet_dat IS NOT NULL
                THEN b.preis_ges_dm
                ELSE 0
            END AS PostCal_Value,
            CASE
                WHEN a.abgerechnet_dat IS NOT NULL
                THEN 1
                ELSE 0
            END AS [Calculation_Status],
            -- if abgrechnet_dat is null then order intake value else invoice values
            CASE
                WHEN a.abgerechnet_dat IS NULL
                THEN a.preis_ges_wr
                ELSE b.preis_ges_wr
            END AS preis_ges_wr,
            CASE
                WHEN a.abgerechnet_dat IS NULL
                THEN a.preis_ges_dm
                ELSE b.preis_ges_dm
            END AS preis_ges_dm,
            a.kurs
     FROM -- getting order complete date
     (
         SELECT dbo.LZ_VENTAS_vkopf.nr_auftrag,
                dbo.LZ_VENTAS_vpos.nr_position,
                dbo.LZ_VENTAS_vpos.liefertermin,
                dbo.LZ_VENTAS_rgko.belegdatum,
                dbo.LZ_VENTAS_rgko.kurs,
                dbo.LZ_VENTAS_vpos.preis_ges_wr,
                dbo.LZ_VENTAS_vpos.preis_ges_dm,
                dbo.LZ_VENTAS_ksttr.abgerechnet_dat
         FROM dbo.LZ_VENTAS_vkopf
              INNER JOIN dbo.LZ_VENTAS_vpos ON dbo.LZ_VENTAS_vkopf.nr_auftrag = dbo.LZ_VENTAS_vpos.nr_auftrag
                                               AND dbo.LZ_VENTAS_vkopf.[database] = dbo.LZ_VENTAS_vpos.[database]
              INNER JOIN dbo.LZ_VENTAS_rgpo ON dbo.LZ_VENTAS_vpos.[database] = dbo.LZ_VENTAS_rgpo.[database]
                                               AND dbo.LZ_VENTAS_vpos.seriell = dbo.LZ_VENTAS_rgpo.join_vpos
              INNER JOIN dbo.LZ_VENTAS_rgko ON dbo.LZ_VENTAS_rgpo.join_feld = dbo.LZ_VENTAS_rgko.seriell
                                               AND dbo.LZ_VENTAS_rgpo.[database] = dbo.LZ_VENTAS_rgko.[database]
              INNER JOIN dbo.LZ_VENTAS_ksttr ON dbo.LZ_VENTAS_vkopf.nr_auftrag = dbo.LZ_VENTAS_ksttr.join_table
                                                AND dbo.LZ_VENTAS_vkopf.[database] = dbo.LZ_VENTAS_ksttr.[database]
         WHERE(YEAR(dbo.LZ_VENTAS_rgko.belegdatum) >= 2008)
              AND (dbo.LZ_VENTAS_rgko.satzart = N'RECH')
              AND (dbo.LZ_VENTAS_rgko.join_storno IS NULL)
     ) a
     JOIN -- getting invoice values for order completes

     (
         SELECT dbo.LZ_VENTAS_vkopf.nr_auftrag,
                dbo.LZ_VENTAS_vpos.nr_position,
                SUM(CASE
                        WHEN dbo.LZ_VENTAS_rgpo.belart = 18
                        THEN-1
                        ELSE 1
                    END * dbo.LZ_VENTAS_rgpo.preis_ges_wr) AS preis_ges_wr,
                SUM(CASE
                        WHEN dbo.LZ_VENTAS_rgpo.belart = 18
                        THEN-1
                        ELSE 1
                    END * dbo.LZ_VENTAS_rgpo.preis_ges_dm) AS preis_ges_dm
         FROM dbo.LZ_VENTAS_vkopf
              INNER JOIN dbo.LZ_VENTAS_vpos ON dbo.LZ_VENTAS_vkopf.nr_auftrag = dbo.LZ_VENTAS_vpos.nr_auftrag
                                               AND dbo.LZ_VENTAS_vkopf.[database] = dbo.LZ_VENTAS_vpos.[database]
              INNER JOIN dbo.LZ_VENTAS_rgpo ON dbo.LZ_VENTAS_vpos.[database] = dbo.LZ_VENTAS_rgpo.[database]
                                               AND dbo.LZ_VENTAS_vpos.seriell = dbo.LZ_VENTAS_rgpo.join_vpos
              INNER JOIN dbo.LZ_VENTAS_rgko ON dbo.LZ_VENTAS_rgpo.join_feld = dbo.LZ_VENTAS_rgko.seriell
                                               AND dbo.LZ_VENTAS_rgpo.[database] = dbo.LZ_VENTAS_rgko.[database]
         WHERE dbo.LZ_VENTAS_rgko.satzart <> N'RECT'
         GROUP BY dbo.LZ_VENTAS_vkopf.nr_auftrag,
                  dbo.LZ_VENTAS_vpos.nr_position
     ) b ON a.nr_auftrag = b.nr_auftrag
            AND a.nr_position = b.nr_position;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Comm_DB2pos]'
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Comm_DB2pos]
AS
     SELECT a.nr_kontrakt,
            a.nr_position,
            SUM(c.b_betrag) * CASE
                                  WHEN b.preis_ges_dm_ges = 0
                                  THEN a.preis_ges_dm / (anz_pos * 1.0)
                                  ELSE a.preis_ges_dm / b.preis_ges_dm_ges * 100
                              END / 100 AS DB2,
            '0' AS PreCal_Value_DB2,
            '0' AS PreCal_Value_DB3,
            SUM(c.b_betrag) * CASE
                                  WHEN b.preis_ges_dm_ges = 0
                                  THEN a.preis_ges_dm / (anz_pos * 1.0)
                                  ELSE a.preis_ges_dm / b.preis_ges_dm_ges * 100
                              END / 100 AS PostCal_Value_DB2,
            '0' AS PostCal_Value_DB3,
            '1' AS [Calculation_Status],
            a.belegdatum,
            c.nr_konto
     FROM dbo.vTMP_VENTAS_OrderComplete_Comm_Value AS a
          INNER JOIN
     (
         SELECT nr_kontrakt,
                SUM(preis_ges_dm) AS preis_ges_dm_ges,
                COUNT(*) AS anz_pos
         FROM dbo.vTMP_VENTAS_OrderComplete_Comm_Value
         GROUP BY nr_kontrakt
     ) AS b ON a.nr_kontrakt = b.nr_kontrakt
          INNER JOIN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2 AS c ON c.nr_kontrakt = a.nr_kontrakt
     GROUP BY a.nr_kontrakt,
              a.nr_position,
              b.preis_ges_dm_ges,
              a.preis_ges_dm,
              b.anz_pos,
              a.belegdatum,
              c.nr_konto
     UNION ALL

     -- DB2 from Order Intake for Order with "abgerechnet_dat" = null
     SELECT a.nr_kontrakt,
            a.nr_position,
            b.db2,
            ISNULL(b.db2,0) AS PreCal_Value_DB2,
            '0' AS PreCal_Value_DB3,
            '0' AS PostCal_Value_DB2,
            '0' AS PostCal_Value_DB3,
            '0' AS [Calculation_Status],
            -- removed after meeting with project team 11.10.2013 15:07
            --b.db2wrg / a.kurs as db2,
            a.belegdatum,
            '' AS konto
     FROM vTMP_VENTAS_OrderComplete_Comm_Value a
          JOIN vTMP_VENTAS_OrderIntake_Comm_03_DB2pos b ON a.nr_kontrakt = b.nr_kontrakt
                                                           AND a.nr_position = b.nr_position
     WHERE abgerechnet_dat IS NULL;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderComplete]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderComplete] ADD
[PreCal_Value] [money] NULL,
[PreCal_Value_Currency] [money] NULL,
[PostCal_Value] [money] NULL,
[PostCal_Value_Currency] [money] NULL,
[Calculation_Status] [bit] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Rebuilding [dbo].[TMP_VENTAS_OrderComplete_Trade_Value]'
GO
CREATE TABLE [dbo].[RG_Recovery_1_TMP_VENTAS_OrderComplete_Trade_Value]
(
[nr_Auftrag] [int] NULL,
[nr_position] [smallint] NULL,
[belegdatum] [datetime2] NULL,
[liefertermin] [datetime2] NULL,
[PreCal_Value_Currency] [numeric] (16, 2) NULL,
[PreCal_Value] [numeric] (16, 2) NULL,
[PostCal_Value_Currency] [numeric] (38, 2) NULL,
[PostCal_Value] [numeric] (38, 2) NULL,
[Calculation_Status] [int] NOT NULL,
[preis_ges_wr] [numeric] (38, 2) NULL,
[preis_ges_dm] [numeric] (38, 2) NULL,
[kurs] [float] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
INSERT INTO [dbo].[RG_Recovery_1_TMP_VENTAS_OrderComplete_Trade_Value]([nr_Auftrag], [nr_position], [belegdatum], [liefertermin], [preis_ges_wr], [preis_ges_dm], [kurs]) SELECT [nr_Auftrag], [nr_position], [belegdatum], [liefertermin], [preis_ges_wr], [preis_ges_dm], [kurs] FROM [dbo].[TMP_VENTAS_OrderComplete_Trade_Value]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DROP TABLE [dbo].[TMP_VENTAS_OrderComplete_Trade_Value]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[RG_Recovery_1_TMP_VENTAS_OrderComplete_Trade_Value]', N'TMP_VENTAS_OrderComplete_Trade_Value', N'OBJECT'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Trade_DB2pos]'
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Trade_DB2pos]
AS
     SELECT a.nr_auftrag,
            a.nr_position,
            SUM(c.b_betrag) * CASE
                                  WHEN b.preis_ges_dm_ges = 0
                                  THEN a.preis_ges_dm / (anz_pos * 1.0)
                                  ELSE a.preis_ges_dm / b.preis_ges_dm_ges * 100
                              END / 100 AS DB2,
            '0' AS PreCal_Value_DB2,
            '0' AS PreCal_Value_DB3,
            SUM(c.b_betrag) * CASE
                                  WHEN b.preis_ges_dm_ges = 0
                                  THEN a.preis_ges_dm / (anz_pos * 1.0)
                                  ELSE a.preis_ges_dm / b.preis_ges_dm_ges * 100
                              END / 100 AS PostCal_Value_DB2,
            '0' AS PostCal_Value_DB3,
            '1' AS [Calculation_Status],
            c.nr_konto1
     FROM dbo.vTMP_VENTAS_OrderComplete_Trade_Value AS a
          INNER JOIN
     (
         SELECT nr_auftrag,
                SUM(preis_ges_dm) AS preis_ges_dm_ges,
                COUNT(*) AS anz_pos
         FROM dbo.vTMP_VENTAS_OrderComplete_Trade_Value
         GROUP BY nr_auftrag
     ) AS b ON a.nr_auftrag = b.nr_auftrag
          INNER JOIN dbo.vTMP_VENTAS_OrderComplete_Trade_DB2 AS c ON c.nr_auftrag = a.nr_auftrag
     GROUP BY a.nr_auftrag,
              a.nr_position,
              b.preis_ges_dm_ges,
              a.preis_ges_dm,
              b.anz_pos,
              c.nr_konto1
     UNION ALL
     -- DB2 from Order Intake for Order with "abgerechnet_dat" = null
     SELECT b.nr_Auftrag,
            b.nr_position_vpos,
            b.db2,
            ISNULL(b.db2,0) AS PreCal_Value_DB2,
            '0' AS PreCal_Value_DB3,
            '0' AS PostCal_Value_DB2,
            '0' AS PostCal_Value_DB3,
            '0' AS [Calculation_Status],
            -- removed after meeting with project team 11.10.2013 15:07
            --b.db2wrg / c.kurs as db2, -- Order Intake DB2 with exchange rate from invoice

            '' AS konto
     FROM TMP_VENTAS_OrderIntake_Trade_03_DB2pos b
          INNER JOIN TMP_VENTAS_OrderComplete_Trade_Value c ON b.nr_auftrag = c.nr_Auftrag
                                                               AND b.nr_position_vpos = c.nr_position
                                                               AND b.abgerechnet_dat IS NULL;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderComplete_DB2]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderComplete_DB2] ADD
[PreCal_Value_DB2] [money] NULL,
[PreCal_Value_DB3] [money] NULL,
[PostCal_Value_DB2] [money] NULL,
[PostCal_Value_DB3] [money] NULL,
[Calculation_Status] [bit] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
