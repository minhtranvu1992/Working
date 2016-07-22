
CREATE VIEW [dbo].[vAudit_Mapping_MappingSetContainsMappingsTargetingMultipleLayerTypes] AS
WITH MappingSet_Mapping_DWLayer 
AS 
(SELECT 
    MappingSetMapping.MappingSetID,
    MappingSetMapping.MappingID,
    Mapping.TargetObjectID,
    DWObject.DWLayerID,
    DWLayer.DWLayerType,
    DWObject.IncludeInBuild
FROM
    dbo.MappingSetMapping MappingSetMapping
    LEFT JOIN dbo.Mapping Mapping
	   ON MappingSetMapping.MappingID = Mapping.MappingID
    LEFT JOIN dbo.DWObject DWObject
	   ON Mapping.TargetObjectID = DWObject.DWObjectID
    LEFT JOIN dbo.DWLayer DWLayer
	   ON DWObject.DWLayerID = DWLayer.DWLayerID	   
	   )
SELECT 
    'Mapping' AS  ObjectType,
    MappingSet_Mapping_DWLayer.MappingSetID AS ParentObjectID, 
    MappingID AS ObjectID,
    CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END AS Severity,
    'Mapping ' + MappingID + ' is mapped to TargetObject ' +  + ' Which is a ' + MappingSet_Mapping_DWLayer.DWLayerType + ' Layer Object. This is different to the majority of mappings in this Mapping Set'  AS Violation,
    'Either remove the Mapping from the mapping set, or review the target object for the Mapping' AS Mitigation,
    IncludeInBuild AS IncludeInBuild
FROM MappingSet_Mapping_DWLayer
INNER JOIN 
    (SELECT 
	   MappingSetID, DWLayerType, ROW_Number() OVER (PARTITION bY MappingSetID ORDER BY COUNT(*) DESC) AS LayerCount
    FROM 
	   MappingSet_Mapping_DWLayer
    GROUP BY
	   MappingSetID, DWLayerType) sub
    ON MappingSet_Mapping_DWLayer.MappingSetID = sub.MappingSetID AND MappingSet_Mapping_DWLayer.DWLayerType = sub.DWLayerType AND sub.LayerCount > 1