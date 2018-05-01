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

    private static var DEGREES_PER_SECOND : Float = 360 / 12;

    private static var CROSS_SIZE : Int = 40;

	private static var DOTS_RADIUS : Int = 20;
	private static var DOTS_POSITIONS : Array<FlxPoint> = [
		new FlxPoint(-300, -150),
		new FlxPoint(300, -150),
		new FlxPoint(0, 300)
	];

	private var state : FlxState;
	private var background : DotsIllusionBackground;
	private var dotsAndCrossCanvas : FlxSprite;
	private var dotsSize : Int;
	private var degreesPerSecond : Float;
	private var backgroundRotationTween : FlxTween;

	public function new(state : FlxState) : Void {
		this.state = state;
		this.background = new DotsIllusionBackground(ILLUSION_WIDTH, ILLUSION_HEIGHT);
        this.background.setCenter(ILLUSION_X, ILLUSION_Y);
        state.add(this.background);

        // Create and position dots and cross canvas
        this.dotsAndCrossCanvas = new FlxSprite();
        this.dotsAndCrossCanvas.makeGraphic(ILLUSION_WIDTH, ILLUSION_HEIGHT, FlxColor.TRANSPARENT, true);
        this.dotsAndCrossCanvas.x = ILLUSION_X - ILLUSION_WIDTH / 2;
        this.dotsAndCrossCanvas.y = ILLUSION_Y - ILLUSION_HEIGHT / 2;

        this.dotsSize = DOTS_RADIUS;

        this.drawCross();
        this.drawDots();

        this.state.add(this.dotsAndCrossCanvas);

        this.degreesPerSecond = DEGREES_PER_SECOND;

        this.updateBackgroundRotation();
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	if (name == "slider1") {
    		this.dotsSize = Std.int(value);
    		this.redraw();
    	} else if (name == "slider2") {
    		this.degreesPerSecond = value;
    		this.updateBackgroundRotation();
    	}
    }

    private function redraw() {
    	// Remove all previous drawings
    	this.dotsAndCrossCanvas.fill(FlxColor.TRANSPARENT);

    	this.drawCross();
    	this.drawDots();
    }

    private function drawCross() {
        var corssLineStyle : LineStyle = { color : FlxColor.GRAY, thickness : 2 };
        this.dotsAndCrossCanvas.drawLine(ILLUSION_WIDTH / 2 - CROSS_SIZE  / 2, ILLUSION_HEIGHT / 2, 
        	ILLUSION_WIDTH / 2 + CROSS_SIZE  / 2, ILLUSION_HEIGHT / 2, corssLineStyle);
        this.dotsAndCrossCanvas.drawLine(ILLUSION_WIDTH / 2, ILLUSION_HEIGHT / 2 - CROSS_SIZE / 2, 
        	ILLUSION_WIDTH / 2, ILLUSION_HEIGHT / 2 + CROSS_SIZE / 2, corssLineStyle);
    }

    private function drawDots() {
    	for (dot in DOTS_POSITIONS) {
        	drawCircleWithCenterAndRadius(this.dotsAndCrossCanvas, new FlxPoint(ILLUSION_WIDTH / 2, ILLUSION_HEIGHT / 2), dot, this.dotsSize);
        }
    }

    private function drawCircleWithCenterAndRadius(canvas : FlxSprite, center : FlxPoint, diff : FlxPoint, radius : Float) {
    	canvas.drawCircle(center.x + diff.x, center.y + diff.y, radius, FlxColor.WHITE);
    }

    private function updateBackgroundRotation() {
    	// Stop current animation if exists
    	if (this.backgroundRotationTween != null) {
    		this.backgroundRotationTween.cancel();
    		this.backgroundRotationTween = null;
    	}

    	// Start background infinite spin
    	if (this.degreesPerSecond != 0) {
		    this.backgroundRotationTween = FlxTween.angle(this.background, this.background.angle, 
		    	background.angle + (this.degreesPerSecond > 0 ? 360 : -360), 360 / Math.abs(this.degreesPerSecond), { type: FlxTween.LOOPING});
		}
    }
}