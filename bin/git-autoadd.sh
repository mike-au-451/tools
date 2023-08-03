#!/bin/bash

git status | perl -ne '/^\s+modified:\s+(.+)/ && print "$1\n"' | xargs git add

