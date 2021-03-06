/*
Run this script on:

        (local).Staging_Test    -  This database will be modified

to synchronize it with:

        (local).Staging

You are recommended to back up your database before running this script

Script created by SQL Compare version 11.5.2 from Red Gate Software Ltd at 6/1/2016 4:48:50 PM

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



ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Comm_Value] AS
SELECT		dbo.LZ_VENTAS_akpos.nr_kontrakt, 
			dbo.LZ_VENTAS_akpos.nr_position, 
			dbo.LZ_VENTAS_akpos.preis_ges_wr, 
			dbo.LZ_VENTAS_akpos.preis_ges_dm, 
            dbo.LZ_VENTAS_akontr.nr_waehrung,  
            dbo.LZ_VENTAS_rgko.kurs, 
            MIN(dbo.LZ_VENTAS_rgko.belegdatum) AS belegdatum
FROM         dbo.LZ_VENTAS_apos INNER JOIN
                      dbo.LZ_VENTAS_akontr INNER JOIN
                      dbo.LZ_VENTAS_akpos ON dbo.LZ_VENTAS_akontr.[database] = dbo.LZ_VENTAS_akpos.[database] AND 
                      dbo.LZ_VENTAS_akontr.nr_kontrakt = dbo.LZ_VENTAS_akpos.nr_kontrakt ON dbo.LZ_VENTAS_apos.join_akpos = dbo.LZ_VENTAS_akpos.seriell AND 
                      dbo.LZ_VENTAS_apos.[database] = dbo.LZ_VENTAS_akpos.[database] INNER JOIN
                      dbo.LZ_VENTAS_rgpo INNER JOIN
                      dbo.LZ_VENTAS_rgko ON dbo.LZ_VENTAS_rgpo.join_feld = dbo.LZ_VENTAS_rgko.seriell AND dbo.LZ_VENTAS_rgpo.[database] = dbo.LZ_VENTAS_rgko.[database] ON 
                      dbo.LZ_VENTAS_apos.seriell = dbo.LZ_VENTAS_rgpo.join_apos AND dbo.LZ_VENTAS_apos.[database] = dbo.LZ_VENTAS_rgpo.[database]
WHERE     (dbo.LZ_VENTAS_rgko.satzart = N'RECH' and dbo.LZ_VENTAS_rgko.join_storno is null)
--and dbo.LZ_VENTAS_akpos.nr_kontrakt = 202252

GROUP BY	dbo.LZ_VENTAS_akpos.nr_kontrakt, 
			dbo.LZ_VENTAS_akpos.nr_position, 
			dbo.LZ_VENTAS_akpos.preis_ges_wr, 
			dbo.LZ_VENTAS_akpos.preis_ges_dm, 
            dbo.LZ_VENTAS_akontr.nr_waehrung, 
            dbo.LZ_VENTAS_rgko.kurs





GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Trade_Value]'
GO
ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Trade_Value] AS

SELECT 
	
a.nr_Auftrag,
a.nr_position,	
a.belegdatum,
a.liefertermin,

-- if abgrechnet_dat is null then order intake value else invoice values
case when a.abgerechnet_dat is null then a.preis_ges_wr else b.preis_ges_wr end as preis_ges_wr,
case when a.abgerechnet_dat is null then a.preis_ges_dm else b.preis_ges_dm end as preis_ges_dm,

a.kurs
FROM

-- getting order complete date
(
	SELECT     
		dbo.LZ_VENTAS_vkopf.nr_auftrag, 
		dbo.LZ_VENTAS_vpos.nr_position, 
		dbo.LZ_VENTAS_vpos.liefertermin,
		dbo.LZ_VENTAS_rgko.belegdatum,
		dbo.LZ_VENTAS_rgko.kurs,
		dbo.LZ_VENTAS_vpos.preis_ges_wr,
		dbo.LZ_VENTAS_vpos.preis_ges_dm,
		dbo.LZ_VENTAS_ksttr.abgerechnet_dat
		
	FROM         
		dbo.LZ_VENTAS_vkopf 
		INNER JOIN dbo.LZ_VENTAS_vpos 
			ON dbo.LZ_VENTAS_vkopf.nr_auftrag = dbo.LZ_VENTAS_vpos.nr_auftrag AND 
						  dbo.LZ_VENTAS_vkopf.[database] = dbo.LZ_VENTAS_vpos.[database] INNER JOIN
						  dbo.LZ_VENTAS_rgpo ON dbo.LZ_VENTAS_vpos.[database] = dbo.LZ_VENTAS_rgpo.[database] AND 
						  dbo.LZ_VENTAS_vpos.seriell = dbo.LZ_VENTAS_rgpo.join_vpos INNER JOIN
						  dbo.LZ_VENTAS_rgko ON dbo.LZ_VENTAS_rgpo.join_feld = dbo.LZ_VENTAS_rgko.seriell AND 
						  dbo.LZ_VENTAS_rgpo.[database] = dbo.LZ_VENTAS_rgko.[database]
		INNER JOIN dbo.LZ_VENTAS_ksttr on dbo.LZ_VENTAS_vkopf.nr_auftrag = dbo.LZ_VENTAS_ksttr.join_table and  dbo.LZ_VENTAS_vkopf.[database] =dbo.LZ_VENTAS_ksttr.[database]
	WHERE     (YEAR(dbo.LZ_VENTAS_rgko.belegdatum) >= 2008) AND (dbo.LZ_VENTAS_rgko.satzart = N'RECH') AND (dbo.LZ_VENTAS_rgko.join_storno IS NULL)

	
) a

JOIN
-- getting invoice values for order completes

(
	SELECT     

		dbo.LZ_VENTAS_vkopf.nr_auftrag, 
		dbo.LZ_VENTAS_vpos.nr_position, 
		sum(case when dbo.LZ_VENTAS_rgpo.belart = 18 then -1 else 1 end * dbo.LZ_VENTAS_rgpo.preis_ges_wr) as preis_ges_wr, 
		sum(case when dbo.LZ_VENTAS_rgpo.belart = 18 then -1 else 1 end * dbo.LZ_VENTAS_rgpo.preis_ges_dm) as preis_ges_dm
	FROM         
		dbo.LZ_VENTAS_vkopf 
		INNER JOIN dbo.LZ_VENTAS_vpos 
			ON dbo.LZ_VENTAS_vkopf.nr_auftrag = dbo.LZ_VENTAS_vpos.nr_auftrag AND 
						  dbo.LZ_VENTAS_vkopf.[database] = dbo.LZ_VENTAS_vpos.[database] INNER JOIN
						  dbo.LZ_VENTAS_rgpo ON dbo.LZ_VENTAS_vpos.[database] = dbo.LZ_VENTAS_rgpo.[database] AND 
						  dbo.LZ_VENTAS_vpos.seriell = dbo.LZ_VENTAS_rgpo.join_vpos INNER JOIN
						  dbo.LZ_VENTAS_rgko ON dbo.LZ_VENTAS_rgpo.join_feld = dbo.LZ_VENTAS_rgko.seriell AND 
						  dbo.LZ_VENTAS_rgpo.[database] = dbo.LZ_VENTAS_rgko.[database]
WHERE dbo.LZ_VENTAS_rgko.satzart <> N'RECT'
	GROUP BY
		dbo.LZ_VENTAS_vkopf.nr_auftrag, 
		dbo.LZ_VENTAS_vpos.nr_position


) b on a.nr_auftrag = b.nr_auftrag and a.nr_position = b.nr_position
 
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Comm_DB2pos]'
GO

ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Comm_DB2pos] AS
SELECT		a.nr_kontrakt, 
			a.nr_position, 
			SUM(c.b_betrag) * CASE WHEN b.preis_ges_dm_ges = 0 
									THEN a.preis_ges_dm / (anz_pos * 1.0) 
									ELSE a.preis_ges_dm / b.preis_ges_dm_ges * 100 
							  END / 100 AS DB2,
			a.belegdatum, 
            c.nr_konto
FROM         dbo.vTMP_VENTAS_OrderComplete_Comm_Value AS a INNER JOIN
                          (SELECT		nr_kontrakt, 
										SUM(preis_ges_dm) AS preis_ges_dm_ges, 
										COUNT(*) AS anz_pos
                            FROM          dbo.vTMP_VENTAS_OrderComplete_Comm_Value
                            GROUP BY nr_kontrakt) AS b 
                            ON a.nr_kontrakt = b.nr_kontrakt INNER JOIN
							dbo.vTMP_VENTAS_OrderComplete_Comm_DB2 AS c 
							ON c.nr_kontrakt = a.nr_kontrakt
GROUP BY a.nr_kontrakt, a.nr_position, b.preis_ges_dm_ges, a.preis_ges_dm, b.anz_pos, a.belegdatum, c.nr_konto

UNION ALL

-- DB2 from Order Intake for Order with "abgerechnet_dat" = null
SELECT 
	a.nr_kontrakt,
	a.nr_position,
	b.db2,
	-- removed after meeting with project team 11.10.2013 15:07
	--b.db2wrg / a.kurs as db2,
	a.belegdatum,
	'' as konto 
FROM 
	vTMP_VENTAS_OrderComplete_Comm_Value a
		join vTMP_VENTAS_OrderIntake_Comm_03_DB2pos b 
			on a.nr_kontrakt = b.nr_kontrakt and a.nr_position = b.nr_position
where abgerechnet_dat is null






GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderComplete]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderComplete] DROP
COLUMN [PreCal_Value],
COLUMN [PreCal_Value_Currency],
COLUMN [PostCal_Value],
COLUMN [PostCal_Value_Currency],
COLUMN [Calculation_Status]
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vTMP_VENTAS_OrderComplete_Trade_DB2pos]'
GO


ALTER VIEW [dbo].[vTMP_VENTAS_OrderComplete_Trade_DB2pos] AS
SELECT  a.nr_auftrag, 
		a.nr_position, 
		SUM(c.b_betrag) * CASE WHEN b.preis_ges_dm_ges = 0 
								THEN a.preis_ges_dm / (anz_pos * 1.0) 
								ELSE a.preis_ges_dm / b.preis_ges_dm_ges * 100 
						  END / 100 AS DB2, c.nr_konto1
FROM         dbo.vTMP_VENTAS_OrderComplete_Trade_Value AS a INNER JOIN
                          (SELECT     nr_auftrag, SUM(preis_ges_dm) AS preis_ges_dm_ges, COUNT(*) AS anz_pos
                            FROM          dbo.vTMP_VENTAS_OrderComplete_Trade_Value
                            GROUP BY nr_auftrag) AS b ON a.nr_auftrag = b.nr_auftrag INNER JOIN
                      dbo.vTMP_VENTAS_OrderComplete_Trade_DB2 AS c ON c.nr_auftrag = a.nr_auftrag
GROUP BY a.nr_auftrag, a.nr_position, b.preis_ges_dm_ges, a.preis_ges_dm, b.anz_pos, c.nr_konto1

UNION ALL
-- DB2 from Order Intake for Order with "abgerechnet_dat" = null
SELECT 

b.nr_Auftrag,
b.nr_position_vpos,
b.db2,
-- removed after meeting with project team 11.10.2013 15:07
--b.db2wrg / c.kurs as db2, -- Order Intake DB2 with exchange rate from invoice

'' as konto


FROM 
TMP_VENTAS_OrderIntake_Trade_03_DB2pos b 
inner join
	TMP_VENTAS_OrderComplete_Trade_Value c  on
	b.nr_auftrag = c.nr_Auftrag and b.nr_position_vpos = c.nr_position
	and b.abgerechnet_dat is null


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderComplete_DB2]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderComplete_DB2] DROP
COLUMN [PreCal_Value_DB2],
COLUMN [PreCal_Value_DB3],
COLUMN [PostCal_Value_DB2],
COLUMN [PostCal_Value_DB3],
COLUMN [Calculation_Status]
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
