# Overview

Setup a RTSP Stream via MediaMTX.

Refer to [MediaMTX Quick Start](https://bookstack.handy:26654/books/media-mtx/page/mediamtx-quick-start) to initial steps

## Update `mediamtx.yml`

Update the follow parameters in the yaml:
- `rtsp: yes` : enable RTSP
- `rtspTransports: [udp, multicast, tcp]` : include supported protocols in array
- `rtspAddress: :12345` : specify the port (hostname is not required and doesn't seem to work - haven't figured out how)
- `rtspsAddress: :12346` : specify the port for secured connection
-  `paths:`
   - `stm:`
     - `runOnInit: ffmpeg -re -stream_loop -1 -i [video file] -c copy -f rtsp rtsp://[host]:[port]/[path]` specify ffmpeg to stream to mediamtx server
   - `rdt:`
     - `source: rtsp://[host]:[port]/[path]`
    
## Ensure ffmpeg is installed and added to PATH

Refer to:
- [Hostinger Tutorial](https://www.hostinger.com/tutorials/how-to-install-ffmpeg)
- [Geeks for Geeks](https://www.geeksforgeeks.org/how-to-install-ffmpeg-on-windows/)
- [PhoenixNAP](https://phoenixnap.com/kb/ffmpeg-windows)

## Running MediaMTX

As MediaMTX is now configured to stream RTSP, you can simply execute `.\mediamtx.exe` or equivalent.