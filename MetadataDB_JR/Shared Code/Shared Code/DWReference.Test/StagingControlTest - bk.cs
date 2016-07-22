using System;
using System.ComponentModel;
using System.Data;
using System.Threading;
using DWReferenceHelper;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;
using System.Configuration;

namespace DWReference.Test
{
    using System.Collections.Generic;
    using System.Linq;

    [TestClass]
    public class StagingControlTest
    {
        [TestMethod]
        public void CheckConnectionString()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            Assert.AreEqual(String.IsNullOrEmpty(connStr), false);
        }

        [TestMethod]
        public void GetManagerVarialbes()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            var ds = DataHelper.GetData("[dbo].[spGetStagingManagerVariables]", connStr);


            Assert.AreEqual(ds.Tables.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns.Count, 4);

            Assert.AreEqual(ds.Tables[0].Columns.Contains("Server"), true);
            Assert.AreEqual(ds.Tables[0].Columns.Contains("StagingExecutionLocation"), true);
            Assert.AreEqual(ds.Tables[0].Columns.Contains("ConnStr_msdb"), true);
            Assert.AreEqual(ds.Tables[0].Columns.Contains("FileNameSeparator"), true);

            Assert.AreEqual(ds.Tables[0].Rows.Count, 1);

            Assert.AreEqual(DataHelper.HashDataTable(ds.Tables[0]), "CzK2pwMxnrwCOBEb3YCF2uL4Eahg+SOwZPZzj/LfxlVY9dLXAVI5El9RA3UJkq8jyOz+5Yz055vKnOPai46Gog==");
        }

        [TestMethod]
        public void spGetStagingManagerFolderLocationTest1()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            var ds = DataHelper.GetData("[dbo].[spGetStagingManagerFolderLocation] @SuiteName = 'dbo'", connStr);


            Assert.AreEqual(ds.Tables.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns.Count, 4);

            Assert.AreEqual(ds.Tables[0].Columns.Contains("BaseFolder"), true);
            Assert.AreEqual(ds.Tables[0].Columns.Contains("Environment"), true);
            Assert.AreEqual(ds.Tables[0].Columns.Contains("SuiteName"), true);
            Assert.AreEqual(ds.Tables[0].Columns.Contains("Folder"), true);

            Assert.AreEqual(DataHelper.HashDataTable(ds.Tables[0]), "OxqfL9qcYwYiVhd/rWr7/4xdzSUO4MFzJwQAG04rClUzR9xSLQTJV6UL/wn3yVxfZNEccHTtcExuFS07ppFDSA==");
        }


        [TestMethod]
        public void GetFileSuites1()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.RunQuery("DELETE FROM dbo.StagingControl", connStr);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "Suite", "SuiteID", connStr, DataHelper.DataRecordHandling.Insert);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("EXEC [dbo].[spGetStagingSuites]", connStr);


            Assert.AreEqual(ds.Tables.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns[0].ColumnName, "Suite");

            Assert.AreEqual(ds.Tables[0].Rows.Count, 1);
        }

        [TestMethod]
        public void GetFileSuites2()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.RunQuery("DELETE FROM dbo.StagingControl", connStr);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad2.xlsx", "StagingControl", "StagingControlID", connStr, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("EXEC [dbo].[spGetStagingSuites]", connStr);


            Assert.AreEqual(ds.Tables.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns[0].ColumnName, "Suite");

            Assert.AreEqual(ds.Tables[0].Rows.Count, 1);
        }

        [TestMethod]
        public void GetFileSuites3()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.RunQuery("DELETE FROM dbo.StagingControl", connStr);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad3.xlsx", "StagingControl", "StagingControlID", connStr, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("EXEC [dbo].[spGetStagingSuites]", connStr);


            Assert.AreEqual(ds.Tables.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns.Count, 1);

            Assert.AreEqual(ds.Tables[0].Columns[0].ColumnName, "Suite");

            Assert.AreEqual(ds.Tables[0].Rows.Count, 2);
        }

        [TestMethod]
        public void TestspGetStagingManagerFolderLocation()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("[dbo].[spGetStagingManagerFolderLocation] @SuiteName = 'dbo'", connStr_DWRefenece, false);

            string expected = @"\\05W8F2APSQ03\DWReferenceFileProcess\unit\dbo\Unprocessed";

            Assert.AreEqual(expected, ds.Tables[0].Rows[0]["FolderLocationUprocessed"].ToString());
        }

        /// <summary>
        /// Run Sataging Manager Load 1 File
        /// </summary>
        [TestMethod]
        public void SimpleLoadFile1()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.ClearAllFiles();

            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);
            Assert.AreEqual(false, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));

            var FileDestination = DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination));

            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"StagingControl\SimpleLoadQuery.sql")), connStr_DWRefenece);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("SELECT '[' + s.SuiteName + '].[' + sc.StagingTable + ']' FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            string Server = DataHelper.GetDataSSISConfiguration("Server", connStr_DWRefenece);
            string Environment = DataHelper.GetDataSSISConfiguration("Environment", connStr_DWRefenece);


            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            ScriptHelper sh = new ScriptHelper();
            sh.StartManagerPackageStaging(Server, @"\" + Environment + @"\core\StagingManagerDynamic", connStr_DWRefenece);

            while (0 < sh.SSISPackagesCount)
            {
                //Check every 5 secs to see if the packages have completed.
                Thread.Sleep(500);
            }

            Assert.AreEqual(0, sh.ProcessControl[-1].ExitCode);

            //checked file moved
            Assert.AreEqual(false, File.Exists(FileDestination));
            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 1);
            //cehck file is in processed folder
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));
        }
        /// <summary>
        /// Run Sataging Manager Load 2 files
        /// </summary>
        [TestMethod]
        public void SimpleLoadFile2()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.ClearAllFiles();


            var FileDestination1 = DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination1));

            var FileDestination2 = DataHelper.CopyFile(@"StagingControl\SimpleLoad2.csv", @"dbo\Unprocessed\SimpleLoad_20140102120041.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination2));

            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"StagingControl\SimpleLoadQuery.sql")), connStr_DWRefenece);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("SELECT  sc.StagingTable FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            string Server = DataHelper.GetDataSSISConfiguration("Server", connStr_DWRefenece);
            string Environment = DataHelper.GetDataSSISConfiguration("Environment", connStr_DWRefenece);


            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            ScriptHelper sh = new ScriptHelper();
            sh.StartManagerPackageStaging(Server, @"\" + Environment + @"\core\StagingManagerDynamic", connStr_DWRefenece);

            while (0 < sh.SSISPackagesCount)
            {
                //Check every 5 secs to see if the packages have completed.
                Thread.Sleep(500);
            }

            Assert.AreEqual(0, sh.ProcessControl[-1].ExitCode);

            //checked file moved
            Assert.AreEqual(false, File.Exists(FileDestination1));
            Assert.AreEqual(false, File.Exists(FileDestination2));
            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 2);
            //cehck file is in processed folder
            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120041.txt")));
        }

        /// <summary>
        /// Run Sataging Manager Load 1 File. But expect an error. Check the logging to be working
        /// </summary>
        [TestMethod]
        public void SimpleLoadFile3()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.ClearAllFiles();

            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);
            Assert.AreEqual(false, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));

            var FileDestination = DataHelper.CopyFile(@"StagingControl\SimpleLoad4.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination));

            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"StagingControl\SimpleLoadQuery.sql")), connStr_DWRefenece);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad4.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad4.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("SELECT '[' + s.SuiteName + '].[' + sc.StagingTable + ']' FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            string Server = DataHelper.GetDataSSISConfiguration("Server", connStr_DWRefenece);
            string Environment = DataHelper.GetDataSSISConfiguration("Environment", connStr_DWRefenece);


            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            ScriptHelper sh = new ScriptHelper();
            sh.StartManagerPackageStaging(Server, @"\" + Environment + @"\core\StagingManagerDynamic", connStr_DWRefenece);

            while (0 < sh.SSISPackagesCount)
            {
                //Check every 5 secs to see if the packages have completed.
                Thread.Sleep(500);
            }

            Assert.AreEqual(0, sh.ProcessControl[-1].ExitCode);

            //checked file moved
            Assert.AreEqual(false, File.Exists(FileDestination));
            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 1);
            //cehck file is in processed folder
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));
        }

        /// <summary>
        /// Run Sataging Manager Load 1 File. But expect an error. Check the logging to be working
        /// </summary>
        [TestMethod]
        public void SimpleLoadSql1()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.ClearAllFiles();

            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);
            Assert.AreEqual(false, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));

            var FileDestination = DataHelper.CopyFile(@"StagingControl\SimpleLoad4.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination));

            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"StagingControl\SimpleLoadQuery.sql")), connStr_DWRefenece);

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad4.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad4.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var ds = DataHelper.GetData("SELECT '[' + s.SuiteName + '].[' + sc.StagingTable + ']' FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            string Server = DataHelper.GetDataSSISConfiguration("Server", connStr_DWRefenece);
            string Environment = DataHelper.GetDataSSISConfiguration("Environment", connStr_DWRefenece);


            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            ScriptHelper sh = new ScriptHelper();
            sh.StartManagerPackageStaging(Server, @"\" + Environment + @"\core\StagingManagerDynamic", connStr_DWRefenece);

            while (0 < sh.SSISPackagesCount)
            {
                //Check every 5 secs to see if the packages have completed.
                Thread.Sleep(500);
            }

            Assert.AreEqual(0, sh.ProcessControl[-1].ExitCode);

            //checked file moved
            Assert.AreEqual(false, File.Exists(FileDestination));
            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 1);
            //cehck file is in processed folder
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));
        }


        /// <summary>
        /// Run Check File Headers And Columns with valid flat file: SimpleLoad1.csv. Expect no error.
        /// </summary>
        [TestMethod]
        public void CheckFileHeadersAndColumns1()
        {
            bool expected = true;
            bool actual = false;
            try
            {
                string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
                string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
                string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
                DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

                DataHelper.ClearAllFiles();

                var FileDestination1 = DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
                Assert.AreEqual(true, File.Exists(FileDestination1));

                DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"StagingControl\SimpleLoadQuery.sql")), connStr_DWRefenece);

                // Get source query mapping
                string sourceQueryMapping = string.Empty;
                string stagingTable = string.Empty;
                var delimiter = new char();

                var ds = DataHelper.GetData("SELECT SourceQueryMapping, StagingTable, DelimiterChar FROM [dbo].[StagingControl] WHERE StagingControlId=1", connStr_DWRefenece);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    sourceQueryMapping = ds.Tables[0].Rows[0][0].ToString();
                    stagingTable = ds.Tables[0].Rows[0][1].ToString();
                    delimiter = Convert.ToChar(ds.Tables[0].Rows[0][2].ToString());
                }

                var sh = new ScriptHelper();
                actual = sh.CheckFileHeadersAndColumns(FileDestination1, sourceQueryMapping, stagingTable, connStr_DWStaging, delimiter);
            }
            catch (Exception ex)
            {
                actual = false;
            }

            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        /// Run Check File Headers And Columns with flat file has not existed header  (from SimpleLoad5.csv). Expect File header field is not existed error.
        /// </summary>
        [TestMethod]
        public void CheckFileHeadersAndColumnsWithNotExistedHeader()
        {
            bool expected = false;
            bool actual = true;
            try
            {
                string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
                string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
                string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
                DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

                // Get source query mapping
                string sourceQueryMapping = string.Empty;
                string stagingTable = string.Empty;
                var delimiter = new char();

                var ds = DataHelper.GetData("SELECT SourceQueryMapping, StagingTable, DelimiterChar FROM [dbo].[StagingControl] WHERE StagingControlId=1", connStr_DWRefenece);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    sourceQueryMapping = ds.Tables[0].Rows[0][0].ToString();
                    stagingTable = ds.Tables[0].Rows[0][1].ToString();
                    delimiter = Convert.ToChar(ds.Tables[0].Rows[0][2].ToString());
                }

                var sh = new ScriptHelper();
                actual = sh.CheckFileHeadersAndColumns(@"..\..\Data\StagingControl\SimpleLoad6.csv", sourceQueryMapping, stagingTable, connStr_DWStaging, delimiter);

            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("File header field is not existed"))
                {
                    actual = false;
                }
                else
                {
                    actual = true;
                }
            }

            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        /// Run Check File Headers And Columns with wrong source query mapping (from file SimpleLoad5.xlsx). Expect Sourcequerymaping is unvalid error.
        /// </summary>
        [TestMethod]
        public void CheckFileHeadersAndColumnsWithWrongSourceQueryMapping()
        {
            bool expected = false;
            bool actual = true;
            try
            {
                string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
                string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
                string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
                DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad5.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

                // Get source query mapping
                string sourceQueryMapping = string.Empty;
                string stagingTable = string.Empty;
                var delimiter = new char();

                var ds = DataHelper.GetData("SELECT SourceQueryMapping, StagingTable, DelimiterChar FROM [dbo].[StagingControl] WHERE StagingControlId=1", connStr_DWRefenece);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    sourceQueryMapping = ds.Tables[0].Rows[0][0].ToString();
                    stagingTable = ds.Tables[0].Rows[0][1].ToString();
                    delimiter = Convert.ToChar(ds.Tables[0].Rows[0][2].ToString());
                }

                var sh = new ScriptHelper();
                actual = sh.CheckFileHeadersAndColumns(@"..\..\Data\StagingControl\SimpleLoad1.csv", sourceQueryMapping, stagingTable, connStr_DWStaging, delimiter);
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("Sourcequerymaping is unvalid"))
                {
                    actual = false;
                }
                else
                {
                    actual = true;
                }
            }

            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        /// Run Check File Headers And Columns with flat file has wrong order headers (from SimpleLoad5.csv). Expect Wrong header order error.
        /// </summary>
        [TestMethod]
        public void CheckFileHeadersAndColumnsWithWrongOrderHeader()
        {
            bool expected = false;
            bool actual = true;
            try
            {
                string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
                string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
                string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
                DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

                // Get source query mapping
                string sourceQueryMapping = string.Empty;
                string stagingTable = string.Empty;
                var delimiter = new char();

                var ds = DataHelper.GetData("SELECT SourceQueryMapping, StagingTable, DelimiterChar FROM [dbo].[StagingControl] WHERE StagingControlId=1", connStr_DWRefenece);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    sourceQueryMapping = ds.Tables[0].Rows[0][0].ToString();
                    stagingTable = ds.Tables[0].Rows[0][1].ToString();
                    delimiter = Convert.ToChar(ds.Tables[0].Rows[0][2].ToString());
                }

                var sh = new ScriptHelper();
                actual = sh.CheckFileHeadersAndColumns(@"..\..\Data\StagingControl\SimpleLoad5.csv", sourceQueryMapping, stagingTable, connStr_DWStaging, delimiter);

            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("Wrong header order"))
                {
                    actual = false;
                }
                else
                {
                    actual = true;
                }
            }

            Assert.AreEqual(expected, actual);
        }


        /// <summary>
        /// Run Check Truncate Staging Table with valid TruncateStagingTable flag is true. Expect the table will be truncated.
        /// </summary>
        [TestMethod]
        public void TruncateStagingTable1()
        {
            bool expected = true;
            bool actual = false;
            try
            {
                string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
                string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
                string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
                DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

                string stagingTable = string.Empty;
                bool bTruncateStagingTable = false;
                var ds = DataHelper.GetData("SELECT StagingTable, TruncateStagingTable FROM StagingControl WHERE StagingControlID = 1", connStr_DWRefenece);
                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                {
                    stagingTable = ds.Tables[0].Rows[0][0].ToString();
                    bTruncateStagingTable = Convert.ToBoolean(ds.Tables[0].Rows[0][1]);
                }


                var dsb = new System.Data.Common.DbConnectionStringBuilder();

                dsb.ConnectionString = connStr_DWStaging;
                dsb.Remove("Provider");
                connStr_DWStaging = dsb.ConnectionString + ";Connect Timeout=0";

                var sh = new ScriptHelper();
                sh.TruncateTable(stagingTable, connStr_DWStaging, bTruncateStagingTable);


                var dsStagingTable = DataHelper.GetCount("SELECT COUNT(*) FROM " + stagingTable, connStr_DWStaging);
                actual = dsStagingTable == 0;
            }
            catch (Exception ex)
            {
                actual = false;
            }

            Assert.AreEqual(expected, actual);
        }

        [TestMethod]
        public void DuplicateProcessControl()
        {
            var duplicate = false;

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\StagingControl_DuplicateProcess.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var sh = new ScriptHelper();

            var fileNames = new List<string> { "SimpleLoad1_20140522140400", "SimpleLoad2_20140522140400" };
            var suite = "MYS2";
            var fileNameSeparator = "_";

            var FileStagingControlIds = new List<int>();
            FileStagingControlIds = sh.GetStagingControlIDs(connStr_DWRefenece, fileNames, suite, fileNameSeparator);

            var SQLStagingControlIds = new List<int>();
            SQLStagingControlIds = sh.GetNextRunDateTimeStagingControlID(connStr_DWRefenece, suite);

            duplicate = FileStagingControlIds.Any(f => SQLStagingControlIds.Contains(f)) || SQLStagingControlIds.Any(f => FileStagingControlIds.Contains(f));

            Assert.AreEqual(duplicate, false);
        }

        [TestMethod]
        public void EmailStagingMaxExpectedDurationBetweenFilesFailure()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"ETLParameters\ETLParameters1.xlsx", "ETLParameters", "ETLParameterName", connStr_DWRefenece, DataHelper.DataRecordHandling.Update);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\StagingControl_MaxExpectedDurationFailure.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var recipient = "TestRecipient@brightstarcorp.com";

            // Delete previous test mail
            DataHelper.RunQuery("DELETE FROM msdb.dbo.sysmail_allitems WHERE recipients='" + recipient + "'", connStr_DWRefenece);

            var lastErrorEmailChecker = new DateTime(2014, 5, 1);
            DataHelper.RunQuery("EXEC dbo.spSendEmailStagingMaxExpectedDurationBetweenFiles @EmailReceipent = '" + recipient + "', @LastErrorEmailChecker ='" + lastErrorEmailChecker + "' ", connStr_DWRefenece);


            string subject = string.Empty;
            string body = string.Empty;

            var ds = DataHelper.GetData("SELECT TOP 1 m.subject, m.body  FROM msdb.dbo.sysmail_allitems m WHERE recipients ='" + recipient + "' ", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                subject = ds.Tables[0].Rows[0][0].ToString();
                body = ds.Tables[0].Rows[0][1].ToString();
            }

            Assert.IsTrue(subject != string.Empty && body != string.Empty && body.Contains("Max Expected Duration Between Files"));
        }

        [TestMethod]
        public void EmailStagingMaxExpectedDurationBetweenFilesSuccess()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"ETLParameters\ETLParameters1.xlsx", "ETLParameters", "ETLParameterName", connStr_DWRefenece, DataHelper.DataRecordHandling.Update);

            // Should update StagingControl_MaxExpectedDurationSuccess.xlsx file with correct values
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\StagingControl_MaxExpectedDurationSuccess.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var recipient = "TestRecipient@brightstarcorp.com";

            // Delete previous test mail
            DataHelper.RunQuery("DELETE FROM msdb.dbo.sysmail_allitems WHERE recipients='" + recipient + "'", connStr_DWRefenece);

            DataHelper.RunQuery("UPDATE [dbo].[StagingControl] SET LastProcessedTime = DATEADD(dd,1,(getdate() + CONVERT(DATETIME,MaxExpectedDurationBetweenFiles))) WHERE StagingControlID in (1,2)", connStr_DWRefenece);


            var lastErrorEmailChecker = new DateTime(2014, 5, 1);
            DataHelper.RunQuery("EXEC dbo.spSendEmailStagingMaxExpectedDurationBetweenFiles @EmailReceipent = '" + recipient + "', @LastErrorEmailChecker ='" + lastErrorEmailChecker + "' ", connStr_DWRefenece);


            string subject = string.Empty;
            string body = string.Empty;

            var ds = DataHelper.GetData("SELECT TOP 1 m.subject, m.body  FROM msdb.dbo.sysmail_allitems m WHERE recipients ='" + recipient + "' ", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                subject = ds.Tables[0].Rows[0][0].ToString();
                body = ds.Tables[0].Rows[0][1].ToString();
            }

            Assert.IsTrue(subject == string.Empty && body == string.Empty);

        }

        /// <summary>
        /// Run dbo.spSendEmailStagingFailure with error row in SummaryExecutionLog.
        /// </summary>
        [TestMethod]
        public void TestspSendEmailStagingFailure()
        {
            //Connection String to DWReference
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            //Get Current Time
            DateTime currentTime = DateTime.Now;

            //Get ManagerGUID
            var ManagerGUID = Guid.NewGuid().ToString();

            //Insert error log
            var sh = new ScriptHelper();
            sh.StagingLogMessage(
                connStr_DWRefenece,
                        -1,
                        0,
                        1,
                        "Log Manager Error Log for StagingExecutionDynamic",
                        "Testing Message SendEmailStagingFailure",
                        0,
                        0,
                        0,
                        0,
                        "",
                        "", //Start Time
                        "",
                        "",
                        1, //Staging Control ID
                        ManagerGUID);


            string recipient = "TestRecipient@brightstarcorp.com";
            string LastErrorEmailChecker = currentTime.AddMinutes(-1).ToString("MMM dd yyyy h:mm");
            string ScheduleType = "Daily";
            // Delete previous test mail
            DataHelper.RunQuery("DELETE FROM msdb.dbo.sysmail_allitems WHERE recipients='" + recipient + "'", connStr_DWRefenece);


            //Run Store Procedure to send email
            DataHelper.GetData("[dbo].[spSendEmailStagingFailure] @EmailReceipent = '" + recipient + "', @LastErrorEmailChecker = '" + LastErrorEmailChecker + "', @ScheduleType = '" + ScheduleType + "'", connStr_DWRefenece);

            string subject = string.Empty;
            string body = string.Empty;

            // Query mail DB to see if any mail sent out
            var ds = DataHelper.GetData("SELECT TOP 1 m.subject, m.body  FROM msdb.dbo.sysmail_allitems m WHERE recipients ='" + recipient + "' ", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                subject = ds.Tables[0].Rows[0][0].ToString();
                body = ds.Tables[0].Rows[0][1].ToString();
            }

            Assert.IsTrue(subject != string.Empty && body != string.Empty && body.Contains("StagingControlID"));

        }

        [TestMethod]
        public void MovingZipFileIntoProcessed()
        {

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var sh = new ScriptHelper();
            int StagingJobID = -1;

            var ds = new DataSet();

            ds = DataHelper.GetData("exec dbo.spGetJobID @Type= 'StagingJobID' ", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                StagingJobID = Convert.ToInt32(ds.Tables[0].Rows[0][0]);
            }

            string InProcessedFileFullName = string.Empty;

            sh.SuiteFolderLocation = @"\\05W8F2APSQ03\DWReferenceFileProcess\Unit\dbo";
            sh.unProcessedFileFullName = @"\\05W8F2APSQ03\DWReferenceFileProcess\Unit\dbo\Unprocessed\SimpleLoad_20140811131052.zip";

            if (!File.Exists(sh.unProcessedFileFullName))
            {
                File.Copy(Path.GetFullPath(Path.Combine(BulkPath, @"StagingControl\SimpleLoad_20140811131052.zip")),
                    sh.unProcessedFileFullName);
            }

            // Get source query mapping
            string sourceQueryMapping = string.Empty;
            string StagingExtractTable = string.Empty;
            var DelimiterChar = new char();
            bool HasHeader = true;
            bool bTruncateStagingTable = true;
            ds = DataHelper.GetData("SELECT SourceQueryMapping, StagingTable, HasHeader, DelimiterChar, TruncateStagingTable FROM [dbo].[StagingControl] WHERE StagingControlId=1", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                sourceQueryMapping = ds.Tables[0].Rows[0][0].ToString();
                StagingExtractTable = ds.Tables[0].Rows[0][1].ToString();
                HasHeader = Convert.ToBoolean(ds.Tables[0].Rows[0][2]);
                DelimiterChar = Convert.ToChar(ds.Tables[0].Rows[0][3].ToString());
                bTruncateStagingTable = Convert.ToBoolean(ds.Tables[0].Rows[0][4]);
            }

            var Mappings = sh.SplitMappings(sourceQueryMapping);
            int BulkUploadLoadSize = 1000;

            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            dsb.ConnectionString = connStr_DWStaging;
            dsb.Remove("Provider");
            connStr_DWStaging = dsb.ConnectionString + ";Connect Timeout=0";


            InProcessedFileFullName = sh.moveFileToInProcess(sh.unProcessedFileFullName, StagingJobID, sh.SuiteFolderLocation);
            sh.TruncateTable(StagingExtractTable, connStr_DWStaging, bTruncateStagingTable);
            sh.ProcessFile(StagingJobID, InProcessedFileFullName, connStr_DWStaging, Mappings, BulkUploadLoadSize, StagingExtractTable, sh.SuiteFolderLocation, HasHeader, DelimiterChar);

            // The zip file has already moved from Unprocessed into Processed
            Assert.IsFalse(File.Exists(@"\\05W8F2APSQ03\DWReferenceFileProcess\Unit\dbo\Unprocessed\SimpleLoad_20140811131052.zip"));

            Assert.IsTrue(File.Exists(@"\\05W8F2APSQ03\DWReferenceFileProcess\Unit\dbo\Processed\SimpleLoad_20140811131052.zip"));
        }
    }
}
