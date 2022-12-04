#!/bin/bash

SS=./single-sensor
MS=./multi-sensor
SA=./single-actuator
MA=./multi-actuator
COMP=./complex
SRC=./src
BUILD=./build

echo "[*] Building attack filters..."

if [ ! -d $BUILD ]; then
  mkdir $BUILD
else
  rm -f $BUILD/*
fi

for DIR in $SS $MS $SA $MA $COMP; do
  for FNAME in $DIR/$SRC/*; do
    FILTERNAME=${FNAME##*/}; FILTERNAME=$BUILD/${FILTERNAME%.filter}.ef
    etterfilter $FNAME -o $FILTERNAME
  done
done
