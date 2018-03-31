---
title: "重启iptables导致的docker容器工作不正常问题原因及解决方法"
date: 2018-03-31T10:12:14+08:00
---

阿里云的云盾报了很多次线上用的centos因为有段时间没有更新导致的出现了很多的漏洞需要打补丁，所以在某台机器上做了一把`yum upgrade`更新系统，完毕之后发现sentry上面突然报了大量的访问超时的错误，这样的事情其实从以往到现在发生过了不只一次了，解决方法都是重启机器，一直也没有云太深究其中的问题，今天下了决心准备云探查一番。

初步的猜测是更新的时候如果更新到了`iptables-service`，会导致`iptables.service`的重启，重启会清掉所有的iptables的配置项并且加载系统预置的配置，而docker自己在启动的时候也会加载一批配置项以保证自己的内部容器可以正常使用网络，是否是因为这批iptables的配置项被清掉了导致docker启动的服务无法被外边访问? 实际情况还需要通过实验来判断了。

在阿里云开通了一台按量付费的服务器(最低配置, 4分钱一小时)，安装好iptables和docker开始实验。

1. 先部署一个容器

    `docker run -d --restart always -p 8080:80 --name nginx nginx:alpine`

1. 然后测试访问这个nginx

    `curl http://127.0.0.1:8080/`

    根据刚才的猜测，这个是可以正常访问得了的

1. 重启iptables, 测试服务可访问性

    `systemctl restart iptables`

    这个时候通过 `iptables-save` 可以看到配置的条目数量只有几条了，和docker相关的部分全部都被清空了，按之前的猜测，这个时候nginx应该是无法正常访问的，于是我执行了一下`curl http://127.0.0.1:8080/`，居然可以正常访问，所以之前的猜测是有偏差的。从netstat的信息来看, 8080端口是被一个叫做docker-proxy的进程开启的，和iptables没有什么关联，所以正常访问也算是合情合理的，那到底是什么原因导致的服务挂掉的呢，是不是容器内部的服务连网的能力受限呢？

1. 测试容器内访问网络的情况

    执行了一下 `docker exec -ti nginx wget -O- www.baidu.com` 果然失败了，失败信息为`wget: bad address 'www.baidu.com'`

1. 再次重启docker让docker把自己的那堆iptables配置重新生效之后，执行上一步的命令可以正常访问网络了。


  所以，问题现在应该算是已经找到了，确实是iptables.service的服务重启导致清理掉了可以让容器内部访问外部网络的能力失效，直接的解决办法很简单，在iptables服务重启的时候，手动的把docker重启一把就可以了。

  那么，有没有更加方便的办法让docker自动的跟着iptables.service重启呢? 办法是有的，在centos中，配置一下systemd的启动参数，让iptables的重启自动的把docker重启一下即可。

  下面是docker的systemd配置文件中的Unit模块的配置，最后一行是

{{< highlight ini >}}

[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service iptables.service
Wants=network-online.target

Requires=iptables.service
{{< / highlight >}}

如此一来 如果iptables重启 那么docker也会跟着一起重启掉

以下是受影响部分的iptables的配置

{{< highlight bash >}}
[root@node09 ~]# iptables-save | grep docker0
-A POSTROUTING -s 172.24.2.64/26 ! -o docker0 -j MASQUERADE
-A DOCKER -i docker0 -j RETURN
-A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -o docker0 -j DOCKER
-A FORWARD -i docker0 ! -o docker0 -j ACCEPT
-A FORWARD -i docker0 -o docker0 -j ACCEPT
{{< / highlight >}}

BTW: iptables的配置和原理也算是一个比较复杂的东西，想搞完全搞清楚其细节还是一个比较费时间的事情，由于因为不熟悉它的原因出的锅还蛮多的，是有必要花点时间来把这套体系的东西搞清楚些了，再说给大家查资料在路由器上配置的相关设置也是和iptables密切相关的。

