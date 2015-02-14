def add_srt_to_final_mp4
	srt_file = "'#{@editsdir}/#{PLAYLISTNAME}/srt_file.srt'"
	inputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}.mp4'"
	outputfile = "'#{Dir.pwd}/videos_final/#{PLAYLISTNAME}_subs.mp4'"

	# `ffmpeg -i #{inputfile} -i #{srt_file} -c:s mov_text -c:v copy -c:a copy #{outputfile}`
	`ffmpeg -i #{inputfile} -i #{srt_file} -vcodec copy -acodec copy -scodec mov_text -filter_complex "[0:v][0:s]overlay" #{outputfile}`

end

# def test_srt
# 	[*1..2000].each do |i|
# 		p convert_ms_to_srt(i*100)
# 	end 

# end


def create_srt_from_snippets

	@snippets = Snippet.all
	@start_ms = 0
	@srt_file = open("#{@editsdir}/#{PLAYLISTNAME}/srt_file.srt", "w")
	@counter = 1

	@snippets.each do |snippet|
		sentence = Sentence.find_by("id=#{snippet.sentence_id}")
		text = sentence.full_sentence
		duration = snippet.sentence_duration

		@start_srt = convert_ms_to_srt(@start_ms)
		@end_srt = convert_ms_to_srt(@start_ms+duration )

		
		# 1
		@srt_file.puts(@counter.to_s)

		# 00:00:14,000 –> 00:00:20,500
		time_string = "#{@start_srt} –> #{@end_srt}"
		@srt_file.puts(time_string)

		p time_string

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


# 1
# 00:00:14,000 –> 00:00:20,500
# Lost Corners consists of charcoal paintings.

# 2
# 00:00:21,000 –> 00:00:27,500
# The series shows landmarks, places and objects.