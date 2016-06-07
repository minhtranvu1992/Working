USE [Staging];
GO


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
		  b.db2 AS PreCal_Value_DB2,
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

