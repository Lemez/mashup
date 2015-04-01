

def make_new_video downloading=false
		# get the info from the named csv and create Sentences and Videos
	# get_files_from_specific_rule ARGV[0] #returns Sentence objects with video_ids

	get_files_from_db_specific_csv ARGV[0] #returns Sentence objects with video_ids

	create_and_match_saved_videos

	if DOWNLOADING && @number_of_relevant_videos_in_db <5
		do_downloading 
		reformat_videos_if_required
		create_and_match_saved_videos #run it again to update the list of videos
	end

		# get the sentences and timings from the sentences that have videos with saved files
	# get_sentences_with_saved_videos

		# get sentences with unique keywords / # choose_sentences
	@sentences_to_extract = Video.all.is_saved.flat_map(&:sentences).uniq{|s| s.keyword.downcase}.shuffle

	p @sentences_to_extract.count

		# create snippets from those sentences and save their locations and rule numbers
	create_snippets_from_sentences

		#print out snippets created, file, duration and lyric data
	show_current_snippets

		# normalize audio with fades
	normalize_audio

		#create srt file from snippets
	create_srt_from_snippets

		#create a text file and intermediate files from snippets
	create_snippets_text_file 

		# create intermediate files together
	create_intermediate_files_from_snippets

						## NO XFADES
		# glue intermediate video files and normalized audio together
	@@xfade = false 
	glue_intermediate_files_and_normal_audio

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

	add_subs


end

def do_downloading
	p "*********"
	p "do_downloading"
	p "*********"


		# create array of videos still needing to be downloaded, where location = ''
	@list_to_dl = create_list_of_videos_to_download

	p @list_to_dl

		# try to download those videos (currently some issues here on the plugins end)
	download_undownloaded_vids @list_to_dl 
end

def create_and_match_saved_videos
		# get the info from the saved videos folder and create SavedVideos
	get_all_titles_from_dir

		# match videos on csv with saved videos on hard drive
	match_videos_with_saved_videos
end


def reformat_videos_if_required
	format_downloaded_video_filenames
	check_for_webm_videos @playlist_name
end

def add_subs
		# add SRT file to final output file
		# test_srt
 	add_srt_to_final_mp4

 	# srt_to_ass
 	# add_subs_ass_to_final_mp4
end
