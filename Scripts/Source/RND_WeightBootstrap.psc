Scriptname RND_WeightBootstrap extends questVersioning  

SexLabFramework Property SexLab = None              Auto
Quest           Property RNDWeight = None           Auto

GlobalVariable  Property RNDstatus = None           Auto Hidden 
GlobalVariable  Property RNDThirstPoints = None     Auto Hidden 
GlobalVariable  Property RNDHungerPoints = None     Auto Hidden 
GlobalVariable  Property RNDSleepPoints = None      Auto Hidden 
GlobalVariable  Property RNDSleepMax = None         Auto Hidden 
Bool            Property bRegisterForUpdate = False Auto Hidden 

Actor kPlayer = none

int Function qvGetVersion()
	return 1
endFunction

function qvUpdate( int aiCurrentVersion )
	baseInit()
endFunction

function baseInit()
	RNDstatus = Game.GetFormFromFile(0x00012c4c, "RealisticNeedsandDiseases.esp") as GlobalVariable
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

	if bRegisterForUpdate && SexLab != None
		RNDThirstPoints = Game.GetFormFromFile(0x00002e07, "RealisticNeedsandDiseases.esp") as GlobalVariable
		RNDHungerPoints = Game.GetFormFromFile(0x00002884, "RealisticNeedsandDiseases.esp") as GlobalVariable
		RNDSleepPoints  = Game.GetFormFromFile(0x0000bac2, "RealisticNeedsandDiseases.esp") as GlobalVariable
		RNDSleepMax     = Game.GetFormFromFile(0x0000bac8, "RealisticNeedsandDiseases.esp") as GlobalVariable
		RegisterForModEvent("OrgasmEnd", "rndSwallow")
	endIf
endFunction

event rndSwallow(string eventName, string argString, float argNum, form sender)
	sslBaseAnimation anim = SexLab.HookAnimation(argString)
	actor[] actorList     = SexLab.HookActors(argString)
	float sleepMax        = RNDSleepMax.GetValue()
	
	if actorList[0] == kPlayer && RNDWeight.IsRunning()
		RNDSleepPoints.SetValue( RNDSleepPoints.GetValue() + 40.0 )
		if RNDSleepPoints.GetValue() > sleepMax
			RNDSleepPoints.SetValue( sleepMax )
		endIf

		if anim.HasTag("Oral") || anim.HasTag("Blowjob")
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
