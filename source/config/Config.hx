package config;

class Config {

	macro public static function json(path : String) {
		var value : String = sys.io.File.getContent(path);
		return macro $v{value};
	}
}