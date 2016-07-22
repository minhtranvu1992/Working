

CREATE PROC [dbo].[uspShowAllDMLChanges] (
	@StartTime DATETIME = NULL,
	@EndTime DATETIME = NULL
)
AS
BEGIN

	SET @StartTime = COALESCE(@StartTime, GETDATE() - 1)
	SET @EndTime = COALESCE(@EndTime, GETDATE())

	select 
		'Connection' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Connection_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ConnectionClass' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ConnectionClass_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ConnectionClassCategory' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ConnectionClassCategory_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DataMart' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DataMart_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DataMartDWElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DataMartDWElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DeleteType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DeleteType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DeltaType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DeltaType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DomainDataType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DomainDataType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWLayer' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWLayer_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWObject' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWObject_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWObjectBuildType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWObjectBuildType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'DWObjectType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.DWObjectType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ETLImplementationType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ETLImplementationType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ExportElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ExportElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ExportObject' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ExportObject_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'ExportSystem' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.ExportSystem_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'Frequency' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Frequency_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'Mapping' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Mapping_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingElement' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingElement_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingInstance' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingInstance_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingInstanceMapping' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingInstanceMapping_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingSet' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingSet_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'MappingSetMapping' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.MappingSetMapping_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'Parameter' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.Parameter_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'SourceChangeType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.SourceChangeType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

	select 
		'TargetType' AS TableEntity,
		CASE [__$operation] 
			WHEN 1 THEN 'Delete' 
			WHEN 2 THEN 'Insert'
			WHEN 3 THEN 'Pre-Update'
			WHEN 4 THEN 'Post-Update'
		END AS Operation, 
		* 
	FROM cdc.TargetType_Audit_CT 
	WHERE __$Start_lsn > sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1)
		
		AND UpdatedDateTime BETWEEN @StartTime AND @EndTime
	ORDER BY __$start_lsn

END