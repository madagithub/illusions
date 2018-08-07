package illusions;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;

import config.ConfigData;

using flixel.util.FlxSpriteUtil;

class DotsIllusion implements Illusion {
	
	private static var DOTS_POSITIONS : Array<FlxPoint> = [
		new FlxPoint(-300, -150),
		new FlxPoint(300, -150),
		new FlxPoint(0, 300)
	];

	private var state : PlayState;
	private var background : DotsIllusionBackground;
	private var dotsAndCrossCanvas : FlxSprite;

	private var dotsSize : Int;
	private var degreesPerSecond : Float;

	private var lastDotsSize : Int;
	private var lastDegreesPerSecond : Float;

	private var backgroundRotationTween : FlxTween;

    private var config : DotsConfig;

	public function new(state : PlayState, config : DotsConfig) : Void {
		this.state = state;
        this.config = config;
		this.background = new DotsIllusionBackground(this.config.width, this.config.height);
        this.background.setCenter(this.config.x, this.config.y);
        state.add(this.background);

        // Create and position dots and cross canvas
        this.dotsAndCrossCanvas = new FlxSprite();
        this.dotsAndCrossCanvas.makeGraphic(this.config.width, this.config.height, FlxColor.TRANSPARENT, true);
        this.dotsAndCrossCanvas.x = this.config.x - this.config.width / 2;
        this.dotsAndCrossCanvas.y = this.config.y - this.config.height / 2;

        this.state.add(this.dotsAndCrossCanvas);
    }

    public function update(elapsed : Float) {}

    public function stop() : Void {
    	this.lastDotsSize = this.dotsSize;
    	this.lastDegreesPerSecond = this.degreesPerSecond;

    	// Note: Changing attributes directly and refreshing, as this is a bypass sliders mechanism,
    	// so no need to do any sliderChanged calls!
        this.dotsSize = this.config.stopDotSize;
        this.redraw();

        this.degreesPerSecond = this.config.stopSpeed;
        this.updateBackgroundRotation();
    }

    public function start() : Void {
        this.dotsSize = this.lastDotsSize;
        this.redraw();

        this.degreesPerSecond = this.lastDegreesPerSecond;
        this.updateBackgroundRotation();	
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	if (name == "slider1") {
    		this.dotsSize = Std.int(value);
    		this.lastDotsSize = this.dotsSize;
    		this.redraw();
    	} else if (name == "slider2") {
    		this.degreesPerSecond = value;
    		this.lastDegreesPerSecond = this.degreesPerSecond;
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
        this.dotsAndCrossCanvas.drawLine(this.config.width / 2 - this.config.crossSize  / 2, this.config.height / 2, 
        	this.config.width / 2 + this.config.crossSize  / 2, this.config.height / 2, corssLineStyle);
        this.dotsAndCrossCanvas.drawLine(this.config.width / 2, this.config.height / 2 - this.config.crossSize / 2, 
        	this.config.width / 2, this.config.height / 2 + this.config.crossSize / 2, corssLineStyle);
    }

    private function drawDots() {
    	for (dot in DOTS_POSITIONS) {
        	drawCircleWithCenterAndRadius(this.dotsAndCrossCanvas, new FlxPoint(this.config.width / 2, this.config.height / 2), dot, this.dotsSize);
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