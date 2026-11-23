#Include 'Protheus.ch'

/***********************************************************************
Autor: Otávio Barreiro
Data: 30/03/2026
Consultoria: TecSistem Soluções em Sistemas de Informação
Uso: Compras    
Rotina: SX1_VALID do Grupo MTA235
Função: xVldResid 
Info: Validação para checar se em ambos os parâmetros os pedido são iguais
************************************************************************/
User Function xVldResid(cDe,cAt)
Local lRet     := .T.

If cDe == cAt
    lRet     := .T.
Else
    FWAlertWarning("So e permitido eliminar residuo de um Pedido de Compra de cada vez", "ATENCAO")
    lRet     := .F.
EndIf 

Return(lRet)
