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

for item in "$JAVA" ; do
  if [ x"$(which "$item")" = x"" ] ; then
    echo "$item is required"
    exit
  fi
done

for item in "$FEDORA" "$INFINISPAN" "$LOG" ; do
  if [ ! -e "$item" ] ; then
    echo "$item must exist" 
    exit
  fi
done

function fedora {
  instance="$1"
  port="800$instance"
  log_file="log/fedora-$instance.log"
  echo Starting Fedora "$instance"
  "$JAVA" \
    -Xmx4024m -XX:MaxMetaspaceSize=4024m \
    -Dfcrepo.ispn.configuration="$INFINISPAN_CONFIG" \
    -Djgroups.tcp.address="$IP" \
    -Djgroups.tcpping.initial_hosts="$INITIAL_HOSTS" \
    -Dfcrepo.ispn.repo.cache="$PWD/fcrepo4-data/cache/fedora-$instance" \
    -Dfcrepo.ispn.jgroups.configuration="$JGROUPS_CONFIG" \
    -jar "$FEDORA" \
    --headless \
    --bindAddress "$IP" \
    --port "$port" \
    > $log_file \
    2>&1
}

function infinispan {
  instance="$1"
  log_file="log/infinispan-$instance.log"
  echo "Starting Infinispan $instance"
  "$JAVA" \
    -Dinfinispan.host="$IP" \
    -Dinfinispan.http.port="810$instance" \
    -Dinfinispan.hotrod.host="$IP" \
    -Dinfinispan.hotrod.port="1122$instance" \
    -Dinfinispan.memcached.host="$IP" \
    -Dinfinispan.memcached.port="1121$instance" \
    -Dinfinispan.config="$INFINISPAN_CONFIG" \
    -Dfcrepo.ispn.configuration="$INFINISPAN_CONFIG" \
    -Dfcrepo.ispn.jgroups.configuration="$JGROUPS_CONFIG" \
    -Djgroups.tcp.address="$IP" \
    -Djgroups.tcpping.initial_hosts="$INITIAL_HOSTS" \
    -Dfcrepo.ispn.repo.cache="$PWD/fcrepo4-data/cache/infinispan-$instance" \
    -jar "$INFINISPAN"  \
    > "$log_file" \
    2>&1
}

fedora 1 &
sleep 2
echo "Sleeping 20"
sleep 18

fedora 2 &
sleep 2
echo "Sleeping 20"
sleep 18

infinispan 1 &
sleep 2
echo "Sleeping 10"
sleep 8

infinispan 2
