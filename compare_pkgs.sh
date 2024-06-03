#!/usr/bin/env bash

#
# compare installed pkgs for mingw32/mingw64
#

mingw32_list=$(pacman -Q | grep 'i686')
mingw64_list=$(pacman -Q | grep 'x86_64' | grep -iv 'ucrt')

# ref: https://stackoverflow.com/a/13210909
mingw32_filtered=${mingw32_list//i686-/}
mingw64_filtered=${mingw64_list//x86_64-/}

# ref: https://unix.stackexchange.com/a/393352, https://stackoverflow.com/a/37712614, https://stackoverflow.com/a/48016366
sdiff --suppress-common-lines --width=$(tput cols) <( echo "${mingw32_filtered}" ) <( echo "${mingw64_filtered}" )
