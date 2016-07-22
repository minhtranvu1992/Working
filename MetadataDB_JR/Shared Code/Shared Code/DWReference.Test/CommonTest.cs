using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DWReferenceHelper;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace DWReference.Test
{
    [TestClass]
    public class CommonTest
    {
        [TestMethod]
        public void ConnectionTimeOutInvalidServer()
        {

            string connStr = "Data Source=xxxxx;User ID=RegDist_UAT_ETL;Password=jash-jy-rtax;Initial Catalog=SEAAX2009BS01;Provider=SQLNCLI11.1;Persist Security Info=True;";
            var dsb = new System.Data.Common.DbConnectionStringBuilder();

            dsb.ConnectionString = connStr;
            dsb.Remove("Provider");
            connStr = dsb.ConnectionString;// + ";Connect Timeout=0";

            bool conOpenned = false;
            SqlConnection con = new SqlConnection(connStr);
            try
            {
                con.Open();
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                    conOpenned = true;
                }
            }
            catch (Exception)
            {

            }

            Assert.AreEqual(conOpenned, false);
        }

        [TestMethod]
        public void InitTests()
        {
            DataHelper.RestoreDatabase("DWReference");
            DataHelper.RestoreDatabase("DWStaging");

            string connStr = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;

            DataHelper.RunQuery("EXEC dbo.spRefreshSSISConfiguration", connStr);

            Assert.AreEqual(1, 1);
        }

        [TestMethod]
        public void EmailNotificationCheckMaxJobIdFailure()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"ETLParameters\ETLParameters1.xlsx", "ETLParameters", "ETLParameterName", connStr_DWRefenece, DataHelper.DataRecordHandling.Update);
            DataHelper.LoadExcelData(BulkPath, @"ExtractControl\SimpleLoadCheckMaxJobExtractFailure.xlsx", "ExtractControl", "ExtractControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);
            DataHelper.LoadExcelData(BulkPath, @"DeliveryControl\SimpleLoadCheckMaxJobDeliveryFailure.xlsx", "DeliveryControl", "DeliveryControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);
            DataHelper.LoadExcelData(BulkPath, @"SummaryControl\SimpleLoadCheckMaxJobSummaryFailure.xlsx", "SummaryControl", "SummaryControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var recipient = "TestRecipient@brightstarcorp.com";


            // Delete test mail
            DataHelper.RunQuery("DELETE FROM msdb.dbo.sysmail_allitems WHERE recipients='" + recipient + "'", connStr_DWRefenece);

            DataHelper.RunQuery("EXEC dbo.spSendEmailMaxJobIDChecker @EmailReceipent = '" + recipient + "' ", connStr_DWRefenece);

            string subject = string.Empty;
            string body = string.Empty;

            var ds = DataHelper.GetData("SELECT TOP 1 m.subject, m.body  FROM msdb.dbo.sysmail_allitems m WHERE recipients ='" + recipient + "' ", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                subject = ds.Tables[0].Rows[0][0].ToString();
                body = ds.Tables[0].Rows[0][1].ToString();
            }

            Assert.IsTrue(subject != string.Empty && body != string.Empty && body.Contains("ExtractControlID") && body.Contains("DeliveryControlID") && body.Contains("SummaryControlID"));
        }

        [TestMethod]
        public void EmailNotificationCheckMaxJobIdSuccess()
        {
            string connStr_DWRefenece = ConfigurationManager.ConnectionStrings["DWRefenece"].ConnectionString;
            string BulkPath = ConfigurationManager.AppSettings["DataFiles"];
            DataHelper.LoadExcelData(BulkPath, @"ETLParameters\ETLParameters1.xlsx", "ETLParameters", "ETLParameterName", connStr_DWRefenece, DataHelper.DataRecordHandling.Update);
            DataHelper.LoadExcelData(BulkPath, @"ExtractControl\SimpleLoadCheckMaxJobExtractSuccess.xlsx", "ExtractControl", "ExtractControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);
            DataHelper.LoadExcelData(BulkPath, @"DeliveryControl\SimpleLoadCheckMaxJobDeliverySuccess.xlsx", "DeliveryControl", "DeliveryControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);
            DataHelper.LoadExcelData(BulkPath, @"SummaryControl\SimpleLoadCheckMaxJobSummarySuccess.xlsx", "SummaryControl", "SummaryControlID", connStr_DWRefenece, DataHelper.DataRecordHandling.Insert | DataHelper.DataRecordHandling.Delete);

            var recipient = "TestRecipient@brightstarcorp.com";

            // Delete test mail
            DataHelper.RunQuery("DELETE FROM msdb.dbo.sysmail_allitems WHERE recipients='" + recipient + "'", connStr_DWRefenece);

            DataHelper.RunQuery("EXEC dbo.spSendEmailMaxJobIDChecker @EmailReceipent = '" + recipient + "' ", connStr_DWRefenece);

            string subject = string.Empty;
            string body = string.Empty;

            var ds = DataHelper.GetData("SELECT TOP 1 m.subject, m.body  FROM msdb.dbo.sysmail_allitems m WHERE recipients ='" + recipient + "'", connStr_DWRefenece);
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                subject = ds.Tables[0].Rows[0][0].ToString();
                body = ds.Tables[0].Rows[0][1].ToString();
            }

            Assert.IsTrue(subject == string.Empty && body == string.Empty);

        }
    }
}
