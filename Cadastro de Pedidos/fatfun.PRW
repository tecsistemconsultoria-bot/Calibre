
/*
+-------+--------------+---------+----------------------------------+---------+-------------+
|Funcao | FATFUN       | Autor:  | Rodrigo Carvalhaes               | Data:   | 28/06/06    |
+-------+--------------+---------+----------------------------------+---------+-------------+
|Descricao:   |  Funcoes diversas utilizadas nas rotinas de faturamento                     |
+-------------+-----------------------------------------------------------------------------+
| Uso:        | Módulo Compras                                                              |
+-------------+-----------------------------------------------------------------------------+
|            ALTERACOES FEITAS DESDE A CRIACAO DO PROGRAMA:                        		    |
+--------------------+-----------+----------------------------------------------------------+
|Programador 		 | Data      | Descricao                                                |
+--------------------+-----------+----------------------------------------------------------+    
|Rodrigo Carvalhaes  | 31/10/2006| funcao forn_cli, incluido tipo "D" para SA2              |
+--------------------+-----------+----------------------------------------------------------+
*/

User Function Forn_Cli()
Local _cNome := ""

// N = NORMAL, C= COMPLEMENTO PRECOS, I= COMPLEMENTO ICMS, P= COMPLEMENTO IPI, D= DEVOLUCAO COMPRAS
// B= UTILIZA FORNECEDOR
Local cAliaAnte, nAreaAnte, nRegiAnte 

cAliaAnte := Alias()
nAreaAnte := IndexOrd()
nRegiAnte := RecNo()

If FUNNAME() <> "MATA410"
		
	If SF2->F2_TIPO == "B" .OR. SF2->F2_TIPO == "D"
		_cNome := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,1,"")
	Else
		_cNome := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,1,"") 
	Endif
Else
	If SC5->C5_TIPO == "B" .OR. SC5->C5_TIPO == "D"
		_cNome := GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,"")
	Else
		_cNome := GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,1,"") 
	Endif
Endif

dbSelectArea(cAliaAnte)
dbSetOrder(nAreaAnte)
dbGoTo(nRegiAnte)


Return(_cNome)
