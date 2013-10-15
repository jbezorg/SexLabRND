;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 6
Scriptname QF_RNDWeight_01 Extends Quest Hidden

;BEGIN ALIAS PROPERTY PlayerRef
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerRef Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE RND_Weight
Quest __temp = self as Quest
RND_Weight kmyQuest = __temp as RND_Weight
;END AUTOCAST
;BEGIN CODE
; START QUEST
kmyQuest.startQuest( Alias_PlayerRef.GetActorReference() )
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN AUTOCAST TYPE RND_Weight
Quest __temp = self as Quest
RND_Weight kmyQuest = __temp as RND_Weight
;END AUTOCAST
;BEGIN CODE
; END QUEST
kmyQuest.endQuest( Alias_PlayerRef.GetActorReference() )
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
