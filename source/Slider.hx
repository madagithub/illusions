package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

typedef Arch = {
	sprite : FlxSprite,
	value : Float
}

class Slider {
	private static var MIN_ARCH_WIDTH : Int = 10;
	private static var MAX_ARCH_WIDTH : Int = 60;
	private static var SLIDER_TRIANGLE_Y : Int = 43;

	private var state : FlxState;
	private var name : String;
	private var boundingRect : FlxRect;
	private var onSliderValueChanged : String->Float->Void;
	private var limitValue : Float;
	private var isDragging : Bool = false;
	private var sliderHandle : FlxSprite;
	private var archs : Array<Arch> = new Array<Arch>();
	private var selectedArch : Arch = null;

	public function new(state : FlxState, name : String, boundingRect : FlxRect, onSliderValueChanged : String->Float->Void, minValue : Float, maxValue : Float, archDiff : Float, startValue : Float, limitValue: Float) : Void {
		this.state = state;
		this.name = name;
		this.boundingRect = boundingRect;
		this.limitValue = limitValue;
		this.onSliderValueChanged = onSliderValueChanged;

		// Render archs
		var currArchPosition : FlxPoint = new FlxPoint(boundingRect.left + boundingRect.width / 2, boundingRect.bottom);
		var currArchValue : Float = minValue;
		var archsNum : Int = Std.int((maxValue - minValue) / archDiff);
		var yArchDiff : Float = boundingRect.height / archsNum;
		var archWidthDiff : Float = (MAX_ARCH_WIDTH - MIN_ARCH_WIDTH) / (archsNum - 1);
		var currArchWidth : Float = MIN_ARCH_WIDTH;

		for (i in 0...archsNum) {
			var archSprite : FlxSprite = new FlxSprite();
			var newArch : Arch = { sprite: archSprite, value: currArchValue };
			this.setArchAsset(newArch, startValue);

			archSprite.x = currArchPosition.x - currArchWidth;
			archSprite.y = currArchPosition.y - archSprite.height / 2;
			archSprite.scale.set(currArchWidth / archSprite.width, 1);
			this.state.add(archSprite);

			if (newArch.value == startValue) {
				// Render slider handle
				this.sliderHandle = new FlxSprite();
				this.sliderHandle.loadGraphic("assets/images/slider.png");
				this.sliderHandle.x = currArchPosition.x;
				this.sliderHandle.y = newArch.sprite.y - SLIDER_TRIANGLE_Y;
				this.state.add(sliderHandle);
				this.selectedArch = newArch;
			}

			currArchWidth += archWidthDiff;
			currArchPosition.y -= yArchDiff;
			currArchValue += archDiff;

			archs.push(newArch);
		}
	}

	public function mouseDown(position : FlxPoint) {
		if (boundingRect.containsPoint(position)) {
			this.isDragging = true;
			sliderHandle.loadGraphic("assets/images/sliderPressed.png");
			this.snapToPosition(position);
		}
	}

	public function mouseUp(position : FlxPoint) {
		this.updateSliderImage(position);

		// Send new value event, should happen only on mouse up if it was dragging!
		// Note: A click is also a drag without a move, so will work for a click as well
		if (this.isDragging) {
			this.onSliderValueChanged(this.name, this.selectedArch.value);
		}

		this.isDragging = false;
	}

	public function mouseMove(position : FlxPoint) {
		if (this.isDragging) {
			this.snapToPosition(position);
		} else {
			this.updateSliderImage(position);	
		}
	}

	private function snapToPosition(position : FlxPoint) {
		// Search closest arch
		var currMinDist : Float = FlxG.height;
		var currMinArch : Arch = null;
		for (arch in this.archs) {
			var dist : Float = arch.sprite.getPosition().distanceTo(position);
			if (dist < currMinDist) {
				currMinArch = arch;
				currMinDist = dist;
			}
		}

		this.snapToArch(currMinArch);
	}

	private function snapToArch(arch : Arch) {
		if (this.selectedArch != null) {
			this.setArchAsset(this.selectedArch, arch.value);
		}
		this.setArchAsset(arch, arch.value);
		this.selectedArch = arch;

		this.sliderHandle.y = arch.sprite.y - SLIDER_TRIANGLE_Y;
	}

	private function updateSliderImage(position : FlxPoint) {
		if (boundingRect.containsPoint(position)) {
			this.sliderHandle.loadGraphic("assets/images/sliderHover.png");
		} else {
			this.sliderHandle.loadGraphic("assets/images/slider.png");
		}
	}

	private function setArchAsset(arch : Arch, currValue : Float) {
		// Note: if value is the selected value, it will show a current line graphics,
		// only if not the selected value and is the limit value, it will show a limit value graphics
		if (arch.value == currValue) {
			arch.sprite.loadGraphic("assets/images/currentLine.png");
		} else if (arch.value == this.limitValue) {
			arch.sprite.loadGraphic("assets/images/limitLine.png");
		} else {
			arch.sprite.loadGraphic("assets/images/regularLine.png");
		}
	}
}