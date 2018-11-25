package utils;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class Utils {
	static public function drawDot(x : Float, y : Float, dotSize : Int, state : FlxState) : FlxSprite {
        var dot : FlxSprite = new FlxSprite();

        dot.makeGraphic(dotSize * 2, dotSize * 2, FlxColor.TRANSPARENT, true);
        dot.x = x;
        dot.y = y;
        dot.drawCircle(dotSize, dotSize, dotSize, FlxColor.WHITE);
        state.add(dot);

        return dot;
    }
}