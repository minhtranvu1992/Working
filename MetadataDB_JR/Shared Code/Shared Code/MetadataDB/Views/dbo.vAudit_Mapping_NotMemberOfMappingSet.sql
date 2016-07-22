





CREATE VIEW [dbo].[vAudit_Mapping_NotMemberOfMappingSet]
AS 
SELECT 
    'Mapping' AS  ObjectType,
    Mapping.MappingID AS ParentObjectID, 
    'N/A' AS ObjectID,
    (CASE WHEN DWObject.IncludeInBuild = 1 AND Mapping.IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
    'Mapping is not part of a mapping set' AS Violation,
    'Either: Add in the Mapping  ' + Mapping.MappingID + ' to a MappingSet OR Delete ' + Mapping.MappingID + ' from Mapping table' AS Mitigation,
    (CASE WHEN DWObject.IncludeInBuild = 1 AND Mapping.IncludeInBuild = 1 THEN 1 ELSE 0 END) AS IncludeInBuild
FROM 
	dbo.DWLayer DWLayer
	INNER JOIN dbo.DWObject DWObject
		ON DWObject.DWLayerID = DWLayer.DWLayerID
	INNER JOIN dbo.Mapping Mapping
		ON DWObject.DWObjectID = Mapping.TargetObjectID
	LEFT JOIN dbo.MappingSetMapping MappingSetMapping
		ON Mapping.MappingID = MappingSetMapping.MappingID
WHERE	
	 DWLayer.DWLayerID <> 'ref'
	AND MappingSetMapping.MappingID IS NULL