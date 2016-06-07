USE [Staging];
GO


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
		  b.db2 AS PreCal_Value_DB2,
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
