#!/bin/bash

#Download and Upload file from transfer.sh


state=up

#Version 
currentVersion="0.0.1"

#Upload multiple files
multipleUpload()
{
  for i in "$@"; do


    local filePath="${i//~/$HOME}"
    local tempFileName
    sed "s/.*\///" "$filePath" "$tempFileName"
    echo "Uploading $tempFileName"
    response=$(curl --progress-bar --upload-file "$filePath" "https://transfer.sh/$tempFileName") || { echo "Failure !"; return 1;}
    echo "Transfer File URL:"  "$response"

  done
}


#Download single file
singleDownload(){
  local path="$1"
  local id="$2"
  local file="$3"
  

  echo Downloading "$file"
  
  curl --progress-bar "https://transfer.sh/$id/$file" -o "$path/$file" 
  
  return $?
}

printDownloadResponse(){
  local exit_code=$?
  if [ "$exit_code" -eq 0 ]; then
    echo "Success!"
  else
    echo "Error. Downloading interupted"
  fi
}

#Help function for helping user to understand how to work with this script
help(){
  cat << EOF
    Description: Bash tool to transfer files from the command line.
  Usage:
    -d Download single file
    -h Show the help
    -v Get the tool version
  Examples:
  ./transfer.sh test.txt test2.txt - upload files
  ./transfer.sh -d ./test Mij6ca test.txt - download file
EOF
}

while getopts 'vhd' flag; do
  case "${flag}" in
    d) 
      state=down
    ;;  
    h) 
      help 
    ;;
    v)
      echo "$currentVersion"
    ;;
    *) 
      echo "Invalid flag"
    ;;
  esac
done


if [ "$state" == "up" ]; then
  multipleUpload "$@"
elif [ "$state" == "down" ]; then
  singleDownload "$2" "$3" "$4"
  printDownloadResponse
fi