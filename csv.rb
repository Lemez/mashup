def query_saved_videos_per_node destroy=false

	p "************** query_saved_videos_per_node **************"

	calculate_completed_videos

	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	reading_file = "./csv/summary/summary_medleys_FINAL.csv"

	CSV.open("./csv/videos/hits_medleys_FINAL.csv","w", {:col_sep => ";"}) do |csv|
		csv << ["Node", "Example","Total","Profane","Relevant Videos","Sentence Hits", "Completed"]

		CSV.foreach(reading_file,options) do |row|

			@playlist_name = row[0]
			@error = ''

			rule = Rule.where(:rule_name => @playlist_name).first_or_create
			p "Rule #{@playlist_name} saved" if rule.save!

			next if row[0] == @lastrow

			p "*** Processing #{@playlist_name} *****"
			# sleep 3
			get_files_from_db_specific_csv "#{@playlist_name}.csv"
			# sleep 3
			create_and_match_saved_videos
			# sleep 3
			sentences = choose_sentences_from_saved_videos
			# sleep 3
			p sentences
			# sleep 3

			unless sentences.empty?
				relevant_videos_length = sentences.flat_map(&:video_id).uniq.count
				current_hits = sentences.count
			else
				relevant_videos_length = 0
				current_hits = 0
			end

			@completed.include?(@playlist_name) ? completed = true : completed = false
			p "#{@playlist_name} completed = #{completed}; empty? #{Dir["#{@finaldir}/#{@playlist_name}/{*,.*}"].empty?}"


			if completed == true
				completed = false if Dir["#{@finaldir}/#{@playlist_name}/{*,.*}"].empty?	
			end
			
			results = [row[0], # name
					row[1], # example
					row[2], # total sentences
					row[3].to_i.to_s, #profane
					relevant_videos_length,
					current_hits,
					completed.to_s]


			csv << results

			Sentence.destroy_all if destroy

			@lastrow = row[0]

		end
	end
end


def get_files_from_db_specific_csv rule
	p "************** get_files_from_db_specific_csv **************"

	@videos_saved = {}
	listarray = []

	# p "Getting data from #{rule}"
	# Rule.create(:rule_name => rule)

	list = CSV.read("#{@csvdir}/#{rule}", {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"})

	list.each {|row| listarray << row}

	@sentence_data = []
	@last = ''

	# p "Reading: #{list}"
	
	listarray.shuffle.each do |line|

		@profane = !line[16].to_i.zero?
		offset = line[17].to_i

		@line_id,@original_artist,@original_title  = line[2],line[4],line[6] 
		@line_artist = @original_artist.split(/ |\_/).map(&:downcase).join(" ").gsub("'","")
		@line_title = @original_title.split(/ |\_/).map(&:downcase).join(" ").gsub("'","")

		@keyword,sentence_w_gap  = line[7], line[9]

		sentence_words = []
		# sentence_w_gap.split(" ").each {|w| w = @keyword + w[-1] if w.include?("__") and w!="__"; w = @keyword if w==("__"); @profane = true if w.include?("*"); word = w.gsub(/[^\p{Alnum} ']/, ''); sentence_words << word}
		# next unless sentence_w_gap.behaves_nicely(@keyword)

		sentence_w_gap.split(" ").each do |w|
		  	
		  	w = @keyword if w==("__")
		  	w =	@keyword + w["__".length..-1] if w.include?("__")		  
		   	@profane = true if w.include?("*") || RUDE.include?(w.downcase)
		    # word = w.gsub(/[^\p{Alnum} ']/, '');
		 	sentence_words << w
		end

		sentence_no_gap = sentence_words.join(" ")

		@node, @group, @game = line[10], line[11], line[12]

		time_at,time_until,dur_ms = line[13], line[14],line[15]

		newvideo = Video.where(:yt_id => @line_id).first

		if newvideo.nil?
			@video = Video.where(:yt_id => @line_id).first_or_create
			@video.title = @line_title
			@video.artist = @line_artist
			@video.artist_original = @original_artist
			@video.title_original = @original_title
			@video.save!

		end

		@video= Video.where(:yt_id => @line_id).first

		@video.offset = offset
		@video.save!

		sentence = Sentence.where(:rule_name => @node, :video_id => @video.id, :l_node => @node, :l_group => @group, :l_game => @game, :full_sentence =>sentence_no_gap, :sentence_gap => sentence_w_gap, :keyword => @keyword, :start_at => time_at, :end_at => time_until, :duration => dur_ms, :adult => @profane).first_or_create
		
	end

	rule = Rule.where(:rule_name => @playlist_name).first_or_create
	p "Rule #{@playlist_name} saved" if rule.save!

end




def db_files_to_csv
	p "************** db_files_to_csv **************"

	@linecounter = 0

	# list = CSV.read("./csv/master/maria_10_03_2015_working.csv",{:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => "\t"})
	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	list = "./csv/master/for_medleys_FINAL.csv"

	CSV.foreach(list,options) do |line|

		line = line.gsub("\"","") if line.include?("\"")#remove illegal quoting Malformed CSV Error if 
		
		node = line[10]

		# next if node == "dances round the room" || node == " there's demons closing in on"

		if @linecounter == 0
			@csv = CSV.open("./csv/nodes_final/#{node}.csv", "w", {:col_sep => ";"})

		elsif @node != node 
			@csv.close
			@csv = CSV.open("./csv/nodes_final/#{node}.csv", "w", {:col_sep => ";"})

			@csv << line
		else
			@csv << line
		end

		@linecounter += 1
		@node = node
	end
	@csv.close
end

def get_files_from_db_csv

	p "************** get_files_from_db_csv **************"

	files = Dir.glob("./csv/nodes_final/*.csv")
	
	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}

	summaryfile = CSV.open("./csv/summary/summary_medleys_FINAL.csv","w", {:col_sep => ";"}) do |csv|
		csv << ["Node", "Example","Total","Profane"]

		files.each do |file|

			p "Reading: #{file}"
			@profanecounter = 0
			@linecounter = 0
			@current_node = Node.new
			
			CSV.foreach(file,options) do |line|

				@linecounter+=1

				@profane = !line[16].to_i.zero?
				offset = line[17].to_i

				@line_id,@original_artist,@original_title  = line[2],line[4],line[6] 
				@line_artist = @original_artist.split(/ |\_/).map(&:downcase).join(" ").gsub("'","")
				@line_title = @original_title.split(/ |\_/).map(&:downcase).join(" ").gsub("'","")

				@keyword,sentence_w_gap  = line[7], line[9]

				sentence_words = []
				sentence_w_gap.split(" ").each {|w| w = @keyword + w[-1] if w.include?("__") and w!="__"; w = @keyword if w==("__"); @profane = true if w.include?("*"); word = w.gsub(/[^\p{Alnum} ']/, ''); sentence_words << word}
				sentence_no_gap = sentence_words.join(" ")

				@node, @group, @game = line[10], line[11], line[12]

				time_at,time_until,dur_ms = line[13], line[14],line[15]
				
				@profanecounter += 1 if @profane

				newvideo = Video.where(:yt_id => @line_id).first

				if newvideo.nil?
					@video = Video.where(:yt_id => @line_id).first_or_create
					@video.title = @line_title
					@video.artist = @line_artist
					@video.artist_original = @original_artist
					@video.title_original = @original_title
					@video.save!

					# p "Video #{@line_id} saved" if @video.save!
				end

				@video= Video.where(:yt_id => @line_id).first

				@video.offset = offset
				@video.save!

				sentence = Sentence.where(:rule_name => @node,
										  :video_id => @video.id,
										  :l_node => @node,
										  :l_group => @group,
										  :l_game => @game,
										  :full_sentence =>sentence_no_gap, 
										  :sentence_gap => sentence_w_gap, 
										  :keyword => @keyword, 
										  :start_at => time_at, 
										  :end_at => time_until, 
										  :duration => dur_ms, 
										  :adult => @profane).first_or_create

				# p  "#{@linecounter}. Node: #{sentence.l_node}, Group: #{sentence.l_group}, Game: #{sentence.l_game}" if @linecounter==1
			end

			@current_node.total_instances = @linecounter
			@current_node.total_profane = @profanecounter
			@current_node.name = @node
			@current_node.keyword = @keyword
			@current_node.save!

			p "#{@current_node.name} saved!" if @current_node.save!

			csv << [@node,@keyword,@linecounter,@profanecounter]
			# p "Profane: #{@profanecounter} out of a total #{@linecounter}"
		end

	end

end








##### OLD



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
	p "*****";p "get_files_from_specific_rule";p "*****"

	@videos_saved = {}
	p "Getting data from #{rule}"
	
	Rule.create(:rule_name => @playlist_name)

	list = CSV.read("#{rule}", {:headers => true})

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
		@video.save!
		
		# p "saved" if @video.save!
		@sss = Sentence.where(:video_id => @video.id, :rule_name => @playlist_name,:full_sentence =>sentence_no_gap, :sentence_gap => sentence_w_gap, :keyword => keyword, :start_at => time_at, :end_at => time_until, :duration => dur_ms, :adult => use).first_or_create

		# p @video_id
		p @sss
	end
end

def map_details_to_hashes details
	p "******\nmapping details to hashes\n*******"

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