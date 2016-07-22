
CREATE VIEW [dbo].[vFeedData_Summary] AS
SELECT TOP 100000
	DWLayer.DWLayerName AS [Source Type],
	DWObjectType.DWObjectGroup AS [Feed Type],
	DWObjectType.DWObjectType AS [Destination Object Type],
	DWObject.DWObjectName AS [Feed Name],
	DWObject.DWObjectDesc AS [Feed Description],
	Mapping.DefaultSourceChangeTypeID AS [Data Window Category],
	Mapping.DefaultFrequencyID AS [Feed Frequency],
	'' AS [Data Currency]
FROM 
	dbo.DWObject DWObject
	INNER JOIN dbo.DWObjectType DWObjectType ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
	INNER JOIN dbo.DWLayer DWLayer ON DWObject.DWLayerID = DWLayer.DWLayerID
	INNER JOIN dbo.Mapping Mapping ON DWObject.DWObjectID = Mapping.TargetObjectID
		AND (MappingID LIKE 'pla_%' OR MappingID LIKE 'mdm_%' OR MappingID Like '%_ax2012_Def' OR MappingID LIKE 'pos_%' ) 
WHERE 
	DWLayerType = 'Base'
	AND DWObject.IncludeInBuild = 1
	AND DWObject.DWLayerID IN ('erp')
	AND DWObject.DWObjectName NOT IN ('BusinessEntityProductRange', 'CurrencyAlias', 'CurrencyMapping', 'InventoryAgeing', 'BusinessEntityCountry', 'Country')
ORDER BY 
	DWLayer.DWLayerName,
	DWObjectType.DWObjectGroup,
	DWObject.DWObjectName