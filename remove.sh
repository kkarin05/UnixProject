 #!/bin/bash
 
 
#Function writes file path to restore.info and moves file to recycle bin
function movetoRC() {
      inode=$(stat -c%i $filename)
      basename=$(basename $filename)
      recycledfile=$(echo $basename $inode | tr " " "_")
      path=$(readlink -m $filename)
 
 
      echo $recycledfile:$path >> $HOME/.restore.info
      mv $filename $HOME/deleted/$recycledfile
      return 0

}

#Checks if the recycling bin exists, if not creates it
function createdelete() {
      if ! [ -d $HOME/deleted ]
       then
            echo $(mkdir $HOME/deleted)
            echo "Recycle bin ~/deleted created"
      fi
}

#Checks if file name provided is a directory
function provideddir() {
       if [ -d $filename ]
       then
           echo "Error, name provided is a directory"
           exit 1
       fi
}

#Checks if file exists
function notexist() {
      if ! [ -e $filename ]
       then
            echo "Error, $filename does not exist"
             exit 3
      fi
}

#Checks if the user is trying to remove the remove script
function delete() {
       if [[ $filename = *project/remove.sh ]] || [[ $filename = remove.sh ]] || [[ $filename = */remove.sh ]]
      then
             echo "Attempting to delete remove - operation aborted"
            exit 4
       fi
	   }

#Function same as the interactive option for rm 
function interactive() {
      if [ $opti -eq 1 ]
      then
            read -p "rm: remove regular empty file '"$filename"'?" input
           if [[ $input = [Yy] ]] || [[ $input = [Yy]es ]]
            then
                  return 0
            else
                   echo "File was not removed"
				   exit 7
             fi
      fi
 }

 #Function same as the verbose option for rm
function verbose() {
      if [[ $optv -eq 1 ]] && ! [[ -e $filename ]]
       then
            echo "removed \`$filename"
     fi
 }

#Function same as the recursive option for rm
function recursive() {
      if [[ $optr -eq 1 ]] && [[ -d $filename ]]
      then
            for efiles in $(find $filename)
            do
                   finode=$(stat -c%i $efiles)
                  fbasename=$(basename $efiles)
                  frecycled=$(echo $fbasename $finode | tr " " "_")
                  fpath=$(readlink -m $efiles)
                  if [ -f $efiles ]
                  then
                        echo $frecycled:$fpath >> $HOME/.restore.info
                        mv $efiles $HOME/deleted/$frecycled
                  fi
             done
            rm -r $filename
             return 0
      fi
}


opti=0
optv=0
optr=0

 while getopts ivr opt
 do
      case $opt in
       i) opti=1 ;;
       v) optv=1 ;;
       r) optr=1 ;;
       *) exit 6;;
       esac
done

shift $[$OPTIND -1]

#Checks if a file name is provided
if [ $# -eq 0 ]
 then
      echo "Error, no file provided"
      exit 2
 fi

#Multiple arguments are able to be provided
for filename in "$@"
do
      createdelete
      notexist
      delete
      interactive
      if [[ $optr -eq 1 ]]
      then
            for filename in "$@"
            do
            recursive
            done
            break
      fi
      provideddir
      movetoRC
      verbose
done


