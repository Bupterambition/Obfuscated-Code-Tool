#!/bin/sh
function confound() {
    cd $1
    filelist=`ls`
    for file in $filelist
    do
        if test -f $file 
        then
            FILE=$file;
            if [ "${FILE#*.}" == "h" ] || [ "${FILE#*.}" == "m" ] || [ "${FILE#*.}" == "mm" ]
            then
                
                # echo $file
                chmod 777 $file 
                lines=`cat $file | egrep -o '\-\s*\(\w+\)(\w*)\:*\s*\(*\s*\w*.*\)*'|egrep -o '\w+[\;\:]'`
                if [[ $lines ]]; then
                    echo $lines
                    linedelta=0
                    for line in $lines; do
                        linedelta=`expr $linedelta + 1`
                        echo $linedelta
                        if [[ (($linedelta > "1" )) ]]; then
                            echo $line
                            exist=`echo $line|egrep -o ';'`
                            if [[ -z "$exist" ]]; then
                                line=`echo $line | sed 's/[\;\:]//g'`
                                echo $line
                                exist="`egrep -o "$line" $2`""`echo $line | egrep -o 'init' `"
                                if [[ -z "$exist" ]]; then
                                    newLine="#define $line "t""`md5 -q $2`""
                                    echo "$newLine" >> $2
                                    # gsed -i "$numofline a $newLine" $2
                                fi
                            else
                                linedelta=0
                            fi
                            
                        else
                            exist=`echo $line|egrep -o ';'`
                            if [ ! -z "$exist" ]; then
                                linedelta=0
                            fi
                            line=`echo $line | sed 's/[\;\:]//g'`
                            echo $line
                            exist="`egrep -o "$line" $2`""`echo $line | egrep -o 'init' `"
                            if [[ -z "$exist" ]]; then
                                newLine="#define $line "t""`md5 -q $2`""
                                echo $newLine
                                # gsed -i "$numofline a $newLine" $2
                                echo "$newLine" >> $2
                            fi
                        fi
                        
                    done
                    
                fi
                
            fi
        fi
        if test -d $file
        then
            FILE=$file;
            if [ "${FILE#*.}" != "framework" ]
                then
                confound $file $2
                cd ..
            fi
        fi
    done
    
}

brew install gnu-sed --default-names
# read -p "Input the completed path you want to confuse :" path
path=`pwd`
if  test -d $path 
    then
    cd $path
    if  test -f "PreConfuse.h" 
    then
        touch PreConfuse.txt
        cat PreConfuse.h > PreConfuse.txt
        mappath=`pwd`
        mappath="$mappath/PreConfuse.txt"
        numofline=`awk '{print NR}' 'PreConfuse.txt' |tail -n1`
        confound $(pwd) $mappath
    else
        touch PreConfuse.txt
        echo "//
//  PreConfuse.h
//  BUPT
//
//  Created by senmiao .
//  Copyright (c) 2016 BUPT. All rights reserved.
//" >'PreConfuse.txt'
        mappath=`pwd`
        mappath="$mappath/PreConfuse.txt"
        numofline=`awk '{print NR}' 'PreConfuse.txt' |tail -n1`
        confound $(pwd) $mappath
    fi
    pwd
    mv -f "PreConfuse.txt" "PreConfuse.h"
    # read -p "The PreConfuse's path is: $mappath,do you want to check (Y/N)" check
    # if [[ $check == "Y" || $check == "y" ]]; then
    #         open "`pwd`/PreConfuse.h"
    # fi
else
    echo "can't open the path you input, please try again"
fi


