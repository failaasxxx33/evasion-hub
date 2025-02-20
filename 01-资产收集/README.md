# 0x01 目标资产
# 01 子域名
基于公司根域名收集子域名
```
方式很多：

空间测绘：
DNS解析：
SSL证书：
爆破：
```

# 02 IP段
基于子域名尝试获取真实IP段
```
ping一下看是不是CDN，是的话需要绕过CDN，方式很多：

多地ping：
空间测绘：
```

# 03 Web目录扫描
```
工具：https://github.com/ffuf/ffuf
```

# 04 JavaScript接口提取
```
工具：https://github.com/GerbenJavado/LinkFinder
工具：https://github.com/rtcatc/Packer-Fuzzer
```

# 05 Host碰撞
```
https://github.com/pmiaowu/HostCollision
```

# 06 403绕过
```
工具：https://github.com/asaotomo/forbiddenpass-Hx0
```

# 07 历史解析记录
记得有一次是通过历史解析记录对应的IP，资产中有一个jboss的nday漏洞
```
工具：https://ip138.com/
```

# 08 Punycode编码
从[某次攻防演练中通过一个弱口令干穿内网](https://mp.weixin.qq.com/s/lKa0SZezqh9diWe-0NqmiA)这篇文章中看到Punycode编码收集资产，之前没听过这个东西，deepseek后有个基本了解，思考了一下感觉应该是：有些政府事业单位域名中使用中文，但中文的域名在录入域名系统时，需要使用Punycode编码，所以猜测作者是，使用中文对应的Punycode编码收集的子域名
```
工具：https://myssl.com/punycode.html
```

# 0x02 子公司、分公司、父公司资产
收集目标资产无果的话，就要考虑从父子公司下手了，通过天眼查等平台收集根域名后，把上面的流程再走一遍

# 0x03 供应链资产
上面都无果的话，就要考虑从供应链下手了，也是通过天眼查等平台收集根域名后、把上面的流程再走一遍