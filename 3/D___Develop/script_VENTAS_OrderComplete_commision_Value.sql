SELECT dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_position,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_kontrakt,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.belegdatum,
       dbo.FAKT_OrderIntake.bu_id,
       dbo.FAKT_OrderIntake.industry,
       dbo.FAKT_OrderIntake.merchandise,
       dbo.FAKT_OrderIntake.orderdate,
       dbo.FAKT_OrderIntake.estdeliverydate,
       dbo.FAKT_OrderIntake.customer,
       dbo.FAKT_OrderIntake.supplier,
       dbo.FAKT_OrderIntake.currency,
       dbo.FAKT_OrderIntake.country,
       dbo.FAKT_OrderIntake.ordertype,
       dbo.FAKT_OrderIntake.source,
       dbo.FAKT_OrderIntake.department,
       dbo.FAKT_OrderIntake.descriptionofgoods,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.preis_ges_wr,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.preis_ges_dm,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PreCal_Value_Currency AS PreCal_Value_Currency,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PreCal_Value AS PreCal_Value,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PostCal_Value_Currency AS PostCal_Value_Currency,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_Value.PostCal_Value AS PostCal_Value,
	  dbo.vTMP_VENTAS_OrderComplete_Comm_Value.[Calculation_Status],
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_waehrung,
       dbo.vTMP_VENTAS_OrderComplete_Comm_Value.belegdatum AS deliverydate
FROM dbo.vTMP_VENTAS_OrderComplete_Comm_Value
     INNER JOIN dbo.FAKT_OrderIntake ON dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_position = dbo.FAKT_OrderIntake.orderpos
                                        AND dbo.vTMP_VENTAS_OrderComplete_Comm_Value.nr_kontrakt = dbo.FAKT_OrderIntake.orderno
WHERE(dbo.FAKT_OrderIntake.source = N'HBG')
     AND (dbo.FAKT_OrderIntake.ordertype = N'C');