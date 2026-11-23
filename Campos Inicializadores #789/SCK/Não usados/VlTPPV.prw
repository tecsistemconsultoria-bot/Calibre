User Function VlTPPV()         
//Esta rotina 'e chamada nos gatilhos de C6_QUANTIDA para nAo serem disparados se for uma nota de retorno ou devolucao de compra
                                       
Local _Ret := .t.              
Private _aArea := Getarea()

Private pNFORI   := aScan(aHeader,{|x| Alltrim(x[2]) == "C6_NFORI"})   
                
If !empty(aCols[n][pNFORI])       
	_Ret := .f.
EndIf



RestArea(_aArea)
Return(_Ret)
