BACKUP DATABASE [DWStaging] TO  DISK = N'D:\UnitTest\DatabaseBackups\DWStaging.bak'
 WITH NOFORMAT, INIT,  
 NAME = N'DWStaging-Full Database Backup', 
 SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO
