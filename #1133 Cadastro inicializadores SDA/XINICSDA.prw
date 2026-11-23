#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "TOTVS.CH"

/***********************************************************************
Autor: Otávio Barreiro
Data: 19/10/2026
Função: XINICSDA
Uso: Calibre - Cadastro de inicializadores SDA
Info:  Inicializadores para os Campos  DA_XQECOM (Qtd.Emb.Comp), DA_XCODVEN (Cod.Prod.Ven) e DA_XQEVEN (Qtd.Emb.Ven)
************************************************************************/

User Function XINICSDA(cCampo)

    Local cRet     := {}
    Local aArea    := GetArea()

    If !Empty(Posicione("SB5",1,xFilial("SB5")+SDA->DA_PRODUTO,"B5_XCOD"))

        If cCampo == "DA_XQECOM"

            cRet := POSICIONE("SB1",1,XFILIAL("SB1")+POSICIONE("SB5",1,XFILIAL("SB5")+SDA->DA_PRODUTO,"B5_XCOD"),"B1_QE")
        
        ElseIf cCampo == "DA_XCODVEN"

            cRet := POSICIONE("SB5",1,XFILIAL("SB5")+SDA->DA_PRODUTO,"B5_COD")

        ElseIf cCampo == "DA_XQEVEN"
        
            cRet := POSICIONE("SB1",1,XFILIAL("SB1")+POSICIONE("SB5",1,XFILIAL("SB5")+SDA->DA_PRODUTO,"B5_COD"),"B1_QE")

        Endif

    Else

        If cCampo == "DA_XQECOM"

            cRet := POSICIONE("SB1",1,XFILIAL("SB1")+SDA->DA_PRODUTO,"B1_QE")
        
        ElseIf cCampo == "DA_XCODVEN"

            cRet := SDA->DA_PRODUTO

        ElseIf cCampo == "DA_XQEVEN"
        
            cRet := POSICIONE("SB1",1,XFILIAL("SB1")+SDA->DA_PRODUTO,"B1_QE")

        Endif

    Endif

    RestArea(aArea)

Return cRet
