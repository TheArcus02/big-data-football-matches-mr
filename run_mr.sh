#!/bin/bash

IN_DIR=$1
OUT_DIR=$2

hadoop fs -rm -r -f $OUT_DIR

hadoop jar target/footballmatches.jar com.example.bigdata.FootballMatches $IN_DIR $OUT_DIR cluster
