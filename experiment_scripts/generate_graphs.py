import sys
import re
import numpy as np
import matplotlib.pyplot as plt

FILE_REGEX = "(?P<loss>0.[0-9]+).out"

TCP_UNITS_REGEX = "\((?P<rate>[0-9]+(?:\.[0-9]+)?) (?P<units>(?:M|K)B/s)\)"
TCP_REGEX = ".*?%s:.*?%s" % (FILE_REGEX, TCP_UNITS_REGEX)

QUIC_SECS_REGEX = "(?P<min>[0-9]+):(?P<secs>[0-9][0-9].[0-9]+)"
QUIC_REGEX = ".*?%s.*?%s" % (FILE_REGEX, QUIC_SECS_REGEX)

def extract_data(filename, protocol, regex):
    assert protocol in filename

    f = open(filename, 'r')

    loss_to_tput = {}
    for line in f:
        match = re.search(regex, line)
        if match:
            print "%s:%s%s" % (match.group("loss"), match.group("rate"), match.group("units"))
        else:
            print line
        loss_to_tput[float(match.group("loss"))] = convert_to_mbps(match.group("rate"), match.group("units"))
    print loss_to_tput
    return loss_to_tput

def convert_to_mbps(rate, units):
    if units == "MB/s":
        return float(rate)
    elif units == "KB/s":
        return float(rate) / 1000
    else:
        assert false

def extract_quic_data(filename, protocol, regex, file_size):
    assert protocol in filename

    f = open(filename, 'r')

    loss_to_tput = {}
    for line in f:
        match = re.search(regex, line)
        total_time = 60*int(match.group("min")) + float(match.group("secs"))
        loss_to_tput[float(match.group("loss"))] = convert_secs_to_mbps(file_size, total_time)
    print loss_to_tput
    return loss_to_tput

def convert_secs_to_mbps(file_size, secs):
    return (file_size/secs)/1000000

def main():
    assert len(sys.argv) == 4

    tcp_loss_to_tput = extract_data(sys.argv[1], "tcp", TCP_REGEX)
    quic_loss_to_tput = extract_quic_data(sys.argv[2], "quic", QUIC_REGEX, int(sys.argv[3]))        
    plt.scatter(tcp_loss_to_tput.keys(), tcp_loss_to_tput.values(), color='red')
    plt.scatter(quic_loss_to_tput.keys(), quic_loss_to_tput.values(), color='green')
    plt.show()

if __name__ == "__main__": main()
