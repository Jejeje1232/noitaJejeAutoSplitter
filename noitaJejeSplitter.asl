state("noita") {
	uint gameCompleted : "fmodstudio.dll", 0x107238, 0x24, 0xC, 0xE4, 0x54, 0x30, 0xC, 0xE4, 0x7C, 0x1C;
	uint orbs : 0xE067FC;
}

startup {
	settings.Add("startOnWorld", true, "Start upon world load (Noita sign appears)");
		settings.Add("startOnPlayer", true, "Start upon player spawn instead (Noita sign fades)", "startOnWorld");

	settings.Add("splits", true, "Split on:");
		settings.Add("holyMountain", true, "Holy Mountain (Passing by the heart and refresher)", "splits");
		settings.Add("theWork", true, "The Work (End) (Enter)", "splits");
		settings.Add("gameCompleted", true, "Game Completed screen", "splits");
		settings.Add("sampo", false, "Using The Sampo", "splits");
		//settings.Add("orb", false, "Orb pickup", "splits");
		settings.Add("deadSplit", false, "Dead", "splits");

	settings.Add("reset", true, "Reset on:");
		settings.Add("newGame", true, "Starting game", "reset");
		settings.Add("dead", false, "Dead", "reset");

}

init {
	string logPath = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Noita\\logger.txt";
	try {
		FileStream fs = new FileStream(logPath, FileMode.Open, FileAccess.Write, FileShare.ReadWrite);
		fs.SetLength(0);
		fs.Close();
	} catch {
		print("Cant open log");
	}
	vars.machineryFound = false;
	vars.line = "";
	vars.reader = new StreamReader(new FileStream(logPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite));
	if (vars.reader != null) print("opened log");
}

exit {
	timer.IsGameTimePaused = true;
	vars.reader = null;
}

update {
	if (vars.reader == null) return false;
	vars.line = vars.reader.ReadLine();
	
	if(vars.line != null && vars.line.StartsWith("LUA: Machineryfound, trying to animate")) {
		vars.machineryFound = true;
	}
}

start {
	if(vars.line != null && vars.line.StartsWith("SpawnPlayer") && settings["startOnPlayer"]) {
		timer.IsGameTimePaused = false;
		vars.machineryFound = false;
		return true;
	}
	
	if(vars.line != null && vars.line.StartsWith("World generation took:") && !settings["startOnPlayer"]) {
		timer.IsGameTimePaused = false;
		vars.machineryFound = false;
		return settings["startOnWorld"];
	}
}

reset {
	if(vars.line != null && vars.line.StartsWith("WorldLightAndFog")) {
		return settings["newGame"];
	}
	
	if(vars.line != null && vars.line.StartsWith("HandleEvent - Player Entity Destroyed") && !vars.machineryFound) {
		return settings["dead"];
	}
}

split {	
	if (vars.line != null && vars.line.StartsWith("Music - Playing music/temple/enter")) {
		return settings["holyMountain"];
	}
	
	if (vars.line != null && vars.line.StartsWith("LUA: time_in_seconds:")) {
		return settings["theWork"];
	}
	
	if (current.gameCompleted != null) {
		if(current.gameCompleted > 0 && old.gameCompleted == 0){
			return settings["gameCompleted"];
		}
	}
	
	if (vars.line != null && vars.line.StartsWith("LUA: Sampo:")) {
		return settings["sampo"];
	}
	
	if (vars.line != null && vars.line.StartsWith("HandleEvent - Player Entity Destroyed")) {
		return settings["deadSplit"];
	}
	
	//if (current.orbs != null) {
	//	if(current.orbs > old.orbs){
	//		return settings["orb"];
	//	}
	//}
}
