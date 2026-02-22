#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

set -e

mkdir -p framework/dist
cd framework
cp -f ../cn/system/framework/framework.jar .
cd dist
7z x ../framework.jar
cd ..
mkdir -p src
java -jar ../bin/baksmali.jar d -a 29 dist/classes.dex -o src/classes
java -jar ../bin/baksmali.jar d -a 29 dist/classes2.dex -o src/classes2
java -jar ../bin/baksmali.jar d -a 29 dist/classes3.dex -o src/classes3
