 #!/bin/bash
 
function movetoRC() {
      inode=$(stat -c%i $filename)
      basename=$(basename $filename)
      recycledfile=$(echo $basename $inode | tr " " "_")
      path=$(readlink -m $filename)
 
 
      echo $recycledfile:$path >> $HOME/.restore.info
      mv $filename $HOME/deleted/$recycledfile
      return 0

}

function createdelete() {
      if ! [ -d $HOME/deleted ]
       then
            echo $(mkdir $HOME/deleted)
            echo "Recycle bin ~/deleted created"
      fi
}

function provideddir() {
       if [ -d $filename ]
       then
           echo "Error, name provided is a directory"
           exit 1
       fi
}

function notexist() {
      if ! [ -e $filename ]
       then
            echo "Error, $filename does not exist"
             exit 3
      fi
}

function delete() {
       if [[ $filename = *project/remove.sh ]] || [[ $filename = remove.sh ]] || [[ $filename = */remove.sh ]]
      then
             echo "Attempting to delete remove - operation aborted"
            exit 4
       fi
	   }

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

function verbose() {
      if [[ $optv -eq 1 ]] && ! [[ -e $filename ]]
       then
            echo "removed \`$filename"
     fi
 }

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

if [ $# -eq 0 ]
 then
      echo "Error, no file provided"
      exit 2
 fi

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


