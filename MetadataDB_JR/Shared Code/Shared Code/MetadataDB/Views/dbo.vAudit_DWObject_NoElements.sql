


CREATE VIEW [dbo].[vAudit_DWObject_NoElements]
AS 
SELECT 
  'DWObject' AS  ObjectType,
    DWObject.DWObjectID AS ParentObjectID, 
    'N/A' AS ObjectID,
    (CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
    'DW Object has no associated DWElements' AS Violation,
    'Either: Add in the DWElements for ' + DWObject.DWObjectID + ' OR Delete ' + DWObject.DWObjectID + ' from DWObject table' AS Mitigation,
    IncludeInBuild
FROM 
	dbo.DWLayer DWLayer
	INNER JOIN dbo.DWObject DWObject
		ON DWObject.DWLayerID = DWLayer.DWLayerID
	LEFT JOIN dbo.DWElement DWElement
		ON DWObject.DWObjectID = DWElement.DWObjectID
WHERE	
	DWElement.DWObjectID IS NULL