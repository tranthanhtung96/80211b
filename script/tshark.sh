tshark -Y "rftap and not icmp and wlan.ta"  -i lo -q -T fields -e wlan.ta -e rftap.freqofs >> ~/80211b/clustering/data.csv

