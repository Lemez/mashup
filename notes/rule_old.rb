# def change_rule_to_completed
# 	return Rule.where('final_subs_logo != ?', params[:final_subs_logo]).count
# end

# NODE_DESCRIPTIONS = {
# 	"double_cons_before_ing_ed_er" => ["Words that \ndouble the last consonant before adding\n-ING, -ED, -ER", "forgetting"],
# 	"Feature_Has_Phoneme_Aw_Spelled_Ou" => ["Words where the OW sound \n is spelt OU", "about"],
# 	"Feature_Has_Phoneme_Aw_Spelled_Ow" => ["Words where the OW sound \n is spelt OW", "how"],
# 	"Feature_Has_Phoneme_Ay_Spelled_Ie" => ["Words where the IY sound \n is spelt IE", "tries"],
# 	"Feature_Has_Phoneme_Ay_Spelled_Y_Not_End" => ["Words where the IY sound \n in the middle of a word \nis spelt Y ", "myself"],
# 	"Feature_Has_Phoneme_Ey_Spelled_Eigh" => ["Words where the AY sound \n is spelt EIGH", "weigh"],
# 	"Feature_Has_Phoneme_Ey_Spelled_Ey" => ["Words where the AY sound \n is spelt EY", "grey"],
# 	"Feature_Has_Phoneme_F_Spelled_Ph" => ["Words where the F sound \n is spelt PH", "elephant"],
# 	"Feature_Has_Phoneme_Ih_Spelled_Ea" => ["Words where the EE sound \n is spelt EA", "dream"],
# 	"Feature_Has_Phoneme_Ih_Spelled_Ie" => ["Words where the EE sound \n is spelt IE", "piece"],
# 	"Feature_Has_Phoneme_Ih_Spelled_Y_Not_End" => ["Words where a middle I sound \n is spelt Y", "everything"],
# 	"Feature_Has_Phoneme_Iy_Spelled_Ee" => ["Words where the EE sound \n is spelt EE", "feel"],
# 	"Feature_Has_Phoneme_Iy_Spelled_Ey" => ["Words where the EE sound \n is spelt EY", "key"],
# 	"Feature_Has_Phoneme_Jh_Spelled_G" => ["Words where the hard J sound \n is spelt G", "change"],
# 	"Feature_Has_Phoneme_K_Spelled_Ch" => ["Words where the K sound \n is spelt CH", "school"],
# 	"Feature_Has_Phoneme_Ow_Spelled_Oe" => ["Words where the O sound \n is spelt OE", "goes"],
# 	"Feature_Has_Phoneme_Ow_Spelled_Ough" => ["Words where the O sound \n is spelt OUGH", "although"],
# 	"Feature_Has_Phoneme_Ow_Spelled_Ow" => ["Words where the O sound \n is spelt OW", "know"],
# 	"Feature_Has_Phoneme_S_Spelled_Sc" => ["Words where the S sound \n is spelt SC", "descend"],
# 	"Feature_Has_Phoneme_Sh_Spelled_Ch" => ["Words where the SH sound \n is spelt CH", "machine"],
# 	"Feature_Has_Phoneme_Uw_Spelled_Ew" => ["Words where the OO sound \n is spelt EW", "grew"],
# 	"Feature_Has_Phoneme_Uw_Spelled_Ough" => ["Words where the OO sound \n is spelt OUGH", "through"],
# 	"Feature_Has_Phoneme_Uw_Spelled_Ue" => ["Words where the OO sound \n is spelt UE", "blue"],
# 	"Feature_Has_Phoneme_W_Spelled_Wh" => ["Words where the W sound \n is spelt WH", "why"],
# 	"Feature_Has_Phoneme_Zh_Spelled_S" => ["Words where the soft J sound \n is spelt S", "treasure"],
# 	"Feature_Has_Phonemes_Ah0_L_Spelled_Al" => ["Words where the L sound \n is spelt AL", "special"],
# 	"Feature_Has_Phonemes_Ah0_L_Spelled_El" => ["Words where the L sound \n is spelt EL", "angel"],
# 	"Feature_Has_Phonemes_Ah0_L_Spelled_Le" => ["Words where the L sound \n is spelt LE", "castle"],
# 	"Feature_Has_Phonemes_S_Ah0_N_Spelled_Sten" => ["Words where the SN sound \n is spelt STEN", "listen"],
# 	"Feature_Has_Silent_U_In_Ui" => ["Words spelt UI\n with a silent U" , "build"],
# 	"Feature_Has_String_Cei" => ["Words where the SEE sound \n is spelt CEI", "ceiling"],
# 	"Feature_Has_String_Ie" => ["Words that have the letters \nIE", "believe"],
# 	"Feature_Has_String_Ight" =>["Words that have the letters \nIGHT", "night"],
# 	"Feature_Has_Suffix_Ch" => ["Words that have the suffix \n(or that end in) CH", "reach"],
# 	"Feature_Has_Suffix_Gue" => ["Words that have the suffix \n(or that end in) GUE", "tongue"],
# 	"Feature_Has_Suffix_Tch" => ["Words that have the suffix \n(or that end in) TCH", "catch"],
# 	"silent_cons" => ["Words that have a silent consonant \n", "knife"],
# 	"single_cons_before_ing_ed_er" => ["Words with just one consonant\n before -ING, -ED, -ER ", "happened"],
# 	"sound_s" => ["Words with the sound S", "chase"],
# 	"string_air" => ["Words where the AIR sound \n is spelt AIR", "hair"],
# 	"string_are" => ["Words where the AIR sound \n is spelt ARE", "careful"],
# 	"string_ear" => ["Words where the AIR sound \n is spelt EAR", "wear"],
# 	"string_ore" => ["Words with the sound OR", "record"],
# 	"string_ough" => ["Words that contain the letters UGH", "though"]

# }


# GAME_DESCRIPTIONS = {
# 	"sounds_ey_ay" => "Vowel Sounds 2",
# 	"sounds_ih_iy" => "Vowel Sounds 3",
# 	"sounds_ow_aw_uw" => "Vowel Sounds 1",
# 	"sounds_s_ch_jh_zh_w_f" => "Consonants Sounds 1",
# 	"silent_cons_and_foreign" => "Silent Letters And Words With A Foreign Origin",
# 	"double_cons" => "Double and Single Consonants",
# 	"strings" => "Common Letter Combinations"

# }