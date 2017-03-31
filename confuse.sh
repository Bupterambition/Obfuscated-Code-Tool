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
                lines=`egrep -n  "@interface.+:.+\w+" $file|awk -F : '{print $1}'`
                if [[ $lines ]]; then
                	linedelta=0
                	for line in $lines; do
                		md5Value=`md5 -q $file`
                        line=`expr $line + $linedelta`
                		classline=`gsed -n "$line p" $file`
                		classline=`echo $classline|egrep -o 'interface.+:'`
                		classline=`echo $classline|egrep -o '\s\w+\s'`
                		linecount=`awk '{print NR}' "$2"|tail -n1`
                		if [[ -z $linecount ]]; then
                			linecount=1
                			gsed -i "$linecount a class : $classline : $md5Value " $2
                		else
                			gsed -i "$linecount a class : $classline : $md5Value " $2
                		fi
                		gsed -E -i "$line i __attribute__((objc_runtime_name(\""$md5Value"\")))" $file
                		linedelta=`expr $linedelta + 1`
                	done
                	
                fi

                lines=`egrep -n "@protocol\s+\w+" $file|awk -F : '{print $1}'`
                if [[ $lines ]]; then
                	linedelta=0
                	for line in $lines; do
                		md5Value=`md5 -q $file`
                        line=`expr $line + $linedelta`
                		classline=`gsed -n "$line p" $file`
                		classline=`echo $classline|egrep -o 'protocol.+'`
                		classline=`echo $classline|egrep -o '\s\w+\s?'`
                		linecount=`awk '{print NR}' "$2"|tail -n1`
                		if [[ -z $linecount ]]; then
                			linecount=1
                			gsed -i "$linecount a protocol : $classline : $md5Value " $2
                		else
                			gsed -i "$linecount a protocol : $classline : $md5Value " $2
                		fi
                		line=`expr $line + $linedelta`
                		gsed -E -i "$line i __attribute__((objc_runtime_name(\""$md5Value"\")))" $file
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
                confound $file $2
            fi
        fi
    done
    cd ..
}

# brew install gnu-sed --default-names
if  test -f "ClassTableMap.txt" 
then
    mappath=`pwd`
    mappath="$mappath/ClassTableMap.txt"
	confound $(pwd) $mappath
else
	touch ClassTableMap.txt
	echo "This is a Class and Protocol Maptable" > ClassTableMap.txt
    mappath=`pwd`
    mappath="$mappath/ClassTableMap.txt"
	confound $(pwd) $mappath
fi

