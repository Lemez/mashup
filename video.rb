# class Video < ActiveRecord::Base
# 	def initialize(youtubeid,artist,title, saved=false, offset=0)  
# 	    # Instance variables  
# 	    @yt_id = youtubeid  
# 	    @title = title
# 	    @artist = artist
#       @saved = saved
#       @offset = offset
#       @filename = "#{artist} ~ #{title}"
#   	end

#   	def self.id
#   		@id
#   	end

#   	def self.title
#   		@title
#   	end

#   	def self.artist
#   		@artist
#   	end

#     def self.saved?
#       @saved
#     end

#     def self.offset
#       @offset
#     end

#      def self.filename
#       @filename
#     end

#   	def self.all
#         ObjectSpace.each_object(self).to_a
#     end
# end
