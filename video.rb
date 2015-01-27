class Video
	def initialize(youtubeid, title,artist='')  
	    # Instance variables  
	    @id = youtubeid  
	    @title = title
	    @artist = artist
  	end

  	def self.id
  		@id
  	end

  	def self.title
  		@title
  	end

  	def self.artist
  		@artist
  	end

  	def self.all
        ObjectSpace.each_object(self).to_a
    end
end
