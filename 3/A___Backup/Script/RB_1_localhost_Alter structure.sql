USE [Staging_Test];
GO

/****** Object:  View [dbo].[vTMP_VENTAS_OrderComplete_Comm_DB2pos]    Script Date: 6/1/2016 1:43:31 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
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
            -- removed after meeting with project team 11.10.2013 15:07
            --b.db2wrg / a.kurs as db2,
            a.belegdatum,
            '' AS konto
     FROM vTMP_VENTAS_OrderComplete_Comm_Value a
          JOIN vTMP_VENTAS_OrderIntake_Comm_03_DB2pos b ON a.nr_kontrakt = b.nr_kontrakt
                                                           AND a.nr_position = b.nr_position
     WHERE abgerechnet_dat IS NULL;
GO

/****** Object:  View [dbo].[vTMP_VENTAS_OrderComplete_Comm_Value]    Script Date: 6/1/2016 1:43:42 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Comm_Value]
AS
     SELECT dbo.LZ_VENTAS_akpos.nr_kontrakt,
            dbo.LZ_VENTAS_akpos.nr_position,
            dbo.LZ_VENTAS_akpos.preis_ges_wr,
            dbo.LZ_VENTAS_akpos.preis_ges_dm,
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

/****** Object:  View [dbo].[vTMP_VENTAS_OrderComplete_Trade_DB2pos]    Script Date: 6/1/2016 1:44:45 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
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
            -- removed after meeting with project team 11.10.2013 15:07
            --b.db2wrg / c.kurs as db2, -- Order Intake DB2 with exchange rate from invoice

            '' AS konto
     FROM TMP_VENTAS_OrderIntake_Trade_03_DB2pos b
          INNER JOIN TMP_VENTAS_OrderComplete_Trade_Value c ON b.nr_auftrag = c.nr_Auftrag
                                                               AND b.nr_position_vpos = c.nr_position
                                                               AND b.abgerechnet_dat IS NULL;
GO

/****** Object:  View [dbo].[vTMP_VENTAS_OrderComplete_Trade_Value]    Script Date: 6/1/2016 1:45:20 PM ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Trade_Value]
AS
     SELECT a.nr_Auftrag,
            a.nr_position,
            a.belegdatum,
            a.liefertermin,

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