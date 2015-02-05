def vimeo_login
	@base = Vimeo::Advanced::Base.new("#{VIMEO_IDENTIFIER}", "#{VIMEO_SECRET}")	
end

def yt_login

	user = "RQVtG1GPjsa0YHOmGyiiqQ" #Engage channel
	client = YouTubeIt::Client.new(:username => YT_USER, :password =>  YT_PW, :dev_key => YT_DEV_KEY)

	return client, user
end