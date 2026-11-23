#Include 'Protheus.ch'

/*=================================================================
Autor: Otávio Barreiro
Data: 25/06/2026
Consultoria: TecSistem
Uso: Calibre
Info: Função para pegar Prazo de Entrega Aéreo/Marítimo no campo C6_XPRZFOR
*==================================================================*/
User Function PRZEAM()

Local aArea    := GetArea()
Local cRet := ""

DbSelectArea("SB1")
DbSetOrder(1)

If Posicione("SB1",1,XFilial("SB1")+AllTrim(M->C6_PRODUTO),"B1_CRVMART") == "S"

    DbSelectArea("SA2")
    DbSetOrder(1)
    cRet := "Marítimo " + cValToChar(Posicione("SA2",1,XFilial("SA2")+AllTrim(SB1->B1_PROC)+AllTrim(SB1->B1_LOJPROC),"A2_CRVPZM"))+" Dias"

ElseIf Posicione("SB1",1,XFilial("SB1")+AllTrim(M->C6_PRODUTO),"B1_CRVMART") == "N"

    DbSelectArea("SA2")
    DbSetOrder(1)
    cRet := "Aéreo " + cValToChar(Posicione("SA2",1,XFilial("SA2")+AllTrim(SB1->B1_PROC)+AllTrim(SB1->B1_LOJPROC),"A2_CRVPZO"))+" Dias"

EndIf
      
RestArea(aArea)
Return(cRet)
