#!/bin/bash

randomBed -seed 23 -l 1000 -n 50000 -g hg19.genome | sortBed > a.bed
randomBed -seed 31 -l 1000 -n 50000 -g hg19.genome | sortBed > b.bed
