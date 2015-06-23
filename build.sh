#!/bin/bash

rm -rf out/log/*
rm -rf out/*.beam

cd src

erl -v -make && mv *.beam ../out

cd ..
