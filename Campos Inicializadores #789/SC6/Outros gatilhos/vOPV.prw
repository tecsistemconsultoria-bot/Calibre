#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"                               
#INCLUDE "TBICONN.CH"

User Function vOPV(_Orig)   
Private _Ret := .T.

If _Orig = "S"
	If ltrim(rtrim(Funname()))="TMKA271"
		_Ret := .F.
	EndIf
Else
	_Ret := U_VLTPPV()
	If _Ret
		If ltrim(rtrim(Funname()))="TMKA271"
			_Ret := .F.
		EndIf
	EndIf
EndIf
Return(_Ret)