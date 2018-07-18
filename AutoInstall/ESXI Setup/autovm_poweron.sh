#!/bin/sh
#Turns on machine in order listed in line 1

for i in misp fame viper cuckoo mastiff dionaea 
do
        id="$(vim-cmd vmsvc/getallvms | sed '1d' | awk -v a="$i" '{if ($2 == a) print $1}')"
        vim-cmd vmsvc/power.on "$id"
done
