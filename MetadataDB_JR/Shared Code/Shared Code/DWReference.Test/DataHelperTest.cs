using System;
using System.Data;
using System.Text;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace DWReference.Test
{
    /// <summary>
    /// Summary description for DataHelperTest
    /// </summary>
    [TestClass]
    public class DataHelperTest
    {
        [TestMethod]
        public void buildUpsertCommandSimpleTest1()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update);
            Assert.AreEqual("","");
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest2()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update);
            Assert.AreEqual("UPDATE TestTable SET TestName = 'TestProduct' WHERE TestID = '10'" + Environment.NewLine, result);
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest3()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            dt.Columns.Add("Flag", typeof(bool));
            dt.Columns.Add("NullCol", typeof(bool));
            dt.Columns.Add("DBNullCol", typeof(bool));
            dt.Columns.Add("loadTime", typeof(DateTime));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dr["Flag"] = false;
            dr["DBNullCol"] = DBNull.Value;
            dr["loadTime"] = new DateTime(2014, 12, 14, 12, 15, 0);
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update);
            string expectedResult =
                "UPDATE TestTable SET TestName = 'TestProduct', Flag = 'False', NullCol = NULL, DBNullCol = NULL, loadTime = '2014-12-14 12:15:00' WHERE TestID = '10'" +
                Environment.NewLine;
            Assert.AreEqual(expectedResult, result);
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest4()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Insert);
            Assert.AreEqual("", "");
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest5()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Insert);

            string expectResult = "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '10')" + Environment.NewLine
                             + "BEGIN" + Environment.NewLine
                             + "INSERT INTO TestTable (TestID, TestName) VALUES ('10', 'TestProduct')" + Environment.NewLine
                             + "END" + Environment.NewLine;


            Assert.AreEqual(expectResult, result);
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest6()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            dt.Columns.Add("Flag", typeof(bool));
            dt.Columns.Add("NullCol", typeof(bool));
            dt.Columns.Add("DBNullCol", typeof(bool));
            dt.Columns.Add("loadTime", typeof(DateTime));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dr["Flag"] = false;
            dr["DBNullCol"] = DBNull.Value;
            dr["loadTime"] = new DateTime(2014, 12, 14, 12, 15, 0);
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Insert);

            string expectedResult = "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '10')" + Environment.NewLine
                            + "BEGIN" + Environment.NewLine
                            + "INSERT INTO TestTable (TestID, TestName, Flag, NullCol, DBNullCol, loadTime) VALUES ('10', 'TestProduct', 'False', NULL, NULL, '2014-12-14 12:15:00')" + Environment.NewLine
                            + "END" + Environment.NewLine;

            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandSimpleTest7()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update);
            Assert.AreEqual("", "");
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest8()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Delete);
            string expectedResult = "DELETE FROM TestTable WHERE TestID = '10'" + Environment.NewLine;
            Assert.AreEqual(expectedResult, result);
        }
        [TestMethod]
        public void buildUpsertCommandSimpleTest9()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            dt.Columns.Add("Flag", typeof(bool));
            dt.Columns.Add("NullCol", typeof(bool));
            dt.Columns.Add("DBNullCol", typeof(bool));
            dt.Columns.Add("loadTime", typeof(DateTime));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dr["Flag"] = false;
            dr["DBNullCol"] = DBNull.Value;
            dr["loadTime"] = new DateTime(2014, 12, 14, 12, 15, 0);
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Delete);
            string expectedResult = "DELETE FROM TestTable WHERE TestID = '10'" + Environment.NewLine;
            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandComplexTest1()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update | DataHelper.DataRecordHandling.Delete);
            string expectedResult = "DELETE FROM TestTable WHERE TestID = '10'" + Environment.NewLine
                                    + "UPDATE TestTable SET TestName = 'TestProduct' WHERE TestID = '10'" +
                                    Environment.NewLine;
            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandComplexTest2()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update | DataHelper.DataRecordHandling.Delete | DataHelper.DataRecordHandling.Insert);
            string expectedResult = "DELETE FROM TestTable WHERE TestID = '10'" + Environment.NewLine
                                    + "UPDATE TestTable SET TestName = 'TestProduct' WHERE TestID = '10'" + Environment.NewLine
                                    + "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '10')" + Environment.NewLine
                                    + "BEGIN" + Environment.NewLine
                                    + "INSERT INTO TestTable (TestID, TestName) VALUES ('10', 'TestProduct')" + Environment.NewLine
                                    + "END" + Environment.NewLine;

            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandComplexTest3()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            dr = dt.NewRow();
            dr["TestID"] = 12;
            dr["TestName"] = "TestProduct1";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update);
            string expectedResult = "UPDATE TestTable SET TestName = 'TestProduct' WHERE TestID = '10'" + Environment.NewLine
                                    + "UPDATE TestTable SET TestName = 'TestProduct1' WHERE TestID = '12'" + Environment.NewLine;
                                  
            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandComplexTest4()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            dr = dt.NewRow();
            dr["TestID"] = 12;
            dr["TestName"] = "TestProduct1";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Delete);
            string expectedResult = "DELETE FROM TestTable WHERE TestID = '10'" + Environment.NewLine
                                    + "DELETE FROM TestTable WHERE TestID = '12'" + Environment.NewLine;
                                    
            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandComplexTest5()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            dr = dt.NewRow();
            dr["TestID"] = 12;
            dr["TestName"] = "TestProduct1";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Insert);
            string expectedResult = "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '10')" + Environment.NewLine
                                    + "BEGIN" + Environment.NewLine
                                    + "INSERT INTO TestTable (TestID, TestName) VALUES ('10', 'TestProduct')" + Environment.NewLine
                                    + "END" + Environment.NewLine
                                    + "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '12')" + Environment.NewLine
                                    + "BEGIN" + Environment.NewLine
                                    + "INSERT INTO TestTable (TestID, TestName) VALUES ('12', 'TestProduct1')" + Environment.NewLine
                                    + "END" + Environment.NewLine;
                
            Assert.AreEqual(expectedResult, result);
        }

        [TestMethod]
        public void buildUpsertCommandComplexTest6()
        {
            DataHelper dh = new DataHelper();
            var dt = new DataTable();
            dt.Columns.Add("TestID", typeof(int));
            dt.Columns.Add("TestName", typeof(string));
            var dr = dt.NewRow();
            dr["TestID"] = 10;
            dr["TestName"] = "TestProduct";
            dt.Rows.Add(dr);

            dr = dt.NewRow();
            dr["TestID"] = 12;
            dr["TestName"] = "TestProduct1";
            dt.Rows.Add(dr);

            string result = DataHelper.buildUpsertCommand(dt, "TestID", "TestTable", DataHelper.DataRecordHandling.Update | DataHelper.DataRecordHandling.Delete | DataHelper.DataRecordHandling.Insert);
            string expectedResult = "DELETE FROM TestTable WHERE TestID = '10'" + Environment.NewLine
                                  + "UPDATE TestTable SET TestName = 'TestProduct' WHERE TestID = '10'" + Environment.NewLine
                                  + "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '10')" + Environment.NewLine
                                  + "BEGIN" + Environment.NewLine
                                  + "INSERT INTO TestTable (TestID, TestName) VALUES ('10', 'TestProduct')" + Environment.NewLine
                                  + "END" + Environment.NewLine
                                  + "DELETE FROM TestTable WHERE TestID = '12'" + Environment.NewLine
                                  + "UPDATE TestTable SET TestName = 'TestProduct1' WHERE TestID = '12'" + Environment.NewLine
                                  + "IF NOT EXISTS(SELECT * FROM TestTable WHERE TestID = '12')" + Environment.NewLine
                                  + "BEGIN" + Environment.NewLine
                                  + "INSERT INTO TestTable (TestID, TestName) VALUES ('12', 'TestProduct1')" + Environment.NewLine
                                  + "END" + Environment.NewLine; 
            Assert.AreEqual(expectedResult, result);
        }
    }
}
