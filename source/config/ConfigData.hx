package config;

typedef SliderPosition = {
	x : Int,
	y : Int,
	width : Int,
	height : Int
};

typedef SliderData = {
	min : Float,
	max : Float, 
	diff : Float,
	start : Float,
	limit : Float
}

typedef LanguageData = {
	id : Int,
	rtl : Bool,
	buttonSpritesheet : String,
	stopSpritesheet : String,
	infoSpritesheet : String,
	backgroundImage : String,
	infoImage : String
};

typedef IllusionData = {
	name : String,
	sliders : Array<SliderData>
}

typedef ConfigData = {
	infoX : Int,
	infoY : Int,

	stopButtonX : Int,
	stopButtonY : Int,

	stopButtonWidth : Int,
	stopButtonHeight : Int,

	handCursorOffsetX : Int,
	handCursorOffsetY : Int,

	firstLanguageX : Int,
	languageY : Int,
	languageSpacing: Int,

	idleSecondsAllowed : Int,

	sliders : Array<SliderPosition>,

	illusions : Array<IllusionData>,
	illusionName : String,

	languages : Array<LanguageData>,
	startLanguageId : Int
};