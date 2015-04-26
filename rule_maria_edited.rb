def change_rule_to_completed
	return Rule.where('final_subs_logo != ?', params[:final_subs_logo]).count
end

NODE_DESCRIPTIONS = {
	"double_cons_before_ing_ed_er" => ["Words that \n double the consonant before \n adding -ING or -ED", "referred"],
	"Feature_Has_Phoneme_Aw_Spelled_Ou" => ["Words where the OW sound \n is spelt OU", "pound"],
	"Feature_Has_Phoneme_Aw_Spelled_Ow" => ["Words where the OW sound \n is spelt OW", "cow"],
	"Feature_Has_Phoneme_Ay_Spelled_Ie" => ["Words where the AY sound \n is spelt IE", "lie"],
	"Feature_Has_Phoneme_Ay_Spelled_Y_Not_End" => ["Words where the AY sound \n is spelt Y", "cry"],
	"Feature_Has_Phoneme_Ey_Spelled_Eigh" => ["Words where the EY sound \n is spelt EIGH", "neighbour"],
	"Feature_Has_Phoneme_Ey_Spelled_Ey" => ["Words where the EY sound \n is spelt EY", "grey"],
	"Feature_Has_Phoneme_F_Spelled_Ph" => ["Words where the F sound \n is spelt PH", "elephant"],
	"Feature_Has_Phoneme_Iy_Spelled_Ea" => ["Words where the EE sound \n is spelt EA", "dream"],
	"Feature_Has_Phoneme_Iy_Spelled_Ie" => ["Words where the EE sound \n is spelt IE", "piece"],
	"Feature_Has_Phoneme_Ih_Spelled_Y_Not_End" => ["Words where the short I sound \n is spelt Y", "abyss"],
	"Feature_Has_Phoneme_Iy_Spelled_Ee" => ["Words where the EE sound \n is spelt EE", "see"],
	"Feature_Has_Phoneme_Iy_Spelled_Ey" => ["Words where the EE sound \n is spelt EY", "key"],
	"Feature_Has_Phoneme_Jh_Spelled_G" => ["Words where the hard J sound \n is spelt G", "change"],
	"Feature_Has_Phoneme_K_Spelled_Ch" => ["Words where the K sound \n is spelt CH", "character"],
	"Feature_Has_Phoneme_Ow_Spelled_Oe" => ["Words where the O sound \n is spelt OE", "toe"],
	"Feature_Has_Phoneme_Ow_Spelled_Ough" => ["Words where the O sound \n is spelt OUGH", "dough"],
	"Feature_Has_Phoneme_Ow_Spelled_Ow" => ["Words where the O sound \n is spelt OW", "row"],
	"Feature_Has_Phoneme_S_Spelled_Sc" => ["Words with the sound S \n spelt S or C", "chase"],
	"Feature_Has_Phoneme_Sh_Spelled_Ch" => ["Words where the SH sound \n is spelt CH", "machine"],
	"Feature_Has_Phoneme_Uw_Spelled_Ew" => ["Words where the OO sound \n is spelt EW", "grew"],
	"Feature_Has_Phoneme_Uw_Spelled_Ough" => ["Words where the OO sound \n is spelt OUGH", "through"],
	"Feature_Has_Phoneme_Uw_Spelled_Ue" => ["Words where the OO sound \n is spelt UE", "true"],
	"Feature_Has_Phoneme_W_Spelled_Wh" => ["Words where the W sound \n is spelt WH", "whale"],
	"Feature_Has_Phoneme_Zh_Spelled_S" => ["Words where the soft J sound \n is spelt S", "pleasure"],
	"Feature_Has_Phonemes_Ah0_L_Spelled_Al" => ["Words where the L sound \n is spelt AL", "special"],
	"Feature_Has_Phonemes_Ah0_L_Spelled_El" => ["Words where the L sound \n is spelt EL", "angel"],
	"Feature_Has_Phonemes_Ah0_L_Spelled_Le" => ["Words where the L sound \n is spelt LE", "castle"],
	"Feature_Has_Phonemes_S_Ah0_N_Spelled_Sten" => ["Words where the SN sound \n is spelt STEN", "listen"],
	"Feature_Has_Silent_U_In_Ui" => ["Words spelt UI\n with a silent U" , "guilty"],
	"Feature_Has_String_Cei" => ["Words where the SEE sound \n is spelt CEI", "deceive"],
	"Feature_Has_String_Ie" => ["Words that have the letters \nIE", "believe"],
	"Feature_Has_String_Ight" =>["Words that have the letters \nIGHT", "night"],
	"Feature_Has_Suffix_Ch" => ["Words with the sound CH \n spelt CH", "reach"],
	"Feature_Has_Suffix_Gue" => ["Words that end in -GUE", "plague"],
	"Feature_Has_Suffix_Tch" => ["Words with the sound CH \n spelt TCH", "match"],
	"silent_cons" => ["Words that have a silent consonant \n", "knife"],
	"single_cons_before_ing_ed_er" => ["Words with just one consonant \n before -ING or -ED", "limited"],
	"sound_s" => ["Words with the sound S", "chase"],
	"string_air" => ["Words where the AIR sound \n is spelt AIR", "dispair"],
	"string_are" => ["Words where the AIR sound \n is spelt ARE", "rare"],
	"string_ear" => ["Words where the AIR sound \n is spelt EAR", "wear"],
	"string_ore" => ["Words with the OR sound \n spelt OR or ORE", "record"],
	"string_ough" => ["Words that contain the letters OUGH", "dough"]

}


GAME_DESCRIPTIONS = {
	"sounds_ey_ay" => "Vowel Sounds 2",
	"sounds_ih_iy" => "Vowel Sounds 3",
	"sounds_ow_aw_uw" => "Vowel Sounds 1",
	"sounds_s_ch_jh_zh_w_f" => "Consonants Sounds 1",
	"silent_cons_and_foreign" => "Silent Letters and Words with a Foreign Origin",
	"double_cons" => "Double and Single Consonants",
	"strings" => "Common Letter Combinations"

}