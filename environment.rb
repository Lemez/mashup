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
    end
 
    create_table :videos do |table|
        table.column :artist, :string
        table.column :title, :string
        table.column :yt_id, :string
        table.column :vimeo_id, :string
        table.column :offset, :integer
        table.column :saved, :boolean

    end

    create_table :sentences do |table|
        table.column :video_id, :integer
        table.column :full_sentence, :string
        table.column :sentence_gap, :string
        table.column :keyword, :string
        table.column :start_at, :integer
        table.column :end_at, :integer
        table.column :duration, :integer
    end
end

class Video < ActiveRecord::Base
    has_many :sentences 

    def self.id
    	@id
    end
end

class Sentence < ActiveRecord::Base
    belongs_to :video
end

class VideoSaved < ActiveRecord::Base

    def self.filename
    	@filename
    end

    def self.extension
    	@extension
    end
end
 

 

