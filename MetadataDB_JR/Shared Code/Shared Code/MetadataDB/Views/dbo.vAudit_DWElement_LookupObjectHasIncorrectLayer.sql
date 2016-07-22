


CREATE VIEW [dbo].[vAudit_DWElement_LookupObjectHasIncorrectLayer] 
AS
SELECT
    'DWElement' AS  ObjectType,
    DWElement.DWObjectID AS ParentObjectID, 
    DWElement.DWElementID AS ObjectID,
    CASE WHEN Parent_DWObject.IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END AS Severity,
    'Layer Type of DWElement ' + DWElement.DWElementID + ' (' + Parent_DWLayer.DWLayerType + ') does not match the layer type of the Lookup Object ' + Lookup_DWObject.DWObjectID + ' (' + Lookup_DWLayer.DWLayerType + ')' AS Violation,
    'Change the lookup object to one of the appropriate DWLayer' AS Mitigation,
    Parent_DWObject.IncludeInBuild
FROM 
    dbo.DWElement DWElement
    LEFT JOIN dbo.DWObject Parent_DWObject 
	   ON DWElement.DWObjectID = Parent_DWObject.DWObjectID
    LEFT JOIN dbo.DWLayer Parent_DWLayer 
	   ON Parent_DWObject.DWLayerID = Parent_DWLayer.DWLayerID
    LEFT JOIN dbo.DWObject Lookup_DWObject 
	   ON DWElement.EntityLookupObjectID = Lookup_DWObject.DWObjectID
    LEFT JOIN dbo.DWLayer Lookup_DWLayer 
	   ON Lookup_DWObject.DWLayerID = Lookup_DWLayer.DWLayerID
WHERE
    Lookup_DWObject.DWObjectID IS NOT NULL
    AND Parent_DWLayer.DWLayerType <> Lookup_DWLayer.DWLayerType