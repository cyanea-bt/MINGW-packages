#!/usr/bin/env bash

#
# create a backup of all installed and compiled packages
#

# setup for archive filenames
if [[ $# -eq 0 ]] ; then
  DATE=$(date "+%Y-%m-%d-%H.%M.%S")
else
  DATE=$(date "+%Y-%m-%d")
fi

# clean-up before
if [[ -d "./database" ]]; then
  rm -rf ./database
fi
mkdir ./database

# list all native/database pkgs and download them from msys database
# make sure to run pacman in msys env
if [[ $MSYSTEM != "MSYS" ]]; then 
  /usr/bin/env MSYSTEM=MSYS /usr/bin/bash -l <<- "END1"
  PKG_LIST="$(pacman -Qqn | xargs echo)"
  pacman -Sw --noconfirm --cachedir ./database/ ${PKG_LIST}
END1
else
  PKG_LIST="$(pacman -Qqn | xargs echo)"
  pacman -Sw --noconfirm --cachedir ./database/ ${PKG_LIST}
fi

# check pacman exit code
retVal=${?}
if [[ $retVal -ne 0 ]]; then
  echo "pacman ERROR! Exit: ${retVal}"
  exit ${retVal}
else
  echo "pacman SUCCESS!"
fi

# run 7z in mingw64 since msys version is slow
/usr/bin/env MSYSTEM=MINGW64 /usr/bin/bash -l << END2
7z a -t7z -y -mx=9 -mhe=on -mmt=on -ms=on -mtc=on -mtm=on -mta=on "/opt/packages_${DATE}.7z" "database" "mingw32" "mingw64"
END2

# clean-up after
rm -rf ./database
