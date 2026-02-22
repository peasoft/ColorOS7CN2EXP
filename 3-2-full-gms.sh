#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

# USE THE SCRIPT WITH YOU OWN RISK!!!
# Comment out the line below to run the script!
throw You should not run this script!!!

assertSu
assertFile cn/system/build.prop
assertFile ex/system/build.prop

set -e

copy(){
    cp -rf ex/system/$1 cn/system/$1
}

copy product/app/CalendarGoogle
copy product/app/Chrome
copy product/app/Gmail2
copy product/app/Keep
copy product/app/Maps
copy product/app/Messages
copy product/app/YouTube
copy product/priv-app/GoogleFeedback
