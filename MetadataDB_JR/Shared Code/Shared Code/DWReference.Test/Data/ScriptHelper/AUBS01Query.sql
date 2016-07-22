USE DWStaging
GO

/****** Object:  Table AUBS01.STG_PremiseInventory    Script Date: 8/19/2014 9:09:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('AUBS01.STG_PremiseInventory', 'U') IS NOT NULL
BEGIN
	DROP TABLE AUBS01.STG_PremiseInventory
END
GO
CREATE TABLE AUBS01.STG_PremiseInventory(
	StagingJobID int NOT NULL,
	Date date NOT NULL,
	DealerCode nvarchar(40) NOT NULL,
	Article nvarchar(40) NOT NULL,
	IMEI nvarchar(40) NOT NULL,
	Qty int NULL,
 CONSTRAINT PK_AUBS01_STG_PremiseInventory PRIMARY KEY CLUSTERED 
(
	Date ASC,
	DealerCode ASC,
	Article ASC,
	IMEI ASC
)
) 
GO

IF OBJECT_ID('AUBS01.stg_Vendor', 'U') IS NOT NULL
BEGIN
	DROP TABLE AUBS01.stg_Vendor
END
GO
CREATE TABLE AUBS01.stg_Vendor(
	VendorID nvarchar(40) NOT NULL,
	CompanyCode nvarchar(40) NULL,
	CountryCode nvarchar(40) NULL,
	CreditTerms nvarchar(100) NULL,
	CreditTermsCode nvarchar(40) NULL,
	Vendor nvarchar(100) NULL,
	VendorClass nvarchar(100) NULL,
	VendorClassCode nvarchar(40) NULL,
	VendorCode nvarchar(40) NULL,
	LoadTime datetime NOT NULL,
	LastChangeTime datetime NULL,
	StagingJobID int NOT NULL,
	SourceIdentifier nvarchar(40) NULL,
	ExtractJobID int NULL,
 CONSTRAINT PK_Ext_erp_Vendor_EJID_BK PRIMARY KEY CLUSTERED 
(
	StagingJobID ASC,
	VendorID ASC
)) 

GO

ALTER TABLE AUBS01.stg_Vendor ADD  CONSTRAINT DF_AUBS01_stg_Vendor_LoadTime  DEFAULT (getdate()) FOR LoadTime
GO


