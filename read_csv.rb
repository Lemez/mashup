
def getfiles 
	list = CSV.read("./csv/songlist.csv") 
	p list
	allsongs = []
	playlist_name = ''

	list.each do |song|
		id = song[7]
		artist = song[4]
		title = song[3]
		playlist_name = song[0].sub(" PLAYLIST", "") if !song[0].nil? && song[0].length > 3 && song[0] != "ON AIR" 
		details = [playlist_name,artist,title,id]
		allsongs << details unless artist.nil? || artist.include?('should') || artist.include?('playlist') 
	end

	allsongs.shift
	# p @allsongs
	return allsongs
end

def get_files_from_specific_rule rule
	@videos_saved = {}
	p "Getting data from #{rule}"

	list = CSV.read("./csv/#{rule}", {:headers => true})

	@sentence_data = []
	@last = ''


	list.each do |line|

		s = {}
		@line_id = line[0] unless line[0].nil?
		@original_artist = line[1] unless line[1].nil?
		@original_title = line[2] unless line[2].nil?
		@line_artist = line[1].split(/ |\_/).map(&:downcase).join(" ").gsub("'","") unless line[1].nil?
		@line_title = line[2].split(/ |\_/).map(&:downcase).join(" ").gsub("'","") unless line[2].nil?

		keyword = line[3]
		sentence_w_gap = line[5]
		time_at = line[6]
		time_until = line[7]
		dur_ms = line[8]

		sentence_no_gap = ''
		sentence_words = []

		words = sentence_w_gap.split(" ")
		words.each do |w|
			w = keyword if w=="__"
			sentence_words << w
		end

		sentence_no_gap = sentence_words.join(" ")
		use = !line[9].nil?

		s['video_id'],s['artist'], s['title'],s['keyword'],s['sentence_w_gap'],s['full_sentence'],s['start'],s['end'],s['dur'] = @line_id,@line_artist,@line_title,keyword, sentence_w_gap, sentence_no_gap, time_at,time_until,dur_ms
		
		@sentence_data << s unless @last['video_id']==s['video_id']
		@last = s

		@video = Video.where(:yt_id => @line_id).first_or_create
		@video.title = @line_title
		@video.artist = @line_artist
		@video.artist_original = @original_artist
		@video.title_original = @original_title

		p "saved" if @video.save!
		@sss = Sentence.where(:video_id => @video.id, :rule_name => @playlist_name,:full_sentence =>sentence_no_gap, :sentence_gap => sentence_w_gap, :keyword => keyword, :start_at => time_at, :end_at => time_until, :duration => dur_ms, :adult => use).first_or_create

		# p @video_id
		# p @sss
	end
end

def map_details_to_hashes details
	p " \n mapping details to hashes \n"
	@hash = Hash.new
	@hash["rule"] = @playlist_name
	@data_array = Array.new

	details.each_with_index do |item,index|
		number_hash = Hash.new
		number_hash["key_word"] = item["keyword"]
		number_hash["artist"] = item["artist"]
		number_hash["title"] = item["title"]
		number_hash["yt_id"] = item["video_id"]
		number_hash["full_sentence"] = item["full_sentence"]
		number_hash["sentence_w_gap"] = item["sentence_w_gap"]
		number_hash["start_time"] = item["start"]
		number_hash["end_time"] = item["end"]
		number_hash["duration"] = item["dur"]
		# @hash["data"]["#{index}"] = number_hash
		@data_array << number_hash
		
	end
	@hash["data"] = @data_array
	return @hash

end

# get kids files from the getfiles function
def get_videos_from_songlist_file (argument)

	videos = getfiles.select{ |i| i[0][/#{Regexp.escape(argument)}$/] }.each {|a| a.shift}

	video_ids = []
	titles = []
	artists = []
	videos.each{|a| video_ids << a[-1]; titles << @client.video_by(a[-1]).title }
 	p titles.length == video_ids.length

	return video_ids,titles
end