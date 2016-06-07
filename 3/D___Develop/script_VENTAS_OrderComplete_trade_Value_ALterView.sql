USE [Staging];
GO
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