def crossfade_snippets_to_xfaded_ts 

	@items = Snippet.all.map(&:temp_file_location)
	@durations = Snippet.all.map(&:clip_duration)
	
	@number = @items.length - 1

	make_dir_if_none "#{Dir.pwd}/videos_other","test"
	
	@first = true
	@last = false
	@fadelength = FADELENGTH

	@number.times do |t|

		p "items length = #{@items.length}"
		p "dur length = #{@durations.length}"
		p "number = #{@number}"
		duration = @durations[0].to_s

		if @first
			@vid1 = @items[t]
			@vid2 = @items[t+1]
		
			@outfile = "#{Dir.pwd}/videos/test/temp-#{t}.ts"
				
				#nb need to adjust all timings to reflect the fade length overlap
				# ie timecodes are -1 second from the 2nd video onwards
				# use an extra buffer?

			@dur = @durations[0] + @durations[1] - @fadelength
			@fadeout_start = @durations[0] - @fadelength # set fade out start point 
			
		else
			@vid1 = @outfile
			@vid2 = @items[0]

			@outfile = "#{Dir.pwd}/videos_other/test/temp-#{t}.ts"

			@fadeout_start = @dur - @fadelength # set fade out start point
			@dur += @durations[0]
		end


		if @items.length==1
			@last = true
			@outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/xfaded_video.ts"
	
			rule = Rule.find_by("rule_name='#{PLAYLISTNAME}'")
			rule.xfade_ts = @outfile
			rule.save!
		end


		index1 = @vid1.rindex("/")+1
		@vid1name = @vid1[index1..-1]

		index2 = @vid2.rindex("/")+1
		@vid2name = @vid2[index2..-1]

		index3 = @outfile.rindex("/")+1
		@outname = @outfile[index3..-1]


		# `ffprobe -v verbose -show_format -of json '#{@items[0][0]}'`

		p "first" if @first
		p "last" if @last

		p "1: name= #{@vid1name}"

		p "1: length = #{@items[0][1].to_f}" if @first
		p "1: length = #{@dur - @durations[0]}" unless @first

		p "fadeout starts: #{@fadeout_start}"
		p ""

		p "2: name= #{@vid2name}"

		p "2: length = #{@durations[1]}" if @first
		p "2: length = #{@durations[0]}" unless @first or @last

		p "----------------------"
		p "out= #{@dur}"
		p "*********************"



		`ffmpeg -i '#{@vid1}' -i '#{@vid2}' -f lavfi -i color=black -filter_complex \
		"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=#{@fadeout_start}:d=#{@fadelength}:alpha=1,setpts=PTS-STARTPTS[va0];\
		[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=#{@fadelength}:alpha=1,setpts=PTS-STARTPTS+#{@fadeout_start}/TB[va1];\
		[2:v]scale=720x406,trim=duration=#{@dur}[over];\
		[over][va0]overlay[over1];\
		[over1][va1]overlay=format=yuv420[outv]" \
		 -vcodec libx264 -y -map [outv] '#{@outfile}' -loglevel quiet`

		@items.shift
		@items.shift if @first
		@durations.shift
		@durations.shift if @first
		
		@first = false


	end

end

# It is also possible to use this effect to perform general cross-fades, e.g. to join two songs. In this case, excess would typically be an number of seconds, the −q option would typically be given (to select an ‘equal power’ cross-fade), and leeway should be zero (which is the default if −q is given). For example, if f1.wav and f2.wav are audio files to be cross-faded, then
#    sox f1.wav f2.wav out.wav splice −q $(soxi −D f1.wav),3
# cross-fades the files where the point of equal loudness is 3 seconds before the end of f1.wav, i.e. the total length of the cross-fade is 2 × 3 = 6 seconds (Note: the $(...) notation is POSIX shell).


def crossfade_snippets_to_ts_and_audio_to_wav

	p "******"
	p "crossfade_snippets_to_ts_and_audio_to_wav"
	p "******"

	@items = Snippet.all.map(&:temp_file_location)
	@durations = Snippet.all.map(&:clip_duration)
	@audiofiles = Snippet.all.map(&:normal_audio_file_location)
	@audio_durations = Snippet.all.map(&:normal_audio_duration)
	
	@number = @items.length - 1

	make_dir_if_none "#{Dir.pwd}/videos_other","test"
	
	@first = true
	@last = false
	@fadelength = FADELENGTH # in s
	@audiofadelength = @fadelength/2

	@number.times do |t|

		# p "items length = #{@items.length}"
		# p "dur length = #{@durations.length}"
		# p "number = #{@number}"
		duration = @durations[0].to_s

		if @first
			@vid1 = @items[t]
			@vid2 = @items[t+1]
		
			@outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/tmp/temp-#{t}.ts"

			@audio1 = @audiofiles[t]
			@audio2 = @audiofiles[t+1]

			@audio_outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/tmp/audio-#{t}.wav"
				
				#nb need to adjust all timings to reflect the fade length overlap
				# ie timecodes are -1 second from the 2nd video onwards
				# use an extra buffer?

			@dur = @durations[0] + @durations[1] - @fadelength
			@fadeout_start = @durations[0] - @fadelength # set fade out start point 
			
		else
			@vid1 = @outfile
			@vid2 = @items[0]

			@outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/tmp/temp-#{t}.ts"

			@audio1 = @audio_outfile
			@audio2 = @audiofiles[0]

			@audio_outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/tmp/audio-#{t}.wav"

			@fadeout_start = @dur - @fadelength # set fade out start point
			@dur += @durations[0]
		end


		if @items.length==1
			@last = true
			@outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/xfaded_video.ts"
			@audio_outfile = "#{Dir.pwd}/video_edits/#{PLAYLISTNAME}/xfaded_audio.wav"

		end


		index1 = @vid1.rindex("/")+1
		@vid1name = @vid1[index1..-1]

		index2 = @vid2.rindex("/")+1
		@vid2name = @vid2[index2..-1]

		index3 = @outfile.rindex("/")+1
		@outname = @outfile[index3..-1]


		# `ffprobe -v verbose -show_format -of json '#{@items[0][0]}'`

		# p "first" if @first
		# p "last" if @last

		# p "1: name= #{@vid1name}"

		# p "1: length = #{@items[0][1].to_f}" if @first
		# p "1: length = #{@dur - @durations[0]}" unless @first

		# p "fadeout starts: #{@fadeout_start}"
		# p ""

		# p "2: name= #{@vid2name}"

		# p "2: length = #{@durations[1]}" if @first
		# p "2: length = #{@durations[0]}" unless @first or @last

		# p "----------------------"
		# p "out= #{@dur}"
		# p "*********************"



		`ffmpeg -i '#{@vid1}' -i '#{@vid2}' -f lavfi -i color=black -filter_complex \
		"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=#{@fadeout_start}:d=#{@fadelength}:alpha=1,setpts=PTS-STARTPTS[va0];\
		[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=#{@fadelength}:alpha=1,setpts=PTS-STARTPTS+#{@fadeout_start}/TB[va1];\
		[2:v]scale=720x406,trim=duration=#{@dur}[over];\
		[over][va0]overlay[over1];\
		[over1][va1]overlay=format=yuv420[outv]" \
		 -vcodec libx264 -y -map [outv] '#{@outfile}' -loglevel quiet` # unless File.exists?(@outfile)

		 # process audio in the same way
		 # p "xfading audio"

		 a = `soxi -D '#{@audio1}'`
		 @sox_length = a[0..-2].to_f

		 p @audio1
		 p @audio2
		 p "#{@audio_durations[t]},#{@audio_durations[t+1]} == #{@sox_length}"


		 # p "1: audio = #{@audio1}"
		 # p "2: audio = #{@audio2}"
		 # p "3: out = #{@audio_outfile}"
		 # p "fade: #{@audiofadelength.to_s}"
		 # p "soxlength: #{@sox_length.to_s}"

		 
		# sox FAIL splice: usage: [-h|-t|-q] {position[,excess[,leeway]]}
		# 	  -h        Half sine fade (default); constant gain (for correlated audio)
		# 	  -t        Triangular (linear) fade; constant gain (for correlated audio)
		# 	  -q        Quarter sine fade; constant power (for correlated audio e.g. x-fade)
		# 	  position  The length of part 1 (including the excess)
		# 	  excess    At the end of part 1 & the start of part2 (default 0.005)
		# 	  leeway    Before part2 (default 0.005; set to 0 for cross-fade)

		 s = "sox --no-show-progress '#{@audio1}' '#{@audio2}' '#{@audio_outfile}' splice #{@sox_length},#{@audiofadelength},0" 
		 
		 `#{s}` #unless File.exists?(@audio_outfile)
		@items.shift
		@items.shift if @first
		@durations.shift
		@durations.shift if @first
		@audiofiles.shift
		@audiofiles.shift if @first
		
		@first = false

		if @last
			rule = Rule.find_by("rule_name='#{PLAYLISTNAME}'")
			rule.xfade_ts = @outfile
			rule.xfade_audio = @audio_outfile
			rule.save!
		end


	end

end





# def make_audio_with_fades

# 	p "making audio fades"

# 	@snippets = Snippet.all

# 	@snippets.each do |snip|

# 		t = @snippets.index(snip)
# 		@audio = snip.normal_audio_file_location
# 		@audio_out = "#{Dir.pwd}/videos/test/audio-temp-#{t}.wav"

# 		 if snip==@snippets[0]
# 		 	# add 1 sec fadeout to first snippet
# 		 	# `sox -t wav '#{@audio}' -t wav '#{@audio_out}' fade 0 1 −−no−show−progress` 


# 		 elsif snip==@snippets[-1]
# 		 	# add 1 sec fadein to last snippet
# 		 	# `sox -t wav '#{@audio}' -t wav '#{@audio_out}' fade 1 0 −−no−show−progress` 

# 		else
# 			# add 1 sec fadeout and 1 sec fadein
# 			# `sox -t wav '#{@audio}' -t wav '#{@audio_out}' fade 1 1 −−no−show−progress` 
# 		end

# 		p @audio_out

# 		snip.xfaded_audio_file_location = @audio_out
# 		snip.save!
		
# 	end
# end

# def crossfade_audio_with_fades
# 	@audiofiles = Snippet.all.map(&:xfaded_audio_file_location)

# end
