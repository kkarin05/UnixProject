#!/bin/bash


function findinfo() {
     fullinfo=$(grep $filename ~/.restore.info)
      name=$(grep $filename ~/.restore.info | cut -d "_" -f1)
      namewithinode=$(grep $filename ~/.restore.info | cut -d ":" -f1)
      path=$(grep $filename ~/.restore.info | cut -d ":" -f2)
}

function restore() {
      if ! [ -e $path ]
      then
            mkdir -p $path
      fi
      mv ~/deleted/$namewithinode $path
     sed -i "/^$name/d" ~/.restore.info
}

function exist() {
      if [ -e $path/$name ]
      then
            read -p "Do you want to overwrite?" input
                  if [[ $input = [Yy] ]] || [[ $input = [Yy]es ]]
                  then
                       return 0
                  else
                        echo "File was not overwritten"
                       exit 4
                  fi
      fi
}
 
 
if [ $# -eq 0 ]
then
      echo "Error, no file provided in argument"
       exit 1
fi


for filename in "$@"
do
       findinfo

      if [[ $filename != $namewithinode ]]
       then
            echo "Error, file supplied does not exist"
            exit 2
      fi

      exist
      restore

done
