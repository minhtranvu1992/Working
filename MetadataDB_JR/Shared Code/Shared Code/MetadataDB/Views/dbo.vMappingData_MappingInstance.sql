
CREATE VIEW [dbo].[vMappingData_MappingInstance] AS 
SELECT 
    MappingInstance.MappingInstanceID,
    MappingInstanceDesc,
    TargetLayer,
    TargetLayerSchema,
    MappingInstance.MappingSetID,
    MappingSet.MappingSet AS MappingSetDesc,
    Connection.ConnectionName AS MappingSourceDescription,
    ConnectionClass.ConnectionClassName AS MappingSourceSystem,
    ConnectionClassCategory.ConnectionClassCategoryName AS SourceSystemTechnology,
    COUNT(DISTINCT Mapping.MappingID) AS NumberOfMappings,
    COUNT(DISTINCT MappingElement.MappingID + MappingElement.TargetElementID) AS NumberOfMappingElements

FROM MappingInstance MappingInstance
INNER JOIN 
    vMappingData_MappingSet MappingSet
    ON MappingInstance.MappingSetID = MappingSet.MappingSetID
LEFT JOIN Connection Connection
    ON MappingInstance.SourceConnectionID = Connection.ConnectionID
LEFT JOIN ConnectionClass ConnectionClass
    ON Connection.ConnectionClassID = ConnectionClass.ConnectionClassID
LEFT JOIN ConnectionClassCategory ConnectionClassCategory
    ON ConnectionClass.ConnectionClassCategoryID = ConnectionClassCategory.ConnectionClassCategoryID
LEFT JOIN 
    vMappingData_Mapping Mapping
    ON MappingSet.MappingSetID = Mapping.MappingSetID
LEFT JOIN 
    vMappingData_MappingElement MappingElement
    ON Mapping.MappingID = MappingElement.MappingID
WHERE IncludeInBuild = 1 
GROUP BY 
    MappingInstance.MappingInstanceID,
    MappingInstanceDesc,
    TargetLayer,
    TargetLayerSchema,
    MappingInstance.MappingSetID,
    MappingSet.MappingSet,
    Connection.ConnectionName,
    ConnectionClass.ConnectionClassName,
    ConnectionClassCategory.ConnectionClassCategoryName