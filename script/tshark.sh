tshark -Y "rftap and not icmp"  -i lo -q -T fields -e wlan.ta -e rftap.freqofs

