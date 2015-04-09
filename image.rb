def make_image

	make_dir_if_none @imgdir, @playlist_name

	@image = "#{@imgdir}/#{@playlist_name}/#{@playlist_name}.png"
	feature_has_p = "Feature_Has_Phoneme_"

	if @playlist_name.include?(feature_has_p)
		sound,spelling = @playlist_name[feature.length..-1].split("_Spelled_")
		label = "label: Words that sound like \n#{sound.upcase}\n but look like \n#{spelling.upcase}"
	else
		label='"#{@playlist_name}"'
	end

	`convert \
	-size 720x406 \
	-background '#FBF3A0' \
	 -fill '#7F7F7F' \
	 -gravity center \
	 -pointsize 30 \
	-font '#{@fontdir}/OpenDyslexic-Regular.otf' \
	 #{label} \
	'#{@image}' `

end

def add_logo

	@logo = "#{@imgdir}/logo.png"
	@image_w_logo = "#{@image}_logo.png"

	`convert #{@image} \
   '#{@logo}' -size 720x406 \
    -gravity North  -composite \
   '#{@output}' `
end

def turn_img_to_video

	@image_video = "#{@image}_logo.mp4"

	`ffmpeg -loop 1 -i #{@image_w_logo} -c:v libx264 -t 2 -pix_fmt yuv420p #{@image_video}`
end

def add_img_video_and_pic_video

	tmp1 = "#{@testdir}/_intermediate1.ts"
	tmp2 = "#{@testdir}/_intermediate2.ts"

	subs_vid = "#{@finaldir}/#{@playlist_name}/#{@playlist_name}_subs.mp4"
	final = "#{@finaldir}/#{@playlist_name}/#{@playlist_name}_subs_logo.mp4"

	`ffmpeg -i '#{@image_video}' -c copy -bsf:v h264_mp4toannexb -f mpegts '#{tmp1}'`
	`ffmpeg -i '#{subs_vid}' -c copy -bsf:v h264_mp4toannexb -f mpegts '#{tmp2}'`
	`ffmpeg -i "concat:#{tmp1}|#{tmp2}" -c copy -bsf:a aac_adtstoasc #{final}`

end


def trim_vid
	vid = "#{Dir.pwd}/_out.mp4"
	test = "#{@testdir}/_out_clip.mp4"
	`ffmpeg -i #{vid} -ss 00:00:00.00 -t 3 #{test}`
end






