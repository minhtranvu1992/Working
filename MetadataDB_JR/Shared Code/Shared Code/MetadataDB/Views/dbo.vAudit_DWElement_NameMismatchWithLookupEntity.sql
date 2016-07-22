

CREATE VIEW [dbo].[vAudit_DWElement_NameMismatchWithLookupEntity] 
AS
SELECT 
    'DWElement' AS  ObjectType,
    DWElement.DWObjectID AS ParentObjectID, 
    DWElement.DWElementID AS ObjectID,
    'Info' AS Severity,
    'Naming of DWElement ' + DWElement.DWElementName + 'does not match the entity which it references ' + Lookup_DWObject.DWObjectName AS Violation,
    'Alter the Name of the element, or correct the entity to which it is mapped' AS Mitigation,
    Parent_DWObject.IncludeInBuild    
FROM 
    dbo.DWElement DWElement
    LEFT JOIN dbo.DWObject Parent_DWObject 
	   ON DWElement.DWObjectID = Parent_DWObject.DWObjectID
    LEFT JOIN dbo.DWObject Lookup_DWObject 
	   ON DWElement.EntityLookupObjectID = Lookup_DWObject.DWObjectID
WHERE DWElement.EntityLookupObjectID IS NOT NULL AND CHARINDEX(Lookup_DWObject.DWObjectName, DWElement.DWElementName, 0) = 0