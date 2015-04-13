def get_clean_name (s)
	return s.gsub(/[^0-9a-z. ]/i, '')
end

def get_clean_name_alphanum (s)
	return s.gsub(/[^0-9a-z ~]/i, '').gsub("  "," ")
end

def get_clean_name_alphanum_dash (s)
	return s.gsub(/[^0-9a-z ~-]/i, '').gsub("  "," ")
end

def convert_to_start_time(s)
	# ms to 00:02:00

	ss, ms = s.to_i.divmod(1000)         
	mm, ss = ss.divmod(60)            
	hh, mm = mm.divmod(60)          
	start =  format("%02d:%02d:%02d", hh, mm, ss)
	
	return start 
end

def convert_to_duration(d)
	whole_units = d.to_i/1000
	if whole_units < 60
		return format("00:00:%02d",whole_units ) 
	else
		# return sprintf("00:%02d:%02d",whole_units/60, whole_units%60 ) 
		raise "Houston, we have a sentence duration problem from the csv"
	end
end

def convert_to_seconds_and_ms(ms)
	ms=ms/1.0
	return ms/1000
		# 	‘23.189’
		# 23.189 seconds
end

def convert_ms_to_srt(s)
	ss, ms = s.to_i.divmod(1000)         
	mm, ss = ss.divmod(60)            
	      
	time = format("00:%02d:%02d,%03d", mm, ss,ms)
	
	return time
		# 	‘23.189’
		# 23.189 seconds
end

def match_best other_title, array_from_csv, type

	@other_title_words = other_title.downcase.gsub(/[^0-9a-z ~]/i, '').gsub("  "," ").split(" ")
		
	array_from_csv.each do |item|

		p item

		item = item.downcase.gsub(/[^0-9a-z ~]/i, '')

		@string = ''

		@other_title_words.each do |word|
			word = word.downcase 
			
			if item == @string
				# p "name found is #{@string}"
				current_index = @other_title_words.index(word)
				@remaining_words = @other_title_words[current_index..-1]
				@remaining_words << "zgzgzg"
				@remaining_word_string = @remaining_words.join(" ")
				# p "name found is #{@string} with remaining words #{@remaining_word_string}"
				
				return @string, @remaining_word_string

			else
				if @string.empty?
					@string = @string.downcase + word 
				else 
					@string = @string.downcase + " " + word
				end 
			end
    	end
	end

end

def get_best_match array, filename
	@a = []
	@t = []
	array.each do |hash|
		@a << hash["artist"].downcase
		@t << hash["title"].downcase
	end

	# need to ignore if the filename is already in the correct format, ie eminem ~ the monster.mp4

	artist_match_results = match_best filename,@a, "artist"
	artist_filename = artist_match_results[0]
	remaining_words = artist_match_results[1]
	song_match_results = match_best remaining_words, @t, "song"
	song_filename = song_match_results[0]
	return "#{artist_filename} ~ #{song_filename}"
end

def find_artist_and_title other_title, artist_array,title_array
	jarow = FuzzyStringMatch::JaroWinkler.create( :native )
	@best_artist_match_from_csv = ''
	@best_title_match_from_csv = ''

	@highest_artist_distance_from_csv = 0
	@highest_title_distance_from_csv = 0

	artist_array.each do |artist|
		distance = jarow.getDistance( artist, other_title)
    	if distance > @highest_artist_distance_from_csv
    		@highest_artist_distance_from_csv = distance 
    		@best_artist_match_from_csv = artist
    	end
	end

	title_array.each do |t|
		distance = jarow.getDistance( t, other_title)
    	if distance > @highest_title_distance_from_csv
    		@highest_title_distance_from_csv = distance 
    		@best_title_match_from_csv = t
    	end
	end

	p "Best match for #{other_title} is #{@best_title_match_from_csv} by #{@best_artist_match_from_csv} "
	return @best_artist_match_from_csv, @best_title_match_from_csv
end