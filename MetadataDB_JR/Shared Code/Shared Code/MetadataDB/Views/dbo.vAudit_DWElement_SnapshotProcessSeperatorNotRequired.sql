CREATE VIEW [dbo].[vAudit_DWElement_SnapshotProcessSeperatorNotRequired]
AS 
SELECT 
    'DWElement' AS  ObjectType,
    DWElement.DWObjectID AS ParentObjectID,
    DWElement.DWElementID AS ObjectID, 
    'Warning' AS Severity,
    'DWObject ' + DWElement.DWObjectID + ' of type ' + DWObject.DWObjectTypeID + ' Has DWElement ' + DWElement.DWElementID + ' set as a SnapshotProcessSeperator. Not required for objects of this type'   AS Violation,
    'Either: Set the SnapshotProcessSeperator flag to 0 or NULL for this DWElement or change the ObjectType to FACT-SNAPSHOT' AS Mitigation,
    IncludeInBuild
FROM 
    DWObject DWObject 
    LEFT JOIN DWElement DWElement
	   ON DWElement.DWObjectID = DWObject.DWObjectID
WHERE 
    DWObject.DWObjectTypeID <>  'FACT-SNAPSHOT'
    AND DWElement.SnapshotProcessSeperator = 1