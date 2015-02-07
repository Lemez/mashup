

# usage: ruby make_rule_video.rb '3rd person present tense (303).csv'
raise "Please specify a local csv file, eg >> $ ruby make_rule_video.rb '3rd person present tense (303).csv' " if ARGV[0].nil?

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




###### variables #########################
@videodir = Dir.pwd + '/videos'

@playlist_name = ARGV[0][0...ARGV[0].index(".")]
@mydir = "#{@dir}#{@playlist_name}"

# @time = Time.now.usec.to_s
#######

# get the info from the named csv and create Sentences and Videos
get_files_from_specific_rule ARGV[0] #returns Sentence objects with video_ids

# get the info from the saved videos folder and create SavedVideos
get_all_titles_from_dir

Sentence.all.each {|v| v_id = v.video_id; video = Video.find_by("id=#{v_id}"); p "#{v.full_sentence} is from #{video.title} by #{video.artist}"}
# p "getting ids"
# @rule_video_ids = @sentence_data.each.map{|e| e['video_id']}
# @rule_titles = @sentence_data.each.map{|e| e['title']}
# @rule_artists = @sentence_data.each.map{|e| e['artist']}
# @rule_starttimes = @sentence_data.each.map{|e| e['start']}
# @rule_durations = @sentence_data.each.map{|e| e['dur']}

# map to hashes

# @data_hash = map_details_to_hashes @sentence_data
# @data_array = @data_hash["data"]

# p "logging in"
# @client,@user = yt_login

# p "checking if pl exists"
# pl_exists,pl_id = check_if_playlist_exists(@playlist_name)

# p "seeing what's on the playlist"
# # # #see what is on the playlist
# get_vids_on_playlist (@playlist_name)

# p "adding to pl"
# @new_pl_id = add_to_playlist_if_not_already_there @playlist_name, @rule_video_ids, pl_exists, pl_id, @rule_titles

# p "making dir if none"
# make_dir_if_none(@dir,@playlist_name)

# get_all_titles_from_dir @mydir

# p "download_all_videos_from_pl"
# download_all_videos_from_pl @new_pl_id, @playlist_name

# p "clean up video names"
# clean_up_video_names (@mydir)

# p "checking for webm"
# check_for_webm_videos (@mydir)

# filename = add_files_to_text_doc (name,directory)
# make_intermediate_files(filename,directory,name)
# work_the_av_magic
# vimeo_login
# try_vimeo "American Authors - Believer",@mydir,"vimeo"

# artist_match_results = match_best "Jessie J Price Tag", @rule_artists
# @song_artist = artist_match_results[0]
# remaining_words = artist_match_results[1]
# song_match_results = match_best remaining_words, @rule_titles
# @song_title = song_match_results[0]
	
# p @song_artist
# p @song_title

# get_vimeo_manually @song_artist,@song_title,@mydir,"vimeo"

# download_a_video 82217180,@mydir,"vimeo"

#### TO DOOOO
# MAKE SURE THAT FILES ARE SAVED IN A FORMAT WE RECOGNIZE ON LOCAL MACHINE
# ie rename the videos to match our artist and title name

# make_video_names_identifiable @videodir

# @videos_saved.each {|v| p v}

#  @data_array :))


# p"editing videos"
#this needs to be a loop depending on which videos got dl


# edit_videos (@mydir,@rule_starttimes,@rule_durations)


