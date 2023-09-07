state("LiveSplit") {}

startup
{
	// Creates a persistent instance of the PS1 class (for PS1 emulators)
	vars.Helper = Assembly.Load(File.ReadAllBytes("Components/emu-help")).CreateInstance("PS1");

	// In order to make the helper work, you need to define a Dictionary<string, string> with valid IDs
	// for the game you want to support in your script. The following Keys are relative to the game "Kula World"
	// You can look up for known IDs on https://psxdatacenter.com/
	// The autosplitter will work only for the games with the IDs defined in this Dictionary.

	vars.Helper.Gamecodes = new Dictionary<string, string>
	{
		{ "SLUS-01042", "NTSC-U" },
		{ "SLES-02558", "PAL-E" },
	};

	vars.Helper.Load = (Func<IntPtr, MemoryWatcherList>)(wram => new MemoryWatcherList{
		new StringWatcher(wram + 0x60DDA, 10) { Name = "NTSC-U_Gamecode" },
		new StringWatcher(wram + 0x61F52, 10) { Name = "PAL-E_Gamecode" },

		new MemoryWatcher<ushort>(wram + 0x714C6) { Name = "NTSC-U_MapID" },
		new MemoryWatcher<ushort>(wram + 0x114DDC) { Name = "NTSC-U_KeyItem" },
		new MemoryWatcher<ushort>(wram + 0x1FFDA8) { Name = "NTSC-U_ItemChange" },
		new MemoryWatcher<ushort>(wram + 0x91CF8) { Name = "NTSC-U_KillEve" },

		new MemoryWatcher<ushort>(wram + 0x7254E) { Name = "PAL-E_MapID" },
		new MemoryWatcher<ushort>(wram + 0x115E64) { Name = "PAL-E_KeyItem" },
		new MemoryWatcher<ushort>(wram + 0x200E30) { Name = "PAL-E_ItemChange" },
		new MemoryWatcher<ushort>(wram + 0x92D80) { Name = "PAL-E_KillEve" },
	});

   // Our standard startup code can be put below this point
   
	vars.completedSplits = new List<ushort>();

	settings.Add("Door", false, "Door Splitter - Does Not Split on Level End");

	settings.Add("Key", false, "Key Item Splitter");
	vars.Levels = new Dictionary<string,string>
	{
		{"257","Cafeteria Key"},
		{"258","Metallic Implant"},
		{"260","Blue Key"},
		{"271","Motel Key No.6"},
		{"272","Saloon Key"},
		{"283","Magnet"},
		{"277","Factory Key"},
		{"276","Wire Rope"},
		{"273","Monkey Wrench"},
		{"274","Lobby Key"},
		{"275","Bronco Masterkey"},
		{"279","Jerry Can"},
		{"280","Gasoline"},
		{"278","Truck Key"},
		{"287","Board"},
		{"131","Kyle's Handgun"},
		{"290","Yoshida's Card"},
		{"291","Car Key"},
		{"296","Canister"},
	};

	 foreach (var Tag in vars.Levels){
		settings.Add(Tag.Key, false, Tag.Value, "Key");
	};
	settings.CurrentDefaultParent = null;

	settings.Add("End", false, "Kill Eve - Always Active");
}

update
{
	if (!vars.Helper.Update()) return false;

	current.Map = vars.Helper["MapID"].Current;
	current.KeyItem = vars.Helper["KeyItem"].Current;
	current.Eve = vars.Helper["KillEve"].Current;
	old.Eve = vars.Helper["KillEve"].Old;
	
	if(timer.CurrentPhase == TimerPhase.NotRunning)
	{
		vars.completedSplits.Clear();
	}
}

start
{
	return vars.Helper["MapID"].Changed && vars.Helper["MapID"].Current == 276;
}

split
{
	vars.Item = current.KeyItem.ToString();
	
	if(settings["Door"] && vars.Helper["MapID"].Current != vars.Helper["MapID"].Old){
		return true;
	}

	else if(settings[vars.Item] && vars.Helper["ItemChange"].Current == vars.Helper["KeyItem"].Current && !vars.completedSplits.Contains(current.KeyItem)){
		vars.completedSplits.Add(current.KeyItem);
		return true;
	}
	

	else if(current.Map == 1046 && current.Eve != old.Eve && current.Eve > 60000){
		return true;
	}

	else return false;
}

shutdown
{
	// Terminates the main Task being run inside the helper
	// Please don't remove this line from this block
	vars.Helper.Dispose();
}
