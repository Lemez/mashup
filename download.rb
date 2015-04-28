def download_critical_vids
	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	list = "./csv/videos/video_hits.csv"
	undownloaded = "./csv/undownloaded.csv"
	@threads = []

	not_on_vimeo = []
	CSV.foreach(undownloaded,options) {|row|not_on_vimeo << row[1]}
	
	CSV.foreach(list,options) do |line|

		get_all_titles_from_dir
		@saved_titles = SavedVideo.all.map(&:title)

		title,hits = line[0],line[1]
		song_artist,song_title = title.downcase.split("~")

		next if @saved_titles.include?(song_title)
		next if not_on_vimeo.include?(song_title)
		p "____________"
		p "not_on_vimeo"
		p "____________"
		p "#{hits.to_s}: #{title}"
		p "____________"

		p "Continue? Press y or any other key to skip"
    	`echo "Do you wish to continue?"`

   		output = STDIN.gets.chomp!

		if output == "y"
			p "yes" 
			get_vimeo_manually song_artist,song_title,'vimeo'
	 	else
	 		next
	 	end
	end
	@threads.each { |t| t.join }
end


def download_undownloaded_vids array

	p "* download_undownloaded_vids *"

	array.each do |record|
		@song_artist = record.artist
		@song_title = record.title
		@vid = record.yt_id

		p "Not trying YT due to broken YT dl"

		video_string = "http://www.youtube.com/watch?v=#{@vid}"
		download_video = "viddl-rb #{video_string} -d 'aria2c' -s #{@videodir}"

		# shell_command = `#{download_video}`
		
		# aborted = shell_command.include? "Download aborted"

		# sleep 1 #wait 1 sec

		# # go to Vimeo to download if it doesnt work
		# if aborted

			# p "FAILED: #{shell_command}"
			# sleep 3 #wait 3 secs

			

			 p "Continue with #{@song_artist} - #{@song_title}? Press y to continue,  B to break or any other key to skip"
		    `echo "Do you wish to continue?"`

		    output = STDIN.gets.chomp!

			if output == "y"

				"Getting from Vimeo"

				get_vimeo_manually @song_artist,@song_title,'vimeo'

			elsif output == "B"
				return

			else
			 	write_to_not_dl_file @song_artist, @song_title

			 	next

			 end

			

	# 	else
	# 		p "SUCCESS: #{shell_command}"
	# 		sleep 3 #wait 3 secs
			
	# 		# if successful save vimeo id and saved=true and location
	# 	end
	end
end


def try_vimeo artist,title,source
	vimeo_login

	p "Trying to download #{artist} #{title} from Vimeo"
	p VIMEO_ACCESS_TOKEN
	escaped_title = CGI::escape("#{artist} #{title}")
	api_url = "https://api.vimeo.com/videos?query=#{escaped_title}&sort=relevant&access_token=#{VIMEO_ACCESS_TOKEN}"
	vimeo_response = JSON.parse(HTTParty.get api_url)
	# p vimeo_response
	id = vimeo_response["data"][0]["uri"].gsub(/[^\d]/, '')  #"/videos/58786867"
	
	download_a_video id,source
end

def get_vimeo_manually artist,title,source
	@title_to_check = " #{artist} #{title}"
	p "Trying to download #{artist} #{title} from Vimeo manually"

	escaped_title = @title_to_check #CGI::escape(title)
	url = "https://vimeo.com/search?q=#{escaped_title}"
	jarow = FuzzyStringMatch::JaroWinkler.create( :native )

    begin
    	browser = Watir::Browser.new 
	    browser.driver.manage.timeouts.implicit_wait = 3 #3 seconds
	    browser.goto url

	    p "Searching for #{@title_to_check} at url #{browser.url}"

	    results = browser.ol :class => 'js-browse_list clearfix browse browse_videos browse_videos_thumbnails kane'
    	results.wait_until_present # wait until the url changes
    	 # TO DO!!!! CHECK TO MAKE SURE THAT FIRST X ELEMENTS OF SEARCH QUERY MATCH LI TEXT, IN ORDER TO STOP FALSE DOWNLOADS
	    @highest_match = 0
	    @distance = 0
	    @vimeo_id = ""
	    @best_title = ""
	   	results.lis.each do |li|
	    	@vimeo_title = li.a.title.downcase
	    	unless @vimeo_title.include?("live") or
	    	 @vimeo_title.include?("cover") or
	    	 @vimeo_title.include?("explicit") or
	    	 @vimeo_title.include?("remix") or
	    	 @vimeo_title.include?("lyric") or
	    	 @vimeo_title.include?("tour") or
	    	 @vimeo_title.include?("unofficial")or
	    	 @vimeo_title.include?("dj")

	    		@distance = jarow.getDistance( @vimeo_title, @title_to_check)

	    		@distance += 0.2 if @vimeo_title.include?("official") || @vimeo_title.include?("album")
	    		if @distance > @highest_match
	    			@highest_match = @distance 
	    			@vimeo_id = li.id.gsub(/[^\d]/, '')
	    			@best_title = @vimeo_title

	    			p "#{@best_title} with id #{@vimeo_id} is the best match so far"
	    		end
			end 
	    end

    p "Searching for #{@title_to_check}, #{@best_title} has Vimeo ID #{@vimeo_id} with distance #{@highest_match}"

    p "Continue? Press y or any other key to skip"
    `echo "Do you wish to continue?"`

    output = STDIN.gets.chomp!

	if output == "y"
		p "yes" 
		download_a_video @vimeo_id,'vimeo'
	 else
	 	p "Enter correct 8-10 digit Vimeo ID or enter to skip"
	 	`echo "Do you wish to continue?"`
	 	@manual_id = STDIN.gets.chomp!

	 	if !@manual_id.empty?
	 		@threads << Thread.new{download_a_video @manual_id,'vimeo'}
	 		play_sound true
	 	else
	 		write_to_not_dl_file artist,title
	 		"Trying next video"
	 		return
	 	end
	 end
	

    rescue Timeout::Error, Watir::Wait::TimeoutError => e
    	puts "Vimeo search for #{@title_to_check} page did not load: #{e}" 
    	puts $!, $@
    	return

    end

    at_exit { browser.close  } # close browser on exit
end

def download_a_video (video_id,source)
	baseurl = "http://www.youtube.com/watch?v=" if source=='youtube'
	baseurl = "http://vimeo.com/videos/" if source=='vimeo'

	download_video = "viddl-rb #{baseurl}#{video_id} -d 'aria2c' -s '#{@videodir}'"
	system (download_video)

	format_downloaded_video_filenames

	# if successful save vimeo id and saved=true and location
end

# Download the videos not on the HD already from this playlist

def download_all_videos_from_pl id,d_name
	my_directory = "#{@dir}#{d_name}"

	 videos_already_saved_array = get_all_titles_from_dir my_directory

	 videos_already_saved_titles, videos_already_saved_paths = 
	 					videos_already_saved_array.map{|e| e[0]}, videos_already_saved_array.map{|e| e[2]}

	@current_playlist_video_titles.each do |v|
			source = 'youtube'
			index = @current_playlist_video_titles.index(v)
			p index
			vid = @current_playlist_video_ids[index]
			p vid

		if !videos_already_saved_titles.include?(v)	
			
			video_string = "http://www.youtube.com/watch?v=#{vid}"
			download_video = "viddl-rb #{video_string} -d 'aria2c' -s '#{my_directory}'"

			captured_stdout = ''
			captured_stderr = ''
			stdin, stdout, stderr, wait_thr = Open3.popen3("#{download_video}")
			pid = wait_thr.pid
			stdin.close
			captured_stdout = stdout.gets(nil)
			aborted = captured_stdout.include? "Download aborted"
  			# captured_stderr = stderr.read
			wait_thr.value # Process::Status object returned

	# extract the info we need
			puts "STDOUT: " + captured_stdout
			# puts "STDERR: " + captured_stderr

			# go to Vimeo to download if it doesnt work
			if aborted
				artist_match_results = match_best v, @rule_artists
				@song_artist = artist_match_results[0]
				remaining_words = artist_match_results[1]
				song_match_results = match_best remaining_words, @rule_titles
				@song_title = song_match_results[0]

				source='vimeo'
				get_vimeo_manually @song_artist,@song_title,@mydir,"vimeo"
				# Process.kill("KILL", stream.pid)
				# get_vimeo_manually v,my_directory,source 
			end

			p "already have it" if videos_already_saved_titles.include?(v)
		end


	end

	
end