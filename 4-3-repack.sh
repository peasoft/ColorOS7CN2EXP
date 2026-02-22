#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

set -e

cd framework
java -jar ../bin/smali.jar a -a 29 src/classes -o dist/classes.dex
java -jar ../bin/smali.jar a -a 29 src/classes2 -o dist/classes2.dex
java -jar ../bin/smali.jar a -a 29 src/classes3 -o dist/classes3.dex
rm -f framework.zip || true
rm -f framework.jar || true
cd dist
7z a ../framework.zip * -mx0
cd ..
zipalign -f -p -v -z 4 framework.zip framework.jar
