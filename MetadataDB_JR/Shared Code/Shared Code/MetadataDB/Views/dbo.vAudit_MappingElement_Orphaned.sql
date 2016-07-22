
CREATE VIEW [dbo].[vAudit_MappingElement_Orphaned] 
AS
SELECT 
    'MappingElement' AS  ObjectType,
    MappingElement.MappingID AS ParentObjectID, 
    MappingElement.TargetElementID AS ObjectID,
    (CASE WHEN COALESCE(DWObject.IncludeInBuild, StagingObject.IncludeInBuild) = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
    'No Corresponding Target Element for MappingElement with MappingID ' + MappingElement.MappingID + ' that targets Element ' + MappingElement.TargetElementID  AS Violation,
    'Either: Add in the DWElement or StagingElement for  ' + MappingElement.MappingID + ' that matches the TargetElementID ' + MappingElement.TargetElementID + ' OR Delete this MappingElement' AS Mitigation,
    COALESCE(DWObject.IncludeInBuild, StagingObject.IncludeInBuild) AS IncludeInBuild
FROM 
	dbo.MappingElement MappingElement
	INNER JOIN dbo.Mapping Mapping
	   ON MappingElement.MappingID = Mapping.MappingID
     LEFT JOIN dbo.DWObject DWObject
	   ON Mapping.TargetObjectID = DWObject.DWObjectID
	   And Mapping.TargetTypeID = 'dw'
	LEFT JOIN dbo.DWElement DWElement 
	   ON MappingElement.TargetElementID = DWElement.DWElementID
	   And Mapping.TargetTypeID = 'dw'
     LEFT JOIN dbo.StagingObject StagingObject
	   ON Mapping.TargetObjectID = StagingObject.StagingObjectID
	   And Mapping.TargetTypeID = 'stag'
	LEFT JOIN dbo.StagingElement StagingElement 
	   ON MappingElement.TargetElementID = StagingElement.StagingElementID
	   And Mapping.TargetTypeID = 'stag'
WHERE	
	(Mapping.TargetTypeID = 'dw' AND DWElement.DWElementID IS NULL)
	OR  (Mapping.TargetTypeID = 'stag' AND StagingElement.StagingElementID IS NULL)