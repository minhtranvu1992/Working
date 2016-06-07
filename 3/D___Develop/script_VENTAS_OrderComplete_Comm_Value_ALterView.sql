USE [Staging];
GO


     
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
