
CREATE VIEW [dbo].[vMappingData_Mapping]
AS
SELECT MappingSetSource + ' to ' + DWLayerAbbreviation + '.' + DWObjectName AS Mapping
	,COALESCE(MappingComments, '') AS MappingComments
	,DeliveryMethod
	,ETLImplementationType.ETLImplementationType AS ETLImplementation
	,SourceChangeType AS ExtractMethod
	,COALESCE(PreMappingLogic, '') AS PreMappingLogic
     ,(CASE WHEN SourceChangeType = 'Flat File' THEN 'Flat File: Not Applicable' ELSE SourceObjectLogic END) AS MappingLogic
	,COALESCE(PostMappingLogic, '') AS PostMappingLogic
	,MappingSet.MappingSetID
	,Mapping.MappingID
FROM MappingSet
INNER JOIN MappingSetMapping
	ON MappingSet.MappingSetID = MappingSetMapping.MappingSetID
INNER JOIN Mapping
	ON MappingSetMapping.MappingID = Mapping.MappingID
LEFT JOIN ETLImplementationType
	ON Mapping.DefaultETLImplementationTypeID = ETLImplementationType.ETLImplementationTypeID
LEFT JOIN
    (SELECT 
	   DWLayer.DWLayerAbbreviation,
	   DWObject.DWObjectID,
	   DWObject.DWObjectName,
	   DWObject.IncludeInBuild,
	   DWObjectType.DWObjectType AS DeliveryMethod
    FROM
	   DWObject	
	   LEFT JOIN DWLayer
		  ON DWObject.DWLayerID = DWLayer.DWLayerID
	   LEFT JOIN DWObjectType
		  ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
    UNION
    SELECT
	   StagingOwner.StagingOwnderPrefix,
	   StagingObject.StagingObjectID,
	   StagingObject.StagingObjectName,
	   StagingObject.IncludeInBuild,
	   StagingObjectType.StagingObjectType
    FROM
	   StagingObject	
	   LEFT JOIN StagingOwner
		  ON StagingObject.StagingOwnerID = StagingOwner.StagingOwnerID
	   LEFT JOIN StagingObjectType
		  ON StagingObject.StagingObjectTypeID = StagingObjectType.StagingObjectTypeID
    ) DWObject
    ON Mapping.TargetObjectID = DWObject.DWObjectID
    LEFT JOIN SourceChangeType
	    ON Mapping.DefaultSourceChangeTypeID = SourceChangeType.SourceChangeTypeID
WHERE DWObject.IncludeInBuild = 1