BACKUP DATABASE [DWReference] TO  DISK = N'D:\UnitTest\DatabaseBackups\DWReference.bak'
 WITH NOFORMAT, INIT,  
 NAME = N'DWReference-Full Database Backup', 
 SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
GO
