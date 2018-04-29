package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;

class DotsIllusion {
	private static var ILLUSION_WIDTH : Int = 900;
    private static var ILLUSION_HEIGHT : Int = 900;

    private static var ILLUSION_X : Int = 670;
    private static var ILLUSION_Y : Int = 570;

    private static var FULL_CIRCLE_ROTATION_SECONDS : Int = 12;

    private static var CROSS_SIZE : Int = 40;

	private static var DOTS_RADIUS : Int = 20;
	private static var DOTS_POSITIONS : Array<FlxPoint> = [
		new FlxPoint(-300, -150),
		new FlxPoint(300, -150),
		new FlxPoint(0, 300)
	];

	private var state : FlxState;

	public function new(state : FlxState) : Void {
		this.state = state;
		var background = new DotsIllusionBackground(ILLUSION_WIDTH, ILLUSION_HEIGHT);
        background.setCenter(ILLUSION_X, ILLUSION_Y);
        state.add(background);

        // Create dots
        var canvas : FlxSprite = new FlxSprite();
        canvas.makeGraphic(ILLUSION_WIDTH, ILLUSION_HEIGHT, FlxColor.TRANSPARENT, true);

        // Draw cross
        var corssLineStyle : LineStyle = { color : FlxColor.GRAY, thickness : 2 };
        canvas.drawLine(ILLUSION_WIDTH / 2 - CROSS_SIZE  / 2, ILLUSION_HEIGHT / 2, 
        	ILLUSION_WIDTH / 2 + CROSS_SIZE  / 2, ILLUSION_HEIGHT / 2, corssLineStyle);
        canvas.drawLine(ILLUSION_WIDTH / 2, ILLUSION_HEIGHT / 2 - CROSS_SIZE / 2, 
        	ILLUSION_WIDTH / 2, ILLUSION_HEIGHT / 2 + CROSS_SIZE / 2, corssLineStyle);

        canvas.x = ILLUSION_X - ILLUSION_WIDTH / 2;
        canvas.y = ILLUSION_Y - ILLUSION_HEIGHT / 2;
        for (dot in DOTS_POSITIONS) {
        	drawCircleWithCenterAndRadius(canvas, new FlxPoint(ILLUSION_WIDTH / 2, ILLUSION_HEIGHT / 2), dot, DOTS_RADIUS);
        }
        this.state.add(canvas);

        // Start background infinite spin
        FlxTween.angle(background, 0, 360, FULL_CIRCLE_ROTATION_SECONDS, { type: FlxTween.LOOPING});
    }

    private function drawCircleWithCenterAndRadius(canvas : FlxSprite, center : FlxPoint, diff : FlxPoint, radius : Float) {
    	canvas.drawCircle(center.x + diff.x, center.y + diff.y, radius, FlxColor.WHITE);
    }
}