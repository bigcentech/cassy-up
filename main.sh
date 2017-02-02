#!/usr/bin/env bash
export SCRIPT_ROOT="/vagrant"

(cd $SCRIPT_ROOT/oracle-jdk && ./main.sh)

source $SCRIPT_ROOT/apache-cassandra/cassandra-vagrant-params.sh
(cd $SCRIPT_ROOT/apache-cassandra && ./main.sh)

echo "all done. bye bye."

