def get_clean_name (s)
	return s.gsub(/[^0-9a-z. ]/i, '')
end

def get_clean_name_alphanum (s)
	return s.gsub(/[^0-9a-z ~]/i, '').gsub("  "," ")
end

def convert_to_time_format(s,d)
	# ms to 00:02:00

	ss, ms = s.to_i.divmod(1000)         
	mm, ss = ss.divmod(60)            
	hh, mm = mm.divmod(60)          
	start =  format("%02d:%02d:%02d", hh, mm, ss)
	dur = format("00:00:%02d", d.to_i/1000)

	return start,dur 
end