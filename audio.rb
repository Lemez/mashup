
def normalize_audio
	
	make_dir_if_none "#{@editsdir}/#{PLAYLISTNAME}","normalized"

	Dir.glob("#{@editsdir}/#{PLAYLISTNAME}/tmp/*.ts").each do |temp_file|

		normal_dir = "#{@editsdir}/#{PLAYLISTNAME}/normalized"

		i_start = temp_file.rindex("/")+1
		i_end = temp_file.rindex(".")
		namestring = temp_file[i_start...i_end]

		audio_file = "'#{normal_dir}/#{namestring}-clean.wav'"
		normal_file = "'#{normal_dir}/#{namestring}-normal.wav'"
	
		`ffmpeg -i '#{temp_file}' -ac 2 -y #{audio_file}` unless File.exists?(audio_file)
		`sox --show-progress #{audio_file} #{normal_file} norm -0.2` unless File.exists?(normal_file)

		`rm #{audio_file}` if File.exists?(audio_file)

		# final_file = "'#{normal_dir}/#{namestring}-normal.mp4'"
		# video_file = "'#{normal_dir}/#{namestring}-clean.mp4'"
		# text_file = "#{namestring}-audio.txt"

		# `ffmpeg -i '#{temp_file}' -map 0:0 -vcodec copy -y #{video_file}`
		# `ffmpeg -i #{video_file} -i #{normal_file} -vcodec copy #{final_file}`

		

	end
end
