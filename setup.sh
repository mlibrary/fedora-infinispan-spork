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

for item in "$MVN" "$GIT" "$PATCH"; do
  if [ x"$(which "$item")" = x"" ] ; then
    echo "$item is required"
    exit
  fi
done

# Clone if needed
if [ ! -d "$FEDORA_PATH" ] ; then
  "$GIT" clone "$FEDORA_GIT" "$FEDORA_PATH"
  pushd "$FEDORA_PATH" > /dev/null 2>&1
  "$PATCH" -p1 < "$FEDORA_PATCH"
  popd > /dev/null 2>&1
fi

# Build the jar file
if [ ! -e "$FEDORA" ] ; then
  pushd "$FEDORA_PATH" > /dev/null 2>&1
  "$MVN" package
  popd > /dev/null 2>&1
fi

if [ ! -e "$INFINISPAN_PATH" ] ; then
  "$GIT" clone --branch "$INFINISPAN_BRANCH" "$INFINISPAN_GIT" "$INFINISPAN_PATH"
fi

if [ ! -e "$INFINISPAN" ] ; then
  pushd "$INFINISPAN_PATH" > /dev/null 2>&1
  "$MVN" package
  popd > /dev/null 2>&1
fi

mkdir -p "$LOG"

echo "Setup complete."
