# 高级版破解
```
xray v1.8.4版本的破解可通过修改日期，不过之后版本的破解用此方式则无效
xray v1.9.3破解版，下载自：微信公众号--小阿辉谈安全
xray v1.9.4破解版，下载自：https://github.com/NHPT/Xray_Cracked
```

# 修改配置文件
```
在配置文件config.yaml中取消对政府、教育等目标的漏扫限制（搜索mitm）

如果想让浏览器走xray的话，需要将ca.crt导入到火狐和chrome的根证书颁发机构

修改worker数量，parallel: 100

plugins部分
将baseline中的子项全部改为false，同时想要排除掉某个poc，可在exclude_poc: [poc-yaml-go-pprof-leak]中添加

reverse部分
指定db_file_path和token，修改client中的remote_server和http_base_url
```

# 配置反连平台
上传 xray_1.9.11_linux_amd64和xray-license.lic 到云服务器

步骤1
```
执行 ./xray_1.9.11_linux_amd64 会生成4个配置文件：config.yaml、xray.yaml、module.xray.yaml、plugin.xray.yaml
```

步骤2
```
编辑本地config.yaml，修改reverse部分
将http enabled改为true，并指定listen_port
将client remote_server改为false
修改后上传到云服务器覆盖原来的config.yaml
```