#Include 'Protheus.ch'

/*/{Protheus.doc} MA090ATU

O ponto de entrada MA090ATU complementa após as operações de cadastro da rotina de moedas, passando como referencia a variável nOpc,
indicando qual operação foi realizada:1 - Pesquisa 2 - Visualiza 3 - Inclui 4 - Altera 5 - Exclui 6 - Projeta

@author rtrindade
@since 03/04/2017
@version 1.0
@param nOpc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function MA090ATU(nOpc)
	Local aMoedas := {}
	Local nMoeda := 1
	Local n := 1
	Local aAreaSYF := SYF->(GETAREA())
	Local aArea := GetArea()
	Local aAreaSYE := SYE->(GETAREA())
	Default nOpc := Paramixb[1]

	Begin Sequence
		dbSelectArea("SYF")
		SYF->(dbSetOrder(2))

		dbSelectArea("SYE")
		SYE->(dbSetOrder(1))
		IF !ISINCALLSTACK("A090PROJET")
			IF nOpc == 3 .or. nOpc == 4 // Se estiver incluindo ou alterando

				// Coleta moedas disponiveis no sistema
				While meuGetMV("MV_MOEDA"+ALLTRIM(STR(nMoeda)),.T.)
					aAdd(aMoedas,{meuGETMV("MV_MOEDA"+ALLTRIM(STR(nMoeda))),"",0})
					nMoeda++
				END

				// Encontra moedas equivalentes no EIC

				For n := 1 to Len(aMoedas)

					IF SYF->(dbSeek(xFilial("SYF")+ALLTRIM(aMoedas[n][1]),.F.))
						// SE ENCONTRAR A MOEDA GRAVA INFORMAÇÃO NO ARRAY
						aMoedas[n][2] := SYF->YF_MOEDA

						// Verifica se existe cotação no eic para a data e moeda informada.

						IF SYE->(DBSEEK(XFILIAL("SYE")+DTOS(SM2->M2_DATA)+SYF->YF_MOEDA,.F.))
							// Se encontrou apenas altera a cotação
							IF SYE->YE_VLCON_C != SM2->(&("M2_MOEDA"+ALLTRIM(STR(n))))
								RECLOCK("SYE",.F.)
								SYE->YE_VLCON_C := SM2->(&("M2_MOEDA"+ALLTRIM(STR(n))))
								SYE->YE_VLFISCA := SM2->(&("M2_MOEDA"+ALLTRIM(STR(n))))
								SYE->YE_MOE_FIN := ALLTRIM(STR(SYF->YF_MOEFAT))
								SYE->(MSUNLOCK())
							END IF
						ELSE
							// Se não encontrou a cotação inclui
							RECLOCK("SYE",.T.)
							SYE->YE_FILIAL := XFILIAL("SYE")
							SYE->YE_DATA := SM2->M2_DATA
							SYE->YE_MOEDA := SYF->YF_MOEDA
							SYE->YE_VLCON_C := SM2->(&("M2_MOEDA"+ALLTRIM(STR(n))))
							SYE->YE_VLFISCA := SM2->(&("M2_MOEDA"+ALLTRIM(STR(n))))
							SYE->YE_MOE_FIN := ALLTRIM(STR(SYF->YF_MOEFAT))
							SYE->(MSUNLOCK())
						END IF

					END IF

				Next

			END IF
		END IF

		SYF->(RestArea(aAreaSYF))
		SYE->(RestArea(aAreaSYE))
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
