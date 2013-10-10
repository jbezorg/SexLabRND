;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname QF_RNDWeight_01 Extends Quest Hidden

;BEGIN ALIAS PROPERTY PlayerRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerRef Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN AUTOCAST TYPE RND_Weight
Quest __temp = self as Quest
RND_Weight kmyQuest = __temp as RND_Weight
;END AUTOCAST
;BEGIN CODE
; END QUEST
kmyQuest.UnregisterForUpdateGameTime()
kmyQuest.UnregisterForUpdate()

Actor pActor = Alias_PlayerRef.GetActorReference()
ActorBase pActorBase = pActor.GetActorBase()

pActorBase.SetWeight( kmyQuest.fOrigPlayerWeight )
pActor.SetActorValue("Mass", kmyQuest.fOrigPlayerMass)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE RND_Weight
Quest __temp = self as Quest
RND_Weight kmyQuest = __temp as RND_Weight
;END AUTOCAST
;BEGIN CODE
; START QUEST

Actor pActor = Alias_PlayerRef.GetActorReference()
ActorBase pActorBase = pActor.GetActorBase()

kmyQuest.fOrigPlayerWeight = pActorBase.GetWeight() as Float
kmyQuest.fOrigPlayerMass = pActor.GetActorValue("Mass")

kmyQuest.fCurrentPlayerWeight = kmyQuest.fOrigPlayerWeight
kmyQuest.fCurrentPlayerMass = kmyQuest.fOrigPlayerMass

Int idx = 0
While idx < kmyQuest.RNDHungerEffects.Length
	MagicEffect nthMagicEffect = Game.GetFormFromFile( kmyQuest.RNDHungerEffects[idx], "RealisticNeedsandDiseases.esp") as MagicEffect
	Debug.Trace( "RNDWeight::GetFormFromFile = " + nthMagicEffect.GetName() + " :: " + nthMagicEffect)
	kmyQuest.RNDHungerMagicEffects[idx] = nthMagicEffect
	idx += 1
EndWhile

kmyQuest.RegisterForUpdateGameTime( 0.125 )
kmyQuest.RegisterForUpdate( 5.0 )
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
