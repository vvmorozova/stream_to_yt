GST_DEBUG=3 gst-launch-1.0\
	\
	audiotestsrc ! voaacenc ! mux. \
	v4l2src device='/dev/video0' io-mode=2 ! image/jpeg, width=1280, height=720, framerate=30/1 !\
	nvjpegdec ! 'video/x-raw, width=1280, height=720, framerate=30/1' !\
	nvvidconv ! 'video/x-raw(memory:NVMM), width=1280, height=720, framerate=30/1' ! queue max-size-bytes=0 max-size-buffers=0 ! glue. \
	rtspsrc location='rtsp://<camera_ip>/Channel1 ' protocols=tcp latency=500 ! rtph264depay ! h264parse ! nvv4l2decoder !\
	nvvidconv left=420 right=1500 top=0 bottom=1080 ! 'video/x-raw(memory:NVMM), width=1920, height=1080, framerate=25/1' ! queue max-size-bytes=0 max-size-buffers=0 ! glue. \
	videotestsrc pattern=2 is-live=true ! autovideoconvert ! glue. \
	nvcompositor name=glue \
	sink_0::xpos=691 sink_0::ypos=195 sink_0::width=1220 sink_0::height=691 \
	sink_1::xpos=0 sink_1::ypos=195 sink_1::width=691 sink_1::height=691 \
	sink_2::xpos=0 sink_2::ypos=886 sink_2::width=1920 sink_2::height=194 \
	background-w=1920 background-h=1080 background=0 ! \
	nvvidconv ! 'video/x-raw(memory:NVMM), width=1920, height=1080, framerate=25/1' ! nvv4l2h264enc bitrate='4500000' !\
	h264parse config-interval=1 disable-passthrough=true ! queue max-size-bytes=0 max-size-buffers=0 ! mux.\
	flvmux name=mux streamable=true ! rtmpsink location='rtmp://a.rtmp.youtube.com/live2/<stream_key> live=1 flashver=FME/3.0\20(compatible;\20FMSc\201.0)' &> debug_strm_cam+screen.txt

