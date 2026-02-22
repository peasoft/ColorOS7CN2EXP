#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

assertSu

umount cn
umount ex
