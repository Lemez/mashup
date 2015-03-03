def test_srt
	p "********"
	p "test_srt"
	p "********"

	srt_file = "#{@subsdir}/srt_ex.srt"

	inputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}.mp4'"
	outputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}_srt_test.mp4'"

	`ffmpeg -i #{inputfile} -vf subtitles=#{srt_file} -y #{outputfile} -loglevel error`
end

def add_srt_to_final_mp4
	p "********"
	p "add_srt_to_final_mp4"
	p "********"

	srt_file = "'#{@subsdir}/#{PLAYLISTNAME}/srt_file.srt'"

	inputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}.mp4'"
	outputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}_subs.mp4'"

	`ffmpeg -i #{inputfile} -vf subtitles=#{srt_file} -y #{outputfile} -loglevel error`

end


def create_srt_from_snippets

	p "********"
	p "create_srt_from_snippets"
	p "********"

	make_dir_if_none "#{@subsdir}", "#{PLAYLISTNAME}"

	@snippets = Snippet.all
	
	@srt_file = open("#{@subsdir}/#{PLAYLISTNAME}/srt_file.srt", "w")

	# @start_ms = 0
	# @counter = 1

	emptyline =	'''1
00:00:00,000 --> 00:00:00,001

'''
	@srt_file.puts(emptyline)
	@start_ms = 1
	@counter = 2

	@snippets.each do |snippet|
		sentence = Sentence.find_by("id=#{snippet.sentence_id}")
		
		duration = snippet.sentence_duration

		@start_srt = convert_ms_to_srt(@start_ms)
		@end_srt = convert_ms_to_srt(@start_ms+duration )

		# 1
		@srt_file.puts(@counter.to_s)

		# 00:00:14,000 –> 00:00:20,500
		time_string = "#{@start_srt} --> #{@end_srt}"
		@srt_file.puts(time_string)

		# Process text and fonts
		text_array = sentence.full_sentence.split(" ")
		keyword = sentence.keyword
		kw_index = text_array.index(keyword)
		size = "24px"
		highlight_size = "24px"
		first_half = "<font size=#{size}>" + text_array[0...kw_index].join(" ") + "</font>"
		second_half = "<font size=#{size}>" + text_array[kw_index+1..-1].join(" ") + "</font>"

		highlight_colour = "#ffff00"
		
		highlighted_word = "<font color=#{highlight_colour} size=#{highlight_size}><b> #{keyword} </b></font>"
		text = first_half + highlighted_word + second_half # + " X1:117 X2:619 Y1:042 Y2:428"

		# Lost Corners consists of charcoal paintings.
		@srt_file.puts(text)

		# new line
		@srt_file.puts("")



		@start_ms += duration
		@start_srt = @end_srt
		@counter += 1
	end

	@srt_file.close
end



def srt_to_ass

	p "********"
	p "srt_to_ass"
	p "********"

	srt_file = "#{@subsdir}/#{PLAYLISTNAME}/srt_file.srt"
	ass_file = "#{@subsdir}/#{PLAYLISTNAME}/srt_file.ass"
	
	`ffmpeg -i '#{srt_file}' '#{ass_file}' -loglevel error -y`
end


def add_subs_ass_to_final_mp4

	p "********"
	p "add_subs_ass_to_final_mp4"
	p "********"

	ass_file = "'#{@subsdir}/#{PLAYLISTNAME}/srt_file.ass'"

	inputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}.mp4'"
	outputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}_subs_ass.mp4'"
	mkvinputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}.mkv'"
	mkvoutputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}_subs.mkv'"
	avioutputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}_subs.avi'"

	`ffmpeg -i #{inputfile} -vf subtitles=#{ass_file} #{outputfile} -y -loglevel error`

end





# def test_srt
# 	[*1..2000].each do |i|
# 		p convert_ms_to_srt(i*100)
# 	end 

# end


# old commands
# `ffmpeg -i #{inputfile} -i #{srt_file} -vcodec copy -acodec copy -scodec mov_text -filter_complex "[0:v][0:s]overlay" #{outputfile}`

	# `ffmpeg -i #{inputfile} -f srt -i #{srt_file} -c:v copy -c:a copy -c:s mov_text #{outputfile}  -loglevel error`

	# `ffmpeg -i #{inputfile} -i '#{srt_file}' -c:v copy -c:a copy -c:s mov_text #{outputfile}  -loglevel error`

	# `ffmpeg -i #{inputfile} -i '#{srt_file}' -c:v copy -c:a copy -c:s ass #{mkvoutputfile}  -loglevel error`

	# `ffmpeg -i #{inputfile} -c:v copy -c:a copy #{mkvinputfile}`
	# `mkvmerge -o #{mkvoutputfile} #{mkvinputfile} '#{srt_file}'`

	# `ffmpeg -i #{inputfile} -c:v copy -c:a copy #{aviinputfile}`
	# `ffmpeg -i #{aviinputfile} -vf subtitles='#{srt_file}' #{avioutputfile}`
	

	# ffmpeg -i infile.mp4 -f srt -i infile.srt -c:v copy -c:a copy \
 #  -c:s mov_text outfile.mp4

	# `ffmpeg -i #{inputfile} -vf subtitles=#{ass_file} #{mkvoutputfile}`

	# `ffmpeg -i #{inputfile} -filter:v subtitles=#{srt_file} #{outputfile} -y`
	

# 	`ffmpeg -i #{inputfile} -i #{srt_file} \
# -c:v libx264 -preset ultrafast \
# -c:s mov_text -map 0 -map 1 \
# #{outputfile}`



# 1
# 00:00:14,000 –> 00:00:20,500
# Lost Corners consists of charcoal paintings.

# 2
# 00:00:21,000 –> 00:00:27,500
# The series shows landmarks, places and objects.