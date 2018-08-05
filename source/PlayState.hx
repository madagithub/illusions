package;

using Lambda;
using ConfigData;

import haxe.Json;
import sys.io.File;

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

// IMPORTANT!
//-----------
// FOR DEBUGGING, this program better runs with with HaxeFlixel 4.4.1, and:
//-------------------------------------------------------
// haxelib set openfl 3.6.1
// haxelib set lime 2.9.1
//-------------------------------------------------------
// As otherwise Neko is very slow!
//-------------------------------------------------------
// However, for production, best to use updated versions and compile to cpp!

class PlayState extends FlxState
{
    private static var DOTS_ILLUSION_NAME : String = "dots";
    private static var SPHERE_ILLUSION_NAME : String = "sphere";
    private static var BIO_MOTION_ILLUSION_NAME : String = "biomotion";

    private static var SLIDERS_NUM : Int = 2;

    private var sliders : Array<Slider>;
    private var onInfoClickableButtons : Array<FlxButton>;

    private var stopIllusionButton : FlxButton;

    private var selectedLanguage : LanguageData;
    private var background : FlxSprite;
    private var info : FlxSprite;

    private var idleTimer : FlxTimer;

    private var illusion : Illusion;

    private var logger : EasyLogger;
    private var config : ConfigData;

    private var slidersPositions : Array<FlxRect>;

    override public function create() : Void {
        super.create();

        this.logger = new EasyLogger("./illusions_log_[logType].txt");
        this.logger.consoleOutput = true;

        this.config = Json.parse(File.getContent('assets/data/config.json'));
        trace(this.config);

        this.setSelectedLanguage();

        this.stopIllusionButton = this.loadButton(this.config.stopButtonX, this.config.stopButtonY, this.selectedLanguage.stopSpritesheet, this.startIllusion, 
            this.config.stopButtonWidth, this.config.stopButtonHeight);
        trace(this.stopIllusionButton.height);
        this.stopIllusionButton.onDown.callback = this.stopIllusion;
        this.stopIllusionButton.onOut.callback = this.startIllusion;

        this.background = new FlxSprite();
        this.info = new FlxSprite();
        this.info.visible = false;
        this.loadLanguage();
        add(this.background);

        add(stopIllusionButton);

        var infoButton : FlxButton = this.loadButton(this.config.infoX, this.config.infoY, this.selectedLanguage.infoSpritesheet, this.toggleInfo);
        trace(infoButton.height);
        add(infoButton);

        this.onInfoClickableButtons = new Array<FlxButton>();
        this.onInfoClickableButtons.push(infoButton);

        this.createLanguageButtons();

        // Create sliders
        this.sliders = new Array<Slider>();

        this.slidersPositions = new Array<FlxRect>();
        for (i in 0...SLIDERS_NUM) {
            this.slidersPositions.push(new FlxRect(this.config.sliders[i].x, this.config.sliders[i].y, this.config.sliders[i].width, this.config.sliders[i].height));
        }

        this.createIllusion(this.config.illusionName);

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
        } else if (name == SPHERE_ILLUSION_NAME) {
            this.illusion = new SphereIllusion(this);
        } else {
            this.illusion = new BioMotionIllusion(this);
        }

        var illusionData : IllusionData = this.config.illusions.find(function(illusion) return illusion.name == this.config.illusionName);

        for (i in 0...SLIDERS_NUM) {
            this.sliders.push(new Slider(this, i == 0 ? "slider1" : "slider2", this.slidersPositions[i], this.sliderChanged, 
                illusionData.sliders[i].min, illusionData.sliders[i].max, illusionData.sliders[i].diff, illusionData.sliders[i].start, illusionData.sliders[i].limit));
        }
    }

    private function getFullSpritesheetPath(spritesheetName : String) {
        return "assets/images/" + spritesheetName + ".png";
    }

    private function loadButton(x : Float, y : Float, spirtesheetName : String, onClick : Void -> Void, width : Int = 0, height : Int = 0) : FlxButton {
        var button : FlxButton = new FlxButton(x, y, "", onClick);
        button.loadGraphic(this.getFullSpritesheetPath(spirtesheetName), true, width, height);
        button.x -= button.width / 2;
        button.y -= button.height / 2;

        return button;
    }

    private function restartIdleTimer() {
        this.idleTimer.cancel();
        this.startIdleTimer();
    }

    private function startIdleTimer() {
        this.idleTimer.start(this.config.idleSecondsAllowed, function(timer) { 
            this.restart();
            this.startIdleTimer();
        }, 1);
    }

    private function setSelectedLanguage() {
        this.selectedLanguage = this.config.languages.find(function(language) return language.id == this.config.startLanguageId);
    }

    private function restart() {
        this.info.visible = false;
        this.setSelectedLanguage();

        this.loadLanguage();
        
        for (slider in this.sliders) {
            slider.restart();
        }
    }

    private function loadLanguage() {
        this.background.loadGraphic(this.getFullSpritesheetPath(this.selectedLanguage.backgroundImage));
        this.info.loadGraphic(this.getFullSpritesheetPath(this.selectedLanguage.infoImage));
        this.stopIllusionButton.loadGraphic(this.getFullSpritesheetPath(this.selectedLanguage.stopSpritesheet), true, this.config.stopButtonWidth, this.config.stopButtonHeight);
    }

    private function createLanguageButtons() {
        var currButtonX : Float = this.config.firstLanguageX;
        for (language in this.config.languages) {
            // NOTE: Passing to the onClick function an already binded toggleLanguage function with the current langauge,
            // so it will get the language to set to
            var languageButton : FlxButton = this.loadButton(currButtonX, this.config.languageY, language.buttonSpritesheet, this.toggleLanguage.bind(language));
            add(languageButton);
            onInfoClickableButtons.push(languageButton);

            currButtonX += (languageButton.width + this.config.languageSpacing);
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

    private function toggleLanguage(language : LanguageData) : Void {
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
