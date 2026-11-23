#Include 'Protheus.ch'

/***********************************************************************
Autor: Otávio Barreiro
Data: 30/03/2026
Consultoria: TecSistem Soluções em Sistemas de Informação
Uso: Compras    
Rotina: Pedidos -> Eliminar Resíduos
Função: MA235PC 
Info: Ponto de entrada que possibilita a eliminação de resíduos
************************************************************************/
User Function MA235PC()  

Local cNum:= mv_par04
Local ExpL1 := .T.

DbSelectArea("SC7")
SC7->(DbSetOrder(1))      
SC7->(DBSeek(xFilial("SC7")+cNum))
    
If !Empty(SC7->C7_PO_EIC) .AND. FunName() <> "EICPO400"
    FWAlertWarning("Este PC esta associado a "+AllTrim(SC7->C7_PO_EIC)+" e so pode ter o residuo eliminado via EIC. Por favor, entre em contato com Comex!","ATENCAO:")
    ExpL1 := .F.
Else
    ExpL1 := .T.
EndIf
Return (ExpL1)
