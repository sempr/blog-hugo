---
title: "修复python升级后导致的virtualenv中的python无法正常运行"
date: 2018-05-15T15:08:24+08:00
draft: false
---

去往virtualenv的目录，执行下面的命令

```
# 确定当前的版本，查找到对应目录的所有软链并且删掉后 重建新的软链
CUR_PY=`readlink bin/python`
find . -type l -delete
virtualenv . -p $CUR_PY
```