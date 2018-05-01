package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.math.FlxRect;

import openfl.Lib;

class PlayState extends FlxState
{
    private static var INFO_X : Float = 1462;
    private static var INFO_Y : Float = 1020;
    private static var INFO_WIDTH : Int = 83;
    private static var INFO_HEIGHT : Int = 83;

    private var slider : Slider;

    private var dotsIllusion : DotsIllusion;

    override public function create() : Void {
        super.create();

        var background = new FlxSprite();
        background.loadGraphic("assets/images/background.png");
        add(background);

        var infoButton = new FlxButton(INFO_X - INFO_WIDTH / 2, INFO_Y - INFO_HEIGHT / 2, "", toggleInfo);
        infoButton.loadGraphic("assets/images/infoSpritesheet.png", true, INFO_WIDTH, INFO_HEIGHT);
        add(infoButton);

        this.dotsIllusion = new DotsIllusion(this);

        // Create sliders
        slider = new Slider(this, "slider1", new FlxRect(100/*1400*/, 100/*425*/, 100, 420), this.sliderChanged, 1, 30, 1, 3, 5);
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

    private function toggleInfo() : Void {

    }

    private function checkExitKey() : Void {
        if (FlxG.keys.enabled && FlxG.keys.pressed.ESCAPE) {
            Lib.close();
        }
    }

    private function checkMouseEvents() : Void {
        slider.mouseMove(FlxG.mouse.getScreenPosition());

        if (FlxG.mouse.justPressed) {
            slider.mouseDown(FlxG.mouse.getScreenPosition());
        }

        if (FlxG.mouse.justReleased) {
            slider.mouseUp(FlxG.mouse.getScreenPosition());
        }
    }

    private function sliderChanged(sliderName : String, newValue : Float) {
        trace("Name: " + sliderName + ", Value: " + newValue);
        dotsIllusion.sliderChanged(sliderName, newValue);
    }
}
