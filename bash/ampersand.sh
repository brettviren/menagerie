#!/bin/bash

shopt -s nullglob

zzz="${1:-0}"
bkgdir="${2:-$HOME/Desktop/bkg}"


if [ ! -d "$bkgdir" ] ; then
    echo "No directory of desktop backgrounds at: \"$bkgdir\""
    exit 1
fi

while true ; do
    # the quick and dirty but will always show the same crop.
    # feh --bg-fill --randomize $bkgdir/*

    # the slow and dirtier way
    declare -a imgs
    imgs=("$bkgdir"/*)
    nimgs=${#imgs[@]}
    ind="$(($RANDOM%$nimgs))"
    image="${imgs[$ind]}"
    echo "image: [$ind / $nimgs] $image"

    iwh=( $(exiftool -p '$ImageWidth $ImageHeight' "$image") )
    swh=( $(xdpyinfo | awk '/dimensions:/ { print $2; exit }' | tr x ' ') )

    echo "image: ${iwh[*]}, screen: ${swh[*]}"

    weat=""
    heat=""

    # image wider than screen
    x=0
    if [ ${iwh[0]} -gt ${swh[0]} ] ; then 
        weat=$(( ${iwh[0]} - ${swh[0]} ))
        x=$(( $RANDOM % $weat ))
        width=${swh[0]}
        echo "eat width $x $width"
    else
        width=${iwh[0]}
        echo "keep width $width"
    fi
    
    # image taller than screen
    y=0
    if [ ${iwh[1]} -gt ${swh[1]} ] ; then 
        heat=$(( ${iwh[1]} - ${swh[1]} ))
        y=$(( $RANDOM % $heat ))
        height=${swh[1]}
        echo "eat height $y $height"
    else
        height=${iwh[1]}
        echo "keep height $height"
    fi


    if [ -z "$weat" -a -z "$heat" ] ; then
        # image fully smaller than screen so fill it
        feh --bg-fill "$image"
    else
        # image bigger than screen in at least one dimension
        echo "$image"
        # some images fool anytopnm so give some help based on extension
        ext=$(echo "${image##*.}" | tr '[:upper:]' '[:lower:]')
        dec=""
        if [ "$ext" = "jpg" -o "$ext" = "jpeg" ] ; then
            dec=jpeg
        elif [ "$ext" = "png" ] ; then
            dec=png
        elif [ "$ext" = "tif" -o "$ext" = "tiff" ] ; then
            dec=tiff
        else
            dec=any
        fi
        ${dec}topnm "$image" | pnmcut -left $x -top $y -width $width -height $height | feh --bg-fill -
    fi

    if [ "$zzz" = "0" ] ; then
        break;
    fi
    sleep $zzz
done
