# ColorOS 7 CN to Exp

把国内版 (CN) ColorOS 7 转制为国际版 (Exp, Export)。严格来说，根据本项目制作的系统为半国际版，因为系统保留了部分国内版功能，且有一部分是有意保留的。

此处以 OPPO K1 (PBCM30) / R15x (PBCM10) 的最新系统 ColorOS 7.1 为例。

要刷入该系统，请确保你的手机已经解锁 Bootloader。

如果你使用的是 OPPO K1 或 R15x，可以直接在 Release 中下载 `system.img.7z`，解压后刷入即可。

## 准备

下载以下文件：

- 原机系统包（此处以 `PBCM10_11_OTA_2230_all_wYioLkcn5N5E.ozip` 为例）
- 国际版系统包（此处以 `RMX1801EX_11_OTA_2120_all_4q5L63MjpxAp.ozip` 为例）

安装 Linux 系统（本文以 Ubuntu 24.04 为例，可以用 WSL 2）。

建议为后续操作预留 20G 磁盘空间。请不要在 Windows 磁盘 / NTFS 磁盘中操作。

## 获得 `system.img`

安装运行库和工具：

```bash
sudo apt install python3 python3-pycryptodome brotli 7zip
```

对于原机系统包，将 ozip 转换为 zip。

```bash
python3 ./bin/ozipdecrypt.py PBCM10_11_OTA_2230_all_wYioLkcn5N5E.ozip
```

对于国际版系统包，经观察发现该刷机包未加密，把 ozip 直接重命名为 zip 即可。

执行:

```bash
./1-extract.sh PBCM10_11_OTA_2230_all_wYioLkcn5N5E.zip system_cn.img
./1-extract.sh RMX1801EX_11_OTA_2120_all_4q5L63MjpxAp.zip system_ex.img
```

## 处理系统程序+权限配置

挂载镜像：

```bash
sudo ./2-mount.sh
```

增删文件：

```bash
sudo ./3-1-exp.sh
```

请浏览 `3-1-exp.sh` 的代码来了解修改了哪些文件。这一操作还会额外打入适用于 ColorOS 7/11 的 CVE-2025-10184 短信泄漏漏洞补丁“短信卫士”，该补丁来自 OPPO 官方。

注意：本项目没有去除 `cn.google.services` 标记，因为“纯国际版”系统并没有你想象中那么好。比如，“连接至 Windows”会根据这个标记判断是否强制依赖国际网络；在 [代理分流规则正确](https://github.com/peasoft/NoMoreWalls/blob/91f29c33f620f85ad37592f9f1163576e957c49d/snippets/example.yml#L134) 的情况下，国行机的 Google Play 会从上海服务器下载软件，下载速度与国内应用商店基本相同。

系统首次启动时先完成 Google 设置向导，再完成 ColorOS 开机设置。如不需要 Google 设置向导，可以执行 `sudo ./3-2-no-google-setup.sh` 删除 Google 设置向导。

由于国行机系统分区容量有限，本项目只为系统加入了基础 GMS 组件。如有需要，可以在 Google Play 中安装剩下的软件或 ROOT 后自行刷入 GApps 模块。本项目保留了 `3-3-full-gms.sh` 以供参考，除非有绝对的把握，您不应运行该脚本。

## 修改系统框架

由于国内版 ColorOS 中的部分组件包含错误的国际版代码，直接转换系统版本会导致部分关键系统组件崩溃。我们需要对这些组件欺骗系统版本为国内版。另外，这样做还可以避免丢失一部分国内版系统的专属功能。

这一步操作需要手工完成。首先，请在系统中安装 Java Runtime，比如：

```bash
sudo apt install default-jre-headless zipalign
```

解包 `framework.jar` 并生成补丁代码：

```bash
./4-1-unpack.sh
./4-2-gen-smali.py
```

用文本编辑器打开 `framework/src/classes/android/app/ApplicationPackageManager.smali`，搜索 `hasSystemFeature(Ljava/lang/String;I)Z`，你会得到这样的代码：

```smali
.method public whitelist hasSystemFeature(Ljava/lang/String;I)Z
    .registers 5
    .param p1, "name"    # Ljava/lang/String;
    .param p2, "version"    # I

    .line 656
    :try_start_0
    iget-object v0, p0, Landroid/app/ApplicationPackageManager;->mPM:Landroid/content/pm/IPackageManager;

    invoke-interface {v0, p1, p2}, Landroid/content/pm/IPackageManager;->hasSystemFeature(Ljava/lang/String;I)Z

    move-result v0
    :try_end_6
    .catch Landroid/os/RemoteException; {:try_start_0 .. :try_end_6} :catch_7

    return v0

    .line 657
    :catch_7
    move-exception v0

    .line 658
    .local v0, "e":Landroid/os/RemoteException;
    invoke-virtual {v0}, Landroid/os/RemoteException;->rethrowFromSystemServer()Ljava/lang/RuntimeException;

    move-result-object v1

    throw v1
.end method
```

按照下面的示例，把 `.registers 5` 改为 `.registers 8`，然后新增代码（提示行无需加入代码）：

```smali
.method public whitelist hasSystemFeature(Ljava/lang/String;I)Z
    .registers 8
    .param p1, "name"    # Ljava/lang/String;
    .param p2, "version"    # I

################ 新增代码开始 1 ################

    const-string v3, "oppo.version.exp"

    invoke-virtual {p1, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :try_start_0

    iget-object v2, p0, Landroid/app/ApplicationPackageManager;->mContext:Landroid/app/ContextImpl;

    invoke-virtual {v2}, Landroid/app/ContextImpl;->getPackageName()Ljava/lang/String;

    move-result-object v2

################ 稍后再此插入代码 ################

################ 新增代码结束 1 ################

    .line 656
    :try_start_0
    iget-object v0, p0, Landroid/app/ApplicationPackageManager;->mPM:Landroid/content/pm/IPackageManager;

################ 中略 ################

    .line 658
    .local v0, "e":Landroid/os/RemoteException;
    invoke-virtual {v0}, Landroid/os/RemoteException;->rethrowFromSystemServer()Ljava/lang/RuntimeException;

    move-result-object v1

    throw v1

################ 新增代码开始 2 ################

    :cond_0
    const/4 v3, 0x0

    return v3

################ 新增代码结束 2 ################

.end method
```

打开 `framework/patch.smali`，复制所有代码，粘贴到 `稍后再此插入代码` 处。可以额外加入“强制启用多用户”补丁，请见 `res/smali-patch-multi-user.md`。

重新打包：

```bash
./4-3-repack.sh
sudo ./4-4-push.sh
```

## 完成

执行：

```bash
sudo ./5-umount.sh
```

获得可刷入的半国际版 `system_cn.img`。国内版多数应用并非预装，需从 zip 刷机包的 `data_update_patch/app` 提取 APK 自行安装。
