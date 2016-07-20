/*
Run this script on:

        10.97.1.48.Staging    -  This database will be modified

to synchronize it with:

        10.124.101.6.Staging

You are recommended to back up your database before running this script

Script created by SQL Compare version 11.5.2 from Red Gate Software Ltd at 7/18/2016 9:40:55 AM

*/
-- Backs up the target database using native SQL Server backup
BACKUP DATABASE [Staging] TO DISK='D:\Minh TV\DB\Staging.2016-07-18 16 40 55Z.bak'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
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
PRINT N'Dropping extended properties'
GO
EXEC sp_dropextendedproperty N'MS_DiagramPane1', 'SCHEMA', N'dbo', 'VIEW', N'vFAKT_OrderBacklog_Actual', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_dropextendedproperty N'MS_DiagramPaneCount', 'SCHEMA', N'dbo', 'VIEW', N'vFAKT_OrderBacklog_Actual', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_dropextendedproperty N'MS_DiagramPane1', 'SCHEMA', N'dbo', 'VIEW', N'vFAKT_OrderBacklog_StockValue', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_dropextendedproperty N'MS_DiagramPaneCount', 'SCHEMA', N'dbo', 'VIEW', N'vFAKT_OrderBacklog_StockValue', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderIntake]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderIntake] ADD
[post_orderintake_value_currency] [money] NULL,
[pre_orderintake_db2_currency] [money] NULL,
[post_orderintake_db2_currency] [money] NULL,
[pre_orderintake_db3] [money] NULL,
[post_orderintake_db3] [money] NULL,
[CalculationStatus] [varchar] (1) COLLATE Latin1_General_CI_AS NULL,
[Chargeable] [tinyint] NULL,
[ServiceType] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[JRMachinery] [tinyint] NULL,
[Pre_OrderRevenue] [float] NULL,
[Post_OrderRevenue] [float] NULL,
[Pre_OrderRevenue_Currency] [float] NULL,
[Post_OrderRevenue_Currency] [float] NULL,
[Pre_OrderManDays] [float] NULL,
[Post_OrderManDays] [float] NULL,
[Pre_OrderManHours] [float] NULL,
[Post_OrderManHours] [float] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderIntake].[orderintake_value]', N'pre_orderintake_value', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderIntake].[orderintake_db2]', N'post_orderintake_value', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderIntake].[orderintake_db3]', N'pre_orderintake_db2', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderIntake].[orderintake_db2_currency]', N'post_orderintake_db2', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderIntake].[orderintake_value_currency]', N'pre_orderintake_value_currency', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderComplete]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderComplete] ADD
[post_ordercomplete_value_currency] [money] NULL,
[pre_ordercomplete_db2_currency] [money] NULL,
[post_ordercomplete_db2_currency] [money] NULL,
[pre_ordercomplete_db3] [money] NULL,
[post_ordercomplete_db3] [money] NULL,
[CalculationStatus] [varchar] (1) COLLATE Latin1_General_CI_AS NULL,
[Chargeable] [tinyint] NULL,
[ServiceType] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[JRMachinery] [tinyint] NULL,
[Pre_OrderRevenue] [float] NULL,
[Post_OrderRevenue] [float] NULL,
[Pre_OrderRevenue_Currency] [float] NULL,
[Post_OrderRevenue_Currency] [float] NULL,
[Pre_OrderManDays] [float] NULL,
[Post_OrderManDays] [float] NULL,
[Pre_OrderManHours] [float] NULL,
[Post_OrderManHours] [float] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete].[ordercomplete_value]', N'pre_ordercomplete_value', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete].[ordercomplete_db2]', N'post_ordercomplete_value', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete].[ordercomplete_value_currency]', N'pre_ordercomplete_db2', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete].[ordercomplete_db2_currency]', N'post_ordercomplete_db2', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete].[ordercomplete_db3]', N'pre_ordercomplete_value_currency', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vFAKT_OrderBacklog_StockValue]'
GO


--DROP VIEW [dbo].[vFAKT_ServOrderBacklog_StockValue]

ALTER VIEW [dbo].[vFAKT_OrderBacklog_StockValue] AS  
SELECT       
 m.jahrmonat,   
 b.invoicedate,   
 a.orderno,   
 a.orderpos,   
 a.bu_id,   
 a.industry,   
 a.merchandise,   
 a.orderdate,   
 a.estdeliverydate,   
 a.deliverydate,   
 a.customer,   
 a.supplier,   
 a.currency,   
 a.country,   
 a.ordertype,   
 a.source,   
 a.department,   
 a.descriptionofgoods,   
 a.pre_orderintake_value, 
 a.post_orderintake_value,  
 a.pre_orderintake_db2,
 a.post_orderintake_db2,   
 a.pre_orderintake_value_currency,   
 a.post_orderintake_value_currency,
 a.pre_orderintake_db2_currency,
 a.post_orderintake_db2_currency,   
 a.Backlogrelevant  ,
 a.procurementCenter
	, a.pre_orderintake_db3
	, a.post_orderintake_db3
	, a.[Chargeable] 
	, a.[ServiceType]
	, a.[JRMachinery]
	, a.CalculationStatus
	, a.Pre_OrderRevenue
	, a.Post_OrderRevenue
	, a.Pre_OrderRevenue_Currency
	, a.Post_OrderRevenue_Currency
	, a.Pre_OrderManHours
	, a.Post_OrderManHours
	, a.Pre_OrderManDays
	, a.Post_OrderManDays
	
FROM   dbo.FAKT_OrderIntake AS a 
	LEFT OUTER JOIN  dbo.FAKT_OrderComplete AS b ON a.orderno = b.orderno AND a.orderpos = b.orderpos   
	INNER JOIN dbo.TMP_Months AS m ON   m.jahrmonat   
		BETWEEN CONVERT(char(6), a.orderdate, 112) AND 
			CASE WHEN b.invoicedate IS NULL AND a.backlogrelevant = 'J' 
					THEN CONVERT(char(6), GETDATE(), 112) 
                 ELSE CONVERT(char(6), dateadd(m,-1, b.invoicedate), 112) END  
  

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[vFAKT_OrderBacklog_Actual]'
GO


ALTER VIEW [dbo].[vFAKT_OrderBacklog_Actual]  
AS  
SELECT     oi.orderno, oi.orderpos, oi.bu_id, oi.industry, oi.merchandise, oi.orderdate, oi.estdeliverydate, oi.deliverydate, oi.customer, oi.supplier, oi.currency, oi.country,   
                      oi.ordertype, oi.source, oi.department, oi.descriptionofgoods
                      , oi.pre_orderintake_value
                      , oi.pre_orderintake_db2
                      , oi.pre_orderintake_value_currency
                      , oi.pre_orderintake_db2_currency,   
                      oi.Backlogrelevant , oi.ProcurementCenter
	, oi.pre_orderintake_db3
	, oi.[Chargeable] 
	, oi.[ServiceType]
	, oi.[JRMachinery]
	, oi.Pre_OrderRevenue
	, oi.Pre_OrderRevenue_Currency
	, oi.Pre_OrderManHours
	, oi.Pre_OrderManDays
FROM         dbo.FAKT_OrderIntake AS oi LEFT OUTER JOIN  
                          (	SELECT DISTINCT orderno, orderpos  
                            FROM          dbo.FAKT_OrderComplete) AS oc ON oi.orderno = oc.orderno AND oi.orderpos = oc.orderpos  
WHERE     (oc.orderpos IS NULL) AND (oi.Backlogrelevant = 'J')


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Data Reader Order Backlog Actual Regular Order]'
GO
Create Procedure [dbo].[Data Reader Order Backlog Actual Regular Order]
AS
/*Data Reader Order Backlog Actual */
SELECT CONVERT( CHAR(8), dbo.vFAKT_OrderBacklog_Actual.estdeliverydate, 112),--day
       dbo.vFAKT_OrderBacklog_Actual.orderno,--order number
       dbo.vFAKT_OrderBacklog_Actual.supplier,--supplier
       dbo.vFAKT_OrderBacklog_Actual.merchandise,--merchandise
       dbo.vFAKT_OrderBacklog_Actual.descriptionofgoods,--Description of Goods
       dbo.vFAKT_OrderBacklog_Actual.source,--Datasource
       RTRIM(orderno)++'-'+RIGHT('0'+CONVERT(   VARCHAR(2), orderpos), 2),--Order Number Pos.
       CONVERT( CHAR(4), dbo.vFAKT_OrderBacklog_Actual.estdeliverydate, 112),--Year
       dbo.vFAKT_OrderBacklog_Actual.industry,--industry
       dbo.vFAKT_OrderBacklog_Actual.ordertype,--business
       CONVERT( DATE, estdeliverydate),--Est.delivery
       dbo.vFAKT_OrderBacklog_Actual.ProcurementCenter, --Procurement Center
       dbo.vFAKT_OrderBacklog_Actual.pre_orderintake_db2,--cube Pre Expected Shipments DB2
       dbo.vFAKT_OrderBacklog_Actual.pre_orderintake_value,--cube Pre Expected Shipments Value
       dbo.vFAKT_OrderBacklog_Actual.pre_orderintake_value,--cube  Pre Expected Shipments Value YEAR
       dbo.vFAKT_OrderBacklog_Actual.pre_orderintake_db2,--cube Pre Expected Shipments DB2 year
       dbo.vFAKT_OrderBacklog_Actual.pre_orderintake_db3,-- cube Pre Expected Shipments DB3
       dbo.vFAKT_OrderBacklog_Actual.pre_orderintake_db3--cube Pre Expected Shipments DB3 Year
FROM dbo.vFAKT_OrderBacklog_Actual;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Data Reader Order Backlog Stock Regular Order]'
GO
CREATE Procedure [dbo].[Data Reader Order Backlog Stock Regular Order]
AS
/*Data Reader Order Backlog Stock Regular Order*/

SELECT LEFT(dbo.vFAKT_OrderBacklog_StockValue.jahrmonat, 6), --Month
       dbo.vFAKT_OrderBacklog_StockValue.orderno, -- Order Number
       dbo.vFAKT_OrderBacklog_StockValue.supplier, -- Supplier 
       dbo.vFAKT_OrderBacklog_StockValue.merchandise, --Merchandise
       dbo.vFAKT_OrderBacklog_StockValue.descriptionofgoods, --Description of Goods
       dbo.vFAKT_OrderBacklog_StockValue.source, --Data source
       RTRIM(orderno)++'-'+RIGHT('0'+CONVERT(   VARCHAR(2), orderpos), 2), -- Order Number Pos.
       LEFT(dbo.vFAKT_OrderBacklog_StockValue.jahrmonat, 4), --year
       dbo.vFAKT_OrderBacklog_StockValue.industry, --Industry
       dbo.vFAKT_OrderBacklog_StockValue.ordertype, --Business Type
       CONVERT( DATE, estdeliverydate), --Est. delivery
       dbo.vFAKT_OrderBacklog_StockValue.procurementCenter, --Procurement Center
       dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus, --Calculation Status
       dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_value, --Cube Pre Order Backlog Value
       dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db2, --Cube Pre Order Backlog DB2
       CASE
           WHEN RIGHT(jahrmonat, 2) = '12'
           THEN dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_value
           ELSE 0
       END, --cube Pre Order Backlog value year
       dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db3, --cube Pre Order Backlog DB3
       CASE
           WHEN RIGHT(jahrmonat, 2) = '12'
           THEN dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db3
           ELSE 0
       END, --cube Pre Order Backlog Db3 Year
       CASE
           WHEN RIGHT(jahrmonat, 2) = '12'
           THEN dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db2
           ELSE 0
       END, --cube Pre Order Backlog DB2 Year
       CASE
           WHEN dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus = 1
           THEN dbo.vFAKT_OrderBacklog_StockValue.post_orderintake_value
           ELSE dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_value
       END AS [cube Order Backlog Value v2], --cube Order Backlog Value v2
       CASE
           WHEN dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus = 1
           THEN dbo.vFAKT_OrderBacklog_StockValue.post_orderintake_db2
           ELSE dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db2
       END AS [cube Order Backlog DB2 v2], --cube Order Backlog DB2 v2
       CASE
           WHEN RIGHT(jahrmonat, 2) = '12'
           THEN CASE
                    WHEN dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus = 1
                    THEN dbo.vFAKT_OrderBacklog_StockValue.post_orderintake_value
                    ELSE dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_value
                END
           ELSE 0
       END AS [cube Order Backlog Value Year v2], --cube Order Backlog Value Year v2
       CASE
           WHEN RIGHT(jahrmonat, 2) = '12'
           THEN CASE
                    WHEN dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus = 1
                    THEN dbo.vFAKT_OrderBacklog_StockValue.post_orderintake_db2
                    ELSE dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db2
                END
           ELSE 0
       END AS [cube Order backlog Db2 Year v2], --cube Order backlog Db2 Year v2
       CASE
           WHEN dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus = 1
           THEN dbo.vFAKT_OrderBacklog_StockValue.post_orderintake_db3
           ELSE dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db3
       END, --cube Order Backlog Db3 v2
       CASE
           WHEN RIGHT(jahrmonat, 2) = '12'
           THEN CASE
                    WHEN dbo.vFAKT_OrderBacklog_StockValue.CalculationStatus = 1
                    THEN dbo.vFAKT_OrderBacklog_StockValue.post_orderintake_db3
                    ELSE dbo.vFAKT_OrderBacklog_StockValue.pre_orderintake_db3
                END
           ELSE 0
       END AS [cube Order backlog DB3 Year v2]--cube Order backlog DB3 Year v2
FROM dbo.vFAKT_OrderBacklog_StockValue
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Data Reader Order Complete Value Regular Order]'
GO

Create Procedure [dbo].[Data Reader Order Complete Value Regular Order]
AS
/*Data Reader Order Complete Value Regular Order*/
SELECT CONVERT( VARCHAR(8), dbo.FAKT_OrderComplete.invoicedate, 112),--day
       dbo.FAKT_OrderComplete.orderno,--order number 
       dbo.FAKT_OrderComplete.supplier,--Supplier
       dbo.FAKT_OrderComplete.merchandise,--Merchandise 
       dbo.FAKT_OrderComplete.descriptionofgoods,-- Description of Good 
       dbo.FAKT_OrderComplete.source,--Data source
       RTRIM(orderno)++'-'+RIGHT('0'+CONVERT(   VARCHAR(2), orderpos), 2),--order number pos.
       dbo.FAKT_OrderComplete.ordertype,--business type 
       CONVERT( CHAR(10), dbo.FAKT_OrderComplete.invoicedate),--Order completed date
       dbo.FAKT_OrderComplete.currency,-- Currency
       dbo.FAKT_OrderComplete.ProcurementCenter,--Procurement center
       dbo.FAKT_OrderComplete.CalculationStatus,--Calculation
       dbo.FAKT_OrderComplete.pre_ordercomplete_value,--cube Pre order Complete Value
       dbo.FAKT_OrderComplete.pre_ordercomplete_db3,-- cube Pre Order Complete Db3
       CASE
           WHEN dbo.FAKT_OrderComplete.CalculationStatus = 1
           THEN dbo.FAKT_OrderComplete.post_ordercomplete_value
           ELSE dbo.FAKT_OrderComplete.pre_ordercomplete_value
       END,--cube Order Complete value v2
       CASE
           WHEN dbo.FAKT_OrderComplete.CalculationStatus = 1
           THEN dbo.FAKT_OrderComplete.post_ordercomplete_db3
           ELSE dbo.FAKT_OrderComplete.pre_ordercomplete_db3
       END--cube Order Complete DB3 v2
FROM dbo.FAKT_OrderComplete;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Altering [dbo].[FAKT_OrderComplete_DB2]'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
ALTER TABLE [dbo].[FAKT_OrderComplete_DB2] ADD
[pre_ordercomplete_value_currency] [money] NULL,
[post_ordercomplete_value_currency] [money] NULL,
[pre_ordercomplete_db2_currency] [money] NULL,
[post_ordercomplete_db2_currency] [money] NULL,
[CalculationStatus] [varchar] (1) COLLATE Latin1_General_CI_AS NULL,
[Chargeable] [tinyint] NULL,
[ServiceType] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[JRMachinery] [tinyint] NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete_DB2].[ordercomplete_value]', N'pre_ordercomplete_value', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete_DB2].[ordercomplete_db2]', N'post_ordercomplete_value', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete_DB2].[ordercomplete_value_currency]', N'pre_ordercomplete_db2', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_rename N'[dbo].[FAKT_OrderComplete_DB2].[ordercomplete_db2_currency]', N'post_ordercomplete_db2', N'COLUMN'
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Data Reader Order Complete DB2 Regular Order]'
GO
Create Procedure [dbo].[Data Reader Order Complete DB2 Regular Order]
AS
/*Data Reader Order Complete DB2 Regular Order*/
SELECT CONVERT( VARCHAR(8), dbo.FAKT_OrderComplete_DB2.invoicedate, 112),--day
       dbo.FAKT_OrderComplete_DB2.orderno,--Order Number
       dbo.FAKT_OrderComplete_DB2.supplier,--Supplier
       dbo.FAKT_OrderComplete_DB2.merchandise,--merchandise
       dbo.FAKT_OrderComplete_DB2.descriptionofgoods,--Description of goods
       dbo.FAKT_OrderComplete_DB2.source,--Data source
       dbo.FAKT_OrderComplete_DB2.account,--account
       RTRIM(orderno)++'-'+RIGHT('0'+CONVERT(   VARCHAR(2), orderpos), 2),--Order number pos.
       dbo.FAKT_OrderComplete_DB2.ordertype,--Business Type
       dbo.FAKT_OrderComplete_DB2.currency,--Currency
       dbo.FAKT_OrderComplete_DB2.ProcurementCenter,--Procurement Center
       dbo.FAKT_OrderComplete_DB2.CalculationStatus,--Calculation Status
       dbo.FAKT_OrderComplete_DB2.pre_ordercomplete_db2,--cube Pre Order Complete DB2
       CASE
           WHEN dbo.FAKT_OrderComplete_DB2.CalculationStatus = 1
           THEN dbo.FAKT_OrderComplete_DB2.post_ordercomplete_db2
           ELSE dbo.FAKT_OrderComplete_DB2.pre_ordercomplete_db2
       END--cube Order Complete Db2 v2
FROM dbo.FAKT_OrderComplete_DB2;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Hist_FAKT_OrderIntake_Hist]'
GO
CREATE TABLE [dbo].[Hist_FAKT_OrderIntake_Hist]
(
[orderno] [nvarchar] (11) COLLATE Latin1_General_CI_AS NULL,
[orderpos] [int] NOT NULL,
[bu_id] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[industry] [nvarchar] (4) COLLATE Latin1_General_CI_AS NULL,
[merchandise] [nvarchar] (1) COLLATE Latin1_General_CI_AS NULL,
[orderdate] [datetime2] NULL,
[estdeliverydate] [datetime2] NULL,
[deliverydate] [datetime2] NULL,
[customer] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[supplier] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[currency] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[country] [nvarchar] (2) COLLATE Latin1_General_CI_AS NULL,
[ordertype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[source] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[department] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[descriptionofgoods] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[orderintake_value] [money] NULL,
[orderintake_db2] [money] NULL,
[orderintake_value_currency] [money] NULL,
[orderintake_db2_currency] [money] NULL,
[Backlogrelevant] [varchar] (1) COLLATE Latin1_General_CI_AS NULL,
[office_reference] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL,
[ProcurementCenter] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[orderintake_db3] [money] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Hist_FAKT_OrderComplete_Hist]'
GO
CREATE TABLE [dbo].[Hist_FAKT_OrderComplete_Hist]
(
[orderno] [nvarchar] (11) COLLATE Latin1_General_CI_AS NULL,
[orderpos] [int] NULL,
[bu_id] [int] NULL,
[industry] [nvarchar] (4) COLLATE Latin1_General_CI_AS NULL,
[merchandise] [nvarchar] (1) COLLATE Latin1_General_CI_AS NULL,
[orderdate] [datetime2] NULL,
[estdeliverydate] [datetime2] NULL,
[deliverydate] [datetime2] NULL,
[invoicedate] [datetime2] NULL,
[customer] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[supplier] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[currency] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[country] [nvarchar] (2) COLLATE Latin1_General_CI_AS NULL,
[ordertype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[source] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[department] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[descriptionofgoods] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[ordercomplete_value] [money] NULL,
[ordercomplete_db2] [money] NULL,
[ordercomplete_value_currency] [money] NULL,
[ordercomplete_db2_currency] [money] NULL,
[ProcurementCenter] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL,
[ordercomplete_db3] [money] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Hist_vFAKT_OrderBacklog_Actual_Hist]'
GO


CREATE VIEW [dbo].[Hist_vFAKT_OrderBacklog_Actual_Hist]  
AS  
SELECT     oi.orderno, oi.orderpos, oi.bu_id, oi.industry, oi.merchandise, oi.orderdate, oi.estdeliverydate, oi.deliverydate, oi.customer, oi.supplier, oi.currency, oi.country,   
                      oi.ordertype, oi.source, oi.department, oi.descriptionofgoods, oi.orderintake_value, oi.orderintake_db2, oi.orderintake_value_currency, oi.orderintake_db2_currency,   
                      oi.Backlogrelevant , oi.ProcurementCenter, oi.orderintake_db3
FROM         dbo.Hist_FAKT_OrderIntake_Hist AS oi LEFT OUTER JOIN  
                          (SELECT DISTINCT orderno, orderpos  
                            FROM          dbo.Hist_FAKT_OrderComplete_Hist) AS oc ON oi.orderno = oc.orderno AND oi.orderpos = oc.orderpos  
WHERE     (oc.orderpos IS NULL) AND (oi.Backlogrelevant = 'J')  


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Data Reader Order Intake Regular Order]'
GO
Create Procedure [dbo].[Data Reader Order Intake Regular Order]
AS
/*Data Reader Order Intake Regular Order */
SELECT CONVERT( CHAR(8), [orderdate], 112),--day
       dbo.FAKT_OrderIntake.orderno,--Order Number 
       dbo.FAKT_OrderIntake.supplier,--Supplier
       dbo.FAKT_OrderIntake.merchandise,--Merchandise
       dbo.FAKT_OrderIntake.descriptionofgoods,--Description of Goods
       dbo.FAKT_OrderIntake.source,--Data Source
       dbo.FAKT_OrderIntake.customer,--Customer
       dbo.FAKT_OrderIntake.industry,--Industry
       dbo.FAKT_OrderIntake.country,--country
       dbo.FAKT_OrderIntake.ordertype,--business Type
       dbo.FAKT_OrderIntake.department,--department
       CAST(dbo.FAKT_OrderIntake.bu_id AS    VARCHAR),--Business Unit
       RTRIM(orderno)++'-'+RIGHT('0'+CONVERT(   VARCHAR(2), orderpos), 2),--Order Number Pos.
       dbo.FAKT_OrderIntake.office_reference,--Office Reference
       dbo.FAKT_OrderIntake.office_reference,--Office Reference
       CASE
           WHEN dbo.FAKT_OrderIntake.merchandise IN('M', 'P')
           THEN 'MP'
           ELSE merchandise
       END,--Merchandise Short 
       CONVERT( DATE, dbo.FAKT_OrderIntake.orderdate),--Order Intake date
       dbo.FAKT_OrderIntake.currency,--currency
       dbo.FAKT_OrderIntake.ProcurementCenter,--Procurement Center
       dbo.FAKT_OrderIntake.CalculationStatus,--Calculation Status
       dbo.FAKT_OrderIntake.pre_orderintake_value,--cube Pre Order Intake Value
       dbo.FAKT_OrderIntake.pre_orderintake_db2,--cube Pre Order Intake DB2
       dbo.FAKT_OrderIntake.pre_orderintake_db3,--cube Pre Order Intake DB3
       CASE
           WHEN dbo.FAKT_OrderIntake.CalculationStatus = 1
           THEN dbo.FAKT_OrderIntake.post_orderintake_value
           ELSE dbo.FAKT_OrderIntake.pre_orderintake_value
       END,--cube Order Intake Value v2
       CASE
           WHEN dbo.FAKT_OrderIntake.CalculationStatus = 1
           THEN dbo.FAKT_OrderIntake.post_orderintake_db2
           ELSE dbo.FAKT_OrderIntake.pre_orderintake_db2
       END,--cube Order Intake DB2 v2
       CASE
           WHEN dbo.FAKT_OrderIntake.CalculationStatus = 1
           THEN dbo.FAKT_OrderIntake.post_orderintake_db3
           ELSE dbo.FAKT_OrderIntake.pre_orderintake_db3
       END--cube Order Intake Db3 v2
FROM dbo.FAKT_OrderIntake;
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Hist_vFAKT_OrderBacklog_StockValue_Hist]'
GO


CREATE VIEW [dbo].[Hist_vFAKT_OrderBacklog_StockValue_Hist] AS  
SELECT       
 m.jahrmonat,   
 b.invoicedate,   
 a.orderno,   
 a.orderpos,   
 a.bu_id,   
 a.industry,   
 a.merchandise,   
 a.orderdate,   
 a.estdeliverydate,   
 a.deliverydate,   
 a.customer,   
 a.supplier,   
 a.currency,   
 a.country,   
 a.ordertype,   
 a.source,   
 a.department,   
 a.descriptionofgoods,   
 a.orderintake_value,   
 a.orderintake_db2,   
 a.orderintake_value_currency,   
 a.orderintake_db2_currency,   
 a.Backlogrelevant  ,
 a.procurementCenter,
 a.orderintake_db3
FROM   
 dbo.Hist_FAKT_OrderIntake_Hist AS a LEFT OUTER JOIN  
                      dbo.Hist_FAKT_OrderComplete_Hist AS b ON a.orderno = b.orderno AND a.orderpos = b.orderpos   
 INNER JOIN dbo.TMP_Months AS m ON   
   
 m.jahrmonat   
   
 BETWEEN CONVERT(char(6), a.orderdate, 112) AND CASE WHEN b.invoicedate IS NULL AND   
                      a.backlogrelevant = 'J' THEN CONVERT(char(6), GETDATE(), 112) ELSE CONVERT(char(6), dateadd(m,-1, b.invoicedate), 112) END  
  


GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Hist_FAKT_OrderComplete_DB2_Hist]'
GO
CREATE TABLE [dbo].[Hist_FAKT_OrderComplete_DB2_Hist]
(
[orderno] [nvarchar] (11) COLLATE Latin1_General_CI_AS NULL,
[orderpos] [int] NULL,
[account] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[bu_id] [int] NULL,
[industry] [nvarchar] (4) COLLATE Latin1_General_CI_AS NULL,
[merchandise] [nvarchar] (1) COLLATE Latin1_General_CI_AS NULL,
[orderdate] [datetime2] NULL,
[estdeliverydate] [datetime2] NULL,
[deliverydate] [datetime2] NULL,
[invoicedate] [datetime2] NULL,
[customer] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[supplier] [nvarchar] (8) COLLATE Latin1_General_CI_AS NULL,
[currency] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[country] [nvarchar] (2) COLLATE Latin1_General_CI_AS NULL,
[ordertype] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[source] [nvarchar] (3) COLLATE Latin1_General_CI_AS NULL,
[department] [nvarchar] (10) COLLATE Latin1_General_CI_AS NULL,
[descriptionofgoods] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[ordercomplete_value] [money] NULL,
[ordercomplete_db2] [money] NULL,
[ordercomplete_value_currency] [money] NULL,
[ordercomplete_db2_currency] [money] NULL,
[ProcurementCenter] [nvarchar] (5) COLLATE Latin1_General_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating extended properties'
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "oi"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "oc"
            Begin Extent = 
               Top = 6
               Left = 291
               Bottom = 84
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Hist_vFAKT_OrderBacklog_Actual_Hist', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Hist_vFAKT_OrderBacklog_Actual_Hist', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 222
               Right = 267
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "m"
            Begin Extent = 
               Top = 6
               Left = 291
               Bottom = 114
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Hist_vFAKT_OrderBacklog_StockValue_Hist', NULL, NULL
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Hist_vFAKT_OrderBacklog_StockValue_Hist', NULL, NULL
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
--Native Backup Restore command start
--To Restore the database uncomment the following line
--RESTORE DATABASE [Staging] FROM DISK='D:\Minh TV\DB\Staging.2016-07-18 16 40 55Z.bak' WITH REPLACE
--Native Backup Restore command finish
