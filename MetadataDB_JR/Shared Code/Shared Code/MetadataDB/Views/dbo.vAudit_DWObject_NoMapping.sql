




CREATE VIEW [dbo].[vAudit_DWObject_NoMapping]
AS
SELECT 
  'DWObject' AS  ObjectType,
    DWObject.DWObjectID AS ParentObjectID, 
    'N/A' AS ObjectID,
    (CASE WHEN DWObject.IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
    'DW Object has no associated Mapping and is not a reference object' AS Violation,
    'Either: Add in the Mappings for ' + DWObject.DWObjectID + ' OR Delete ' + DWObject.DWObjectID + ' from DWObject table' AS Mitigation,
    DWObject.IncludeInBuild
FROM 
	dbo.DWLayer DWLayer
	INNER JOIN dbo.DWObject DWObject
		ON DWObject.DWLayerID = DWLayer.DWLayerID
	LEFT JOIN dbo.Mapping Mapping
		ON DWObject.DWObjectID = Mapping.TargetObjectID
WHERE	
	DWLayer.DWLayerID <> 'ref'
	AND Mapping.MappingID IS NULL