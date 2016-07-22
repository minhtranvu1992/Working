CREATE VIEW vAudit_Element_BusinessKeyOrder AS
SELECT
     ElementType AS ObjectType ,
     DWObjectID AS ParentObjectID ,
     DWElementID AS ObjectID , 
     (CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
     DWObjectID + ' element ' + DWElementID + ' has a business key order of ' + CAST(BusinessKeyOrder_Actual AS VARCHAR) + ' but this may need to be ' + CAST(BusinessKeyOrder_Contiguous AS VARCHAR)  AS Violation ,
     'Please updated the BusinessKeyOrder Field for Elements in the ' + DWObjectID + ' Object so that they start with 1 and are Contiguous'  AS Mitigation ,
     IncludeInBuild AS IncludeInBuild 
FROM
(SELECT 
    'DWElement' AS ElementType, IncludeInBuild, DWObject.DWObjectID, DWElementID, ROW_NUMBER() OVER (PARTITION BY DWObject.DWObjectID ORDER BY BusinessKeyOrder) AS BusinessKeyOrder_Contiguous, BusinessKeyOrder AS BusinessKeyOrder_Actual
FROM 
    dbo.DWElement DWElement
    INNER JOIN dbo.DWObject DWObject
	   ON DWElement.DWObjectID = DWObject.DWObjectID 
WHERE DWElement.BusinessKeyOrder IS NOT NULL
UNION
SELECT 
    'StagingElement' AS ElementType, IncludeInBuild, StagingObject.StagingObjectID, StagingElementID, ROW_NUMBER() OVER (PARTITION BY StagingObject.StagingObjectID ORDER BY BusinessKeyOrder) AS BusinessKeyOrder_Contiguous, BusinessKeyOrder AS BusinessKeyOrder_Actual
FROM 
    dbo.StagingElement StagingElement
    INNER JOIN dbo.StagingObject StagingObject
	   ON StagingElement.StagingObjectID = StagingObject.StagingObjectID 
WHERE StagingElement.BusinessKeyOrder IS NOT NULL
) AllObjects
WHERE AllObjects.BusinessKeyOrder_Contiguous <> AllObjects.BusinessKeyOrder_Actual