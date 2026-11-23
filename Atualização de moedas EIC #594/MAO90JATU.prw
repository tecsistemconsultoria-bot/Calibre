#Include 'Protheus.ch'

/*=================================================================
Autor: Otávio Barreiro
Data: 27/04/2026
Consultoria: TecSistem
Uso: Calibre
Info: JOB Para atualizar cotação na SYE
*==================================================================*/

User Function MA090JATU()
	Local cQuery  := ""
	Local cAlias  := GetNextAlias()
	Local aMoedas := {}
	Local nMoeda := 1
	Local n := 1
	Local aArea := GetArea()

    RPCSetEnv("01","01",,,"FIN")

	Begin Sequence
		dbSelectArea("SYF")
		SYF->(dbSetOrder(2))

		dbSelectArea("SYE")
		SYE->(dbSetOrder(1))
			
		// Coleta moedas disponiveis no sistema
		While meuGetMV("MV_MOEDA"+ALLTRIM(STR(nMoeda)),.T.)
			aAdd(aMoedas,{meuGETMV("MV_MOEDA"+ALLTRIM(STR(nMoeda))),"",0})
			nMoeda++
		END

		cQuery := " "
		cQuery += "SELECT "
		cQuery += "SM2.M2_DATA, "
		cQuery += "SM2.M2_MOEDA1, "
		cQuery += "SM2.M2_MOEDA2, "
		cQuery += "SM2.M2_MOEDA3, "
		cQuery += "SM2.M2_MOEDA4, "
		cQuery += "SM2.M2_MOEDA5 "
		cQuery += "FROM "+RetSqlName("SM2")+" SM2 "
		cQuery += "WHERE SM2.D_E_L_E_T_ = '' "
		cQuery += "ORDER BY SM2.M2_DATA ASC "
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
		(cAlias)->(DbGoTop())

		While !(cAlias)->(Eof())

			// Encontra moedas equivalentes no EIC
			For n := 1 to Len(aMoedas)

				IF SYF->(dbSeek(xFilial("SYF")+ALLTRIM(aMoedas[n][1]),.F.))
					// SE ENCONTRAR A MOEDA GRAVA INFORMAÇÂO NO ARRAY
					aMoedas[n][2] := SYF->YF_MOEDA

					// Verifica se existe cotação no eic para a data e moeda informada.

					IF SYE->(DBSEEK(XFILIAL("SYE")+(cAlias)->M2_DATA+SYF->YF_MOEDA,.F.))
						// Se encontrou apenas altera a cotação
						IF SYE->YE_VLCON_C != (cAlias)->(&("M2_MOEDA"+ALLTRIM(STR(n))))
							RECLOCK("SYE",.F.)
							SYE->YE_VLCON_C := (cAlias)->(&("M2_MOEDA"+ALLTRIM(STR(n))))
							SYE->YE_VLFISCA := (cAlias)->(&("M2_MOEDA"+ALLTRIM(STR(n))))
							SYE->YE_MOE_FIN := ALLTRIM(STR(SYF->YF_MOEFAT))
							SYE->(MSUNLOCK())
						END IF
					ELSE
						// Se não encontrou a cotação inclui
						RECLOCK("SYE",.T.)
						SYE->YE_FILIAL := XFILIAL("SYE")
						SYE->YE_DATA := SToD((cAlias)->M2_DATA)
						SYE->YE_MOEDA := SYF->YF_MOEDA
						SYE->YE_VLCON_C := (cAlias)->(&("M2_MOEDA"+ALLTRIM(STR(n))))
						SYE->YE_VLFISCA := (cAlias)->(&("M2_MOEDA"+ALLTRIM(STR(n))))
						SYE->YE_MOE_FIN := ALLTRIM(STR(SYF->YF_MOEFAT))
						SYE->(MSUNLOCK())
					END IF

				END IF

			Next

			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())

		RestArea(aArea)
		Break
		Recover
	End Sequence
Return

/*/ {Prottheus.doc} meugetmv

Retorna conteudo de um parametro

@author Rafael Trindade
@param cParametro, Character, Nome do parametro para retornar conteudo
@since 15/05/2023
/*/

Static Function meugetmv(cParametro,lver)
Default lver := .F.
Return GETMV(cParametro,lver)
