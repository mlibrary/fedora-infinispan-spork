#!/bin/bash
# Copyright (c) 2015, Regents of the University of Michigan.
# All rights reserved. See LICENSE.txt for details.

# First figure out where we're being run from
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd)"

source "$DIR/.env"

for item in "$MVN" ; do
  if [ x"$(which "$item")" = x"" ] ; then
    echo "$item is required"
  fi
done

# Run maven clean
for dir in "$INFINISPAN_PATH" "$FEDORA_PATH" ; do
  pushd "$dir" > /dev/null 2>&1
  "$MVN" clean
  popd > /dev/null 2>&1
done

# Delete transient data
rm "$LOG"/*
rm -r "$DATA"

