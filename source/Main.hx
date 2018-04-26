package;

import flixel.FlxGame;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.autoPause = false;
		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
	}
}
