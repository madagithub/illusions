package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;

import openfl.Lib;

class PlayState extends FlxState
{
    private static var INFO_X : Float = 1462;
    private static var INFO_Y : Float = 1020;
    private static var INFO_WIDTH : Int = 83;
    private static var INFO_HEIGHT : Int = 83;

    override public function create() : Void {
        super.create();

        var background = new FlxSprite();
        background.loadGraphic("assets/images/background.png");
        add(background);

        var infoButton = new FlxButton(INFO_X - INFO_WIDTH / 2, INFO_Y - INFO_HEIGHT / 2, "", toggleInfo);
        infoButton.loadGraphic("assets/images/infoSpritesheet.png", true, INFO_WIDTH, INFO_HEIGHT);
        add(infoButton);

        var dotsIllusion = new DotsIllusion(this);
    }

    override public function onFocusLost() : Void {
    }

    override public function onFocus() : Void {
    }

    override public function update(elapsed : Float) : Void {
        checkExitKey();

        super.update(elapsed);
    }

    private function toggleInfo() : Void {

    }

    private function checkExitKey() : Void {
        if (FlxG.keys.enabled && FlxG.keys.pressed.ESCAPE) {
            Lib.close();
        }
    }
}
