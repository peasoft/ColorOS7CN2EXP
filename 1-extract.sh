#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

assertFile $1
assertNotExist $2

set -e

7z x $1 system.new.dat.br system.transfer.list
brotli -d system.new.dat.br
rm -f system.new.dat.br
python3 ./bin/sdat2img.py system.transfer.list system.new.dat $2
rm -f system.new.dat system.transfer.list
