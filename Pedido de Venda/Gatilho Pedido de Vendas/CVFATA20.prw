#Include 'protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Otávio Barreiro
Data: 02/03/2026
Consultoria: TecSistem Soluções em Sistemas de Informação
Uso: Calibre
Rotina: Faturamento
Função: CVFATA20
Info: Limpar Campos ao atualizar C5_TIPO   (NÃO ESTA EM USO)
************************************************************************/
User Function CVFATA20()

    Local lIsBlind := IsBlind()
	Local nPrcVen  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_PRCVEN'})
    Local nVlr     := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_VALOR'})
    Local nL       := 0

    If !lIsBlind
        For nL := 1 To Len(aCols)
            
            aCols[nL][nPrcVen] := 0
            aCols[nL][nVlr] := 0

        Next nL   
    Endif

Return
