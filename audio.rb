def play_sound value
	`afplay #{Dir.pwd}/audio/true.aiff`if value==true
end

def normalize_audio

	p "******";p "normalize_audio";p "******"

	@count = 0

	Snippet.selected.each do |snippet|

		temp_file = snippet.location
		i_start = temp_file.rindex("/")+1
		i_end = temp_file.rindex(".")
		namestring = temp_file[i_start...i_end]
		# sync_offset = 0.3 # correct sync error
		# sync_offset = 0 if @count==0

		@count==0 ? sync_offset = 0: sync_offset = 0
		 p "first" if @count==0 

		duration = snippet.clip_duration

		normal_dir = "#{@editsdir}/normalized"
		
		outfile = "#{normal_dir}/#{namestring}-sync_offset.mp4"
		audio_file = "#{normal_dir}/#{namestring}-clean.aiff"
		normal_file = "#{normal_dir}/#{namestring}-normal.aiff"
		mp2_file = "#{normal_dir}/#{namestring}-normal.mp2"
		# normal_ts = "#{normal_dir}/#{namestring}-normal.ts"

			# use count to determine first file or later ones
		# `sox --no-show-progress #{audio_file} '#{normal_file}' rate 44100 norm fade 0.5 #{duration} 0.5` 
		unless File.exists?("mp2_file")
			`ffmpeg -i '#{temp_file}' -itsoffset #{sync_offset} -i '#{temp_file}' -map 0:0 -map 1:1 -c:v copy -c:a copy '#{outfile}' -loglevel quiet` unless File.exists?("#{outfile}")
			`ffmpeg -i '#{outfile}' -ac 2 -y '#{audio_file}' -loglevel quiet`  unless File.exists?("#{audio_file}")
			`sox --no-show-progress '#{audio_file}' '#{normal_file}' rate 44100 norm` unless File.exists?("#{normal_file}")
			`ffmpeg -i '#{normal_file}' -ac 2 -y '#{mp2_file}' -loglevel quiet` unless File.exists?("#{mp2_file}")
		end

		# `ffmpeg -i '#{normal_file}' -ac 2 -y '#{normal_ts}'` unless File.exists?(normal_ts)
		# p "#{temp_file}: #{duration}, with clip: #{snippet.clip_duration} and sentence: #{snippet.sentence_duration}"

		snippet.normal_audio_file_location = mp2_file
		snippet.normal_audio_duration = duration
		snippet.save!

		`rm '#{outfile}'` if File.exists?("#{outfile}")
		`rm '#{audio_file}'` if File.exists?("#{audio_file}")
		`rm '#{normal_file}'` if File.exists?("#{normal_file}")

		@count +=1

	end
end


########## OLD


def create_silence

	make_dir_if_none "#{@editsdir}/#{@playlist_name}","silence"
	shhh = "'#{@editsdir}/#{@playlist_name}/silence/silence.wav'"

	`sox -n -r 44100 -c 2 shhh trim 0.0 0.001`

end

def trim_audio

	snippets=Snippet.selected

	normal_dir = "#{@editsdir}/#{@playlist_name}/normalized"
	
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

	p "***********";p "create_normalized_snippets";p "***********"


	# To merge specific streams (audio or video) from several files use -i option for each input and -map input_index[:stream_index]. For example, the following command merges the first stream of the first input with the second input and keeps the codecs:

	# ffmpeg -i input.mkv -i input_audio.ogg -map 0:0 -map 1 \
 #    -vcodec copy -acodec copy output.mkv


 	snippets=Snippet.selected

 	snippets.each do |snip|
 		ts_file = snip.temp_file_location
		normal_file = snip.normal_audio_file_location

		dir,filename = File.split(ts_file)
		location,extension = filename.split(".")
		outfile = "#{dir}/normal-" + location + ".ts"
			

		`ffmpeg -i '#{ts_file}' -itsoffset #{sync_offset} -i '#{normal_file}' -map 0:0 -map 1:1 -c:v copy -c:a copy '#{outfile}' -y`
		snip.normal_snippet_file_location = outfile
		snip.save!
	end


end


