def create_srt_from_snippets

	@snippets = Snippet.all
	@start_ms = 0
	@srt_file = open("#{@editsdir}/#{PLAYLISTNAME}/srt_file.txt", "w")
	@counter = 1

	@snippets.each do |snippet|
		sentence = Sentence.find_by("id=#{snippet.sentence_id}")
		text = sentence.full_sentence
		duration = snippet.sentence_duration

		@start_srt = convert_ms_to_srt(@start_ms)
		@end_srt = convert_ms_to_srt(@start_ms+duration )
		
		@srt_file.puts(@counter.to_s)
		time_string = "#{@start_srt} –> #{@end_srt}"
		@srt_file.puts(time_string)
		@srt_file.puts(text)
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