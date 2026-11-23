#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Função | MTASF2       | Autor:  | Rodrigo Carvalhaes        | Data:   | 20/11/04    |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Rotina para gravar observação na tabela SF2					         |
|-------------+----------------------------------------------------------------------+
|DETALHES DO P.E.                                                                    |
|Descrição:Após a atualização dos campos do SF2 (Cabeçalho das Notas Ficais de Saída)|
|e antes da gravação da espécie e do volume.										 |
|                                                                                    |
|Observações: Permite o usuário personalizar o cabeçalho das Notas Fiscais de Saída. |
|																					 |
|Retorno Esperado:      Nenhum.														 |
|-------------+----------------------------------------------------------------------+
| Uso:        | Módulo Faturamento                                                   |
+-------------+----------------------------------------------------------------------+
|            ALTERAÇÕES FEITAS DESDE A CRIAÇÃO DO PROGRAMA:                          |
+--------------------+-----------+---------------------------------------------------+
|Programador         | Data      | Descrição                                         |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 22/05/2011|Incluido tratamento f2_hora formato 99:99:99       |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 29/05/2011|Incluido tratamento para notas vinculadas          |
+--------------------+-----------+---------------------------------------------------+
|Mauricio Garcia     | 14/02/2012|Foi acresentado Restore Area no final do PE        |
+--------------------+-----------+---------------------------------------------------+

*/

//----> TO DO LIST:

*---------------------------------*
User Function MTASF2()
*---------------------------------*

Local cQuery   := ""
Local area     := GetArea()
Local qtde_nf  := 0

/***************************************************************
* Grava hora no formato hh:mm:ss
*
************/
RecLock("SF2",.F.)
SF2->F2_HORA = Time()
MsUnlock()

//msgalert(nModulo)

/***************************************************************
* Quando gera nota pela carga (conferencia.prw)
*
************/
//If nModulo = 39	//
Dbselectarea("SZK") // CABECALHO DOS DADOS DE VOLUME DA CARGA
//	Dbsetorder(5)  // (zk_filial, zk_carga, zk_cliente, r_e_c_n_o_, d_e_l_e_t_)
Dbsetorder(2)  // (zk_filial, zk_carga, zk_cliente, r_e_c_n_o_, d_e_l_e_t_)

//	If Dbseek( xFilial("SZK") + SF2->F2_CARGA + SF2->F2_CLIENTE)  // Encontrou carga + cliente...
If Dbseek( xFilial("SZK") + SF2->F2_DOC + SF2->F2_SERIE)  // Encontrou carga + cliente...
	//Conout(" PE MTASFE ")
	//Conout ("********************************************************")
	////Conout("Carga " + SF2->F2_CARGA)
	
	If cFILANT=='01'
		cQuery := " SELECT F2_DOC NOTA, F2_CRVVINC NF_VINCULADA FROM " + RetSQLName("SF2")
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND F2_CARGA = '"  + SF2->F2_CARGA + "'"
		cQuery += " AND  F2_FILIAL = '"+xFilial("SF2")+"'  AND F2_CLIENTE = '"  + SF2->F2_CLIENTE + "' AND F2_SERIE = '2' ORDER BY F2_DOC"
	Else
		cQuery := " SELECT F2_DOC NOTA, F2_CRVVINC NF_VINCULADA FROM " + RetSQLName("SF2")
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND F2_CARGA = '"  + SF2->F2_CARGA + "'"
		cQuery += " AND  F2_FILIAL = '"+xFilial("SF2")+"'  AND F2_CLIENTE = '"  + SF2->F2_CLIENTE + "' AND F2_SERIE = '3' ORDER BY F2_DOC"
	Endif
	
	// Execucao da query
	TcQuery cQuery New Alias "QRY"
	Count to qtde_nf
	
	QRY->(DbGoTop())
	//Conout("numero de registros" + Str(qtde_nf) )
	
	
	//Conout("Aplicando UPDATE NA NF " + SF2->F2_DOC)
	
	IF Len(aEspVol) > 0
		aEspVol[1,1] := 'CAIXA(S)'
		aEspVol[1,2] := SZK->ZK_VOL
	else
		aADD(aEspVol,{'CAIXA(S)',aEspVol})
	endif

	cQuery := " UPDATE " + RetSQLName("SF2") + " SET  F2_ESPECI1 = 'CAIXA(S)' "
	cQuery += " , F2_PLIQUI = "+STR(SZK->ZK_PESLIQ)+", F2_PBRUTO = "+STR(SZK->ZK_PESOBRU)+", F2_VOLUME1 = "+STR(SZK->ZK_VOL)+", F2_VOLUME2 = "+STR(SZK->ZK_CUB)+" "
	cQuery += " WHERE F2_CARGA = '" + SF2->F2_CARGA + "' AND F2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND D_E_L_E_T_ <> '*' "
	cQuery += " AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = '" + SF2->F2_DOC + "'"
	
	TcSQLExec(cQuery)
	
	
	QRY->(DbCloseArea())
	
	RestArea(area) //14/02/2012 - Estava faltando restaurar a area neste ponto de entrada, possivel problema de travamento
	
	Return
	IF qtde_nf = 0
		//Conout("Nao existe outra nota faturada junto com esta ou eh a ultima NF da serie...Gravando dados de volumes na NF " + SF2->F2_DOC)
		
		cQuery := " UPDATE " + RetSQLName("SF2") + " SET  F2_ESPECI1 = 'CAIXA(S)', "
		cQuery += " , F2_PLIQUI = "+STR(SZK->ZK_PESLIQ)+", F2_PBRUTO = "+STR(SZK->ZK_PESOBRU)+", F2_VOLUME1 = "+STR(SZK->ZK_VOL)+", F2_VOLUME2 = "+STR(SZK->ZK_CUB)+" "
		cQuery += " WHERE F2_CARGA = '" + SF2->F2_CARGA + "' AND F2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND D_E_L_E_T_ <> '*' "
		cQuery += " AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = '" + SF2->F2_DOC + "'"
		TcSQLExec(cQuery)
		
		/*
		RecLock("SF2",.F.)
		Replace SF2->F2_PLIQUI  With SZK->ZK_PESLIQ
		Replace SF2->F2_PBRUTO  With SZK->ZK_PESOBRU
		Replace SF2->F2_VOLUME1 With SZK->ZK_VOL
		Replace SF2->F2_VOLUME2 With SZK->ZK_CUB
		Replace SF2->F2_ESPECI1 With "CAIXA(S)"
		MsUnlock()
		*/
	Elseif qtde_nf > 1
		//Conout("Aplicando UPDATE NA NF " + SF2->F2_DOC)
		
		cQuery := " UPDATE " + RetSQLName("SF2") + " SET F2_CRVVINC = '" + SF2->F2_DOC + "',f2_CRVVINS = '"
		cQuery += SF2->F2_SERIE + "', F2_ESPECI1 = 'VIDE "  + SF2->F2_DOC + "'"
		cQuery += " , F2_PLIQUI = 0, F2_PBRUTO = 0, F2_VOLUME1 = 0, F2_VOLUME2 = 0 "
		cQuery += " WHERE F2_CARGA = '" + SF2->F2_CARGA + "' AND F2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND D_E_L_E_T_ <> '*' "
		cQuery += " AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC <> '" + SF2->F2_DOC + "'"
		TcSQLExec(cQuery)
		
		cQuery := " UPDATE " + RetSQLName("SF2") + " SET F2_CRVVINC = '" + SF2->F2_DOC + "',F2_CRVVINS = '"
		cQuery += SF2->F2_SERIE + "', F2_ESPECI1 = 'CAIXA(S)' "
		cQuery += " , F2_PLIQUI = "+STR(SZK->ZK_PESLIQ)+", F2_PBRUTO = "+STR(SZK->ZK_PESOBRU)+", F2_VOLUME1 = "+STR(SZK->ZK_VOL)+", F2_VOLUME2 = "+STR(SZK->ZK_CUB)+" "
		cQuery += " WHERE F2_CARGA = '" + SF2->F2_CARGA + "' AND F2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND D_E_L_E_T_ <> '*' "
		cQuery += " AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = '" + SF2->F2_DOC + "'"
		
		TcSQLExec(cQuery)
		
		/*
		cQuery := " UPDATE " + RetSQLName("SF2") + " SET f2_crvvinc = '" + SF2->F2_DOC + "',f2_crvvins = '"
		cQuery += SF2->F2_SERIE + "', f2_especi1 = 'VIDE NF "  + SF2->F2_DOC + "'"
		cQuery += " , f2_pliqui = 0, f2_pbruto = 0, f2_volume1 = 0, f2_volume2 = 0 "
		cQuery += " WHERE f2_carga = '" + SF2->F2_CARGA + "' AND f2_cliente = '" + SF2->F2_CLIENTE + "' AND d_e_l_e_t_ <> '*' "
		cQuery += " AND f2_filial = '01' AND f2_doc <> '" + SF2->F2_DOC + "'"
		
		TcSQLExec(cQuery)
		
		RecLock("SF2",.F.)
		Replace SF2->F2_PLIQUI  With SZK->ZK_PESLIQ
		Replace SF2->F2_PBRUTO  With SZK->ZK_PESOBRU
		Replace SF2->F2_VOLUME1 With SZK->ZK_VOL
		Replace SF2->F2_VOLUME2 With SZK->ZK_CUB
		Replace SF2->F2_ESPECI1 With "CAIXA(S)"
		MsUnlock()
		*/
		
	Elseif qtde_nf = 1
		//Conout("Aplicando UPDATE NA NF " + SF2->F2_DOC)
		
		cQuery := " UPDATE " + RetSQLName("SF2") + " SET  F2_ESPECI1 = 'CAIXA(S)' "
		cQuery += " , F2_PLIQUI = "+STR(SZK->ZK_PESLIQ)+", F2_PBRUTO = "+STR(SZK->ZK_PESOBRU)+", F2_VOLUME1 = "+STR(SZK->ZK_VOL)+", F2_VOLUME2 = "+STR(SZK->ZK_CUB)+" "
		cQuery += " WHERE F2_CARGA = '" + SF2->F2_CARGA + "' AND F2_CLIENTE = '" + SF2->F2_CLIENTE + "' AND D_E_L_E_T_ <> '*' "
		cQuery += " AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = '" + SF2->F2_DOC + "'"
		
		TcSQLExec(cQuery)
		
		
	Endif
	QRY->(DbCloseArea())
Endif
//Endif

RestArea(area) //14/02/2012 - Estava faltando restaurar a area neste ponto de entrada, possivel problema de travamento

Return
