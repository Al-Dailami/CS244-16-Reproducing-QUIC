#!/bin/bash

# Part 0: Get Mahimahi set up.
sudo sysctl -w net.ipv4.ip_forward=1

# Part I: Set up temp directories
TMP_DIR="/tmp/quic-exp"
mkdir $TMP_DIR &> /dev/null
rm -rf $TMP_DIR/* &> /dev/null
pkill -f python &> /dev/null
pkill -f quic &> /dev/null

# Part I: Set up the http server and run wget through mahimahi.
cd ~/chromium/quic-data/www.example.org/
python -m SimpleHTTPServer &
sleep 5s # give enough time for server to set up

HOST_IP=$(echo `hostname -I`)

LOSS_RATES=( 0.0 0.005 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 )

TRACE_DIR=~/CS244-16-Reproducing-QUIC/traces
MM_CMD="mm-link $TRACE_DIR/5mb.trace $TRACE_DIR/5mb.trace mm-loss downlink"

for LOSS in "${LOSS_RATES[@]}"
do
  $MM_CMD $LOSS wget http://$HOST_IP:8000 &> $TMP_DIR/tcp_$LOSS.out
done

egrep "KB/s|MB/s" $TMP_DIR/tcp* > $TMP_DIR/tcp_loss_aggregate.txt

# Clean up
#rm $TMP_DIR/*.out
rm index.html.* &> /dev/null
pkill -f python &> /dev/null

# Part II: Set up the quic server and fetch from the quic client
cd ~/chromium/src
./out/Debug/quic_server \
  --quic_in_memory_cache_dir=/home/user/chromium/quic-data/www.example.org \
  --certificate_file=net/tools/quic/certs/out/leaf_cert.pem \
  --key_file=net/tools/quic/certs/out/leaf_cert.pkcs8 &
echo "Server started."
sleep 5s # give enough time for server to set up

# TODO: get IP better
for LOSS in "${LOSS_RATES[@]}"
do
  $MM_CMD $LOSS -- time -v -o $TMP_DIR/quic_$LOSS.out ./out/Debug/quic_client  --host=100.64.0.1 --port=6121 https://www.example.org/index.html &> /dev/null
done

grep -i "elapsed" $TMP_DIR/quic* > $TMP_DIR/quic_loss_aggregate.txt

pkill -f quic &> /dev/null
cd ~
