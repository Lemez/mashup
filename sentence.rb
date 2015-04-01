def get_sentences_with_saved_videos
	p "*******";p "get_sentences_with_saved_videos";p "*******"
	
	@sentences_to_extract = []
	Sentence.all.obeys_rule.each do |sentence|
		svid = sentence.video_id
		v = Video.find_by("id=#{svid}")
		@sentences_to_extract << sentence if v.saved
	end
end

def choose_sentences
	p "******"
	p "choose_sentences"
	p "******"

	@sentences_to_extract = Video.all.is_saved.flat_map(&:sentences).uniq{|s| s.keyword.downcase}.shuffle
	@sentences_to_extract.each{|sentence| p sentence.adult}
end

