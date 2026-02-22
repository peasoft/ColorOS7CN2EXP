#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

assertSu
assertFile cn/system/build.prop

set -e

rm -rf cn/system/product/priv-app/SetupWizard
