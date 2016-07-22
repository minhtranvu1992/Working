using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace DWReference.Test
{
    class DataHelper
    {
        static public string GetDataSSISConfiguration(string ConfigurationFilter, string connStr)
        {
            var ds = GetData("SELECT ConfiguredValue FROM dbo.SSISConfiguration WHERE ConfigurationFilter = '" + ConfigurationFilter + "'", connStr);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["ConfiguredValue"].ToString();
            }
            return "";
        }

        static public string CopyFile(string FullFileNameSource, string FullFileNameDestination, string connStr_DWRefenece)
        {
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            String testFile = Path.GetFullPath(Path.Combine(BulkPath, FullFileNameSource));

            string sqlquery = "SELECT sfp.ConfiguredValue AS 'Folder', sEn.ConfiguredValue AS 'Environment' FROM [DWReference].[dbo].[SSISConfiguration] sFP "
                            + "INNER JOIN [DWReference].[dbo].[SSISConfiguration] sEn ON sEn.[ConfigurationFilter] = 'Environment' "
                            + "WHERE sfp.[ConfigurationFilter] = 'FileDir_DWRefenceFileProcess'";

            var ds = GetData(sqlquery, connStr_DWRefenece, false);

            string baseFolder = Path.Combine(ds.Tables[0].Rows[0]["Folder"].ToString(),ds.Tables[0].Rows[0]["Environment"].ToString());

            string FileDestination = Path.Combine(baseFolder, FullFileNameDestination);

            File.Copy(testFile, FileDestination);

            return FileDestination;
        }

        static public  int GetCount(string query, string connStr, bool timeoutOverride = false)
        {
            var ds = GetData(query, connStr, timeoutOverride);
            return Convert.ToInt32(ds.Tables[0].Rows[0][0]);
        }
        static public DataSet GetData(string query, string connStr, bool timeoutOverride = false)
        {
            var dsb = new System.Data.Common.DbConnectionStringBuilder();
            dsb.ConnectionString = connStr;
            dsb.Remove("Provider");
            connStr = dsb.ConnectionString;

            DataSet ds = new DataSet();

            SqlConnectionStringBuilder sb = new SqlConnectionStringBuilder(connStr);

            if (timeoutOverride)
            {
                sb.ConnectTimeout = 0;
            }

            using (SqlConnection sqlConn = new SqlConnection(sb.ConnectionString))
            {
                SqlCommand command = new SqlCommand(query, sqlConn);

                if (timeoutOverride)
                {
                    command.CommandTimeout = 0;
                }

                SqlDataAdapter dataAdapt = new SqlDataAdapter();
                dataAdapt.SelectCommand = command;

                dataAdapt.Fill(ds);

                sqlConn.Close();
            }

            return ds;
        }

        public static void LoadExcelData(string BulkPath, string FileLocation, string SheetName, string PrimaryKey, string connStr, DataHelper.DataRecordHandling drh)
        {
            String dataFile = Path.GetFullPath(Path.Combine(BulkPath, FileLocation));
            var dt = getExeclData(dataFile, SheetName + "$");

            // Check whether destination table has indentity columns
            int hasIdentity = DataHelper.GetCount("SELECT count(*) FROM  SYS.IDENTITY_COLUMNS WHERE OBJECT_NAME(OBJECT_ID) = '" + SheetName + "'", connStr);

            string dataquery = buildUpsertCommand(dt, PrimaryKey, SheetName, drh);
            if (hasIdentity > 0)
            {
                dataquery = "SET IDENTITY_INSERT [dbo].[" + SheetName + "] ON" + Environment.NewLine + "GO"
                            + Environment.NewLine + dataquery + Environment.NewLine + "GO" + Environment.NewLine
                            + "SET IDENTITY_INSERT [dbo].[" + SheetName + "] OFF" + Environment.NewLine + "GO"
                            + Environment.NewLine;
            }
            else
            {
                dataquery = Environment.NewLine + dataquery + Environment.NewLine + "GO" + Environment.NewLine;
            }

            RunQuery(dataquery, connStr);
        }

        public static void ExecuteSqlScript(string fullFileNamePath, string connStr)
        {
            FileInfo fileInfo = new FileInfo(fullFileNamePath);
            string script = fileInfo.OpenText().ReadToEnd();

            RunQuery(script, connStr);
        }

        static public void RunQuery(string query, string connStr)
        {
            var dsb = new System.Data.Common.DbConnectionStringBuilder();
            dsb.ConnectionString = connStr;
            dsb.Remove("Provider");
            connStr = dsb.ConnectionString;

            //split the script on "GO" commands
            string[] splitter = new string[] { "\r\nGO\r\n" };
            string[] commandTexts = query.Split(splitter, StringSplitOptions.RemoveEmptyEntries);

            using (SqlConnection sqlConn = new SqlConnection(connStr))
            {
                sqlConn.Open();

                foreach (string commandText in commandTexts)
                {
                    SqlCommand command = new SqlCommand(commandText, sqlConn);
                    command.CommandTimeout = 0;

                    command.ExecuteNonQuery();
                }
                sqlConn.Close();
            }
        }

        [Flags]
        public enum DataRecordHandling{ Insert=1, Update=2, Delete=4}
        public static string buildUpsertCommand(DataTable dt, string PrimaryKeyColumn, string TableName, DataRecordHandling drh)
        {
            string sqlquery = "";
            foreach (DataRow dr in dt.Rows)
            {
                if ((drh & DataRecordHandling.Delete) == DataRecordHandling.Delete)
                {
                    sqlquery += "DELETE FROM " + TableName + " WHERE " + PrimaryKeyColumn + " = '" +
                                dr[PrimaryKeyColumn].ToString() + "'" + Environment.NewLine;
                }

                if ((drh & DataRecordHandling.Update) == DataRecordHandling.Update)
                {
                    string values = "";
                    foreach (DataColumn dc in dt.Columns)
                    {
                        if (dc.ColumnName != PrimaryKeyColumn)
                        {
                            if (!String.IsNullOrEmpty(values))
                            {
                                values += ", ";
                            }

                            if (dr[dc.ColumnName] == null || dr[dc.ColumnName] == DBNull.Value)
                            {
                                values += dc.ColumnName + " = NULL";
                            }
                            else
                            {
                                if (dc.DataType.Name == "DateTime")
                                {
                                    values += dc.ColumnName + " = " + "'" +
                                              ((DateTime) dr[dc.ColumnName]).ToString("yyyy-MM-dd hh:mm:ss") + "'";
                                }
                                else
                                {
                                    values += dc.ColumnName + " = " + "'" + dr[dc.ColumnName].ToString() + "'";
                                }
                            }

                        }
                    }
                    sqlquery += "UPDATE " + TableName + " SET " + values + " WHERE " + PrimaryKeyColumn + " = '" +
                                dr[PrimaryKeyColumn].ToString() + "'" + Environment.NewLine;
                }

                if ((drh & DataRecordHandling.Insert) == DataRecordHandling.Insert)
                {
                    string InsertColumns = "";
                    string Values = "";
                    foreach (DataColumn dc in dt.Columns)
                    {
                        if (!String.IsNullOrEmpty(InsertColumns))
                        {
                            InsertColumns += ", ";
                        }

                        if (!String.IsNullOrEmpty(Values))
                        {
                            Values += ", ";
                        }

                        InsertColumns += dc.ColumnName;

                        if (dr[dc.ColumnName] == null || dr[dc.ColumnName] == DBNull.Value)
                        {
                            Values += "NULL";
                        }
                        else
                        {
                            if (dc.DataType.Name == "DateTime")
                            {
                                Values += "'" + ((DateTime) dr[dc.ColumnName]).ToString("yyyy-MM-dd hh:mm:ss") + "'";
                            }
                            else
                            {
                                Values += "'" + dr[dc.ColumnName].ToString() + "'";
                            }
                        }
                    }
                    sqlquery += "IF NOT EXISTS(SELECT * FROM " + TableName + " WHERE " + PrimaryKeyColumn + " = '" + dr[PrimaryKeyColumn].ToString() + "')" + Environment.NewLine
                             + "BEGIN" + Environment.NewLine
                             + "INSERT INTO " + TableName + " (" + InsertColumns + ") VALUES (" + Values + ")" + Environment.NewLine
                             + "END" + Environment.NewLine;
                                
                }
            }
            return sqlquery;
        }
        
        static public string HashDataTable(DataTable dt)
        {
            // Serialize the table
            DataContractSerializer serializer = new DataContractSerializer(typeof(DataTable));
            MemoryStream memoryStream = new MemoryStream();
            XmlWriter writer = XmlDictionaryWriter.CreateBinaryWriter(memoryStream);
            serializer.WriteObject(memoryStream, dt);
            byte[] serializedData = memoryStream.ToArray();

            // Calculte the serialized data's hash value
            //SHA1CryptoServiceProvider SHA = new SHA1CryptoServiceProvider();
            SHA512CryptoServiceProvider SHA = new SHA512CryptoServiceProvider();
            byte[] hash = SHA.ComputeHash(serializedData);

            // Convert the hash to a base 64 string
            return Convert.ToBase64String(hash);
        }

        static public void RestoreDatabase(string databaseName)
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            
            string databaseFolder = ConfigurationManager.AppSettings["DatabaseFolder"];

            string query = @"USE [master]" + "\r\n" +
                           @"ALTER DATABASE [" + databaseName + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE" + "\r\n" +
                           @"RESTORE DATABASE [" + databaseName + "] FROM  DISK = N'" + Path.Combine(databaseFolder, databaseName + ".bak") + "'\r\n" +
                           @"ALTER DATABASE [" + databaseName + "] SET MULTI_USER";
            RunQuery(query, connStr);                           
        }
        static public void ClearLogTables()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string query = "DECLARE @TableName NVARCHAR(1000)" + "\r\n" +
                               "DECLARE @SqlQuery NVARCHAR(1000)" + "\r\n" +
                               "DECLARE curTruncateLog CURSOR FOR" + "\r\n" +
                               "SELECT TABLE_SCHEMA + '.' + TABLE_NAME AS 'TableName' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%log' AND TABLE_TYPE = 'BASE TABLE'" +
                               "\r\n" +
                               "OPEN curTruncateLog" + "\r\n" +
                               "FETCH NEXT FROM curTruncateLog INTO @TableName" + "\r\n" +
                               "WHILE (@@FETCH_STATUS = 0)" + "\r\n" +
                               "BEGIN" + "\r\n" +
                               "	SET @SqlQuery = 'DELETE FROM ' + @TableName" + "\r\n" +
                               "\r\n" +
                               "	EXEC sp_executesql @SqlQuery" + "\r\n" +
                               "\r\n" +
                               "	FETCH NEXT FROM curTruncateLog INTO @TableName" + "\r\n" +
                               "END" + "\r\n" +
                               "CLOSE curTruncateLog" + "\r\n" +
                               "DEALLOCATE curTruncateLog" + "\r\n";
            RunQuery(query, connStr);
        }

        public static void ClearAllFiles()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            string baseFolder = GetFolderLocation(connStr_DWRefenece);

            foreach (string dir in Directory.GetDirectories(baseFolder))
            {
                DataHelper.ClearAllFiles(Path.Combine(baseFolder, dir));
            }
        }

        public static string GetFolderLocation(string connStr_DWRefenece)
        {
            string sqlquery = "SELECT sfp.ConfiguredValue AS 'Folder', sEn.ConfiguredValue AS 'Environment' FROM [DWReference].[dbo].[SSISConfiguration] sFP "
                           + "INNER JOIN [DWReference].[dbo].[SSISConfiguration] sEn ON sEn.[ConfigurationFilter] = 'Environment' "
                           + "WHERE sfp.[ConfigurationFilter] = 'FileDir_DWRefenceFileProcess'";

            var ds = DataHelper.GetData(sqlquery, connStr_DWRefenece, false);

            return Path.Combine(ds.Tables[0].Rows[0]["Folder"].ToString(), ds.Tables[0].Rows[0]["Environment"].ToString());
        }
        public static void ClearAllFiles(string directory)
        {
            ClearFiles(Path.Combine(directory, "Unprocessed"));
            ClearFiles(Path.Combine(directory, "Failed"));
            ClearFiles(Path.Combine(directory, "InProcess"), true);
            ClearFiles(Path.Combine(directory, "Processed"));
        }

        public static void ClearFiles(string directory, bool subFolders = false)
        {
            if (Directory.Exists(directory))
            {
                var files = Directory.GetFiles(directory);
                if (files.Count() > 0)
                {
                    foreach (var file in files)
                    {
                        File.SetAttributes(file, FileAttributes.Normal);
                        File.Delete(file);
                    }
                }
                if (subFolders)
                {
                    foreach (var dir in Directory.GetDirectories(directory))
                    {
                        Directory.Delete(dir, true);
                    }
                    
                }
            }

        }

        public static DataTable getExeclData(string fullFileNamePath, string sheetName)
        {
            var eReader = new ExcelHelper();
            eReader.FileName = fullFileNamePath;
            eReader.SetConnectionString();
            return eReader.ReadExcelSheet(sheetName, true);
        }
    }
}
