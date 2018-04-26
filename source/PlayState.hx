package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create() : Void
	{
		super.create();

		var background = new FlxSprite();
		background.loadGraphic("assets/images/background.png");
		add(background);
	}

	override public function onFocusLost() : Void
	{
	}

	override public function onFocus() : Void
	{
	}

	override public function update(elapsed : Float) : Void
	{
		super.update(elapsed);
	}
}
