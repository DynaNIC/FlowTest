# It kind of worked on Dn setup with this and my changes,
#  then a custom FW had to flashed to the FPGA

./prepare_machine.sh -s -p ansible/flowtest_tools_nfb.yaml # will likely fail on some NFB error, at that point, you are good.

#  then run to load NDK_NIC
./flash-card.sh
nfb-eth -e1


# Afterwards this replay worked

sudo ft-replay -i ./pcap/vxlan.pcap -o nfb:queueCount=1,packetSize=1520,device=/dev/nfb/by-pci-slot/0000:01:00.0,queueOffset=0 -l 10 -t

## Ok, so in blackhat-demo-assets folder you have e.g. 10G PCAP.
# With this I can acheive 200G replay -- absolute max -- the limit is apparently in DMA endpoints where one endpoint has a 100G limit. You would need to use queues from different 4 endpoints to acheive best performance. But with current configuration it is not possible.
sudo ft-replay -i ./10G_test.pcap -o nfb:queueCount=8,packetSize=1520,device=/dev/nfb/by-pci-slot/0000:01:00.0,queueOffset=12 -l 10 -t

# 160G with 2 cores only:
sudo ft-replay -i ./test_10G.pcap -o nfb:queueCount=2,packetSize=1520,device=/dev/nfb/by-pci-slot/0000:01:00.0,queueOffset=15 -l 10 -t --cpu-cores=0-1

# FAQ:
# Q: Cannot flash the FPGA
# A: Ask gurus to fix it -- DDoS demo prevents reflashing the FPGA

# Q: Is replication done in HW or in SW?
# A: In SW. That's why adding packet replications with "-t" (max speed) just adds more packets and prolongs the replay duration but does not increase replay speed.
