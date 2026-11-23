#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"                               
#INCLUDE "TBICONN.CH" 

User Function GVLDESSC6()

	Local aArea     := GetArea()
	Local _Ret      := 0  
	Local nPXPRCTAB := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_XPRCTAB"})  

	If nPXPRCTAB > 0

		_Ret := xGvlDesc6()

	Endif 
	
	RestArea(aArea)

Return(_Ret)

Static Function xGvlDesc6()

Local _Ret := 0        

Local nPXPRCTAB := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_XPRCTAB"})           
Local nPPRCVEN := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})           
Local nPQTDVEN := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})           
Local nPVALOR := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})  
Local nTotTab := 0
Local nTotVlVe:= 0                                                                   

teste := ""
If aCols[n][nPXPRCTAB] >= aCols[n][nPPRCVEN]   
	If aCols[n][nPQTDVEN] = 0  
		nTotTab := 1*aCols[n][nPXPRCTAB]
	Else  
		 nTotTab := aCols[n][nPQTDVEN]*aCols[n][nPXPRCTAB]
	EndIf
	teste:= " "                                                      
	If aCols[n][nPVALOR] = 0   
		nTotVlVe := 1* aCols[n][nPPRCVEN]	
	Else                                
		nTotVlVe := aCols[n][nPQTDVEN]*aCols[n][nPPRCVEN]
	EndIf
	 teste := " "
	_Ret:= nTotTab - nTotVlVe

Else 
	_Ret:= 0
EndIf
 
SYSREFRESH()
GetDRefresh()

Return(_Ret)