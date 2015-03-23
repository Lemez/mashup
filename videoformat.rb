# Change any webm to mp4
def check_for_webm_videos (directory)

		p "check_for_webm_videos"

	Dir.glob("#{@videodir}/*.webm").each do |item|

		item = "'" + item + "'"
		r_item = item[0..item.rindex('/')] +item[item.rindex('/')+1..-7]

		p "item: #{item}"
		p "r_item: #{r_item}"

		webmtomp4 = "ffmpeg -fflags +genpts -i #{item} -r 24 #{r_item}.mp4'" 
		system (webmtomp4)

	end
end

#reduce video size
def reduce_video_size file
	`ffmpeg -i #{file} -s 640x480 -b 512k -vcodec mpeg1video -acodec copy`
end
