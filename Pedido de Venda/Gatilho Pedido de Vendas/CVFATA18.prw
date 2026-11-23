#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 17/12/2025
Consultoria: TecSistem Soluções em Sistemas de Informação
Uso: Calibre
Rotina: Faturamento
Função: CVFATA18
Info: Preço Net 
************************************************************************/
User Function CVFATA18()

	Local lIsBlind := IsBlind()
	Local nPrcVen  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRCVEN'})
    Local nPrxtab  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_XPRCTAB'})
    Local nDesc	   := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_XDESC'})
    Local nTes     := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_TES'})
    Local nProd    := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRODUTO'})
	Local nPrVenda := 0

    //FWAlertError(cValToChar(aCols[n][nDesc]))
    
	If !lIsBlind
	
		If !(M->C5_TIPO) $ 'D|B|C'

			If SubStr(aCols[n][nProd],1,3) <> 'SV0'

				aCols[n][nPrcVen] := Round(U_xCalcPrc(aCols[n][nPrxtab]*(1-aCols[n][nDesc]/100),M->C5_CLIENTE,M->C5_LOJACLI,aCols[n][nTes],M->C5_TIPOCLI,aCols[n][nProd]),2)
				nPrVenda := aCols[n][nPrcVen]
			Else 
				
				nPrVenda := aCols[n][nPrcVen]
			
			Endif

		Else
			
			nPrVenda := aCols[n][nPrcVen]
		
		Endif 
	
	Else
		
		nPrVenda := aCols[n][nPrcVen]
	
	Endif 

Return(nPrVenda)
