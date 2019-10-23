#!/bin/bash


for file in $(find run_2_zip/ -type f -name "*.bag.zip"); do
    echo $file
    file_wo_zip=${file%.*}
    file_concat=$(echo $file_wo_zip | sed "s/run_2_zip/run_2_temp/")
    new_dir=$(dirname "${file_concat}")
    mkdir -p $new_dir

    # echo $file_concat
    # echo $file_wo_zip

    cat $file_wo_zip.z* > $file_concat.zip
    unzip $file_concat.zip
done
