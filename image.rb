def make_image

	@image = "#{@testdir}/whatever.png"
	feature = "Feature_Has_Phoneme_"

	if @playlist_name.include?(feature)
		sound,spelling = @playlist_name[feature.length..-1].split("_Spelled_")
	end

	`convert \
	-size 720x406 \
	-background '#FBF3A0' \
	 -fill '#7F7F7F' \
	 -gravity center \
	 -pointsize 30 \
	-font '#{@fontdir}/OpenDyslexic-Regular.otf' \
	 'label: Words that sound like \n#{sound.upcase}\n but look like \n#{spelling.upcase} ' \
	'#{@image}' `

end

def add_logo

	@logo = "#{@imgdir}/logo.png"
	@output = "#{@testdir}/whatever_logo.png"

	`convert #{@image} \
   '#{@logo}' -size 720x406 \
    -gravity North  -composite \
   '#{@output}' `

end

def trim_vid
	vid = "#{Dir.pwd}/_out.mp4"
	test = "#{@testdir}/_out_clip.mp4"
	`ffmpeg -i #{vid} -ss 00:00:00.00 -t 3 #{test}`
end

def turn_img_to_video
	
	pic = "#{@testdir}/whatever_logo.png"
	ov = "#{@testdir}/_pic_vid.mp4"

	`ffmpeg -loop 1 -i #{pic} -c:v libx264 -t 2 -pix_fmt yuv420p #{ov}`
end


def add_img_video_and_pic_video


	test = "#{@testdir}/_out_clip.mp4"
	picvid = "#{@testdir}/_pic_vid.mp4"
	tmp1 = "#{@testdir}/_intermediate1.ts"
	tmp2 = "#{@testdir}/_intermediate2.ts"
	ov = "#{@testdir}/_test_w_img.mp4"


	`ffmpeg -i #{picvid} -c copy -bsf:v h264_mp4toannexb -f mpegts #{tmp1}`
	`ffmpeg -i #{test} -c copy -bsf:v h264_mp4toannexb -f mpegts #{tmp2}`
	`ffmpeg -i "concat:#{tmp1}|#{tmp2}" -c copy -bsf:a aac_adtstoasc #{ov}`

end


