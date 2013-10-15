Scriptname RND_Weight extends questVersioning Conditional

; RNDHungerEffects 0 = Gluttony
; RNDHungerEffects 1 = Satiated
; RNDHungerEffects 2 = Peckish
; RNDHungerEffects 3 = Hungry
; RNDHungerEffects 4 = Very Hungry
; RNDHungerEffects 5 = Very Hungry Perk
; RNDHungerEffects 6 = Starving
; RNDHungerEffects 7 = Starving Perk
MagicEffect[]       Property RNDHungerMagicEffects  Auto
GlobalVariable      Property GameHour               Auto  
ReferenceAlias      Property Alias_Player           Auto
Message             Property SexLabRNDRestore       Auto  
Int[]               Property RNDHungerEffects       Auto
Int[]               Property iEatingHabit           Auto  Conditional

Float               Property fOrigPlayerWeight      Auto Hidden Conditional
Float               Property fOrigPlayerMass        Auto Hidden Conditional
Float               Property fCurrentPlayerWeight   Auto Hidden Conditional
Float               Property fCurrentPlayerMass     Auto Hidden Conditional
Int                 Property quarterHour = 0        Auto Hidden Conditional

RND_WeightBootstrap Property bootstrap = None       Auto
SexLabFramework     Property SexLab = None          Auto

Actor kPlayer
ActorBase kPlayerBase

Int iThisEatingHabit
Int iEatingHabitAvg

Int lastQuarterHour = 0
Int adj             = 0
Int activityPoll    = 0
Float combatAdj     = 0.0
Float combatAve     = 0.0
Float sprintAdj     = 0.0
Float sprintAve     = 0.0
Float weightAdj     = 0.0
Float weightAve     = 0.0
Float gluttonAdj    = 0.0
Float gluttonAve    = 0.0
Float satiatedAdj   = 0.0
Float satiatedAve   = 0.0
Float peckishAdj    = 0.0
Float peckishAve    = 0.0
Float hungryAdj     = 0.0
Float hungryAve     = 0.0
Float veryHungryAdj = 0.0
Float veryHungryAve = 0.0
Float starvingAdj   = 0.0
Float starvingAve   = 0.0
Float sexAdj        = 0.0
Float sexAve        = 0.0
Bool glutton        = False
Bool satiated       = False
Bool peckish        = False
Bool hungry         = False
Bool veryHungry     = False
Bool starving       = False
Bool sexualyActive  = False
Bool overLoaded     = False

Bool underWeight    = False
Bool overWeight     = False
Bool triggerUpdate  = False
Bool rndFound       = False

int Function qvGetVersion()
	return 2
endFunction

function qvUpdate( int aiCurrentVersion )
	if (qvCurrentVersion >= 2 && aiCurrentVersion < 2)
		SexLabRNDRestore = Game.GetFormFromFile(0x000093f8, "SexLab RND.esp") as Message
	endIf
endFunction

function startQuest(Actor pActor)
	ActorBase pActorBase = pActor.GetActorBase()

	fOrigPlayerWeight    = pActorBase.GetWeight() as Float
	fOrigPlayerMass      = pActor.GetActorValue("Mass")
	fCurrentPlayerWeight = fOrigPlayerWeight
	fCurrentPlayerMass   = fOrigPlayerMass

	Int idx = 0
	While idx < RNDHungerEffects.Length
		MagicEffect nthMagicEffect = Game.GetFormFromFile( RNDHungerEffects[idx], "RealisticNeedsandDiseases.esp") as MagicEffect
		Debug.Trace( "RNDWeight::GetFormFromFile = " + nthMagicEffect.GetName() + " :: " + nthMagicEffect)
		RNDHungerMagicEffects[idx] = nthMagicEffect
		idx += 1
	EndWhile

	RegisterForUpdateGameTime( 0.125 )
	RegisterForUpdate( 5.0 )
endFunction

function endQuest(Actor pActor)
	ActorBase pActorBase = pActor.GetActorBase()

	if SexLabRNDRestore.Show(fCurrentPlayerWeight, fOrigPlayerWeight) == 1
		pActorBase.SetWeight( fOrigPlayerWeight )
		pActor.SetActorValue("Mass", fOrigPlayerMass)
	endIf

	UnregisterForUpdateGameTime()
	UnregisterForUpdate()
endFunction


Function ModActorWeight(Actor akActor, ActorBase akActorBase, Int iModVal )
	fCurrentPlayerWeight = akActorBase.GetWeight() + iModVal
	
	if ( fCurrentPlayerWeight < 0.1 )
		fCurrentPlayerWeight = 0.1
	endif
	if ( fCurrentPlayerWeight > 99.0 )
		fCurrentPlayerWeight = 99.0
	endif
	Debug.Trace( "RNDWeight:: " + fCurrentPlayerWeight )
	
	; make sure we have 3d loaded to access
	While ( !akActor.Is3DLoaded() )
		Utility.Wait( 0.01 )
	EndWhile

	akActorBase.SetWeight( fCurrentPlayerWeight )
EndFunction

Int Function getAverageFromIntArray( Int[] aiArray )
	Int iSum = 0
	Int iIdx = 0
	Int iLen = aiArray.Length
	Float fVal
	Float fAbs
	Int iRet

	While ( iIdx < iLen )
		iSum += aiArray[iIdx]
		iIdx += 1
	EndWhile
	
	fVal = iSum/iLen
	fAbs = Math.abs(fVal)
	iRet = Math.Ceiling(fAbs)
	
	if ( fAbs > 0.5 )
		if ( fVal < 0 )
			Return 0 - iRet
		Else
			Return iRet
		endif
	Else
		Return 0
	endif
EndFunction

Function zeroArray( Int[] aiArray )
	Int iIdx = 0
	Int iLen = aiArray.Length

	While ( iIdx < iLen )
		aiArray[iIdx] = 0
		iIdx += 1
	EndWhile
EndFunction

Event OnInit()
	kPlayer      = Alias_Player.GetActorReference()
	kPlayerBase  = kPlayer.GetActorBase()
	iEatingHabit = New Int[96]
EndEvent

Event OnUpdateGameTime()
	if !Game.GetFormFromFile(0x00012c4c, "RealisticNeedsandDiseases.esp")
		UnregisterForUpdateGameTime()
		UnregisterForUpdate()
		Stop()
		return
	endif

	quarterHour = Math.Floor( GameHour.GetValue() * 4.0 )
	underWeight = fCurrentPlayerWeight < fOrigPlayerWeight
	overWeight  = fCurrentPlayerWeight > fOrigPlayerWeight

	if ( lastQuarterHour != quarterHour )
		gluttonAve       = gluttonAdj / activityPoll
		satiatedAve      = satiatedAdj / activityPoll
		peckishAve       = peckishAdj / activityPoll
		hungryAve        = hungryAdj / activityPoll
		veryHungryAve    = veryHungryAdj / activityPoll
		starvingAve      = starvingAdj / activityPoll
		combatAve        = combatAdj / activityPoll
		sprintAve        = sprintAdj / activityPoll
		weightAve        = weightAdj / activityPoll
		sexAve           = sexAdj / activityPoll

		iThisEatingHabit = 0
		if ( gluttonAve >= 0.5 )
			iThisEatingHabit += 2
		endif
		if ( satiatedAve >= 0.5 || peckishAve >= 0.5 ) && underWeight
			iThisEatingHabit += 1
		endif
		if ( satiatedAve >= 0.5 || peckishAve >= 0.5 ) && overWeight
			iThisEatingHabit += -1
		endif
		if veryHungryAve >= 0.5
			iThisEatingHabit += -1
		endif
		if starvingAve >= 0.5
			iThisEatingHabit += -2
		endif
		if ( combatAve >= 0.5 )
			iThisEatingHabit += -1
		endif
		if ( sprintAve >= 0.5 )
			iThisEatingHabit += -1
		endif
		if ( weightAve >= 0.5 )
			iThisEatingHabit += -1
		endif
		if ( sexAve >= 0.5 )
			iThisEatingHabit += -1
		endif
		
		if ( lastQuarterHour > quarterHour )
			; we've wrapped the array
			triggerUpdate = True

			While lastQuarterHour < iEatingHabit.Length
				iEatingHabit[lastQuarterHour] = iThisEatingHabit
				lastQuarterHour += 1
			EndWhile
			iEatingHabitAvg = getAverageFromIntArray( iEatingHabit )
			lastQuarterHour = 0
			While lastQuarterHour < quarterHour
				iEatingHabit[lastQuarterHour] = iThisEatingHabit
				lastQuarterHour += 1
			EndWhile
		Else
			triggerUpdate = ( quarterHour == 0 )

			While lastQuarterHour < quarterHour
				iEatingHabit[lastQuarterHour] = iThisEatingHabit
				lastQuarterHour += 1
			EndWhile
			
			if triggerUpdate
				iEatingHabitAvg = getAverageFromIntArray( iEatingHabit )
			endif
		endif

		activityPoll  = 0
		combatAdj     = 0.0
		combatAve     = 0.0
		sprintAdj     = 0.0
		sprintAve     = 0.0
		weightAdj     = 0.0
		weightAve     = 0.0
		gluttonAdj    = 0.0
		gluttonAve    = 0.0
		satiatedAdj   = 0.0
		satiatedAve   = 0.0
		peckishAdj    = 0.0
		peckishAve    = 0.0
		hungryAdj     = 0.0
		hungryAve     = 0.0
		veryHungryAdj = 0.0
		veryHungryAve = 0.0
		starvingAdj   = 0.0
		starvingAve   = 0.0
		sexAdj        = 0.0
		sexAve        = 0.0

		lastQuarterHour = quarterHour
	endif
	
	if ( triggerUpdate )
		triggerUpdate = False
		ModActorWeight( kPlayer, kPlayerBase, iEatingHabitAvg )
	endif
EndEvent

Event OnUpdate()
	if !Game.GetFormFromFile(0x00012c4c, "RealisticNeedsandDiseases.esp")
		UnregisterForUpdateGameTime()
		UnregisterForUpdate()
		Stop()
		return
	endif

	glutton       = kPlayer.HasMagicEffect( RNDHungerMagicEffects[0] )
	satiated      = kPlayer.HasMagicEffect( RNDHungerMagicEffects[1] )
	peckish       = kPlayer.HasMagicEffect( RNDHungerMagicEffects[2] )
	hungry        = kPlayer.HasMagicEffect( RNDHungerMagicEffects[3] )
	veryHungry    = ( kPlayer.HasMagicEffect( RNDHungerMagicEffects[4] ) || kPlayer.HasMagicEffect( RNDHungerMagicEffects[5] ) )
	starving      = ( kPlayer.HasMagicEffect( RNDHungerMagicEffects[6] ) || kPlayer.HasMagicEffect( RNDHungerMagicEffects[7] ) )
	overLoaded    = ( kPlayer.GetAV("InventoryWeight") > kPlayer.GetAV("CarryWeight") )
	sexualyActive = ( SexLab.ValidateActor(kPlayer) == -10 )

	activityPoll += 1
	if ( kPlayer.IsInCombat() )
		combatAdj += 1.0
	endif
	if ( kPlayer.IsSprinting() )
		sprintAdj += 1.0
	endif
	if glutton
		gluttonAdj += 1.0
	endif
	if satiated
		satiatedAdj += 1.0
	endif
	if peckish
		peckishAdj += 1.0
	endif
	if hungry
		hungryAdj += 1.0
	endif
	if veryHungry
		veryHungryAdj += 1.0
	endif
	if starving
		starvingAdj += 1.0
	endif
	if overLoaded
		weightAdj += 1.0
	endif
	if sexualyActive
		sexAdj += 1.0
	endif
EndEvent
