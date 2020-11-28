#!/bin/bash

source $(dirname "$0")/CONFIG

if [ -z "$1" ]; then
    echo "usage: $0 directory [targetDirectory]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "specified directory $1 is not valid" >&2
    exit 1
fi

if [ -n "$2" ] && [ ! -d "$2" ]; then
    echo "specified output directory $outputdir is not valid" >&2
    exit 1
fi

if [ $(which identify) == "" ]; then
    echo "The ImageMagick 'identify' was not found"
    exit 1
fi

dir=$(realpath "$1")
targetdir=$(realpath "$2")
printf "analyzing directory $dir:\n"

BASEDIR="$dir"

if [ -n "$targetdir" ]; then
    BASEDIR="${targetdir}"
fi

COUNTER=0;

for i in "$dir"/*;
do
    DATE=$(identify -format %[EXIF:DateTime] "$i" | awk '{print $1}')
    FILE=$(realpath "$i")
    printf "$FILE ... $DATE\n"

    if [ -n "$DATE" ]; then

        printf "\n$DATE\n"

        FILEDATE=$(echo $DATE | sed -e "s/:/-/g")
        NEWDIR="$BASEDIR/$(date -d "$FILEDATE" "+${PREFIXDATEPATTERN}")/"

        mkdir -p "$NEWDIR"

        mv "$FILE" "$NEWDIR"

        let COUNTER++;
    fi;

done;
printf "$COUNTER files moved\n"
printf "done\n"