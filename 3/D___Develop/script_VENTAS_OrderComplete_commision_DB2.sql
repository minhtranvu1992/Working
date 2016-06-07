SELECT CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730'
           THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.DB2
       END AS DB2,
	  CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730' and dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status]=0
           THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB2
       END AS PreCal_Value_DB2,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PreCal_Value_DB3,
	  CASE
           WHEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto = '3730' and dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status]=1
           THEN dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB2 / 2
           ELSE dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB2
       END AS PostCal_Value_DB2,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.PostCal_Value_DB3,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.[Calculation_Status],
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.belegdatum,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_konto,
       dbo.FAKT_OrderIntake.bu_id,
       dbo.FAKT_OrderIntake.industry,
       dbo.FAKT_OrderIntake.merchandise,
       dbo.FAKT_OrderIntake.orderdate,
       dbo.FAKT_OrderIntake.estdeliverydate,
       dbo.FAKT_OrderIntake.deliverydate,
       dbo.FAKT_OrderIntake.customer,
       dbo.FAKT_OrderIntake.supplier,
       dbo.FAKT_OrderIntake.currency,
       dbo.FAKT_OrderIntake.country,
       dbo.FAKT_OrderIntake.ordertype,
       dbo.FAKT_OrderIntake.source,
       dbo.FAKT_OrderIntake.department,
       dbo.FAKT_OrderIntake.descriptionofgoods,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt,
       dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position
FROM dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos
     INNER JOIN dbo.FAKT_OrderIntake ON dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_kontrakt = dbo.FAKT_OrderIntake.orderno
                                        AND dbo.vTMP_VENTAS_OrderComplete_Comm_DB2pos.nr_position = dbo.FAKT_OrderIntake.orderpos;