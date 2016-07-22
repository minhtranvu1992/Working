CREATE VIEW dbo.vAudit_Mapping_Issues AS
WITH MappingAuditInfo
AS
(
    SELECT 
	   TargetConnectionID,
	   MappingID,
	   DefaultSourceChangeTypeID,
	   SourceObjectLogic,
	   DefaultETLImplementationTypeID,
	   Mapping.IncludeInBuild 
    FROM dbo.Mapping Mapping
    INNER JOIN 
    (
	   SELECT StagingObjectID AS TargetObjectID, IncludeInBuild FROM dbo.StagingObject StagingObject
	   WHERE IncludeInBuild = 1
	   UNION 
	   SELECT DWObjectID, IncludeInBuild FROM dbo.DWObject DWObject
	   WHERE IncludeInBuild = 1) BuildObjects
	   ON Mapping.TargetObjectID = BuildObjects.TargetObjectID
    WHERE 1=1
	   --Mapping.IncludeInBuild = 1 AND 
	   --(DefaultSourceChangeTypeID IS NULL OR SourceObjectLogic IS NULL OR DefaultETLImplementationTypeID IS NULL) 
)
SELECT
    'Mapping' AS ObjectType,
    TargetConnectionID AS ParentObjectID,
    MappingID AS ObjectID, 
    CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END AS Severity,
    'Mapping ' + MappingID + ' is missing SourceObjectLogic'  AS Violation,
    'Add the Mapping Logic for the Mapping' AS Mitigation,
    IncludeInBuild AS IncludeInBuild
FROM
     MappingAuditInfo MappingAuditInfo
WHERE 
    MappingAuditInfo.DefaultETLImplementationTypeID <> 'FlatFile_Bulkload_Staging' AND SourceOBjectLogic IS NULL
UNION
SELECT
    'Mapping' AS ObjectType,
    TargetConnectionID AS ParentObjectID,
    MappingID AS ObjectID, 
    CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END AS Severity,
    'Mapping ' + MappingID + ' is missing the DefaultETLImplementationTypeID'  AS Violation,
    'Add the DefaultETLImplementationTypeID for the Mapping' AS Mitigation,
    IncludeInBuild AS IncludeInBuild
FROM
     MappingAuditInfo MappingAuditInfo
WHERE 
    MappingAuditInfo.DefaultETLImplementationTypeID IS NULL
UNION
SELECT
    'Mapping' AS ObjectType,
    TargetConnectionID AS ParentObjectID,
    MappingID AS ObjectID, 
    CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END AS Severity,
    'Mapping ' + MappingID + ' is missing the DefaultSourceChangeTypeID'  AS Violation,
    'Add the DefaultSourceChangeTypeID for the Mapping' AS Mitigation,
    IncludeInBuild AS IncludeInBuild
FROM
     MappingAuditInfo MappingAuditInfo
WHERE 
    MappingAuditInfo.DefaultSourceChangeTypeID IS NULL
UNION
SELECT
    'Mapping' AS ObjectType,
    TargetConnectionID AS ParentObjectID,
    MappingID AS ObjectID, 
    CASE WHEN IncludeInBuild = 1 THEN 'Error' ELSE 'Warning' END AS Severity,
    'Mapping ' + MappingID + ' DefaultSourceChangeTypeID:' + DefaultSourceChangeTypeID + ' DefaultETLImplementationTypeID:' +  DefaultETLImplementationTypeID + '. These should both be view if one is view'  AS Violation,
    'Change both to be view, or change the one with the view value to have another value' AS Mitigation,
    IncludeInBuild AS IncludeInBuild
FROM
     MappingAuditInfo MappingAuditInfo
WHERE 
    (DefaultSourceChangeTypeID = 'view' OR DefaultETLImplementationTypeID = 'view')
    AND (DefaultSourceChangeTypeID <> DefaultETLImplementationTypeID)