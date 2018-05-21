package illusions;

interface Illusion {
	public function start() : Void;
	public function stop() : Void;
	public function sliderChanged(name : String, value : Float) : Void;
	public function update(elapsed : Float): Void;
}