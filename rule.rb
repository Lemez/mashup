def change_rule_to_completed
	return Rule.where('final_subs_logo != ?', params[:final_subs_logo]).count
end

NODE_DESCRIPTIONS = {
	"double_cons_before_ing_ed_er" => ["Words that double their last consonant before you add \n -ING, -ED, -ER ", "forgetting"],
	"Feature_Has_Phoneme_Aw_Spelled_Ou" => ["Words where the \nAW\n sound is spelt \nOU", "about"],
	"Feature_Has_Phoneme_Aw_Spelled_Ow" => ["Words where the \nAW\n sound is spelt OW", "how"],
	"Feature_Has_Phoneme_Ay_Spelled_Ie" => ["Words where the \nAY\n sound is spelt IE", "tries"],
	"Feature_Has_Phoneme_Ay_Spelled_Y_Not_End" => ["Words where the \nAY\n sound in the middle of a word is spelt \nY\n ", "myself"],
	"Feature_Has_Phoneme_Ey_Spelled_Eigh" => ["Words where the \nEY\n sound is spelt \nEIGH", "weigh"],
	"Feature_Has_Phoneme_Ey_Spelled_Ey" => ["Words where the \nEY\n sound is spelt \nEY", "grey"],
	"Feature_Has_Phoneme_F_Spelled_Ph" => ["Words where the \nF\n sound is spelt \nPH", "elephant"],
	"Feature_Has_Phoneme_Ih_Spelled_Ea" => ["Words where the \nIH\n sound is spelt \nEA", "dream"],
	"Feature_Has_Phoneme_Ih_Spelled_Ie" => ["Words where the \nIH\n sound is spelt \nIE", "piece"],
	"Feature_Has_Phoneme_Ih_Spelled_Y_Not_End" => ["Words where the \nIH\n sound in the middle is spelt \nY\n in the middle", "everything"],
	"Feature_Has_Phoneme_Iy_Spelled_Ee" => ["Words where the \nIY\n sound is spelt \nEE", "feel"],
	"Feature_Has_Phoneme_Iy_Spelled_Ey" => ["Words where the \nIH\n sound is spelt \nEY", "key"],
	"Feature_Has_Phoneme_Jh_Spelled_G" => ["Words where the \nJ\n sound is spelt \nG", "change"],
	"Feature_Has_Phoneme_K_Spelled_Ch" => ["Words where the \nK\n sound is spelt \nCH", "school"],
	"Feature_Has_Phoneme_Ow_Spelled_Oe" => ["Words where the \nO\n sound is spelt \nIE", "goes"],
	"Feature_Has_Phoneme_Ow_Spelled_Ough" => ["Words where the \nO\n sound is spelt \nIE", "although"],
	"Feature_Has_Phoneme_Ow_Spelled_Ow" => ["Words where the \nO\n sound is spelt \nIE", "know"],
	"Feature_Has_Phoneme_S_Spelled_Sc" => ["Words where the \nS\n sound is spelt \nSC", "descend"],
	"Feature_Has_Phoneme_Sh_Spelled_Ch" => ["Words where the \nSH\n sound is spelt \nCH", "machine"],
	"Feature_Has_Phoneme_Uw_Spelled_Ew" => ["Words where the \nOO\n sound is spelt \nEW", "grew"],
	"Feature_Has_Phoneme_Uw_Spelled_Ough" => ["Words where the \nOO\n sound is spelt \nOUGH", "through"],
	"Feature_Has_Phoneme_Uw_Spelled_Ue" => ["Words where the \nOO\n sound is spelt \nUE", "blue"],
	"Feature_Has_Phoneme_W_Spelled_Wh" => ["Words where the \nW\n sound is spelt \nWH", "why"],
	"Feature_Has_Phoneme_Zh_Spelled_S" => ["Words where the \nsoft J\n sound is spelt \nS", "treasure"],
	"Feature_Has_Phonemes_Ah0_L_Spelled_Al" => ["Words where the \nL\n sound is spelt \nAL", "special"],
	"Feature_Has_Phonemes_Ah0_L_Spelled_El" => ["Words where the \nL\n sound is spelt \nOUGH", "angel"],
	"Feature_Has_Phonemes_Ah0_L_Spelled_Le" => ["Words where the \nL\n sound is spelt \nOUGH", "castle"],
	"Feature_Has_Phonemes_S_Ah0_N_Spelled_Sten" => ["Words where the \nSN\n sound is spelt \nSTEN", "listen"],
	"Feature_Has_Silent_U_In_Ui" => ["Words spelt \nUI\n with a \nsilent U" , "build"],
	"Feature_Has_String_Cei" => ["Words where the \nSEE\n sound is spelt CEI", "ceiling"],
	"Feature_Has_String_Ie" => ["Words where the \nEE\n sound is spelt IE", "believe"],
	"Feature_Has_String_Ight" =>["Words where the \nAY\n sound is spelt IGH", "night"],
	"Feature_Has_Suffix_Ch" => ["Words that have a suffix \n(words that end in)\nCH", "reach"],
	"Feature_Has_Suffix_Gue" => ["Words that have a suffix \n(words that end in)\nGUE", "tongue"],
	"Feature_Has_Suffix_Tch" => ["Words that have a suffix \n(words that end in)\nTCH", "catch"],
	"silent_cons" => ["Words that have a silent consonant \nOUGH", "knife"],
	"single_cons_before_ing_ed_er" => ["Words with just one consonant before \n -ING, -ED, -ER ", "happened"],
	"sound_s" => ["Words that have the sound \nS", "chase"],
	"string_air" => ["Words where the \nAIR\n sound is spelt \nAIR", "hair"],
	"string_are" => ["Words where the \nAIR\n sound is spelt \nARE", "careful"],
	"string_ear" => ["Words where the \nAIR\n sound is spelt \nEAR", "wearing"],
	"string_ore" => ["Words where the sound is \nOR", "before"],
	"string_ough" => ["Words that contain the letters \nUGH", "laugh"]

}