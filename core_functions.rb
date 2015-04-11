def create_mashups_with_enough_videos
	# rebuild current list of completed final videos
	# read csv 

	calculate_completed_videos

	options = {:headers => true, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	reading_file = "./csv/videos/hits_medleys_FINAL.csv"

	@csv_count = 1

	CSV.foreach(reading_file,options) do |row|

		next if row[6] == true || row[6] == "true" # if completed already

		# execute each one
		if row[4].to_i > 4 

			 # only process first video as a check
			return if @csv_count > 1

			@playlist_name = row[0]
			@playlist_csv = "#{@playlist_name}.csv"
			full_file = "#{@csvdir}/#{@playlist_name}"
			p "EXECUTING #{@playlist_name} with row[6] = #{row[6]}"

			make_new_video @playlist_name, downloading=false

			@csv_count += 1
		end
	end
end


def make_new_video playlist, downloading=false
	p "****** make_new_video #{playlist}"
	DIRECTORIES.each{|d| make_dir_if_none d,@playlist_name}

	get_files_from_db_specific_csv @playlist_csv #returns Sentence objects with video_ids

	number_of_relevant_videos_in_db = create_and_match_saved_videos

	if downloading && number_of_relevant_videos_in_db <5
		do_downloading; reformat_videos_if_required; create_and_match_saved_videos #run it again to update the list of videos
	end

	@sentences_to_extract = choose_sentences_from_saved_videos

	add_titles_to_video
	# create_snippets_from_sentences	# create snippets from those sentences, save their locations & rule numbers
	# show_current_snippets	#print out snippets created, file, duration and lyric data
	# # check_snips
	# normalize_audio	# normalize audio with/without fades
	# # check_snips
	# create_srt_from_snippets	#create srt file from snippets
	# # check_snips
	# create_snippets_text_file 	#create a text file and intermediate files from snippets
	# # check_snips
	# create_intermediate_files_from_snippets	# create intermediate files together

	# # check_snips

	# @@xfade = false    ## NO XFADES
	# glue_intermediate_files_and_normal_audio	# glue intermediate video files and normalized audio together
	# add_subs	# add subtitles with highlighted keyword
	
	# # add image
	# make_image
	# add_logo
	# turn_img_to_video
	# add_img_video_and_pic_video


	# # ÷ Xfade options see below

end

def do_downloading
	p "*********";p "do_downloading";p "*********"

		# create array of videos still needing to be downloaded, where location = ''
	@list_to_dl = create_list_of_videos_to_download

		# try to download those videos (currently some issues here on the plugins end)
	download_undownloaded_vids @list_to_dl 
end


def reformat_videos_if_required
	format_downloaded_video_filenames
	check_for_webm_videos @playlist_name
end

def add_subs  # add SRT file to final output file
		
 	add_srt_to_final_mp4
 	# test_srt  # srt_to_ass # add_subs_ass_to_final_mp4
end

# ÷ OLD FUNCTIONS
		
	# get_files_from_specific_rule ARGV[0] #returns Sentence objects with video_ids # get the info from the named csv and create Sentences and videos
	# get_sentences_with_saved_videos # get the sentences and timings from the sentences that have videos with saved files
 	# choose_sentences_from_saved_videos # get sentences with unique keywords /  


# ÷ OLD XFADE FUNCTIONS

	# 					## XFADES
	# # @@xfade = true 

	# 					# create normalized snippets.ts
	# 					# create_normalized_snippets

	# 					# crossfade snippets that already have normalised audio
	# 					# crossfade_snippets_with_normal_audio_together

	# 						# trim audio to adapt to crossfades
	# 					# trim_audio

	# 					#create silence
	# 					# create_silence

	# 						# crossfade intermediate files
	# 					# crossfade_snippets_to_xfaded_ts
	# 					# crossfade_snippets_to_ts_and_audio_to_wav

	# 						# make ts output into mp4
	# 					# process_xfaded_ts_to_mp4

	# 						# glue crossfaded video files and normalized audio together
	# 					# glue_crossfaded_video_and_normal_audio

	# 					# test gluing
	# 					# test_gluing

	#					# add_subs


