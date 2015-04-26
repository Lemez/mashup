# def get_sentences_with_saved_videos
# 	p "**";p "get_sentences_with_saved_videos";p "**"
	
# 	@sentences_to_extract = []
# 	Sentence.all.obeys_rule.each do |sentence|
# 		svid = sentence.video_id
# 		v = Video.find_by("id=#{svid}")
# 		@sentences_to_extract << sentence if v.saved
# 	end
# end

def initiate_keyword_and_video
	p "* initiate_keyword_and_video *"
	@sentence_pass = 0
	@unique_keyword = true
	@unique_video = true
	@no_further_attempts = false
end

def choose_sentences_from_saved_videos
	p "* choose_sentences_from_saved_videos *"

	initiate_keyword_and_video

	begin
		sentences_to_extract = []
		sentences_to_extract = Video.all.is_saved.flat_map(&:sentences)
									.uniq{|s| s.full_sentence.downcase}
									.sort_by{|s| s.keyword.downcase}
									.select{|s| s.full_sentence.behaves_nicely(s.keyword)}
									# .sort_by{|v| Video.where("id=#{v.id}").title}.reverse.shuffle
									# .joins(:sentences).where("sentences.rule_name=#{@playlist_name}")
		
		# sentences_to_extract.each{|s| p s.full_sentence.split(" ").include?(s.keyword)}

		# return if sentences_to_extract.empty?

		rule = Rule.find_by(:rule_name => @playlist_name)
		unless sentences_to_extract.empty?
			# p sentences_to_extract
			rule.example = sentences_to_extract[0].keyword.downcase
			rule.save!
		end

		return sentences_to_extract

	rescue NoMethodError => e
		p "Error! ---------- #{sentences_to_extract}"
		raise e
		return
	end
end

def select_filter_sentences
	p "* select_filter_sentences *"

	if @unique_keyword==true && @unique_video==true
		sentences = @all_sentences_to_extract.uniq(&:video_id).uniq(&:keyword) 
	
	elsif @unique_keyword==true
		sentences = @all_sentences_to_extract.uniq(&:keyword)
	
	elsif @unique_video==true
		sentences = @all_sentences_to_extract.uniq(&:video_id)
	
	else
		sentences = @all_sentences_to_extract
	end
	
	sentences.each {|s| sentences.delete(s) if EXCLUDED.include?(Video.find_by("id=#{s.video_id}").title)}
		
	@sentence_pass += 1

	return sentences.sort! { |a,b| a.duration <=> b.duration }

end

def continue_or_stop
	p "* continue_or_stop *"

	if @sentences_to_extract.count < @number_of_clips
		p "Not enough unique sentences, only #{@sentences_to_extract.count} found with #{@number_of_clips.to_s} required"

		# remove_files_created
		true
	else
		p "Processing unique sentences, #{@sentences_to_extract.count} found with #{@number_of_clips.to_s} required"

		DIRECTORIES.each{|d| make_dir_if_none d,@playlist_name}
		p @sentences_to_extract
		false
	end
end

def iterate_over_sentence_filters
	p "* iterate_over_sentence_filters *"

	case @sentence_pass
	when 1
		p "unique_video"
		@unique_video = false
	when 2
		@unique_video = true
		@unique_keyword = false
	when 3
		@unique_video = false
		@unique_keyword = false
	when 4..5
		@number_of_clips -=1
	when 6 
		@no_further_attempts = true
	end

	p "Unique video: #{@unique_video.to_s}"
	p "Unique keyword: #{@unique_keyword.to_s}"
	p "Sentence passes: #{@sentence_pass.to_s}"

	@sentences_to_extract = select_filter_sentences
	
end

def refine_sentences_further

	if @sentences_to_extract.count > @number_of_clips
		@sentences_to_extract.select {|s| s.duration < MAX_DUR}
							.select {|s| s.duration > MIN_DUR}
	end

	p "Selecting #{@number_of_clips.to_s} sentences from #{@sentences_to_extract.count} found"

	previous = @sentences_to_extract.dup

	@sentences_to_extract = @sentences_to_extract[-5..-1]

	difference = previous - @sentences_to_extract
	
	p "Rejecting #{difference}"

end

