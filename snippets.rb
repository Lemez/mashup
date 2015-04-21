def create_snippets_from_sentences

	p "****** create_snippets_from_sentences ******"


	@full_sentence = ''
	@title = ''
	@saved_videos = Video.all.is_saved

	@sentences_to_extract.each do |sentence|
		
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
		# d += 500 if d < 4000

		next if d > MAX_DUR
		# next if d < MIN_DUR

		start_secs = convert_to_seconds_and_ms(s)
		end_secs = convert_to_seconds_and_ms(e)
		duration_secs = convert_to_seconds_and_ms(d)

		location_string = "#{@editsdir}/snippets/#{artist}-#{title}-#{s.to_s}-#{d.to_i.to_s}.mp4"

		# define skipping conditions
		# next if sentence.full_sentence.split(" ").length < 4
		# next if @full_sentence==full_sentence

		# if EXCLUDED.include?(title) || d < MIN_DUR or d > MAX_DUR

		# 	p "Skipping #{artist} #{title} with duration #{d.to_s} "
		# 	next
		# end


		s = Snippet.create(:video_id => video_id, :sentence_duration => d, :clip_duration => duration_secs, :sentence_id => sentence_id, :full_video_location => full_video_location, :location => location_string, :rule_name => rule_name )	

		sync_offset = 0.01 # 10ms, correcting sync error

		# save cut of each video to rule edits folder
		command = "ffmpeg -i #{full_video_location}  -ss #{start_secs} -t #{duration_secs} -async 1 -threads 0 '#{location_string}' -y -loglevel quiet"
		
		# unless File.exists?(location_string)
			
			p "Processing #{artist} #{title} with duration #{d.to_s} and clip=#{start_secs}:#{duration_secs} "
			system (command) 
		# else
			# p "Existing: #{artist} #{title} with duration #{d.to_s} "
		# end

		@full_sentence=full_sentence
		@title=title
	end
	
end


def show_current_snippets

	p "****** show_current_snippets ******"
	# p "#{Snippet.selected.count} selected snippets"

	Snippet.selected.each do |s|
		id = s.sentence_id
		sentence = Sentence.find_by("id=#{id}")
		p "#{sentence.full_sentence}"
		p "#{s.location}"
		p "#{s.sentence_duration}"
		p "#{s.clip_duration}"
	end
end

def create_snippets_text_file 

	p "******"
	p "create_snippets_text_file"
	p "******"

		file = open("#{@editsdir}/#{@playlist_name}_snippets_file.txt",'w')
		Snippet.selected.each do |item|
			s = "file '#{item.location}'"
			file.puts(s)
		end
		file.close
end

def create_intermediate_files_from_snippets

	p "****** create_intermediate_files_from_snippets ******"

	myfile = "#{@editsdir}/#{@playlist_name}_snippets_file.txt"
		
	File.readlines(myfile).each do |url|

		name, extension = get_file_attributes url
		snippet_url = url[5..-2]
		@snip = Snippet.find_by("location=#{snippet_url}")
		snippet_s_id = @snip.sentence_id
		duration = @snip.sentence_duration
		sentence = Sentence.find_by("id=#{snippet_s_id}")
		video = Video.find_by("id=#{sentence.video_id}")
		words = sentence.full_sentence.gsub(/[^0-9a-z ]/i, '').gsub(" ","_")
		artist = video.artist.gsub(" ","_")
		title = video.title.gsub(" ","_")

		inter_name = "#{@editsdir}/tmp/#{artist}-#{title}-#{words}-#{duration.to_i}.ts"

	# Make sure that all files have same aspect ratio
	# http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg

		file_with_ar = "ffmpeg -i #{snippet_url} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 -y '#{inter_name}' -loglevel quiet"
		
		# save temp file location to Snippet
		@snip.temp_file_location = inter_name	
		p "Saved #{@snip.id} with #{@snip.temp_file_location}" if @snip.save!

		# p @snip.temp_file_location
		system(file_with_ar) unless File.exists?(inter_name)

	end
end