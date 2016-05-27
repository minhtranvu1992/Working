SELECT *
FROM Parameter;
INSERT INTO Parameter
(ParameterName,
 ParameterValue,
 ParameterDesc
)
       SELECT p.ParameterName,
              p.ParameterValue,
              p.ParameterDesc
       FROM MetadataDB_NEW.dbo.Parameter p
       WHERE p.ParameterName IN('DWStaging_ActualDB', 'DWStaging_ModelDB', 'DWStaging_Size_DataFile_Model', 'DWStaging_Size_LogFile_Model','EnalbeForeignKeys_Model','CompressionType_Model');