# https://sites.google.com/a/asu.edu/wireless-video-sensor/video/how-to-setup-full-ffmpeg-tools-in-ubuntu-11-10/useful-ffmpeg-commands

#Create ordered array of video durations

#  Add text to video at each start time and leave it on for 2 seconds

#Begin at 1:00

def add_titles_to_video

	@durations_array = @sentences_to_extract.map{|s| convert_to_duration(s.start_at + (CARD_LENGTH*1000))}

	p @durations_array
	# @durations_array.each |duration|

	# end
end



# ffmpeg -y -i in_video.mp4 \
#        -vf "drawtext=fontcolor=white: fontsize=16: \
#                      fontfile=/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf: \
#                      box=1:boxcolor=black@0.3:x=50:y=20: \
#                      timecode='00\\:01\\:00\\;02':rate=30000/1001" \
#         out.mp4
