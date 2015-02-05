# def make_dir_if_none (dir,name)

# 	d = "#{dir}#{name}"
# 	dir_exists = Dir.exists?(d) 

# 	unless dir_exists
# 		p "making dir #{name}"
# 		FileUtils::mkdir_p d	
# 	else
# 		p "dir #{name} exists"
# 	end
# 	# FileUtils::mkdir_p 'foo/bar'
# end

def get_all_titles_from_dir dir
	p dir
	all_currently_saved_videos = []

	Dir.glob("#{videodir}/*.mp4").each do |item|
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

def get_file_attributes item
	extension = File.extname(item)
	name = File.basename(item)
	oldname = name[0...name.index(extension)]
	newname = get_clean_name_alphanum(oldname)
	rootpath = item[0..item.rindex('/')]

	return rootpath,newname,name,extension
end

def make_video_names_identifiable directory
	Dir.glob("#{directory}/*").each do |item|
		rootpath,newname,name,extension = get_file_attributes item

		csv_name = get_best_match @data_array, newname.downcase
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
