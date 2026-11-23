#Include "Protheus.ch"  
#Include "Rwmake.ch"
#Include "TopConn.ch"                               
#Include "TBIConn.ch" 

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 25/08/2026
Uso: Calibre
Tipo: Atualizações
Rotina: Específica
Função: GVLDESCK
Info: Atualização do Preço no orçamento tabela SCK
************************************************************************/
User Function GVLDESCK()

	Local aArea := GetArea()
	Local nRet  := 0  

	nRet := xGvlDeSCK()
	
	RestArea(aArea)

Return(nRet)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/08/2026
Uso: Calibre
Info: Atualização do Preço no orçamento tabela SCK
*==================================================================*/
Static Function xGvlDeSCK()

	Local nRet     := 0      
	Local nTotTab  := 0
	Local nTotVlVe := 0                                                                   

	If TMP1->CK_XPRCTAB >=TMP1->CK_PRCVEN   

		If TMP1->CK_QTDVEN == 0  
		
			nTotTab := 1 * TMP1->CK_XPRCTAB
			
		Else 
			
			nTotTab := TMP1->CK_QTDVEN * TMP1->CK_XPRCTAB
		
		Endif 

		If TMP1->CK_VALOR == 0   
			nTotVlVe := 1 * TMP1->CK_PRCVEN	
		Else                                
			nTotVlVe := TMP1->CK_QTDVEN * TMP1->CK_PRCVEN
		EndIf

		nRet := nTotTab - nTotVlVe

	Else 
		
		nRet := 0
		
	Endif 
 
	SYSREFRESH()
	GetDRefresh()

Return(Round(nRet,2))
