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

