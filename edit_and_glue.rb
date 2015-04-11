def check_snips
	Snippet.first
end


def glue_intermediate_files_and_normal_audio

	p "******"
	p "glue_intermediate_files_and_normal_audio"
	p "******"

	# #2D concatenate the files creatd using the below format 
		# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
	make_dir_if_none "#{@editsdir}/#{@playlist_name}", "tmp"
	dir = "#{@editsdir}/#{@playlist_name}/tmp"

	@temp_video_files = '"' + "concat:" + Snippet.selected.map(&:temp_file_location).join("|") + '"'
	# @normal_audio_files_ts = '"' + "concat:" + @selectedsnippets.map(&:normal_audio_file_location).join("|") + '"'
	@normal_audio_files_wav = "'" + Snippet.selected.map(&:normal_audio_file_location).join("' '") + "'"

	p @temp_video_files
	


	`ffmpeg -i #{@temp_video_files} -c copy -y '#{dir}/_video.mp4'` #glue video 
	# # `ffmpeg -i #{@normal_audio_files} -vn -acodec 'copy' -y '#{dir}/_audio.mp2'`  #glue audio

	`sox #{@normal_audio_files_wav} '#{dir}/_audio.wav'`

	make_dir_if_none Dir.pwd, "videos_final" #make dir
	make_dir_if_none @finaldir, @playlist_name #make dir

	# glue them together ORDER IMPORTANT::: AUDIO then VIDEO
	command_xfaded = "ffmpeg -i '#{dir}/_audio.wav' -i '#{dir}/_video.mp4' -y '#{Dir.pwd}/videos_final/xfaded_#{@playlist_name}.mp4' -loglevel quiet" 
	command = "ffmpeg -i '#{dir}/_audio.wav' -i '#{dir}/_video.mp4' -y '#{Dir.pwd}/videos_final/#{@playlist_name}/#{@playlist_name}.mp4' -loglevel quiet"
	
	command = command_xfaded if @@xfade
	system(command)

	# clean up
	# `rm '#{dir}/_video.mp4'`
	# `rm '#{dir}/_audio.wav'`

end


def process_xfaded_ts_to_mp4

	p "******"
	p "process_xfaded_ts_to_mp4"
	p "******"

	infile = "#{Dir.pwd}/video_edits/#{@playlist_name}/xfaded_video.ts"
	final_xfaded_mp4 = "#{Dir.pwd}/video_edits/#{@playlist_name}/xfaded_video.mp4"

	make_dir_if_none "#{Dir.pwd}/videos_final", "#{@playlist_name}" #make dir
	
	rule = Rule.find_by("xfade_ts='#{infile}'")
	rule.xfade_mp4 = final_xfaded_mp4
	rule.save!

	`ffmpeg -i '#{infile}' -acodec copy -vcodec copy -y '#{final_xfaded_mp4}' -loglevel quiet`
end

def glue_crossfaded_video_and_normal_audio

	p "******"
	p "glue_crossfaded_video_and_normal_audio"
	p "******"

	mp4_file = "#{Dir.pwd}/video_edits/#{@playlist_name}/xfaded_video.mp4"
	final_video_and_audio_file = "#{Dir.pwd}/videos_final/#{@playlist_name}/final_xfaded_video_and_audio.mp4"

	dir = "#{@editsdir}/#{@playlist_name}/tmp"

	# @normal_audio_files_wav = "'" + Snippet.selected.map(&:normal_audio_file_location).join("' '") + "'"
	# `sox #{@normal_audio_files_wav} '#{dir}/_audio.wav'` 
	
	@trimmed_audio_files_wav = "'" + Snippet.selected.map(&:trimmed_audio).join("' '") + "'"
	`sox --no-show-progress #{@trimmed_audio_files_wav} '#{dir}/_audio.wav'`

	# glue them together ORDER IMPORTANT::: AUDIO then VIDEO
	message = "ffmpeg -i '#{dir}/_audio.wav' -i '#{mp4_file}' -y '#{final_video_and_audio_file}' -loglevel quiet"

	p message
	system(message)

	rule = Rule.find_by("xfade_mp4='#{mp4_file}'")
	rule.final_mp4 = final_video_and_audio_file
	rule.save!


	# clean up
	# `rm '#{dir}/_video.mp4'`
	# `rm '#{dir}/_audio.wav'`
end

def test_gluing

	p "******"
	p "test_gluing"
	p "******"

	audio = "/Users/JW/Dropbox/T10/SBRI/_code/video_edits/3rd person present tense (303)/xfaded_audio.wav"
	video = "/Users/JW/Dropbox/T10/SBRI/_code/video_edits/3rd person present tense (303)/xfaded_video.mp4"
	final =  "/Users/JW/Dropbox/T10/SBRI/_code/video_edits/3rd person present tense (303)/xfaded_final.mp4"


	`ffmpeg -i '#{audio}' -i '#{video}' -y '#{final}' -loglevel quiet` 
end





def edit_videos (directory,start,dur)


 	Dir.glob("#{directory}/*.mp4").each do |item|

 	name = File.basename(item)
	
 	# make edit dir if none
 	make_dir_if_none(directory,"edits")

	# convert time to h:m:s format
	starttime,duration = convert_to_time_format(start,dur) 
  
 #  #save two second cut of each video to edits folder starting at 00:01:30
	command = "ffmpeg -i '#{item}' -ss #{starttime} -t #{duration} -async 1 '#{directory}/edits/#{duration}#{name}'"

	system( command )

 end
end

def add_files_to_text_doc (name,directory)
	# 1.create a list from the file names
		file = open("#{directory}/#{name}.txt",'w')
		Dir.glob("#{directory}/*.mp4").each do |item|

			next if item == "#{@directory}/." or item == "#{directory}/.." or item=="#{directory}/.DS_Store"
			s = "file '#{item}'"
			file.puts(s)
		end
		file.close
		return "#{directory}/#{name}.txt"
end

def make_intermediate_files(f,directory,name)

	file=open(f)
	i = 0
	@inter_files = []

	file.each do |f|
		i+=1
		istring = i.to_s
		f = f[5..-2]


		inter_name = "#{directory}/intermediate#{istring}.ts"
		@inter_files << inter_name

		# Make sure that all files have same aspect ratio
		# http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg

		file_with_ar = "ffmpeg -i #{f} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 #{inter_name}"
		system(file_with_ar)

	end
	file.close
end

def work_the_av_magic

	#2D concatenate the files creatd using the below format 
		# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
		
	#VIDEO, no audio
	str = ''
	@inter_files.each{|name| str+=name+'|'}
	str.chop! # remove last pipe
	str = '"concat:' + str + '"'
	video_s = "ffmpeg -i #{str} -c copy '#{directory}/video.mp4'"

	# concatenate the video files 
	p video_s
	system(video_s)


	#AUDIO, no video
	str = ''
	@inter_files.each{|name| str+=name+'|'}
	str.chop! # remove last pipe
	str = '"concat:' + str + '"'
	audio_s = "ffmpeg -i #{str} -vn -acodec 'copy' '#{directory}/audio.mp2'"

	# concatenate the video files 
	p audio_s
	system(audio_s)

	#mashem together
	total_s = "ffmpeg -i '#{directory}/video.mp4' -i '#{directory}/audio.mp2' '#{directory}/output.mp4'"
	p total_s
	system(total_s)		


end