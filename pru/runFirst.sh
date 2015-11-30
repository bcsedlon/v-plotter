
modprobe uio_pruss
echo BB-BONE-PRU-01 > /sys/devices/bone_capemgr.9/slots

cat /sys/devices/bone_capemgr.9/slots
modprobe uio_pruss

