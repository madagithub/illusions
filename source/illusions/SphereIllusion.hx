package illusions;

import Random;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import config.ConfigData;

using flixel.util.FlxSpriteUtil;

typedef DotInfo = {
    dot : FlxSprite,
    y : Float,
    width : Float,
    radians : Float
}

class SphereIllusion implements Illusion {

	private var state : PlayState;

    private var dotInfos : Array<DotInfo>;

	private var dotsNum : Int;
	private var dotsSpeed : Float;

    private var lastDotsNum : Int;
	private var lastDotsSpeed : Float;

	private var backgroundRotationTween : FlxTween;

    private var maxDotsNum : Int;

    private var config : SphereConfig;

	public function new(state : PlayState, illusionData : IllusionData) : Void {
		this.state = state;
        this.config = illusionData.sphereConfig;

        this.maxDotsNum = Std.int(illusionData.sliders[0].max);

        this.dotInfos = new Array<DotInfo>();
        this.createDots();
    }

    public function stop() : Void {
    	this.lastDotsSpeed = this.dotsSpeed;
        this.dotsSpeed = this.config.stopSpeed;

        this.lastDotsNum = this.dotsNum;
        this.dotsNum = this.config.stopDotsNum;
        this.setVisibleDots();
    }

    public function start() : Void {
        this.dotsSpeed = this.lastDotsSpeed;

        this.dotsNum = this.lastDotsNum;
        this.setVisibleDots();
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	if (name == "slider1") {
    		this.dotsNum = Std.int(value);
    		this.setVisibleDots();
            trace("Visible dots: " + this.dotsNum);
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
            dotInfo.dot.x = Math.cos(dotInfo.radians) * dotInfo.width + this.config.x;

            // Apply angle transformation along circle center
            var angle : Float = 15 / 360 * 2 * Math.PI;
            dotInfo.dot.x = this.config.x + (dotInfo.dot.x - this.config.x) * Math.cos(angle) - (dotInfo.y - this.config.y) * Math.sin(angle);
            dotInfo.dot.y = this.config.y + (dotInfo.y - this.config.y) * Math.cos(angle) + (dotInfo.dot.x - this.config.x) * Math.sin(angle);
        }
    }

    private function setVisibleDots() {
        for (i in 0...this.maxDotsNum) {
            this.dotInfos[i].dot.visible = (i < this.dotsNum);
        }
    }

    private function createDots() {
        for (i in 0...this.maxDotsNum) {

            var radians = Random.float(0, Math.PI * 2);
            var dotY : Float = Math.sin(Math.PI * 2 / this.maxDotsNum * i) * this.config.width / 2 + this.config.y;
            var dot : FlxSprite = this.drawDot(Math.cos(radians) * this.config.width / 2 + this.config.x, dotY);
            this.dotInfos.push({
                dot: dot,
                y: dotY,
                width: Math.cos(Math.PI * 2 / this.maxDotsNum * i) * this.config.width / 2,
                radians: Random.float(0, Math.PI * 2)
            });
        }

        Random.shuffle(this.dotInfos);
    }

    private function drawDot(x : Float, y : Float) : FlxSprite {
        var dot : FlxSprite = new FlxSprite();
        dot.makeGraphic(this.config.dotSize * 2, this.config.dotSize * 2, FlxColor.TRANSPARENT, true);
        dot.x = x;
        dot.y = y;
        dot.drawCircle(this.config.dotSize, this.config.dotSize, this.config.dotSize, FlxColor.WHITE);
        this.state.add(dot);
        return dot;
    }
}