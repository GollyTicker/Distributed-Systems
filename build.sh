#!/bin/bash

rm -rf log/*
rm -rf out/*.beam

cd src

erl -v -make && mv *.beam ../out

cd ..