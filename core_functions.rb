
def create_mashups_with_enough_videos
	p "* create_mashups_with_enough_videos *"
	# rebuild current list of completed final videos
	# read csv 

	options = {:headers => false, :encoding => 'windows-1251:utf-8', :col_sep => ";"}
	reading_file = "./csv/videos/hits_medleys_FINAL.csv"

	@csv_count = 1
	incomplete = []	

	CSV.foreach(reading_file,options) do |row|

		calculate_completed_videos
		@number_of_clips = LIMIT


		# p  "#{row[0]}: #{row[5].to_i} hits"# if row[6].to_bool == false 

		# execute each one
		# p @completed
		@playlist_name = row[0]

		if row[5].to_i >= @number_of_clips && !@completed.include?(row[0]) && row[5].to_i>0
	
			@playlist_csv = "#{@playlist_name}.csv"
			full_file = "#{@csvdir}/#{@playlist_name}"
			p "EXECUTING #{@playlist_name} with row[6] = #{row[6]}"

			make_new_video @playlist_name, downloading=false

			@csv_count += 1
			return if SINGLE

		elsif !@completed.include?(row[0])
			p " #{@playlist_name} - #{@number_of_clips} clips reqd and #{row[5].to_i} hits"

			incomplete << row
		end

		
	end
	# p "Incomplete:"
	# incomplete.each{|i| p i}
end


def make_new_video playlist, downloading=false
	p "* make_new_video #{playlist} **"

	clean_up_records

	get_files_from_db_specific_csv @playlist_csv #returns Sentence objects with video_ids

	number_of_relevant_videos_in_db = create_and_match_saved_videos

	add_video_offset

	if DOWNLOADING #&& number_of_relevant_videos_in_db <5
		do_downloading; reformat_videos_if_required; create_and_match_saved_videos #run it again to update the list of videos
	end

	@all_sentences_to_extract = choose_sentences_from_saved_videos

	@pass = 0
	@number_of_clips.times do 
		"Processing #{@playlist_name} with #{@number_of_clips} clips"
		@sentences_to_extract = select_filter_sentences
		@not_enough_sentences = continue_or_stop
		break if @not_enough_sentences == false
		
		@unique_video = false if @pass==0
		@unique_keyword = false if @pass==1

		@pass+=1
	end

	return if @not_enough_sentences

	
	# p "?????????????? ??????????????"

	# while @not_enough_sentences

	# 	p "?????????????? ITERATING ??????????????"
	# 	iterate_over_sentence_filters
	# 	@not_enough_sentences = continue_or_stop

	# 	if @no_further_attempts
	# 		p "Only #{@sentences_to_extract.count.to_s} found for #{playlist} with #{@number_of_clips.to_s} required. "
	# 		p "Returning"
	# 		return
	# 		# clean_up_records
	# 		# @no_further_attempts = false
	# 		# @number_of_clips -= 1
	# 		# make_new_video @playlist_name, downloading=false
			
	# 	else 
	# 		p "Try #{@sentence_pass.to_s}: #{@sentences_to_extract.count.to_s} found, #{@number_of_clips.to_s} required for #{playlist}"

	# 	end

	# end
	
	return if @not_enough_sentences

	# refine_sentences_further if @sentences_to_extract.count > @number_of_clips
	
	# add_titles_to_video
	#check_snips
	create_snippets_from_sentences	# create snippets from those sentences, save their locations & rule numbers
	show_current_snippets	#print out snippets created, file, duration and lyric data
	normalize_audio	# normalize audio with/without fades
	# mp2_to_aac  #// NEW
	# add_normal_audio_back_to_snippet  #// NEW

	create_srt_from_snippets	#create srt file from snippets
	create_snippets_text_file 	#create a text file and intermediate files from snippets

	create_intermediate_files_from_snippets	# create intermediate files together

	# # glue_intermediate_files // NEW

	@@xfade = false    ## NO XFADES
	glue_intermediate_files_and_normal_audio	# glue intermediate video files and normalized audio together
	
	
	add_subs	# add subtitles with highlighted keyword
	
	create_silence #need to do this as card length can change

	make_image # add image
	add_logo
	turn_img_to_video
	add_silence_to_image_video
	add_img_video_and_pic_video

	@done =+1

	# # ÷ Xfade options see below

end

def clean_up_records
	p "* clean_up_records *"
	Sentence.destroy_all
	Snippet.destroy_all
	Video.destroy_all
	SavedVideo.destroy_all

end

def do_downloading
	p "* do_downloading *"

		# create array of videos still needing to be downloaded, where location = ''
	@list_to_dl = create_list_of_videos_to_download

		# try to download those videos (currently some issues here on the plugins end)
	download_undownloaded_vids @list_to_dl 
end

def add_video_offset
	p "* add_offset *"
	OFFSET.each_pair  do |k,v|
		video = Video.where("location='#{k}'").first_or_create
		video.offset = v
		# p "Offset #{v.to_s} added to #{k}" if video.save!
		video.save!
	end
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


