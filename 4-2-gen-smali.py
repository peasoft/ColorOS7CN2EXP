#!/usr/bin/env python3
import os

os.chdir(os.path.dirname(os.path.realpath(__file__)))

with open('res/pkgNoExp.list') as f:
    packages = f.read().splitlines()

smali = ''

for package in packages:
    if package:
        smali += '''    const-string v3, "%s"

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_0

''' % package

with open('framework/patch.smali', 'w') as f:
    f.write(smali)
