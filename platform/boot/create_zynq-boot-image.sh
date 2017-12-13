#!/bin/bash

if [ $# -ne 2 ];then
  echo "You must specify the .bif file and the output extension."
  echo "Example: $0 bootimage.bif bin"
  echo "Example: $0 bootimage.bif mcs"
  exit 1
fi
if [ $2 != "bin" ]
then
  if [ $2 != "mcs" ]
  then
    echo "Output extension must be bin or mcs. Exit"
    exit 1
  fi
fi
if test -f $1.$2
then
  rm $1.$2
fi
bootgen -image $1 -o i $1.$2
if test -f BOOT.$2
then
  rm BOOT.$2
fi
ln -s $1.$2 BOOT.$2
