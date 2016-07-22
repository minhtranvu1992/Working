

CREATE VIEW [dbo].[vMappingData_MappingElement]
AS
WITH MappingElementSet AS
(SELECT 
    DWObjectType.DWObjectGroup,
    DWLayer.DWLayerType,
    DWLayer.DWLayerAbbreviation,
    DWElement.DWElementName,
    DWElement.InferredMemberLoad,
    DWElement.EntityLookupObjectID,
    DWElement.RetainBusinessKey,
    COALESCE(CAST(DWElement.BusinessKeyOrder AS VARCHAR), '') AS BusinessKeyOrder,
    DWElement.SnapshotProcessSeperator,
    DomainDataType.DataType,
    MappingElement.MappingComments,
    Mapping.MappingID,
    DWElement.DWElementID AS TargetElementID,
    MappingElement.SourceElementLogic,
    EntityLookupObject.DWObjectName AS EntityLookupObjectName,
    EntityLookupLayer.DWLayerType AS EntityLookupLayerType,
    EntityLookupLayer.DWLayerAbbreviation AS EntityLookupLayerAbbreviation,
    COALESCE(CASE 
	   WHEN DefaultTypeID = 'DomainDefault' THEN DomainDataType.DomainDefaultValue
	   WHEN DefaultTypeID = 'UserDefined' THEN BespokeDefaultLogic
	   ELSE ''
    END, '') AS DefaultValue
FROM DWElement 
LEFT JOIN DomainDataType DomainDataType
     ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
INNER JOIN DWObject DWObject
	ON DWElement.DWObjectID = DWObject.DWObjectID
INNER JOIN Mapping Mapping
     ON  DWObject.DWObjectID = Mapping.TargetObjectID
LEFT JOIN MappingElement
     ON Mapping.MappingID = MappingElement.MappingID
	AND MappingElement.TargetElementID = DWElement.DWElementID
INNER JOIN DWLayer DWLayer
	ON DWObject.DWLayerID = DWLayer.DWLayerID
INNER JOIN DWObjectType DWObjectType
	ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
LEFT JOIN DWObject EntityLookupObject
	ON DWElement.EntityLookupObjectID = EntityLookupObject.DWObjectID
LEFT JOIN DWLayer EntityLookupLayer
	ON EntityLookupObject.DWLayerID = EntityLookupLayer.DWLayerID
UNION 
SELECT 
    StagingObjectType.StagingObjectType AS DWObjectGroup,
    'Staging' AS DWLayerType,
    StagingOwner.StagingOwnderPrefix,
    StagingElement.StagingElementName,
    NULL AS InferredMemberLoad,
    'N/A' AS EntityLookupObjectID,
    NULL AS RetainBusinessKey,
    COALESCE(CAST(StagingElement.BusinessKeyOrder AS VARCHAR), '') AS BusinessKeyOrder,
    NULL AS SnapshotProcessSeperator,
    DomainDataType.DataType,
    MappingElement.MappingComments,
    Mapping.MappingID,
    StagingElement.StagingElementID AS TargetElementID,
    MappingElement.SourceElementLogic,
    'N/A' AS EntityLookupObjectName,
    'N/A' AS EntityLookupLayerType,
    'N/A' AS EntityLookupLayerAbbreviation,
    'N/A' AS DefaultValue
FROM StagingElement 
LEFT JOIN DomainDataType DomainDataType
     ON StagingElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
INNER JOIN StagingObject StagingObject
	ON StagingElement.StagingObjectID = StagingObject.StagingObjectID
INNER JOIN Mapping Mapping
     ON  StagingObject.StagingObjectID = Mapping.TargetObjectID
LEFT JOIN MappingElement
     ON Mapping.MappingID = MappingElement.MappingID
	AND MappingElement.TargetElementID = StagingElement.StagingElementID
INNER JOIN StagingOwner StagingOwner
	ON StagingObject.StagingOwnerID = StagingOwner.StagingOwnerID
INNER JOIN StagingObjectType StagingObjectType
	ON StagingObject.StagingObjectTypeID = StagingObjectType.StagingObjectTypeID
)
--Mappings to base DW Objects
SELECT 
    DWElementName AS TargetColumn
	,COALESCE(MappingComments, '') AS Comments
	,COALESCE(SourceElementLogic,'') AS ColumnLogic
	,'' AS AdjunctETLRequired
	,'' AS AdjunctETLTarget
	,MappingID
	,TargetElementID
	,CASE WHEN DWObjectGroup = 'Fact' AND EntityLookupObjectID IS NULL THEN BusinessKeyOrder ELSE '' END AS BusinessKeyOrder
	,DataType
	,DefaultValue
	,EntityLookupObjectID
FROM
    MappingElementSet UnchangedElements
WHERE
    DWLayerType IN ('Base')
	   --Either its a normal element where we don't create a surrogate key (entitylookupid is null)
    AND ((EntityLookupObjectID IS NULL)
	   --Or its an element where we do create a surrogate key where but we want to retain the businesskey in the data model
    OR (EntityLookupObjectID IS NOT NULL AND COALESCE(RetainBusinessKey, 1) = 1))
UNION ALL
SELECT 
    (CASE 
	   WHEN ([DataType] LIKE '%Date%')  
			 THEN REPLACE(DWElementName,'Date','DateID') 
	   WHEN (DWElementName LIKE '%ID')  OR (DWObjectGroup = 'Dimension' AND BusinessKeyOrder = '1' AND DWElementName LIKE '%ID' AND DWElementName <> 'DateID')
			 THEN REPLACE(DWElementName,'ID','SK') 
	   WHEN (EntityLookupObjectID IS NOT NULL AND DWElementName NOT LIKE '%ID')  OR (DWObjectGroup = 'Dimension' AND BusinessKeyOrder = 1 AND DWElementName NOT LIKE '%ID')
			 THEN DWElementName + 'SK' 
	   ELSE DWElementName
    END) AS TargetColumn
	,COALESCE(MappingComments, '') AS Comments
	--,COALESCE(SourceElementLogic,'') AS ColumnLogic
     ,(CASE
	   WHEN (DWObjectGroup = 'Dimension' AND BusinessKeyOrder = '1') THEN 'Incrementing Identity'
	   ELSE 'Use ' + DWElementName + ' Logic: [' + COALESCE(SourceElementLogic,'') + ']'
	  END)  AS ColumnLogic
	,COALESCE(CASE 
		WHEN EntityLookupObjectID IS NOT NULL AND DWLayerType = 'Base' AND InferredMemberLoad = 1 AND DWObjectGroup = 'FACT'
			THEN 'InferredMemberLoad'
		WHEN EntityLookupObjectID IS NOT NULL AND DWLayerType = 'Base' AND InferredMemberLoad = 1 AND DWObjectGroup = 'Dimension'
			THEN 'SnowflakeMemberLoad'
		ELSE NULL
		END, '') AS AdjunctETLRequired
	,(CASE WHEN DWLayerType = 'Base' AND InferredMemberLoad = 1 THEN COALESCE((EntityLookupLayerAbbreviation + '.' + EntityLookupObjectName), '') ELSE '' END) AS AdjunctETLTarget
	,MappingID
	,TargetElementID
	,BusinessKeyOrder
	,'integer' AS DataType
	,DefaultValue
	,EntityLookupObjectID
FROM
    MappingElementSet SurrogateKeyFields
WHERE
    SurrogateKeyFields.DWLayerType IN ('Base') AND
    (
	   EntityLookupObjectID IS NOT NULL OR 
	   (DWObjectGroup = 'Dimension' AND BusinessKeyOrder = '1')
	)
--Mappings to Logical Layer DW Objects
UNION ALL
SELECT 
    DWElementName AS TargetColumn
	,COALESCE(MappingComments, '') AS Comments
	,COALESCE(SourceElementLogic,'') AS ColumnLogic
	,'' AS AdjunctETLRequired
	,'' AS AdjunctETLTarget
	,MappingID
	,TargetElementID
	,BusinessKeyOrder  
	,DataType
	,DefaultValue
	,EntityLookupObjectID
FROM
    MappingElementSet LogicalElements
WHERE
    DWLayerType IN ('Logical', 'Summary')
UNION
SELECT
    DWElementName AS TargetColumn
	,COALESCE(MappingComments, '') AS Comments
	,COALESCE(SourceElementLogic,'') AS ColumnLogic
	,'' AS AdjunctETLRequired
	,'' AS AdjunctETLTarget
	,MappingID
	,TargetElementID
	,BusinessKeyOrder  
	,DataType
	,DefaultValue
	,EntityLookupObjectID
FROM 
    MappingElementSet StagingElements
WHERE DWLayerType = 'Staging'