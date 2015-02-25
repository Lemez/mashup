def create_snippets_text_file 

	p "******"
	p "create_snippets_text_file"
	p "******"

		file = open("#{@editsdir}/#{PLAYLISTNAME}/snippets_file.txt",'w')
		Snippet.all.each do |item|
			s = "file '#{item.location}'"
			file.puts(s)
		end
		file.close
end


def create_snippets_from_sentences

	p "******"
	p "create_snippets_from_sentences"
	p "******"

	make_dir_if_none @editsdir, PLAYLISTNAME
	make_dir_if_none "#{@editsdir}/#{PLAYLISTNAME}", "snippets"

	@full_sentence = ''
	@title = ''

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
		d = sentence.duration + 1000 
		d += 1000 if d < 4000

		start_secs = convert_to_seconds_and_ms(s)
		duration_secs = convert_to_seconds_and_ms(d)

		# duration_secs = 4 if artist=='shakira' and title=='cant remember to forget you'

		location_string = "#{@editsdir}/#{rule_name}/snippets/#{artist}-#{title}-#{sentence_id.to_s}-#{d.to_i.to_s}.mp4"

		# define skipping conditions
		next if artist=='u2' or artist=='U2' or artist=="destinys child" or artist=="eminem"
		next if sentence.full_sentence.split(" ").length < 4
		next if @full_sentence==full_sentence
		next if @title==title

		s = Snippet.create(:video_id => video_id, :sentence_duration => d, :clip_duration => duration_secs, :sentence_id => sentence_id, :full_video_location => full_video_location, :location => location_string, :rule_name => rule_name )	

		# save cut of each video to rule edits folder
		command = "ffmpeg -i #{full_video_location} -ss #{start_secs} -t #{duration_secs} -async 1 '#{location_string}' -y -loglevel quiet"

		system (command) unless File.exists?(location_string)

		@full_sentence=full_sentence
		@title=title
	end
	
end

def show_current_snippets

	p "******"
	p "show_current_snippets"
	p "******"
	@snippets = Snippet.all
	@snippets.each do |s|
		id = s.sentence_id
		sentence = Sentence.find_by("id=#{id}")
		p "#{sentence.full_sentence}"
		p "#{s.location}"
		p "#{s.sentence_duration}"
		p "#{s.clip_duration}"
	end
end

def create_intermediate_files_from_snippets

	p "******"
	p "create_intermediate_files_from_snippets"
	p "******"

	directory = "#{@editsdir}/#{PLAYLISTNAME}"
	myfile = "#{directory}/snippets_file.txt"

	make_dir_if_none directory,"tmp"
		
	File.readlines(myfile).each do |url|

		name, extension = get_file_attributes url
		snippet_url = url[5..-2]
		@snip = Snippet.find_by("location=#{snippet_url}")
		snippet_s_id = @snip.sentence_id
		sentence = Sentence.find_by("id=#{snippet_s_id}")
		video = Video.find_by("id=#{sentence.video_id}")
		words = sentence.full_sentence.gsub(/[^0-9a-z ]/i, '')
		artist = video.artist
		title = video.title

		inter_name = "#{@editsdir}/#{PLAYLISTNAME}/tmp/#{artist}-#{title}-#{snippet_s_id}-#{words}.ts"

	# Make sure that all files have same aspect ratio
	# http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg

		file_with_ar = "ffmpeg -i #{snippet_url} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 -y '#{inter_name}' -loglevel quiet"
		
		# save temp file location to Snippet
		@snip.temp_file_location = inter_name
		@snip.save!

		# p @snip.temp_file_location
		system(file_with_ar) unless File.exists?(inter_name)

	end
end