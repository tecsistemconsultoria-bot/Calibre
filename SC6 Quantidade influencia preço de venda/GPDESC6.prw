#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"                               
#INCLUDE "TBICONN.CH" 

User Function GPDESC6(_Orig)
Local _Ret := 0
Local aArea 	:= GetArea()
Local nPQtd := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_QTDVEN'})             // Quantidade               
Local nPPro := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})           // Preco Tabela Customizado 
Local _Qtd	:= aCols[n][nPQtd]
Local _Prod	:= aCols[n][nPPro]                                                                                                  
Local nPrcVen := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})            
Local nXPrcTab := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_XPRCTAB"})
               
If _Qtd = 0
	_Qtd := 1 
EndIf
                
If _Orig ="LIQ"
	
	If  aCols[n][nPrcVen] > aCols[n][nXPrcTab]
		_Ret := 0
	ElseIf aCols[n][nPrcVen] = aCols[n][nXPrcTab]
		 _Ret := U_GatPDesc("FAT",_Prod  ,_Qtd ,M->C5_CLIENTE, M->C5_LOJACLI,M->C5_TABELA, M->C5_CONDPAG)    
	Else
			_Ret :=  100-round(((aCols[n][nPrcVen]*100)/aCols[n][nXPrcTab]),2)
	EndIf   
Else   
	_Ret := U_GatPDesc("FAT",_Prod  ,_Qtd ,M->C5_CLIENTE, M->C5_LOJACLI,M->C5_TABELA, M->C5_CONDPAG)                                                                                   
EndIf
 



teste := " " 
SYSREFRESH()
GetDRefresh()                                 
teste := " " 

RestArea(aArea)
Return(_Ret)