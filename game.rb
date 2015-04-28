def make_games_from_features
	# csv_to_game
	# create_hash_of_features
	# compile_features_to_game
	# which_vids_are_done
	# check_games

	features_to_game false
	# compile_games
	# add_intro_to_games
	# @games.each {|game| p game.gname}
end



def features_to_game option
	options = {:headers => false, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	list = "./csv/games_final/games-csv-2015-04-25-maria.csv"

	@existing_final_videos = Dir.glob("./videos_final/*/*").select{|f| f.include?("logo")}
	
	CSV.foreach(list,options) do |row|
		
		game,nodes = row[0],row[1][1..-2].split(",")
		g = Game.where(:gname => game).first_or_create

		game_text_file  = File.open("#{@gamesdir}/#{game}.txt", 'w')

		nodes.each{|n| n.gsub!(/[^\p{Alnum}_']/, '')}.sort!{ |a,b| a <=> b }

		nodes.each do |node|
			@node_location = ''
			@existing_final_videos.each do |f|
				file = File.basename(f)[0..-15] 
				full_location = Dir.pwd + f[1..-1] 
				@node_location = full_location if node==file
			end

		 	@mynode = Node.where(:game_id => g.id, :name => node, :file_location => @node_location).first_or_create
			@mynode.save!

			s = "file '#{@node_location}'" 
			game_text_file.puts(s) unless @node_location.empty?

			node_video_to_ts if option==true

		end

		game_text_file.close

		p nodes

	end
end


def node_video_to_ts
	p "+ #{@mynode.name} --> node_video_to_ts  +"
	location = @mynode.file_location
	tmp_video = "#{Dir.pwd}/_test/tmp_vid.mp4"
	tmp_audio = "#{Dir.pwd}/_test/tmp_audio.mp4"
	
	!location.empty? ? ts_location = "#{location[0..-5]}.ts" : ts_location="" 
	sync_offset = -0.25

	unless ts_location.empty?
		#1. Extract video stream
		`ffmpeg -i #{location} -vcodec copy -an  -y #{tmp_video}  -loglevel warning`

		#2. Extract audio stream
		`ffmpeg -i #{location} -vn -acodec copy -y #{tmp_audio} -loglevel warning`

		#3. Combine with offset
		`ffmpeg -itsoffset #{sync_offset} -i #{tmp_video} -i #{tmp_audio} -vcodec copy -acodec copy -bsf:v h264_mp4toannexb  -y -shortest '#{ts_location}' -loglevel warning` 
	end

	@mynode.ts_file = ts_location
	@mynode.save!

end


def compile_games
	p "+ compile_games +"
	
	dir = @gamesdir
	nodes = Node.all
	@games = Game.all

	# nodes.map(&:game_id).sort{|a,b| a<=>b }.each{|a| p a}
	# nodes.select{|s| p s if s.game_id==2}

	@games.each do |game|

		p "Starting Game with id: #{game.id}"
		node_locations = nodes.where("game_id=#{game.id}").map(&:ts_file).select{|s| !s.empty?}.sort_by{|a,b| a <=> b}

		@gamename = game.gname
		game_location = "#{dir}/#{@gamename}.mp4"

		game_video_files = '"' + "concat:" + node_locations.join("|") + '"'
		
		`ffmpeg -i #{game_video_files} -c copy -bsf:a aac_adtstoasc -y -shortest #{game_location}` #glue video 

		game.glocation = game_location
		p "Game #{@gamename} saved to #{game_location}" if game.save!

		sleep 3
		
	end
end

def add_intro_to_games
	@games.each do |game|

		@game_name = game.gname
		@game_location = game.glocation

		make_game_image
		add_logo
		turn_img_to_video
		create_silence
		add_silence_to_image_video
		add_img_video_and_game_video
	end
end


def check_games
	Game.all.each{|g| p g.gname}
end

def csv_to_game

	@linecounter = 0

	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	list = "./csv/master/for_medleys_FINAL.csv"
	@csv = CSV.open("./csv/games_final/games.csv", "w", {:col_sep => ";"})
	@game = ''
	@node = ''
	nodes_in_game = []

	CSV.foreach(list,options) do |line|

		line = line.gsub("\"","") if line.include?("\"")#remove illegal quoting Malformed CSV Error if 
		
		node = line[10]
		game = line[12]

		if @linecounter == 0
			nodes_in_game << node
			p "#{game}:#{node}"

		elsif @game != game 
			@csv << [@game,nodes_in_game]
			nodes_in_game = []
			nodes_in_game << node
			p "New #{game}:#{node}"
		else
			nodes_in_game << node if @node != node 
			@csv << [@game,nodes_in_game] if @linecounter - File.open(list).readlines.size == 1
			p "#{game}:#{node}"
		end

		@linecounter += 1
		@game = game
		@node = node

	end

	@csv.close
end

