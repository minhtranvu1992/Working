




CREATE VIEW [dbo].[vAudit_DWElement_NotUsedinDatamart]
AS 
SELECT 
    'DWElement' AS  ObjectType,
    DWElement.DWObjectID AS ParentObjectID,
    DWElement.DWElementID AS ObjectID, 
    'Info' AS Severity,
    'DWElement ' + DWElement.DWElementID + ' is not used in any of the Data Marts'   AS Violation,
    'Either: Add in the DWElementt ' + DWElement.DWElementID + ' to the required datamart  OR Delete from DWElement table' AS Mitigation,
    IncludeInBuild
FROM 
	dbo.DWLayer DWLayer
	INNER JOIN dbo.DWObject DWObject
		ON DWObject.DWLayerID = DWLayer.DWLayerID
	INNER JOIN dbo.DWElement DWElement
		ON DWObject.DWObjectID = DWElement.DWObjectID
	LEFT JOIN dbo.DataMartDWElement DataMartDWElement
		ON DWElement.DWElementID = DataMartDWElement.DWElementID
WHERE	
	DWLayer.DWLayerType = 'Logical'
	AND DataMartDWElement.DWElementID IS NULL