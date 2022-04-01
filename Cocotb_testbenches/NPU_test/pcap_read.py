from scapy.all import *
import binascii
import os

def txt_gen(pcapPath, TxtPath):
# Check, PCAP file
    if os.path.exists(pcapPath) == False:
        print('Error!' + pcapPath + ' no such file or directory!')
        exit()

    packets = rdpcap(pcapPath)
    f = open (TxtPath,'w+')
    for pack in packets:
        pck = str(binascii.hexlify(bytes(pack)), "utf-8")
        f.write(pck)
        f.write("\n")       
    f.close()
