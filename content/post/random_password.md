+++
date = "2016-02-29T08:49:25+08:00"
title = "生成随机密码"
+++

山坡驴近来折腾各种服务器和软件比较多，各种需要生成随机密码，在网上找到了一个生成密码的命令，在这里记录一下

{{< highlight bash >}}

cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -1

{{< / highlight >}}

在Mac下面会遇到如下的错误
{{< highlight bash >}}
Sempr@fred % tr -dc 'a-zA-Z0-9' < /dev/urandom| fold -w 10 | head -1
tr: Illegal byte sequence
{{< / highlight >}}

解决方案也很简单，最前面加一下LC_CTYPE=C

{{< highlight bash >}}
LC_CTYPE=C tr -dc 'a-zA-Z0-9' < /dev/urandom| fold -w 10 | head -1
{{< / highlight >}}
