package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class Slider {
	private static var MIN_ARCH_WIDTH : Int = 10;
	private static var MAX_ARCH_WIDTH : Int = 60;
	private static var SLIDER_TRIANGLE_Y : Int = 43;

	private var state : FlxState;
	private var limitValue : Float;
	private var isDragging : Bool = false;
	private var lastY : Float;
	private var sliderHandle : FlxSprite;
	private var archValues : Array<Float> = new Array<Float>();

	public function new(state : FlxState, boundingRect : FlxRect, onSliderValueChanged : Float->Void, minValue : Float, maxValue : Float, archDiff : Float, startValue : Float, limitValue: Float) : Void {
		this.state = state;
		this.limitValue = limitValue;

		// Render archs
		var currArchPosition : FlxPoint = new FlxPoint(boundingRect.left + boundingRect.width / 2, boundingRect.bottom);
		var currArchValue : Float = startValue;
		var archsNum : Int = Std.int((maxValue - minValue) / archDiff);
		var yArchDiff : Float = boundingRect.height / archsNum;
		var archWidthDiff : Float = (MAX_ARCH_WIDTH - MIN_ARCH_WIDTH) / (archsNum - 1);
		var currArchWidth : Float = MIN_ARCH_WIDTH;

		for (i in 0...archsNum) {
			var arch : FlxSprite = new FlxSprite();
			arch.loadGraphic(getArchAsset(currArchValue, startValue));

			arch.x = currArchPosition.x - currArchWidth;
			arch.y = currArchPosition.y - arch.height / 2;
			arch.scale.set(currArchWidth / arch.width, 1);
			this.state.add(arch);

			if (currArchValue == startValue) {
				// Render slider handle
				sliderHandle = new FlxSprite();
				sliderHandle.loadGraphic("assets/images/slider.png");
				sliderHandle.x = currArchPosition.x;
				sliderHandle.y = arch.y - SLIDER_TRIANGLE_Y;
				this.state.add(sliderHandle);
			}

			currArchWidth += archWidthDiff;
			currArchPosition.y -= yArchDiff;
			currArchValue += archDiff;
			archValues.push(currArchValue);
		}
	}

	public function mouseDown(position : FlxPoint) {
		if (sliderHandle.getHitbox().containsPoint(position)) {
			this.isDragging = true;
			this.lastY = position.y;
			sliderHandle.loadGraphic("assets/images/sliderPressed.png");
		}
	}

	public function mouseUp(position : FlxPoint) {
		this.updateSliderImage(position);
		this.isDragging = false;
		this.snapToPosition();
	}

	public function mouseMove(position : FlxPoint) {
		if (this.isDragging) {
			sliderHandle.y += position.y - this.lastY;
			this.lastY = position.y;
		} else {
			this.updateSliderImage(position);	
		}
	}

	private function updateSliderImage(position : FlxPoint) {
		if (sliderHandle.getHitbox().containsPoint(position)) {
			sliderHandle.loadGraphic("assets/images/sliderHover.png");
		} else {
			sliderHandle.loadGraphic("assets/images/slider.png");
		}
	}

	private function getArchAsset(archValue : Float, currValue : Float) : String {
		// Note: if value is the selected value, it will show a current line graphics,
		// only if not the selected value and is the limit value, it will show a limit value graphics
		if (archValue == currValue) {
			return "assets/images/currentLine.png";
		} else if (archValue == this.limitValue) {
			return "assets/images/limitLine.png";
		} else {
			return "assets/images/regularLine.png";
		}
	}
}