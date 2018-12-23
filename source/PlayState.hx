package;

using Lambda;
using config.ConfigData;

import utils.Constants;

import haxe.Json;
import sys.io.File;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

import ui.Slider;

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
    private var infoShown : Bool;

    private var idleTimer : FlxTimer;

    private var illusion : Illusion;
    private var illusionData : IllusionData;

    private var logger : Logger;
    private var config : ConfigData;

    private var slidersPositions : Array<FlxRect>;

    private var toggleTween : FlxTween;

    private var handCursor : FlxSprite;

    override public function create() : Void {
        super.create();

        this.toggleTween = null;

        this.config = Json.parse(File.getContent("assets/data/config.json"));

        this.background = new FlxSprite();
        add(this.background);

        // Create sliders
        this.sliders = new Array<Slider>();

        this.slidersPositions = new Array<FlxRect>();
        for (i in 0...SLIDERS_NUM) {
            this.slidersPositions.push(new FlxRect(this.config.sliders[i].x, this.config.sliders[i].y, this.config.sliders[i].width, this.config.sliders[i].height));
        }

        this.createIllusion(this.config.illusionName);

        this.logger = new Logger("./illusions_log_[logType].txt", this.config.maxLogFiles, this.config.maxRowsPerLogFile);

        this.handCursor = new FlxSprite();
        this.handCursor.loadGraphic("assets/images/handCursor.png", true);

        this.setSelectedLanguage();

        this.stopIllusionButton = this.loadButton(this.config.stopButtonX, this.config.stopButtonY, this.selectedLanguage.stopSpritesheet, this.startIllusion, 
            this.config.stopButtonWidth, this.config.stopButtonHeight);
        this.stopIllusionButton.onOver.callback = this.setHandCursorOnButton;
        this.stopIllusionButton.onDown.callback = this.stopIllusion;
        this.stopIllusionButton.onOut.callback = function() {
            this.startIllusion();
            this.setRegularCursorOnButton();
        }

        this.info = new FlxSprite();
        this.restartInfoState();
        this.loadLanguage();

        add(stopIllusionButton);

        var infoButton : FlxButton = this.loadButton(this.config.infoX, this.config.infoY, this.selectedLanguage.infoSpritesheet, this.toggleInfo);
        this.setButtonCursorReactive(infoButton);
        add(infoButton);

        this.onInfoClickableButtons = new Array<FlxButton>();
        this.onInfoClickableButtons.push(infoButton);

        this.createLanguageButtons();

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

    public function setButtonCursorReactive(button : FlxButton) {
        button.onOver.callback = this.setHandCursorOnButton;
        button.onOut.callback = this.setRegularCursorOnButton;
    }

    private function setHandCursorOnButton() {
        if (!this.infoShown) {
            this.setHandCursor();
        }
    }

    private function setHandCursor() {
        FlxG.mouse.load(this.handCursor.pixels, 1, this.config.handCursorOffsetX, this.config.handCursorOffsetY);
    }

    private function setRegularCursorOnButton() {
        if (!this.infoShown) {
            this.setRegularCursor();
        }
    }

    private function setRegularCursor() {
        FlxG.mouse.unload();
    }

    private function createIllusion(name : String) {
        this.illusionData = this.config.illusions.find(function(illusion) return illusion.name == this.config.illusionName);

        if (name == DOTS_ILLUSION_NAME) {
            this.illusion = new DotsIllusion(this, illusionData.dotsConfig);
        } else if (name == SPHERE_ILLUSION_NAME) {
            this.illusion = new SphereIllusion(this, illusionData);
        } else {
            this.illusion = new BioMotionIllusion(this, illusionData.bioMotionConfig);
        }

        for (i in 0...SLIDERS_NUM) {
            this.sliders.push(new Slider(this, i == 0 ? Constants.FIRST_SLIDER_ID : Constants.SECOND_SLIDER_ID, this.slidersPositions[i], this.sliderChanged, this.sliderDragDone,
                illusionData.sliders[i].min, illusionData.sliders[i].max, illusionData.sliders[i].diff, illusionData.sliders[i].start, illusionData.sliders[i].limit));
        }
    }

    private function restartInfoState() {
        this.info.visible = false;
        this.info.alpha = 0.0;
        this.infoShown = false;
    }

    private function getFullSpritesheetPath(spritesheetName : String, addIllusionName : Bool = false) {
        return "assets/images/" + (addIllusionName ? (this.illusionData.name + "/") : "") + spritesheetName + ".png";
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
        this.restartInfoState();
        this.setSelectedLanguage();

        this.loadLanguage();
        
        for (slider in this.sliders) {
            slider.restart();
        }
    }

    private function loadLanguage() {
        this.background.loadGraphic(this.getFullSpritesheetPath(this.selectedLanguage.backgroundImage, true));
        this.info.loadGraphic(this.getFullSpritesheetPath(this.selectedLanguage.infoImage, true));
        this.stopIllusionButton.loadGraphic(this.getFullSpritesheetPath(this.selectedLanguage.stopSpritesheet), true, this.config.stopButtonWidth, this.config.stopButtonHeight);
    }

    private function createLanguageButtons() {
        var currButtonX : Float = this.config.firstLanguageX;
        for (language in this.config.languages) {
            // NOTE: Passing to the onClick function an already binded toggleLanguage function with the current langauge,
            // so it will get the language to set to
            var languageButton : FlxButton = this.loadButton(currButtonX, this.config.languageY, language.buttonSpritesheet, this.toggleLanguage.bind(language));
            this.setButtonCursorReactive(languageButton);
            add(languageButton);
            onInfoClickableButtons.push(languageButton);

            currButtonX += (languageButton.width + this.config.languageSpacing);
        }
    }

    private function stopIllusion() : Void {
        this.logger.log("STOP_ILLUSION");
        this.illusion.stop();
    }

    private function startIllusion() : Void {
        this.logger.log("START_ILLUSION");
        this.illusion.start();
    }

    private function toggleInfo() : Void {
        if (this.toggleTween != null) {
            this.toggleTween.cancel();
        }

        var currAlpha : Float = this.info.alpha;
        var destAlpha : Float = this.infoShown ? 0.0 : 1.0;

        this.info.visible = true;
        this.infoShown = !this.infoShown;
        this.toggleTween = FlxTween.tween(this.info, {alpha: destAlpha}, 0.3 * Math.abs(destAlpha - currAlpha), {onComplete: function(tween) this.info.visible = this.infoShown});

        if (this.infoShown) {
            this.setHandCursor();
            this.logger.log("INFO_SHOW");
        } else {
            this.setRegularCursor();
            this.logger.log("INFO_HIDE");
        }
    }

    private function toggleLanguage(language : LanguageData) : Void {
        this.logger.log("LANGUAGE_CHANGE" + "," + this.selectedLanguage.id + "," + language.id);
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
        if (FlxG.mouse.justPressed && this.infoShown && !isPositionInButton(FlxG.mouse.getScreenPosition())) {
            this.toggleInfo();
        }

        for (slider in this.sliders) {
            var result : CursorMode = slider.mouseMove(FlxG.mouse.getScreenPosition());

            if (!this.infoShown) {
                if (result == ENTER || result == OVER) {
                    this.setHandCursor();
                } else if (result == EXIT) {
                    this.setRegularCursor();
                }

                if (FlxG.mouse.justPressed) {
                    slider.mouseDown(FlxG.mouse.getScreenPosition());
                }

                if (FlxG.mouse.justReleased) {
                    slider.mouseUp(FlxG.mouse.getScreenPosition());
                }
            }
        }
    }

    private function sliderDragDone(sliderName : String, oldValue : Float, newValue : Float) {
        if (oldValue != Slider.NO_VALUE) {
            this.logger.log("SLIDER_CHANGE_" + sliderName + "," + oldValue + "," + newValue);
        }
    }

    private function sliderChanged(sliderName : String, oldValue : Float, newValue : Float) {
        illusion.sliderChanged(sliderName, newValue);
    }
}
