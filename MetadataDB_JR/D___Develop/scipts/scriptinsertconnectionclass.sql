use MetadataDB_JR

select * from dbo.ConnectionClassCategory 
insert into ConnectionClass (ConnectionClassID,ConnectionClassCategoryID,ConnectionClassName)
values ('flat_file_def','flat_file_def','Flat file Default')