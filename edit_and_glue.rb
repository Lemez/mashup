def create_snippets_text_file 

		file = open("#{@editsdir}/#{PLAYLISTNAME}/snippets_file.txt",'w')
		Snippet.all.each do |item|

			s = "file '#{item.location}'"
			file.puts(s)
		end
		file.close
end


def create_snippets_from_sentences

	make_dir_if_none @editsdir, @sentences_to_extract.first.rule_name

	@full_sentence = ''

	@sentences_to_extract.each do |sentence|
		
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

		duration_secs = 4 if artist=='shakira' and title=='cant remember to forget you'

		location_string = "#{@editsdir}/#{rule_name}/#{artist}-#{title}-#{sentence_id.to_s}.mp4"

		# define skipping conditions
		next if artist=='u2' or artist=='U2' or artist=="destinys child" or artist=="eminem"
		next if sentence.full_sentence.split(" ").length < 4
		next if @full_sentence==full_sentence

		s = Snippet.create(:video_id => video_id, :sentence_duration => d, :clip_duration => duration_secs, :sentence_id => sentence_id, :full_video_location => full_video_location, :location => location_string, :rule_name => rule_name )	

		# save cut of each video to rule edits folder
		command = "ffmpeg -i #{full_video_location} -ss #{start_secs} -t #{duration_secs} -async 1 '#{location_string}'"

		system (command) unless File.exists?(location_string) 

		@full_sentence=full_sentence
	end
	
end

def show_current_snippets
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
	directory = "#{@editsdir}/#{PLAYLISTNAME}"
	myfile = "#{directory}/snippets_file.txt"

	make_dir_if_none directory,"tmp"
		
	File.readlines(myfile).each do |url|

		name, extension = get_file_attributes url
		snippet_url = url[5..-2]
		snippet_s_id = Snippet.find_by("location=#{snippet_url}").sentence_id
		sentence = Sentence.find_by("id=#{snippet_s_id}")
		video = Video.find_by("id=#{sentence.video_id}")
		artist = video.artist
		title = video.title

		inter_name = "'#{@editsdir}/#{PLAYLISTNAME}/tmp/#{artist}-#{title}-#{snippet_s_id}.ts'"

	# Make sure that all files have same aspect ratio
	# http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg

		file_with_ar = "ffmpeg -i #{snippet_url} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 #{inter_name}"
		p file_with_ar
		system(file_with_ar)

	end
end

def glue_intermediate_files_and_normal_audio


	# #2D concatenate the files creatd using the below format 
	# 	# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
		
	# #VIDEO, no audio
	# str = ''
	# @inter_files.each{|name| str+=name+'|'}
	# str.chop! # remove last pipe
	# str = '"concat:' + str + '"'
	# video_s = "ffmpeg -i #{str} -c copy '#{directory}/video.mp4'"

	# # concatenate the video files 
	# p video_s
	# system(video_s)


	# #AUDIO, no video
	# str = ''
	# @inter_files.each{|name| str+=name+'|'}
	# str.chop! # remove last pipe
	# str = '"concat:' + str + '"'
	# audio_s = "ffmpeg -i #{str} -vn -acodec 'copy' '#{directory}/audio.mp2'"

	# # concatenate the video files 
	# p audio_s
	# system(audio_s)

	# #mashem together
	# total_s = "ffmpeg -i '#{directory}/video.mp4' -i '#{directory}/audio.mp2' '#{directory}/output.mp4'"
	# p total_s
	# system(total_s)		

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