
def match_videos_with_saved_videos

	Video.all.each do |video|

		 @assumed_filename = "#{video.artist} ~ #{video.title}";
						
		SavedVideo.all.each do |sv|
			 @f = ''
			 @f = sv.filename
			if @f==@assumed_filename
				video.saved = true
				video.location = "#{@f}#{sv.extension}"
				video.save!
			end
		end
	end
end

def create_list_of_videos_to_download
	Video.all.to_download
end