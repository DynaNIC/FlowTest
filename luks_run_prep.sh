# It kind of worked on Dn setup with this and my changes,
#  then a custom FW had to flashed to the FPGA

./prepare_machine.sh -s -p ansible/flowtest_tools_nfb.yaml # will likely fail on some NFB error, at that point, you are good.

#  then run to load NDK_NIC
./flash-card.sh
nfb-eth -e1


# Afterwards this replay worked

sudo ft-replay -i ./pcap/vxlan.pcap -o nfb:queueCount=1,packetSize=1520,device=/dev/nfb/by-pci-slot/0000:01:00.0,queueOffset=0 -l 10 -t
