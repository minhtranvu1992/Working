CREATE VIEW [dbo].[vAudit_DWElement_MultipleSnapshotProcessSeperator]
AS 
SELECT 
    'DWElement' AS  ObjectType,
    DWElement.DWObjectID AS ParentObjectID,
    DWElement.DWElementID AS ObjectID, 
    (CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END) AS Severity,
    'DWElement ' + DWElement.DWElementID + ' is one of multiple SnapshotProcessSeperators'   AS Violation,
    'Either: Ensure only 1 Element per DWObject has SnapshotProcessSeperator Set to 1' AS Mitigation,
    IncludeInBuild
FROM 
    DWElement DWElement
    INNER JOIN DWObject DWObject 
	   ON DWElement.DWObjectID = DWObject.DWObjectID
    INNER JOIN 
	   (SELECT DWObjectID
	   FROM DWElement
	   WHERE SnapshotProcessSeperator = 1
	   GROUP BY DWObjectID
	   HAVING COUNT(*) > 1) t
	   ON DWElement.DWObjectID = t.DWObjectID
WHERE 
    DWElement.SnapshotProcessSeperator = 1