---
title: "MTR v0.92(以及后续版本) 在mac下的非root帐号下使用"
date: 2017-06-26T16:17:45+08:00
---

长话短说，解决方法是

```
cd /usr/local/Cellar/mtr/0.94_1/sbin/
sudo chmod u+s mtr-packet
sudo chown root mtr-packet

# 确保是这样一个状态
$ ls -lh
total 184K
-r-xr-xr-x 1 Sempr 110K Jan  2 22:35 mtr
-r-sr-xr-x 1 root   71K Sep 24  2020 mtr-packet
```

`mtr` 是一个非常好用的 `ping+traceroute` 的工具，在 MacOS 下 升级了 0.92 版本之后，参照网上说的使用`chmod u+s `的方式反复多次都无法让它在日常帐号下使用，必须得 sudo 才能好，每次都会报 `mtr should not run suid`错误，非常的疑惑，网上也无法查得到解决办法。所以只能去看看代码里发生了什么事情。

从代码里看，mtr.c 中 直接有这么一个片段

{{< highlight c "linenos=table,linenostart=723" >}}
/_
mtr used to be suid root. It should not be with this version.
We'll check so that we can notify people using installation
mechanisms with obsolete assumptions.
_/
if ((geteuid() != getuid()) || (getegid() != getgid())) {
error(EXIT_FAILURE, errno, "mtr should not run suid");
}
{{< / highlight >}}

明显的就是禁止了通过 `chmod u+s` 的方式执行`mtr`了

接下来要怎么办呢？以前允许了现在不行了肯定是有 _安全_ 原因的，查查相关说明文档再看看咯。于是我找到了下面这一段:

{{< highlight c "linenos=table,linenostart=35" >}} 3. Make mtr-packet a setuid-root binary.

The mtr-packet binary can be made setuid-root, which is what "make install"
does by default.

When mtr-packet is installed as suid-root, some concern over security is
justified. mtr-packet does the following two things after it is launched:
{{< / highlight >}}

也就是说 mtr 不允许 setuid-root 但是 mtr-packet 允许，推测是因为以前的做法可能有安全隐患，所以只把需要依赖 root 的逻辑放到了 mtr-packet 里，把不需要 root 但是给了 root 可能带来安全问题的部分继续放在 mtr 中使用普通帐户执行，执行 mtr 的时候再调用 mtr-packet，通过 suid-root 的方式获得 root 的权限。

这个事情其实很好的展示了开发中的`最小权限原则`，只给出必须的授权，不给出额外的授权。
