#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

/***********************************************************************
Autor: Fernando Pessoa 
Data: 27/03/2026
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: CVEICRVE
Info: Função que tem por objetivo chamar o fonte CVFATRV3, que por sua fez irá enviar um relatório de vendas por e-mail. Este fonte será executado via Job
************************************************************************/
User Function CVEICRVE()

   //Local aEmail := {}
   //Local aEmail2 := {}
   //Local nX      := 0

   RPCSetEnv("01","01",,,"EIC")
   
   //aEmail := xFilSX5("XE")

   //If Len(aEmail) > 0
      
   //For nX := 1 To Len(aEmail)   
      
      //IF aEmail[nX] <> ''
         U_CVFATRV3() //Relatório de Vendas
      //ENDIF   
   
  // Next nX
   
   //Endif

   RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return

/*=================================================================
Autor: Fernando Pessoa
Data: 26/03/2026
Consultoria: TecSistem
Uso: Calibre
Info: Filtro tabelas na SX5
*==================================================================*/
/*
Static Function xFilSX5(cTabela)

	Local aAreaSX5 := GetArea()
	Local cTemp    := GetNextAlias()
	Local cQuery   := ""
	Local aRetorno := {}

	cQuery := "SELECT * FROM "+RetSQLName("SX5")
	cQuery += " WHERE X5_FILIAL = '"+xFilial("SX5")+"'"
	cQuery += "		AND X5_TABELA = '"+cTabela+"'"
	cQuery += "		AND D_E_L_E_T_ <> '*'"

	//Proteção para verificar se há dados já na tabela temporária
    If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
        cTemp := GetNextAlias() 
    Endif 
    
    //Conversão da query para a sintaxe do banco de dados do cliente
    cQuery := ChangeQuery(cQuery)

    //Execução da query no banco de dados
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
    
    DbSelectArea(cTemp)
    (cTemp)->(DbGoTop())

	aAdd(aRetorno,"")

    While !((cTemp)->(Eof()))
		
		aAdd(aRetorno,AllTrim((cTemp)->X5_DESCRI))

		(cTemp)->(DbSkip())

	EndDo

	RestArea(aAreaSX5)

Return(aRetorno)
*/
