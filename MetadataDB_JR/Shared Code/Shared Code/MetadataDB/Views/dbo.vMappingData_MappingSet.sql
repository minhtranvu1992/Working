
CREATE VIEW [dbo].[vMappingData_MappingSet]
AS
SELECT 
    MappingSet,
    TargetLayer,
    TargetLayerSchema,
    MappingSetID
FROM
    (SELECT
	   *, ROW_NUMBER() OVER (PARTITION BY MappingSetID ORDER BY MappingCount DESC) AS RowPriority
    FROM
	   (SELECT 
		  MappingSetSource + ' to ' + MappingSetTarget AS MappingSet
		   ,DWLayerType AS TargetLayer
		   ,DWLayerAbbreviation AS TargetLayerSchema
		   ,MappingSet.MappingSetID
		   ,COUNT(*) AS MappingCount
	   FROM MappingSet
	   INNER JOIN MappingSetMapping
		   ON MappingSet.MappingSetID = MappingSetMapping.MappingSetID
	   INNER JOIN Mapping
		   ON MappingSetMapping.MappingID = Mapping.MappingID
	   LEFT JOIN 
	   (SELECT 
		  DWObjectID,
		  DWLayerType,
		  DWLayerAbbreviation,
		  DWObject.IncludeInBuild
	   FROM
		  DWObject DWObject 
		  LEFT JOIN DWLayer DWLayer
			 ON DWObject.DWLayerID = DWLayer.DWLayerID
	   UNION
	   SELECT 
		  StagingObjectID AS DWObjectID,
		  'Staging' AS DWLayerType,
		  StagingOwnderPrefix AS DWLayerAbbreviation,
		  StagingObject.IncludeInBuild
	   FROM	   
		  StagingObject StagingObject
		  LEFT JOIN StagingOwner StagingOwner
			 ON StagingObject.StagingOwnerID = StagingObject.StagingOwnerID
	   ) DWObject
		  ON Mapping.TargetObjectID = DWObject.DWObjectID
	   WHERE DWObject.IncludeInBuild = 1
	   GROUP BY 
		  MappingSetSource + ' to ' + MappingSetTarget
		   ,DWLayerType
		   ,DWLayerAbbreviation
		   ,MappingSet.MappingSetID) t
    ) t1
WHERE RowPriority = 1