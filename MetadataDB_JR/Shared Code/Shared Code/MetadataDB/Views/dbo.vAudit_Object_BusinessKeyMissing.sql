CREATE VIEW vAudit_Object_BusinessKeyMissing AS
SELECT
     ElementType AS ObjectType ,
     DWObjectID AS ParentObjectID ,
     DWObjectID AS ObjectID , 
     (CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
     DWObjectID + ' Does not have a Business Key' AS Violation ,
     'Please updated the BusinessKeyOrder Field in the related Element Table for' + DWObjectID  AS Mitigation ,
     IncludeInBuild AS IncludeInBuild 
FROM
(SELECT 
    'DWObject' AS ElementType, IncludeInBuild, DWObject.DWObjectID, BusinessKeyOrder
FROM 
    dbo.DWElement DWElement
    INNER JOIN dbo.DWObject DWObject
	   ON DWElement.DWObjectID = DWObject.DWObjectID 
UNION
SELECT 
    'StagingObject' AS ElementType, IncludeInBuild, StagingObject.StagingObjectID, BusinessKeyOrder
FROM 
    dbo.StagingElement StagingElement
    INNER JOIN dbo.StagingObject StagingObject
	   ON StagingElement.StagingObjectID = StagingObject.StagingObjectID 
) AllObjects
GROUP bY ElementType, IncludeInBuild, DWObjectID
HAVING COUNT(BusinessKeyOrder) = 0