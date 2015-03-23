def download_undownloaded_vids array

	p "*****"
	p "download_undownloaded_vids"
	p "*****"

	array.each do |record|
		@song_artist = record.artist
		@song_title = record.title
		@vid = record.yt_id

		video_string = "http://www.youtube.com/watch?v=#{@vid}"
		download_video = "viddl-rb #{video_string} -d 'aria2c' -s #{@videodir}"

		shell_command = `#{download_video}`
		
		aborted = shell_command.include? "Download aborted"

		sleep 1 #wait 1 sec

		# go to Vimeo to download if it doesnt work
		if aborted

			p "FAILED: #{shell_command}"
			sleep 3 #wait 3 secs

			get_vimeo_manually @song_artist,@song_title,'vimeo'

		else
			p "SUCCESS: #{shell_command}"
			sleep 3 #wait 3 secs
			
			# if successful save vimeo id and saved=true and location
		end
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
	p "Trying to download #{title} from Vimeo manually"
	
	escaped_title = @title_to_check #CGI::escape(title)
	url = "https://vimeo.com/search?q=#{escaped_title}"
	jarow = FuzzyStringMatch::JaroWinkler.create( :native )

    browser = Watir::Browser.new 
    browser.driver.manage.timeouts.implicit_wait = 3 #3 seconds
    browser.goto url
    p "URL is #{browser.url}"

    results = browser.ol :class => 'js-browse_list clearfix browse browse_videos browse_videos_thumbnails kane'

    results.wait_until_present # wait until the url changes

    # TO DO!!!! CHECK TO MAKE SURE THAT FIRST X ELEMENTS OF SEARCH QUERY MATCH LI TEXT, IN ORDER TO STOP FALSE DOWNLOADS
    @highest_match = 0
    @vimeo_id = ""
    @best_title = ""
   	results.lis.each do |li|
    	@vimeo_title = li.a.title.downcase
    	unless @vimeo_title.include?("live") or @vimeo_title.include?("cover") or @vimeo_title.include?("explicit") or @vimeo_title.include?("remix") or @vimeo_title.include?("lyrics") or @vimeo_title.include?("tour")
    		distance = jarow.getDistance( @vimeo_title, @title_to_check)
    		if distance > @highest_match
    			@highest_match = distance 
    			@vimeo_id = li.id.gsub(/[^\d]/, '')
    			@best_title = @vimeo_title
    		end
		end
    end

    p "Searching for #{@title_to_check}, #{@best_title} has Vimeo ID #{@vimeo_id} with distance #{@highest_match}"

	download_a_video @vimeo_id,source

end

def download_a_video (video_id,source)
	baseurl = "http://www.youtube.com/watch?v=" if source=='youtube'
	baseurl = "http://vimeo.com/videos/" if source=='vimeo'

	download_video = "viddl-rb #{baseurl}#{video_id} -d 'aria2c' -s '#{@videodir}'"
	system (download_video)

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