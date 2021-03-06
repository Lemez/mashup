def make_image
	p "* make_image *"
	make_dir_if_none @imgdir, @playlist_name

	@image = "#{@imgdir}/#{@playlist_name}/#{@playlist_name}"

	rule,example = NODE_DESCRIPTIONS[@playlist_name][0],NODE_DESCRIPTIONS[@playlist_name][1]
	label = "label: #{rule}\n\n \'#{example}\'"

	`convert \
	-size 720x406 \
	-background '#FBF3A0' \
	 -fill '#7F7F7F' \
	 -gravity center \
	 -pointsize 30 \
	-font '#{@fontdir}/OpenDyslexic-Regular.otf' \
	 '#{label}' \
	'#{@image}.png' `

end

def make_game_image
	p "* make_game_image *"
	make_dir_if_none @gamesdir, @game_name

	@image = "#{@gamesdir}/#{@game_name}/#{@game_name}"

	rule,example = GAME_DESCRIPTIONS[@game_name][0],GAME_DESCRIPTIONS[@game_name][1]
	label = "label: #{rule}\n\n#{example}"

	`convert \
	-size 720x406 \
	-background '#F2F2F2' \
	 -fill '#7F7F7F' \
	 -gravity center \
	 -pointsize 30 \
	-font '#{@fontdir}/OpenDyslexic-Regular.otf' \
	 '#{label}' \
	'#{@image}.png' `
end

def add_logo
	p "* add_logo *"

	@logo = "#{@imgdir}/logo.png"
	@image_w_logo = "#{@image}_logo.png"

	`convert #{@image}.png \
   '#{@logo}' -size 720x406 \
    -gravity North  -composite \
   '#{@image_w_logo}' `

   `rm #{@image}.png`
end

def turn_img_to_video type
	p "* turn_img_to_video *"

	type=="game" ? @card_length=GAME_CARD_LENGTH : @card_length=FEATURE_CARD_LENGTH

	@image_video = "#{@image}_logo.mp4"

	`ffmpeg -loop 1 -i #{@image_w_logo} -c:v libx264 -t #{@card_length} -pix_fmt yuv420p #{@image_video} -y`
	`rm #{@image_w_logo}`

end

def add_silence_to_image_video
	p "* add_silence_to_image_video *"
	@silence = "#{Dir.pwd}/audio/silence.wav"
	@image_video_silence  = "#{@image}_logo_silence.mp4"
	`ffmpeg -i '#{@image_video}' -i '#{@silence}'  '#{@image_video_silence}' -shortest -y`
	`rm #{@image_video}`
end

def add_img_video_and_pic_video
	p "* add_img_video_and_pic_video *"

	tmp1 = "#{@testdir}/#{@playlist_name}_intermediate1.ts"
	tmp2 = "#{@testdir}/#{@playlist_name}_intermediate2.ts"

	subs_vid = "#{@finaldir}/#{@playlist_name}/#{@playlist_name}_subs.mp4"
	final = "#{@finaldir}/#{@playlist_name}/#{@playlist_name}_subs_logo.mp4"

	`ffmpeg -i #{@image_video_silence} -c copy -bsf:v h264_mp4toannexb -f mpegts '#{tmp1}' -shortest -loglevel quiet -y`
	`ffmpeg -i '#{subs_vid}' -c copy -bsf:v h264_mp4toannexb -f mpegts '#{tmp2}' -shortest -loglevel quiet  -y`
	`ffmpeg -i "concat:#{tmp1}|#{tmp2}" -c copy -bsf:a aac_adtstoasc #{final} -shortest -loglevel quiet  -y`

	@rule = Rule.find_by(:rule_name => "#{@playlist_name}")

	@rule.final_subs_logo = final
	@rule.completed = true
	@rule.save!

	p "Saved - final logo video for: #{@rule.rule_name}" if @rule.save!

	play_sound true  # add a sound to tell me it is completed

	`rm #{tmp1}`
	`rm #{tmp2}`
	`rm #{@image_video_silence}`

	sleep 3
	
end

def add_img_video_and_game_video
	p "* add_img_video_and_pic_video *"

	tmp1 = "#{@testdir}/#{@game_name}_intermediate1.ts"
	tmp2 = "#{@testdir}/#{@game_name}_intermediate2.ts"

	final = "#{@gamesdir}/#{@game_name}/#{@game_name}_with_intro_card.mp4"
	
	if GAME_CARD_ON
		`ffmpeg -i #{@image_video_silence} -c copy -bsf:v h264_mp4toannexb -f mpegts '#{tmp1}' -shortest -loglevel quiet -y`
		`ffmpeg -i '#{@game_location}' -c copy -bsf:v h264_mp4toannexb -f mpegts '#{tmp2}' -shortest -loglevel quiet  -y`
		`ffmpeg -i "concat:#{tmp1}|#{tmp2}" -c copy -bsf:a aac_adtstoasc #{final} -shortest -loglevel quiet  -y`

		play_sound true  # add a sound to tell me it is completed

		`rm #{tmp1}`
		`rm #{tmp2}`
		`rm #{@image_video_silence}`

		sleep 3
	end

	return final
	

end




# def trim_vid
# 	vid = "#{Dir.pwd}/_out.mp4"
# 	test = "#{@testdir}/_out_clip.mp4"
# 	`ffmpeg -i #{vid} -ss 00:00:00.00 -t 3 #{test}`
# end






