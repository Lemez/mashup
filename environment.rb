# require 'rubygems'
require 'active_record'
require 'yaml'

Dir["./*.rb"].each {|file| next if file == "./make_rule_video.rb"; require file }

# Dir["./methods/*.rb"].each(&method(:require_relative)) put all files into methods (but then clean up the direcgtory issues)

ActiveRecord::Base.logger = Logger.new(STDERR)
# ActiveRecord::Base.colorize_logging = false
 
ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3",
    :database  => ":memory:"
)
 
ActiveRecord::Schema.define do
    create_table :saved_videos do |table|
        table.column :filename, :string
        table.column :extension, :string
        table.column :location, :string
        table.column :artist, :string
        table.column :title, :string
    end
 
    create_table :videos do |table|
    	table.column :artist_original, :string
        table.column :artist, :string
        table.column :title_original, :string
        table.column :title, :string
        table.column :yt_id, :string
        table.column :vimeo_id, :string
        table.column :offset, :integer
        table.column :saved, :boolean
        table.column :location, :string

    end

    create_table :sentences do |table|
        table.column :video_id, :integer
        table.column :full_sentence, :string
        table.column :sentence_gap, :string
        table.column :keyword, :string
        table.column :start_at, :integer
        table.column :end_at, :integer
        table.column :duration, :integer
        table.column :rule_name, :string
    end

    create_table :snippets do |table|
        table.column :saved_video_id, :integer
        table.column :location, :string
        table.column :sentence_id, :string
        table.column :duration, :integer
    end
end

class Video < ActiveRecord::Base
    has_many :sentences 
    after_initialize :init

    def init
    	self.location  ||= ''
    end

    def self.id
    	@id
    end

    def self.artist
    	self.artist
    end

    def self.title
    	@title
    end

    def self.to_download
    	self.where("location=''")
    end

    def self.location
        @location
    end
end

class Sentence < ActiveRecord::Base
    belongs_to :video

    scope :obeys_rule,  ->  { where(rule_name: "#{PLAYLISTNAME}") }

    def self.video_id
    	@video_id
    end

    def self.rule_name
    	@rule_name
    end

    def self.full_sentence
    	@full_sentence
    end

    def self.sentence_gap
    	@sentence_gap
    end

    def self.keyword
    	@keyword
    end

    def self.start_at
    	@start_at
	end

    def self.end_at
    	@end_at
    end

    def self.duration
    	@duration
    end

end

class SavedVideo < ActiveRecord::Base

	has_many :snippets

    def self.filename
    	@filename
    end

    def self.extension
    	@extension
    end

    def self.id
    	@id
    end

    def self.artist
    	@artist
    end

    def self.title
    	@title
    end
end


class Snippet < ActiveRecord::Base
	belongs_to :saved_video

	def self.saved_video_id
		@saved_video_id
	end

	def self.location
		@location
	end
	
	def self.sentence_id
		@sentence_id
	end
	
	def self.duration
		@duration
	end
end

 

 

