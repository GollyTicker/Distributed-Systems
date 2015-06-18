#!/bin/bash

rm -rf log/*
rm -r out/*.beam

cd src

erl -v -make

rm -r ../out 
mkdir ../out
mv *.beam ../out

cd ..