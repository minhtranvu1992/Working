









CREATE VIEW [dbo].[vAudit_DWElement_MissingMappingElement]
AS 
SELECT
    'DWElement' AS  ObjectType,
    Mapping.MappingID AS ParentObjectID, 
    DWElement.DWElementID AS ObjectID,
    'Warning' AS Severity,
    'DWElement ' + DWElement.DWElementID + ' is missing a mapping for the Mapping ' + Mapping.MappingID   AS Violation,
    'Either: Add in the MappingElement for  ' + Mapping.MappingID + ' that has the TargetElementID ' + DWElement.DWElementID + ' OR Delete ' + DWElement.DWElementID + ' from DWElement table' AS Mitigation,
    DWObject.IncludeInBuild
FROM 
	dbo.DWLayer DWLayer
	INNER JOIN dbo.DWObject DWObject
		ON DWObject.DWLayerID = DWLayer.DWLayerID
	INNER JOIN dbo.DWElement DWElement
		ON DWObject.DWObjectID = DWElement.DWObjectID
	INNER JOIN dbo.Mapping Mapping
		ON DWObject.DWObjectID = Mapping.TargetObjectID
	LEFT JOIN dbo.MappingElement MappingElement
		ON Mapping.MappingID = MappingElement.MappingID
		AND DWElement.DWElementID = MappingElement.TargetElementID
WHERE	
	DWLayer.DWLayerID <> 'ref'
	AND MappingElement.TargetElementID IS NULL
	AND (DWElement.DefaultTypeID IS NULL)