def get_clean_name (s)
	return s.gsub(/[^0-9a-z. ]/i, '')
end

def get_clean_name_alphanum (s)
	return s.gsub(/[^0-9a-z ~]/i, '').gsub("  "," ")
end

def convert_to_start_time(s)
	# ms to 00:02:00

	ss, ms = s.to_i.divmod(1000)         
	mm, ss = ss.divmod(60)            
	hh, mm = mm.divmod(60)          
	start =  format("%02d:%02d:%02d", hh, mm, ss)
	
	return start 
end

def convert_to_duration(d)
	whole_units = d.to_i/1000
	if whole_units < 60
		return format("00:00:%02d",whole_units ) 
	else
		# return sprintf("00:%02d:%02d",whole_units/60, whole_units%60 ) 
		raise "Houston, we have a sentence duration problem from the csv"
	end
end

def convert_to_seconds_and_ms(ms)
	ms=ms/1.0
	return ms/1000
		# 	‘23.189’
		# 23.189 seconds
end

def convert_ms_to_srt(s)
	ss, ms = s.to_i.divmod(1000)         
	mm, ss = ss.divmod(60)            
	      
	time = format("00:%02d:%02d,%03d", mm, ss,ms)
	
	return time
		# 	‘23.189’
		# 23.189 seconds
end