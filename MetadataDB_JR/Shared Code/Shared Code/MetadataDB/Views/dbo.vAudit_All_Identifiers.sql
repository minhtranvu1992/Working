
CREATE VIEW [dbo].[vAudit_All_Identifiers]
AS
SELECT 'DataMart' AS ObjectType,
		'N/A' AS ParentObjectID,
		DataMart.DataMartID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for DataMart.DataMartSchemaAbbreviation' AS Mitigation,
		IncludeInBuild
	FROM dbo.DataMart AS DataMart 
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(DataMart.DataMartSchemaAbbreviation)), IncludeInBuild) AS ErrorList

UNION ALL

SELECT 'DWElement' AS ObjectType,
		DWElement.DWObjectID AS ParentObjectID,
		DWElement.DWElementID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for DWElement.DWElementName' AS Mitigation,
		DWObject.IncludeInBuild AS IncludeInBuild
	FROM dbo.DWElement AS DWElement
	   INNER JOIN DWObject DWObject
		  ON DWElement.DWObjectID = DWObject.DWObjectID
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(DWElement.DWElementName)), DWObject.IncludeInBuild) AS ErrorList

UNION ALL

SELECT 'DWLayer' AS ObjectType,
		'N/A' AS ParentObjectID,
		DWLayer.DWLayerID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for DWLayer.DWLayerAbbreviation' AS Mitigation,
		'1' AS IncludeInBuild
	FROM dbo.DWLayer AS DWLayer
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(DWLayer.DWLayerAbbreviation)), 1) AS ErrorList

UNION ALL

SELECT 'DWObject' AS ObjectType,
		DWObject.DWLayerID AS ParentObjectID,
		DWObject.DWObjectID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for DWObject.DWObjectName' AS Mitigation,
		DWObject.IncludeInBuild AS IncludeInBuild
	FROM dbo.DWObject AS DWObject
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(DWObject.DWObjectName)), DWObject.IncludeInBuild) AS ErrorList

UNION ALL

SELECT 'StagingObject' AS ObjectType,
		'N/A' AS ParentObjectID,
		StagingObject.StagingObjectID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for StagingObject.StagingObjectName' AS Mitigation,
		StagingObject.IncludeInBuild AS IncludeInBuild
	FROM dbo.StagingObject AS StagingObject
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(StagingObject.StagingObjectName)), StagingObject.IncludeInBuild) AS ErrorList

UNION ALL

SELECT 'StagingOwner' AS ObjectType,
		'N/A' AS ParentObjectID,
		StagingOwner.StagingOwnerID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for StagingOwner.StagingOwnderPrefix' AS Mitigation,
		'1' AS IncludeInBuild
	FROM dbo.StagingOwner AS StagingOwner
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(StagingOwner.StagingOwnderPrefix)), 1) AS ErrorList

UNION ALL

SELECT 'Mapping' AS ObjectType,
		'N/A' AS ParentObjectID,
		Mapping.MappingID AS ObjectID,
		ErrorList.Severity,
		ErrorList.ViolatedDescription AS Violation,
		Mitigation + ' for Mapping.AlternatePackageName' AS Mitigation,
		COALESCE(DWObject.IncludeInBuild, StagingObject.IncludeInBuild) AS IncludeInBuild
	FROM dbo.Mapping AS Mapping
	LEFT JOIN DWObject DWObject
	   ON Mapping.TargetObjectID = DWObject.DWObjectID AND Mapping.TargetTypeID = 'dw'
	LEFT JOIN StagingObject StagingObject
	   ON Mapping.TargetObjectID = StagingObject.StagingObjectID AND Mapping.TargetTypeID = 'stag'
		CROSS APPLY  [dbo].[fnValidateIdentifier](RTRIM(LTRIM(Mapping.AlternatePackageName)), COALESCE(DWObject.IncludeInBuild, StagingObject.IncludeInBuild)) AS ErrorList
	WHERE Mapping.AlternatePackageName IS NOT NULL