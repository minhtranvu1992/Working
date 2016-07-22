/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Connection ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.Connection ADD CONSTRAINT
	DF_Connection_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.Connection ADD CONSTRAINT
	DF_Connection_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.Connection ADD CONSTRAINT
	DF_Connection_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.Connection ADD CONSTRAINT
	DF_Connection_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.Connection SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER Connection_AfterUpdate
ON dbo.Connection
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Connection
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Connection tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ConnectionID = tbl_ins.ConnectionID

	
END
GO

CREATE TRIGGER Connection_Delete
ON dbo.Connection
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.Connection
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Connection tbl
		INNER JOIN deleted tbl_del
		ON tbl.ConnectionID = tbl_del.ConnectionID

	DELETE FROM dbo.Connection WHERE ConnectionID IN 
	(SELECT ConnectionID FROM deleted)
END
GO

---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.ConnectionClass ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.ConnectionClass ADD CONSTRAINT
	DF_ConnectionClass_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.ConnectionClass ADD CONSTRAINT
	DF_ConnectionClass_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.ConnectionClass ADD CONSTRAINT
	DF_ConnectionClass_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.ConnectionClass ADD CONSTRAINT
	DF_ConnectionClass_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.ConnectionClass SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER ConnectionClass_AfterUpdate
ON dbo.ConnectionClass
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ConnectionClass
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ConnectionClass tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ConnectionClassID = tbl_ins.ConnectionClassID

	
END
GO

CREATE TRIGGER ConnectionClass_Delete
ON dbo.ConnectionClass
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.ConnectionClass
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ConnectionClass tbl
		INNER JOIN deleted tbl_del
		ON tbl.ConnectionClassID = tbl_del.ConnectionClassID

	DELETE FROM dbo.ConnectionClass WHERE ConnectionClassID IN 
	(SELECT ConnectionClassID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.ConnectionClassCategory ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.ConnectionClassCategory ADD CONSTRAINT
	DF_ConnectionClassCategory_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.ConnectionClassCategory ADD CONSTRAINT
	DF_ConnectionClassCategory_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.ConnectionClassCategory ADD CONSTRAINT
	DF_ConnectionClassCategory_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.ConnectionClassCategory ADD CONSTRAINT
	DF_ConnectionClassCategory_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.ConnectionClassCategory SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER ConnectionClassCategory_AfterUpdate
ON dbo.ConnectionClassCategory
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ConnectionClassCategory
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ConnectionClassCategory tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ConnectionClassCategoryID = tbl_ins.ConnectionClassCategoryID

	
END
GO

CREATE TRIGGER ConnectionClassCategory_Delete
ON dbo.ConnectionClassCategory
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.ConnectionClassCategory
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ConnectionClassCategory tbl
		INNER JOIN deleted tbl_del
		ON tbl.ConnectionClassCategoryID = tbl_del.ConnectionClassCategoryID

	DELETE FROM dbo.ConnectionClassCategory WHERE ConnectionClassCategoryID IN 
	(SELECT ConnectionClassCategoryID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DataMart ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DataMart ADD CONSTRAINT
	DF_DataMart_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DataMart ADD CONSTRAINT
	DF_DataMart_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DataMart ADD CONSTRAINT
	DF_DataMart_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DataMart ADD CONSTRAINT
	DF_DataMart_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DataMart SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DataMart_AfterUpdate
ON dbo.DataMart
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DataMart
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DataMart tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DataMartID = tbl_ins.DataMartID

	
END
GO

CREATE TRIGGER DataMart_Delete
ON dbo.DataMart
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DataMart
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DataMart tbl
		INNER JOIN deleted tbl_del
		ON tbl.DataMartID = tbl_del.DataMartID

	DELETE FROM dbo.DataMart WHERE DataMartID IN 
	(SELECT DataMartID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DataMartDWElement ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DataMartDWElement ADD CONSTRAINT
	DF_DataMartDWElement_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DataMartDWElement ADD CONSTRAINT
	DF_DataMartDWElement_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DataMartDWElement ADD CONSTRAINT
	DF_DataMartDWElement_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DataMartDWElement ADD CONSTRAINT
	DF_DataMartDWElement_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DataMartDWElement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DataMartDWElement_AfterUpdate
ON dbo.DataMartDWElement
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DataMartDWElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DataMartDWElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWElementID = tbl_ins.DWElementID
		AND tbl.DataMartID = tbl_ins.DataMartID

	
END
GO

CREATE TRIGGER DataMartDWElement_Delete
ON dbo.DataMartDWElement
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DataMartDWElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DataMartDWElement tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWElementID = tbl_del.DWElementID
		AND tbl.DataMartID = tbl_del.DataMartID

	DELETE tbl FROM dbo.DataMartDWElement tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWElementID = tbl_del.DWElementID
		AND tbl.DataMartID = tbl_del.DataMartID 
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeleteType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DeleteType ADD CONSTRAINT
	DF_DeleteType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DeleteType ADD CONSTRAINT
	DF_DeleteType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DeleteType ADD CONSTRAINT
	DF_DeleteType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DeleteType ADD CONSTRAINT
	DF_DeleteType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DeleteType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DeleteType_AfterUpdate
ON dbo.DeleteType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DeleteType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DeleteType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DeleteTypeID = tbl_ins.DeleteTypeID

	
END
GO

CREATE TRIGGER DeleteType_Delete
ON dbo.DeleteType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DeleteType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DeleteType tbl
		INNER JOIN deleted tbl_del
		ON tbl.DeleteTypeID = tbl_del.DeleteTypeID

	DELETE FROM dbo.DeleteType WHERE DeleteTypeID IN 
	(SELECT DeleteTypeID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeltaType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DeltaType ADD CONSTRAINT
	DF_DeltaType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DeltaType ADD CONSTRAINT
	DF_DeltaType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DeltaType ADD CONSTRAINT
	DF_DeltaType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DeltaType ADD CONSTRAINT
	DF_DeltaType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DeltaType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DeltaType_AfterUpdate
ON dbo.DeltaType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DeltaType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DeltaType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DeltaTypeID = tbl_ins.DeltaTypeID

	
END
GO

CREATE TRIGGER DeltaType_Delete
ON dbo.DeltaType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DeltaType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DeltaType tbl
		INNER JOIN deleted tbl_del
		ON tbl.DeltaTypeID = tbl_del.DeltaTypeID

	DELETE FROM dbo.DeltaType WHERE DeltaTypeID IN 
	(SELECT DeltaTypeID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DomainDataType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DomainDataType ADD CONSTRAINT
	DF_DomainDataType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DomainDataType ADD CONSTRAINT
	DF_DomainDataType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DomainDataType ADD CONSTRAINT
	DF_DomainDataType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DomainDataType ADD CONSTRAINT
	DF_DomainDataType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DomainDataType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DomainDataType_AfterUpdate
ON dbo.DomainDataType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DomainDataType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DomainDataType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DomainDataTypeID = tbl_ins.DomainDataTypeID

	
END
GO

CREATE TRIGGER DomainDataType_Delete
ON dbo.DomainDataType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DomainDataType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DomainDataType tbl
		INNER JOIN deleted tbl_del
		ON tbl.DomainDataTypeID = tbl_del.DomainDataTypeID

	DELETE FROM dbo.DomainDataType WHERE DomainDataTypeID IN 
	(SELECT DomainDataTypeID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DWElement ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DWElement ADD CONSTRAINT
	DF_DWElement_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DWElement ADD CONSTRAINT
	DF_DWElement_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DWElement ADD CONSTRAINT
	DF_DWElement_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DWElement ADD CONSTRAINT
	DF_DWElement_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DWElement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DWElement_AfterUpdate
ON dbo.DWElement
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWElementID = tbl_ins.DWElementID

	
END
GO

CREATE TRIGGER DWElement_Delete
ON dbo.DWElement
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DWElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWElement tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWElementID = tbl_del.DWElementID

	DELETE FROM dbo.DWElement WHERE DWElementID IN 
	(SELECT DWElementID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DWLayer ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DWLayer ADD CONSTRAINT
	DF_DWLayer_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DWLayer ADD CONSTRAINT
	DF_DWLayer_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DWLayer ADD CONSTRAINT
	DF_DWLayer_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DWLayer ADD CONSTRAINT
	DF_DWLayer_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DWLayer SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DWLayer_AfterUpdate
ON dbo.DWLayer
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWLayer
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWLayer tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWLayerID = tbl_ins.DWLayerID

	
END
GO

CREATE TRIGGER DWLayer_Delete
ON dbo.DWLayer
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DWLayer
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWLayer tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWLayerID = tbl_del.DWLayerID

	DELETE FROM dbo.DWLayer WHERE DWLayerID IN 
	(SELECT DWLayerID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DWObject ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DWObject ADD CONSTRAINT
	DF_DWObject_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DWObject ADD CONSTRAINT
	DF_DWObject_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DWObject ADD CONSTRAINT
	DF_DWObject_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DWObject ADD CONSTRAINT
	DF_DWObject_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DWObject SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DWObject_AfterUpdate
ON dbo.DWObject
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWObject
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObject tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWObjectID = tbl_ins.DWObjectID

	
END
GO

CREATE TRIGGER DWObject_Delete
ON dbo.DWObject
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DWObject
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObject tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWObjectID = tbl_del.DWObjectID

	DELETE FROM dbo.DWObject WHERE DWObjectID IN 
	(SELECT DWObjectID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DWObjectBuildType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DWObjectBuildType ADD CONSTRAINT
	DF_DWObjectBuildType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DWObjectBuildType ADD CONSTRAINT
	DF_DWObjectBuildType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DWObjectBuildType ADD CONSTRAINT
	DF_DWObjectBuildType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DWObjectBuildType ADD CONSTRAINT
	DF_DWObjectBuildType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DWObjectBuildType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DWObjectBuildType_AfterUpdate
ON dbo.DWObjectBuildType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWObjectBuildType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObjectBuildType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWObjectBuildTypeID = tbl_ins.DWObjectBuildTypeID

	
END
GO

CREATE TRIGGER DWObjectBuildType_Delete
ON dbo.DWObjectBuildType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DWObjectBuildType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObjectBuildType tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWObjectBuildTypeID = tbl_del.DWObjectBuildTypeID

	DELETE FROM dbo.DWObjectBuildType WHERE DWObjectBuildTypeID IN 
	(SELECT DWObjectBuildTypeID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DWObjectType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.DWObjectType ADD CONSTRAINT
	DF_DWObjectType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.DWObjectType ADD CONSTRAINT
	DF_DWObjectType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.DWObjectType ADD CONSTRAINT
	DF_DWObjectType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.DWObjectType ADD CONSTRAINT
	DF_DWObjectType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.DWObjectType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER DWObjectType_AfterUpdate
ON dbo.DWObjectType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.DWObjectType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObjectType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.DWObjectTypeID = tbl_ins.DWObjectTypeID

	
END
GO

CREATE TRIGGER DWObjectType_Delete
ON dbo.DWObjectType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.DWObjectType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.DWObjectType tbl
		INNER JOIN deleted tbl_del
		ON tbl.DWObjectTypeID = tbl_del.DWObjectTypeID

	DELETE FROM dbo.DWObjectType WHERE DWObjectTypeID IN 
	(SELECT DWObjectTypeID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.ETLImplementationType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.ETLImplementationType ADD CONSTRAINT
	DF_ETLImplementationType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.ETLImplementationType ADD CONSTRAINT
	DF_ETLImplementationType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.ETLImplementationType ADD CONSTRAINT
	DF_ETLImplementationType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.ETLImplementationType ADD CONSTRAINT
	DF_ETLImplementationType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.ETLImplementationType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER ETLImplementationType_AfterUpdate
ON dbo.ETLImplementationType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ETLImplementationType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ETLImplementationType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ETLImplementationTypeID = tbl_ins.ETLImplementationTypeID

	
END
GO

CREATE TRIGGER ETLImplementationType_Delete
ON dbo.ETLImplementationType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.ETLImplementationType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ETLImplementationType tbl
		INNER JOIN deleted tbl_del
		ON tbl.ETLImplementationTypeID = tbl_del.ETLImplementationTypeID

	DELETE FROM dbo.ETLImplementationType WHERE ETLImplementationTypeID IN 
	(SELECT ETLImplementationTypeID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.ExportElement ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.ExportElement ADD CONSTRAINT
	DF_ExportElement_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.ExportElement ADD CONSTRAINT
	DF_ExportElement_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.ExportElement ADD CONSTRAINT
	DF_ExportElement_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.ExportElement ADD CONSTRAINT
	DF_ExportElement_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.ExportElement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER ExportElement_AfterUpdate
ON dbo.ExportElement
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ExportElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ExportElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ExportElementID = tbl_ins.ExportElementID

	
END
GO

CREATE TRIGGER ExportElement_Delete
ON dbo.ExportElement
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.ExportElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ExportElement tbl
		INNER JOIN deleted tbl_del
		ON tbl.ExportElementID = tbl_del.ExportElementID

	DELETE FROM dbo.ExportElement WHERE ExportElementID IN 
	(SELECT ExportElementID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.ExportObject ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.ExportObject ADD CONSTRAINT
	DF_ExportObject_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.ExportObject ADD CONSTRAINT
	DF_ExportObject_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.ExportObject ADD CONSTRAINT
	DF_ExportObject_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.ExportObject ADD CONSTRAINT
	DF_ExportObject_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.ExportObject SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER ExportObject_AfterUpdate
ON dbo.ExportObject
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ExportObject
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ExportObject tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ExportObjectID = tbl_ins.ExportObjectID

	
END
GO

CREATE TRIGGER ExportObject_Delete
ON dbo.ExportObject
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.ExportObject
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ExportObject tbl
		INNER JOIN deleted tbl_del
		ON tbl.ExportObjectID = tbl_del.ExportObjectID

	DELETE FROM dbo.ExportObject WHERE ExportObjectID IN 
	(SELECT ExportObjectID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.ExportSystem ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.ExportSystem ADD CONSTRAINT
	DF_ExportSystem_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.ExportSystem ADD CONSTRAINT
	DF_ExportSystem_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.ExportSystem ADD CONSTRAINT
	DF_ExportSystem_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.ExportSystem ADD CONSTRAINT
	DF_ExportSystem_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.ExportSystem SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER ExportSystem_AfterUpdate
ON dbo.ExportSystem
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.ExportSystem
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ExportSystem tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ExportSystemID = tbl_ins.ExportSystemID

	
END
GO

CREATE TRIGGER ExportSystem_Delete
ON dbo.ExportSystem
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.ExportSystem
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.ExportSystem tbl
		INNER JOIN deleted tbl_del
		ON tbl.ExportSystemID = tbl_del.ExportSystemID

	DELETE FROM dbo.ExportSystem WHERE ExportSystemID IN 
	(SELECT ExportSystemID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Frequency ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.Frequency ADD CONSTRAINT
	DF_Frequency_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.Frequency ADD CONSTRAINT
	DF_Frequency_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.Frequency ADD CONSTRAINT
	DF_Frequency_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.Frequency ADD CONSTRAINT
	DF_Frequency_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.Frequency SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER Frequency_AfterUpdate
ON dbo.Frequency
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Frequency
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Frequency tbl
		INNER JOIN inserted tbl_ins
		ON tbl.FrequencyID = tbl_ins.FrequencyID

	
END
GO

CREATE TRIGGER Frequency_Delete
ON dbo.Frequency
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.Frequency
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Frequency tbl
		INNER JOIN deleted tbl_del
		ON tbl.FrequencyID = tbl_del.FrequencyID

	DELETE FROM dbo.Frequency WHERE FrequencyID IN 
	(SELECT FrequencyID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Mapping ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.Mapping ADD CONSTRAINT
	DF_Mapping_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.Mapping ADD CONSTRAINT
	DF_Mapping_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.Mapping ADD CONSTRAINT
	DF_Mapping_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.Mapping ADD CONSTRAINT
	DF_Mapping_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.Mapping SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER Mapping_AfterUpdate
ON dbo.Mapping
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Mapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Mapping tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingID = tbl_ins.MappingID

	
END
GO

CREATE TRIGGER Mapping_Delete
ON dbo.Mapping
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.Mapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Mapping tbl
		INNER JOIN deleted tbl_del
		ON tbl.MappingID = tbl_del.MappingID

	DELETE FROM dbo.Mapping WHERE MappingID IN 
	(SELECT MappingID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.MappingElement ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.MappingElement ADD CONSTRAINT
	DF_MappingElement_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.MappingElement ADD CONSTRAINT
	DF_MappingElement_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.MappingElement ADD CONSTRAINT
	DF_MappingElement_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.MappingElement ADD CONSTRAINT
	DF_MappingElement_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.MappingElement SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER MappingElement_AfterUpdate
ON dbo.MappingElement
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingElement tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingID = tbl_ins.MappingID
		AND tbl.TargetElementID = tbl_ins.TargetElementID

	
END
GO

CREATE TRIGGER MappingElement_Delete
ON dbo.MappingElement
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.MappingElement
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingElement tbl
		INNER JOIN deleted tbl_del
		ON tbl.MappingID = tbl_del.MappingID
		AND tbl.TargetElementID = tbl_del.TargetElementID

	DELETE tbl FROM dbo.MappingElement tbl 
		INNER JOIN deleted tbl_del
		ON tbl.MappingID = tbl_del.MappingID
		AND tbl.TargetElementID = tbl_del.TargetElementID 

END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.MappingInstance ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.MappingInstance ADD CONSTRAINT
	DF_MappingInstance_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.MappingInstance ADD CONSTRAINT
	DF_MappingInstance_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.MappingInstance ADD CONSTRAINT
	DF_MappingInstance_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.MappingInstance ADD CONSTRAINT
	DF_MappingInstance_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.MappingInstance SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER MappingInstance_AfterUpdate
ON dbo.MappingInstance
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingInstance
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingInstance tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingInstanceID = tbl_ins.MappingInstanceID

	
END
GO

CREATE TRIGGER MappingInstance_Delete
ON dbo.MappingInstance
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.MappingInstance
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingInstance tbl
		INNER JOIN deleted tbl_del
		ON tbl.MappingInstanceID = tbl_del.MappingInstanceID

	DELETE FROM dbo.MappingInstance WHERE MappingInstanceID IN 
	(SELECT MappingInstanceID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.MappingInstanceMapping ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.MappingInstanceMapping ADD CONSTRAINT
	DF_MappingInstanceMapping_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.MappingInstanceMapping ADD CONSTRAINT
	DF_MappingInstanceMapping_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.MappingInstanceMapping ADD CONSTRAINT
	DF_MappingInstanceMapping_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.MappingInstanceMapping ADD CONSTRAINT
	DF_MappingInstanceMapping_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.MappingInstanceMapping SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER MappingInstanceMapping_AfterUpdate
ON dbo.MappingInstanceMapping
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingInstanceMapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingInstanceMapping tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingInstanceID = tbl_ins.MappingInstanceID
		AND tbl.MappingID = tbl_ins.MappingID

	
END
GO

CREATE TRIGGER MappingInstanceMapping_Delete
ON dbo.MappingInstanceMapping
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.MappingInstanceMapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingInstanceMapping tbl
		INNER JOIN deleted tbl_del
		ON tbl.MappingInstanceID = tbl_del.MappingInstanceID
		AND tbl.MappingID = tbl_del.MappingID

	DELETE tbl FROM dbo.MappingInstanceMapping tbl 
		INNER JOIN deleted tbl_del
		ON tbl.MappingInstanceID = tbl_del.MappingInstanceID
		AND tbl.MappingID = tbl_del.MappingID 

END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.MappingSet ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.MappingSet ADD CONSTRAINT
	DF_MappingSet_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.MappingSet ADD CONSTRAINT
	DF_MappingSet_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.MappingSet ADD CONSTRAINT
	DF_MappingSet_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.MappingSet ADD CONSTRAINT
	DF_MappingSet_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.MappingSet SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER MappingSet_AfterUpdate
ON dbo.MappingSet
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingSet
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingSet tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingSetID = tbl_ins.MappingSetID

	
END
GO

CREATE TRIGGER MappingSet_Delete
ON dbo.MappingSet
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.MappingSet
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingSet tbl
		INNER JOIN deleted tbl_del
		ON tbl.MappingSetID = tbl_del.MappingSetID

	DELETE FROM dbo.MappingSet WHERE MappingSetID IN 
	(SELECT MappingSetID FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.MappingSetMapping ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.MappingSetMapping ADD CONSTRAINT
	DF_MappingSetMapping_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.MappingSetMapping ADD CONSTRAINT
	DF_MappingSetMapping_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.MappingSetMapping ADD CONSTRAINT
	DF_MappingSetMapping_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.MappingSetMapping ADD CONSTRAINT
	DF_MappingSetMapping_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.MappingSetMapping SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER MappingSetMapping_AfterUpdate
ON dbo.MappingSetMapping
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.MappingSetMapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingSetMapping tbl
		INNER JOIN inserted tbl_ins
		ON tbl.MappingSetID = tbl_ins.MappingSetID
		AND tbl.MappingID = tbl_ins.MappingID

	
END
GO

CREATE TRIGGER MappingSetMapping_Delete
ON dbo.MappingSetMapping
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.MappingSetMapping
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.MappingSetMapping tbl
		INNER JOIN deleted tbl_del
		ON tbl.MappingSetID = tbl_del.MappingSetID
		AND tbl.MappingID = tbl_del.MappingID

	DELETE tbl FROM dbo.MappingSetMapping tbl 
		INNER JOIN deleted tbl_del
		ON tbl.MappingSetID = tbl_del.MappingSetID
		AND tbl.MappingID = tbl_del.MappingID 
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Parameter ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.Parameter ADD CONSTRAINT
	DF_Parameter_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.Parameter ADD CONSTRAINT
	DF_Parameter_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.Parameter ADD CONSTRAINT
	DF_Parameter_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.Parameter ADD CONSTRAINT
	DF_Parameter_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.Parameter SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER Parameter_AfterUpdate
ON dbo.Parameter
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Parameter
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Parameter tbl
		INNER JOIN inserted tbl_ins
		ON tbl.ParameterName = tbl_ins.ParameterName

	
END
GO

CREATE TRIGGER Parameter_Delete
ON dbo.Parameter
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.Parameter
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.Parameter tbl
		INNER JOIN deleted tbl_del
		ON tbl.ParameterName = tbl_del.ParameterName

	DELETE FROM dbo.Parameter WHERE ParameterName IN 
	(SELECT ParameterName FROM deleted)
END
GO


---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.SourceChangeType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.SourceChangeType ADD CONSTRAINT
	DF_SourceChangeType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.SourceChangeType ADD CONSTRAINT
	DF_SourceChangeType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.SourceChangeType ADD CONSTRAINT
	DF_SourceChangeType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.SourceChangeType ADD CONSTRAINT
	DF_SourceChangeType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.SourceChangeType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER SourceChangeType_AfterUpdate
ON dbo.SourceChangeType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.SourceChangeType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.SourceChangeType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.SourceChangeTypeID = tbl_ins.SourceChangeTypeID

	
END
GO

CREATE TRIGGER SourceChangeType_Delete
ON dbo.SourceChangeType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.SourceChangeType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.SourceChangeType tbl
		INNER JOIN deleted tbl_del
		ON tbl.SourceChangeTypeID = tbl_del.SourceChangeTypeID

	DELETE FROM dbo.SourceChangeType WHERE SourceChangeTypeID IN 
	(SELECT SourceChangeTypeID FROM deleted)
END
GO




---------------------------------------------------------------------------------------------------------------------------
/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.TargetType ADD
	CreatedBy varchar(100) NULL,
	CreatedDateTime datetime NULL,
	UpdatedBy varchar(100) NULL,
	UpdatedDateTime datetime NULL
GO
ALTER TABLE dbo.TargetType ADD CONSTRAINT
	DF_TargetType_CreatedBy DEFAULT suser_name() FOR CreatedBy
GO
ALTER TABLE dbo.TargetType ADD CONSTRAINT
	DF_TargetType_CreatedDateTime DEFAULT GETDATE() FOR CreatedDateTime
GO
ALTER TABLE dbo.TargetType ADD CONSTRAINT
	DF_TargetType_UpdatedBy DEFAULT suser_name() FOR UpdatedBy
GO
ALTER TABLE dbo.TargetType ADD CONSTRAINT
	DF_TargetType_UpdatedDateTime DEFAULT GETDATE() FOR UpdatedDateTime
GO
ALTER TABLE dbo.TargetType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


CREATE TRIGGER TargetType_AfterUpdate
ON dbo.TargetType
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.TargetType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.TargetType tbl
		INNER JOIN inserted tbl_ins
		ON tbl.TargetTypeID = tbl_ins.TargetTypeID

	
END
GO

CREATE TRIGGER TargetType_Delete
ON dbo.TargetType
INSTEAD OF DELETE
AS
BEGIN
	UPDATE dbo.TargetType
		SET UpdatedDateTime = GETDATE(),
		UpdatedBy = SUSER_NAME()
	FROM dbo.TargetType tbl
		INNER JOIN deleted tbl_del
		ON tbl.TargetTypeID = tbl_del.TargetTypeID

	DELETE FROM dbo.TargetType WHERE TargetTypeID IN 
	(SELECT TargetTypeID FROM deleted)
END
GO




USE MetadataDB_New
GO

	DISABLE TRIGGER Audit_DDL
	ON ALL SERVER;
	GO

	exec sys.sp_cdc_disable_db

	IF	(SELECT is_cdc_enabled FROM sys.databases WHERE name = 'MetadataDB_New') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on MetadataDB_New...'
		exec sys.sp_cdc_enable_db
	END
	GO

	
	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'Connection') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on Connection...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'Connection', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'Connection_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'ConnectionClass') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on ConnectionClass...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'ConnectionClass', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'ConnectionClass_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'ConnectionClassCategory') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on ConnectionClassCategory...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'ConnectionClassCategory', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'ConnectionClassCategory_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DataMart') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DataMart...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DataMart', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DataMart_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DataMartDWElement') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DataMartDWElement...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DataMartDWElement', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DataMartDWElement_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DeleteType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DeleteType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DeleteType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DeleteType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DeltaType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DeltaType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DeltaType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DeltaType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DomainDataType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DomainDataType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DomainDataType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DomainDataType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DWElement') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DWElement...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DWElement', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DWElement_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DWLayer') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DWLayer...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DWLayer', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DWLayer_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DWObject') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DWObject...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DWObject', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DWObject_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DWObjectBuildType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DWObjectBuildType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DWObjectBuildType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DWObjectBuildType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'DWObjectType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on DWObjectType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'DWObjectType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'DWObjectType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'ETLImplementationType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on ETLImplementationType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'ETLImplementationType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'ETLImplementationType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'ExportElement') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on ExportElement...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'ExportElement', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'ExportElement_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'ExportObject') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on ExportObject...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'ExportObject', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'ExportObject_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'ExportSystem') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on ExportSystem...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'ExportSystem', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'ExportSystem_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'Frequency') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on Frequency...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'Frequency', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'Frequency_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'Mapping') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on Mapping...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'Mapping', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'Mapping_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'MappingElement') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on MappingElement...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'MappingElement', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'MappingElement_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'MappingInstance') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on MappingInstance...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'MappingInstance', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'MappingInstance_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'MappingInstanceMapping') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on MappingInstanceMapping...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'MappingInstanceMapping', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'MappingInstanceMapping_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'MappingSet') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on MappingSet...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'MappingSet', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'MappingSet_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'MappingSetMapping') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on MappingSetMapping...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'MappingSetMapping', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'MappingSetMapping_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'Parameter') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on Parameter...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'Parameter', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'Parameter_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'SourceChangeType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on SourceChangeType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'SourceChangeType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'SourceChangeType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO

	IF (SELECT is_tracked_by_cdc FROM sys.tables WHERE name = 'TargetType') = 0
	BEGIN
		PRINT N'Enable Change Data Capture on TargetType...'
		exec sys.sp_cdc_enable_table 
		  @source_schema = N'dbo', --Schema
		  @source_name = N'TargetType', --Table
		  @role_name = NULL, --Database role that has access
		  @capture_instance = N'TargetType_Audit',
		  @supports_net_changes = 1,
		  @captured_column_list = NULL, --include all columns
		  @filegroup_name = NULL -- use default file group 
	END
	GO


	ENABLE TRIGGER Audit_DDL
	ON ALL SERVER;
	GO

exec dbo.uspShowAllDMLChanges

ALTER PROC uspShowAllDMLChanges (
	@StartTime DATETIME = NULL,
	@EndTime DATETIME = NULL
)
AS
BEGIN

	SET @StartTime = COALESCE(@StartTime, GETDATE() - 1)
	SET @EndTime = COALESCE(@EndTime, GETDATE())

	select 
		'Connection' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Connection_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ConnectionClass' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ConnectionClass_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ConnectionClassCategory' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ConnectionClassCategory_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DataMart' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DataMart_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DataMartDWElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DataMartDWElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DeleteType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DeleteType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DeltaType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DeltaType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DomainDataType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DomainDataType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWLayer' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWLayer_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWObject' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWObject_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWObjectBuildType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWObjectBuildType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWObjectType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWObjectType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ETLImplementationType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ETLImplementationType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ExportElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ExportElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ExportObject' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ExportObject_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ExportSystem' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ExportSystem_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'Frequency' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Frequency_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'Mapping' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Mapping_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingInstance' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingInstance_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingInstanceMapping' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingInstanceMapping_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingSet' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingSet_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingSetMapping' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingSetMapping_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'Parameter' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Parameter_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'SourceChangeType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.SourceChangeType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'TargetType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.TargetType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

END

