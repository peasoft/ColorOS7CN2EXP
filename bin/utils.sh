#!/bin/bash

throw(){
    echo $* >&2
    exit 1
}

assertFile(){
    [ -f $1 ] || throw Missing file \"$1\"
}

assertNotExist(){
    [ -e $1 ] || throw \"$1\" already exists
}

assertSu(){
    [ $(id -u) -ne 0 ] && throw Please run the script with sudo!
}

assertCmd(){
    command -v $1 > /dev/null 2>&1 || throw Command \"$1\" not found
}
