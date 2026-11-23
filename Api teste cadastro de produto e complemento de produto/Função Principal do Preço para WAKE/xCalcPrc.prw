#Include "Protheus.ch"

// 27/10/26 Aldo 
// adicionando o campo de valor do IPI para ser calculado
User Function xCalcPrc(nPrc,cCliente,cLoja,cTes,cTipoCli,cProd,lExecAuto,nVlrIPI,nIcms,lICMS)
Local aArea      := GetArea()
Local nRet       := nPrc
Local cUf        := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_EST")
Local cContrib   := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_CONTRIB")
Local cIcms      := GetMV("MV_ESTICM",.F.)
//Local nIcms      := 0 //onPesqIcms(cUf,cIcms)
Local nIcmInt    := onPesqIcms(cUf,cIcms)
Local nTxPis     := GetMV("MV_TXPIS",.F.)
Local nTxCofins  := GetMV("MV_TXCOFIN",.F.)
Local nDifal     := 0
Local nXPrcTab   := 0
Local nxPrCult   := 0
Local lGrafic    := IsBlind()

Default lExecAuto := .F.
Default nPrc      := 0
Default nIcms     := 0
Default nVlrIPI   := 0
Default lICMS     := .F.

    If !lExecAuto

        If !lGrafic
            nXPrcTab   := Ascan(aHeader,{|x| AllTrim(x[2]) == "C6_XPRCTAB"})
            nxPrCult   := Ascan(aHeader,{|x| AllTrim(x[2]) == "CK_XPRCULT"})
        Else 
            nXPrcTab := 1
            nxPrCult := 1
        Endif 

    Else

        nXPrcTab := 1
        nxPrCult := 1

    Endif 

    If nXPrcTab > 0 .Or. nxPrCult > 0
		// 27/10/26 Aldo 
		// adicionando o campo de valor do IPI para ser calculado
        nIcms := onGetIcmsMXF(cProd, cTes, nPrc, cCliente, cLoja, cTipoCli, @nVlrIPI)

        If lICMS
            Return nIcms
        Endif

        IF cContrib = '1'
            nRet   := nPrc / (1 - (nTxPis + nTxCofins)/100) / ( 1 - nIcms/100 )
        ELSE
            nRet   := nPrc / (1 - (nTxPis + nTxCofins)/100) / ( 1 - nIcms/100 )
            nDifal := ( nPrc / (1 - (nTxPis + nTxCofins)/100) / ( 1 - nIcmInt/100 ) ) - nRet
            nRet   := nRet + nDifal
        ENDIF

    Endif

	RestArea(aArea)

Return nRet


Static function onPesqIcms(cUf,cIcms)
	Local nRet := 0
	Local nPos := At(cUf,cIcms)

	IF nPos 
		cEst := Substr(cIcms,nPos+2,3)    
		cEst := iif(Substr(cEst,3) == ".",Substr(cIcms,nPos+2,5),Substr(cEst,1,2))
		nRet := Val(cEst)
	ENDIF 

Return nRet



Static function onGetIcmsMXF(cProduto,cTes,nValor, cCliente, cLoja, cTipoCli, nVlrIPI)

    Local nRIcm := {}
    Local aICM := {}

    MaFisSave()
    MaFisEnd()
    /// Forma o array aNFCab (Cabeçalho do Documento Fiscal) 
    MaFisIni(cCliente,;                      // 1-Codigo Cliente/Fornecedor
            cLoja,;                        // 2-Loja do Cliente/Fornecedor
            "C",;                                 // 3-C:Cliente , F:Fornecedor
            "N",;                                 // 4-Tipo da NF
            cTipoCli,;                     // 5-Tipo do Cliente/Fornecedor
            MaFisRelImp("MTR700",{"SCJ","SCK"}),; // 6-Relacao de Impostos que suportados no arquivo
            ,;                                    // 7-Tipo de complemento
            ,;                                    // 8-Permite Incluir Impostos no Rodape .T./.F.
            "SB1",;                               // 9-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
            "MTR700") 

    MaFisAdd(cProduto,;          // 1-Codigo do Produto ( Obrigatorio )
                cTes,;           // 2-Codigo do TES ( Opcional )
                1,;              // 3-Quantidade ( Obrigatorio )
                nValor,;         // 4-Preco Unitario ( Obrigatorio )
                0,;              // 5-Valor do Desconto ( Opcional )
                ,;               // 6-Numero da NF Original ( Devolucao/Benef )
                ,;               // 7-Serie da NF Original ( Devolucao/Benef )
                ,;               // 8-RecNo da NF Original no arq SD1/SD2
                0,;              // 9-Valor do Frete do Item ( Opcional )
                0,;              // 10-Valor da Despesa do item ( Opcional )
                0,;              // 11-Valor do Seguro do item ( Opcional )
                0,;              // 12-Valor do Frete Autonomo ( Opcional )
                nValor,;         // 13-Valor da Mercadoria ( Obrigatorio )
                0,;              // 14-Valor da Embalagem ( Opiconal )
                SB1->(Recno()),; // 15-RecNo do SB1
                SF4->(Recno()))  // 16-RecNo do SF4

    nPIcm    := MaFisRet(1,"IT_ALIQICM")
    nVlrIPI  := MaFisRet(1,"IT_VALIPI")

    /*
    aICM := MaFisRet(1,"IT_ICMS")
    if aICM[16] = 0
     nRIcm := Round(aICM[4],2)
    else
     nRIcm := Round(aICM[4] * (1-(aICM[16]/100)),2)
    endif
    */
    mafisend()
    MaFisRestore()

return nPIcm
