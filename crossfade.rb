def crossfade_snippets_to_mp4 

	@items = Snippet.all.map(&:temp_file_location)
	@durations = Snippet.all.map(&:clip_duration)

	@number = @items.length - 1

	make_dir_if_none "#{Dir.pwd}/videos_other","test"
	
	@first = true
	@last = false
	@fadelength = 1 # in s

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
