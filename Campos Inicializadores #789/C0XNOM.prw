#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'
#Include "TopConn.ch"

/*=================================================================
Autor: Otávio Barreiro
Data: 06/07/2026
Consultoria: TecSistem
Uso: Calibre
*==================================================================*/
User Function C0XNOM()

Local aArea := GetArea()
Local cRet  := ""

DbSelectArea("SC0")

If AllTrim(SC0->C0_TIPO) == "PD"

    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbSeek(XFilial("SC5")+AllTrim(SC0->C0_DOCRES)))

    cRet := Posicione("SA1",1,xFilial("SA1")+AllTrim(SC5->C5_CLIENTE)+SC5->C5_LOJACLI,"A1_NOME")
    
EndIf   
    
RestArea(aArea)
Return(cRet)
