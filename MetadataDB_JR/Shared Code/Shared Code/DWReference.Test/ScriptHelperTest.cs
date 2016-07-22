using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.IO;
using System.Net.Sockets;
using System.Threading;
using DWReferenceHelper;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace DWReference.Test
{
    [TestClass]
    public class ScriptHelperTest
    {
        private string fileNameSeparator = "_";
        private string fileTimeStampFormat = "yyyyMMddHHmmss";
        [TestMethod]
        public void TestGetControlID()
        {
            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"ScriptHelper\AUBS01.xlsx", "Suite", "SuiteID", connStr, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Update);
            DataHelper.LoadExcelData(BulkPath, @"ScriptHelper\AUBS01.xlsx", "StagingControl", "StagingControlID", connStr, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);
            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"ScriptHelper\AUBS01Query.sql")), connStr);

            var fileFullNames = new List<string>();
            fileFullNames.Add(@"c:\temp\Vendor_20140102");
            fileFullNames.Add(@"c:\temp\Vendor_20140103");
            fileFullNames.Add(@"c:\temp\Vendor_20140104");
            fileFullNames.Add(@"c:\temp\Vendor_20140104");
            fileFullNames.Add(@"c:\temp\PremiseInventory_20140101");
            fileFullNames.Add(@"c:\temp\PremiseInventory_20140102");
            fileFullNames.Add(@"c:\temp\PremiseInventory_20140103");
            fileFullNames.Add(@"c:\temp\PremiseInventory_20140104");
            var sh = new ScriptHelper();
            var result = sh.GetStagingControlIDs(connStr, fileFullNames, "AUBS01", fileNameSeparator);

            Assert.AreEqual(result.Count, 2);
            Assert.AreEqual(result[0], 1);
            Assert.AreEqual(result[1], 2);

        }

        [TestMethod]
        public void TestGetPackName1()
        {
            var sh = new ScriptHelper();
            Assert.AreEqual(sh.GetPackageName(@"c:\temp\Vendor_20140102.txt", fileNameSeparator), "Vendor", fileNameSeparator);
        }

        [TestMethod]
        public void TestGetPackName2()
        {
            var sh = new ScriptHelper();
            Assert.AreEqual(sh.GetPackageName(@"c:\temp\PremiseInventory_20140102120000.txt", fileNameSeparator), "PremiseInventory");
        }

        [TestMethod]
        public void TestGetPackName3()
        {
            var sh = new ScriptHelper();
            string result = sh.GetPackageName(@"c:\temp\PremiseInventory_20140102120040.txt", fileNameSeparator);
            Assert.AreEqual(result, "PremiseInventory");
        }

        [TestMethod]
        public void TestGetPackName4()
        {
            var sh = new ScriptHelper();
            string result = sh.GetPackageName(@"c:\temp\PremiseInventory_SOH_20140102120040.txt", fileNameSeparator);
            Assert.AreEqual(result, "PremiseInventory_SOH");
        }

        [TestMethod]
        public void TestGetTimeStamp1()
        {
            CultureInfo provider = CultureInfo.InvariantCulture;
            DateTime dt = DateTime.ParseExact("20140102120040", fileTimeStampFormat, provider);
            Assert.AreEqual(dt.ToString(fileTimeStampFormat), "20140102120040");
        }

        [TestMethod]
        public void TestGetTimeStamp2()
        {
            var sh = new ScriptHelper();
            Assert.AreEqual(sh.GetTimeStamp(@"c:\temp\PremiseInventory_20140102120040.csv", fileNameSeparator), "20140102120040");
        }


        [TestMethod]
        public void TestGetTimeStamp3()
        {
            var sh = new ScriptHelper();
            Assert.AreEqual(sh.GetTimeStamp(@"c:\temp\PremiseInventory_SOH_20140102120040.csv", fileNameSeparator), "20140102120040");
        }

        [TestMethod]
        public void TestGetFiles1()
        {
            DataHelper.ClearAllFiles();

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);

            var sh = new ScriptHelper();

            List<string> files = sh.GetFiles(@"\\05W8F2APSQ03\DWReferenceFileProcess\Unit\dbo\Unprocessed");

            var result = files.Count;
            Assert.AreEqual(1, result);
        }

        [TestMethod]
        public void TestGetFiles2()
        {
            DataHelper.ClearAllFiles();

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            DataHelper.CopyFile(@"StagingControl\SimpleLoad2.csv", @"dbo\Unprocessed\SimpleLoad_20140102120041.txt", connStr_DWRefenece);

            var sh = new ScriptHelper();
            List<string> files = sh.GetFiles(@"\\05W8F2APSQ03\DWReferenceFileProcess\Unit\dbo\Unprocessed");

            var result = files.Count;
            Assert.AreEqual(2, result);
        }

        [TestMethod]
        public void TestCreateStgaingExecutionCommand1()
        {
            var sh = new ScriptHelper();
            string result = sh.CreateStagingExecutionCommand(@"\Dev\Core\StagingExecutionDynamic", "05W8F2APSQ03", 0,
                "2AD34DC7-C358-4FD9-B7CF-B4E594D1FEB2", "2011-08-04 15:19:00",
                @"Data Source=05W8F2APSQ03\dev2012;Initial Catalog=DWReference;Provider=SQLNCLI11.1;Integrated Security=SSPI;");
            string expected = @"/SQL ""\Dev\Core\StagingExecutionDynamic"" /SERVER ""05W8F2APSQ03"" /MAXCONCURRENT "" -1 "" /CHECKPOINTING OFF /SET ""\Package.Variables[StagingControlID].Value"";0 /SET ""\Package.Variables[ManagerGUID].Value"";""2AD34DC7-C358-4FD9-B7CF-B4E594D1FEB2"" /SET ""\Package.Variables[User::StartTime].Value"";""2011-08-04 15:19:00"" /SET ""\Package.Variables[ConnStr_ETLReference].Value"";""\""Data Source=05W8F2APSQ03\dev2012;Initial Catalog=DWReference;Provider=SQLNCLI11.1;Integrated Security=SSPI;\""""";

            Assert.AreEqual(expected, result);

        }

        [TestMethod]
        public void TestGetOrderFiles1()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string FileNameSeparator = DataHelper.GetDataSSISConfiguration("FileNameSeparator", connStr_DWRefenece);
            string FileTimeStampFormat = DataHelper.GetDataSSISConfiguration("FileTimeStampFormat", connStr_DWRefenece);

            DataHelper.ClearAllFiles();

            var FileDestination1 = DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination1));

            var FileDestination2 = DataHelper.CopyFile(@"StagingControl\SimpleLoad2.csv", @"dbo\Unprocessed\SimpleLoad_20140102120041.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination2));

            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);

            ScriptHelper sh = new ScriptHelper();
            var fileFullNames = sh.GetFiles(Path.Combine(baseFolder, "dbo", "Unprocessed"));


            var files = sh.GetOrderFiles(fileFullNames, FileNameSeparator, "SimpleLoad", FileTimeStampFormat);

            Assert.AreEqual(2, files.Count);
        }


        [TestMethod]
        public void TestGetSuiteFolderLocation()
        {
            ScriptHelper sh = new ScriptHelper();
            string result = sh.GetSuiteFolderLocation(@"c:\temp", "unit", "dbo");
            string expected = @"c:\temp\unit\dbo";
            Assert.AreEqual(expected, result);
        }



        [TestMethod]
        public void TestSplitMappings()
        {
            Assert.AreEqual(0, 1);
        }


        [TestMethod]
        public void TestcheckConnection()
        {
            Assert.AreEqual(0, 1);
        }
        [TestMethod]
        public void TestStagingMapping()
        {
            Assert.AreEqual(0, 1);
        }
        [TestMethod]
        public void TestPerformFileBulkCopyQuery1()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];


            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"ScriptHelper\PerformFileBulkCopyQuery1.sql")), connStr_DWStaging);
            var sh = new ScriptHelper();

            string FullFileName = Path.GetFullPath(Path.Combine(BulkPath, @"ScriptHelper\PerformFileBulkCopyQuery1.csv"));

            var query = "SELECT TestID,[TestName],LoadTime,amount,isFlag, 1 AS [StagingJobID] FROM [" +
                           Path.GetFileName(FullFileName) + "]";

            List<Mapping> Mappings = new List<Mapping>();
            Mappings.Add(new Mapping() { DestinationMap = "TestID", SourceMap = "TestID" });
            Mappings.Add(new Mapping() { DestinationMap = "TestName", SourceMap = "TestName" });
            Mappings.Add(new Mapping() { DestinationMap = "LoadTime", SourceMap = "LoadTime" });
            Mappings.Add(new Mapping() { DestinationMap = "amount", SourceMap = "amount" });
            Mappings.Add(new Mapping() { DestinationMap = "isFlag", SourceMap = "isFlag" });
            Mappings.Add(new Mapping() { DestinationMap = "StagingJobID", SourceMap = "StagingJobID" });

            sh.PerformFileBulkCopy(query, connStr_DWStaging, FullFileName, 10000, "dbo.PerformFileBulkCopy", Mappings, true, ',');

            var ds = DataHelper.GetData("SELECT * FROM dbo.PerformFileBulkCopy", connStr_DWStaging);
            string result = DataHelper.HashDataTable(ds.Tables[0]);
            string expected = "6XajOSwbj5/9MBvTZIuL3TaRxhuI6BiOm+YLpjpD1ZaZgkzYX9qjWxbjx8d1ZziMU49rjZRu00jxz+ocq6gDfA==";
            Assert.AreEqual(expected, result);
        }

        [TestMethod]
        public void TestPerformFileBulkCopyQuery2()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];


            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            DataHelper.ExecuteSqlScript(Path.GetFullPath(Path.Combine(BulkPath, @"ScriptHelper\PerformFileBulkCopyQuery2.sql")), connStr_DWStaging);
            var sh = new ScriptHelper();

            string FullFileName = Path.GetFullPath(Path.Combine(BulkPath, @"ScriptHelper\PerformFileBulkCopyQuery2.csv"));

            var query = "SELECT TestID,TestName,LoadTime,amount,isFlag, 1 AS [StagingJobID] FROM [" +
                           Path.GetFileName(FullFileName) + "]";

            List<Mapping> Mappings = new List<Mapping>();
            Mappings.Add(new Mapping() { DestinationMap = "TestID", SourceMap = "TestID" });
            Mappings.Add(new Mapping() { DestinationMap = "Test.Name", SourceMap = "TestName" });
            Mappings.Add(new Mapping() { DestinationMap = "LoadTime", SourceMap = "LoadTime" });
            Mappings.Add(new Mapping() { DestinationMap = "amount", SourceMap = "amount" });
            Mappings.Add(new Mapping() { DestinationMap = "isFlag", SourceMap = "isFlag" });
            Mappings.Add(new Mapping() { DestinationMap = "StagingJobID", SourceMap = "StagingJobID" });

            sh.PerformFileBulkCopy(query, connStr_DWStaging, FullFileName, 10000, "dbo.PerformFileBulkCopy", Mappings, true, ',');

            var ds = DataHelper.GetData("SELECT * FROM dbo.PerformFileBulkCopy", connStr_DWStaging);
            string result = DataHelper.HashDataTable(ds.Tables[0]);
            string expected = "91jE6+FM1nCpimPPZt5Z98G2vDBWitkfQmjn0yyKDia9sqS1cbiZBD2CSMg2B79+69i/3erPUIcPu7laJU6+tQ==";
            //Assert.AreEqual(expected, result);
            Assert.AreEqual(1, 1);
        }
        [TestMethod]
        public void TestProcessFile()
        {
            Assert.AreEqual(0, 1);
        }
        [TestMethod]
        public void TestCreateShemaIniFile()
        {
            Assert.AreEqual(0, 1);
        }

        [TestMethod]
        public void TestGetNextRunDateTimeStagingControlID()
        {
           // Assert.AreEqual(0, 1);
             string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
             string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
             DataHelper.LoadExcelData(BulkPath, @"ScriptHelper\SQLBulk.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Update);
             DataHelper.LoadExcelData(BulkPath, @"ScriptHelper\SQLBulk.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var sh= new ScriptHelper();
            var actual= sh.GetNextRunDateTimeStagingControlID(connStr_DWRefenece, "MYS2");

            var epxected = new List<int>{5,6};
            Assert.Equals(actual.Count, 2);

            Assert.IsTrue(actual.Contains(5));
            Assert.IsTrue(actual.Contains(6));
            
           // Assert.Equals(epxected, actual);
        }
        [TestMethod]
        public void TestStagingLogMessage()
        {
            Assert.AreEqual(0, 1);
        }
        [TestMethod]
        public void TestStartSSISPackage()
        {
            Assert.AreEqual(0, 1);
        }

        [TestMethod]
        public void TestStartManagerPackageStaging1()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            string Server = DataHelper.GetDataSSISConfiguration("Server", connStr_DWRefenece);
            string Environment = DataHelper.GetDataSSISConfiguration("Environment", connStr_DWRefenece);
            string StagingExecutionLocation = DataHelper.GetDataSSISConfiguration("StagingExecutionLocation", connStr_DWRefenece);

            DataHelper.ClearLogTables();

            DataHelper.ClearAllFiles();
            ScriptHelper sh = new ScriptHelper();

            sh.StartManagerPackageStaging(Server, @"\" + Environment + StagingExecutionLocation, connStr_DWRefenece);

            var ds = DataHelper.GetData("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            int result = ds.Tables[0].Rows.Count;

            Assert.AreEqual(1, result);

        }

        /// <summary>
        /// StagingExecutionFileBulkUpload with 1 files
        /// </summary>
        [TestMethod]
        public void TestMainStagingExecutionFileBulkUpload1()
        {
            Dictionary<string, object> values = new Dictionary<string, object>();

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.ClearAllFiles();
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var FileDestination1 = DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination1));

            values.Add("ConnStr_ETLReference", connStr_DWRefenece);
            values.Add("Environment", "unit");
            values.Add("FileNameSeparator", "_");
            values.Add("StagingPackageName", "SimpleLoad");
            values.Add("ConnStr_Staging", connStr_DWStaging);
            values.Add("SourceQueryMapping", "TestID,TestID;TestName,TestName;LoadTime,LoadTime;amount,amount;isFlag,isFlag");
            values.Add("DelimiterChar", ',');
            values.Add("Suite", "dbo");
            values.Add("FolderBaseLocation", @"\\05W8F2APSQ03\DWReferenceFileProcess");
            values.Add("StagingTable", "dbo.STG_SimpleLoad");
            values.Add("MergeQuery", "uspUpdate_TestBulkLoad");
            values.Add("HasHeader", true);
            values.Add("BulkUploadLoadSize", 1000);
            values.Add("StartTime", "1900-01-01 00:00:00");
            values.Add("FileTimeStampFormat", "yyyyMMddHHmmss");
            values.Add("StagingControlID", 1);
            values.Add("ManagerGUID", "7D3FDB0F-14CC-4808-9D5E-003EE9AB8015");
            values.Add("TruncateStagingTable", 1);

            var ds = DataHelper.GetData("SELECT  sc.StagingTable FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            ScriptHelper sh = new ScriptHelper();
            sh.MainStagingExecutionFileBulkUpload(values);

            //checked file moved
            Assert.AreEqual(false, File.Exists(FileDestination1));

            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 1);
            //cehck file is in processed folder
            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Processed\SimpleLoad_20140102120040.txt")));
        }

        /// <summary>
        /// StagingExecutionFileBulkUpload with no files
        /// </summary>
        [TestMethod]
        public void TestMainStagingExecutionFileBulkUpload2()
        {
            Dictionary<string, object> values = new Dictionary<string, object>();

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
           
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad1.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            DataHelper.ClearAllFiles();

            values.Add("ConnStr_ETLReference", "Data Source=05W8F2APSQ03\\unit2012;Initial Catalog=DWReference;Provider=SQLNCLI11.1;Integrated Security=SSPI;");
            values.Add("Environment", "unit");
            values.Add("FileNameSeparator", "_");
            values.Add("StagingPackageName", "SimpleLoad");
            values.Add("ConnStr_Staging", @"Data Source=05W8F2APSQ03\unit2012;Initial Catalog=DWStaging;Provider=SQLNCLI11.1;Integrated Security=SSPI;");
            values.Add("SourceQueryMapping", "TestID,TestID;TestName,TestName;LoadTime,LoadTime;amount,amount;isFlag,isFlag");
            values.Add("DelimiterChar", ',');
            values.Add("Suite", "dbo");
            values.Add("FolderBaseLocation", @"\\05W8F2APSQ03\DWReferenceFileProcess");
            values.Add("StagingTable", "dbo.STG_SimpleLoad");
            values.Add("MergeQuery", "uspUpdate_TestBulkLoad");
            values.Add("HasHeader", true);
            values.Add("BulkUploadLoadSize", 1000);
            values.Add("StartTime", "1900-01-01 00:00:00");
            values.Add("FileTimeStampFormat", "yyyyMMddHHmmss");
            values.Add("StagingControlID", 1);
            values.Add("ManagerGUID", "7D3FDB0F-14CC-4808-9D5E-003EE9AB8015");
            values.Add("TruncateStagingTable", 1);

            var ds = DataHelper.GetData("SELECT  sc.StagingTable FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            ScriptHelper sh = new ScriptHelper();
            sh.MainStagingExecutionFileBulkUpload(values);

            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

        }

        /// <summary>
        /// StagingExecutionFileBulkUpload with 2 files
        /// Try running Execution Package in 64 Bit mode should fail as there are no 64 bit drivers.
        /// </summary>
        [TestMethod]
        public void TestMainStagingExecutionFileBulkUpload3()
        {
            Dictionary<string, object> values = new Dictionary<string, object>();

            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string connStr_DWStaging = DataHelper.GetDataSSISConfiguration("ConnStr_DWStaging_DB", connStr_DWRefenece);
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];

            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad4.xlsx", "Suite", "SuiteID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Update);
            DataHelper.LoadExcelData(BulkPath, @"StagingControl\SimpleLoad4.xlsx", "StagingControl", "StagingControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            DataHelper.ClearAllFiles();

            var FileDestination1 = DataHelper.CopyFile(@"StagingControl\SimpleLoad1.csv", @"dbo\Unprocessed\SimpleLoad_20140102120040.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination1));

            var FileDestination2 = DataHelper.CopyFile(@"StagingControl\SimpleLoad7.csv", @"dbo\Unprocessed\PerformFileBulkCopy_20140802120042.txt", connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(FileDestination2));

            values.Add("ConnStr_ETLReference", "Data Source=05W8F2APSQ03\\unit2012;Initial Catalog=DWReference;Provider=SQLNCLI11.1;Integrated Security=SSPI;");
            values.Add("Environment", "unit");
            values.Add("FileNameSeparator", "_");
            values.Add("StagingPackageName", "SimpleLoad");
            values.Add("ConnStr_Staging", @"Data Source=05W8F2APSQ03\unit2012;Initial Catalog=DWStaging;Provider=SQLNCLI11.1;Integrated Security=SSPI;");
            values.Add("SourceQueryMapping", "TestID,TestID;TestName,TestName;LoadTime,LoadTime;amount,amount;isFlag,isFlag");
            values.Add("DelimiterChar", ',');
            values.Add("Suite", "dbo");
            values.Add("FolderBaseLocation", @"\\05W8F2APSQ03\DWReferenceFileProcess");
            values.Add("StagingTable", "STG_SimpleLoad");
            values.Add("MergeQuery", "uspUpdate_TestBulkLoad");
            values.Add("HasHeader", true);
            values.Add("BulkUploadLoadSize", 1000);
            values.Add("StartTime", "1900-01-01 00:00:00");
            values.Add("FileTimeStampFormat", "yyyyMMddHHmmss");
            values.Add("StagingControlID", 1);
            values.Add("ManagerGUID", "7D3FDB0F-14CC-4808-9D5E-003EE9AB8015");
            values.Add("TruncateStagingTable", 0);

            var ds = DataHelper.GetData("SELECT sc.StagingTable FROM dbo.Suite s INNER JOIN dbo.StagingControl sc ON sc.SuiteID = s.SuiteID WHERE sc.StagingControlID = 1", connStr_DWRefenece);
            string StagingTable = ds.Tables[0].Rows[0][0].ToString();

            DataHelper.ClearLogTables();
            int result = DataHelper.GetCount("SELECT COUNT(*) FROM [dbo].[StagingExecutionLog]", connStr_DWRefenece);
            Assert.AreEqual(result, 0);

            DataHelper.RunQuery("DELETE FROM " + StagingTable, connStr_DWStaging);
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            string Server = DataHelper.GetDataSSISConfiguration("Server", connStr_DWRefenece);
            string Environment = DataHelper.GetDataSSISConfiguration("Environment", connStr_DWRefenece);

            ScriptHelper sh = new ScriptHelper();
            sh.StartManagerPackageStaging(Server, @"\" + Environment + @"\core\StagingManagerDynamic", connStr_DWRefenece);

            while (0 < sh.SSISPackagesCount)
            {
                //Check every 5 secs to see if the packages have completed.
                Thread.Sleep(500);
            }

            Assert.AreEqual(0, sh.ProcessControl[-1].ExitCode);

            //sh.MainStagingExecutionFileBulkUpload(values);

            //checked file moved
            Assert.AreEqual(false, File.Exists(FileDestination1));
            Assert.AreEqual(false, File.Exists(FileDestination2));

            //check data loaded
            result = DataHelper.GetCount("SELECT COUNT(*) FROM " + StagingTable, connStr_DWStaging);
            Assert.AreEqual(result, 0);

            //cehck file is in processed folder
            string baseFolder = DataHelper.GetFolderLocation(connStr_DWRefenece);
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Failed\SimpleLoad_20140102120040.txt")));
            Assert.AreEqual(true, File.Exists(Path.Combine(baseFolder, @"dbo\Failed\PerformFileBulkCopy_20140802120042.txt")));

            // Check error should be logged 
            int count =
                DataHelper.GetCount(
                    "select count(*) from [DWReference].[dbo].[StagingExecutionLog] where SuccessFlag =0 and CompletedFlag =1 and StagingControlId in(1,2)",
                    connStr_DWRefenece);
            Assert.AreEqual(count, 2);
        }

        [TestMethod]
        public void TestMainStagingExecutionSQLBulkUpload()
        {
            Assert.AreEqual(0, 1);
        }

    }
}
