#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

assertSu
assertFile system_cn.img
assertFile system_ex.img

mkdir -p cn
mount system_cn.img cn
mkdir -p ex
mount -o ro system_ex.img ex
