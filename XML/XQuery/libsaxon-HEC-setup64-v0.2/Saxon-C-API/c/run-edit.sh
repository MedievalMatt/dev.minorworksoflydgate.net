#!/bin/sh

jetprofile=/usr/lib/rt
jvmdir=
#echo $LD_LIBRARY_PATH
if [ "$1" = "hs" ]; then
  export LD_LIBRARY_PATH=$jvmdir:$LD_LIBRARY_PATH
else
  export LD_LIBRARY_PATH=$jetprofile/lib/i386/jetvm
fi

./saxonProcessor

