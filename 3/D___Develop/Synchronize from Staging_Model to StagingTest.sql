/*
Run this script on:

        HCMNTB0021.StagingTest    -  This database will be modified

to synchronize it with:

        HCMNTB0021.Staging_Model

You are recommended to back up your database before running this script

Script created by SQL Compare version 11.5.2 from Red Gate Software Ltd at 6/9/2016 10:32:17 AM

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
PRINT N'Altering [dbo].[vTMP_LOD_OrderIntake]'
GO
ALTER VIEW [dbo].[vTMP_LOD_OrderIntake]
AS
     SELECT o.Industry,
            o.Merchandise,
            o.EstDeliveryDate,
            o.Currency,
            o.OrderIntakeDate,
            o.GoodDescription,
            o.OrderVal_EUR,
            o.DB2Val_EUR,
            o.OrderVal,
            o.DB2Val,
            o.LocalRef,
            c.CustomerID,
            s.SupplierID,
            o.GroupNo AS OrderNo_New,
            CAST('LOD' AS NVARCHAR(5)) AS source,
            tb.bu_id,
            CASE
                WHEN vl.source = 'HKG'
                THEN 'J'
                ELSE CASE
                         WHEN bs.ShippedDate IS NOT NULL
                         THEN 'N'
                         ELSE 'J'
                     END
            END AS backlogrelevant,
            '1' AS OrderPos,
            bs.ShippedDate,
            LEFT(o.BusinessType, 1) AS OrderType,
            CAST(pc.code AS NVARCHAR(3)) AS ProcurementCenter,
            ors.LabourDB3,
            ors.LabourDB3Post,
            o.OrderVal_EUR AS Precal_IntakeValue,
            o.DB2Val_EUR AS Precal_IntakeDB2,
            o.OrderVal AS Precal_IntakeValue_Currency,
            o.DB2Val AS Precal_IntakeDB2_Currency,
            ors.LabourDB3 AS Precal_IntakeDB3,
            CASE
                WHEN bs.ShippedDate IS NOT NULL
                     AND bs.FinalizedDate IS NOT NULL
                     AND YEAR(o.OrderIntakeDate) < 2013
                THEN ISNULL(bs.OrderVal_EUR, 0)
                WHEN ss.active = 0
                     AND YEAR(o.OrderIntakeDate) >= 2013
                     AND o.OrderIntakeDate >= '2008-01-01'
                THEN ISNULL(sc.OrderCompleteValue, 0)
                ELSE 0
            END AS Postcal_IntakeValue,
            CASE
                WHEN bs.ShippedDate IS NOT NULL
                     AND bs.FinalizedDate IS NOT NULL
                     AND YEAR(o.OrderIntakeDate) < 2013
                THEN ISNULL(bs.OrderVal, 0)
                WHEN ss.active = 0
                     AND YEAR(o.OrderIntakeDate) >= 2013
                     AND o.OrderIntakeDate >= '2008-01-01'
                THEN ISNULL(o.OrderVal, 0)
                ELSE 0
            END AS Postcal_IntakeValue_Currency,
            CASE
                WHEN bs.ShippedDate IS NOT NULL
                     AND bs.FinalizedDate IS NOT NULL
                     AND YEAR(o.OrderIntakeDate) < 2013
                THEN ISNULL(bs.DB2Amt_EUR, 0)
                WHEN ss.active = 0
                     AND YEAR(o.OrderIntakeDate) >= 2013
                     AND o.OrderIntakeDate >= '2008-01-01'
                THEN ISNULL(sd.OrderCompleteDB2, 0)
                ELSE 0
            END AS Postcal_IntakeDB2,
            CASE
                WHEN bs.ShippedDate IS NOT NULL
                     AND bs.FinalizedDate IS NOT NULL
                     AND YEAR(o.OrderIntakeDate) < 2013
                THEN ISNULL(bs.DB2Amt, 0)
                WHEN ss.active = 0
                     AND YEAR(o.OrderIntakeDate) >= 2013
                     AND o.OrderIntakeDate >= '2008-01-01'
                THEN 0
                ELSE 0
            END AS Postcal_IntakeDB2_currency,
            CASE
                WHEN bs.ShippedDate IS NOT NULL
                     AND bs.FinalizedDate IS NOT NULL
                     AND YEAR(o.OrderIntakeDate) < 2013
                THEN ISNULL(ors.LabourDB3Post, 0)
                WHEN ss.active = 0
                     AND YEAR(o.OrderIntakeDate) >= 2013
                     AND o.OrderIntakeDate >= '2008-01-01'
                THEN 0
                ELSE 0
            END AS Postcal_IntakeDB3,
            CASE
                WHEN bs.ShippedDate IS NOT NULL
                     AND bs.FinalizedDate IS NOT NULL
                     AND YEAR(o.OrderIntakeDate) < 2013
                THEN 1
                WHEN ss.active = 0
                     AND YEAR(o.OrderIntakeDate) >= 2013
                     AND o.OrderIntakeDate >= '2008-01-01'
                THEN 1
                ELSE 0
            END AS Calculation_Status
     FROM LZ_LOD_OrderReg o
          LEFT JOIN LZ_LOD_Customer c ON o.Customer = c.CustomerName
          LEFT JOIN LZ_LOD_Supplier s ON o.Supplier = s.SupplierName
          JOIN tmp_bu tb ON o.BusinessUnit = tb.bu_desc
          JOIN
     (
         SELECT OrderNo,
                'HKG' AS source
         FROM dbo.vLOD_HKGOrderNo
         UNION ALL
         SELECT OrderNo,
                'HKG'
         FROM dbo.vLOD_FOXPROOrderNo
         UNION ALL
         SELECT OrderNo,
                'nonHKG'
         FROM dbo.vLOD_NonHKGOrderNo
     ) vl ON o.GroupNo = vl.OrderNo
          LEFT JOIN LZ_LOD_OrderBillingShipping bs ON o.OrderNo = bs.OrderNo
          LEFT JOIN ADM_ProcurementCenter pc ON pc.description = o.ProcCenter
          LEFT JOIN LZ_LOD_OrderRegService ors ON o.OrderNo = ors.OrderNo
                                                  AND o.Merchandise = 'S'
          LEFT JOIN dbo.vTMP_Solomon_03_OrderComplete_Date_BusinessType_new sb ON o.GroupNo = sb.ord_no
          LEFT JOIN dbo.vTMP_Solomon_02_OrderComplete_value_new sc ON o.GroupNo = sc.ord_no
          LEFT JOIN
     (
         SELECT [ord_no],
                SUM([OrderCompleteDB2]) AS [OrderCompleteDB2]
         FROM [dbo].[vTMP_Solomon_02_OrderComplete_DB2_New]
         GROUP BY [ord_no]
     ) AS sd ON o.GroupNo = sd.ord_no
          LEFT JOIN dbo.TMP_Solomon_SubAcct ss ON o.GroupNo = ss.orderno
     WHERE ISNULL(ors.Chareable, 1) <> 0; -- filter out non-chargeable LOD service orders 






GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderIntake]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderIntake] ADD
[Precal_IntakeValue] [money] NULL,
[Precal_IntakeValue_Currency] [money] NULL,
[Postcal_IntakeValue] [money] NULL,
[Postcal_IntakeValue_Currency] [money] NULL,
[Precal_IntakeDB2] [money] NULL,
[Precal_IntakeDB2_Currency] [money] NULL,
[Postcal_IntakeDB2] [money] NULL,
[Postcal_IntakeDB2_currency] [money] NULL,
[Precal_IntakeDB3] [money] NULL,
[Postcal_IntakeDB3] [money] NULL,
[Calculation_Status] [bit] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[TMP_VENTAS_OrderComplete_Trade_Value]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[TMP_VENTAS_OrderComplete_Trade_Value] DROP
COLUMN [PreCal_Value_Currency],
COLUMN [PreCal_Value],
COLUMN [PostCal_Value_Currency],
COLUMN [PostCal_Value],
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
