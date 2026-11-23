#include "rwmake.ch"
/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Função | MT010ALT     | Autor:  | Rodrigo Carvalhaes        | Data:   | 22/10/2008  |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Após a alteração do registro no SB1, Descrição Genérica do Produto.  |
+-------------+----------------------------------------------------------------------+
| Uso:        | Módulo Genérico                                                      |
+-------------+----------------------------------------------------------------------+
|            ALTERAÇÕES FEITAS DESDE A CRIAÇÃO DO PROGRAMA:                          |
+--------------------+-----------+---------------------------------------------------+
|Programador         | Data      | Descrição                                         |
+--------------------+-----------+---------------------------------------------------+          
|Rodrigo Carvalhaes  |           |                                                   |
+--------------------+-----------+---------------------------------------------------+
*/ 
//----> Pendências

*---------------------------------* 
User Function MT010Alt()                            
*---------------------------------*      
//Alert ("Entrei Mt010ALT") 

Local area   := GetArea()

RecLock("SB1", .F.)   					 // RECLOCK DIRETO POIS JÁ ESTÁ POSICIONADO NO SB1

SB1->B1_CRVREV  := DDATABASE 			 // DATA DA INCLUSAO DO REGISTRO

MsUnlock()

U_fWKProTst(SB1->B1_COD)

RestArea(area)

Return()      
