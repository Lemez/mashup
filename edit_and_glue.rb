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