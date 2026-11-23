#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"                               
#INCLUDE "TBICONN.CH"



User Function vOPrSCK()
Local 	nPPro   := TMP1->CK_PRODUTO                     
Local 	aArea   := GetArea() 
Local _Retorno 	:= .f.

_Retorno := VOPrck(M->CJ_TABELA,nPPro, M->CJ_CLIENTE,M->CJ_LOJA)
        
RestArea(aArea)
Return(_Retorno)


Static Function VOPrck(_TabPr,nPPro, _Cli,_Loj)
Local _Ret := .F. 
                                       
SA1->(dbSelectarea("SA1"))
SA1->(dbSetOrder(1)) // Codigo do produto
SA1->(dbSeek( xFilial('SA1')+ _Cli+_Loj,.F. ))
                                                    
teste := " "       
                 
ACO->(dbSelectarea("ACO"))
ACO->(dbSetOrder(3)) // ACO_FILIAL+ACO_CODCLI+ACO_LOJA+ACO_CODTAB
ACO->(dbSeek( xFilial('ACO')+ _Cli+_Loj+_TabPr,.F. ))

If ACO->(Found())
	teste := " " 
	ACP->(dbSelectarea("ACP"))
	ACP->(dbSetOrder(4)) // ACP_FILIAL+ACP_CODREG+ACP_CODPRO+ACP_CFAIXA
	ACP->(dbSeek(xFilial("ACP")+ACO->ACO_CODREG+ _Prod,.F. )) 
	teste:= " "
	If ACP->(Found()) .and. ACP->ACP_CRVLIQ > 0   
		_Ret  := .t.    
	EndIf   
EndIf   
TESTE := " " 
Return(_Ret)        
