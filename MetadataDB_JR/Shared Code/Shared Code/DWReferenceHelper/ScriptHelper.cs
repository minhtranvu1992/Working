using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
//This code is copied to:
//Packages_Core.StagingManagerDynamic
//Packages_Core.StagingExecutionDynamic
//and StagingHelper
//The problem is referencing the dll on all servers used. 
using System.Threading;
using Microsoft.SqlServer.Dts.Runtime;

namespace DWReferenceHelper
{
    public class ScriptHelper
    {

        #region Properties
        public int RowsInserted { get; set; }
        public int RowsDeleted { get; set; }
        public int RowsUpdated { get; set; }
        public int RowsStaged { get; set; }
        public string SuiteFolderLocation { get; set; }
        public string unProcessedFileFullName { get; set; }
        public string InProcessedFileFullName { get; set; }
        public Dictionary<int, ProcessInformation> ProcessControl = new Dictionary<int, ProcessInformation>();
        public int SSISPackagesCount = 0;

        public List<string> ORACLE = new List<string> { "OLEDB_ORACLE", "ODBC_ORACLE" };
        public List<string> SQL = new List<string> { "OLEDB", "ODBC", "OLEDB_SQL", "ODBC_SQL" };

        #endregion

        #region Staging Manager

        /// <summary>
        /// Staging Manager Process Files Task
        /// Checks if any files are to be loaded or sql extracts and run them
        /// </summary>
        /// <param name="values"></param>
        public void MainStagingManagerProcessFiles(Dictionary<string, object> values)
        {
            string Suite = values["Suite"].ToString();
            string StagingExecutionLocation = values["StagingExecutionLocation"].ToString();
            string Server = values["Server"].ToString();
            string FileNameSeparator = values["FileNameSeparator"].ToString();
            string ConnStr_ETLReference = values["ConnStr_ETLReference"].ToString();
            string ExecutionInstanceGUID = values["ExecutionInstanceGUID"].ToString();
            string StartTime = values["StartTime"].ToString();

            //Process Files

            var ds = GetData(ConnStr_ETLReference, "[dbo].[spGetStagingManagerFolderLocation] @SuiteName = '" + Suite + "'");



            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                string FolderLocationUprocessed = Path.Combine(dr["BaseFolder"].ToString(),
                                                               dr["Environment"].ToString(),
                                                               dr["SuiteName"].ToString(),
                                                               dr["Folder"].ToString());
                var files = GetFiles(FolderLocationUprocessed);

                if (files != null && files.Count > 0)
                {
                    foreach (int stagingControlID in GetStagingControlIDs(ConnStr_ETLReference, files, Suite, FileNameSeparator))
                    {
                        ds = GetData(ConnStr_ETLReference, "SELECT RunAs32Bit FROM StagingControl WHERE StagingControlID = " + stagingControlID);
                        bool runAs32Bit = Convert.ToBoolean(ds.Tables[0].Rows[0]["RunAs32Bit"]);

                        string dtexec = GetDtexecLocation(runAs32Bit, ConnStr_ETLReference);


                        string ExecutionCommand = CreateStagingExecutionCommand(StagingExecutionLocation, Server, stagingControlID, ExecutionInstanceGUID, StartTime, ConnStr_ETLReference);

                        StagingLogMessage(ConnStr_ETLReference,
                            -1,
                            1,
                            0,
                            "Log Manager Starting StagingExecution File Extract",
                            dtexec + " " + ExecutionCommand,
                            0,
                            0,
                            0,
                            0,
                            "",
                            StartTime,
                            "",
                            "",
                            stagingControlID,
                            ExecutionInstanceGUID);

                        StartSSISPackage(ExecutionCommand, stagingControlID, runAs32Bit, ConnStr_ETLReference);
                    }
                }
            }
            //Process Data Extracts
            foreach (int stagingControlID in GetNextRunDateTimeStagingControlID(ConnStr_ETLReference, Suite))
            {
                ds = GetData(ConnStr_ETLReference, "SELECT RunAs32Bit FROM StagingControl WHERE StagingControlID = " + stagingControlID);
                bool runAs32Bit = Convert.ToBoolean(ds.Tables[0].Rows[0]["RunAs32Bit"]);

                string dtexec = GetDtexecLocation(runAs32Bit, ConnStr_ETLReference);

                string ExecutionCommand = CreateStagingExecutionCommand(StagingExecutionLocation, Server, stagingControlID, ExecutionInstanceGUID,
                    StartTime, ConnStr_ETLReference);

                StagingLogMessage(ConnStr_ETLReference,
                    -1,
                    1,
                    0,
                    "Log Manager Starting StagingExecution Data Extracts",
                    dtexec + " " + ExecutionCommand,
                    0,
                    0,
                    0,
                    0,
                    "",
                    StartTime,
                    "",
                    "",
                    stagingControlID,
                    ExecutionInstanceGUID);

                StartSSISPackage(ExecutionCommand, stagingControlID, false, ConnStr_ETLReference);
            }
            while (0 < SSISPackagesCount)
            {
                //Check every 5 secs to see if the packages have completed.
                Thread.Sleep(5000);
            }

            foreach (var value in ProcessControl.Values)
            {
                if (value.ExitCode != 0)
                {
                    StagingLogMessage(ConnStr_ETLReference,
                        -1,
                        0,
                        1,
                        "Log Manager Error Log for StagingExecutionDynamic",
                        value.OutputMessage,
                        0,
                        0,
                        0,
                        0,
                        "",
                        StartTime,
                        "",
                        "",
                        value.ControlID,
                        ExecutionInstanceGUID);
                }
            }

            StagingLogMessage(ConnStr_ETLReference,
                   -1,
                   1,
                   1,
                   "Log Manager Complete",
                   "",
                   0,
                   0,
                   0,
                   0,
                   "",
                   StartTime,
                   "",
                   "",
                   -1,
                   ExecutionInstanceGUID);
        }

        /// <summary>
        /// Staging Execution Sql BulkUpload
        /// Checks if any sql extracts need to occur and run them
        /// </summary>
        /// <param name="values"></param>
        public void MainStagingExecutionSqlBulkUpload(Dictionary<string, object> values)
        {
            string ConnStr_ETLReference = values["ConnStr_ETLReference"].ToString();
            string ConnStr_Staging = values["ConnStr_Staging"].ToString();
            string ConnStr_Source = values["ConnStr_Source"].ToString();
            int StagingJobID = Convert.ToInt32(values["StagingJobID"]);
            string SourceCmdText = values["SourceCmdText"].ToString();
            string StartTime = values["StartTime"].ToString();
            string ExtractStartTime = values["ExtractStartTime"].ToString();
            string ExtractEndTime = values["ExtractEndTime"].ToString();
            int StagingControlID = Convert.ToInt32(values["StagingControlID"]);
            string ManagerGUID = values["ManagerGUID"].ToString();
            int BulkUploadLoadSize = Convert.ToInt32(values["BulkUploadLoadSize"]);
            string StagingTable = values["StagingTable"].ToString();
            string SourceQueryMapping = values["SourceQueryMapping"].ToString();
            bool bTruncateStagingTable = Convert.ToBoolean(values["TruncateStagingTable"]);
            string SourceTypeName = values["SourceTypeName"].ToString();

            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            checkConnection(ConnStr_Staging);
            dsb.ConnectionString = ConnStr_Staging;
            dsb.Remove("Provider");
            ConnStr_Staging = dsb.ConnectionString + ";Connect Timeout=0";

            checkConnection(ConnStr_Source, SourceTypeName);
            dsb.ConnectionString = ConnStr_Source;
            dsb.Remove("Provider");

            ConnStr_Source = dsb.ConnectionString;
            if (SQL.Contains(SourceTypeName))
            {
                ConnStr_Source += ";Connect Timeout=0";
            }

            StagingLogMessage(ConnStr_ETLReference,
                StagingJobID,
                1,
                0,
                "Log StagingExecution BulkSQL evaluated Source Query",
                SourceCmdText,
                0,
                0,
                0,
                0,
                "",
                StartTime,
                ExtractStartTime,
                ExtractEndTime,
                StagingControlID,
                ManagerGUID);

            TruncateTable(StagingTable, ConnStr_Staging, bTruncateStagingTable);

            int rowsCopied = PerformSQLBulkCopy(ConnStr_Source, SourceCmdText, ConnStr_Staging, BulkUploadLoadSize, StagingTable, SourceQueryMapping, SourceTypeName);
            values.Add("rowsCopied", rowsCopied);

        }

        public void MainStagingExecutionFileBulkUpload(Dictionary<string, object> values)
        {

            string ConnStr_ETLReference = values["ConnStr_ETLReference"].ToString();
            string Environment = values["Environment"].ToString();
            string FileNameSeparator = values["FileNameSeparator"].ToString();
            string StagingPackageName = values["StagingPackageName"].ToString();
            string ConnStr_Staging = values["ConnStr_Staging"].ToString();
            string SourceQueryMapping = values["SourceQueryMapping"].ToString();
            char DelimiterChar = Convert.ToChar(values["DelimiterChar"]);
            string Suite = values["Suite"].ToString();
            string FolderBaseLocation = values["FolderBaseLocation"].ToString();
            string StagingTable = values["StagingTable"].ToString();
            string MergeQuery = values["MergeQuery"].ToString();
            bool bHasHeader = Convert.ToBoolean(values["HasHeader"]);
            int BulkUploadLoadSize = Convert.ToInt32(values["BulkUploadLoadSize"]);
            string StartTime = values["StartTime"].ToString();
            string FileTimeStampFormat = values["FileTimeStampFormat"].ToString();
            int StagingControlID = Convert.ToInt32(values["StagingControlID"]);
            string ManagerGUID = values["ManagerGUID"].ToString();
            bool bTruncateStagingTable = Convert.ToBoolean(values["TruncateStagingTable"]);

            SuiteFolderLocation = GetSuiteFolderLocation(FolderBaseLocation, Environment, Suite);

            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            checkConnection(ConnStr_Staging);
            dsb.ConnectionString = ConnStr_Staging;
            dsb.Remove("Provider");
            ConnStr_Staging = dsb.ConnectionString + ";Connect Timeout=0";

            List<Mapping> Mappings = SplitMappings(SourceQueryMapping);

            var fileFullNames = GetFiles(Path.Combine(SuiteFolderLocation, "Unprocessed"));
            var OrderFiles = GetOrderFiles(fileFullNames, FileNameSeparator, StagingPackageName, FileTimeStampFormat);

            if (OrderFiles != null)
            {
                foreach (var file in OrderFiles)
                {

                    int StagingJobID = GetStagingJobID(ConnStr_ETLReference);
                    unProcessedFileFullName = file.Value;

                    StagingLogMessage(ConnStr_ETLReference,
                        StagingJobID,
                        1,
                        0,
                        "Log StagingExecution Starting file process.",
                        "",
                        0,
                        0,
                        0,
                        0,
                        unProcessedFileFullName,
                        StartTime,
                        "",
                        "",
                        StagingControlID,
                        ManagerGUID);


                    InProcessedFileFullName = moveFileToInProcess(unProcessedFileFullName, StagingJobID, SuiteFolderLocation);

                    CheckFileHeadersAndColumns(InProcessedFileFullName, SourceQueryMapping, StagingTable, ConnStr_Staging, DelimiterChar);

                    TruncateTable(StagingTable, ConnStr_Staging, bTruncateStagingTable);

                    ProcessFile(StagingJobID, InProcessedFileFullName, ConnStr_Staging, Mappings, BulkUploadLoadSize, StagingTable, SuiteFolderLocation, bHasHeader, DelimiterChar);

                    RowCountStaged(ConnStr_Staging, StagingTable, StagingJobID);

                    MergeData(ConnStr_Staging, MergeQuery, StagingJobID);

                    StagingLogMessage(ConnStr_ETLReference,
                        StagingJobID,
                        1,
                        1,
                        "Log StagingExecution Completed files processed.",
                        "",
                        RowsInserted,
                        RowsDeleted,
                        RowsUpdated,
                        RowsStaged,
                        unProcessedFileFullName,
                        StartTime,
                        "",
                        "",
                        StagingControlID,
                        ManagerGUID);
                }
            }
            else
            {
                StagingLogMessage(ConnStr_ETLReference,
                        -1,
                        1,
                        1,
                        "Log StagingExecution Completed no files found.",
                        "",
                        0,
                        0,
                        0,
                        0,
                        "",
                        StartTime,
                        "",
                        "",
                        StagingControlID,
                        ManagerGUID);
            }

        }

        public string GetPackageName(string fileFullName, string fileNameSeparator)
        {
            string fileName = Path.GetFileName(fileFullName);

            string packageName = fileName.Substring(0, fileName.LastIndexOf(fileNameSeparator));
            return packageName;
        }

        public string GetSuiteFolderLocation(string FolderBaseLocation, string Environment, string Suite)
        {
            return Path.Combine(FolderBaseLocation, Environment, Suite);
        }

        public string CreateStagingExecutionCommand(string StagingExecutionLocation, string Server, int StagingControlID, string ManagerGUID, string StartTime,
            string ConnStr_ETLReference)
        {
            string command = "/SQL \"" + StagingExecutionLocation
                             + "\" /SERVER \"" + Server
                             + "\"" + " /MAXCONCURRENT \" -1 \" /CHECKPOINTING OFF"
                             + " /SET \"\\Package.Variables[StagingControlID].Value\";" + StagingControlID
                             + " /SET \"\\Package.Variables[ManagerGUID].Value\";\"" + ManagerGUID + "\""
                             + " /SET \"\\Package.Variables[User::StartTime].Value\";\"" + StartTime + "\""
                             + " /SET \"\\Package.Variables[ConnStr_ETLReference].Value\";\"\\\"" + ConnStr_ETLReference + "\\\"\"";
            return command;
        }

        public void StartManagerPackageStaging(string server, string packageLocationlocation, string ConnStr_ETLReference)
        {
            string command = "/SQL \"" + packageLocationlocation
                             + "\" /SERVER \"" + server + "\""
                             + " /CHECKPOINTING OFF"
                             + " /SET \"\\Package.Variables[ConnStr_ETLReference].Value\";\"\\\"" + ConnStr_ETLReference + "\\\"\""
                             + " /REPORTING E";

            StartSSISPackage(command, -1, false, ConnStr_ETLReference);
        }

        public string GetTimeStamp(string fileFullName, string fileNameSeparator)
        {
            string fileName = Path.GetFileName(fileFullName);
            int index = fileName.LastIndexOf(fileNameSeparator);
            string timeStamp = fileName.Substring((fileName.LastIndexOf(fileNameSeparator) + 1), (fileName.Length - 1 - index));
            return Path.GetFileNameWithoutExtension(timeStamp);
        }

        public List<string> GetFiles(string suiteFolderLocation)
        {
            if (Directory.Exists(suiteFolderLocation))
            {
                var files =
                    Directory.GetFiles(suiteFolderLocation, "*.*")
                        .Where(file => file.ToLower().EndsWith("csv")
                                       || file.ToLower().EndsWith("zip")
                                       || file.ToLower().EndsWith("txt"))
                        .ToList();
                return files;
            }
            return null;
        }

        public List<int> GetStagingControlIDs(string ConnStr_ETLReference, List<string> fileFullNames, String suite, string fileNameSeparator)
        {
            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            dsb.ConnectionString = ConnStr_ETLReference;
            dsb.Remove("Provider");

            string packages = "";
            foreach (var fileFullName in fileFullNames)
            {
                string packageName = GetPackageName(fileFullName, fileNameSeparator);

                if (!String.IsNullOrEmpty(packages))
                {
                    packages += ", ";
                }
                packages += "''" + packageName + "''";
            }
            if (!String.IsNullOrEmpty(packages))
            {
                string sqlQuery = "EXEC dbo.spGetStagingPackagesFile @SuiteName='" + suite + "', @Packages='" + packages + "' ";

                var ds = GetData(ConnStr_ETLReference, sqlQuery);

                if (ds.Tables.Count > 0)
                {
                    DataTable dtPackages = ds.Tables[0];
                    var query = from r in dtPackages.AsEnumerable()
                                select r.Field<int>("StagingControlID");

                    return query.ToList();

                }
            }

            return null;
        }

        public SortedList<DateTime, String> GetOrderFiles(List<string> fileFullNames, string fileNameSeparator, string PackageName, string fileTimeStampFormat)
        {
            var files = new SortedList<DateTime, String>();
            foreach (var filefullName in fileFullNames)
            {
                if (PackageName == GetPackageName(filefullName, fileNameSeparator))
                {
                    string timeStamp = GetTimeStamp(filefullName, fileNameSeparator);

                    CultureInfo provider = CultureInfo.InvariantCulture;
                    DateTime dt = DateTime.ParseExact(timeStamp, fileTimeStampFormat, provider);

                    files.Add(dt, filefullName);
                }
            }
            if (files.Count > 0)
            {
                return files;
            }
            return null;
        }

        public void RowCountStaged(string ConnStr_Staging, string StagingExtractTable, int StagingJobID)
        {
            var ds = GetData(ConnStr_Staging, "SELECT COUNT(*) AS 'RowsStaged' FROM " + StagingExtractTable + " WHERE StagingJobID = " + StagingJobID);

            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                RowsStaged = Convert.ToInt32(ds.Tables[0].Rows[0]["RowsStaged"]);
            }
            else
            {
                throw new Exception("RowCountStaged - Failed to return row count");
            }

        }

        public void MergeData(string ConnStr_Staging, string MergeQuery, int StagingJobID)
        {
            var ds = GetData(ConnStr_Staging, "EXEC " + MergeQuery + " @StagingJobID = " + StagingJobID);

            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                RowsInserted = Convert.ToInt32(ds.Tables[0].Rows[0]["RowsInserted"]);
                RowsDeleted = Convert.ToInt32(ds.Tables[0].Rows[0]["RowsDeleted"]);
                RowsUpdated = Convert.ToInt32(ds.Tables[0].Rows[0]["RowsUpdated"]);
            }
            else
            {
                throw new Exception("MergeData stored proc failed to return row count details");
            }
        }

        public int GetStagingJobID(string ConnStr_ETLReference)
        {
            var ds = GetData(ConnStr_ETLReference, "EXEC dbo.spGetJobID @Type = 'StagingJobID'");

            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                return Convert.ToInt32(ds.Tables[0].Rows[0]["JobID"]);
            }

            throw new Exception("GetStagingJobID failed to return a StagingJobID");
        }

        public void CleanUpFiles(string unProcessedFileFullName, string InProcessedFileFullName, string SuiteFolderLocation)
        {
            if (String.IsNullOrEmpty(SuiteFolderLocation) == false)
            {
                if (String.IsNullOrEmpty(InProcessedFileFullName) == false && File.Exists(InProcessedFileFullName))
                {
                    string archiveFileFullName = Path.Combine(getFailedDir(SuiteFolderLocation), Path.GetFileName(InProcessedFileFullName));
                    if (File.Exists(archiveFileFullName))
                    {
                        File.Delete(archiveFileFullName);
                    }

                    File.Move(InProcessedFileFullName, archiveFileFullName);

                    if (Directory.Exists(Path.GetDirectoryName(InProcessedFileFullName)))
                    {
                        //Todo: Delete files
                        Directory.Delete(Path.GetDirectoryName(InProcessedFileFullName), true);
                    }
                }

                if (String.IsNullOrEmpty(unProcessedFileFullName) == false && File.Exists(unProcessedFileFullName))
                {
                    string archiveFileFullName = Path.Combine(getFailedDir(SuiteFolderLocation), Path.GetFileName(unProcessedFileFullName));
                    if (File.Exists(archiveFileFullName))
                    {
                        //Todo: Delete files
                        File.Delete(archiveFileFullName);
                    }

                    File.Move(unProcessedFileFullName, Path.Combine(getFailedDir(SuiteFolderLocation), Path.GetFileName(unProcessedFileFullName)));
                }
            }
        }

        public int PerformSQLBulkCopy(string ConnStr_Source, string SourceCmdText, string ConnStr_Destination,
            int BulkUploadLoadSize, string StagingTable, string SourceQueryMapping, string SourceTypeName)
        {
            List<Mapping> Mappings = SplitMappings(SourceQueryMapping);

            return PerformSQLBulkCopy(ConnStr_Source, SourceCmdText, ConnStr_Destination, BulkUploadLoadSize,
                StagingTable, Mappings, SourceTypeName);
        }


        public int PerformFileBulkCopy(string SourceCmdText, string ConnStr_Destination, string FileFullName,
            int BulkUploadLoadSize, string DestinationTable, List<Mapping> Mappings, bool HasHeader, char DelimiterChar)
        {

            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            dsb.ConnectionString = ConnStr_Destination;
            dsb.Remove("Provider");
            ConnStr_Destination = dsb.ConnectionString + ";Connect Timeout=0";

            CreateShemaIniFile(FileFullName, Mappings, HasHeader, DelimiterChar);

            var bulkCopy = new SqlBulkCopy(ConnStr_Destination, SqlBulkCopyOptions.KeepIdentity);

            bulkCopy.BatchSize = BulkUploadLoadSize;
            bulkCopy.BulkCopyTimeout = 0;
            bulkCopy.DestinationTableName = DestinationTable;

            BulkCopyMapping(bulkCopy, Mappings);

            var connString = string.Format(
                @"Provider=Microsoft.Jet.OleDb.4.0; Data Source={0};Extended Properties=""Text;HDR=YES;FMT=Delimited""",
                Path.GetDirectoryName(FileFullName)
            );

            using (var conn = new OleDbConnection(connString))
            {
                conn.Open();

                using (OleDbCommand cmd = new OleDbCommand(SourceCmdText, conn))
                {

                    using (OleDbDataReader reader = cmd.ExecuteReader())
                    {
                        bulkCopy.WriteToServer(reader);
                    }
                }
            }
            int result = SqlBulkCopyExtension.RowsCopiedCount(bulkCopy);

            bulkCopy.Close();
            return result;
        }

        public void ProcessFile(int StagingJobID, string InProcessedFileFullName, string ConnStr_Staging, List<Mapping> Mappings, int BulkUploadLoadSize,
            string StagingExtractTable, string SuiteFolderLocation, bool HasHeader, char DelimiterChar)
        {
            string selectColumns = "";
            foreach (var mapping in Mappings)
            {
                selectColumns += mapping.OledSourceMap + ", ";
            }

            var query = "SELECT " + selectColumns + StagingJobID + " AS [StagingJobID] FROM [" +
                            Path.GetFileName(InProcessedFileFullName) + "]";

            PerformFileBulkCopy(query, ConnStr_Staging, InProcessedFileFullName, BulkUploadLoadSize, StagingExtractTable,
                Mappings, HasHeader, DelimiterChar);

            string archiveFileFullName = Path.Combine(SuiteFolderLocation, "Processed", Path.GetFileName(InProcessedFileFullName));

            if (File.Exists(archiveFileFullName))
            {
                //TODO: Fix deletion
                File.Delete(archiveFileFullName);
            }

            File.Move(InProcessedFileFullName, archiveFileFullName);

            if (Directory.Exists(Path.GetDirectoryName(InProcessedFileFullName)))
            {
                Directory.Delete(Path.GetDirectoryName(InProcessedFileFullName), true);
            }

            // Move zip file into Processed

            if (Path.GetExtension(unProcessedFileFullName).ToLower() == ".zip")
            {
                archiveFileFullName = Path.Combine(SuiteFolderLocation, "Processed", Path.GetFileName(unProcessedFileFullName));

                if (File.Exists(archiveFileFullName))
                {
                    File.Delete(archiveFileFullName);
                }
                File.Move(unProcessedFileFullName, archiveFileFullName);
            }
        }

        /// <summary>
        /// This is used to create the Schema.ini file used by the OleDbConnection. To forece column types
        /// </summary>
        /// <param name="InProcessedFileFullName"></param>
        public void CreateShemaIniFile(string FileFullName, List<Mapping> Mappings, bool HasHeader, char DelimiterChar)
        {
            StringBuilder schema = new StringBuilder();

            schema.AppendLine("[" + Path.GetFileName(FileFullName) + "]");

            if (HasHeader)
            {
                schema.AppendLine("ColNameHeader=True");
            }
            else
            {
                schema.AppendLine("ColNameHeader=False");
            }

            //Delimited Character
            switch (DelimiterChar)
            {
                case ',':
                    schema.AppendLine("Format=CSVDelimited");
                    break;
                case '\t':
                    schema.AppendLine("Format=TabDelimited");
                    break;
                default:
                    schema.AppendLine("Format=Delimited(" + DelimiterChar + ")");
                    break;
            }

            for (int i = 0; i < Mappings.Count; i++)
            {
                schema.AppendLine("col" + (i + 1).ToString() + "=" + Mappings[i].OledSourceMap + " Text");
            }

            string schemaFileName = Path.Combine(Path.GetDirectoryName(FileFullName), "Schema.ini");
            TextWriter tw = new StreamWriter(schemaFileName);
            tw.WriteLine(schema.ToString());
            tw.Close();

        }

        public string moveFileToInProcess(string unProcessedFileFullName, int StagingJobID, string SuiteFolderLocation)
        {
            string InProcessFileFullName = "";
            string InProcessDirectory = Path.Combine(SuiteFolderLocation, "InProcess", Guid.NewGuid().ToString());
            if (Path.GetExtension(unProcessedFileFullName).ToLower() == ".zip")
            {
                var zip = ZipFile.Open(unProcessedFileFullName, ZipArchiveMode.Read);

                string zippedFileName = "";
                if (zip.Entries.Count == 1)
                {
                    zippedFileName = zip.Entries[0].FullName;
                }
                else
                {
                    zip.Dispose();
                    MoveToUnProcessedToFailedDir(unProcessedFileFullName, SuiteFolderLocation, "Zip file has more than one file: ");
                }

                if (zippedFileName.Split('.').Count() > 2)
                {
                    MoveToUnProcessedToFailedDir(unProcessedFileFullName, SuiteFolderLocation, "file has to many fullstops in the name expected format *.*: ");
                }

                string newTempDir = Path.Combine(SuiteFolderLocation, Guid.NewGuid().ToString());
                Directory.CreateDirectory(newTempDir);
                zip.ExtractToDirectory(newTempDir);
                zip.Dispose();

                string extractedFilePathName = Path.Combine(newTempDir, zippedFileName);

                if (File.Exists(extractedFilePathName))
                {
                    InProcessFileFullName = Path.Combine(InProcessDirectory, StagingJobID.ToString().PadLeft(5, '0') + "_" + zippedFileName);
                    Directory.CreateDirectory(InProcessDirectory);
                    System.IO.File.Move(extractedFilePathName, InProcessFileFullName);
                    Directory.Delete(newTempDir, true);
                }
                else
                {
                    throw new Exception("Unzipped file cannot be found: " + extractedFilePathName);
                }
            }
            else
            {
                if (Path.GetFileName(unProcessedFileFullName).Split('.').Count() > 2)
                {
                    MoveToUnProcessedToFailedDir(unProcessedFileFullName, SuiteFolderLocation, "file has to many fullstops in the name expected format *.*: ");
                }

                InProcessFileFullName = Path.Combine(InProcessDirectory, Path.GetFileName(unProcessedFileFullName));
                Directory.CreateDirectory(InProcessDirectory);
                System.IO.File.Move(unProcessedFileFullName, InProcessFileFullName);
            }
            return InProcessFileFullName;
        }

        public string getFailedDir(string SuiteFolderLocation)
        {
            return Path.Combine(SuiteFolderLocation, "Failed");
        }
        public void MoveToUnProcessedToFailedDir(string unProcessedFileFullName, string SuiteFolderLocation, string ErrorMessage)
        {
            string FailedFileFullName = Path.Combine(getFailedDir(SuiteFolderLocation), Path.GetFileName(unProcessedFileFullName));

            //handle zip files
            if (File.Exists(unProcessedFileFullName))
            {
                if (File.Exists(FailedFileFullName))
                {
                    //Todo:Fix deletion
                    File.Delete(FailedFileFullName);
                }

                File.Move(unProcessedFileFullName, FailedFileFullName);
            }

            throw new Exception(ErrorMessage + unProcessedFileFullName);
        }

        public List<int> GetNextRunDateTimeStagingControlID(string ConnStr_ETLReference, string Suite)
        {
            var ds = GetData(ConnStr_ETLReference, "[dbo].[spGetStagingPackagesSql] '" + Suite + "'");

            if (ds.Tables.Count > 0)
            {
                DataTable dtPackages = ds.Tables[0];
                var query = from r in dtPackages.AsEnumerable()
                            select r.Field<int>("StagingControlID");
                return query.ToList();
            }

            return null;
        }

        public bool CheckFileHeadersAndColumns(string filename, string SourceQueryMapping, string StagingTable, string ConnStr_Staging, char Delimeter)
        {
            var schemaName = string.Empty;
            var tableName = StagingTable;

            if (StagingTable.Split('.').Count() > 1)
            {
                schemaName = StagingTable.Split('.')[0];
                tableName = StagingTable.Split('.')[1];
            }

            var query = "SELECT c.COLUMN_NAME AS column_name FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = '" + tableName + "' " + (schemaName != string.Empty ? " AND  c.TABLE_SCHEMA='" + schemaName + "'" : "");
            var columnsDs = GetData(ConnStr_Staging, query);
            List<string> listColumns = (from DataRow row in columnsDs.Tables[0].Rows select row[0].ToString()).ToList();

            var listHeaderFromFile = ReadFileHeader(filename, Delimeter);

            var Mappings = SplitMappings(SourceQueryMapping);

            // Check File Header fields should be valid fair with sourcequerymapping
            bool isHeaderValid = true;
            foreach (var header in listHeaderFromFile)
            {
                isHeaderValid = Mappings.FirstOrDefault(f => f.SourceMap == header) != null;
                if (!isHeaderValid)
                {
                    throw new Exception("File header field is not existed. File header fields: " + header + " doesn't existed in source query mapping: " + SourceQueryMapping + ". File name: " + filename + ", Staging table: " + StagingTable);
                }
            }

            // Check Columns from table should be valid fair with sourcequerymapping
            bool isColumnValid = true;

            foreach (var mapping in Mappings)
            {
                isColumnValid = listColumns.Contains(mapping.DestinationMap);
                if (!isColumnValid)
                {
                    throw new Exception("Sourcequerymaping is unvalid. Mapping: " + mapping.DestinationMap + " in source query mapping: " + SourceQueryMapping + " does not existed in table: " + StagingTable);
                }
            }

            // Check File Header fields should be in the same order and value as the sourcequerymapping
            if (listHeaderFromFile.Count > Mappings.Count)
            {
                isHeaderValid = false;
            }
            else
            {
                if (listHeaderFromFile.Where((t, i) => t != Mappings[i].SourceMap).Any())
                {
                    isHeaderValid = false;
                    throw new Exception("Wrong header order. File header fields in file: " + filename + " has order: " + GenerateListToString(listHeaderFromFile) + " is not matched to source query mapping: " + SourceQueryMapping);
                }
            }

            return isHeaderValid && isColumnValid;
        }

        public static List<string> ReadFileHeader(string filename, char delimiter)
        {
            string strHeader = string.Empty;
            var file = new StreamReader(filename);
            while ((strHeader = file.ReadLine()) != null)
            {
                break;
            }

            file.Close();
            var listHeader = new List<string>();
            if (!string.IsNullOrEmpty(strHeader))
            {
                string[] headers = strHeader.Split(delimiter);

                listHeader.AddRange(headers);
            }

            return listHeader;
        }

        public void StagingLogMessage(string ConnStr_ETLReference,
                      int StagingJobID,
                      int SuccessFlag,
                      int CompletedFlag,
                      string MessageSource,
                      string Message,
                      int RowsInserted,
                      int RowsDeleted,
                      int RowsUpdated,
                      int RowsStaged,
                      string ActualFileName,
                      string StartTime,
                      string ExtractStartTime,
                      string ExtractEndTime,
                      int StagingControlID,
                      string ManagerGUID)
        {
            string tempMessage = Message.Replace("'", "''");

            string sqlCmdLog = "[spInsertStagingExecutionLog] "
                               + "@StagingJobID = " + StagingJobID + ", "
                               + "@ManagerGUID = '" + ManagerGUID + "', "
                               + "@SuccessFlag = " + SuccessFlag + ", "
                               + "@CompletedFlag = " + CompletedFlag + ", "
                               + "@MessageSource = '" + MessageSource + "', "
                               + "@Message = '" + tempMessage + "', "
                               + "@RowsStaged = " + RowsStaged + ", "
                               + "@RowsInserted = " + RowsInserted + ", "
                               + "@RowsDeleted = " + RowsDeleted + ", "
                               + "@RowsUpdated = " + RowsUpdated + ", "
                               + "@StagingPackagePathAndName = NULL, "
                               + "@ActualFileName = '" + ActualFileName + "', "
                               + "@StartTime = '" + StartTime + "', ";

            if (String.IsNullOrEmpty(ExtractStartTime))
            {
                sqlCmdLog += "@ExtractStartTime = NULL, ";
            }
            else
            {
                sqlCmdLog += "@ExtractStartTime = '" + ExtractStartTime + "', ";
            }

            if (String.IsNullOrEmpty(ExtractStartTime))
            {
                sqlCmdLog += "@ExtractEndTime = NULL, ";
            }
            else
            {
                sqlCmdLog += "@ExtractEndTime = '" + ExtractEndTime + "', ";
            }

            sqlCmdLog += "@StagingControlID = " + StagingControlID;

            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            dsb.ConnectionString = ConnStr_ETLReference;
            dsb.Remove("Provider");
            ConnStr_ETLReference = dsb.ConnectionString;

            var SrcConn = new SqlConnection(ConnStr_ETLReference);

            var sCommand = new SqlCommand(sqlCmdLog, SrcConn);
            SrcConn.Open();
            sCommand.ExecuteNonQuery();
            SrcConn.Close();
            SrcConn.Dispose();
        }
        #endregion

        #region Extract Manager

        public void MainExtractManagerBulkUpload(Dictionary<string, object> values)
        {
            var dsb = new DbConnectionStringBuilder();
            var ConnStr_ETLReference = values["ConnStr_ETLReference"].ToString();
            var ConnStr_Destination = values["ConnStr_Destination"].ToString();
            var ConnStr_Source = values["ConnStr_Source"].ToString();
            var SourceTypeName = values["SourceTypeName"].ToString();
            var SourceCmdText = values["SourceCmdText"].ToString();
            var bTruncateExtractTable = Convert.ToBoolean(values["bTruncateExtractTable"]);
            var ExtractTable = values["ExtractTable"].ToString();
            var BulkUploadLoadSize = Convert.ToInt32(values["BulkUploadLoadSize"]);
            var SourceQueryMapping = values["SourceQueryMapping"].ToString();
            var ExtractStartTime = values["ExtractStartTime"].ToString();
            var ExtractEndTime = values["ExtractEndTime"].ToString();
            var ExtractJobID = Convert.ToInt32(values["ExtractJobID"]);
            var ExtractControlID = Convert.ToInt32(values["ExtractControlID"]);
            var ManagerGUID = values["ManagerGUID"].ToString();


            checkConnection(ConnStr_Destination);
            dsb.ConnectionString = ConnStr_Destination;
            dsb.Remove("Provider");
            ConnStr_Destination = dsb.ConnectionString + ";Connect Timeout=0";

            checkConnection(ConnStr_Source, SourceTypeName);
            dsb.ConnectionString = ConnStr_Source;
            dsb.Remove("Provider");

            ConnStr_Source = dsb.ConnectionString;
            if (SQL.Contains(SourceTypeName))
            {
                ConnStr_Source += ";Connect Timeout=0";
            }

            //This is to handle if the source query uses any paramters. All evaluted paramters
            //must be part if the readlonly collection

            string tempSourceCmdText = SourceCmdText.Replace("'", "''");

            ExtractLogMessage(ConnStr_ETLReference,
               ExtractJobID,
               1,
               0,
               "Log ExtractExecution.BulkUpload",
               tempSourceCmdText,
               0,
               "",
               null,
               ExtractStartTime,
               ExtractEndTime,
               ExtractEndTime,
               ExtractControlID,
               ManagerGUID
               );

            TruncateTable(ExtractTable, ConnStr_Destination, bTruncateExtractTable);

            int rowsCopied = PerformSQLBulkCopy(ConnStr_Source, SourceCmdText, ConnStr_Destination, BulkUploadLoadSize, ExtractTable, SourceQueryMapping, SourceTypeName);
            values.Add("rowsCopied", rowsCopied);
        }

        private void ExtractLogMessage(string ConnStr_ETLReference,
                     int ExtractJobID,
                     int SuccessFlag,
                     int CompletedFlag,
                     string MessageSource,
                     string Message,
                     int RowsExtracted,
                     string ExtractPackagePathAndName,
                     string StartTime,
                     string ExtractStartTime,
                     string ExtractEndTime,
                     string NextExtractStartTime,
                     int ExtractControlID,
                     string ManagerGUID
          )
        {
            StartTime = StartTime == null ? "NULL" : "'" + StartTime + "'";
            ExtractStartTime = ExtractStartTime == null ? "NULL" : "'" + ExtractStartTime + "'";
            ExtractEndTime = ExtractEndTime == null ? "NULL" : "'" + ExtractEndTime + "'";
            NextExtractStartTime = NextExtractStartTime == null ? "NULL" : "'" + NextExtractStartTime + "'";

            string sqlCmdLog = "[spInsertExtractExecutionLog] "
                 + "@ExtractJobID = " + ExtractJobID + ", "
                 + "@StartTime = " + StartTime + ","
                 + "@ManagerGUID = '" + ManagerGUID + "', "
                 + "@SuccessFlag = " + SuccessFlag + ", "
                 + "@CompletedFlag = " + CompletedFlag + ", "
                 + "@MessageSource = '" + MessageSource + "', "
                 + "@Message = '" + Message + "', "
                 + "@RowsExtracted = " + RowsExtracted + ", "
                 + "@ExtractStartTime = " + ExtractStartTime + ", "
                 + "@ExtractEndTime = " + ExtractEndTime + ", "
                 + "@NextExtractStartTime = " + NextExtractStartTime + ", "
                 + "@ExtractPackagePathAndName = '" + ExtractPackagePathAndName + "', "
                 + "@ExtractControlID = " + ExtractControlID;

            //string sqlCmdLog = "[spInsertExtractExecutionLog] "
            //     + "@ExtractJobID = " + ExtractJobID + ", "
            //     + "@StartTime = NULL,"
            //     + "@ManagerGUID = '" + ManagerGUID + "', "
            //     + "@SuccessFlag = 1, "
            //     + "@CompletedFlag = 0, "
            //     + "@MessageSource = 'Log ExtractExecution.BulkUpload', "
            //     + "@Message = '" + tempSourceCmdText + "', "
            //     + "@RowsExtracted = 0, "
            //     + "@ExtractStartTime = '" + ExtractEndTime + "', "
            //     + "@ExtractEndTime = '" + ExtractEndTime + "', "
            //     + "@NextExtractStartTime = '" + ExtractEndTime + "', "
            //     + "@ExtractPackagePathAndName = '', "
            //     + "@ExtractControlID = " + ExtractControlID;

            var dsb = new DbConnectionStringBuilder();

            dsb.ConnectionString = ConnStr_ETLReference;
            dsb.Remove("Provider");
            ConnStr_ETLReference = dsb.ConnectionString;

            var SrcConn = new SqlConnection(ConnStr_ETLReference);

            var sCommand = new SqlCommand(sqlCmdLog, SrcConn);
            SrcConn.Open();
            sCommand.ExecuteNonQuery();
            SrcConn.Close();
            SrcConn.Dispose();
        }

        public void StartManagerPackageExtract(string server, string packageLocationlocation, string ConnStr_ETLReference)
        {
            throw new NotImplementedException();
        }

        #endregion

        #region Delivery Manager
        public void StartManagerPackageDelivery(string server, string packageLocationlocation, string ConnStr_ETLReference)
        {
            throw new NotImplementedException();
        }
        #endregion

        #region Summary Manager

        public void StartManagerPackageSummary(string server, string packageLocationlocation, string ConnStr_ETLReference)
        {
            throw new NotImplementedException();
        }
        #endregion

        #region Common

        public int PerformSQLBulkCopy(string ConnStr_Source, string SourceCmdText, string ConnStr_Destination,
         int BulkUploadLoadSize, string DestinatonTable, List<Mapping> Mappings, string SourceTypeName)
        {

            int result = 0;
            var bulkCopy = new SqlBulkCopy(ConnStr_Destination, SqlBulkCopyOptions.KeepIdentity);

            bulkCopy.BatchSize = BulkUploadLoadSize;
            bulkCopy.BulkCopyTimeout = 0;
            bulkCopy.DestinationTableName = DestinatonTable;

            BulkCopyMapping(bulkCopy, Mappings);

            if (SQL.Contains(SourceTypeName))
            {
                var SrcConn = new SqlConnection(ConnStr_Source);
                var sCommand = new SqlCommand(SourceCmdText, SrcConn);
                sCommand.CommandTimeout = 0;

                SrcConn.Open();
                var SqlReader = sCommand.ExecuteReader();
                bulkCopy.WriteToServer(SqlReader);

                SqlReader.Close();
                SrcConn.Close();
                SrcConn.Dispose();
                result = SqlBulkCopyExtension.RowsCopiedCount(bulkCopy);
                bulkCopy.Close();
            }
           

            return result;
        }

        public List<Mapping> SplitMappings(string SourceQueryMapping)
        {
            var lMapping = new List<Mapping>();
            if ((!String.IsNullOrEmpty(SourceQueryMapping)) && SourceQueryMapping.Contains(";"))
            {
                List<string> lSourceQueryMapping = new List<string>(SourceQueryMapping.Split(';'));

                foreach (var map in lSourceQueryMapping)
                {
                    List<string> cols = new List<string>(map.Split(','));
                    if (cols.Count == 2)
                    {
                        if (String.IsNullOrEmpty(cols[0]) || String.IsNullOrEmpty(cols[1]))
                        {
                            throw new System.Exception("Bulk copy SourceQueryMapping has an invalid pair (empty string)");
                        }
                        lMapping.Add(new Mapping()
                        {
                            SourceMap = cols[0].Trim(),
                            DestinationMap = cols[1].Trim()
                        });

                    }
                    else
                    {
                        throw new System.Exception("Bulk copy SourceQueryMapping has an invalid pair (count does not match): " + map);
                    }
                }
            }
            return lMapping;
        }

        public void checkConnection(string ConnStr, string SourceTypeName = "OLEDB")
        {
            var dsb = new DbConnectionStringBuilder();

            dsb.ConnectionString = ConnStr;
            dsb.Remove("Provider");
            if (SQL.Contains(SourceTypeName))
            {

                var con = new SqlConnection(dsb.ConnectionString);
                con.Open();
                con.Close();
            }
            
        }

        public void BulkCopyMapping(SqlBulkCopy bulkCopy, List<Mapping> Mappings)
        {
            foreach (var mapping in Mappings)
            {
                var m = new SqlBulkCopyColumnMapping();

                bulkCopy.ColumnMappings.Add(new
                 SqlBulkCopyColumnMapping(mapping.OledSourceMap, mapping.DestinationMap));
            }
        }

        public string GetDtexecLocation(bool RunAs32Bit, string ConnStr_ETLReference)
        {
            var ds = GetData(ConnStr_ETLReference, "EXEC spGetDtexecLocation @RunAs32Bit='" + RunAs32Bit.ToString() + "'");

            string dtexec = ds.Tables[0].Rows[0]["LocationDtexec"].ToString();

            if (dtexec.Contains(" "))
            {
                dtexec = "\"" + dtexec + "\"";
            }
            return dtexec;
        }
        public void StartSSISPackage(string command, int ControlID, bool RunAs32Bit, string ConnStr_ETLReference)
        {
            string dtexec = GetDtexecLocation(RunAs32Bit, ConnStr_ETLReference);

            ProcessInformation p = new ProcessInformation() { ControlID = ControlID };
            ProcessControl.Add(ControlID, p);
            p.EnableRaisingEvents = true;
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.RedirectStandardError = true;
            p.Exited += p_Exited;

            p.OutputDataReceived += new DataReceivedEventHandler
            (
                delegate(object sender, DataReceivedEventArgs e)
                {
                    ((ProcessInformation)sender).OutputMessage += e.Data + Environment.NewLine;
                }
            );

            p.StartInfo.FileName = dtexec;
            p.StartInfo.Arguments = command;
            p.StartInfo.CreateNoWindow = true;

            SSISPackagesCount++;

            p.Start();
            p.BeginOutputReadLine();
        }

        void p_Exited(object sender, EventArgs e)
        {
            SSISPackagesCount--;
        }

        public string GenerateListToString(List<string> list)
        {
            string str = list.Aggregate(string.Empty, (current, item) => current + (item + ","));
            if (str.Length > 1)
            {
                str = str.Substring(0, str.Length - 1);
            }

            return str;
        }

        public DataSet GetData(string connnectionString, string sqlQuery)
        {
            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            dsb.ConnectionString = connnectionString;
            dsb.Remove("Provider");

            var ds = new DataSet();
            using (var conn = new SqlConnection(dsb.ConnectionString))
            {
                var adapter = new SqlDataAdapter(sqlQuery, conn);
                adapter.Fill(ds);
            }

            return ds;
        }

        public void TruncateTable(string Table, string ConnStr_Destination, bool bTruncateTable)
        {
            if (bTruncateTable)
            {
                var trcConn = new SqlConnection(ConnStr_Destination);

                var trcCommand = new SqlCommand("TRUNCATE TABLE " + Table, trcConn);
                trcCommand.CommandTimeout = 0;

                trcConn.Open();
                trcCommand.ExecuteNonQuery();
                trcConn.Close();
                trcConn.Dispose();
            }
        }
        #endregion

    }

    public class ProcessInformation : Process
    {
        public int ControlID { get; set; }
        public string OutputMessage { get; set; }
    }
    static class SqlBulkCopyExtension
    {
        public static int RowsCopiedCount(this SqlBulkCopy bulkCopy)
        {
            FieldInfo _rowsCopiedField = typeof(SqlBulkCopy).GetField("_rowsCopied", BindingFlags.NonPublic | BindingFlags.GetField | BindingFlags.Instance);
            return (int)_rowsCopiedField.GetValue(bulkCopy);
        }

    }
    public class Mapping
    {
        public string SourceMap { get; set; }
        public string OledSourceMap
        {
            get { return SourceMap.Replace(".", ""); }
        }
        public string DestinationMap { get; set; }
    }

}