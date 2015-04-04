def format_downloaded_video_filenames
	p "*******"
	p "format_downloaded_video_filenames"
	p "*******"
	

	Dir.glob("#{@videodir}/*").each do |vid|


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

	p"********"
	p "match_videos_with_saved_videos"
	p"********"

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

				p "#{@assumed_filename} found"
			end
		end
	end

	number_of_relevant_videos_in_db

end

def create_list_of_videos_to_download
	Video.all.where("location=''")
end