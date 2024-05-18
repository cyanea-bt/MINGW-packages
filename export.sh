#!/usr/bin/env bash

#
# create a backup of all installed packages
#

# clean-up
if [ -d "./database" ]; then
  rm -rf ./database
fi

# list all native/database pkgs and download them from msys database
PKG_LIST=$(pacman -Qqn | xargs echo)
mkdir -p ./database
pacman -Sw --cachedir ./database/ ${PKG_LIST}

DATE=$(date "+%Y-%m-%d-%H.%M.%S")
7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "/opt/packages_${DATE}.7z" "database" "mingw32" "mingw64"

rm -rf ./database
