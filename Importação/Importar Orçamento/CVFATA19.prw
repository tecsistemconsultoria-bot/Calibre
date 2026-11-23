#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Otávio Barreiro
Data: 08/01/2026
Consultoria: TecSistem Soluções em Sistemas de Informação
Uso: Calibre
Rotina: Faturamento
Função: CVFATA19
Info: Relação  Quantidade -> Preço 
************************************************************************/
User Function CVFATA19()

	Local lIsBlind := IsBlind()

	If !lIsBlind
	
		If SubStr(TMP1->CK_PRODUTO,1,3) <> 'SV0'

			TMP1 := IIf(!IsBlind(),IIF(SUBSTR(TMP1->CK_PRODUTO,1,3)<>'SV0',ROUND(U_xCalcPrc(TMP1->CK_PRUNIT,M->CJ_CLIENTE,M->CJ_LOJA,TMP1->CK_TES,M->CJ_TIPOCLI,TMP1->CK_PRODUTO),2),TMP1->CK_PRCVEN),TMP1->CK_PRCVEN) 
			
		Else 
			
			TMP1->CK_PRCVEN := TMP1->CK_PRCVEN
		
		Endif
	
	Else
		
		TMP1->CK_PRCVEN := TMP1->CK_PRCVEN
	
	Endif 

Return(TMP1->CK_PRCVEN)
