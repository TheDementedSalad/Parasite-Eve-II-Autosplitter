state("LiveSplit") {}

startup
{
	// Creates a persistent instance of the PS1 class (for PS1 emulators)
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");
	
	//This allows is to look through a bitmask in order to get split information
	vars.bitCheck = new Func<byte, int, bool>((byte val, int b) => (val & (1 << b)) != 0);
	
	// for the game you want to support in your script. The following Keys are relative to the game "Kula World"
	// You can look up for known IDs on https://psxdatacenter.com/
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
    {
	//Address of Gamecode (This can be multiple addresses in some cases
		emu.MakeString("UGamecode", 10, 0x60DDA);		//SLUS-01042
		emu.MakeString("PGamecode", 10, 0x61F52);		//SLES-02558
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//These are for the NTSCU (American) Version of the game
		//Map
		emu.Make<ushort>("U_Map", 0x714C6);
		//Key Item bits
		emu.Make<byte>("U_Key1", 0x72714);
		emu.Make<byte>("U_Key2", 0x72715);
		emu.Make<byte>("U_Key3", 0x72716);
		emu.Make<byte>("U_Key4", 0x72717);
		emu.Make<byte>("U_Key5", 0x72718);
		//Bosses
		emu.Make<short>("U_BO1", 0x91C00);
		emu.Make<short>("U_BO2", 0x91D48);
		emu.Make<short>("U_BO3", 0x91E88);
		
		emu.Make<short>("U_BOF", 0x91CF8);
		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//These are for the NTSCU (American) Version of the game
		//Map
		emu.Make<ushort>("P_Map", 0x7254E);
		//Key Item bits
		emu.Make<byte>("P_Key1", 0x7379C);
		emu.Make<byte>("P_Key2", 0x7379D);
		emu.Make<byte>("P_Key3", 0x7379E);
		emu.Make<byte>("P_Key4", 0x7379F);
		emu.Make<byte>("P_Key5", 0x737A0);
		//Bosses
		emu.Make<short>("P_BO1", 0x92D00);
		emu.Make<short>("P_BOF", 0x92D80);
	return true;
    });

   // Our standard startup code can be put below this point
   
	vars.completedSplits = new bool[44];

	settings.Add("Door", false, "Door Splitter - Does Not Split on Level End");

	settings.Add("Key", false, "Key Item Splitter");
	vars.Keys = new Dictionary<string,string>
	{
		{"Key1_1","Cafeteia Key"},
		{"Key1_2","Metallic Implant"},
		{"Key1_4","Blue Key"},
		{"Key2_4","Dryfield Map"},
		{"Key2_7","Motel Key No.6"},
		{"Key3_0","Saloon Key"},
		{"Key4_3","Magnet"},
		{"Key3_5","Factory Key"},
		{"Key3_4","Wire Rope"},
		{"Key3_1","Monkey Wrench"},
		{"Key3_2","Lobby Key"},
		{"Key3_3","Bronco Masterkey"},
		{"Key3_7","Jerry Can"},
		{"Key4_0","Gasoline"},
		{"Key3_6","Truck Key"},
		{"Key4_7","Board"},
		{"Key5_1","Bowman's Card"},
		{"Key5_2","Yoshida's Card"},
		{"Key5_3","Car Key"},
	};
	foreach (var Tag in vars.Keys){
		settings.Add(Tag.Key, false, Tag.Value, "Key");
	};
	settings.CurrentDefaultParent = null;
	
	settings.Add("Boss", false, "Boss Splitter");
	vars.Bosses = new Dictionary<string,string>
	{
		{"BO1","Golem 1"},
		{"BO2","Golem 2"},
		{"BO3","Burner"},
	};
	foreach (var Tag in vars.Bosses){
		settings.Add(Tag.Key, false, Tag.Value, "Boss");
	};
	settings.CurrentDefaultParent = null;

	settings.Add("End", false, "Kill Eve - Always Active");
}

update
{
	if(current.UGamecode == "SLUS-01042"){
		//Map
		current.Map = current.U_Map;
		//Key Item Bits
		current.Key1 = current.U_Key1;
		current.Key2 = current.U_Key2;
		current.Key3 = current.U_Key3;
		current.Key4 = current.U_Key4;
		current.Key5 = current.U_Key5;
		//Boss Kills
		current.BO1 = current.U_BO1;
		current.BO2 = current.U_BO2;
		current.BO3 = current.U_BO3;
		current.BOF = current.U_BOF;
	}
	
	if(current.PGamecode == "SLES-02558"){
		//Map
		current.Map = current.P_Map;
		//Key Item Bits
		current.Key1 = current.P_Key1;
		current.Key2 = current.P_Key2;
		current.Key3 = current.P_Key3;
		current.Key4 = current.P_Key4;
		current.Key5 = current.P_Key5;
		//Boss Kills
		current.BO1 = current.P_BO1;
		current.BOF = current.P_BOF;
	}
}

onStart
{
	//resets the splits bools when a new run starts
	vars.completedSplits = new bool[44];
}

start
{
	return current.Map == 276 && old.Map != 276;
}

split
{
	if(settings["Door"] && current.Map != old.Map){
		return true;
	}
	
	if(settings["Key"]){
		for(int i = 0; i < 8; i++){
			if(settings["Key1_" + i] && vars.bitCheck(current.Key1, i) && !vars.completedSplits[0 + i]){
				return vars.completedSplits[0 + i]  = true;
			}
		}
		for(int i = 0; i < 8; i++){
			if(settings["Key2_" + i] && vars.bitCheck(current.Key2, i) && !vars.completedSplits[8 + i]){
				return vars.completedSplits[8 + i]  = true;
			}
		}	
		for(int i = 0; i < 8; i++){
			if(settings["Key3_" + i] && vars.bitCheck(current.Key3, i) && !vars.completedSplits[16 + i]){
				return vars.completedSplits[16 + i]  = true;
			}
		}	
		for(int i = 0; i < 8; i++){
			if(settings["Key4_" + i] && vars.bitCheck(current.Key4, i) && !vars.completedSplits[24 + i]){
				return vars.completedSplits[24 + i]  = true;
			}
		}	
		for(int i = 0; i < 8; i++){
			if(settings["Key5_" + i] && vars.bitCheck(current.Key5, i) && !vars.completedSplits[32 + i]){
				return vars.mcompletedSplits[32 + i]  = true;
			}
		}	
	}
	
	if(settings["Boss"]){
		if(settings["BO1"] && current.Map == 272 && current.BO1 <= 0 && old.BO1 >= 1 && !vars.completedSplits[40])			{return vars.completedSplits[40]  = true;} 
		if(settings["BO2"] && current.Map == 521 && current.BO2 <= 0 && old.BO1 >= 1 && !vars.completedSplits[41])			{return vars.completedSplits[41]  = true;}
		if(settings["BO3"] && current.Map == 797 && current.BO2 <= 0 && old.BO1 >= 1 && !vars.completedSplits[42])			{return vars.completedSplits[42]  = true;}
	}
	
	if(settings["End"] && current.Map == 1046 && current.BOF <= 0 && old.BOF >= 1 && !vars.completedSplits[43])			{return vars.completedSplits[43]  = true;}
}

gameTime
{
}

shutdown
{

}
