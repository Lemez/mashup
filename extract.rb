#usage "ruby ../extract.rb 'KIDS' " to download videos with this name on the doc to a new playlist
#usage "ruby ../extract.rb " to process the current videos on the hard drive 

require 'streamio-ffmpeg'
require 'viddl-rb'
require 'open-uri'
require 'csv'
require 'youtube_it'
require 'open3'
require 'pp'
require 'awesome_print'
require_relative 'keys.rb'
require_relative 'video.rb'
require 'fileutils'
require 'vimeo'
require 'httparty'
require 'cgi'

# USEFUL FFMPEG COMMANDS http://www.labnol.org/internet/useful-ffmpeg-commands/28490/

#################### FUNCTIONS ################################

def vimeo_login
	@base = Vimeo::Advanced::Base.new("#{VIMEO_IDENTIFIER}", "#{VIMEO_SECRET}")
	@access_token = VIMEO_ACCESS_TOKEN
end

def yt_login

	user = "RQVtG1GPjsa0YHOmGyiiqQ" #Engage channel
	client = YouTubeIt::Client.new(:username => YT_USER, :password =>  YT_PW, :dev_key => YT_DEV_KEY)

	return client, user
end

# get list of files

def getfiles 
	list = CSV.read("../csv/songlist.csv") 
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


def check_if_playlist_exists (name)
	@name = name
	return [@client.playlists[0].title==@name,@client.playlists[0].playlist_id]
end

def get_vids_on_playlist (name)

	@current_playlist_video_ids = []
	@current_playlist_video_titles = []
	exists, id = check_if_playlist_exists(name)

	current_playlist_video_ids = []

	videos = @client.playlist(id).videos
	videos.each do |v|
	 	@current_playlist_video_ids << v.unique_id
	 	@current_playlist_video_titles << v.title
	end

end

def add_videos_to_playlist p,i,n
	i.each do |vid| 
		@client.add_video_to_playlist(p, vid)
		t = @client.video_by(vid)
		p "adding video #{t} to new playlist #{n}"
	end
end


def add_to_playlist_if_not_already_there (name,video_ids,existing, id,titles)

	@ids = video_ids
	@titles = titles
	@name = name
	@id = id

	unless existing
		@playlistID = @client.add_playlist(:title => @name, :description => @name).playlist_id
		add_videos_to_playlist @playlistID,@ids,@name

	else
		@playlist = @client.playlist(@id).playlist_id

		get_vids_on_playlist(@name)

		#add only if songs not already on playlist
		p "Currently on there: #{@current_playlist_video_ids}"
		p "Currently on there: #{@current_playlist_video_titles}"

		@ids.each do |i|
			p "Id under consideration #{i}"

				unless @current_playlist_video_ids.include?(i)

				@client.add_video_to_playlist(@playlist, i)

				title = @client.video_by(i).title

				p "adding #{title} to playlist #{name}"
			else
				p " #{title} already on playlist #{name}"
			end
		end
	end


	
	return @playlist
end



def make_dir_if_none (dir,name)

	d = "#{dir}#{name}"
	dir_exists = Dir.exists?(d) 

	unless dir_exists
		p "making dir #{name}"
		FileUtils::mkdir_p d	
	else
		p "dir #{name} exists"
	end
	# FileUtils::mkdir_p 'foo/bar'
end




def get_all_titles_from_dir dir
	p dir
	all_currently_saved_videos = []

	Dir.glob("#{dir}/*.mp4").each do |item|
		size = File.size(item)
		rootpath,newname,name,extension = get_file_attributes item

		current_vids = all_currently_saved_videos.map{|e| e[0]}

		unless current_vids.include?(newname) or size==0 
			p "#{newname} in current directory"
			all_currently_saved_videos << [newname,size,item] 
		end

	end
	p all_currently_saved_videos
	return all_currently_saved_videos
end

def try_vimeo title,dir,source
	p "Trying to download #{title} from Vimeo"
	escaped_title = CGI::escape(title)
	api_url = "https://api.vimeo.com/videos?query=#{escaped_title}&sort=relevant&access_token=#{@access_token}"
	vimeo_response = JSON.parse(HTTParty.get api_url)
	id = vimeo_response["data"][0]["uri"].gsub(/[^\d]/, '')  #"/videos/58786867"
	

	download_a_video id,dir,source

end

def download_a_video (video_id,my_directory,source)
	baseurl = "http://www.youtube.com/watch?v=" if source=='youtube'
	baseurl = "http://vimeo.com/videos/" if source=='vimeo'

	download_video = "viddl-rb #{baseurl}#{video_id} -d 'aria2c' -s '#{my_directory}'"
	system (download_video)
end

# Download the videos not on the HD already from this playlist

def download_all_videos_from_pl id,d_name
	my_directory = "#{@dir}#{d_name}"

	 videos_already_saved_array = get_all_titles_from_dir my_directory

	 videos_already_saved_titles, videos_already_saved_paths = 
	 					videos_already_saved_array.map{|e| e[0]}, videos_already_saved_array.map{|e| e[2]}

	 #log in to Vimeo
	 vimeo_login


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
				# Process.kill("KILL", stream.pid)
				source='vimeo'
				try_vimeo v,my_directory,source 
			end

			p "already have it" if videos_already_saved_titles.include?(v)
		end


	end

	
end


def get_clean_name (s)
	return s.gsub(/[^0-9a-z. ]/i, '')
end

def get_clean_name_alphanum (s)
	return s.gsub(/[^0-9a-z ]/i, '').gsub("  "," ")
end

def get_file_attributes item
	extension = File.extname(item)
	name = File.basename(item)
	oldname = name[0...name.index(extension)]
	newname = get_clean_name_alphanum(oldname)
	rootpath = item[0..item.rindex('/')]

	return rootpath,newname,name,extension
end


#clean up video names
def clean_up_video_names (directory)

	Dir.glob("#{directory}/*").each do |item|
		rootpath,newname,name,extension = get_file_attributes item
		File.rename(rootpath+name, rootpath+newname+extension) if name != newname
	end
end


# Change any webm to mp4
def check_for_webm_videos (directory)
		p directory
	Dir.glob("#{directory}/*.webm").each do |item|
		

		item = "'" + item + "'"
		r_item = item[0..item.rindex('/')] +item[item.rindex('/')+1..-7]

		p "item: #{item}"
		p "r_item: #{r_item}"

		webmtomp4 = "ffmpeg -fflags +genpts -i #{item} -r 24 #{r_item}.mp4'" 
		system (webmtomp4)

	end
end

def convert_to_time_format(s,d)
	# ms to 00:02:00

	ss, ms = s.to_i.divmod(1000)         
	mm, ss = ss.divmod(60)            
	hh, mm = mm.divmod(60)          
	start =  format("%02d:%02d:%02d", hh, mm, ss)
	dur = format("00:00:%02d", d.to_i/1000)

	return start,dur 
end


def edit_videos (directory,start,dur)
 	Dir.glob("#{directory}/*.mp4").each do |item|

 	name = File.basename(item)
	
 	# make edit dir if none
 	make_dir_if_none(directory,"edits")

	# convert time to h:m:s format
	starttime,duration = convert_to_time_format(start,dur) 
  
 #  #save two second cut of each video to edits folder starting at 00:01:30
	command = "ffmpeg -i '#{item}' -ss #{starttime} -t #{duration} -async 1 '#{directory}/edits/#{duration}#{name}'"

	system( command )

 end
end


def add_files_to_text_doc (name,directory)
	# 1.create a list from the file names
		file = open("#{directory}/#{name}.txt",'w')
		Dir.glob("#{directory}/*.mp4").each do |item|

			next if item == "#{@directory}/." or item == "#{directory}/.." or item=="#{directory}/.DS_Store"
			s = "file '#{item}'"
			file.puts(s)
		end
		file.close
		return "#{directory}/#{name}.txt"
end

def make_intermediate_files(f,directory,name)

	file=open(f)
	i = 0
	@inter_files = []

	file.each do |f|
		i+=1
		istring = i.to_s
		f = f[5..-2]


		inter_name = "#{directory}/intermediate#{istring}.ts"
		@inter_files << inter_name

		# Make sure that all files have same aspect ratio
		# http://video.stackexchange.com/questions/9947/how-do-i-change-frame-size-preserving-width-using-ffmpeg

		file_with_ar = "ffmpeg -i #{f} -vf scale=720x406,setdar=16:9 -c:v libx264 -preset slow -profile:v main -crf 20 #{inter_name}"
		system(file_with_ar)

	end
	file.close
end

def work_the_av_magic

	#2D concatenate the files creatd using the below format 
		# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
		
	#VIDEO, no audio
	str = ''
	@inter_files.each{|name| str+=name+'|'}
	str.chop! # remove last pipe
	str = '"concat:' + str + '"'
	video_s = "ffmpeg -i #{str} -c copy '#{directory}/video.mp4'"

	# concatenate the video files 
	p video_s
	system(video_s)


	#AUDIO, no video
	str = ''
	@inter_files.each{|name| str+=name+'|'}
	str.chop! # remove last pipe
	str = '"concat:' + str + '"'
	audio_s = "ffmpeg -i #{str} -vn -acodec 'copy' '#{directory}/audio.mp2'"

	# concatenate the video files 
	p audio_s
	system(audio_s)

	#mashem together
	total_s = "ffmpeg -i '#{directory}/video.mp4' -i '#{directory}/audio.mp2' '#{directory}/output.mp4'"
	p total_s
	system(total_s)		


end


################### end functions #################################

################## CODE ###########################################
			###### variables #########################

@dir = Dir.pwd + '/vids/'
@time = Time.now.usec.to_s
@playlist_name = ARGV[0] || nil	


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
			



# 		# #2D concatenate the files creatd using the below format (works for 1/3rd of videos)
# 		# 	# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
		
# 		#VIDEO, no audio
# 		str = ''
# 		inter_files.each{|name| str+=name+'|'}
# 		str.chop! # remove last pipe
# 		str = '"concat:' + str + '"'
# 		video_s = "ffmpeg -i #{str} -c copy 'video#{@time}.mp4'"

# 		# concatenate the video files 
# 		p video_s
# 		system(video_s)


# 		#AUDIO, no video
# 		str = ''
# 		inter_files.each{|name| str+=name+'|'}
# 		str.chop! # remove last pipe
# 		str = '"concat:' + str + '"'
# 		audio_s = "ffmpeg -i #{str} -vn -acodec 'copy' 'audio#{@time}.mp2'"

# 		# concatenate the video files 
# 		p audio_s
# 		system(audio_s)

# 		#mashem together
# 		total_s = "ffmpeg -i 'video#{@time}.mp4' -i 'audio#{@time}.mp2' 'output#{@time}.mp4'"
# 		p total_s
# 		system(total_s)		


# 		# 2E trying to save file info for each temp file
# 			@info = {}

# 			inter_files.each do |name|
# 				important = {
# 					:bitrate => '',
# 					:video => '',
# 					:audio => ''
# 				} 

# 				sss ="ffprobe -v verbose -show_format -of json ./#{name}"
# 											# system(X) == `X` == %x[X]  :))))))) check this out!!!

# 				stdin, stdout, stderr, wait_thr = Open3.popen3("#{sss}")
# 				stdout.gets(nil)
# 				stdout.close

# # extract the info we need
# 				what_is_wanted = stderr.gets(nil)
				
# # get bitrate
# 				bit_index = what_is_wanted.index("bitrate")+9
# 				bit_text = what_is_wanted[bit_index..-1]
# 				end_bit_index = bit_text.index("kb/s")+3
# 				important_bit = bit_text[0..end_bit_index]

# 				important[:bitrate] = important_bit

# # get video encoding data	

# 				vid_index = what_is_wanted.index("Video:")+7
# 				vid_text = what_is_wanted[vid_index..-1]
# 				end_vid_index = vid_text.index("Stream #0:1[0x101](und):")-6
# 				important_vid = vid_text[0..end_vid_index]

# 				important[:video] = important_vid

# # get audio encoding data

# 				aud_index = what_is_wanted.index("Audio:")+7
# 				aud_text = what_is_wanted[aud_index..-1]
# 				end_aud_index = -2
# 				important_aud = aud_text[0..end_aud_index]

# 				important[:audio] = important_aud	
				
# # end data saving

# 				stderr.close
# 				exit_code = wait_thr.value

# # save info for each file
# 				@info[name] = important

# 			end

# 			# from experiments, seems as through screen size is critical factor: all the 480x360 works, the other don't
# 			ap @info

# # 			# Sooooooo....
# # # We will try MP4box to see if it is good at changing the ARs so that we can put our vids
# # # Filtering and streamcopy cannot be used together





		









