def inspect intermediate_file_array

	@inter = intermediate_file_array
	@info = {}

	@inter.each do |name|
		important = {
			:bitrate => '',
			:video => '',
			:audio => ''
		} 

		sss ="ffprobe -v verbose -show_format -of json ./#{name}" # system(X) == `X` == %x[X]  :) check this out!
									
		stdin, stdout, stderr, wait_thr = Open3.popen3("#{sss}")
		stdout.gets(nil)
		stdout.close

		# extract the info we need
		what_is_wanted = stderr.gets(nil)
		
		# get bitrate
		bit_index = what_is_wanted.index("bitrate")+9
		bit_text = what_is_wanted[bit_index..-1]
		end_bit_index = bit_text.index("kb/s")+3
		important_bit = bit_text[0..end_bit_index]

		important[:bitrate] = important_bit

		# get video encoding data	
		vid_index = what_is_wanted.index("Video:")+7
		vid_text = what_is_wanted[vid_index..-1]
		end_vid_index = vid_text.index("Stream #0:1[0x101](und):")-6
		important_vid = vid_text[0..end_vid_index]

		important[:video] = important_vid

		# get audio encoding data
		aud_index = what_is_wanted.index("Audio:")+7
		aud_text = what_is_wanted[aud_index..-1]
		end_aud_index = -2
		important_aud = aud_text[0..end_aud_index]

		important[:audio] = important_aud	
		
		# end data saving
		stderr.close
		exit_code = wait_thr.value

		# save info for each file
		@info[name] = important
	end

	# from experiments, seems as through screen size is critical factor: all the 480x360 works, the other don't
	ap @info
end