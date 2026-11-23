/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Funcao | EICDI500     | Autor:  | Ricardo Rech              | Data:   | 27/12/2017  |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Grava Peso Produto                                                   |
+-------------+----------------------------------------------------------------------+
| Uso:        | Modulo Easy Import Control                                           |
+-------------+----------------------------------------------------------------------+
|            ALTERACOES FEITAS DESDE A CRIACAO DO PROGRAMA:                          |
+-------------+-----------+----------------------------------------------------------+
|Programador  | Data      | Descricao                                                |
+-------------+-----------+----------------------------------------------------------+ 
+-------------+-----------+----------------------------------------------------------+ 
*/
*---------------------------------* 
User Function EICDI500()
*---------------------------------*             

Local cParam := if(Type("ParamIxb") = "A", ParamIxb[1], if(Type("ParamIxb") = "C", ParamIxb, ""))

Do Case
   Case cParam == "AROTINA"
         Aadd(aRotina, {"Acompanhar Transporte", "U_XTransp", 0, 2})
EndCase

IF Paramixb == "GRAVA_ALTERA_SW7"
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek(xFilial("SB1")+ALLTRIM(SW7->W7_COD_I))
   If Found()
	   RecLock("SB1",.F.)
       SB1->B1_PESO	:=SW7->W7_PESO
 	   MsUnlock()
   Endif
ElseIf Paramixb == 'GRAVA_INCLUI_SW7'  
   dbSelectArea("SB1")
   dbSetOrder(1)
   dbSeek(xFilial("SB1")+ALLTRIM(SW7->W7_COD_I))
   If Found()
	   RecLock("SB1",.F.)
       SB1->B1_PESO	:=SW7->W7_PESO
 	   MsUnlock()
   Endif
Endif  


IF Paramixb == "GERA_EIJ_ITEM"  

   Work_EIJ->EIJ_APLICM := "2"
   Work_EIJ->EIJ_METVAL := "01"  
   SW9->(DBSKIP(-1))
   If EMPTY(M->W9_XLOCVEN)
      Work_EIJ->EIJ_LOCVEN := SW9->W9_XLOCVEN
   Else   
      Work_EIJ->EIJ_LOCVEN := M->W9_XLOCVEN
   EndIf 
   SW9->(DBSKIP())
 
Endif

Return
