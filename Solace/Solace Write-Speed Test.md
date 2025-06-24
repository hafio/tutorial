# Solace Disk Write Test

Solace Event Broker requires at least 20 MBps disk write performance (although this is a very low bar and bare minimum) [System Resource Requirements](https://docs.solace.com/Software-Broker/System-Resource-Requirements.htm#storage-considerations)

Based on experience, at least 1000 MBps write performance (or close to it) is recommended.

# Solace Disk Write Performance Test

`/usr/sw/loads/currentload/bin/soldisktest --dir=<internalSpool directory>`

should produce:

```shell
sh-5.1$ /usr/sw/loads/currentload/bin/soldisktest --dir=/usr/sw/internalSpool/
done!
elapsed time = 2.146
bytes written per second = 3908950605 = 3817334 KBps = 3727 MBps
Deleting test spool files created
All files deleted.
```