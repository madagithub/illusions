package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

import illusions.Illusion;
import illusions.DotsIllusion;
import illusions.SphereIllusion;
import illusions.BioMotionIllusion;

import openfl.system.System;

typedef Language = {
    id : Int,
    buttonSpritesheet : String,
    stopSpritesheet : String,
    backgroundImage : String,
    infoImage : String
}

// IMPORTANT!
//-----------
// This program must run with with HaxeFlixel 4.4.1, and:
//-------------------------------------------------------
// haxelib set openfl 3.6.1
// haxelib set lime 2.9.1
//-------------------------------------------------------
// As otherwise Neko is very slow!

class PlayState extends FlxState
{
    private static var INFO_X : Float = 1462;
    private static var INFO_Y : Float = 1020;
    private static var BUTTON_WIDTH : Int = 83;
    private static var BUTTON_HEIGHT : Int = 83;
    private static var STOP_BUTTON_WIDTH : Int = 160;
    private static var STOP_BUTTON_HEIGHT : Int = 83;

    private static var ILLUSION_ACTIVE_DISPLAY_X : Float = 1521;
    private static var ILLUSION_ACTIVE_DISPLAY_Y : Float = 347;

    private static var FIRST_LANGUAGE_X : Float =  1650;
    private static var LANGUAGE_Y : Float = 1020;
    private static var LANGUAGE_SPACING : Float = 0;

    private static var IDLE_TIME_ALLOWED_SECONDS : Int = 1 * 60 * 5;

    private static var DOTS_ILLUSION_NAME : String = "dots";
    private static var SPHERE_ILLUSION_NAME : String = "sphere";
    private static var BIO_MOTION_ILLUSION_NAME : String = "biomotion";

    private static var ILLUSION_NAME : String = SPHERE_ILLUSION_NAME;

    private static var LANGUAGES: Array<Language> = [
        {id: 0, buttonSpritesheet: "arabicSpritesheet", stopSpritesheet: "stopArabic", backgroundImage: "backgroundArabic", infoImage: "infoArabic"},
        {id: 1, buttonSpritesheet: "englishSpritesheet", stopSpritesheet: "stopEnglish", backgroundImage: "backgroundEnglish", infoImage: "infoEnglish"},
        {id: 2, buttonSpritesheet: "hebrewSpritesheet", stopSpritesheet: "stopHebrew", backgroundImage: "backgroundHebrew", infoImage: "infoHebrew"}
    ];

    private static var START_LANGAUGE_INDEX : Int = 2;

    private var sliders : Array<Slider>;
    private var onInfoClickableButtons : Array<FlxButton>;

    private var stopIllusionButton : FlxButton;

    private var selectedLanguage : Language;
    private var background : FlxSprite;
    private var info : FlxSprite;

    private var idleTimer : FlxTimer;

    private var illusion : Illusion;

    private var logger : EasyLogger;

    override public function create() : Void {
        super.create();

        this.logger = new EasyLogger("./illusions_log_[logType].txt");
        this.logger.consoleOutput = true;

        this.selectedLanguage = LANGUAGES[START_LANGAUGE_INDEX];

        this.stopIllusionButton = new FlxButton(ILLUSION_ACTIVE_DISPLAY_X, ILLUSION_ACTIVE_DISPLAY_Y, "", this.startIllusion);
        this.stopIllusionButton.onDown.callback = this.stopIllusion;
        this.stopIllusionButton.onOut.callback = this.startIllusion;

        this.background = new FlxSprite();
        this.info = new FlxSprite();
        this.info.visible = false;
        this.loadLanguage();
        add(this.background);

        add(stopIllusionButton);

        var infoButton = new FlxButton(INFO_X - BUTTON_WIDTH / 2, INFO_Y - BUTTON_HEIGHT / 2, "", this.toggleInfo);
        infoButton.loadGraphic("assets/images/infoSpritesheet.png", true, BUTTON_WIDTH, BUTTON_HEIGHT);
        add(infoButton);

        this.onInfoClickableButtons = new Array<FlxButton>();
        this.onInfoClickableButtons.push(infoButton);

        this.createLanguageButtons();

        // Create sliders
        this.sliders = new Array<Slider>();
        this.createIllusion(ILLUSION_NAME);

        add(this.info);

        idleTimer = new FlxTimer();
        this.startIdleTimer();
    }

    override public function onFocusLost() : Void {
    }

    override public function onFocus() : Void {
    }

    override public function update(elapsed : Float) : Void {
        checkExitKey();
        checkMouseEvents();

        illusion.update(elapsed);

        super.update(elapsed);
    }

    //TODO: Constants
    private function createIllusion(name : String) {
        if (name == DOTS_ILLUSION_NAME) {
            this.illusion = new DotsIllusion(this);
            this.sliders.push(new Slider(this, "slider1", new FlxRect(1733, 471, 100, 377), this.sliderChanged, 1, 30, 1, 15, 15));
            this.sliders.push(new Slider(this, "slider2", new FlxRect(1525, 471, 100, 377), this.sliderChanged, -5, 40, 1, 20, 20));
        } else if (name == SPHERE_ILLUSION_NAME) {
            this.illusion = new SphereIllusion(this);
            this.sliders.push(new Slider(this, "slider1", new FlxRect(1733, 471, 100, 377), this.sliderChanged, 5, 200, 5, 100, 100));
            this.sliders.push(new Slider(this, "slider2", new FlxRect(1525, 471, 100, 377), this.sliderChanged, 0, 80, 2, 20, 20));
        } else {
            this.illusion = new BioMotionIllusion(this);
            this.sliders.push(new Slider(this, "slider1", new FlxRect(1733, 471, 100, 377), this.sliderChanged, 3, 13, 1, 13, 13));
            this.sliders.push(new Slider(this, "slider2", new FlxRect(1525, 471, 100, 377), this.sliderChanged, 0, 60, 5, 30, 30));
        }
    }

    private function restartIdleTimer() {
        this.idleTimer.cancel();
        this.startIdleTimer();
    }

    private function startIdleTimer() {
        this.idleTimer.start(IDLE_TIME_ALLOWED_SECONDS, function(timer) { 
            this.restart();
            this.startIdleTimer();
        }, 1);
    }

    private function restart() {
        this.info.visible = false;
        this.selectedLanguage = LANGUAGES[START_LANGAUGE_INDEX];
        this.loadLanguage();
        
        for (slider in this.sliders) {
            slider.restart();
        }
    }

    private function loadLanguage() {
        this.background.loadGraphic("assets/images/" + this.selectedLanguage.backgroundImage + ".png");
        this.info.loadGraphic("assets/images/" + this.selectedLanguage.infoImage + ".png");
        this.stopIllusionButton.loadGraphic("assets/images/" + this.selectedLanguage.stopSpritesheet + ".png", true, STOP_BUTTON_WIDTH, STOP_BUTTON_HEIGHT);
    }

    private function createLanguageButtons() {
        var currButtonX = FIRST_LANGUAGE_X;
        for (language in LANGUAGES) {
            // NOTE: Passing to the onClick function an already binded toggleLanguage function with the current langauge,
            // so it will get the language to set to
            var languageButton = new FlxButton(currButtonX - BUTTON_WIDTH / 2, LANGUAGE_Y - BUTTON_HEIGHT / 2, "", toggleLanguage.bind(language));
            languageButton.loadGraphic("assets/images/" + language.buttonSpritesheet + ".png", true, BUTTON_WIDTH, BUTTON_HEIGHT);
            add(languageButton);
            onInfoClickableButtons.push(languageButton);

            currButtonX += (languageButton.width + LANGUAGE_SPACING);
        }
    }

    private function stopIllusion() : Void {
        this.logger.log("1", "STOP_ILLUSION");
        this.illusion.stop();
    }

    private function startIllusion() : Void {
        this.logger.log("1", "START_ILLUSION");
        this.illusion.start();
    }

    private function toggleInfo() : Void {
    	this.info.visible = !this.info.visible;

        if (this.info.visible) {
            this.logger.log("1", "INFO_SHOW");
        } else {
            this.logger.log("1", "INFO_HIDE");
        }
    }

    private function toggleLanguage(language : Language) : Void {
        this.logger.log("1", "LANGUAGE_CHANGE" + "," + this.selectedLanguage.id + "," + language.id);
        this.selectedLanguage = language;
        this.loadLanguage();
    }

    private function checkExitKey() : Void {
        if (FlxG.keys.enabled && FlxG.keys.pressed.ESCAPE) {
            System.exit(0);
        }
    }

    private function isPositionInButton(position : FlxPoint) : Bool {
        for (button in this.onInfoClickableButtons) {
            if (button.getHitbox().containsPoint(position)) {
                return true;
            }
        }

        return false;
    }

    private function checkMouseEvents() : Void {
        // Any mouse movement will restart idle timer!
        if (FlxG.mouse.justPressed || FlxG.mouse.justReleased || FlxG.mouse.justMoved) {
            this.restartIdleTimer();
        }

        // Close info if shown and mouse click was not on info or language button
        if (FlxG.mouse.justPressed && this.info.visible && !isPositionInButton(FlxG.mouse.getScreenPosition())) {
            this.toggleInfo();
        }

        for (slider in this.sliders) {
            slider.mouseMove(FlxG.mouse.getScreenPosition());

            if (FlxG.mouse.justPressed) {
                slider.mouseDown(FlxG.mouse.getScreenPosition());
            }

            if (FlxG.mouse.justReleased) {
                slider.mouseUp(FlxG.mouse.getScreenPosition());
            }
        }
    }

    private function sliderChanged(sliderName : String, oldValue : Float, newValue : Float) {
        if (oldValue != Slider.NO_VALUE) {
            this.logger.log("1", "SLIDER_CHANGE_" + sliderName + "," + oldValue + "," + newValue);
        }

        illusion.sliderChanged(sliderName, newValue);
    }
}
