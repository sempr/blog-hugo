+++
date = "2016-04-18T11:39:50+08:00"
draft = false
title = "不靠谱的busybox"

+++

山坡驴最近用docker搭了一个公司的开发环境(python)，自我感觉挺良好的，但是同事不停的向我抱怨经常改了代码之后，python自带的auto reload会执行，但是执行完了之后修改并没有生效，山坡驴同学于是决定去探究一下到底是个什么鬼……

简单说一下这个环境的状况，山坡驴是在Mac下面开发的，用docker-machine和virtualbox跑的docker，从最外层到最里层分别是
```
Mac(macos) -> virtualbox(tinylinux/boot2docker) -> docker(alpine)
```

代码在Mac下面编辑，透过两层文件映射到最终的执行环境中，山坡驴觉得一定是这两层文件的映射出了问题，下面我开始查看到底是个什么原因导致了这样的问题，我先从中间这一层入手。

在最外层执行了一句 ``` for i in `seq 1 100`; do echo $i; echo $i>>test.log; sleep 3;done ```

使用 ```docker-machine ssh machine-name``` 进入到中间一层查看，在```tail -f test.log```的时候居然神奇的发现 内容居然不更新了……更新了……新了……了……，执行```wc -l ``` 和 ```cat test.log | wc -l```发现结果居然还不一样，用vi命令打开文件也正常，md5sum出来的文件md5值也和外面一样的，这是什么鬼？

我开始怀疑是不是virtualbox的坑，因为之前有见过一个nginx的sendfile的坑，再加上virtualbox一直以来也是存在着各种各样的bug，而且公司的另外一个团队也在这么用，如果我遇上这个坑了，那么他们应该也一样会遇到的，找他们咨询了一下，他们一脸懵懵的表示没有过啊，一直好好的，非常正常，他们使用的PHP语言也是执行时才解释的语言，我遇到的问题他们应该一样会遇到的才是啊，难道在``PHP是最好的语言``的光环之下，灵异事件自动退散？这不可能……

重新打包了一个centos的镜象，直接进到第三层，docker container里面测试，发现居然全都是好的，返回到第二次，还是一样的问题，如果说是vbox的锅，那么为什么中间层错了最里层居然还是对的，这不应该，再仔细想了想，tinylinux和alpine默认的shell都是busybox，是不是这货的锅呢？带着这个疑问我去alpine的docker container里做测试，果然还是出错的，那这样子结果就明了了，busybox在这种情况下无法追踪到文件的修改，所以在这样的测试环境下面，还是老老实实的用bash以及各类unix工具吧，慎用busybox。

完毕
