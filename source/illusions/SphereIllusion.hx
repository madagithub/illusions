package illusions;

import Random;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxSpriteUtil;

typedef DotInfo = {
    dot : FlxSprite,
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

	private static var DOT_RADIUS : Int = 10;

	private var state : FlxState;

    private var dotInfos : Array<DotInfo>;

	private var dotsNum : Int;
	private var dotsSpeed : Float;

	private var lastDotsNum : Int;
	private var lastDegreesPerSecond : Float;

	private var backgroundRotationTween : FlxTween;

	public function new(state : FlxState) : Void {
		this.state = state;

        this.dotsNum = START_DOTS_NUM;
        this.lastDotsNum = this.dotsNum;

        this.dotsSpeed = DEGREES_PER_SECOND;
        this.lastDegreesPerSecond = this.dotsSpeed;

        this.dotInfos = new Array<DotInfo>();
        this.createDots();

        this.updateDotsSpeed();
    }

    public function stop() : Void {
    	this.lastDotsNum = this.dotsNum;
    	this.lastDegreesPerSecond = this.dotsSpeed;

    	// Note: Changing attributes directly and refreshing, as this is a bypass sliders mechanism,
    	// so no need to do any sliderChanged calls!
        this.dotsNum = STOP_DOTS_NUM;
        this.setVisibleDots();

        this.dotsSpeed = STOP_SPEED;
    }

    public function start() : Void {
        this.dotsNum = this.lastDotsNum;
        this.setVisibleDots();

        this.dotsSpeed = this.lastDegreesPerSecond;
        this.updateDotsSpeed();	
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	if (name == "slider1") {
    		this.dotsNum = Std.int(value);
    		this.lastDotsNum = this.dotsNum;
    		this.setVisibleDots();
    	} else if (name == "slider2") {
    		this.dotsSpeed = value;
    		this.lastDegreesPerSecond = this.dotsSpeed;
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
            var dot : FlxSprite = this.drawDot(Math.cos(radians) * ILLUSION_WIDTH / 2 + ILLUSION_X, Math.sin(Math.PI * 2 / this.dotsNum * i) * ILLUSION_WIDTH / 2 + ILLUSION_Y);
            this.dotInfos.push({
                dot: dot,
                width: Math.cos(Math.PI * 2 / this.dotsNum * i) * ILLUSION_WIDTH / 2,
                radians: Random.float(0, Math.PI * 2)
            });
            //FlxTween.tween(dot, {x: ILLUSION_X - Math.cos(Math.PI*2 / this.dotsNum * i) * ILLUSION_WIDTH / 2}, DEGREES_PER_SECOND, {type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, startDelay: Random.float(0, 1)});
        }
        Random.shuffle(this.dotInfos);
/*
        stop();
var ii:Number = Math.abs(_x)*random(1000)/1000;
var scale:Number = Math.abs(_x);

function onEnterFrame() {
    _x = Math.sin(ii)*scale;
    ii += _parent.s;

    
}*/
        /*for (var i = 0; i<total; i++) {
            var y:Number = Math.sin(i)*size/2;
            var x:Number = Math.cos(i)*size/2;
            var _mc:MovieClip = _this.attachMovie("dot_mc", "dot"+i, i, {_x:x, _y:y, i:i});
            mcs.push(_mc);
            vMcs.push(_mc);
        }*/
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

    private function redraw() {
    	
    }

    private function updateDotsSpeed() {
        for (i in 0...this.dotsNum) {

        }

    	// Stop current animation if exists
    	/*if (this.backgroundRotationTween != null) {
    		this.backgroundRotationTween.cancel();
    		this.backgroundRotationTween = null;
    	}

    	// Start background infinite spin
    	if (this.dotsSpeed != 0) {
		    this.backgroundRotationTween = FlxTween.angle(this.background, this.background.angle, 
		    	background.angle + (this.dotsSpeed > 0 ? 360 : -360), 360 / Math.abs(this.degreesPerSecond), { type: FlxTween.LOOPING});
		}*/
    }
}