强制启用多用户。可以修改 XML 实现但是为了方便我就直接改系统框架了。

```smali
.method public whitelist hasSystemFeature(Ljava/lang/String;I)Z
    .registers 8
    .param p1, "name"    # Ljava/lang/String;
    .param p2, "version"    # I

################ 新增代码开始 ################

    const-string v3, "oppo.multiuser.entry.unsupport"

    invoke-virtual {p1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_0

################ 新增代码结束 ################

    const-string v3, "oppo.version.exp"

    invoke-virtual {p1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :try_start_0

################ 后略 ################
```