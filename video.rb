def create_and_match_saved_videos
		# get the info from the saved videos folder and create SavedVideos
	get_all_titles_from_dir

		# match videos on csv with saved videos on hard drive
	return match_videos_with_saved_videos
end

def format_downloaded_video_filenames
	p "* format_downloaded_video_filenames *"
	

	Dir.glob("#{@videodir}/*.mp4").each do |vid|

		extension = File.extname(vid)
		name_with_ext = File.basename(vid)
		name = name_with_ext[0...name_with_ext.index(extension)]

		newname = get_clean_name_alphanum_dash(name)
		newname = newname.downcase.split(" - ").join(" ~ ")

		if !name.include?("~")
			
			p "video renamed: #{newname+extension}"

			File.rename(vid, "#{@videodir}/#{newname}#{extension}")
		else
			p "video already named: #{name_with_ext}"
			p "#{@videodir}/#{newname}#{extension}"

		end
		
	end
end


def match_videos_with_saved_videos

	p "* match_videos_with_saved_videos *"

	number_of_relevant_videos_in_db=0

	Video.all.each do |video|

		 @assumed_filename = "#{video.artist} ~ #{video.title}";
						
		SavedVideo.all.each do |sv|
			 @f = ''
			 @f = sv.filename
			if @f==@assumed_filename
				video.saved = true
				video.location = "#{@f}#{sv.extension}"
				video.save!
				number_of_relevant_videos_in_db +=1

				# p "#{@assumed_filename} found"
			end
		end
	end

	number_of_relevant_videos_in_db

end

def create_list_of_videos_to_download
	Video.all.where("location=''")
end

# Change any webm to mp4
def check_for_webm_videos (directory)

		p "* check_for_webm_videos *"

	Dir.glob("#{@videodir}/*.webm").each do |item|

		item = "'" + item + "'"
		r_item = item[0..item.rindex('/')] +item[item.rindex('/')+1..-7]

		p "item: #{item}"
		p "r_item: #{r_item}"

		webmtomp4 = "ffmpeg -fflags +genpts -i #{item} -r 24 #{r_item}.mp4'" 
		system (webmtomp4)

		video = SavedVideo.where("location=#{item}")

		p "video location - #{item} >> #{r_item}.mp4"

		video.location = "#{r_item}.mp4"
		video.save!

	end
end

#reduce video size
def reduce_video_size file
	`ffmpeg -i #{file} -s 640x480 -b 512k -vcodec mpeg1video -acodec copy`
end

def inspect_videos intermediate_file_array

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
