# require 'rubygems'
require 'active_record'
require 'yaml'

Dir["./*.rb"].each {|file| next if file == "./make_rule_video.rb";
                            next if file == "./make_rule_from_db.rb";
                            require file }

# Dir["./methods/*.rb"].each(&method(:require_relative)) put all files into methods (but then clean up the direcgtory issues)

ActiveRecord::Base.logger = Logger.new(STDERR)
# ActiveRecord::Base.colorize_logging = false

# turn off noisy logging
ActiveRecord::Base.logger.level = 1
 
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
        table.column :duration, :float
        table.column :rule_name, :string
        table.column :adult, :boolean
        table.column :l_node, :string
        table.column :l_group, :string
        table.column :l_game, :string

    end

    create_table :snippets do |table|
        table.column :video_id, :integer
        table.column :sentence_id, :string
        table.column :sentence_duration, :float
        table.column :clip_duration, :float
        table.column :rule_name, :string
        table.column :full_video_location, :string
        table.column :location, :string
        table.column :temp_file_location, :string
        table.column :normal_audio_file_location, :string
        table.column :normal_audio_duration, :float
        table.column :xfaded_audio_file_location, :string
        table.column :trimmed_audio, :string
        table.column :trimmed_file_duration, :float
        table.column :normal_snippet_file_location, :string

    end

      create_table :rules do |table|
        table.column :rule_name, :string
        table.column :game_id, :integer
        table.column :xfade_audio, :string
        table.column :xfade_ts, :string
        table.column :xfade_mp4, :string
        table.column :normal_audio, :string
        table.column :final_mp4, :string
        table.column :normal_xfaded_ts, :string
       
    end

    create_table :games do |table|
        table.column :group_id, :integer
        table.column :game_name, :string
    end

    create_table :groups do |table|
        table.column :node_id, :integer
        table.column :group_name, :string
    end

    create_table :nodes do |table|
        table.column :node_name, :string
    end
end

class Rule < ActiveRecord::Base
    has_many :videos

    def self.normal_xfaded_ts
        @normal_xfaded_ts
    end

    def self.game_id
        @game_id
    end
    
    def self.rule_name
        @rule_name
    end

    def self.xfade_ts
        @xfade_ts
    end

    def self.xfade_mp4
        @xfade_mp4
    end

    def self.xfade_audio
        @xfade_audio
    end

    def self.normal_audio
        @normal_audio
    end

    def self.final_mp4
        @final_mp4
    end
end

class Video < ActiveRecord::Base
    belongs_to :rule
    has_many :sentences
    has_many :snippets, through: :sentences  
    after_initialize :init

    def init
    	self.location  ||= ''
    	self.saved  ||= false
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

    # def self.saved
    # 	@saved
    # end

    def self.is_saved
    	self.where("saved= ?",true)
    end

 #    def self.all_sentences
 #  		Sentence.obeys_rule
	# end
end

class Sentence < ActiveRecord::Base
    belongs_to :rule
    has_one :snippet

    scope :obeys_rule,  ->  { where(rule_name: '"#{PLAYLISTNAME}"') }

    def self.video_id
    	@video_id
    end

    def self.clean
    	!@adult
    end

    def self.l_node
    	@l_node
    end

     def self.l_group
        @l_group
    end

     def self.l_game
        @l_game
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
	belongs_to :sentence

	def self.video_id
		@video_id
	end

	def self.location
		@location
	end

	def self.full_video_location
		@full_video_location
	end
	
	def self.sentence_id
		@sentence_id
	end
	
	def self.duration
		@duration
	end

	def self.rule_name
		@rule_name
	end

	def self.temp_file_location
		@temp_file_location
	end

	def self.normal_audio_file_location
		@normal_audio_file_location
	end

    def self.trimmed_audio
        @trimmed_audio
    end

    def self.trimmed_file_duration
        @trimmed_file_duration
    end

    def self.normal_snippet_file_location
        @normal_snippet_file_location
    end
    
    def self.normal_audio_duration
        @normal_audio_duration
    end

    def self.xfaded_audio_file_location
        @xfaded_audio_file_location
    end
end

 

 

