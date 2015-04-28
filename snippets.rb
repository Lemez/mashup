def create_snippets_from_sentences

	p "* create_snippets_from_sentences *"

	@full_sentence = ''
	@title = ''
	@saved_videos = Video.all.is_saved

	@sentences_to_extract[-@number_of_clips..-1].each do |sentence|
		
		next if sentence.adult==true
		
		video_id = sentence.video_id
		sentence_id = sentence.id
		rule_name = sentence.rule_name

		v = @saved_videos.find_by("id=#{video_id}")

		artist =v.artist
		title = v.title
		offset_in_ms = v.offset
		full_sentence = sentence.full_sentence

		full_video_location = "'#{@videodir}/#{v.location}'"

		s = sentence.start_at + offset_in_ms.to_i
		e = sentence.end_at
		d = sentence.duration + 1000 
		d += 1000 if d < 3000

		d += 1500 if title=="billie jean"
		d += 1000 if title=="royals"
		d += 2000 if title == "when youre gone"

		next if @playlist_name=="string_ear" and title=="wild heart"
		# next if d > MAX_DUR
		# next if d < MIN_DUR
		# next if sentence.full_sentence.split(" ").length < 4
		# next if @full_sentence==full_sentence
		# next if EXCLUDED.include?(title)

		if INTERRUPTIONS.has_key?(v.location)
			p "start was #{s}"
			s += INTERRUPTIONS[v.location][1] if s > INTERRUPTIONS[v.location][0]
			p "start is now #{s}"
		end

		start_secs = convert_to_seconds_and_ms(s)
		end_secs = convert_to_seconds_and_ms(e)
		duration_secs = convert_to_seconds_and_ms(d)

		location_string = "#{@editsdir}/snippets/#{artist}-#{title}-#{s.to_s}-#{d.to_i.to_s}.mp4"

		s = Snippet.create(:video_id => video_id, :sentence_duration => d, :clip_duration => duration_secs, :sentence_id => sentence_id, :full_video_location => full_video_location, :location => location_string, :rule_name => rule_name )	

		# sync_offset = 0.01 # 10ms, correcting sync error

		# save cut of each video to rule edits folder
		command = "ffmpeg -i #{full_video_location}  -ss #{start_secs} -t #{duration_secs} -async 1 -threads 0 '#{location_string}' -shortest -y -loglevel quiet"
		
		unless File.exists?(location_string)
			
			p "Processing #{artist} #{title} with duration #{d.to_s} and clip=#{start_secs}:#{duration_secs} "
			system (command) 
		else
			p "Existing: #{artist} #{title} with duration #{d.to_s} "
		end

		@full_sentence=full_sentence
		@title=title
	end
	
end


def show_current_snippets

	p "* show_current_snippets *"

	Snippet.selected.each do |s|
		sentence = Sentence.find_by("id=#{s.sentence_id}")
		p "#{sentence.full_sentence}"
		p "#{s.location}"
		p "#{s.sentence_duration}"
		p "#{s.clip_duration}"
	end
end

def create_snippets_text_file 

	p "* create_snippets_text_file *"
		@snip_text_file = "#{@editsdir}/#{@playlist_name}_snippets_file.txt"
		file = open(@snip_text_file,'w')
		Snippet.selected.each { |item| file.puts("file '#{item.location}'") }
		file.close
end


def create_intermediate_files_from_snippets

	p "* create_intermediate_files_from_snippets *"
		
	File.readlines(@snip_text_file).each do |url|

		snippet_url = url[5..-2]
		@snip = Snippet.find_by("location=#{snippet_url}")

		snippet_s_id = @snip.sentence_id
		sentence = Sentence.find_by("id=#{snippet_s_id}")
		video = Video.find_by("id=#{sentence.video_id}")
		
		artist,title = video.artist.gsub(" ","_"), video.title.gsub(" ","_")
		words = sentence.full_sentence.gsub(/[^0-9a-z ]/i, '').gsub(" ","_")

		duration = @snip.sentence_duration

		inter_name = "#{@editsdir}/tmp/#{artist}-#{title}-#{words}-#{duration.to_i}.ts"

	# Make sure that all files have same aspect ratio # http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg
		`ffmpeg -i #{snippet_url} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 -y -shortest '#{inter_name}' -loglevel quiet`

		@snip.temp_file_location = inter_name	

		p "Saved #{@snip.id} with #{@snip.temp_file_location}" if @snip.save!
		
	end
end