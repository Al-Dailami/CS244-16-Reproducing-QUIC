#!/bin/bash

# Part 0: Get Mahimahi set up.
sudo sysctl -w net.ipv4.ip_forward=1

# Part I: Set up temp directories
TMP_DIR="/tmp/quic-exp"
mkdir $TMP_DIR &> /dev/null
rm -rf $TMP_DIR/* &> /dev/null
pkill -f SimpleHTTPServer &> /dev/null
pkill -f quic_server &> /dev/null

# Part I: Set up the http server and run wget through mahimahi.

# Tuneable parameters
BANDWIDTHS=( 1 2 4 5 10 20 50 100 )
LOSS_RATES=( 0.0 0.005 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 )

SCRIPTS_DIR=~/CS244-16-Reproducing-QUIC/experiment_scripts
for BANDWIDTH in "${BANDWIDTHS[@]}"
do 
    echo "Running with bandwidth $BANDWIDTH"

    cd ~/chromium/quic-data/www.example.org/
    python -m SimpleHTTPServer &
    sleep 5s # give enough time for server to set up

    HOST_IP=$(echo `hostname -I`)

    TRACE_DIR=~/CS244-16-Reproducing-QUIC/traces
    MM_CMD="mm-link $TRACE_DIR/${BANDWIDTH}mb.trace $TRACE_DIR/${BANDWIDTH}mb.trace mm-delay 10 mm-loss downlink"

    for LOSS in "${LOSS_RATES[@]}"
    do
	echo "Running TCP client with loss rate $LOSS"
	$MM_CMD $LOSS -- time -v -o $TMP_DIR/tcp_${BANDWIDTH}_${LOSS}.out wget http://${HOST_IP}:8000
    done

    grep -i "elapsed" $TMP_DIR/tcp_${BANDWIDTH}* > $TMP_DIR/tcp_loss_${BANDWIDTH}_aggregate.txt

    # Clean up
    rm index.html.* &> /dev/null
    pkill -f SimpleHTTPServer &> /dev/null

    # Part II: Set up the quic server and fetch from the quic client
    cd ~/chromium/src
    ./out/Debug/quic_server \
	--quic_in_memory_cache_dir=/home/user/chromium/quic-data/www.example.org \
	--certificate_file=net/tools/quic/certs/out/leaf_cert.pem \
	--key_file=net/tools/quic/certs/out/leaf_cert.pkcs8 &
    sleep 5s # give enough time for server to set up
    echo "Server started."

    # TODO: get IP better
    for LOSS in "${LOSS_RATES[@]}"
    do
	echo "Running QUIC client with loss rate $LOSS"
	$MM_CMD $LOSS -- time -v -o $TMP_DIR/quic_${BANDWIDTH}_${LOSS}.out ./out/Debug/quic_client  --host=100.64.0.1 --port=6121 https://www.example.org/index.html &> $TMP_DIR/quic_OUTPUT_${BANDWIDTH}_${LOSS}.out
    done

    grep -i "elapsed" $TMP_DIR/quic_${BANDWIDTH}* > $TMP_DIR/quic_loss_${BANDWIDTH}_aggregate.txt

    pkill -f quic_server &> /dev/null

    cd $SCRIPTS_DIR
    FILE_SIZE=`wc -c ~/chromium/quic-data/www.example.org/index.html  | head -n1 | cut -d " " -f1`
    python generate_graphs.py $TMP_DIR/tcp_loss_${BANDWIDTH}_aggregate.txt $TMP_DIR/quic_loss_${BANDWIDTH}_aggregate.txt $FILE_SIZE $BANDWIDTH

    #rm -rf $TMP_DIR/*
done
