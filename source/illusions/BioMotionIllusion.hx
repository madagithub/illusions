package illusions;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import openfl.Assets;

import config.ConfigData;

using flixel.util.FlxSpriteUtil;

class BioMotionIllusion implements Illusion {

    private var state : PlayState;

	private var dotsNum : Int;
    private var animationDotsNum : Int;
    private var framesNum : Int;
	private var dotsSpeed : Float;

    private var lastDotsNum : Int;
	private var lastDotsSpeed : Float;
    private var timeUntilNextFrame : Float;

    private var currAnimation : Int;

    private var currFrame : Int;
    private var isMiddleFrame : Bool;
    private var dots : Array<FlxSprite>;
    private var animationValues : Array<Int>;

    private var config : BioMotionConfig;

	public function new(state : PlayState, config : BioMotionConfig) : Void {
		this.state = state;
        this.config = config;

        this.dots = new Array<FlxSprite>();
        this.animationValues = new Array<Int>();

        this.currAnimation = this.config.startAnimationIndex;
        this.loadAnimation();
        this.isMiddleFrame = false;

        var nextButton = new FlxButton(this.config.nextButtonX, this.config.nextButtonY, "", this.nextAnimation);
        nextButton.loadGraphic("assets/images/" + this.config.nextButtonSpritesheet + ".png", true, this.config.nextButtonWidth, this.config.nextButtonHeight);
        this.state.setButtonCursorReactive(nextButton);
        this.state.add(nextButton);

        var prevButton = new FlxButton(this.config.prevButtonX, this.config.prevButtonY, "", this.prevAnimation);
        prevButton.loadGraphic("assets/images/" + this.config.prevButtonSpritesheet + ".png", true, this.config.prevButtonWidth, this.config.prevButtonHeight);
        this.state.setButtonCursorReactive(prevButton);
        this.state.add(prevButton);
    }

    public function stop() : Void {
        this.lastDotsNum = this.dotsNum;
        this.dotsNum = this.config.stopDotsNum;
        this.setVisibleDots();

    	this.lastDotsSpeed = this.dotsSpeed;
        this.dotsSpeed = this.config.stopSpeed;
    }

    public function start() : Void {
        this.dotsNum = this.lastDotsNum;
        this.setVisibleDots();

        this.dotsSpeed = this.lastDotsSpeed;
        this.timeUntilNextFrame = 1 / this.dotsSpeed;
    }

    public function sliderChanged(name : String, value : Float) {
    	//TODO: Constants for slider names!
    	if (name == "slider1") {
    		this.dotsNum = Std.int(value);
    		this.setVisibleDots();
    	} else if (name == "slider2") {
    		this.dotsSpeed = value;
    		this.lastDotsSpeed = this.dotsSpeed;

            // NOTE: When dotSpeed is 0, time will be inf, which is desired!
            this.timeUntilNextFrame = 1 / this.dotsSpeed;
    	}
    }

    public function update(elapsed : Float) {
        // NOTE: If time is inf, it will never reach the next frame, as desired!
        this.timeUntilNextFrame -= elapsed;
        if (this.timeUntilNextFrame <= 0) {
            if (this.isMiddleFrame) {
                this.isMiddleFrame = false;
                this.currFrame = (this.currFrame + 1) % this.framesNum;
            } else {
                this.isMiddleFrame = true;
            }
            this.loadFrame();
            this.timeUntilNextFrame += 1 / this.dotsSpeed;
        }
    }

    // IMPORTANT : Rendering Technique
    //================================
    // If each frame was played just as is, movement wasn't smooth.
    // To smooth the animation, another frame is entered between two frames, which is the average of the x and y of the edge frames.
    // So, before going to next frame, we first set the isMiddleFrame and calculate the middle distance to the next frame, and load that.
    // On the next frame, isMiddleFrame is set and so the frame moves to the next frame and isMiddleFrame goes back to not being set.
    // If a dot is on (0,0) it should not be displayed, and accordingly, middle frames towards 0 or from 0 are also not really displayed (instead, the current frame is repeated).
    private function loadFrame() {
        for (i in 0...this.dotsNum) {
            var dot : FlxSprite = this.dots[i];
            var xIndex : Int = this.currFrame * this.animationDotsNum * 2 + i * 2;
            var yIndex : Int = this.currFrame * this.animationDotsNum * 2 + i * 2 + 1;
            dot.x = this.animationValues[xIndex] * 1.5;
            dot.y = this.animationValues[yIndex] * 1.5;

            if (this.isMiddleFrame) {
                var nxIndex : Int = xIndex + this.animationDotsNum * 2;
                var nyIndex : Int = yIndex + this.animationDotsNum * 2;

                if (this.currFrame == this.framesNum - 1) {
                    nxIndex = i * 2;
                    nyIndex = i * 2 + 1;
                }

                var nx : Float = this.animationValues[nxIndex] * 1.5;
                var ny : Float = this.animationValues[nyIndex] * 1.5;

                if (dot.x != 0 && nx != 0) {
                    dot.x = (dot.x + nx) / 2;
                }

                if (dot.y != 0 && ny != 0) {
                    dot.y = (dot.y + ny) / 2;
                }
            }

            dot.visible = !(dot.x == 0 && dot.y == 0);

            dot.x += this.config.dotsOffsetX;
            dot.y += this.config.dotsOffsetY;
        }
    }

    // IMPORTANT: File sturcture
    //==========================
    // First row: number of dots
    // Second row: number of frmaes
    // ....
    // Followed by an integer per row, stating x, then y, of dots, then of the second frame of all dots, third, etc...
    // ....
    private function loadAnimation() {
        var filePath : String = "assets/data/animations/" + this.config.animationFileNames[this.currAnimation] + ".txt";
        var animationData : String = Assets.getText(filePath);
        var lines : Array<String> = animationData.split("\n");

        this.animationDotsNum = Std.parseInt(lines[0]);
        this.dotsNum = this.animationDotsNum;
        this.framesNum = Std.parseInt(lines[1]);

        this.animationValues = [];
        for (i in 2...lines.length) {
            this.animationValues.push(Std.parseInt(lines[i]));
        }

        for (dot in this.dots) {
            this.state.remove(dot);
        }

        this.dots = [];
        for (i in 0...this.animationDotsNum) {
            var dot : FlxSprite = this.drawDot(0, 0);
            this.dots.push(dot);
        }

        this.currFrame = 0;
        this.loadFrame();
    }

    private function nextAnimation() {
        this.currAnimation = (this.currAnimation + 1) % this.config.animationFileNames.length;
        this.loadAnimation();
    }

    private function prevAnimation() {
        this.currAnimation = (this.currAnimation - 1 + this.config.animationFileNames.length) % this.config.animationFileNames.length;
        this.loadAnimation();
    }

    private function setVisibleDots() {
        for (i in 0...this.dots.length) {
            this.dots[i].visible = (i < this.dotsNum);
        }
    }

    //TODO: Make super class (or utility function) for dots handling...
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