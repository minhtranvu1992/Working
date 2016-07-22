



CREATE VIEW [dbo].[vAudit_Datamart_OrphanedElements]
AS 
SELECT 
    'DataMartDWElement' AS  ObjectType,
    DataMartDWElement.DataMartID AS ParentObjectID,
    DataMartDWElement.DataMartID + '-' + DataMartDWElement.DWElementID AS ObjectID, 
    'Warning' AS Severity,
    'No Corresponding DWElement for Record in DataMartDWElementTable given by DataMartID ' + DataMartDWElement.DataMartID + ' And DWElementID ' + DataMartDWElement.DWElementID  AS Violation,
    'Either: Add in the DWElement for  ' + DataMartDWElement.DWElementID + ' Or Delete the record from the DataMartDWElement table' AS Mitigation,
    1 AS IncludeInBuild
FROM 
	dbo.DataMartDWElement DataMartDWElement
	LEFT JOIN dbo.DataMart DataMart
	   ON DataMartDWElement.DataMartID = DataMart.DataMartID
	LEFT JOIN dbo.DWElement DWElement
		ON DWElement.DWElementID = DataMartDWElement.DWElementID
WHERE	
	DWElement.DWElementID IS NULL