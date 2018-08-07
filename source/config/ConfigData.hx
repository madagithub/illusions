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

typedef DotsConfig = {
	x : Int,
	y : Int,
	width : Int,
	height : Int,

	dotSize : Int,

	stopSpeed : Int,
	stopDotSize : Int,

	crossSize : Int
}

typedef SphereConfig = {
	x : Int,
	y : Int,
	width : Int,
	height : Int,

	dotSize : Int,

	stopSpeed : Int,
	stopDotsNum : Int
}

typedef BioMotionConfig = {
	dotSize : Int,

	stopSpeed : Int,
	stopDotsNum : Int,

	dotsOffsetX : Int,
	dotsOffsetY : Int,

	prevButtonX : Int,
	prevButtonY : Int,
	nextButtonX : Int,
	nextButtonY : Int,
	nextButtonSpritesheet : String,
	prevButtonSpritesheet : String,

	animationFileNames : Array<String>,
	startAnimationIndex : Int
}

typedef IllusionData = {
	name : String,
	sliders : Array<SliderData>,
	dotsConfig : DotsConfig,
	sphereConfig : SphereConfig,
	bioMotionConfig : BioMotionConfig
}

typedef ConfigData = {
	maxLogFiles : Int,
	maxRowsPerLogFile : Int,

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