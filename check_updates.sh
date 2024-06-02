#!/usr/bin/env bash

#
# check commit date of each pkg against the original msys2 repo
#

dir_here=$(realpath -s "./")
dir_orig=$(realpath -s "../MINGW-packages-orig")

if [[ ! -d "${dir_here}" ]]; then
    echo "${dir_here} is not a directory!"
    exit 1
elif [[ ! -d "${dir_orig}" ]]; then
    echo "${dir_orig} is not a directory!"
    exit 1
fi

# update repo first? start without parameters for no updates
if [[ $# -gt 0 ]] ; then
    cd "${dir_orig}"
    git reset --hard && git checkout master && \
    git fetch && git pull || exit 1
    cd "${dir_here}"
fi

echo ""
for dir in ./mingw-w64-*/
do
    cd "${dir_here}"
    # ref: https://stackoverflow.com/a/56373126, https://git-scm.com/docs/pretty-formats
    date_here_unix=$(git log -1 --pretty="format:%ct" "${dir}")
    date_here_iso=$(git log -1 --pretty="format:%ci" "${dir}")
    
    cd "${dir_orig}"
    # only check packages that exist in both repos, otherwise skip
    if [[ -d "${dir}" ]]; then
        date_orig_unix=$(git log -1 --pretty="format:%ct" "${dir}")
        date_orig_iso=$(git log -1 --pretty="format:%ci" "${dir}")
    else
        continue
    fi
    
    if  [[ $date_orig_unix -gt $date_here_unix ]]; then
        echo "new version: ${dir}"
        echo "orig: ${date_orig_iso} > here: ${date_here_iso}"
        if [[ ! -z $date_here_unix ]]; then
            git log --since="${date_here_unix}" --pretty="format:%C(yellow)%h %C(cyan)%cs%Creset %s" "${dir}"
        else
            git log -3 --pretty="format:%C(yellow)%h %C(cyan)%cs%Creset %s" "${dir}"
        fi
        echo ""
    else
        # ref: https://unix.stackexchange.com/a/26592
        echo -e -n "\033[2Kup-to-date: ${dir}\r"
        # echo "orig: ${date_orig_iso} <= here: ${date_here_iso}"
    fi

    date_here_unix=0
    date_here_iso=""
    date_orig_unix=0
    date_orig_iso=""
done

echo -e "\033[2KDONE"
