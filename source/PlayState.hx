package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.math.FlxRect;

import openfl.Lib;

typedef Language = {
    id : String,
    buttonSpritesheet : String,
    backgroundImage: String
}

class PlayState extends FlxState
{
    private static var INFO_X : Float = 1462;
    private static var INFO_Y : Float = 1020;
    private static var BUTTON_WIDTH : Int = 83;
    private static var BUTTON_HEIGHT : Int = 83;

    private static var FIRST_LANGUAGE_X : Float =  1650;
    private static var LANGUAGE_Y : Float = 1020;
    private static var LANGUAGE_SPACING : Float = 0;

    private static var LANGUAGES: Array<Language> = [
        {id: "arabic", buttonSpritesheet: "infoSpritesheet", backgroundImage: "background"},
        {id: "english", buttonSpritesheet: "infoSpritesheet", backgroundImage: "background"},
        {id: "hebrew", buttonSpritesheet: "infoSpritesheet", backgroundImage: "background"}
    ];

    private var sliders : Array<Slider>;
    private var selectedLanguage : Language;
    private var background : FlxSprite;

    private var dotsIllusion : DotsIllusion;

    override public function create() : Void {
        super.create();

        this.selectedLanguage = LANGUAGES[0];

        this.background = new FlxSprite();
        this.loadLanguage();
        add(background);

        var infoButton = new FlxButton(INFO_X - BUTTON_WIDTH / 2, INFO_Y - BUTTON_HEIGHT / 2, "", toggleInfo);
        infoButton.loadGraphic("assets/images/infoSpritesheet.png", true, BUTTON_WIDTH, BUTTON_HEIGHT);
        add(infoButton);

        this.createLanguageButtons();

        this.dotsIllusion = new DotsIllusion(this);

        // Create sliders
        sliders = new Array<Slider>();
        sliders.push(new Slider(this, "slider1", new FlxRect(1525, 471, 100, 377), this.sliderChanged, 1, 30, 1, 5, 5));
        sliders.push(new Slider(this, "slider2", new FlxRect(1733, 471, 100, 377), this.sliderChanged, -5, 40, 1, 12, 12));
    }

    override public function onFocusLost() : Void {
    }

    override public function onFocus() : Void {
    }

    override public function update(elapsed : Float) : Void {
        checkExitKey();
        checkMouseEvents();

        super.update(elapsed);
    }

    private function loadLanguage() {
        background.loadGraphic("assets/images/" + this.selectedLanguage.backgroundImage + ".png");
    }

    private function createLanguageButtons() {
        var currButtonX = FIRST_LANGUAGE_X;
        for (language in LANGUAGES) {
            // NOTE: Passing to the onClick function an already binded toggleLanguage function with the current langauge,
            // so it will get the language to set to
            var languageButton = new FlxButton(currButtonX - BUTTON_WIDTH / 2, LANGUAGE_Y - BUTTON_HEIGHT / 2, "", toggleLanguage.bind(language));
            languageButton.loadGraphic("assets/images/" + language.buttonSpritesheet + ".png", true, BUTTON_WIDTH, BUTTON_HEIGHT);
            add(languageButton);

            currButtonX += (languageButton.width + LANGUAGE_SPACING);
        }
    }

    private function toggleInfo() : Void {

    }

    private function toggleLanguage(language : Language) : Void {
        trace("TOGGLE TO: " + language.id);
        this.selectedLanguage = language;
        this.loadLanguage();
    }

    private function checkExitKey() : Void {
        if (FlxG.keys.enabled && FlxG.keys.pressed.ESCAPE) {
            Lib.close();
        }
    }

    private function checkMouseEvents() : Void {
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

    private function sliderChanged(sliderName : String, newValue : Float) {
        dotsIllusion.sliderChanged(sliderName, newValue);
    }
}
