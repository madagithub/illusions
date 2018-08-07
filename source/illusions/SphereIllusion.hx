package illusions;

import Random;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxSpriteUtil;

typedef DotInfo = {
    dot : FlxSprite,
    y : Float,
    width : Float,
    radians : Float
}

class SphereIllusion implements Illusion {
	private static var ILLUSION_WIDTH : Int = 900;
    private static var ILLUSION_HEIGHT : Int = 900;

    private static var ILLUSION_X : Int = 670;
    private static var ILLUSION_Y : Int = 570;

    private static var TOTAL_DOTS_NUM : Int = 200;

    private static var START_DOTS_NUM : Int = 200;
    private static var DEGREES_PER_SECOND : Float = 360 / 12;

    private static var STOP_SPEED : Float = 0;
    private static var STOP_DOTS_NUM : Int = 100;

	private static var DOT_RADIUS : Int = 7;

	private var state : PlayState;

    private var dotInfos : Array<DotInfo>;

	private var dotsNum : Int;
	private var dotsSpeed : Float;

	private var lastDotsSpeed : Float;

	private var backgroundRotationTween : FlxTween;

	public function new(state : PlayState) : Void {
		this.state = state;

        this.dotsNum = START_DOTS_NUM;

        this.dotsSpeed = DEGREES_PER_SECOND;
        this.lastDotsSpeed = this.dotsSpeed;

        this.dotInfos = new Array<DotInfo>();
        this.createDots();
    }

    public function stop() : Void {
    	this.lastDotsSpeed = this.dotsSpeed;
        this.dotsSpeed = STOP_SPEED;
    }

    public function start() : Void {
        this.dotsSpeed = this.lastDotsSpeed;
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	if (name == "slider1") {
    		this.dotsNum = Std.int(value);
    		this.setVisibleDots();
    	} else if (name == "slider2") {
    		this.dotsSpeed = value;
    		this.lastDotsSpeed = this.dotsSpeed;
    	}
    }

    public function update(elapsed : Float) {
        this.positionDots(elapsed);
    }

    private function positionDots(elapsed : Float) {
        var radiansChanged : Float = this.dotsSpeed / 360 * 2 * Math.PI * elapsed;
        for (dotInfo in this.dotInfos) {
            dotInfo.radians += radiansChanged;
            dotInfo.dot.x = Math.cos(dotInfo.radians) * dotInfo.width + ILLUSION_X;

            // Apply angle transformation along circle center
            var angle : Float = 15 / 360 * 2 * Math.PI;
            dotInfo.dot.x = ILLUSION_X + (dotInfo.dot.x - ILLUSION_X) * Math.cos(angle) - (dotInfo.y - ILLUSION_Y) * Math.sin(angle);
            dotInfo.dot.y = ILLUSION_Y + (dotInfo.y - ILLUSION_Y) * Math.cos(angle) + (dotInfo.dot.x - ILLUSION_X) * Math.sin(angle);
        }
    }

    private function setVisibleDots() {
        for (i in 0...TOTAL_DOTS_NUM) {
            this.dotInfos[i].dot.visible = (i < this.dotsNum);
        }
    }

    private function createDots() {
        for (i in 0...TOTAL_DOTS_NUM) {

            var radians = Random.float(0, Math.PI * 2);
            var dotY : Float = Math.sin(Math.PI * 2 / this.dotsNum * i) * ILLUSION_WIDTH / 2 + ILLUSION_Y;
            var dot : FlxSprite = this.drawDot(Math.cos(radians) * ILLUSION_WIDTH / 2 + ILLUSION_X, dotY);
            this.dotInfos.push({
                dot: dot,
                y: dotY,
                width: Math.cos(Math.PI * 2 / this.dotsNum * i) * ILLUSION_WIDTH / 2,
                radians: Random.float(0, Math.PI * 2)
            });
        }

        Random.shuffle(this.dotInfos);
    }

    private function drawDot(x : Float, y : Float) : FlxSprite {
        var dot : FlxSprite = new FlxSprite();
        dot.makeGraphic(DOT_RADIUS * 2, DOT_RADIUS * 2, FlxColor.TRANSPARENT, true);
        dot.x = x;
        dot.y = y;
        dot.drawCircle(DOT_RADIUS, DOT_RADIUS, DOT_RADIUS, FlxColor.WHITE);
        this.state.add(dot);
        return dot;
    }
}