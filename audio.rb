def create_silence

	make_dir_if_none "#{@editsdir}/#{PLAYLISTNAME}","silence"
	shhh = "'#{@editsdir}/#{PLAYLISTNAME}/silence/silence.wav'"

	`sox -n -r 44100 -c 2 shhh trim 0.0 0.5`

end

def trim_audio

	snippets=Snippet.all

	normal_dir = "#{@editsdir}/#{PLAYLISTNAME}/normalized"
	
	snippets.each do |snip|

		normal_file = snip.normal_audio_file_location
		trimmed_file = normal_file[0..-11] + "trimmed.wav"

		new_duration = snip.clip_duration - FADELENGTH
		`sox --no-show-progress '#{normal_file}' '#{trimmed_file}' trim 0 #{new_duration} `

		trimmed_file_duration = `soxi -D #{trimmed_file}`[0..-2].to_f

		snip.trimmed_audio = trimmed_file
		snip.trimmed_file_duration = trimmed_file_duration
		snip.save!
	end
end

def create_normalized_snippets

	p "***********"
	p "create_normalized_snippets"
	p "***********"


	# To merge specific streams (audio or video) from several files use -i option for each input and -map input_index[:stream_index]. For example, the following command merges the first stream of the first input with the second input and keeps the codecs:

	# ffmpeg -i input.mkv -i input_audio.ogg -map 0:0 -map 1 \
 #    -vcodec copy -acodec copy output.mkv


 	snippets=Snippet.all

 	snippets.each do |snip|
 		ts_file = snip.temp_file_location
		normal_file = snip.normal_audio_file_location

		dir,filename = File.split(ts_file)
		location,extension = filename.split(".")
		outfile = "#{dir}/normal-" + location + ".ts"

		`ffmpeg -i '#{ts_file}' -i '#{normal_file}' -map 0:0 -map 1 -vcodec copy -acodec copy '#{outfile}' -y`
		snip.normal_snippet_file_location = outfile
		snip.save!
	end


end

def normalize_audio

	p "******"
	p "normalize_audio"
	p "******"

	make_dir_if_none "#{@editsdir}/#{PLAYLISTNAME}","normalized"

	@count = 0

	Snippet.all.each do |snippet|

		temp_file = snippet.location

		normal_dir = "#{@editsdir}/#{PLAYLISTNAME}/normalized"

		i_start = temp_file.rindex("/")+1
		i_end = temp_file.rindex(".")
		namestring = temp_file[i_start...i_end]

		audio_file = "#{normal_dir}/#{namestring}-clean.aiff"
		normal_file = "#{normal_dir}/#{namestring}-normal.aiff"
		mp2_file = "#{normal_dir}/#{namestring}-normal.mp2"

		# normal_ts = "#{normal_dir}/#{namestring}-normal.ts"

		duration = snippet.clip_duration

		# use count to determine first file or later ones
		# `sox --no-show-progress #{audio_file} '#{normal_file}' rate 44100 norm fade 0.5 #{duration} 0.5` 

		unless File.exists?(mp2_file)
			`ffmpeg -i '#{temp_file}' -ac 2 -y '#{audio_file}' -loglevel quiet`  #unless File.exists?("'#{audio_file}'")
			`sox --no-show-progress '#{audio_file}' '#{normal_file}' rate 44100 norm` #unless File.exists?("'#{normal_file}'")
			`ffmpeg -i '#{normal_file}' -ac 2 -y '#{mp2_file}' -loglevel quiet` 
		else
			p "'#{mp2_file}' exists" 
		end

		# `ffmpeg -i '#{normal_file}' -ac 2 -y '#{normal_ts}'` unless File.exists?(normal_ts)

		
		p "#{temp_file}: #{duration}, with clip: #{snippet.clip_duration} and sentence: #{snippet.sentence_duration}"

		snippet.normal_audio_file_location = mp2_file
		snippet.normal_audio_duration = snippet.clip_duration
		# p snippet.normal_audio_duration

		snippet.save!

		`rm '#{audio_file}'`
		`rm '#{normal_file}'`
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
