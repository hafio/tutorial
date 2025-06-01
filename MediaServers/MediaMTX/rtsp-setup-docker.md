# Overview

Quick start to get MediaMTX running in Docker.

Refer to:
- [MediaMTX Quick Start](https://bookstack.handy:26654/books/media-mtx/page/mediamtx-quick-start)
- [RTSP stream via MediaMTX](https://bookstack.handy:26654/books/media-mtx/page/rtsp-server-via-mediamtx)
- [Media MTX Documentation](https://github.com/bluenviron/mediamtx/blob/main/README.md#webrtc-servers)
- [Yealowflicker](https://yeahlowflicker.com/blog/setting-up-a-rtsp-server-with-mediamtx)

# Required Files

## `mediamtx.yml`
> as MediaMTX has quite a number of functionalities (not covered in this doc), modify only the lines shown below to get RTSP server up and running
```
rtspAddress: :14888
.
.
.
paths:
# repeat below for different paths/urls and different videos
# ffmpeg output should match above "rtspAddress" port
  test1:
    runOnInit: ffmpeg -re -stream_loop -1 -i test.mp4 -c copy -f rtsp rtsp://localhost:14888/test1

# settings under "all_others" will be applied to all paths not matching any entry above    
  all_others:
```

## `docker-compose.yaml`
```
name: project-mediamtx

services:
  mediamtx:
    container_name: MediaMTX
    image: bluenviron/mediamtx:latest-ffmpeg
    restart: always
    volumes:
      - "./mediamtx.yml:/mediamtx.yml"
      - "./test.mp4:/test.mp4"
      - "./out.mp4:/out.mp4"
      - "./okinawa.mp4:/okinawa.mp4"
    ports:
      - 14888:14888
```
> - `mediamtx` binary is in `/` directory
> - `mediamtx.yml` should be mapped to `/mediamtx.yml`
> - media files specified in `mediamtx.yml` should specify the path (absolute or relative to `/`)
> - media files need to be mapped under `volumes`
> - `port` mapping should reflect the rtspAddress

## media files for streaming

Take note of the codec - use ffmpeg to transcode if required, or use a readily transcoded media file. Examples used so far are `libx265`.

# Run

Execute `docker-compose up -d` to start containers. Test with VLC to correct `rtsp://hostname:port`