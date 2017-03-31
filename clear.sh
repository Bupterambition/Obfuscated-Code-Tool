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
                echo $file
                chmod 777 $file 
                lines=`egrep -n  "__attribute__.+objc_runtime_name" $file|awk -F : '{print $1}'`
                if [[ $lines ]]; then
                    linedelta=0
                    for line in $lines; do
                        line=`expr $line - $linedelta`
                        gsed -i "$line d" $file
                        linedelta=`expr $linedelta + 1`
                    done
                    
                fi
            fi
        fi
        if test -d $file
        then
            FILE=$file;
            if [ "${FILE#*.}" != "framework" ]
                then
                confound $file
            fi
        fi
    done
    cd ..
}

# brew install gnu-sed --default-names
if  test -f "ClassTableMap.txt" 
then
    rm -rf ClassTableMap.txt
    confound $(pwd) 
else
    confound $(pwd)
fi

