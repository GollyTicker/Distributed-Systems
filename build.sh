#!/bin/bash

# erl -sname hbqNode@localhost -run hbq start
# erl -sname serverNode@localhost -run server start
# erl -sname client -run client start

cdir=${PWD##*/}
if [ "$cdir" == "dist_sys" -o "$cdir" = "Distributed-Systems" ]; then
  rm -rf log/* && rm -rf *.beam && erl -make
fi