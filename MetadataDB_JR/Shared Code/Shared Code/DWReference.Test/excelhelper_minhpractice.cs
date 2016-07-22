using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DWReference.Test
{
    class excelhelper_minhpractice
    {
        string Connectionstring;
        public string Filename { get; set; }
        List<SheetDetails> lsheet= new List<SheetDetails>();
        public List<SheetDetails> sheets
        {
            get
            {
                 return lsheet;
            }
        }
        //public string OpenExcelFile()
        //{
        //    FileName = "";
        //    OpenFileDialog fld = new OpenFileDialog();
        //    fld.Filter = "Excel|*.xls;*.xlsx";

        //    // Show open file dialog box 
        //    Nullable<bool> result = fld.ShowDialog();

        //    // Process open file dialog box results 
        //    if (result == true)
        //    {
        //        FileName = fld.FileName;

        //        SetConnectionString();

        //        GetExcelSheetNames();
        //    }
        //    return FileName;
        //}
        public void SetconnectionString()
        {
            if (System.IO.Path.GetExtension(Filename).Equals(".xls"))//for 97-03 Excel file
            {
                Connectionstring = String.Format("Provider=Microsoft.Jet.OLEDB.4.0;Data Source={0};Extended Properties=\"Excel 8.0;HDR=YES;IMEX=1;\";", Filename);
            }
            else if (System.IO.Path.GetExtension(Filename).Equals(".xlsx"))  //for 2007 Excel file
            {
                Connectionstring = String.Format("Provider=Microsoft.ACE.OLEDB.12.0;Data Source={0};Extended Properties=\"Excel 12.0;HDR=Yes;IMEX=1;\";", Filename);
            }

        }
        public List<SheetDetails> GetExcelSheetNames()
        {
            System.Data.OleDb.OleDbConnection OledbConnection = new System.Data.OleDb.OleDbConnection();
            OledbConnection.ConnectionString = Connectionstring;
            lsheet.Clear();

            try
            {
                OledbConnection.Open();
                DataTable dtSheets = OledbConnection.GetOleDbSchemaTable(System.Data.OleDb.OleDbSchemaGuid.Tables,null);
            
            foreach (DataRow drSheet in dtSheets.Rows)
            {
                if (drSheet["TABLE_NAME"].ToString().Contains("$"))//checks whether row contains '_xlnm#_FilterDatabase' or sheet name(i.e. sheet name always ends with $ sign)
                {
                    lsheet.Add(new SheetDetails(drSheet["TABLE_NAME"].ToString()));
                }
                return lsheet;
            }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                OledbConnection.Close();
            }
            return null;
        }
        public DataTable ReadExcelSheet(string SheetName, bool trim)
        {
            System.Data.OleDb.OleDbConnection OleDbConnection = new System.Data.OleDb.OleDbConnection();
            OleDbConnection.ConnectionString = Connectionstring;
            System.Data.OleDb.OleDbDataAdapter OAdapter = new System.Data.OleDb.OleDbDataAdapter(String.Format("SELECT * FROM [{0}]", SheetName),OleDbConnection);
            DataSet dsExcel = new DataSet();
            try
            {
                OleDbConnection.Open();
                OAdapter.Fill(dsExcel);
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                OleDbConnection.Close();
            }

            if (dsExcel.Tables.Count > 0 && dsExcel.Tables[0].Rows.Count > 0 && dsExcel.Tables[0].Columns.Count > 0)
            {
                var r = dsExcel.Tables[0].Rows.Cast<DataRow>().Where(row => !row.ItemArray.All(field => field is System.DBNull || String.IsNullOrEmpty(field.ToString())));
                if (r.Any())
                {
                    DataTable dtNullRowsRemoved = r.CopyToDataTable();

                    if (trim)
                    {
                        foreach (DataRow dr in dtNullRowsRemoved.Rows)
                        {
                            foreach (DataColumn col in dtNullRowsRemoved.Columns)
                            {
                                if (col.DataType == typeof(System.String) && dr[col].GetType() == typeof(System.String))
                                {
                                    dr[col] = dr[col].ToString().Trim();
                                }
                            }
                        }
                    }
                    return dtNullRowsRemoved;
                }
            }

            return null;

        }
        
    }
    public class SheetDetails
    {
        public SheetDetails(string sheetName, string Name)
        {
            sheetName = sheetName.Replace("'", "");
            Name = sheetName.Replace("'", "").Replace("$", "");
        }

        public string Name { get; private set; }
        public string SheetName { get; private set; }

    }
}
