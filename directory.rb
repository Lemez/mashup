def make_dir_if_none (dir,name)

	d = "#{dir}/#{name}"
	dir_exists = Dir.exists?(d) 

	unless dir_exists
		p "making dir #{name}"
		FileUtils::mkdir_p d	
	else
		p "dir #{d} exists"
	end
	# FileUtils::mkdir_p 'foo/bar'
end

def get_all_titles_from_dir 
	p "*********"
	p "get_all_titles_from_dir"
	p "*********"

	Dir.glob("#{@videodir}/*.mp4").each do |item|
		size = File.size(item)
		name,extension = get_file_attributes item
		artist,title = name.split(" ~ ")
		@saved_video = SavedVideo.where(:filename => name).first_or_create
		@saved_video.extension = extension
		@saved_video.artist = artist
		@saved_video.title = title
		@saved_video.location = item
		@saved_video.save!

		# current_vids = all_currently_saved_videos.map{|e| e[0]}

		# unless current_vids.include?(newname) or size==0 
		# 	p "#{newname} in current directory"
		# 	all_currently_saved_videos << [newname,size,item] 
		# end

	end
	# p all_currently_saved_videos
	# return all_currently_saved_videos
end

def get_file_attributes item
	extension = File.extname(item)
	name_with_ext = File.basename(item)
	name = name_with_ext[0...name_with_ext.index(extension)]

	# newname = get_clean_name_alphanum(oldname)
	# rootpath = item[0..item.rindex('/')]

	return name,extension
end

def make_video_names_identifiable directory
	Dir.glob("#{directory}/*").each do |item|
		name,extension = get_file_attributes item

		csv_name = get_best_match @data_array, name.downcase
		# p "Changing filename from #{name} to #{csv_name}"
		
		# File.rename(rootpath+name, rootpath+csv_name+extension) #if name != csv_name+extension
	end
end


#clean up video names
def clean_up_video_names (directory)

	Dir.glob("#{directory}/*").each do |item|
		rootpath,newname,name,extension = get_file_attributes item
		File.rename(rootpath+name, rootpath+newname+extension) if name != newname
		# p newname
	end
end
