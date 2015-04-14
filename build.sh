#!/bin/bash

cdir=${PWD##*/}
if [ "$cdir" == "dist_sys" -o "$cdir" = "Distributed-Systems" ]; then
  rm -rf log/* && rm -rf *.beam && erl -make
fi