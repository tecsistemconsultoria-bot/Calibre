#Include 'Protheus.ch'

/*/{Protheus.doc} U_CalcVlSC5
Calcula o valor total do Pedido percorrendo todos os itens na tabela SC6
/*/
User Function CalcVlSC5()
    Local nTotal   := 0
    Local aArea    := GetArea()
    Local aAreaSC6 := SC6->(GetArea())
    
    // Define o indice 1 (C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO)
    SC6->(DbSetOrder(1))
    
    If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
        
        While !SC6->(Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
            
            nTotal += (SC6->C6_QTDVEN * SC6->C6_PRCVEN)
            
            SC6->(DbSkip())
        EndDo
        
    EndIf
    
    RestArea(aAreaSC6)
    RestArea(aArea)
        
Return nTotal
