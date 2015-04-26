def check_snips
	Snippet.first
end

def node_video_to_ts node
	p "+ node_video_to_ts #{node} +"
	@mynode = node 
	location = @mynode.file_location
	tmp_video = "#{Dir.pwd}/_test/tmp_vid.mp4"
	tmp_audio = "#{Dir.pwd}/_test/tmp_audio.mp4"
	
	!location.empty? ? ts_location = "#{location[0..-5]}.ts" : ts_location="" 
	sync_offset = 0.15

	unless ts_location.empty?
		#1. Extract video stream
		`ffmpeg -i #{location} -vcodec copy -an #{tmp_video} -y`

		#2. Extract audio stream
		`ffmpeg -i #{location} -vn -acodec copy #{tmp_audio} -y`

		#3. Combine with offset
		`ffmpeg -itsoffset #{sync_offset} -i #{tmp_audio} -i #{tmp_video}  -acodec copy -vcodec copy -bsf:v h264_mp4toannexb  -y -shortest '#{ts_location}'` 
	end

	@mynode.ts_file = ts_location
	@mynode.save!

end

def which_vids_are_done
	gamefile = "./csv/games_final/games.csv"
	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	@found = []
	@notyet = []

	CSV.foreach(gamefile,options) do |line|
		game, nodes = line[0], line[1][1...-2].split(",")
		nodes.each do |n|
			n = n.gsub!(/[^0-9a-z_]/i, '')
			File.exists?("#{@finaldir}/#{n}/#{n}_subs_logo.mp4") ? @found << n : @notyet << n
		end
	end

	p "Found: #{@found.length} - #{@found}"
	p ""
	p "Not yet: #{@notyet.length} - #{@notyet}"
end

def check_games
	Game.all.each{|g| p g.gname}
end


def compile_games
	p "+ compile_games +"
	
	make_dir_if_none @gamesdir, @playlist_name
	dir = "#{@gamesdir}/#{@playlist_name}"
	nodes = Node.all
	games = Game.all

	# nodes.map(&:game_id).sort{|a,b| a<=>b }.each{|a| p a}
	# nodes.select{|s| p s if s.game_id==2}

	games.each do |game|

		p "Starting Game with id: #{game.id}"
		node_locations = nodes.where("game_id=#{game.id}").map(&:ts_file).select{|s| !s.empty?}.sort! { |a,b| a.name <=> b.name }

		game_video_files = '"' + "concat:" + node_locations.join("|") + '"'
		
		`ffmpeg -i #{game_video_files} -c copy -bsf:a aac_adtstoasc -y -shortest '#{dir}/#{game.gname}.mp4'` #glue video 
		
	end
end


def glue_intermediate_files_and_normal_audio

	p "* glue_intermediate_files_and_normal_audio *"

	# #2D concatenate the files creatd using the below format 
		# ffmpeg -i "concat:intermediate1.ts|intermediate2.ts" -c copy -bsf:a aac_adtstoasc output.mp4
	
	make_dir_if_none "#{@editsdir}/#{@playlist_name}", "tmp"
	dir = "#{@editsdir}/#{@playlist_name}/tmp"

	@temp_video_files = '"' + "concat:" + Snippet.selected.map(&:temp_file_location).join("|") + '"'
	# @normal_audio_files_ts = '"' + "concat:" + @selectedsnippets.map(&:normal_audio_file_location).join("|") + '"'
	@normal_audio_files_wav = "'" + Snippet.selected.map(&:normal_audio_file_location).join("' '") + "'"

	p @temp_video_files
	


	`ffmpeg -i #{@temp_video_files} -c copy -y '#{dir}/_video.mp4'` #glue video 
	# # `ffmpeg -i #{@normal_audio_files} -vn -acodec 'copy' -y '#{dir}/_audio.mp2'`  #glue audio

	`sox #{@normal_audio_files_wav} '#{dir}/_audio.wav'`

	make_dir_if_none Dir.pwd, "videos_final" #make dir
	make_dir_if_none @finaldir, @playlist_name #make dir

	# glue them together ORDER IMPORTANT::: AUDIO then VIDEO
	command_xfaded = "ffmpeg -i '#{dir}/_audio.wav' -i '#{dir}/_video.mp4' -y '#{Dir.pwd}/videos_final/xfaded_#{@playlist_name}.mp4' -loglevel quiet" 
	command = "ffmpeg -i '#{dir}/_audio.wav' -i '#{dir}/_video.mp4' -y '#{Dir.pwd}/videos_final/#{@playlist_name}/#{@playlist_name}.mp4' -loglevel quiet"
	
	command = command_xfaded if @@xfade
	system(command)

	Snippet.selected.map(&:temp_file_location).each do |f| 
		p "removing temp file #{f}"
		 `rm '#{f}'`
	end


	# clean up
	# `rm '#{dir}/_video.mp4'`
	# `rm '#{dir}/_audio.wav'`

end


def process_xfaded_ts_to_mp4

	p "* process_xfaded_ts_to_mp4 *"

	infile = "#{Dir.pwd}/video_edits/#{@playlist_name}/xfaded_video.ts"
	final_xfaded_mp4 = "#{Dir.pwd}/video_edits/#{@playlist_name}/xfaded_video.mp4"

	make_dir_if_none "#{Dir.pwd}/videos_final", "#{@playlist_name}" #make dir
	
	rule = Rule.find_by("xfade_ts='#{infile}'")
	rule.xfade_mp4 = final_xfaded_mp4
	rule.save!

	`ffmpeg -i '#{infile}' -acodec copy -vcodec copy -y '#{final_xfaded_mp4}' -loglevel quiet`
end

def glue_crossfaded_video_and_normal_audio

	p "* glue_crossfaded_video_and_normal_audio *"

	mp4_file = "#{Dir.pwd}/video_edits/#{@playlist_name}/xfaded_video.mp4"
	final_video_and_audio_file = "#{Dir.pwd}/videos_final/#{@playlist_name}/final_xfaded_video_and_audio.mp4"

	dir = "#{@editsdir}/#{@playlist_name}/tmp"

	# @normal_audio_files_wav = "'" + Snippet.selected.map(&:normal_audio_file_location).join("' '") + "'"
	# `sox #{@normal_audio_files_wav} '#{dir}/_audio.wav'` 
	
	@trimmed_audio_files_wav = "'" + Snippet.selected.map(&:trimmed_audio).join("' '") + "'"
	`sox --no-show-progress #{@trimmed_audio_files_wav} '#{dir}/_audio.wav'`

	# glue them together ORDER IMPORTANT::: AUDIO then VIDEO
	message = "ffmpeg -i '#{dir}/_audio.wav' -i '#{mp4_file}' -y '#{final_video_and_audio_file}' -loglevel quiet"

	p message
	system(message)

	rule = Rule.find_by("xfade_mp4='#{mp4_file}'")
	rule.final_mp4 = final_video_and_audio_file
	rule.save!


	# clean up
	# `rm '#{dir}/_video.mp4'`
	# `rm '#{dir}/_audio.wav'`
end

def test_gluing

	p "* test_gluing *"

	audio = "/Users/JW/Dropbox/T10/SBRI/_code/video_edits/3rd person present tense (303)/xfaded_audio.wav"
	video = "/Users/JW/Dropbox/T10/SBRI/_code/video_edits/3rd person present tense (303)/xfaded_video.mp4"
	final =  "/Users/JW/Dropbox/T10/SBRI/_code/video_edits/3rd person present tense (303)/xfaded_final.mp4"


	`ffmpeg -i '#{audio}' -i '#{video}' -y '#{final}' -loglevel quiet` 
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