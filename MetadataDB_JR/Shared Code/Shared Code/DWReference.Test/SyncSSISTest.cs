using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DWReferenceHelper;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace DWReference.Test
{
    [TestClass]
    public class SyncSSISTest
    {
        [TestMethod]
        public void CheckSSISPacksScripts()
        {
            SyncSSIS ss = new SyncSSIS();

            string sourceFile = ConfigurationManager.AppSettings["SourceFile"];
            string SSISPackagesFolder = ConfigurationManager.AppSettings["SSISPackagesFolder"];

            ss.ReadSourceFile(sourceFile);

            var ssisPackages = ss.ReadSSISPackages(SSISPackagesFolder, System.IO.Path.GetFileName(sourceFile));

            foreach (var ssisPackage in ssisPackages)
            {
                if (ssisPackage.IsDifferent)
                {
                    Assert.AreEqual(1, 0, "SSISPackage out of sync: " + ssisPackage.fileName);
                }
            }

            Assert.AreEqual(1, 1);
        }
    }
}
