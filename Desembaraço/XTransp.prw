#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Otávio Barreiro
Data: 30/03/2026
Consultoria: TecSistem Soluções em Sistemas de Informação
Uso: Modulo Easy Import Control      
Rotina: Faturamento
Função: XTransp 
Info: Botão 'Acompanhar Transporte'||Abrir URL para acompanhar o transporte
************************************************************************/

User Function XTransp()

    Local cCod    := ""
    Local cCompl  := ""
    Local cTipo   := ""
    Local cTransp := ""


	DbSelectArea("SW6")
	SW6->(DbSetOrder(1))      
    cCod  := SW6->W6_PO_NUM
    cCompl:= SW6->W6_ZIDTRAN

    DbSelectArea("SW2")
	SW2->(DbSetOrder(1))  
    SW2->(DBSeek(xFilial("SW2")+cCod))
  
    cTipo:= SW2->W2_TIPO_EM

    DbSelectArea("SYQ")
	SYQ->(DbSetOrder(1))  
    SYQ->(DBSeek(xFilial("SYQ")+cTipo))

    cTransp:= SYQ->YQ_COD_DI

    If AllTrim(cTransp) == "4-Aerea"

        ShellExecute("Open","https://pt.flightaware.com/live/flight/"+cCompl, "", "", 1)

    ElseIf AllTrim(cTransp) == "1-Maritimo"

        ShellExecute("Open","https://www.vesselfinder.com/vessels/details/"+cCompl, "", "", 1)

    Else

        Alert("O Tipo de transporte não se enquadra nos requesitos para ser acompanhado (Via: Aerea ou Maritima) ")

    EndIf


Return
