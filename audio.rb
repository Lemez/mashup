def create_silence

	make_dir_if_none "#{@editsdir}/#{PLAYLISTNAME}","silence"
	shhh = "'#{@editsdir}/#{PLAYLISTNAME}/silence/silence.wav'"

	`sox -n -r 44100 -c 2 shhh trim 0.0 0.5`

end

def trim_audio
	@snippets=Snippet.all

	normal_dir = "#{@editsdir}/#{PLAYLISTNAME}/normalized"
	

	@snippets.each do |snippet|

		normal_file = snippet.normal_audio_file_location
		trimmed_file = normal_file[0..-11] + "trimmed.wav"

		new_duration = snippet.clip_duration - FADELENGTH
		`sox --no-show-progress '#{normal_file}' '#{trimmed_file}' trim 0 #{new_duration} `

		trimmed_file_duration = `soxi -D #{trimmed_file}`[0..-2].to_f

		snippet.trimmed_audio = trimmed_file
		snippet.trimmed_file_duration = trimmed_file_duration
		snippet.save!
	end
end

def normalize_audio

	p "******"
	p "normalize_audio"
	p "******"

	make_dir_if_none "#{@editsdir}/#{PLAYLISTNAME}","normalized"

	@count = 0

	Snippet.all.each do |snippet|

		temp_file = snippet.temp_file_location

		normal_dir = "#{@editsdir}/#{PLAYLISTNAME}/normalized"

		i_start = temp_file.rindex("/")+1
		i_end = temp_file.rindex(".")
		namestring = temp_file[i_start...i_end]

		audio_file = "'#{normal_dir}/#{namestring}-clean.wav'"
		normal_file = "#{normal_dir}/#{namestring}-normal.wav"

		# normal_ts = "#{normal_dir}/#{namestring}-normal.ts"


		`ffmpeg -i '#{temp_file}' -ac 2 -y #{audio_file} -loglevel quiet` 

		duration = snippet.clip_duration

		`sox --no-show-progress #{audio_file} '#{normal_file}' rate 44100 norm fade 0.5 #{duration} 0.5` 
	

		# `ffmpeg -i '#{normal_file}' -ac 2 -y '#{normal_ts}'` unless File.exists?(normal_ts)

		


		p "#{temp_file}: #{duration}, with clip: #{snippet.clip_duration} and sentence: #{snippet.sentence_duration}"

		snippet.normal_audio_file_location = normal_file
		snippet.normal_audio_duration = snippet.clip_duration
		# p snippet.normal_audio_duration

		snippet.save!

		`rm #{audio_file}`
		# `rm "#{normal_file}"` if File.exists?("#{normal_file}")

		# final_file = "'#{normal_dir}/#{namestring}-normal.mp4'"
		# video_file = "'#{normal_dir}/#{namestring}-clean.mp4'"
		# text_file = "#{namestring}-audio.txt"

		# `ffmpeg -i '#{temp_file}' -map 0:0 -vcodec copy -y #{video_file}`
		# `ffmpeg -i #{video_file} -i #{normal_file} -vcodec copy #{final_file}`

		@count +=1

		

	end

	p Snippet.all.map(&:normal_audio_duration)
end
