#include "rwmake.ch"
/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Função | MT010INC     | Autor:  | Rodrigo Carvalhaes        | Data:   | 23/10/06    |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Após a inclusão do registro no SB1, Descrição Genérica do Produto.   |
+-------------+----------------------------------------------------------------------+
| Uso:        | Módulo Genérico                                                      |
+-------------+----------------------------------------------------------------------+
|            ALTERAÇÕES FEITAS DESDE A CRIAÇÃO DO PROGRAMA:                          |
+--------------------+-----------+---------------------------------------------------+
|Programador         | Data      | Descrição                                         |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 24/12/2007| Incluido novos campos criados para MRP            |
+--------------------+-----------+---------------------------------------------------+
*/
//----> Pendências

*---------------------------------*
User Function MT010Inc()
*---------------------------------*
//Alert ("Entrei Mt010INC")

Local area   := GetArea()

RecLock("SB1", .F.)   					 // RECLOCK DIRETO POIS JÁ ESTÁ POSICIONADO NO SB1
SB1->B1_EMIN     := 0 					 // PONTO DE PEDIDO
SB1->B1_CRVPP    := 0 					 // PONTO DE PEDIDO
SB1->B1_LE   	 := 0 					 // LOTE ECONOMICO
SB1->B1_CRVLE  	 := 0 					 // LOTE ECONOMICO
SB1->B1_LM  	 := 0 					 // LOTE MÍNIMO
SB1->B1_EMAX     := 0  					 // ESTOQUE MÁXIMO
SB1->B1_CRVGRUP  := 'VC'	 			 // GRUPO MRP
SB1->B1_ESTSEG   := 0  					 // ESTOQUE DE SEGURANCA
SB1->B1_UREV     := StoD('        ')  	 // ATUALIZA A DATA DA ULTIMA REVISAO ESTRUTURA PRODUTO
SB1->B1_UCOM     := StoD('        ') 	 // DATA ULTIMA COMPRA
SB1->B1_CONINI   := StoD('        ') 	 // DATA CONSUMO INICIAL
SB1->B1_UCALSTD  := StoD('        ') 	 // ULTIMO CALCULO CUSTO STANDARD
SB1->B1_CRVDATA  := DDATABASE 			 // DATA DA INCLUSAO DO REGISTRO

_ntribipi:='2'
DbSelectArea("SYD")
DbSetOrder(1)
DbSeek(xFilial("SYD")+SB1->B1_POSIPI)
If Found()
	_ntribipi:=syd->YD_IPINTRI
Endif
If SB1->B1_GRPTI <> "0004"
	If _ntribipi=='1'
		SB1->B1_GRPTI := "0003"
	Else
		If SB1->B1_IPI >0
			SB1->B1_GRPTI := "0001"
		Else
			SB1->B1_GRPTI := "0002"
		Endif
	Endif
Endif
MsUnlock()

U_fWKProTst(SB1->B1_COD)

RestArea(area)

Return()
