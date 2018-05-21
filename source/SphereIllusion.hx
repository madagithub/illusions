package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;

using flixel.util.FlxSpriteUtil;

class SphereIllusion implements Illusion {
	private static var ILLUSION_WIDTH : Int = 900;
    private static var ILLUSION_HEIGHT : Int = 900;

    private static var ILLUSION_X : Int = 670;
    private static var ILLUSION_Y : Int = 570;

    private static var START_DOTS_NUM : Int = 200;

    private static var STOP_SPEED : Float = 0;
    private static var STOP_DOTS_NUM : Int = 15;

	private static var DOTS_RADIUS : Int = 10;

	private var state : FlxState;

	private var dotsNum : Int;
	private var degreesPerSecond : Float;

	private var lastDotsNum : Int;
	private var lastDegreesPerSecond : Float;

	private var backgroundRotationTween : FlxTween;

	public function new(state : FlxState) : Void {
		this.state = state;

        this.dotsNum = START_DOTS_NUM;
        this.lastDotsNum = this.dotsNum;

        this.degreesPerSecond = DEGREES_PER_SECOND;
        this.lastDegreesPerSecond = this.degreesPerSecond;

        this.updateDotsSpeed();
    }

    public function stop() : Void {
    	/*this.lastDotsSize = this.dotsSize;
    	this.lastDegreesPerSecond = this.degreesPerSecond;

    	// Note: Changing attributes directly and refreshing, as this is a bypass sliders mechanism,
    	// so no need to do any sliderChanged calls!
        this.dotsSize = STOP_DOT_SIZE;
        this.redraw();

        this.degreesPerSecond = STOP_SPEED;
        this.updateDotsSpeed();*/
    }

    public function start() : Void {
        /*this.dotsSize = this.lastDotsSize;
        this.redraw();

        this.degreesPerSecond = this.lastDegreesPerSecond;
        this.updateDotsSpeed();	*/
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	/*if (name == "slider1") {
    		this.dotsSize = Std.int(value);
    		this.lastDotsSize = this.dotsSize;
    		this.redraw();
    	} else if (name == "slider2") {
    		this.degreesPerSecond = value;
    		this.lastDegreesPerSecond = this.degreesPerSecond;
    		this.updateDotsSpeed();
    	}*/
    }

    private function redraw() {
    	
    }

    private function updateDotsSpeed() {
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