# 拿到一个PHP系统，如何审计出0day
## 0x01 文件上传漏洞
```
关键函数或变量：
move_uploaded_file、$_FILES

参考：
https://www.php.net/manual/zh/function.move-uploaded-file.php
https://www.php.net/manual/zh/reserved.variables.files.php
https://www.php.net/manual/zh/features.file-upload.post-method.php

漏洞演化：
从2005年左右的无过滤，到2015年左右后缀黑名单过滤，再到2025左右后缀白名单过滤，越来越安全了，意味着漏洞越来越难挖了（以上时间是我估计瞎说的，不必太当真）

过滤演化：
无任何验证 -> 前端JS验证 -> 验证文件头、验证Content-Type-> 黑名单验证 -> 白名单验证
```
## 0x03 命令执行漏洞
```
关键函数或变量：
system

参考：
https://www.php.net/manual/zh/function.system.php

```
## 0x03 文件读取漏洞
```
关键函数或变量：
fopen 

参考：
https://www.php.net/manual/zh/function.fopen.php
```