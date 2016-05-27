#!/bin/bash


TMP_DIR=/tmp/quic-exp

# Tuneable parameters
DELAYS=( 1 )
BANDWIDTHS=( 20 )

SCRIPTS_DIR=~/CS244-16-Reproducing-QUIC/experiment_scripts

for DELAY in "${DELAYS[@]}"
do

for BANDWIDTH in "${BANDWIDTHS[@]}"
do 
    cd $SCRIPTS_DIR
    FILE_SIZE=`wc -c ~/quic-data/www.example.org/index.html  | head -n1 | cut -d " " -f1`
    python generate_graphs.py $TMP_DIR/tcp_loss_${DELAY}_${BANDWIDTH}_aggregate.txt $TMP_DIR/quic_loss_${DELAY}_${BANDWIDTH}_aggregate.txt $FILE_SIZE $BANDWIDTH $DELAY
done
done
