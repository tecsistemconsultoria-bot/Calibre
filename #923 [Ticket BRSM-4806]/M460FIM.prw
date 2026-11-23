#INCLUDE "rwmake.ch"
#INCLUDE "ap5mail.ch"
/*         
+-------+--------------+---------+---------------------------+---------+-------------+
|Funcao | M460FIM      | Autor:  | Rodrigo Carvalhaes        | Data:   | 26/08/2009  |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | 						 									         |           
Ponto:	                  Após a Gravação dos Dados da NF de Saída.
Retorno Esperado:      Nenhum		               
|                                                                                    |
+-------------+----------------------------------------------------------------------+
| Uso:        | Modulo Faturamento                                                   |
+-------------+----------------------------------------------------------------------+
|            ALTERACOES FEITAS DESDE A CRIACAO DO PROGRAMA:                          |
+-------------+-----------+----------------------------------------------------------+             
*/   
*---------------------------------* 
User Function M460FIM 
*---------------------------------* 
 
//Alert("PE M460FIM" )
// PONTO DE ENTRADA DA PREPARACAO NOTA FISCAL DE SAIDA
// ENVIA EMAIL PARA RESPONSAVEL DA QUALIDADE  
// CRIAR PARAMETRO MV_QUALID = CONTA DE EMAIL DO RESPONSAVEL PELA QUALIDADE
// VALERIO PRECHT EM 09/06/10

Return()                
        
        
