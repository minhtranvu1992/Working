use MetadataDB_JR
select * from  ConnectionClass

insert into Connection (ConnectionID,ConnectionClassID,ConnectionName,ConnectionString,SuiteName,SourceName)
values ('flat_file_FRP_default','flat_file_def','Flat files for maxis in default format','','FRP','DWReferenceFileProcess')