INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_ModelDB', N'DWData_Model', N'This is the datbase that will be used in the USE Database statement for deployment of the DWData database objects when the environment is ''Model''', NULL, NULL, N'BRIGHTSTAR\slawson', CAST(0x0000A34200AFD181 AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_ModelDB', N'DWExtract_Model', N'This is the datbase that will be used in the USE Database statement for deployment of the DWExtract database objects when the environment is ''Model''', NULL, NULL, N'BRIGHTSTAR\slawson', CAST(0x0000A34200AFD8F0 AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DW_ModelServer', N'05W8F2APSQ03\DEV2012', N'This is the server that will be used in the Connect Statement for deployment of the DWData and DWExtract database objects', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_TargetDB', N'DWData', N'This is the datbase that will be used in the DWData Synonyms in the DWExtract database', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWReference_ModelDB', N'DWReference_Model', N'This is the datbase that will be used in the USE Database statement for deployment of the DWReference Control Records', NULL, NULL, N'BRIGHTSTAR\slawson', CAST(0x0000A3380099F91A AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_DataModelDB', N'DWData_DataModelDB', N'This is the datatabase where a data model can be created off metadata for synching with data model tool', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWReference_TargetDB', N'DWReference', N'This is the name of the active DWReference Database', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_DataFile_DEV', N'4GB', N'This is the size of the data file when DWData is created in DEV', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_LogFile_DEV', N'2GB', N'This is the size of the log file when DWData is created in DEV', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_DataFile_Model', N'50MB', N'This is the size of the data file when DWData is created as a Model DB', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_LogFile_Model', N'25MB', N'This is the size of the log file when DWData is created as a Model DB', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_DataFile_Model', N'50MB', N'This is the size of the data file when DWExtract is created as a Model DB', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_LogFile_Model', N'25MB', N'This is the size of the log file when DWExtract is created as a Model DB', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'CompressionType_Model', N'PAGE', N'This flag indicates whether tables are Page Compressed (Page), Row Compressed (Row) or Uncompressed (None) in Model', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'EnalbeForeignKeys_Model', N'Yes', N'This setting will determine whether foreign keys are enabled between facts and dimensions in Model', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DeltaSelectList', N'{Delta-SelectList}', N'This tag will be the place holder in any SQL code for the insertion of the delta logic as part of the Select (i.e. "Delta AS LastChangeTime")', N'BRIGHTSTAR\slawson', CAST(0x0000A2CB009AF1F0 AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A2CB009B7256 AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DeltaDateRange', N'{Delta-DateRange}', N'This tag will be the place holder in any SQL code fot he insertion of the delta logic as part of an existing WHERE clause (i.e. " AND Delta Between @starttime and @endTime")', N'BRIGHTSTAR\slawson', CAST(0x0000A2CB009BF50A AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A2CB009BF50A AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DeltaWhereClauseDateRange', N'{Delta-WhereClauseDateRange}', N'This tag will be the place holder in any SQL code for the insertion of the delta logic where there is no existing WHERE clause (i.e. " WHERE Delta Between @starttime and @endTime")', N'BRIGHTSTAR\slawson', CAST(0x0000A2CB009C27C3 AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A2CB009C5429 AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_ActualDB', N'DWStaging', N'This is the datbase that will be used in the USE Database statement for deployment of the DWStaging database objects when the environment is ''DEV'', ''UAT'', ''PROD''', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51A AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51A AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_ModelDB', N'DWStaging_Model', N'This is the datbase that will be used in the USE Database statement for deployment of the DWStaging database objects when the environment is ''Model''', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51A AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A34200AFDF9E AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_DataFile_DEV', N'4GB', N'This is the size of the data file when DWStaging is created in DEV', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51B AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51B AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_DataFile_Model', N'50MB', N'This is the size of the data file when DWStaging is created as a Model DB', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51B AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51B AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_DataFile_PROD', N'100GB', N'This is the size of the data file when DWStaging is created in PROD', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51C AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51C AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_DataFile_UAT', N'4GB', N'This is the size of the data file when DWStaging is created in UAT', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51C AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51C AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_LogFile_DEV', N'2GB', N'This is the size of the log file when DWStaging is created in DEV', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51D AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51D AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_LogFile_Model', N'25MB', N'This is the size of the log file when DWStaging is created as a Model DB', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51D AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51D AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_LogFile_PROD', N'50GB', N'This is the size of the log file when DWStaging is created in PROD', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51E AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51E AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWStaging_Size_LogFile_UAT', N'2GB', N'This is the size of the log file when DWStaging is created in UAT', N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51E AS DateTime), N'BRIGHTSTAR\slawson', CAST(0x0000A30100B7F51E AS DateTime))
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_DataFile_UAT', N'4GB', N'This is the size of the data file when DWData is created in UAT', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_LogFile_UAT', N'2GB', N'This is the size of the log file when DWData is created in UAT', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_DataFile_PROD', N'100GB', N'This is the size of the data file when DWData is created in PROD', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_Size_LogFile_PROD', N'50GB', N'This is the size of the log file when DWData is created in PROD', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_DataFile_PROD', N'50GB', N'This is the size of the data file when DWExtract is created in PROD', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_LogFile_PROD', N'25GB', N'This is the size of the log file when DWExtract is created in PROD', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_DataFile_UAT', N'4GB', N'This is the size of the data file when DWExtract is created in UAT', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_LogFile_UAT', N'2GB', N'This is the size of the log file when DWExtract is created in UAT', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_DataFile_DEV', N'4GB', N'This is the size of the data file when DWExtract is created in DEV', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_Size_LogFile_DEV', N'2GB', N'This is the size of the log file when DWExtract is created in DEV', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWData_ActualDB', N'DWData', N'This is the datbase that will be used in the USE Database statement for deployment of the DWData database objects when the environment is ''DEV'', ''UAT'', ''PROD''', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'DWExtract_ActualDB', N'DWExtract', N'This is the datbase that will be used in the USE Database statement for deployment of the DWExtract database objects when the environment is  ''DEV'', ''UAT'', ''PROD''', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'CompressionType_UAT', N'PAGE', N'This flag indicates whether tables are Page Compressed (Page), Row Compressed (Row) or Uncompressed (None) in UAT', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'CompressionType_DEV', N'PAGE', N'This flag indicates whether tables are Page Compressed (Page), Row Compressed (Row) or Uncompressed (None) in DEV', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'CompressionType_PROD', N'PAGE', N'This flag indicates whether tables are Page Compressed (Page), Row Compressed (Row) or Uncompressed (None) in PROD', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'EnableForeignKeys_UAT', N'Yes', N'This setting will determine whether foreign keys are enabled between facts and dimensions in UAT', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'EnableForeignKeys_DEV', N'Yes', N'This setting will determine whether foreign keys are enabled between facts and dimensions in DEV', NULL, NULL, NULL, NULL)
INSERT [dbo].[Parameter] ([ParameterName], [ParameterValue], [ParameterDesc], [CreatedBy], [CreatedDateTime], [UpdatedBy], [UpdatedDateTime]) VALUES (N'EnalbeForeignKeys_PROD', N'No', N'This setting will determine whether foreign keys are enabled between facts and dimensions in PROD', NULL, NULL, NULL, NULL)
