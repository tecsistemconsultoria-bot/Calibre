#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'
#Include "TopConn.ch"

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 03/12/2025
Consultoria: Proativa
Uso: Calibre
Info: Pegar os dados do CT-e [Função não funcional até que realize o 
desenvolvimento da amarração do CT-e conforme alinhado com o Ricardo]
*==================================================================*/
User Function CVFATA16()

	Local cQuery   := ""
	Local cTemp    := GetNextAlias()
	Local cSitCTE  := ""

	cQuery += " SELECT * FROM "+RetSQLName("GXL")
	cQuery += "	WHERE GXL_FILIAL = '"+xFilial("GXL")+"'"
	cQuery += "		AND GXL_NRDC = '"+SF2->F2_DOC+"'"
	cQuery += "		AND GXL_SERDC = '"+SF2->F2_SERIE+"'"
	cQuery += "		AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY R_E_C_N_O_ DESC"

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
	
	If !Empty((cTemp)->GXL_OBS + (cTemp)->GXL_HROCOR)

		cSitCTE := (cTemp)->GXL_OBS + (cTemp)->GXL_HROCOR 

	Endif

	(cTemp)->(DbCloseArea())

Return(cSitCTE)
