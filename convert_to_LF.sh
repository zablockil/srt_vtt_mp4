#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo ""
  echo "Usage: $0 [FILE_IN] [FILE_OUT]"
  exit 1
fi

if ! iconv -f UTF-8 -t UTF-8 "$1" > /dev/null; then
  unknown_charset="$(file -bi "$1" | awk -F "=" '{print $2}')"
  echo ""
  echo "! ! !"
  echo "            file is not UTF-8"
  echo "                        . . ."
  echo "           detected charset : $unknown_charset"
  echo "! ! !"
  #exit 1
fi

# https://stackoverflow.com/a/1068700
tr -cd "\11\12\15\40-\176\200-\377" < "$1" | awk 'BEGIN{RS="\r|\n|\r\n|\n\r";ORS="\n"}NR==1{sub(/^\xef\xbb\xbf/,"")}{print}' > "$2"

echo "DONE."
