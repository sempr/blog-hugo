---
title: "利用Travis CI自动部署hugo生成的静态页面到github pages"
date: 2018-03-25T20:04:47+08:00
---

过程其实挺简单的，在github生成一个token给travis ci使用 直接写个脚本从github上把hugo的二进制文件下载下来在blog的根目录下运行即可得到public目录下要部署的所有静态文件

然后再利用travis ci提供的[GitHub Page Deployment](https://docs.travis-ci.com/user/deployment/pages/) 的文档配置一下，指定要部署的目标即可。

相关代码如下

.travis.yml
```
language: bash
script:
    ./build.sh
deploy:
  provider: pages
  skip-cleanup: true
  github-token: $GITHUB_TOKEN
  keep-history: false 
  repo: sempr/sempr.github.io
  target-branch: master
  on:
    branch: master
  local-dir: public
  verbose: true
```

build.sh
```
#!/bin/bash

DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
cd "$DIR"
git submodule init
git submodule update --remote
wget -qO- https://github.com/gohugoio/hugo/releases/download/v0.37.1/hugo_0.37.1_Linux-64bit.tar.gz | tar xvz
./hugo
```