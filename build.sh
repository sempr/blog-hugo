#!/bin/bash

DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
cd "$DIR"
git submodule init
git submodule update --remote
mkdir -p /hugo
wget -qO- https://github.com/gohugoio/hugo/releases/download/v0.37.1/hugo_0.37.1_Linux-64bit.tar.gz | tar xvz
./hugo
