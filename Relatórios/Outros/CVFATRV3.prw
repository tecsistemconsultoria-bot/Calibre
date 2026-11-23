#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

// alinhamento = Align
Static nLeft 		:= 1
Static nCenter		:= 2
Static nRight		:= 3

// Formatação = Format
Static nGeneral		:= 1
Static nNumber		:= 2
Static nMonetario	:= 3
Static nDateTime	:= 4


/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informações
Uso: Calibre
Tipo: Ponto de Entrada
Rotina: Faturamento
Função: CVFATRV3
Info: Relatório de Vendas
************************************************************************/
User Function CVFATRV3()

	if Select("SX2") == 0
		WfPrepEnv("01","01")
	Endif	
	
	//xQryVend()
	xQrySX5XE()

	//RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informações
Uso: Calibre
Info: Filtra Vendedores
*==================================================================*/
Static Function xQryVend()

	Local cQuery := ""
	Local cTemp  := GetNextAlias()
	Local aVend  := {}
	Local nX     := 0

	// seleciona somente os vendedores ativos que tenha email registrado, pois não adianta enviar sem ter email
	cQuery += " SELECT DISTINCT A3_COD, A3_NOME, A3_END, A3_BAIRRO , A3_MUN, A3_EST, A3_EMAIL" 
	cQuery += " FROM "+RetSQLName("SA3")
	cQuery += " WHERE A3_FILIAL = '"+xFilial("SA3")+"'"
	cQuery += " 	AND A3_MSBLQL <> '1'"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	cQuery += " 	AND A3_EMAIL <> '' "   //26/03/2026 - Por Fernando Cerqueira - TecSistem - Inclusão do filtro A3_EMAIL <> ''
	cQuery += " ORDER BY A3_COD ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	cTemp := GetNextAlias()	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
	
	//DbSelectArea(cTemp)
	//(cTemp)->(DbGoTop())
	While !((cTemp)->(Eof()))

		aAdd(aVend,{(cTemp)->A3_COD,(cTemp)->A3_NOME,AllTrim((cTemp)->A3_END),AllTrim((cTemp)->A3_BAIRRO),(cTemp)->A3_MUN,(cTemp)->A3_EST,AllTrim((cTemp)->A3_EMAIL)})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	If Len(aVend) > 0
	
		For nX := 1 To Len(aVend)

			// processa os dados do vendedor e envia o email com a planilha
			xExecRel(aVend[nX])

		Next nX 
	
	Endif 

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 26/03/2026
Consultoria: TecSistem Consultoria em Sistemas de Informacao
Uso: Calibre
Info: Busca destinatarios SX5/XE e envia relatorio geral
*==================================================================*/
Static Function xQrySX5XE()

	Local cQuery := ""
	Local cTemp  := GetNextAlias()
	Local aEmail := {}
	Local nX     := 0

	cQuery += " SELECT X5_DESCRI "
	cQuery += " FROM "+RetSqlName("SX5")+" SX5 "
	cQuery += " WHERE SX5.D_E_L_E_T_ <> '*' "
	cQuery += "   AND SX5.X5_TABELA = 'XE' "
	cQuery += "   AND SX5.X5_DESCRI <> '' "
	cQuery += " ORDER BY SX5.X5_CHAVE "

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif

	cQuery := ChangeQuery(cQuery)
	cTemp := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	While !((cTemp)->(Eof()))
		aAdd(aEmail, AllTrim((cTemp)->X5_DESCRI))
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->(DbCloseArea())

	If Len(aEmail) > 0
		For nX := 1 To Len(aEmail)
		
			// Executa novamente sem filtro de vendedor para enviar o relatorio geral
			xExecRel(Nil,.T.,aEmail[nX])
		Next nX
	Endif

Return


/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informações
Uso: Calibre
Info: Inicio a geração do Relatório
*==================================================================*/
Static Function xExecRel(aVendedor,lSemFiltroVend,cEmailDestino)

	Local cPasta     := GetMV("XX_XARQUI",.F.,"C:\temp\")
	Local oFWMsExcel := Nil
	Local cData      := StrTran(DToS(Date()),"/","")
	Local cHoraAtu   := Time()
	Local cHora      := StrTran(cHoraAtu,":","")
	Local cDtHora    := AllTrim(cData+"_"+cHora)
	Local cNomeArq   := "Notas_Fiscais_" + cDtHora
	Local cArquivo	 := IIf(!IsBlind(),cPasta+cNomeArq+".xlsx","\spool\"+cNomeArq+".xlsx")
	Local cTemp      := ""
	Local cQuery     := ""

	Local cEmail     := ""
	Local cCodVend   := ""
	Local nA
	Local cFilSB1    := if(Empty(xFilial("SB1")), " '"+xFilial("SB1")+"' ", 'SUBSTRING(CK_FILIAL,1, '+cValToCHar(Len(Alltrim(xFilial("SB1"))))+') ' )

	Default lSemFiltroVend := .F.
	Default cEmailDestino := ""

	If lSemFiltroVend
		cEmail := AllTrim(cEmailDestino)
	Else
		cEmail := AllTrim(aVendedor[7])
		cCodVend := aVendedor[1]
	Endif
   
	//Criando o objeto que irï¿½ gerar o conteï¿½do do Excel
	oFWMsExcel := FwMsExcelXlsx():New()

	//========================= 1 - CRIANDO A ABA ORï¿½AMENTOS INCLUIDOS NO Mï¿½S ================================================
	cTemp  := GetNextAlias()

	aColunas := {}
	aAdd(aColunas, {"CK_FILIAL"		, "C"	, "Filial"				})
	aAdd(aColunas, {"CK_NUM"		, "C"	, "Orcamento"			})
	aAdd(aColunas, {"CJ_EMISSAO"	, "D"	, "Emissao"				})
	aAdd(aColunas, {"F2_EMISSAO"	, "D"	, "Data Faturamento"	})
	aAdd(aColunas, {"F2_DTENTR"		, "D"	, "Data de Entrega"		})
	aAdd(aColunas, {"CJ_CLIENTE"	, "C"	, "Cliente"				})
	aAdd(aColunas, {"CJ_LOJA"		, "C"	, "Loja"				})
	aAdd(aColunas, {"A1_NOME"		, "C"	, "Nome Cliente"		})
	aAdd(aColunas, {"CK_ITEM"		, "C"	, "Item"				})
	aAdd(aColunas, {"CK_PRODUTO"	, "C"	, "Produto"				})
	aAdd(aColunas, {"B1_DESC"		, "C"	, "Descricao"			})
	aAdd(aColunas, {"B1_PROC"		, "C"	, "Fornecedor"			})
	aAdd(aColunas, {"MARCA"			, "C"	, "Fabricante/Marca"	})
	aAdd(aColunas, {"D2_QUANT"		, "N"	, "Qtd."				})
	aAdd(aColunas, {"D2_PRCVEN"		, "N"	, "Prc. Unit."			})
	aAdd(aColunas, {"D2_TOTAL"		, "N"	, "Vlr. Pend. c/ IPI"	})
	aAdd(aColunas, {"D2_TOTAL"		, "N"	, "Vlr. Tot. c/ IPI"	})
	aAdd(aColunas, {"CJ_CRVVEND"	, "C"	, "Vend. Interno"		})
	aAdd(aColunas, {"CJ_XVEND2"		, "C"	, "Vend. Externo"		})
	aAdd(aColunas, {"CJ_XVEND3"		, "C"	, "Ger/Coord."			})
	aAdd(aColunas, {"F2_TPFRETE"	, "C"	, "Tp. Frete"			})
	aAdd(aColunas, {"C6_PEDCLI"		, "C"	, "Ped. Cliente"		})
	aAdd(aColunas, {"PROBABILIDADE"	, "N"	, "% Probabilidade"		})
	aAdd(aColunas, {"TIPO_ORC"		, "C"	, "Tipo Orcamento"		})
	aAdd(aColunas, {"FREQUENCIA"	, "N"	, "Frequencia"			})
	aAdd(aColunas, {"RECORRENCIA"	, "N"	, "Recorrencia"			})
	aAdd(aColunas, {"A1_EST"		, "C"	, "ID UF"				})
	aAdd(aColunas, {"SITUACAO"		, "C"	, "Situacao"			})
	aAdd(aColunas, {"D2_PEDIDO"		, "C"	, "Num PV"				})
	aAdd(aColunas, {"F2_DOC"		, "C"	, "Numero NF"			})
	aAdd(aColunas, {"F2_EMISSAO"	, "D"	, "Data Emissao NF"		})
	//             [1]Campo query    [2]Tipo   [3]Coluna na Planilha

	cQuery := ""
	cQuery += " SELECT CK_FILIAL, CK_NUM, CJ_EMISSAO, F2_EMISSAO, F2_DTENTR, CJ_CLIENTE, CJ_LOJA, A1_NOME, CK_ITEM, CK_PRODUTO, B1_DESC, B1_PROC, ' ' MARCA, "
	cQuery += " D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_TOTAL, CJ_CRVVEND, CJ_XVEND2, CJ_XVEND3, F2_TPFRETE, C6_PEDCLI, 0 PROBABILIDADE, ' ' TIPO_ORC, 0 FREQUENCIA, 0 RECORRENCIA, "
	cQuery += " A1_EST, ' ' SITUACAO, D2_PEDIDO, F2_DOC "
	cQuery += " FROM "+RetSqlName("SCJ")+" SCJ "
	cQuery += " LEFT JOIN "+RetSqlName("SCK")+" SCK "
	cQuery += "   ON SCJ.D_E_L_E_T_ = ' ' AND CJ_FILIAL = CK_FILIAL AND CJ_NUM = CK_NUM "
	cQuery += " LEFT JOIN "+RetSqlName("SC6")+" SC6 "
	cQuery += "   ON SC6.D_E_L_E_T_ = ' ' AND C6_FILIAL = CK_FILIAL AND C6_NUMORC = CK_NUM  AND C6_ITEM = CK_ITEM "
	cQuery += " LEFT JOIN "+RetSqlName("SC5")+" SC5 "
	cQuery += "   ON SC5.D_E_L_E_T_ = ' ' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM   "
	cQuery += " LEFT JOIN "+RetSqlName("SD2")+" SD2 "
	cQuery += "   ON SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL = C6_FILIAL AND D2_DOC = C6_NOTA AND D2_SERIE = C6_SERIE AND D2_ITEMPV = C6_ITEM "
	cQuery += " LEFT JOIN "+RetSqlName("SF2")+" SF2 "
	cQuery += "   ON SF2.D_E_L_E_T_ = ' ' AND D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
	cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 "
	cQuery += "   ON SA1.D_E_L_E_T_ = ' ' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 "
	cQuery += "   ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = "+cFilSB1+" AND B1_COD = CK_PRODUTO "
	cQuery += " WHERE SCK.D_E_L_E_T_ = ' ' AND CK_NUM <> ' ' "
	cQuery += "		AND CJ_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' "  //26/03/2026 - Por Fernando Cerqueira - TecSistem - Insrindo LIKE FORMAT(GETDATE(), 'yyyyMM')
	If !lSemFiltroVend
		cQuery += "		AND ( "
		cQuery += "			(CJ_CRVVEND= '"+cCodVend+"' OR CJ_CRVVEND= '"+cCodVend+"' OR CJ_CRVVEND= '"+cCodVend+"' ) "
		cQuery += "			OR
		cQuery += "			(CJ_XVEND2= '"+cCodVend+"' OR CJ_XVEND2= '"+cCodVend+"' OR CJ_XVEND2= '"+cCodVend+"' ) "
		cQuery += "			OR
		cQuery += "			(CJ_XVEND3= '"+cCodVend+"' OR CJ_XVEND3= '"+cCodVend+"' OR CJ_XVEND3= '"+cCodVend+"' ) "
		cQuery += "		) "
	Endif

	cQuery += " ORDER BY C5_EMISSAO ASC "

	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	cTemp := GetNextAlias()	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	// ajustra os campos data
	For nA := 1 to Len(aColunas)
		if aColunas[nA,2] == "D"
			TcSetField(cTemp, aColunas[nA,2], "D")
		Endif	
	Next

	//Aba Pedidos em Aberto
	cAbaOrcMes := "Orcamento_Mes"
	cDesOrcMes := "Orcamento_do_Mes"
	oFWMsExcel:AddworkSheet(cAbaOrcMes)

	//Criando a Tabela
	oFWMsExcel:AddTable(cAbaOrcMes,cDesOrcMes,.F.)

	// cria as colunas conforme layout
	For nA := 1 to Len(aColunas)
		nAlign := if(aColunas[nA,2]=="N",nRight ,if(aColunas[nA,2]=="D",nCenter,   nLeft   ) )
		nTipo  := if(aColunas[nA,2]=="N",nNumber,if(aColunas[nA,2]=="D",nDateTime, nGeneral) )

		oFWMsExcel:AddColumn(cAbaOrcMes,cDesOrcMes,aColunas[nA,3],1)
	Next

	//DbSelectArea(cTemp)
	//(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))
		// carrega os dados para a linha da planilha respeitando o layout
		aTmp := Array(Len(aColunas))
		For nA := 1 to Len(aColunas)
			cConteudo := (cTemp)->( &(aColunas[nA,1]))
			aTmp[nA] := cConteudo
		Next

		oFWMsExcel:AddRow(cAbaOrcMes,cDesOrcMes,aClone(aTmp) )
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())



	//========================= 2 - CRIANDO A ABA PEDIDOS INCLUIDOS NO Mï¿½S ================================================
	cTemp  := GetNextAlias()

	aColunas := {}
	aColunas := {}
	aAdd(aColunas, {"C5_FILIAL"			,"C"	, "Filial"				})
	aAdd(aColunas, {"C5_NUM"			,"C"	, "Pedido"				})
	aAdd(aColunas, {"C5_EMISSAO"		,"D"	, "Data Emissao"		})	
	aAdd(aColunas, {"F2_EMISSAO"		,"D"	, "Data Faturamento"	})
	aAdd(aColunas, {"F2_DTENTR"			,"D"	, "Data de Entrega"		})
	aAdd(aColunas, {"C5_CLIENTE"		,"C"	, "Cliente"				})
	aAdd(aColunas, {"A1_NOME"			,"C"	, "Nome Cliente"		})
	aAdd(aColunas, {"C6_ITEM"			,"C"	, "Item"				})
	aAdd(aColunas, {"C6_PRODUTO"		,"C"	, "Produto"				})
	aAdd(aColunas, {"B1_DESC"			,"C"	, "Descricao"			})
	aAdd(aColunas, {"B1_PROC"			,"C"	, "Fornecedor"			})
	aAdd(aColunas, {"MARCA"				,"C"	, "Fabricante/Marca"	})
	aAdd(aColunas, {"QTD_PENDENTE"		,"C"	, "Qtd. Pendente"		})
	aAdd(aColunas, {"C6_QTDVEN"			,"C"	, "Qtd. Venda"			})
	aAdd(aColunas, {"C6_PRCVEN"			,"C"	, "Prc. Unit."			})
	aAdd(aColunas, {"VAL_PEND_IPI"		,"C"	, "Vlr. Pend. c/ IPI"	})
	aAdd(aColunas, {"C6_VALOR"			,"C"	, "Vlr. Tot. c/ IPI"	})
	aAdd(aColunas, {"C5_VEND1"			,"C"	, "Vend. Interno"		})
	aAdd(aColunas, {"C5_VEND2"			,"C"	, "Vend. Externo"		})
	aAdd(aColunas, {"C5_VEND3"			,"C"	, "Ger/Coord."			})
	aAdd(aColunas, {"C5_VEND4"			,"C"	, "Vendedor 4"			})
	aAdd(aColunas, {"C5_TPFRETE"		,"C"	, "Tp. Frete"			})
	aAdd(aColunas, {"C6_PEDCLI"			,"C"	, "Ped. Cliente"		})
	aAdd(aColunas, {"PE_ATUALIZADO"		,"C"	, "P.E. Atualizado"		})
	aAdd(aColunas, {"STATUS"			,"C"	, "Status"				})
	aAdd(aColunas, {"AGLUTINA_OC"		,"C"	, "Aglutina OC"			})
	aAdd(aColunas, {"ACEITE_FAT"		,"C"	, "Aceite Fat."			})
	aAdd(aColunas, {"DT_LIMITE_FAT"		,"C"	, "Data Limite Fat."	})
	aAdd(aColunas, {"TIPO_PEDIDO"		,"C"	, "Tipo Pedido"			})
	aAdd(aColunas, {"FREQUENCIA"		,"C"	, "Frequencia"			})
	aAdd(aColunas, {"RECORRENCIA"		,"C"	, "Recorrencia"			})
	aAdd(aColunas, {"A1_EST"			,"C"	, "ID UF"				})
	aAdd(aColunas, {"SITUACAO"			,"C"	, "Situacao"			})
	aAdd(aColunas, {"F2_TRANSP"			,"C"	, "Cod. Transp."		})
	aAdd(aColunas, {"A4_NOME"			,"C"	, "Nome Transp."		})
	aAdd(aColunas, {"C6_NUMORC"			,"C"	, "Num Orcamento"		})
	aAdd(aColunas, {"F2_DOC"			,"C"	, "Numero NF"			})
	aAdd(aColunas, {"F2_EMISSAO"		,"C"	, "Data Emissao NF"		})
	//             [1]Campo query     [2]Tipo     [3]Coluna na Planilha

	cQuery := ""
	cQuery += " SELECT DISTINCT C5_FILIAL, C5_NUM, C5_EMISSAO, F2_EMISSAO, F2_DTENTR, C5_CLIENTE, A1_NOME, C6_ITEM, C6_PRODUTO, B1_DESC, B1_PROC, "
	cQuery += " 	' ' MARCA, 0 QTD_PENDENTE, C6_QTDVEN, C6_PRCVEN, 0 VAL_PEND_IPI, C6_VALOR, C5_VEND1, C5_VEND2, C5_VEND3, C5_VEND4, C5_TPFRETE, "
	cQuery += " 	C6_PEDCLI, ' ' PE_ATUALIZADO, ' ' STATUS, ' ' AGLUTINA_OC, ' ' ACEITE_FAT, ' ' DT_LIMITE_FAT, ' ' TIPO_PEDIDO, 0 FREQUENCIA, "
	cQuery += " 	0 RECORRENCIA, A1_EST, ' ' SITUACAO, F2_TRANSP, A4_COD, C6_NUMORC, F2_DOC, A4_NOME "
	cQuery += " FROM "+RetSqlName("SC5")+" SC5 "
	cQuery += " LEFT JOIN "+RetSqlName("SC6")+" SC6 "
	cQuery += "   ON SC6.D_E_L_E_T_ = ' ' AND C6_FILIAL = C5_FILIAL  AND C6_NUM = C5_NUM  "
	cQuery += " LEFT JOIN "+RetSqlName("SCK")+" SCK "
	cQuery += "   ON SCK.D_E_L_E_T_ = ' ' AND C6_FILIAL = CK_FILIAL AND CK_NUM = C6_NUMORC  AND C6_ITEM = CK_ITEM "
	cQuery += " LEFT JOIN "+RetSqlName("SCJ")+" SCJ "
	cQuery += "   ON SCJ.D_E_L_E_T_ = ' '  AND CJ_FILIAL = CJ_FILIAL  AND CJ_NUM = CK_NUM   "
	cQuery += " LEFT JOIN "+RetSqlName("SD2")+" SD2 "
	cQuery += "   ON SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL = C6_FILIAL AND D2_DOC = C6_NOTA AND D2_SERIE = C6_SERIE AND D2_ITEMPV = C6_ITEM "
	cQuery += " LEFT JOIN "+RetSqlName("SF2")+" SF2 "
	cQuery += "   ON SF2.D_E_L_E_T_ = ' ' AND D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
	cQuery += " LEFT JOIN "+RetSqlName("SA1")+" SA1 "
	cQuery += "   ON SA1.D_E_L_E_T_ = ' ' AND A1_COD = CJ_CLIENTE AND A1_LOJA = CJ_LOJA "
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" B1   "
	cQuery += "   ON  B1.D_E_L_E_T_ = ' ' AND  B1_FILIAL = "+cFilSB1+"  AND B1_COD = C6_PRODUTO "
	cQuery += " LEFT JOIN "+RetSqlName("SA4")+" SA4 "
	cQuery += "   ON  SA4.D_E_L_E_T_ = ' ' AND  A4_FILIAL = ' ' AND A4_COD = C5_TRANSP "
	cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' AND C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM  "
	If !lSemFiltroVend
		cQuery += "		AND ( C5_VEND1 = '"+cCodVend+"' OR C5_VEND2 = '"+cCodVend+"' OR C5_VEND4 = '"+cCodVend+"' ) "
	Endif
	cQuery += "		AND C5_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' " //26/03/2026 - Por Fernando Cerqueira - TecSistem - Insrindo LIKE FORMAT(GETDATE(), 'yyyyMM')
	cQuery += " ORDER BY C5_EMISSAO ASC "
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	cTemp := GetNextAlias()	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	// ajustra os campos data
	For nA := 1 to Len(aColunas)
		if aColunas[nA,2] == "D"
			TcSetField(cTemp, aColunas[nA,2], "D")
		Endif	
	Next

	//Aba Pedidos em Aberto
	cAbaPedMes := "Pedidos_Mes"
	cDesPedMes := "Pedidos_do_Mes"
	oFWMsExcel:AddworkSheet(cAbaPedMes)

	//Criando a Tabela
	oFWMsExcel:AddTable(cAbaPedMes,cDesPedMes,.F.)

	// cria as colunas conforme layout
	For nA := 1 to Len(aColunas)
		nAlign := if(aColunas[nA,2]=="N",nRight ,if(aColunas[nA,2]=="D",nCenter,   nLeft   ) )
		nTipo  := if(aColunas[nA,2]=="N",nNumber,if(aColunas[nA,2]=="D",nDateTime, nGeneral) )

		oFWMsExcel:AddColumn(cAbaPedMes,cDesPedMes,aColunas[nA,3],1)
	Next

	While !((cTemp)->(Eof()))

		// carrega os dados para a linha da planilha respeitando o layout
		aTmp := Array(Len(aColunas))
		For nA := 1 to Len(aColunas)
			cConteudo := (cTemp)->( &(aColunas[nA,1]))
			aTmp[nA] := cConteudo
		Next

		oFWMsExcel:AddRow(cAbaPedMes,cDesPedMes,Aclone(aTmp) )
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	

	//========================= 3 - CRIANDO A ABA NOTAS FISCAIS FATURADAS DO Mï¿½S ================================================
	cTemp  := GetNextAlias()

	aColunas := {}
	aAdd(aColunas, {"FILIAL"			, 'C', "FILIAL"				})
	aAdd(aColunas, {"DATAEMISSAO"		, 'D', "DATAEMISSAO"		})	
	aAdd(aColunas, {"NUMERONF"			, 'C', "NUMERONF"			})
	aAdd(aColunas, {"SERIENF"			, 'C', "SERIENF"			})
	aAdd(aColunas, {"CODCLIENTE"		, 'C', "CODCLIENTE"			})	
	aAdd(aColunas, {"LOJACLIENTE"		, 'C', "LOJACLIENTE"		})
	aAdd(aColunas, {"NOMECLIENTE"		, 'C', "NOMECLIENTE"		})
	aAdd(aColunas, {"FANTASIACLIENTE"	, 'C', "FANTASIACLIENTE"	})	
	aAdd(aColunas, {"BAIRROCLIENTE"		, 'C', "BAIRROCLIENTE"		})	
	aAdd(aColunas, {"UFCLIENTE"			, 'C', "UFCLIENTE"			})
	aAdd(aColunas, {"MUNICIPIOCLIENTE"	, 'C', "MUNICIPIOCLIENTE"	})	
	aAdd(aColunas, {"CNPJ_CPFCLIENTE"	, 'C', "CNPJ_CPFCLIENTE"	})	
	aAdd(aColunas, {"CODPRODUTO"		, 'C', "CODPRODUTO"			})
	aAdd(aColunas, {"DESCPRODUTO"		, 'C', "DESCPRODUTO"		})
	aAdd(aColunas, {"TIPOPRODUTO"		, 'C', "TIPOPRODUTO"		})
	aAdd(aColunas, {"TES"				, 'C', "TES"				})
	aAdd(aColunas, {"CFOP"				, 'C', "CFOP"				})
	aAdd(aColunas, {"QUANTIDADE"		, 'N', "QUANTIDADE"			})
	aAdd(aColunas, {"VALORUNITARIO"		, 'N', "VALORUNITARIO"		})	
	aAdd(aColunas, {"VALORMERCADORIA"	, 'N', "VALORMERCADORIA"	})	
	aAdd(aColunas, {"FATBRUTO"			, 'N', "FATURAMENTOBRUTO"	})	
	aAdd(aColunas, {"FATLIQUIDO"		, 'N', "FATURAMENTOLIQUIDO"})		
	aAdd(aColunas, {"VALORIPI"			, 'N', "VALORIPI"			})
	aAdd(aColunas, {"VALORFRETE"		, 'N', "VALORFRETE"			})	
	aAdd(aColunas, {"VALORDESPESA"		, 'N', "VALORDESPESA"		})	
	aAdd(aColunas, {"VALORSEGURO"		, 'N', "VALORSEGURO"		})	
	aAdd(aColunas, {"VALORICMS_ST"		, 'N', "VALORICMS_ST"		})	
	aAdd(aColunas, {"VALORICMS"			, 'N', "VALORICMS"			})	
	aAdd(aColunas, {"VALORPIS"			, 'N', "VALORPIS"			})
	aAdd(aColunas, {"VALORCOFINS"		, 'N', "VALORCOFINS"		})
	aAdd(aColunas, {"VALORISS"			, 'N', "VALORISS"			})
	aAdd(aColunas, {"NCM"				, 'C', "NCM"				})
	aAdd(aColunas, {"ALIQICMS"			, 'N', "ALIQICMS"			})	
	aAdd(aColunas, {"LOTE"				, 'C', "LOTE"				})
	aAdd(aColunas, {"CHAVENFE"			, 'C', "CHAVENFE"			})	
	aAdd(aColunas, {"FINALIDADETES"		, 'C', "FINALIDADETES"		})
	aAdd(aColunas, {"PEDIDO"			, 'C', "PEDIDO"				})
	aAdd(aColunas, {"EMISSAOPEDIDO"		, 'D', "EMISSAOPEDIDO"		})		
	aAdd(aColunas, {"FABRICANTE"		, 'C', "FABRICANTE"			})	
	aAdd(aColunas, {"FORNECEDOR"		, 'C', "FORNECEDOR"			})	
	aAdd(aColunas, {"NOMEFORNECEDOR"	, 'C', "NOMEFORNECEDOR"		})		
	aAdd(aColunas, {"ATIVIDADE"			, 'C', "ATIVIDADE"			})
	aAdd(aColunas, {"GRUPOPRODUTO"		, 'C', "GRUPOPRODUTO"		})
	aAdd(aColunas, {"GRUPOMRP"			, 'C', "GRUPOMRP"			})
	aAdd(aColunas, {"MRP_SP"			, 'C', "MRP_SP"				})
	aAdd(aColunas, {"CONTRIB"			, 'C', "CONTRIB"			})
	aAdd(aColunas, {"CODVNDINT"			, 'C', "CODVEND_INT"		})	
	aAdd(aColunas, {"NVNDINT"			, 'C', "NOMEVEND_INT"		})	
	aAdd(aColunas, {"CODVNDEXT"			, 'C', "CODVEND_EXT"		})	
	aAdd(aColunas, {"NVNDEXT"			, 'C', "NOMEVEND_EXT"		})	
	aAdd(aColunas, {"GERCOORD"			, 'C', "CODGER_COORD"		})	
	aAdd(aColunas, {"NGCOORD"			, 'C', "NOMEGER_COORD"		})		
	aAdd(aColunas, {"CODESPVEN"			, 'C', "CODESP_VEN"			})	
	aAdd(aColunas, {"NESPVEN"			, 'C', "NOMEESP_VEN"		})	
	aAdd(aColunas, {"CODVNDINTPV"		, 'C', "CODVEND_INT_PV"		})		
	aAdd(aColunas, {"NVNDINTPV"			, 'C', "NOMEVEND_INT_PV"	})
	aAdd(aColunas, {"CODVNDEXTPV"		, 'C', "CODVEND_EXT_PV"		})
	aAdd(aColunas, {"NVNDEXTPV"			, 'C', "NOMEVEND_EXT_PV"	})
	aAdd(aColunas, {"GERCOORDPV"		, 'C', "CODGER_COORD_PV"	})
	aAdd(aColunas, {"NGCOORDPV"			, 'C', "NOMEGER_COORD_PV"	})
	aAdd(aColunas, {"CODESPVENPV"		, 'C', "CODESP_VEN_PV"		})
	aAdd(aColunas, {"NESPVENPV"			, 'C', "NOMEESP_VEN_PV"		})
	aAdd(aColunas, {"PF"				, 'C', "PF"					})
	aAdd(aColunas, {"ME"				, 'C', "ME"					})
	aAdd(aColunas, {"CODTRANSP"			, 'C', "CODTRANSP"			})		
	aAdd(aColunas, {"NOMETRANSP"		, 'C', "NOMETRANSP"			})		
	//             [1]Campo query     [2]Tipo   [3]Coluna na Planilha

	cQuery := ""
	cQuery += "SELECT F2_FILIAL [Filial] "
	cQuery += "	, F2_EMISSAO [DataEmissao] "
	cQuery += ", F2_DOC [NumeroNF] "
	cQuery += ", F2_SERIE [SerieNF] "
	cQuery += ", F2_CLIENTE [CodCliente] "
	cQuery += ", F2_LOJA [LojaCliente] "
	cQuery += ", A1_NOME [NomeCliente] "
	cQuery += ", A1_NREDUZ [FantasiaCliente] "
	cQuery += ", A1_BAIRRO [BairroCliente] "
	cQuery += ", A1_EST [UFCliente] "
	cQuery += ", A1_MUN [MunicipioCliente] "
	cQuery += ", A1_CGC [CNPJ_CPFCliente] "
	cQuery += ", D2_COD [CodProduto] "
	cQuery += ", B1_DESC [DescProduto] "
	cQuery += ", B1_TIPO [TipoProduto] "
	cQuery += ", D2_TES [TES] "
	cQuery += ", D2_CF [CFOP] "
	cQuery += ", D2_QUANT [Quantidade] "
	cQuery += ", D2_PRCVEN [ValorUnitario] "
	cQuery += ", D2_TOTAL [ValorMercadoria] "
	cQuery += ", (D2_TOTAL+IIF(F2_TIPO='P',0,D2_VALIPI)+D2_VALFRE+D2_DESPESA+D2_SEGURO+D2_ICMSRET) [FatBruto]  "
	cQuery += ", ((D2_TOTAL+D2_VALFRE-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_VALISS)) [FatLiquido] "
	cQuery += ", D2_VALIPI [ValorIPI] "
	cQuery += ", D2_VALFRE [ValorFrete] "
	cQuery += ", D2_DESPESA [ValorDespesa] "
	cQuery += ", D2_SEGURO [ValorSeguro] "
	cQuery += ", D2_ICMSRET [ValorICMS_ST] "
	cQuery += ", D2_VALICM [ValorICMS] "
	cQuery += ", D2_VALIMP6 [ValorPIS] "
	cQuery += ", D2_VALIMP5 [ValorCOFINS] "
	cQuery += ", D2_VALISS [ValorISS] "
	cQuery += ", B1_POSIPI [NCM] "
	cQuery += ", D2_PICM [AliqICMS] "
	cQuery += ", D2_LOTECTL [Lote] "
	cQuery += ", F2_CHVNFE [ChaveNFe] "
	cQuery += ", F4_CRVDESC [FinalidadeTES] "
	cQuery += ", D2_PEDIDO [Pedido] "
	cQuery += ", C5_EMISSAO [EmissaoPedido] "
	cQuery += ", B1_FABRIC [Fabricante] "
	cQuery += ", B1_PROC [Fornecedor] "
	cQuery += ", A2_NOME [NomeFornecedor] "
	cQuery += ", SX5.X5_DESCRI [Atividade] "
	cQuery += ", SBM.BM_DESC [GrupoProduto] "
	cQuery += ", B1_CRVGRUP [GrupoMRP] "
	cQuery += ", B1_XGRUPSP [MRP_SP] "
	cQuery += ", A1_CONTRIB [Contrib] "
	cQuery += ", A1_VEND [CodVndInt] "
	cQuery += ", SA31.A3_NOME [NVndInt] "
	cQuery += ", A1_CRVVEN2 [CodVndExt] "
	cQuery += ", SA32.A3_NOME [NVndExt] "
	cQuery += ", A1_CRVVEN3 [GerCoord] "
	cQuery += ", SA33.A3_NOME [NGCoord] "
	cQuery += ", A1_CRVEND4 [CodEspVen] "
	cQuery += ", SA34.A3_NOME [NEspVen] "
	cQuery += ", C5_VEND1 [CodVndIntPV] "
	cQuery += ", SA311.A3_NOME [NVndIntPV] "
	cQuery += ", C5_VEND2 [CodVndExtPV] "
	cQuery += ", SA322.A3_NOME [NVndExtPV] "
	cQuery += ", C5_VEND3 [GerCoordPV] "
	cQuery += ", SA333.A3_NOME [NGCoordPV] "
	cQuery += ", C5_VEND4 [CodEspVenPV] "
	cQuery += ", SA344.A3_NOME [NEspVenPV] "
	cQuery += ", B1_CRVPF [PF] "
	cQuery += ", B1_CRVME [ME] "
	cQuery += ", F2_TRANSP [CodTransp] "
	cQuery += ", A4_NOME [NomeTransp] "
	cQuery += "  FROM "+RetSqlName("SF2")+" SF2 "
	cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '' AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA "
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '' AND SB1.B1_COD = SD2.D2_COD "
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND SF4.F4_FILIAL = SF2.F2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES "
	cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_ = ' ' AND SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SD2.D2_PEDIDO "
	cQuery += "  LEFT JOIN "+RetSqlName("SA4")+" SA4 ON SA4.D_E_L_E_T_ = ' ' AND SA4.A4_FILIAL = '' AND SA4.A4_COD = SF2.F2_TRANSP "
	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND SBM.BM_FILIAL = '' AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_FILIAL = '' AND SA2.A2_COD = SB1.B1_PROC AND SA2.A2_LOJA = SB1.B1_LOJPROC "
	cQuery += "  LEFT JOIN "+RetSqlName("SX5")+" SX5 ON SX5.D_E_L_E_T_ = ' ' AND SX5.X5_TABELA = 'T3' AND SA1.A1_SATIV1 = SX5.X5_CHAVE "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA31 ON SA31.D_E_L_E_T_ = ' ' AND SA31.A3_FILIAL = '' AND SA31.A3_COD = SA1.A1_VEND "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA32 ON SA32.D_E_L_E_T_ = ' ' AND SA32.A3_FILIAL = '' AND SA32.A3_COD = SA1.A1_CRVVEN2 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA33 ON SA33.D_E_L_E_T_ = ' ' AND SA33.A3_FILIAL = '' AND SA33.A3_COD = SA1.A1_CRVVEN3 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA34 ON SA34.D_E_L_E_T_ = ' ' AND SA34.A3_FILIAL = '' AND SA34.A3_COD = SA1.A1_CRVEND4 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA311 ON SA311.D_E_L_E_T_ = ' ' AND SA311.A3_FILIAL = '' AND SA311.A3_COD = SC5.C5_VEND1 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA322 ON SA322.D_E_L_E_T_ = ' ' AND SA322.A3_FILIAL = '' AND SA322.A3_COD = SC5.C5_VEND2 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA333 ON SA333.D_E_L_E_T_ = ' ' AND SA333.A3_FILIAL = '' AND SA333.A3_COD = SC5.C5_VEND3 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA344 ON SA344.D_E_L_E_T_ = ' ' AND SA344.A3_FILIAL = '' AND SA344.A3_COD = SC5.C5_VEND4 "
	cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SF2.F2_FILIAL > ' ' "	//	BETWEEN %Exp:MV_PAR03% and %Exp:MV_PAR04% "
	cQuery += "   AND SF2.F2_TIPO IN ('N','C','P') "
	cQuery += "   AND SF2.F2_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%'"
	cQuery += "   AND (SF4.F4_DUPLIC = 'S' OR SD2.D2_CF IN ('5116','6116','5117','6117')) "
	cQuery += "   AND SD2.D2_CF NOT IN ('5922','6922') "
	//cQuery += "AND SA1.A1_EST BETWEEN %Exp:MV_PAR05% and %Exp:MV_PAR06%  "
	//cQuery += "AND SB1.B1_FABRIC BETWEEN %Exp:MV_PAR07% and %Exp:MV_PAR08% "
	//cQuery += "AND SA1.A1_VEND BETWEEN %Exp:MV_PAR09% and %Exp:MV_PAR10% "
	//cQuery += "AND SA1.A1_CRVVEN2 BETWEEN %Exp:MV_PAR11% and %Exp:MV_PAR12% "
	//cQuery += "AND SA1.A1_CRVVEN3 BETWEEN %Exp:MV_PAR13% and %Exp:MV_PAR14%  "
	//cQuery += "AND SC5.C5_VEND1 BETWEEN %Exp:MV_PAR15% and %Exp:MV_PAR16% "
	//cQuery += "AND SC5.C5_VEND2 BETWEEN %Exp:MV_PAR17% and %Exp:MV_PAR18% "
	//cQuery += "AND SC5.C5_VEND3 BETWEEN %Exp:MV_PAR19% and %Exp:MV_PAR20%  "
	If !lSemFiltroVend
		cQuery += "   AND ( SC5.C5_VEND1 = '"+cCodVend+"' OR SC5.C5_VEND2 = '"+cCodVend+"' OR SC5.C5_VEND4 = '"+cCodVend+"' ) "
		cQuery += "   AND ( SA1.A1_VEND = '"+cCodVend+"' OR SA1.A1_CRVVEN2 = '"+cCodVend+"' OR SA1.A1_CRVVEN3 = '"+cCodVend+"' ) "
	Endif
	cQuery += "		AND F2_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' " //26/03/2026 - Por Fernando Cerqueira - TecSistem - Insrindo LIKE FORMAT(GETDATE(), 'yyyyMM')

	cQuery += " UNION ALL "

	cQuery += " SELECT F1_FILIAL [Filial] "
	cQuery += ", F1_DTDIGIT [DataEmissao] "
	cQuery += ", F1_DOC [NumeroNF] "
	cQuery += ", F1_SERIE [SerieNF] "
	cQuery += ", F1_FORNECE [CodCliente] "
	cQuery += ", F1_LOJA [LojaCliente] "
	cQuery += ", A1_NOME [NomeCliente] "
	cQuery += ", A1_NREDUZ [FantasiaCliente] "
	cQuery += ", A1_BAIRRO [BairroCliente] "
	cQuery += ", A1_EST [UFCliente] "
	cQuery += ", A1_MUN [MunicipioCliente] "
	cQuery += ", A1_CGC [CNPJ_CPFCliente] "
	cQuery += ", D1_COD [CodProduto] "
	cQuery += ", B1_DESC [DescProduto] "
	cQuery += ", B1_TIPO [TipoProduto] "
	cQuery += ", D1_TES [TES] "
	cQuery += ", D1_CF [CFOP] "
	cQuery += ", D1_QUANT*(-1) [Quantidade] "
	cQuery += ", D1_VUNIT*(-1) [ValorUnitario] "
	cQuery += ", D1_TOTAL*(-1) [ValorMercadoria] "
	cQuery += ", (D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET)*(-1) [FatBruto]  "
	cQuery += ", ((D1_TOTAL+D1_VALFRE-D1_VALICM-D1_VALIMP5-D1_VALIMP6)*(-1)) [FatLiquido] "
	cQuery += ", D1_VALIPI*(-1) [ValorIPI] "
	cQuery += ", D1_VALFRE*(-1) [ValorFrete] "
	cQuery += ", D1_DESPESA*(-1) [ValorDespesa] "
	cQuery += ", D1_SEGURO*(-1) [ValorSeguro] "
	cQuery += ", D1_ICMSRET*(-1) [ValorICMS_ST] "
	cQuery += ", D1_VALICM*(-1) [ValorICMS] "
	cQuery += ", D1_VALIMP6*(-1) [ValorPIS] "
	cQuery += ", D1_VALIMP5*(-1) [ValorCOFINS] "
	cQuery += ", 0 [ValorISS] "
	cQuery += ", B1_POSIPI [NCM] "
	cQuery += ", D1_PICM [AliqICMS] "
	cQuery += ", D1_LOTECTL [Lote] "
	cQuery += ", F1_CHVNFE [ChaveNFe] "
	cQuery += ", F4_CRVDESC [FinalidadeTES] "
	cQuery += ", '' [Pedido] "
	cQuery += ", '' [EmissaoPedido] "
	cQuery += ", B1_FABRIC [Fabricante] "
	cQuery += ", B1_PROC [Fornecedor] "
	cQuery += ", A2_NOME [NomeFornecedor] "
	cQuery += ", SX5.X5_DESCRI [Atividade] "
	cQuery += ", SBM.BM_DESC [GrupoProduto] "
	cQuery += ", B1_CRVGRUP [GrupoMRP] "
	cQuery += ", B1_XGRUPSP [MRP_SP] "
	cQuery += ", A1_CONTRIB [Contrib] "
	cQuery += ", A1_VEND [CodVndInt] "
	cQuery += ", SA31.A3_NOME [NVndInt] "
	cQuery += ", A1_CRVVEN2 [CodVndExt] "
	cQuery += ", SA32.A3_NOME [NVndExt] "
	cQuery += ", A1_CRVVEN3 [GerCoord] "
	cQuery += ", SA33.A3_NOME [NGCoord] "
	cQuery += ", A1_CRVEND4 [CodEspVen] "
	cQuery += ", SA34.A3_NOME [NEspVen] "
	cQuery += ", '' [CodVndIntPV] "
	cQuery += ", '' [NVndIntPV] "
	cQuery += ", '' [CodVndExtPV] "
	cQuery += ", '' [NVndExtPV] "
	cQuery += ", '' [GerCoordPV] "
	cQuery += ", '' [NomeGerCoordPV] "
	cQuery += ", '' [CodEspVenPV] "
	cQuery += ", '' [NEspVenPV] "
	cQuery += ", B1_CRVPF [PF] "
	cQuery += ", B1_CRVME [ME] "
	cQuery += ", '' [CodTransp] "
	cQuery += ", '' [NomeTransp] "
	cQuery += "  FROM "+RetSqlName("SF1")+" SF1 "
	cQuery += "  INNER JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D_E_L_E_T_ = ' ' AND SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA "
	cQuery += "  INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '' AND SA1.A1_COD = SF1.F1_FORNECE AND SA1.A1_LOJA = SF1.F1_LOJA "
	cQuery += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_FILIAL = '' AND SB1.B1_COD = SD1.D1_COD "
	cQuery += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND SF4.F4_FILIAL = SF1.F1_FILIAL AND SF4.F4_CODIGO = SD1.D1_TES "
	cQuery += "  LEFT JOIN "+RetSqlName("SBM")+" SBM ON SBM.D_E_L_E_T_ = ' ' AND SBM.BM_FILIAL = '' AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND SA2.A2_FILIAL = '' AND SA2.A2_COD = SB1.B1_PROC AND SA2.A2_LOJA = SB1.B1_LOJPROC "
	cQuery += "  LEFT JOIN "+RetSqlName("SX5")+" SX5 ON SX5.D_E_L_E_T_ = ' ' AND SX5.X5_TABELA = 'T3' AND SA1.A1_SATIV1 = SX5.X5_CHAVE "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA31 ON SA31.D_E_L_E_T_ = ' ' AND SA31.A3_FILIAL = '' AND SA31.A3_COD = SA1.A1_VEND "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA32 ON SA32.D_E_L_E_T_ = ' ' AND SA32.A3_FILIAL = '' AND SA32.A3_COD = SA1.A1_CRVVEN2 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA33 ON SA33.D_E_L_E_T_ = ' ' AND SA33.A3_FILIAL = '' AND SA33.A3_COD = SA1.A1_CRVVEN3 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA34 ON SA34.D_E_L_E_T_ = ' ' AND SA34.A3_FILIAL = '' AND SA34.A3_COD = SA1.A1_CRVEND4 "
	cQuery += " WHERE SF1.D_E_L_E_T_ = ' ' "
	//cQuery += "AND SF1.F1_FILIAL BETWEEN %Exp:MV_PAR03% and %Exp:MV_PAR04% "
	cQuery += "AND SF1.F1_TIPO = 'D' "
	cQuery += "AND SF1.F1_DTDIGIT LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' " //26/03/2026 - Por Fernando Cerqueira - TecSistem - Insrindo LIKE FORMAT(GETDATE(), 'yyyyMM')
	cQuery += "AND SF4.F4_DUPLIC = 'S' "
	//cQuery += "AND SA1.A1_EST BETWEEN %Exp:MV_PAR05% and %Exp:MV_PAR06%  "
	//cQuery += "AND SB1.B1_FABRIC BETWEEN %Exp:MV_PAR07% and %Exp:MV_PAR08% "
	//cQuery += "AND SA1.A1_VEND BETWEEN %Exp:MV_PAR15% and %Exp:MV_PAR16% "
	//cQuery += "AND SA1.A1_CRVVEN2 BETWEEN %Exp:MV_PAR17% and %Exp:MV_PAR18% "
	//cQuery += "AND SA1.A1_CRVVEN3 BETWEEN %Exp:MV_PAR19% and %Exp:MV_PAR20%  "
	If !lSemFiltroVend
		cQuery += "AND ( SA1.A1_VEND = '"+cCodVend+"' OR SA1.A1_CRVVEN2 = '"+cCodVend+"' OR SA1.A1_CRVVEN3 = '"+cCodVend+"' ) "
	Endif
	cQuery += "		AND F1_DTDIGIT LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' " //26/03/2026 - Por Fernando Cerqueira - TecSistem - Insrindo LIKE FORMAT(GETDATE(), 'yyyyMM')
	cQuery += "ORDER BY Filial, DataEmissao, NumeroNF, SerieNF"
 
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	cTemp := GetNextAlias()	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	// ajustra os campos data
	For nA := 1 to Len(aColunas)
		if aColunas[nA,2] == "D"
			TcSetField(cTemp, aColunas[nA,2], "D")
		Endif	
	Next

	//Aba Pedidos em Aberto
	cAbaNotaMes := "Notas_Mes"
	cDesNotaMes := "Notas_do_Mes"
	oFWMsExcel:AddworkSheet(cAbaNotaMes)

	//Criando a Tabela
	oFWMsExcel:AddTable(cAbaNotaMes,cDesNotaMes,.F.)

	// cria as colunas conforme layout
	For nA := 1 to Len(aColunas)
		nAlign := if(aColunas[nA,2]=="N",nRight ,if(aColunas[nA,2]=="D",nCenter,   nLeft   ) )
		nTipo  := if(aColunas[nA,2]=="N",nNumber,if(aColunas[nA,2]=="D",nDateTime, nGeneral) )

		oFWMsExcel:AddColumn(cAbaNotaMes,cDesNotaMes,aColunas[nA,3],1)
	Next

	Do While !((cTemp)->(Eof()))

		// carrega os dados para a linha da planilha respeitando o layout
		aTmp := Array(Len(aColunas))
		For nA := 1 to Len(aColunas)
			cConteudo := (cTemp)->( &(aColunas[nA,1]))
			aTmp[nA] := cConteudo
		Next

		oFWMsExcel:AddRow(cAbaNotaMes,cDesNotaMes,Aclone(aTmp) )
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())


	//========================= 4 - CRIANDO A ABA CARTEIRA PENDENTE ================================================
	cTemp  := GetNextAlias()

	aColunas := {}
	aAdd(aColunas, {'C5_FILIAL'				,'C' ,'Filial'})
	aAdd(aColunas, {'C5_NUM'				,'C' ,'Pedido'})
	aAdd(aColunas, {'C5_EMISSAO'			,'D' ,'Data Emissao'})
	aAdd(aColunas, {'F2_EMISSAO'			,'D' ,'Data Faturamento'})
	aAdd(aColunas, {'F2_DTENTR'				,'D' ,'Data Entrega'})
	aAdd(aColunas, {'Fatura'				,'C' ,'Fatura?'})
	aAdd(aColunas, {'C5_CLIENTE'			,'C' ,'Cod. Cliente'})
	aAdd(aColunas, {'A1_NOME'				,'C' ,'Nome Cliente'})
	aAdd(aColunas, {'C6_ITEM'				,'C' ,'Item'})
	aAdd(aColunas, {'C6_PRODUTO'			,'C' ,'Produto'})
	aAdd(aColunas, {'B1_DESC'				,'C' ,'Descricao'})
	aAdd(aColunas, {'B1_PROC'				,'C' ,'Fornecedor'})
	aAdd(aColunas, {'B1_FABRIC'				,'C' ,'Fabricante/Marca'})
	aAdd(aColunas, {'Saldo_Atual'			,'N' ,'Est. Total'})
	aAdd(aColunas, {'Saldo_Disponivel'		,'N' ,'Est. Disponivel'})
	aAdd(aColunas, {'QTD_PENDENTE'			,'N' ,'Qtd. Pendente'})
	aAdd(aColunas, {'D2_QUANT'				,'N' ,'Qtd. Venda'})
	aAdd(aColunas, {'D2_PRCVEN'				,'N' ,'Prc. Unit.'})
	aAdd(aColunas, {'VAL_PEND_IPI'			,'N' ,'Vlr. Pend. c/ IPI'})
	aAdd(aColunas, {'VAL_TOT_IPI'			,'N' ,'Vlr. Tot. c/ IPI'})
	aAdd(aColunas, {'Vend_Interno'			,'C' ,'Vend. Interno'})
	aAdd(aColunas, {'Vend_Externo'			,'C' ,'Vend. Externo'})
	aAdd(aColunas, {'GerCoor'				,'C' ,'Ger/Coord.'})
	aAdd(aColunas, {'F2_VEND4'				,'C' ,'Vendedor 4'})
	aAdd(aColunas, {'F2_TPFRETE'			,'C' ,'Tp. Frete'})
	aAdd(aColunas, {'Pedido_Origem'			,'C' ,'Ped. Origem'})
	aAdd(aColunas, {'Pedido_WEB'			,'C' ,'Ped. WEB'})
	aAdd(aColunas, {'Pedido_Cliente'		,'C' ,'Ped. Cliente'})
	aAdd(aColunas, {"PE_ATUALIZADO"			,'C' ,'P.E. Atualizado'})
	aAdd(aColunas, {"NovoStatus"			,'C' ,'Status'})
	aAdd(aColunas, {"Aglutina_OC"			,'C' ,'Aglutina OC'})
	aAdd(aColunas, {"Aceite_Faturamento"	,'C' ,'Aceite Fat.'})
	aAdd(aColunas, {"Limite_Faturamento"	,'C' ,'Limite Fat.'})
	aAdd(aColunas, {"Dados_Responsavel"		,'C' ,'Dados Resp.'})
	aAdd(aColunas, {'C5_TIPO'				,'C' ,'Tipo Pedido'})
	aAdd(aColunas, {'FREQUENCIA'			,'N' ,'Frequencia'})
	aAdd(aColunas, {'RECORRENCIA'			,'N' ,'Recorrencia'})
	aAdd(aColunas, {'ID_UF'					,'C' ,'ID UF'})
	aAdd(aColunas, {"Encerrado"				,'C' ,'Situacao'})
	aAdd(aColunas, {'Cod_Transportadora'	,'C' ,'Cod. Transp.'})
	aAdd(aColunas, {'Nome_Transportadora'	,'C' ,'Nome Transp.'})
	aAdd(aColunas, {'C6_NUMORC'				,'C' ,'Num Orcamento'})
	aAdd(aColunas, {'DATA_GERACAO'			,'D' ,'Data Geracao Dados'})
	aAdd(aColunas, {'HORA_GERACAO'			,'C' ,'Hora Geracao Dados'})
	//             [1]Campo query         [2]Tipo  [3]Coluna na Planilha
	
	cQuery := " "
	/*cQuery += " SELECT ZV_FILIAL, ZV_PEDIDO, ZV_EMISSAO, ZV_DTFAT, ZV_FATURA, ZV_CLIENTE, ZV_NMCLI, ZV_ITEM,  	 "
	cQuery += " ZV_PROD, ZV_DESC, ZV_FORN, ZV_FABR, ZV_SLDATU, ZV_SLDDISP, ZV_QTDVEN, ZV_QTDSLD, ZV_PRCUNIT,  	 "
	cQuery += " ZV_TOTAL, ZV_INTERNO, ZV_EXTERNO, ZV_COORD, ZV_TPFRETE, ZV_PEDORI, ZV_PEDWEB,  	 "
	cQuery += " ZV_PEDCLI, ISNULL(CAST(CAST(ZV_PE AS VARBINARY(max)) AS VARCHAR(max)),null) AS ZV_PE,  		 "
	cQuery += " ZV_STATUS, ZV_XAGLOC, ZV_XACFAT, ZV_XLIMFAT, ZV_XRESP, ZV_XIDUF, ZV_ENCER, "
	cQuery += " ZV_TRANS, ZV_NMTRA, "
	cQuery += " ZV_DTGER, ZV_HORA, SZV.R_E_C_N_O_ RECNO "
	cQuery += " FROM "+RetSqlName("SZV")+" SZV "
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_COD = ZV_PROD "
	cQuery += " WHERE SZV.D_E_L_E_T_ = ' ' "
	cQuery += "  AND ZV_FILIAL = '"+xFilial("SZV")+"' "
	cQuery += "  AND ZV_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%'  "
	//cQuery += "AND ZV_DTFAT BETWEEN %Exp:DtoS(mv_par03)% AND %Exp:DtoS(mv_par04)%
	//cQuery += "AND (%Exp:mv_par05% = '      ' OR ZV_CODINT = %Exp:mv_par05%)
	//cQuery += "AND ZV_PROD BETWEEN %Exp:mv_par06% AND %Exp:mv_par07%
	//cQuery += "AND ZV_CLIENTE BETWEEN %Exp:mv_par08% AND %Exp:mv_par09%
	//cQuery += "AND ZV_PEDIDO BETWEEN %Exp:mv_par10% AND %Exp:mv_par11%
	//cQuery += "AND ZV_UF BETWEEN %Exp:mv_par12% AND %Exp:mv_par13%
	//cQuery += "AND B1_GRUPO BETWEEN %Exp:mv_par14% AND %Exp:mv_par15%
	//cQuery += "AND ZV_FABR BETWEEN %Exp:mv_par16% AND %Exp:mv_par17%
	//cQuery += "AND ((ZV_ENCER = 'N' AND %Exp:mv_par18% = 2) OR %Exp:mv_par18% = 3)
	cQuery += "  AND ZV_DTGER + ZV_HORA in ( "
	cQuery += " SELECT top 1 SZV1.ZV_DTGER + SZV1.ZV_HORA "
	cQuery += "  FROM "+RetSqlName("SZV")+" SZV1 "
	cQuery += "  WHERE SZV1.D_E_L_E_T_ = ' ' "
	cQuery += "  AND SZV1.ZV_FILIAL = '"+xFilial("SZV")+"' "
	cQuery += "  AND SZV1.ZV_OK = 'S' "
	cQuery += "  ORDER BY SZV1.ZV_DTGER DESC, SZV1.ZV_HORA DESC "
	cQuery += "  ) "
	cQuery += " UNION ALL "
	*/
	cQuery += "  SELECT C5_FILIAL, C5_NUM, C5_EMISSAO, C6_CRVENT, F2_EMISSAO, F2_DTENTR, F2_DOC, "
	cQuery += "	 CASE WHEN C5_XFATURA = 'S' THEN 'SIM' ELSE 'não' END Fatura, "
	cQuery += "	 C5_CLIENTE, A1_NOME, C6_ITEM, C6_PRODUTO, C6_DESCRI, B1_DESC, B1_PROC, B1_FABRIC, "
	cQuery += "  COALESCE(A2_NOME,''), C6_NUMORC, ' ' PE_ATUALIZADO, 0 FREQUENCIA, 0 RECORRENCIA, "
	cQuery += "  COALESCE(SB2.B2_QATU,0) [Saldo_Atual], "
	cQuery += "  COALESCE(SB2.B2_QATU-SB2.B2_RESERVA,0) [Saldo_Disponivel], "
	cQuery += "  (C6_QTDVEN - C6_QTDENT) [QTD_PENDENTE], D2_QUANT [D2_QUANT], D2_PRCVEN [D2_PRCVEN], (D2_QUANT*D2_PRCVEN*(1+(D2_IPI/100))) [VAL_PEND_IPI], (D2_QUANT*D2_PRCVEN*(1+(D2_IPI/100))) [VAL_TOT_IPI], "
	cQuery += "  COALESCE(SA3INT.A3_NREDUZ,'') [Vend_Interno], "
	cQuery += "  COALESCE(SA3EXT.A3_NREDUZ,'') [Vend_Externo], "
	cQuery += "  COALESCE(SA3GER.A3_NREDUZ,'') [GerCoor], "
	cQuery += "  C5_VEND4 [F2_VEND4], "
	cQuery += "  CASE WHEN C5_TPFRETE = 'C' THEN 'CIF' WHEN C5_TPFRETE = 'F' THEN 'FOB' WHEN C5_TPFRETE = 'T' THEN 'TERCEIROS' WHEN C5_TPFRETE = 'R' THEN 'REMETENTE' WHEN C5_TPFRETE = 'D' THEN 'DESTINATARIO' WHEN C5_TPFRETE = 'S' THEN 'SEM FRETE' END [F2_TPFRETE], "
	cQuery += "  C6_XNUMOG [Pedido_Origem], "
	cQuery += "  C5_XPEDWEB [Pedido_WEB], "
	cQuery += "  C6_XPEDCLI [Pedido_Cliente], "
	cQuery += "  '' ZV_PE, "
	cQuery += "  CASE WHEN F2_CRVROM <> '' THEN '12 - Coletado em ' + CONVERT(VARCHAR,CAST(ZI_DATA AS DATE), 103) + ', NF ' + F2_DOC "
	cQuery += "  WHEN F2_CRVROM = '' THEN '11 - Faturado, NF ' + F2_DOC  "
	cQuery += "  END AS NovoStatus, "
	cQuery += "  CASE WHEN C5_XAGLOC = 'S' THEN 'SIM' WHEN C5_XAGLOC = 'N' THEN 'não' ELSE '' END [Aglutina_OC], "
	cQuery += "  CASE WHEN C5_XACFAT = '1' THEN 'Pedido Parcial' WHEN C5_XAGLOC = '2' THEN 'Pedido Completo' ELSE '' END [Aceite_Faturamento], "
	cQuery += "  C5_XLIMFAT [Limite_Faturamento], "
	cQuery += "  C5_XRESP [Dados_Responsavel], "
	cQuery += "  C5_TIPO [C5_TIPO], "
	cQuery += "  C5_XIDUF [ID_UF], "
	cQuery += "  'S' [Encerrado], "
	cQuery += "  ISNULL(A4_COD,'') [Cod_Transportadora], "
	cQuery += "  ISNULL(A4_NOME,'') [Nome_Transportadora], "
	cQuery += "  '" + Dtoc(MsDate()) + "' [Data_Geracao] , "
	cQuery += "  '"+Time()+"' [Hora_Geracao] "
	cQuery += "  FROM "+RetSqlName("SC6")+" SC6 "
	cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_ = ' ' AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = C6_NUM  "
	cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL = '"+xFilial("SD2")+"' AND D2_PEDIDO = C6_NUM AND D2_ITEMPV = C6_ITEM "
	cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_ = ' ' AND F2_FILIAL = '"+xFilial("SF2")+"' AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE "
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_ = ' ' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI  "
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C6_PRODUTO  "
	cQuery += " INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_ = ' ' AND F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S'  "
	cQuery += " INNER JOIN "+RetSqlName("SE4")+" SE4 ON SE4.D_E_L_E_T_ = ' ' AND E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = C5_CONDPAG  "
	cQuery += "  LEFT JOIN "+RetSqlName("SZI")+" SZI ON SZI.D_E_L_E_T_ = ' ' AND ZI_FILIAL = '"+xFilial("SZI")+"' AND ZI_NUM = F2_CRVROM "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA3INT ON SA3INT.D_E_L_E_T_ = ' ' AND SA3INT.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3INT.A3_COD = C5_VEND1 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA3EXT ON SA3EXT.D_E_L_E_T_ = ' ' AND SA3EXT.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3EXT.A3_COD = C5_VEND2 "
	cQuery += "  LEFT JOIN "+RetSqlName("SA3")+" SA3GER ON SA3GER.D_E_L_E_T_ = ' ' AND SA3GER.A3_FILIAL = '"+xFilial("SA3")+"' AND SA3GER.A3_COD = C5_VEND3 "
	cQuery += "  LEFT JOIN "+RetSqlName("SB2")+" SB2 ON SB2.D_E_L_E_T_ = ' ' AND B2_FILIAL = '"+xFilial("SB2")+"' AND SB2.B2_COD = C6_PRODUTO AND SB2.B2_LOCAL = SB2.B2_FILIAL  "
	cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.D_E_L_E_T_ = ' ' AND A2_FILIAL = '"+xFilial("SA2")+"' AND B1_PROC = A2_COD AND B1_LOJPROC = A2_LOJA  "
	cQuery += "  LEFT JOIN "+RetSqlName("SA4")+" SA4 ON SA4.D_E_L_E_T_ = ' ' AND A4_FILIAL = '"+xFilial("SA4")+"' AND A4_COD = F2_TRANSP  "
	cQuery += " WHERE SC6.D_E_L_E_T_ = ' ' AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery += "   AND C5_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' "
	//cQuery += "AND C6_CRVENT BETWEEN %Exp:DtoS(mv_par03)% AND %Exp:DtoS(mv_par04)%
	//cQuery += "AND (%Exp:mv_par05% = '      ' OR SA3INT.A3_COD = %Exp:mv_par05%)
	//cQuery += "AND C6_PRODUTO BETWEEN %Exp:mv_par06% AND %Exp:mv_par07%
	//cQuery += "AND C5_CLIENTE BETWEEN %Exp:mv_par08% AND %Exp:mv_par09%
	//cQuery += "AND C5_NUM BETWEEN %Exp:mv_par10% AND %Exp:mv_par11%
	//cQuery += "AND A1_EST BETWEEN %Exp:mv_par12% AND %Exp:mv_par13%
	//cQuery += "AND B1_GRUPO BETWEEN %Exp:mv_par14% AND %Exp:mv_par15%
	//cQuery += "AND B1_FABRIC BETWEEN %Exp:mv_par16% AND %Exp:mv_par17%
	//cQuery += "AND (%Exp:mv_par18% = 1 OR %Exp:mv_par18% = 3)
	If !lSemFiltroVend
		cQuery += "	 AND ( C5_VEND1 = '"+cCodVend+"' OR C5_VEND2 = '"+cCodVend+"' OR C5_VEND3 = '"+cCodVend+"' ) "
	Endif
	cQuery += "	 AND C5_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' " //26/03/2026 - Por Fernando Cerqueira - TecSistem - Insrindo LIKE FORMAT(GETDATE(), 'yyyyMM')
	cQuery += "  ORDER BY C5_FILIAL, C6_PRODUTO, C5_EMISSAO, F2_EMISSAO"

	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea())
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	cTemp := GetNextAlias()	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	// ajustra os campos data
	For nA := 1 to Len(aColunas)
		if aColunas[nA,2] == "D"
			TcSetField(cTemp, aColunas[nA,2], "D")
		Endif	
	Next

	//Aba Pedidos em Aberto
	cAbaCarteira := "Carteira"
	cDesCarteira := "Carteira_Pendente"
	oFWMsExcel:AddworkSheet(cAbaCarteira)

	//Criando a Tabela
	oFWMsExcel:AddTable(cAbaCarteira,cDesCarteira,.F.)

	// cria as colunas conforme layout
	For nA := 1 to Len(aColunas)
		nAlign := if(aColunas[nA,2]=="N",nRight ,if(aColunas[nA,2]=="D",nCenter,   nLeft   ) )
		nTipo  := if(aColunas[nA,2]=="N",nNumber,if(aColunas[nA,2]=="D",nDateTime, nGeneral) )

		oFWMsExcel:AddColumn(cAbaCarteira,cDesCarteira,aColunas[nA,3],1)
	Next

	Do While !((cTemp)->(Eof()))

		// carrega os dados para a linha da planilha respeitando o layout
		aTmp := Array(Len(aColunas))
		For nA := 1 to Len(aColunas)
			cConteudo := (cTemp)->( &(aColunas[nA,1]))
			aTmp[nA] := cConteudo
		Next

		oFWMsExcel:AddRow(cAbaCarteira,cDesCarteira,Aclone(aTmp) )
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)
	oFWMsExcel:DeActivate()
	
	If Empty(AllTrim(cEmail))
		Return
	Endif

	//Função para o envio dos e-mails 

	If !IsBlind()
		ShellExecute("Open",cArquivo,"","",5) //Abertura da pasta local onde consta o arquivo Excel
		Return
	Endif
	
	xEnvMail(cArquivo,cEmail)

Return


/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informações
Uso: Calibre
Info: Envio de e-mail 
*==================================================================*/
Static Function xEnvMail(cArquivo,cEmail)

	Local cAssunto  := "RELATORIO DE VENDAS"
	Local lMailAuth	:= GetMV("MV_RELAUTH",.F.,.T.) //Autenticaï¿½ï¿½o com server SMTP
	Local nPortSMTP := 587 //informa a porta que o servidor SMTP irï¿½ se comunicar, podendo ser 25 ou 587
	Local nTimeout  := GetMV("MV_RELTIME") //120 //30
	Local xRet
	Local oServer	
	Local oMessage

	//A porta 25, por ser utilizada há mais tempo, possui uma vulnerabilidade maior a
	//ataques e interceptaï¿½ï¿½o de mensagens, alï¿½m de não exigir autenticaï¿½ï¿½o para envio
	//das mensagens, ao contrï¿½rio da 587 que oferece esta seguranï¿½a a mais.

	//Private cMailConta	:= GetMV("MV_RELAUSR") //GetMV("MV_RELACNT") //Conta utilizada para envio do email
	//Private cMailServer	:= AllTrim(StrTran(GetMV("MV_RELSERV"),":587",""))       //Servidor SMTP
	//Private cMailSenha	:= GetMV("MV_RELAPSW")      //Senha da conta de e-mail utilizada para envio
    Private cMailConta := Alltrim(GetMV("MV_RELACNT"))
	Private cMailServer := AllTrim(GetMV("MV_RELSERV"))
	Private cMailSenha := Alltrim(GetMV("MV_RELPSW"))
	Private nPosPort    := AT(":", cMailServer)

	If nPosPort > 0
		nPortSMTP   := Val(SubStr(cMailServer, nPosPort+1))
		cMailServer := AllTrim(SubStr(cMailServer, 1, nPosPort-1))
	EndIf


	oServer := TMailManager():New()
	oServer:SetUseTLS(.T.) //Indica se serï¿½ utilizarï¿½ a comunicaï¿½ï¿½o segura atravï¿½s de TLS (.T.) ou não (.F.)
	oServer:SetUseSSL(.T.) //Indica se serï¿½ utilizarï¿½ a comunicaï¿½ï¿½o segura atravï¿½s de SSL (.T.) ou não (.F.)

	//xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha,, nPortSMTP ) //inicilizar o servidor
    xRet := oServer:Init( "", cMailServer, Alltrim(GetMV("MV_RELFROM")), cMailSenha,, nPortSMTP )

	If xRet <> 0
		MsgAlert("O servidor SMTP nao foi inicializado: " + oServer:GetErrorString( xRet ))
		Return
	Else
		//MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Server inicializado com sucesso...")
	Endif

	xRet := oServer:SetSMTPTimeout(nTimeout) //Indica o tempo de espera em segundos.

	If xRet <> 0
		MsgAlert(cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	Endif

	xRet := oServer:SMTPConnect()

	If xRet <> 0
		MsgAlert("Nao foi possivel conectar ao server SMTP: " + oServer:GetErrorString( xRet ))
		Return
	Else
		//MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Conexao com o server SMTP realizada com sucesso...")
	Endif

	If lMailAuth

		//O mï¿½todo SMTPAuth ao tentar realizar a autenticaï¿½ï¿½o do
		//usuï¿½rio no servidor de e-mail, verifica a configuraï¿½ï¿½o
		//da chave AuthSmtp, na seï¿½ï¿½o [Mail], no arquivo de
		//configuraï¿½ï¿½o (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )

		If xRet <> 0
			MsgAlert("Nao foi possivel autenticar no server SMTP: " + oServer:GetErrorString( xRet ))
			oServer:SMTPDisconnect()
			Return
		Else
			//MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Autenticacao no server realizada com sucesso...")
		Endif

	Endif
	
	oMessage := TMailMessage():New()

	oMessage:Clear()

	oMessage:cDate	  := cValToChar(Date())
	oMessage:cFrom 	  := AllTrim(GetMV("MV_RELFROM",.F.,"no-reply@carvalhaes.net"))
	oMessage:cTo 	  := cEmail
	oMessage:cSubject := cAssunto
	oMessage:cBody 	  := "Segue anexo relatorio de vendas."

	xRet := oMessage:AttachFile(cArquivo)
	
	If xRet < 0
		MsgAlert("N\o foi possivel anexar o arquivo: " + cArquivo)
	Endif

	xRet := oMessage:Send( oServer )

	If xRet <> 0
		MsgAlert("Nao foi possivel enviar o relatorio: " + oServer:GetErrorString( xRet ))
	Else
		//MsgAlert("Relatorio enviado com sucesso...")
	Endif

	xRet := oServer:SMTPDisconnect()

	If xRet <> 0
		MsgAlert("Nao foi possivel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	Else
		//MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Server desconectado com sucesso...")
	Endif

Return 
