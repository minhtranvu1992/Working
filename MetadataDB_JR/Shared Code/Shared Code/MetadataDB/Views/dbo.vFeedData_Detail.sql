CREATE VIEW [dbo].[vFeedData_Detail] AS
SELECT TOP 100000
		GeneralObjectName AS [Feed Name],
		DWElementName AS [Column Name],
		BusinessKeyOrder AS [Business Key Order],
		DWElementDesc AS [Column Desc],
		DataType AS [Data Type],
		ReferencesObject AS [References Object]
FROM
	(SELECT
		GeneralObjectName,
		DWObject.DWObjectName,
		DWElement.DWElementName,
		(CASE WHEN DWObject.GeneralObjectName = DWObject.DWObjectName 
			THEN DWElement.BusinessKeyOrder
			ELSE NULL
		END) AS BusinessKeyOrder,
		DWElement.DWElementDesc,
		DomainDataType.DataType,
		(CASE WHEN DWObject.GeneralObjectName = DWObject.DWObjectName AND DWObjectType.DWObjectGroup = 'Fact'
			THEN EntityLookupLayer.DWLayerName + '.' + EntityLookupObject.DWObjectName
			ELSE NULL
		END) AS ReferencesObject,
		ROW_NUMBER() OVER (PARTITION BY GeneralObjectName, DWElementName ORDER BY (CASE WHEN  GeneralObjectName = DWObject.DWObjectName THEN 'AAA' ELSE DWObject.DWObjectName END)) As RowPriority
	FROM 
		(SELECT
			DWObjectID,
			CASE 
				WHEN DWObjectName IN ('Premise', 'BillTo', 'DistributionKeyAccount')  THEN 'Premise'
				WHEN DWObjectName IN ('Warehouse', 'PlanningGroup', 'BusinessEntity') THEN 'Warehouse'
				WHEN DWObjectName IN ('Product', 'MasterProduct') THEN 'Product'
				ELSE DWObjectName 
			END AS GeneralObjectName,
			DWObjectName,
			DWObjectTypeID,
			DWLayerID,
			IncludeInBuild
		FROM dbo.DWObject) 
		DWObject
		INNER JOIN dbo.DWObjectType DWObjectType ON DWObject.DWObjectTypeID = DWObjectType.DWObjectTypeID
		INNER JOIN dbo.DWLayer DWLayer ON DWObject.DWLayerID = DWLayer.DWLayerID
		INNER JOIN dbo.DWElement DWElement ON DWObject.DWObjectID = DWElement.DWObjectID
		INNER JOIN dbo.DomainDataType DomainDataType ON DWElement.DomainDataTypeID = DomainDataType.DomainDataTypeID
		LEFT JOIN dbo.DWObject EntityLookupObject ON DWElement.EntityLookupObjectID = EntityLookupObject.DWObjectID
		LEFT JOIN dbo.DWLayer EntityLookupLayer ON EntityLookupObject.DWLayerID = EntityLookupLayer.DWLayerID
	WHERE 
		DWLayer.DWLayerType = 'Base'
		AND DWObject.IncludeInBuild = 1
		AND DWObject.DWLayerID NOT IN ('ref', 'pla')
		AND DWObject.DWObjectName NOT IN ('BusinessEntityProductRange', 'CurrencyAlias', 'CurrencyMapping', 'InventoryAgeing', 'BusinessEntityCountry', 'Country')
) DataFeedColumns
WHERE RowPriority = 1
ORDER BY 
	GeneralObjectName, 
	COALESCE(BusinessKeyOrder,999),
	DWElementName