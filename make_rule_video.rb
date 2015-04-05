

# # usage: ruby make_rule_video.rb '3rd person present tense (303).csv'
# # usage: ruby make_rule_video.rb 'double_cons_before_ing_ed_er.csv' true 'maria'
# # usage: ruby make_rule_video.rb 'double_cons.csv' false 

raise "Please specify a local csv file, eg >> $ ruby make_rule_video.rb '3rd person present tense (303).csv' " if ARGV[0].nil?
raise "Please specify true or false for DOWNLOADING " if ARGV[1].nil?

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
# require 'active_record'
# require 'mysql2'
require_relative './environment.rb'

ViddlRb.io = $stdout

# ###### variables #########################

@playlist_name = ARGV[0][0...ARGV[0].rindex(".")] unless ARGV[0].nil?
PLAYLISTNAME = @playlist_name unless ARGV[0].nil?
DOWNLOADING = ARGV[1] unless ARGV[1].nil?

@csvdir = Dir.pwd + '/csv/nodes_final' 
@videodir = Dir.pwd + '/videos'
@editsdir = Dir.pwd + '/video_edits'
@subsdir = Dir.pwd + '/subs'
@finaldir = Dir.pwd + '/videos_final'
@imgdir = Dir.pwd + '/images'
@fontdir = '/Library/Fonts'
@testdir = Dir.pwd + '/_test'
BLACK_PIC = "#{@imgdir}/black.png"

EXCLUDED = ["believer"]
MIN_DUR = 5000
MAX_DUR = 10000

COMPLETED = Dir.glob("./videos_final/*").map{|f| File.basename(f)}
p COMPLETED

######## CONVERT CSV TO NODES #######
# db_files_to_csv
# get_files_from_db_csv
# query_saved_videos_per_node true #ARGV - destroy all Sentence records each time

### IMAGES PREPEND WORKING AS TEST
make_image
add_logo
turn_img_to_video
add_img_video_and_pic_video


#######  PROGRAMME CODE ######
# make_new_video downloading=DOWNLOADING
# create_mashups_with_enough_videos

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


