package config;

import sys.io.File;

class Config {

	macro public static function json(path : String) {
		var value : String = File.getContent(path);
		return macro $v{value};
	}
}