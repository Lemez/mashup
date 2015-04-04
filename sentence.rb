# def get_sentences_with_saved_videos
# 	p "*******";p "get_sentences_with_saved_videos";p "*******"
	
# 	@sentences_to_extract = []
# 	Sentence.all.obeys_rule.each do |sentence|
# 		svid = sentence.video_id
# 		v = Video.find_by("id=#{svid}")
# 		@sentences_to_extract << sentence if v.saved
# 	end
# end

def choose_sentences_from_saved_videos
	p "******";p "choose_sentences_from_saved_videos";p "******"

	sentences_to_extract = Video.all.is_saved.flat_map(&:sentences)
								.uniq{|s| s.full_sentence.downcase}
								.sort_by{|s| s.keyword.downcase} 
								# .sort_by{|v| Video.where("id=#{v.id}").title}.reverse.shuffle
								# .joins(:sentences).where("sentences.rule_name=#{@playlist_name}")
	return sentences_to_extract
end

