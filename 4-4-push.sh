#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

assertSu

cp -f framework/framework.jar cn/system/framework
