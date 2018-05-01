package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class DotsIllusionBackground extends FlxSprite {
    private static var ILLUSION_RADIUS_DIFF : Int = -70;
    private static var ILLUSION_END_RADIUS : Int = 420;
    private static var CIRCLES_NUM : Int = 6;
    private static var LINES_NUM : Int = 40;

    private var illusionWidth : Int;
    private var illusionHeight : Int;

    private var lineStyle: LineStyle = { color: FlxColor.GRAY, thickness: 2 };
	private var drawStyle: DrawStyle = { smoothing: false };

	public function new(illusionWidth : Int, illusionHeight : Int) : Void {
        super();

        this.illusionWidth = illusionWidth;
        this.illusionHeight = illusionHeight;

        this.makeGraphic(this.illusionWidth, this.illusionHeight, FlxColor.TRANSPARENT, true);

        // Draw circles
        var currRadius : Int = ILLUSION_END_RADIUS;
        for (i in 0...CIRCLES_NUM) {
        	this.drawCircleWithRadius(currRadius);
        	currRadius += ILLUSION_RADIUS_DIFF;
        }

        // Draw lines
        var currRadian : Float = 0;
        var radianDiff : Float = 2 * Math.PI / LINES_NUM;
        for (i in 0...LINES_NUM) {
        	this.drawCuttingLine(currRadian);
        	currRadian += radianDiff;
        }
    }

    public function setCenter(x : Float, y : Float) {
    	this.x = x - this.illusionWidth / 2;
    	this.y = y - this.illusionHeight / 2;
    }

    //TODO: Shoudl be a util?
    private function drawCircleWithRadius(radius : Float) {
    	this.drawCircle(this.illusionWidth / 2, this.illusionHeight / 2, radius, FlxColor.TRANSPARENT, this.lineStyle, this.drawStyle);
    }

    private function drawCuttingLine(radian : Float) {
    	trace(radian);

    	var centerX : Float = this.illusionWidth / 2;
    	var centerY : Float = this.illusionHeight / 2;

    	var minRadius : Float = ILLUSION_END_RADIUS + ILLUSION_RADIUS_DIFF * (CIRCLES_NUM - 1);
    	var maxRadius : Float = ILLUSION_END_RADIUS;

    	var startX : Float = centerX + Math.cos(radian) * minRadius;
    	var startY : Float = centerY + Math.sin(radian) * minRadius;

    	var endX : Float = centerX + Math.cos(radian) * maxRadius;
    	var endY : Float = centerY + Math.sin(radian) * maxRadius;

    	this.drawLine(startX, startY, endX, endY, this.lineStyle);
    }
}