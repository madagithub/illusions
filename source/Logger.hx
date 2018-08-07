package;

import sys.FileSystem;
import sys.io.File;

class Logger {
	private var easyLogger : EasyLogger;
	private var currFileIndex : Int;
	private var currFileRowsCount : Int;
	private var maxFiles : Int;
	private var maxRowsPerFile : Int;
	private var fileName : String;

	public function new(fileName : String, maxFiles : Int, maxRowsPerFile : Int) {
		this.easyLogger = new EasyLogger(fileName);
		this.maxFiles = maxFiles;
		this.maxRowsPerFile = maxRowsPerFile;
		this.fileName = fileName;
		this.setExistingLogsState();
	}

	public function log(message : String) : Void {
		this.easyLogger.log(Std.string(this.currFileIndex), message);
		this.currFileRowsCount++;
		this.checkRollOver();
	}

	private function checkRollOver() {
		if (this.currFileRowsCount >= this.maxRowsPerFile) {
			this.currFileIndex++;
			if (this.currFileIndex > this.maxFiles) {
				this.currFileIndex = 1;
			}
			this.currFileRowsCount = 0;
			this.deleteCurrLogFile();
		}
	}

	private function deleteCurrLogFile() {
		var currFileName : String = StringTools.replace(this.fileName, "[logType]", Std.string(this.currFileIndex));
		if (FileSystem.exists(currFileName)) {
			FileSystem.deleteFile(currFileName);
		}
	}

	private function setExistingLogsState() {
		var currFileIndex = 1;

		var noFile : Bool = false;
		while (!noFile) {
			var currFileName : String = StringTools.replace(this.fileName, "[logType]", Std.string(currFileIndex));
			
			if (!FileSystem.exists(currFileName)) {
				noFile = true;
			} else {
				currFileIndex++;
			}
		}

		if (currFileIndex == 1) {
			this.currFileIndex = 1;
			this.currFileRowsCount = 0;
		} else {
			this.currFileIndex = currFileIndex - 1;
			var currFileName : String = StringTools.replace(this.fileName, "[logType]", Std.string(this.currFileIndex));
			this.currFileRowsCount = File.getContent(currFileName).split('\n').length - 1;

			this.checkRollOver();
		}
	}
}