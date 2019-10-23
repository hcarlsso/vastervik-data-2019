#!/bin/bash


for file in $(find run_1/ -type f -name "*.bag"); do
    echo $file
    DIR=$(dirname "${file}")
    echo $DIR
    NEW_DIR=$(echo $DIR | sed "s/run_1/run_1_zip/")
    mkdir -p $NEW_DIR
    FILE_NEW_DIR=$(echo $file | sed "s/run_1/run_1_zip/")
    ZIP_FILE="${FILE_NEW_DIR}.zip"
    echo "Split files into chunk files of 100 mb "
    zip -s 100m $ZIP_FILE $file
    md5sum ${DIR}/*.bag > $FILE_NEW_DIR.md5
done
