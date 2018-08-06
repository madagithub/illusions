package ui;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

typedef Arch = {
	sprite : FlxSprite,
	value : Float
}

enum CursorMode {
	OUT;
	ENTER;
	EXIT;
	OVER;
}

class Slider {

	public static var NO_VALUE : Int = -9999;

	private static var MIN_ARCH_WIDTH : Int = 10;
	private static var MAX_ARCH_WIDTH : Int = 60;
	private static var SLIDER_TRIANGLE_Y : Int = 43;
	private static var SLIDER_HANDLE_X_OFFSET : Int = -4;

	private var state : FlxState;
	private var name : String;
	private var boundingRect : FlxRect;
	private var onSliderValueChanged : String->Float->Float->Void;
	private var startValue : Float;
	private var limitValue : Float;
	private var isDragging : Bool = false;
	private var sliderHandle : FlxSprite;
	private var archs : Array<Arch> = new Array<Arch>();
	private var selectedArch : Arch = null;

	private var isLastMouseInSlider : Bool = false;

	public function new(state : FlxState, name : String, boundingRect : FlxRect, onSliderValueChanged : String->Float->Float->Void, minValue : Float, maxValue : Float, archDiff : Float, startValue : Float, limitValue: Float) : Void {
		this.state = state;
		this.name = name;
		this.startValue = startValue;
		this.limitValue = limitValue;
		this.onSliderValueChanged = onSliderValueChanged;

		// Render archs
		var currArchPosition : FlxPoint = new FlxPoint(boundingRect.left + boundingRect.width / 2, boundingRect.bottom);
		var currArchValue : Float = minValue;
		var archsNum : Int = Std.int((maxValue - minValue) / archDiff + 1);
		var yArchDiff : Float = boundingRect.height / (archsNum - 1);
		var archWidthDiff : Float = (MAX_ARCH_WIDTH - MIN_ARCH_WIDTH) / (archsNum - 1);
		var currArchWidth : Float = MIN_ARCH_WIDTH;

		for (i in 0...archsNum) {
			var archSprite : FlxSprite = new FlxSprite();
			var newArch : Arch = { sprite: archSprite, value: currArchValue };
			this.setArchAsset(newArch, startValue);

			var scaleX : Float = currArchWidth / archSprite.width;

			// NOTE: If scaling was done only to the right, we would just need to put the sprite in currArchPosition.x - currArchWidth
			// But since scaling scales both left and right, we will need to calculate the pixels added/removed and fix the position
			// by moving half of those added/removed pixels to the sprite position
			archSprite.x = currArchPosition.x - currArchWidth + (scaleX - 1) * archSprite.width / 2;
			archSprite.y = currArchPosition.y - archSprite.height / 2;

			archSprite.scale.set(scaleX, 1);
			this.state.add(archSprite);

			if (newArch.value == startValue) {
				// Render slider handle
				this.sliderHandle = new FlxSprite();
				this.sliderHandle.loadGraphic("assets/images/slider.png");
				this.sliderHandle.x = currArchPosition.x + SLIDER_HANDLE_X_OFFSET;
				this.sliderHandle.y = newArch.sprite.y - SLIDER_TRIANGLE_Y;
				this.state.add(sliderHandle);
				this.selectedArch = newArch;

				this.onSliderValueChanged(this.name, NO_VALUE, newArch.value);
			}

			currArchWidth += archWidthDiff;
			currArchPosition.y -= yArchDiff;
			currArchValue += archDiff;

			archs.push(newArch);
		}

		// Add part of handler that can move above and below archs as included in bounding rect
		// so it will react on mouse over even if on minimum or maximum arch
		this.boundingRect = new FlxRect(boundingRect.x, 
			boundingRect.y - SLIDER_TRIANGLE_Y, 
			boundingRect.width, 
			boundingRect.height + SLIDER_TRIANGLE_Y + (this.sliderHandle.height - SLIDER_TRIANGLE_Y));
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
		this.isDragging = false;
	}

	public function mouseMove(position : FlxPoint) : CursorMode {
		var isMouseInSlider : Bool = false;

		if (this.isDragging) {
			this.snapToPosition(position);
			isMouseInSlider = true;
		} else {
			isMouseInSlider = this.updateSliderImage(position);	
		}

		var result : CursorMode = OUT;
		if (isMouseInSlider && !this.isLastMouseInSlider) {
			result = ENTER;
		} else if (!isMouseInSlider && this.isLastMouseInSlider) {
			result = EXIT;
		} else if (isMouseInSlider) {
			result = OVER;
		}

		this.isLastMouseInSlider = isMouseInSlider;
		return result;
	}

	public function restart() {
		for (arch in this.archs) {
			if (arch.value == this.startValue) {
				this.fireChangeEvent(arch);
				this.snapToArch(arch);
			}
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

		this.fireChangeEvent(currMinArch);
		this.snapToArch(currMinArch);
	}

	private function fireChangeEvent(newArch : Arch) {
		// Send new value event, should happen only if a new arch was selected!
		if (newArch != selectedArch) {
			this.onSliderValueChanged(this.name, selectedArch.value, newArch.value);
		}
	}

	private function snapToArch(arch : Arch) {
		if (this.selectedArch != null) {
			this.setArchAsset(this.selectedArch, arch.value);
		}
		this.setArchAsset(arch, arch.value);
		this.selectedArch = arch;

		this.sliderHandle.y = arch.sprite.y - SLIDER_TRIANGLE_Y;
	}

	private function updateSliderImage(position : FlxPoint) : Bool {
		if (boundingRect.containsPoint(position)) {
			this.sliderHandle.loadGraphic("assets/images/sliderHover.png");
			return true;
		} else {
			this.sliderHandle.loadGraphic("assets/images/slider.png");
			return false;
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