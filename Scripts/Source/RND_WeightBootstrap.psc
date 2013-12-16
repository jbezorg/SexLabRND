Scriptname RND_WeightBootstrap extends questVersioning  

SexLabFramework Property SexLab = None              Auto
Quest           Property RNDWeight = None           Auto
Float           Property agressiveMult = 1.1        Auto
GlobalVariable  Property TimeScale = None           Auto 

GlobalVariable  Property RNDstatus = None           Auto Hidden 
GlobalVariable  Property RNDThirstPoints = None     Auto Hidden 
GlobalVariable  Property RNDHungerPoints = None     Auto Hidden 
GlobalVariable  Property RNDSleepPoints = None      Auto Hidden 
GlobalVariable  Property RNDSleepRateGain = None    Auto Hidden 
GlobalVariable  Property RNDSleepMax = None         Auto Hidden 
Bool            Property bRegisterForUpdate = False Auto Hidden 

String          Property RNDMOD = "RealisticNeedsandDiseases.esp" AutoReadOnly

Actor kPlayer    = none

int Function qvGetVersion()
	return 4
endFunction

function qvUpdate( int aiCurrentVersion )
	baseInit()
	
	if (qvCurrentVersion >= 2 && aiCurrentVersion < 2)
		agressiveMult = 4.0
		TimeScale = Game.GetFormFromFile(0x0000003a, "Skyrim.esm") as GlobalVariable
	endIf
	if (qvCurrentVersion >= 3 && aiCurrentVersion < 3)
		agressiveMult = 1.1
	endIf
	if (qvCurrentVersion >= 4 && aiCurrentVersion < 4)
		(RNDWeight as RND_Weight).SexLabActive = Game.GetFormFromFile(0x00012b24, "SexLab.esm") as Keyword
	endIf
endFunction

function baseInit()
	RNDstatus = None
	int idx   = Game.GetModCount()
	while idx && RNDstatus == None
		idx -= 1
		if Game.GetModName(idx) == RNDMOD
			RNDstatus = Game.GetFormFromFile(0x00012c4c, RNDMOD) as GlobalVariable
		endIf
	endWhile

	kPlayer   = Game.GetPlayer()
	
	if !bRegisterForUpdate && RNDstatus != None
		bRegisterForUpdate = true

		RegisterForSingleUpdate( 1.0 )
		if RNDWeight.IsStopped()
			RNDWeight.Start()
		endIf
	elseIf bRegisterForUpdate && RNDstatus == None
		bRegisterForUpdate = false

		if RNDWeight.IsRunning()
			RNDWeight.Stop()
		endIf
	endIf

	if bRegisterForUpdate && SexLab.Enabled
		RNDThirstPoints  = Game.GetFormFromFile(0x00002e07, RNDMOD) as GlobalVariable
		RNDHungerPoints  = Game.GetFormFromFile(0x00002884, RNDMOD) as GlobalVariable
		RNDSleepPoints   = Game.GetFormFromFile(0x0000bac2, RNDMOD) as GlobalVariable
		RNDSleepRateGain = Game.GetFormFromFile(0x0000bac3, RNDMOD) as GlobalVariable
		RNDSleepMax      = Game.GetFormFromFile(0x0000bac8, RNDMOD) as GlobalVariable

		RegisterForModEvent("OrgasmEnd", "rndSwallow")
	endIf
endFunction

event rndSwallow(string eventName, string argString, float argNum, form sender)
	sslBaseAnimation anim = SexLab.HookAnimation(argString)
	actor[] actorList     = SexLab.HookActors(argString)
	float time            = SexLab.HookTime(argString)
	float sleepMax        = RNDSleepMax.GetValue()
	
	if actorList.Find(kPlayer) >= 0 && RNDWeight.IsRunning()
		bool  isOral      = anim.HasTag("Oral") || anim.HasTag("Blowjob")
		bool  isAgressive = anim.HasTag("Aggressive") || anim.HasTag("Estrus") || anim.HasTag("Creature")
		float statMod     = ( (kPlayer.GetActorValue("Health")/4) + kPlayer.GetActorValue("Stamina") ) * 10

		float exhaustion = time / statMod * TimeScale.GetValue() * RNDSleepRateGain.GetValue()

		if isAgressive
			exhaustion = exhaustion * agressiveMult
		endIf
		RNDSleepPoints.SetValue( RNDSleepPoints.GetValue() + exhaustion )
		if RNDSleepPoints.GetValue() > sleepMax
			RNDSleepPoints.SetValue( sleepMax )
		endIf

		if  actorList[0] == kPlayer && isOral
			RNDThirstPoints.SetValue( RNDThirstPoints.GetValue() - 20.0 )
			if RNDThirstPoints.GetValue() < 0.0
				RNDThirstPoints.SetValue(0.0)
			endIf

			RNDHungerPoints.SetValue( RNDHungerPoints.GetValue() - 5.0)
			if RNDHungerPoints.GetValue() < 0.0
				RNDHungerPoints.SetValue(0.0)
			endIf
		endIf
	endIf
endEvent


event OnInit()
	baseInit()
endEvent

event OnUpdate()
	if bRegisterForUpdate
		if RNDstatus.GetValueInt() == 1 && RNDWeight.IsStopped()
			RNDWeight.Start()
		endIf
		If RNDstatus.GetValueInt() == 0 && RNDWeight.IsRunning()
			RNDWeight.Stop()
		endIf
		RegisterForSingleUpdate( 1.0 )
	endIf
endEvent
