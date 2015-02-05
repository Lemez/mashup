#usage "ruby ../extract.rb 'KIDS' " to download videos with this name on the doc to a new playlist
#usage "ruby ../extract.rb " to process the current videos on the hard drive 





# USEFUL FFMPEG COMMANDS http://www.labnol.org/internet/useful-ffmpeg-commands/28490/





		    ###### end variables #####################

# unless @playlist_name.nil?

# 	@mydir = "#{@dir}#{@playlist_name}"

# 	# # use ARGV to get the YT video ids from file
# 	video_ids,titles = get_videos_from_songlist (@playlist_name)
# 	p video_ids
# 	p @playlist_name

	# @client,@user = yt_login
	# # p @client
	# # p @user

# 	# # check if playlist with that name already exists
# 	pl_exists,pl_id = check_if_playlist_exists (@playlist_name)
# 	# p "2"

# 	# # add to existing or new playlist
# 	new_pl_id = add_to_playlist_if_not_already_there (@playlist_name,video_ids,pl_exists,pl_id)
# 	# p "3"

# 	# make a new folder if current video playlist folder is not on local drive
# 	make_dir_if_none (@playlist_name)
# 	# p "4"

# # TO DO - check in the folder to see if the cleaned videos exist on the hard drive - ie do the cleaning here?)


# 	# # download all the videos from that playlist
# 	download_all_videos_from_pl (new_pl_id,@playlist_name)
# 	p "5"

# 	# # remove all non-alphanumeric characters from saved video filename
# 	clean_up_video_names (@mydir)

# 	# # convert any webm format files to mp4 
# 	check_for_webm_videos (@mydir)

# end

# see what is on the playlist
# get_vids_on_playlist (@playlist_name)

# clean_up_video_names (@dir)
# edit_videos (@dir)


# # iterate over the videos
# 		############ cd into kids_videos
# 		############ ruby ../extract.rb
#

# # # concatenate the files together
# 	# 1.create a list from the file names
# 		file = open("#{@time}.txt",'w')
# 		Dir.glob("#{@dir}shorts/*.mp4").each do |item|

# 			next if item == "#{@dir}." or item == "#{@dir}.." or item=="#{@dir}.DS_Store"
# 			s = "file '#{item}'"
# 			file.puts(s)
# 		end
# 		file.close


# # 	#2.concatenate the files in the list together
# 									# 	#2A this doesnt work
# 									# 		# join = "ffmpeg -f concat -i './myfile.txt' -c cat test2.mp4"
# 									# 		# system (join)


# 	#2B create intermediate files for each file using the below format
# 		# ffmpeg -i input1.mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts intermediate1.ts

		
# 		file=open('./myfile5.txt')
# 		i = 0
# 		inter_files = []

# 		file.each do |f|

# 			i+=1
# 			istring = i.to_s
# 			f = f[5..-2]

# 			inter_name = "intermediate#{istring}#{@time}.ts"
# 			inter_files << inter_name # save all the file names

# 			# Make sure that all files have same aspect ratio
# 			# http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg

# 			file_with_ar = "ffmpeg -i #{f} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 #{inter_name}"
# 			system(file_with_ar)


# 																		# make a temp file for each
# 																			# make_intermediate = "ffmpeg -i #{f} -c copy -bsf:v h264_mp4toannexb -f mpegts #{inter_name}"
# 																			# p make_intermediate
# 																			# system (make_intermediate) 

# 		end


# # 		 # concatenate the files 
			



# # 			# Sooooooo....
# # # We will try MP4box to see if it is good at changing the ARs so that we can put our vids
# # # Filtering and streamcopy cannot be used together





		









