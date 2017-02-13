#!/bin/bash

export SCRIPT_ROOT="/tmp/cassy-up"

#cassandra_params must at least set:
# CASSANDRA_CLUSTER_NAME
# CASSANDRA_SEEDS
# CASSANDRA_DC_SUFFIX
source "$SCRIPT_ROOT/cassandra_params.sh"

# If using Ec2MultiRegionSnitch, CASSANDRA_LISTEN_ADDRESS (private ip), 
# CASSANDRA_BROADCAST_ADDRESS (public ip) need to be set as well

if [ "x$CASSANDRA_SNITCH" == "x" ]; then export CASSANDRA_SNITCH="Ec2Snitch"; fi


#if [ "x$CASSANDRA_SNITCH" == "x" ]; then export CASSANDRA_SNITCH="GossipingPropertyFileSnitch"; fi

(cd $SCRIPT_ROOT/apache-cassandra && ./main.sh)

echo "cassandra installed. bye bye."
