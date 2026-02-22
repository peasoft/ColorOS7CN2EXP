#!/bin/bash
cd $(dirname "$0")
source ./bin/utils.sh

assertSu
assertFile cn/system/build.prop
assertFile ex/system/build.prop

set -e

del(){
    rm -rf cn/system/$1
}

copy(){
    cp -arf ex/system/$1 cn/system/$1
}

copy2(){
    cp -arf ex/system/$1 cn/system/$2
}

dcopy(){
    del $1
    copy $1
}

del app/*Input
del app/CodeBook
del app/com.opos.ads
del app/Instant*
del app/RemoteGuardService
del app/ResourceMonitor
truncate -s 0 cn/system/etc/blacklist/*
del framework/arm/boot-framework.*
del framework/arm64/boot-framework.*
del framework/boot-framework.*
del priv-app/OppoPermissionController
del product/app/ModuleMetadata
del product/priv-app/GooglePlayServicesUpdater
dcopy app/FocusMode
dcopy app/GoogleLatinInput
copy2 etc/permissions/*exp* etc/permissions
cp -f res/com.oppo.features_expCommon.xml cn/system/etc/permissions
copy2 etc/permissions/Google* etc/permissions
dcopy priv-app/GoogleExtServicesPrebuilt
dcopy priv-app/GooglePermissionControllerPrebuilt
dcopy product/app/GoogleLocationHistory
dcopy product/app/GoogleTTS
dcopy product/app/ModuleMetadataGooglePrebuilt
copy product/etc/permissions/split-permissions-google.xml
copy product/etc/preferred-apps
copy product/etc/sysconfig/wellbeing.xml
copy2 product/overlay/Gms* product/overlay
copy2 product/overlay/Google* product/overlay
copy product/overlay/ModuleMetadataConfigOverlay.apk
dcopy product/priv-app/AndroidAutoStub
dcopy product/priv-app/GoogleRestore
dcopy product/priv-app/Phonesky
dcopy product/priv-app/SetupWizard
dcopy product/priv-app/Velvet
dcopy product/priv-app/Wellbeing

mkdir -p cn/system/app/TelephonyProviderPatch
cp -f res/TelephonyProviderPatch.apk cn/system/app/TelephonyProviderPatch
chmod 755 cn/system/app/TelephonyProviderPatch
chmod 644 cn/system/app/TelephonyProviderPatch/*
chcon -R u:object_r:system_file:s0 cn/system/app/TelephonyProviderPatch
