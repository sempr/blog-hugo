#!/bin/bash

DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
cd "$DIR"
git submodule init
git submodule update --remote
wget -qO- https://github.com/gohugoio/hugo/releases/download/v0.91.2/hugo_0.91.2_Linux-64bit.tar.gz | tar xvz
./hugo
