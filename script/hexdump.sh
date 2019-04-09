rm bin.dat hexdump.dat
xxd -r -p hex.dat bin.dat; od -Ax -tx1 -v bin.dat >> hexdump.dat
