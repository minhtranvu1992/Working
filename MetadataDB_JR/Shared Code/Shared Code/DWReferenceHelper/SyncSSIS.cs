using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.Serialization;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using System.Xml.XPath;
using Microsoft.SqlServer.Dts.Design;
using Microsoft.SqlServer.Dts.Runtime;
using Microsoft.SqlServer.Dts.Pipeline.Wrapper;
using Microsoft.SqlServer.Dts.Pipeline;
//using Microsoft.SqlServer.VSTAHosting;
//using Microsoft.SqlServer.IntegrationServices.VSTA;
using Microsoft.SqlServer.Dts.Tasks.ScriptTask;


namespace DWReferenceHelper
{
    public class SyncSSIS
    {
        public string SourceCode { get; set; }
        public string ReadSourceFile(string FullFileName)
        {
            var sr = new StreamReader(FullFileName);
            SourceCode = sr.ReadToEnd();
            return SourceCode;
        }

        public List<SSISFile> ReadSSISPackages(string SSISPackageFolder, string scriptFile)
        {
            List<SSISFile> SSISFiles = new List<SSISFile>();

            foreach (var file in Directory.GetFiles(SSISPackageFolder, "*.dtsx"))
            {
                ReadSSISPackage(file, scriptFile, SSISFiles);
            }

            return SSISFiles;
        }

        public void ReadSSISPackage(string SSISPackage, string scriptFile, List<SSISFile> SSISFiles)
        {
            XmlDocument doc = new XmlDocument();
            doc.PreserveWhitespace = true;
            doc.Load(SSISPackage);
            XmlElement root = doc.DocumentElement;

            var nodes = doc.DocumentElement.SelectNodes(@"//ProjectItem[@Name='ScriptHelper.cs']");

            foreach (var node in nodes)
            {
                SSISFile sf = new SSISFile();
                sf.fileName = SSISPackage;
                sf.node = (XmlNode)node;
                sf.doc = doc;
                string objectName = FindParent(sf.node, "Microsoft.SqlServer.Dts.Tasks.ScriptTask.ScriptTask", sf);
                CheckSourceCodeToTask(sf);
                SSISFiles.Add(sf);
            }
        }

        public string FindParent(XmlNode n, string ExecutableType, SSISFile sf)
        {
            if (n.ParentNode != null)
            {
                if (n.Name == "DTS:Executable")
                {
                    if (n.Attributes.GetNamedItem("DTS:ExecutableType") != null && n.Attributes.GetNamedItem("DTS:ExecutableType").InnerText.Contains(ExecutableType))
                    {
                        sf.ObjectName = n.Attributes["DTS:ObjectName"].Value;
                        return sf.ObjectName;
                    }
                }
                else
                {
                    return FindParent(n.ParentNode, ExecutableType, sf);
                }
            }
            return null;
        }

        public bool CheckSourceCodeToTask(SSISFile sf)
        {
            if(HashDataTable(SourceCode) != HashDataTable(sf.Script))
            {
                sf.IsDifferent = true;
            }
            else
            {
                sf.IsDifferent = false;
            }

            return sf.IsDifferent;
        }

        public string HashDataTable(string script)
        {
            // Serialize the table
            DataContractSerializer serializer = new DataContractSerializer(typeof(string));
            MemoryStream memoryStream = new MemoryStream();
            XmlWriter writer = XmlDictionaryWriter.CreateBinaryWriter(memoryStream);
            serializer.WriteObject(memoryStream, script);
            byte[] serializedData = memoryStream.ToArray();

            // Calculte the serialized data's hash value
            //SHA1CryptoServiceProvider SHA = new SHA1CryptoServiceProvider();
            SHA512CryptoServiceProvider SHA = new SHA512CryptoServiceProvider();
            byte[] hash = SHA.ComputeHash(serializedData);

            // Convert the hash to a base 64 string
            return Convert.ToBase64String(hash);
        }

        public void UpdateSSISPackageSSISFile(SSISFile sf)
        {
            sf.node.FirstChild.Value = SourceCode;
            sf.doc.PreserveWhitespace = true;
            sf.doc.Save(sf.fileName);

            using (TextWriter sw = new StreamWriter(sf.fileName, false, Encoding.UTF8)) //Set encoding
            {
                sf.doc.Save(sw);
            }

            //Recompile the code
            updateDataPackage(sf.fileName);

            Console.WriteLine("Completed.");
        }

        void updateDataPackage(string FullnamePackage)
        {
            string pkgLocation;
            Package pkg;
            Microsoft.SqlServer.Dts.Runtime.Application app;
            DTSExecResult pkgResults;

            pkgLocation = FullnamePackage;
            app = new Microsoft.SqlServer.Dts.Runtime.Application();
            pkg = app.LoadPackage(pkgLocation, null);

            try
            {
                Executables pExecs = pkg.Executables;
                FindTasks(pExecs);

                app.SaveToXml(pkgLocation, pkg, null);
            }
            catch (Exception ex)
            {

                Console.WriteLine(ex.Message.ToString());

            }
        }

        void FindTasks(Executables pExecs)
        {
            foreach (Executable pExec in pExecs)
            {
                Console.WriteLine(pExec.GetType().ToString());
                if (pExec.GetType().ToString() == "Microsoft.SqlServer.Dts.Runtime.Sequence")
                {
                    var task = ((Microsoft.SqlServer.Dts.Runtime.Sequence)pExec);
                    Console.WriteLine("Name: " + task.Name);
                    FindTasks(task.Executables);
                }
                if (pExec.GetType().ToString() == "Microsoft.SqlServer.Dts.Runtime.TaskHost")
                {
                    var task = ((Microsoft.SqlServer.Dts.Runtime.TaskHost)pExec);

                    if ("Microsoft.SqlServer.Dts.Tasks.ScriptTask.ScriptTask" == task.InnerObject.GetType().ToString())
                    {
                        updateScriptTask((Microsoft.SqlServer.Dts.Tasks.ScriptTask.ScriptTask)task.InnerObject);
                        // ((Microsoft.SqlServer.Dts.Tasks.ScriptTask.ScriptTask)task.InnerObject).ScriptStorage.ScriptFiles
                    }

                    Console.WriteLine("Name: " + task.Name);
                }
                if (pExec.GetType().ToString() == "Microsoft.SqlServer.Dts.Runtime.ForEachLoop")
                {
                    var task = ((Microsoft.SqlServer.Dts.Runtime.ForEachLoop)pExec);
                    Console.WriteLine("Name: " + task.Name);
                }
            }
        }
        void updateScriptTask(ScriptTask task)
        {
            if (!(task.ScriptLoaded))
            {
                Console.WriteLine("Task has no script, nothing to do.");
                return;
            }
            task.ScriptingEngine.LoadProjectFromStorage();
            task.ScriptingEngine.SaveProjectToStorage();


            Console.Write("Rebuilding script...");
            VSTATaskScriptingEngine script = new VSTATaskScriptingEngine(task.ScriptStorage);
            // load existing script from it's storage and load it in the designer
            bool loaded = script.LoadProjectFromStorage();
            // re-save it triggering a rebuild
            bool saved = script.SaveProjectToStorage();

            // close the designer... don't forget this or you'll leak processes
            //script.CloseIDE(true);
            Console.WriteLine("done.");
        }
    }

    public class SSISFile
    {
        public XmlNode node { get; set; }
        public bool IsDifferent { get; set; }
        public string ObjectName { get; set; }
        public string fileName { get; set; }
        public string DisplayName {
            get { return Path.GetFileNameWithoutExtension(this.fileName) + " - " + this.ObjectName; }
            }

        public XmlDocument doc { get; set; }

        public string Script
        {
            get { return node.FirstChild.Value; }
        }
    }
        

}
