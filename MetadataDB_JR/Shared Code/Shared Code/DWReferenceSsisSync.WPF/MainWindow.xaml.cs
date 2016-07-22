using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using DWReferenceHelper;
using System.Configuration;
//using System.IO;

namespace DWReferenceSsisSync
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        SyncSSIS ss = new SyncSSIS();
        List<SSISFile> SSISFiles = new List<SSISFile>();
        public MainWindow()
        {
            InitializeComponent();
        }


        private void btnCheckcode_Click(object sender, RoutedEventArgs e)
        {
            string sourceFile = ConfigurationManager.AppSettings["SourceFile"];
            string SSISPackagesFolder = ConfigurationManager.AppSettings["SSISPackagesFolder"];

            tbSource.Text = ss.ReadSourceFile(sourceFile);

            SSISFiles = ss.ReadSSISPackages(SSISPackagesFolder, System.IO.Path.GetFileName(sourceFile));

            lbxScriptasks.ItemsSource = null;
            lbxScriptasks.ItemsSource = SSISFiles;
            lbxScriptasks.DisplayMemberPath = "DisplayName";
        }

        private void lbxScriptasks_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

            var s = ((SSISFile)(e.AddedItems[0]));
            tbSSISSource.Text = s.Script;

            lblIsDifferent.Content = "IsDifferent: " + s.IsDifferent.ToString();
        }

        private void btnUpdate_Click(object sender, RoutedEventArgs e)
        {
            var sf = ((SSISFile)(lbxScriptasks.SelectedItem));
            ss.UpdateSSISPackageSSISFile(sf);
        }

        private void btnUpdateAll_Click(object sender, RoutedEventArgs e)
        {
            var current = this.Cursor;
            this.Cursor = Cursors.Wait;

            foreach (var ssisFile in SSISFiles)
            {
                if (ssisFile.IsDifferent)
                {
                    ss.UpdateSSISPackageSSISFile(ssisFile);
                }
            }

            this.Cursor = current;
        }

    }
}
