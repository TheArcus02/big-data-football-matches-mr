#!/bin/bash

IN_DIR=$1
OUT_DIR=$2

hadoop jar target/footballmatches.jar com.example.bigdata.FootballMatches $IN_DIR $OUT_DIR local
