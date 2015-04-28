# usage: 
#ruby make_rule_video.rb DOWNLOADING=false QUERY=false CREATE=true GAME=false

# new Trollop usage
# ruby make_rule_video --features --clips 2

require 'streamio-ffmpeg'
require 'viddl-rb'
require 'open-uri'
require 'csv'
require 'youtube_it'
require 'open3'
require 'pp'
require 'awesome_print'
require 'fileutils'
require 'vimeo'
require 'httparty'
require 'cgi'
require 'watir-webdriver'
require 'nokogiri'
require 'fuzzystringmatch'
require 'rake'
require 'active_support/all'
# require 'mysql2'
require_relative './environment.rb'

require 'trollop'
@command_arguments = Trollop::options do
  opt :downloading, "Turn on downloading"           # flag --downloading, default false
  opt :features, "Turn on feature creation" 		# flag --features, default false
  opt :games, "Turn on game creation" 				# flag --games, default false
  opt :query, "Turn on db video query before exec" 	# flag --query, default false
  opt :single, "Just one video for testing" 		# flag --single, default false
  opt :clips, "Number of Clips", :default => 3  	# integer --clips <i>, default to 3
  opt :card, "Intro Card Length", :default => 3  	# integer --card <i>, default to 3
  # opt :name, "Monkey name", :type => :string      # string --name <s>, default nil
end

ViddlRb.io = $stdout

# ###### variables #########################

DOWNLOADING = @command_arguments[:downloading]
LIMIT = @command_arguments[:clips]
CREATE = @command_arguments[:features]
QUERY = @command_arguments[:query]
GAME = @command_arguments[:games]
CARD_LENGTH = @command_arguments[:card]
SINGLE = @command_arguments[:single]



# DOWNLOADING = ARGV[0].split("=")[-1].to_bool
# QUERY = ARGV[1].split("=")[-1].to_bool
# CREATE = ARGV[2].split("=")[-1].to_bool
# GAME = ARGV[3].split("=")[-1].to_bool
# LIMIT = 5
# CARD_LENGTH = 4

@csvdir = Dir.pwd + '/csv/nodes_final' 
@videodir = Dir.pwd + '/videos'
@editsdir = Dir.pwd + '/video_edits'
@subsdir = Dir.pwd + '/subs'
@finaldir = Dir.pwd + '/videos_final'
@gamesdir = Dir.pwd + '/videos_final_games'
@imgdir = Dir.pwd + '/images'
@fontdir = '/Library/Fonts'
@testdir = Dir.pwd + '/_test'
BLACK_PIC = "#{@imgdir}/black.png"
DIRECTORIES = [@imgdir,@finaldir,@subsdir]
RUDE = ["damn", "shit", "sex"]

EXCLUDED = []
MIN_DUR = 3500
MAX_DUR = 15000

@done = 0

OFFSET = {
	"2pac ~ california love.mp4" => 78000,
	"5 cent ~ in da club.mp4" => 32500,
	"5 seconds of summer ~ dont stop.mp4" => 0,
	"american authors ~ believer.mp4" => 7700,
	"arcade fire ~ reflektor.mp4" => 5000,
	"ariana grande ~ problem.mp4" => 750,
	"avril lavigne ~ rock n roll.mp4" => 35000,
	"avril lavigne ~ when youre gone.mp4" => 0,
	"birdy ~ not about angels.mp4" => 0,
	"bruno mars ~ young girls.mp4" => 5000,
	"bruno mars ~ just the way you are.mp4" => 0,
	"charli xcx ~ boom clap.mp4" => -500,
	"christina perri ~ human.mp4" => -500, 
	"destinys child ~ survivor.mp4" => 4000,
	"ed sheeran ~ dont.mp4" => 28000,
	"ellie goulding ~ anything could happen.mp4" => 17000,
	"eminem ~ the monster.mp4" => 62000,
	"jonas brothers ~ play my music.mp4" => 17500,
	"lorde ~ royals.mp4" => 8400,
	"marina and the diamonds ~ primadonna.mp4" => 5000,
	"michael jackson ~ billie jean.mp4" => 3500,
	"michael jackson ~ man in the mirror.mp4" => 8000,
	"ne yo ~ one in a million.mp4" => 26000,
	"nico and vinz ~ am i wrong.mp4" => 0,
	"one direction ~ story of my life.mp4" => 0,
	"taylor swift ~ white horse.mp4" => 12000,
	"taylor swift ~ we are never ever getting back together.mp4" => -4500,
	"the vamps ~ wild heart.mp4" => 1500
}

INTERRUPTIONS = {
	"ed sheeran ~ dont.mp4" => [112000,33000]

}

# @playlist_name = ARGV[0][0...ARGV[0].rindex(".")] unless ARGV[0].nil?

######## CONVERT CSV TO NODES #######
# db_files_to_csv
 # get_files_from_db_csv
# get_hits_per_video

#######  PROGRAMME CODE ######
# make_new_video downloading=DOWNLOADING
# calculate_completed_videos

# update list of completed videos
query_saved_videos_per_node true if QUERY #ARGV - destroy all Sentence records each time
create_mashups_with_enough_videos if CREATE
make_games_from_features if GAME

### IMAGES PREPEND WORKING AS TEST

# download_critical_vids

### TESTING #####
# rename_currently_working



	



#############################
# NB BEST WAY TO MAKE SUBS HERE "http://ffmpeg.org/ffmpeg-filters.html#drawtext-1"

# # http://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/subtitle_options
# # To make the subtitles stream from sub.srt appear in transparent green DejaVu Serif, use:

# # subtitles=sub.srt:force_style='FontName=DejaVu Serif,PrimaryColour=&HAA00FF00'
# # How to speed up and slow down audio / video !!!
# # https://trac.ffmpeg.org/wiki/How%20to%20speed%20up%20/%20slow%20down%20a%20video
#############################

# # p "getting ids"
# # @rule_video_ids = @sentence_data.each.map{|e| e['video_id']}
# # @rule_titles = @sentence_data.each.map{|e| e['title']}
# # @rule_artists = @sentence_data.each.map{|e| e['artist']}
# # @rule_starttimes = @sentence_data.each.map{|e| e['start']}
# # @rule_durations = @sentence_data.each.map{|e| e['dur']}

# # map to hashes

# # @data_hash = map_details_to_hashes @sentence_data
# # @data_array = @data_hash["data"]

# # p "logging in"
# # @client,@user = yt_login

# # p "checking if pl exists"
# # pl_exists,pl_id = check_if_playlist_exists(@playlist_name)

# # p "seeing what's on the playlist"
# # # # #see what is on the playlist
# # get_vids_on_playlist (@playlist_name)

# # p "adding to pl"
# # @new_pl_id = add_to_playlist_if_not_already_there @playlist_name, @rule_video_ids, pl_exists, pl_id, @rule_titles

# # p "making dir if none"
# # make_dir_if_none(@dir,@playlist_name)

# # get_all_titles_from_dir @mydir

# # p "download_all_videos_from_pl"
# # download_all_videos_from_pl @new_pl_id, @playlist_name

# # p "clean up video names" # not working Feb 15
# # clean_up_video_names (@mydir)

# # p "checking for webm"
# # check_for_webm_videos (@mydir)

# # filename = add_files_to_text_doc (name,directory)
# # make_intermediate_files(filename,directory,name)
# # work_the_av_magic
# # vimeo_login
# # try_vimeo "American Authors - Believer",@mydir,"vimeo"

# # artist_match_results = match_best "Jessie J Price Tag", @rule_artists
# # @song_artist = artist_match_results[0]
# # remaining_words = artist_match_results[1]
# # song_match_results = match_best remaining_words, @rule_titles
# # @song_title = song_match_results[0]
	
# # p @song_artist
# # p @song_title

# # get_vimeo_manually @song_artist,@song_title,@mydir,"vimeo"

# # download_a_video 82217180,@mydir,"vimeo"

# #### TO DOOOO
# # MAKE SURE THAT FILES ARE SAVED IN A FORMAT WE RECOGNIZE ON LOCAL MACHINE
# # ie rename the videos to match our artist and title name

# # make_video_names_identifiable @videodir

# # @videos_saved.each {|v| p v}

# #  @data_array :))


# # p"editing videos"
# #this needs to be a loop depending on which videos got dl


# # edit_videos (@mydir,@rule_starttimes,@rule_durations)


