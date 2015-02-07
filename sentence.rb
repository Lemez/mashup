# class Sentence

	

# 	def initialize(line_id,line_artist,line_title,keyword, sentence_w_gap, sentence_no_gap, time_at,time_until,dur_ms=0)
		
# 		@line_id = line_id
# 		@line_artist = line_artist
# 		@line_title = line_title
# 		@keyword = keyword
# 		@sentence_w_gap = sentence_w_gap
# 		@full_sentence = sentence_no_gap
# 		@starttime = time_at
# 		@endtime = time_until
# 		@duration = dur_ms
# 	end

# 	def self.all
#         ObjectSpace.each_object(self).to_a
#     end

# 	def self.lasts_for
# 		@duration
# 	end

# 	def self.video_id
# 		@line_id
# 	end

# 	def self.artist
# 		@line_artist
# 	end
# 	def self.title
# 		@line_title
# 	end
# 	def self.keyword
# 		@keyword
# 	end
# 	def self.sentence_w_gap
# 		@sentence_w_gap
# 	end
# 	def self.full_sentence
# 		@full_sentence
# 	end
# 	def self.starts_at
# 		@starttime
# 	end
# 	def self.ends_at
# 		@endtime
# 	end
		
# end