# usage: ruby ../make_rule_video.rb '3rd person present tense (303).csv'

require_relative "./extract.rb"
require_relative './sentence.rb'

raise "Please specify a local csv file, eg >> $ ruby ../make_rule_video.rb '3rd person present tense (303).csv' " if ARGV[0].nil?

###### functions ######

def get_files_from_specific_rule rule
	list = CSV.read("../csv/#{rule}", {:headers => true})

	@sentence_data = []
	@last = ''

	list.each do |line|
		s = {}
		@line_id = line[0] unless line[0].nil?
		@line_artist = line[1].split(/ |\_/).map(&:capitalize).join(" ") unless line[1].nil?
		@line_title = line[2] unless line[2].nil?
		keyword = line[3]
		sentence_w_gap = line[5]
		time_at = line[6]
		time_until = line[7]
		dur_ms = line[8]

		sentence_no_gap = ''
		sentence_words = []

		words = sentence_w_gap.split(" ")
		words.each do |w|
			w = keyword if w=="__"
			sentence_words << w
		end

		sentence_no_gap = sentence_words.join(" ")

		s['video_id'],s['artist'], s['title'],s['keyword'],s['sentence_w_gap'],s['full_sentence'],s['start'],s['end'],s['dur'] = @line_id,@line_artist,@line_title,keyword, sentence_w_gap, sentence_no_gap, time_at,time_until,dur_ms
		
		@sentence_data << s unless @last['video_id']==s['video_id']
		@last = s
	end
end


###### code ######
@playlist_name = ARGV[0]
@mydir = "#{@dir}#{@playlist_name}"

# # get the info from the named csv
p "getting csv data"
get_files_from_specific_rule ARGV[0] #returns Sentence objects with video_ids

p "getting ids"
rule_video_ids = @sentence_data.each.map{|e| e['video_id']}
rule_titles = @sentence_data.each.map{|e| e['title']}
rule_starttimes = @sentence_data.each.map{|e| e['start']}
rule_durations = @sentence_data.each.map{|e| e['dur']}

p "logging in"
@client,@user = yt_login

p "checking if pl exists"
pl_exists,pl_id = check_if_playlist_exists(@playlist_name)

p "seeing what's on the playlist"
# # #see what is on the playlist
get_vids_on_playlist (@playlist_name)

p "adding to pl"
@new_pl_id = add_to_playlist_if_not_already_there @playlist_name, rule_video_ids, pl_exists, pl_id, rule_titles

p "making dir if none"
make_dir_if_none(@dir,@playlist_name)

get_all_titles_from_dir @mydir

p "download_all_videos_from_pl"
download_all_videos_from_pl @new_pl_id, @playlist_name

p "clean up video names"
clean_up_video_names (@mydir)

p "checking for webm"
check_for_webm_videos (@mydir)

# p"editing videos"
#this needs to be a loop depending on which videos got dl
# edit_videos (@mydir,rule_starttimes,rule_durations)

# filename = add_files_to_text_doc (name,directory)
# make_intermediate_files(filename,directory,name)
# work_the_av_magic
# vimeo_login
# try_vimeo "Passenger - Let Her Go [Official Video]",@mydir,"vimeo"


