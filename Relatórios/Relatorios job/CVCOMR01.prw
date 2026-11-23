#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 03/04/2026
Consultoria: Proativa
Uso: Calibre
Tipo: Relatório
Rotina: Easy Import Control 
Função: CVCOMR01
Info:   Criada chamada para Schedule
************************************************************************/
User Function CVCOMR01()
	Local aEmails := {}
	//Local cEmails := ""
	Local nX      := 0
	
	if IsBlind() .or. Select("SX2") == 0
		RPCSetEnv("01","01",,,"EIC")
	Endif

	fConout(Replicate("#",100))
	fConout("### CVCOMR01 - INICIO DO PROCESSAMENTO" )

	// busca a lista de emails da tabela SX5
	cTabela := "XA"	//	"XZ"
	aEmails := BuscaEmail(cTabela)	// esta função pode ser colocada como user function para ser utilizada nos 3 relatorios
	//cEmails := AllTrim(GetMV("XX_RELDEM",.F.,"rgelamo@calibrescientific.com.br;vinicius@proativatecnologia.com.br"))
	//aEmails := StrToKarr(cEmails,";")

	fConout("### CVCOMR01 - LISTA DE EMAILS CONFIGURADOS: "+ListaEmail(aEmails) )	// esta função pode ser colocada como user function para ser utilizada nos 3 relatorios
	
	If !IsBlind()
		CVCOMR01(.F.,"") //Relatório Itens Comprados - Novo
	Else

		If Len(aEmails) > 0

			For nX := 1 To Len(aEmails)
				fConout(" # CVCOMR01 - ENVIANDO EMAIL PARA "+ aEmails[nX])

				CVCOMR01(.T.,aEmails[nX]) //Relatório Itens Comprados - Novo

			Next nX 

		Endif

	Endif

	fConout("### CVCOMR01 - FIM DO PROCESSAMENTO" )
	fConout(Replicate("#",100))

Return


/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 26/03/2025
Consultoria: Proativa
Uso: Calibre
Tipo: Ponto de Entrada
Rotina: Compras
Função: CVCOMR01
Info: Relatório de demandas para Comprar/Importar
************************************************************************/
Static Function CVCOMR01(lProcess,cMail)

	Local cPerg    := ""
	
	Private aDados := {}
	Private cTemp  := ""
	Private INCLUI := .F. //Para não dar erro na função MSMM re retorno da SYP
	Private lJob   := lProcess
	Private cEmail := cMail

	If !lJob 

		cPerg := Padr("CVCOMR1",10)
   
		//Incluir as perguntas na tabela SX1
		AjustaSX1(cPerg)
		
		If Pergunte(cPerg,.T.)
			FWMsgRun(, {|| xFilQry() }, "Aguarde", "Gerando relatório de acordo com os dados filtrados nos parâmetros...")
		Endif 

	Else 

		mv_par01 := ""
		mv_par02 := "ZZZZZZ"
		mv_par03 := 3 //Todos
		mv_par04 := ""
		mv_par05 := ""
		mv_par06 := ""
		mv_par07 := "ZZZZZZZZZZZZZZZ" 
		mv_par08 := 2 //Todos

		xFilQry()

	Endif 
	
Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 03/04/2025
Consultoria: Proativa
Uso: Carvalhaes
Info: Filtra os dados do relatório
*==================================================================*/
Static Function xFilQry()

	Local cQuery   := ""
	Local cFornDe  := mv_par01 
	Local cFornAte := mv_par02
	Local cModal   := IIf(mv_par03 == 2,'S',IIf(mv_par03 == 1,'N',''))
	Local cMRP     := mv_par04
    Local cFabric  := mv_par05
    Local cProdDe  := mv_par06
    Local cProdAte := mv_par07
	Local cDatDe   := DToS(MonthSub(dDataBase,3))
	Local cDatAte  := DToS(dDataBase)

	Private lTodos := IIf(mv_par08 > 1,.T.,.F.)

	cTemp := GetNextAlias()
 
	cQuery += " SELECT DISTINCT"
	cQuery += "  C6_PRODUTO,B1_DESC,B1_UM,B1_TIPO,B1_CRVGRUP,B1_ESTSEG,B1_CRVMART,B1_PROC, "
	cQuery += "  B1_CRVLE,B1_CRVEMIN, "

	cQuery += "("
	cQuery += " 	SELECT TOP 1 ZB_PRECO FROM "+RetSQLName("SZB")
	cQuery += " 	WHERE ZB_CODFORN = SB1.B1_PROC "
	cQuery += " 	AND ZB_COD = SC6.C6_PRODUTO "
	cQuery += " 	AND ZB_ATIVO = 'S' "
	cQuery += " 	AND D_E_L_E_T_ <> '*' "
	cQuery += " 	ORDER BY ZB_TABELA DESC "
	cQuery += "  ) AS ZB_PRECO, "

	cQuery += "  ("
	cQuery += " 	SELECT TOP 1 ZB_MOEDA FROM "+RetSQLName("SZB") 
	cQuery += " 	WHERE ZB_CODFORN = SB1.B1_PROC "
	cQuery += " 	AND ZB_COD = SC6.C6_PRODUTO "
	cQuery += " 	AND ZB_ATIVO = 'S' "
	cQuery += " 	AND D_E_L_E_T_ <> '*' "
	cQuery += " 	ORDER BY ZB_TABELA DESC "
	cQuery += "  ) AS ZB_MOEDA,"
	
	cQuery += "( "
	cQuery += " SELECT (COALESCE(SUM(C6_QTDVEN),0) - COALESCE(SUM(C6_QTDENT),0)) FROM "+RetSQLName("SC6")+" A "
	cQuery += " INNER JOIN "+RetSQLName("SC5")+" B "
	cQuery += "		ON C5_FILIAL = C6_FILIAL "
	cQuery += "		AND C5_NUM = C6_NUM "
	cQuery += " 	AND B.D_E_L_E_T_ <> '*' "
	cQuery += "  INNER JOIN "+RetSQLName("SF4")+" F4 "
	cQuery += "		ON F4_FILIAL = C6_FILIAL "
	cQuery += "		AND F4_CODIGO = C6_TES "
	cQuery += "		AND F4_ESTOQUE = 'S' "
	cQuery += "		AND F4.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery += " 	AND C6_PRODUTO = SC6.C6_PRODUTO "

	If xFilial("SC6") == '01'
		cQuery += "		AND C6_TES NOT IN ('5A2','5N3','5N4','5N5') "
	Else
		cQuery += "		AND C6_TES NOT IN ('522') "
	Endif 

	cQuery += "		AND C6_BLQ <> 'R' "
	cQuery += "		AND A.D_E_L_E_T_ <> '*' "
	cQuery += " ) AS DEMANDA, "	

	cQuery += "( "
	cQuery += " SELECT COALESCE(SUM(D2_QUANT),0) FROM "+RetSQLName("SD2")+" D " 
	cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery += " 	AND D2_COD = SC6.C6_PRODUTO "
	cQuery += "		AND D2_EMISSAO BETWEEN '"+cDatDe+"' AND '"+cDatAte+"' "
	cQuery += "		AND D.D_E_L_E_T_ <> '*' "
	cQuery += " ) AS QTD_FAT, "
		
	cQuery += "  B1_PRVALID,B1_PE,A2_CRVPZO,A2_CRVPZM,B1_CRVPROC, "
	cQuery += "  B1_FABRIC,B1_XPROIB,B1_CRVDG,B1_CRVDG05,B1_POSIPI,B1_REVIMP, "
	cQuery += "  B1_CREVDES,B1_ORG_ANU,B1_CRVORG2,B1_CRVORG3,B1_PESO,B1_PESBRU,B1_DESC_I,B1_XCONTR,B5_XCOD "

	cQuery += "  FROM "+RetSQLName("SC6")+" SC6 "
	cQuery += "  INNER JOIN "+RetSQLName("SB1")+" SB1 "
	cQuery += " 	ON B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += " 	AND B1_COD = C6_PRODUTO "
	cQuery += " 	AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += "  INNER JOIN "+RetSQLName("SC5")+" SC5 "
	cQuery += " 	ON C5_FILIAL = C6_FILIAL "
	cQuery += " 	AND C5_NUM = C6_NUM "
	cQuery += " 	AND C5_CLIENTE = C6_CLI "
	cQuery += " 	AND C5_LOJACLI = C6_LOJA " 
	cQuery += " 	AND SC5.D_E_L_E_T_ <> '*' "
	cQuery += "  LEFT JOIN "+RetSQLName("SB5")+" SB5 "
	cQuery += "  	ON B5_FILIAL = '"+xFilial("SB5")+"' "
	cQuery += " 	AND B5_COD = B1_COD "
	cQuery += " 	AND SB5.D_E_L_E_T_ <> '*' "
	cQuery += "  INNER JOIN "+RetSQLName("SA2")+" SA2 "
	cQuery += "  	ON A2_FILIAL = '"+xFilial("SA2")+"' "
	cQuery += " 	AND A2_COD = B1_PROC "
	cQuery += " 	AND A2_LOJA = B1_LOJPROC "
	cQuery += " 	AND SA2.D_E_L_E_T_ <> '*' "
	cQuery += "  INNER JOIN "+RetSQLName("SF4")+" F4 "
	cQuery += "		ON F4_FILIAL = C6_FILIAL "
	cQuery += "		AND F4_CODIGO = C6_TES "
	cQuery += "		AND F4_ESTOQUE = 'S' "
	cQuery += "		AND F4.D_E_L_E_T_ <> '*' "
	cQuery += "  WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery += " 	AND C6_NOTA = '' "
	cQuery += " 	AND C5_NOTA = '' "

	If xFilial("SC6") == '01'
		cQuery += "		AND C6_TES NOT IN ('5A2','5N3','5N4','5N5') "
	Else
		cQuery += "		AND C6_TES NOT IN ('522') "
	Endif 

    cQuery += "     AND B1_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' "
    cQuery += " 	AND B1_PROC BETWEEN '"+cFornDe+"' AND '"+cFornAte+"' "
	
	If !Empty(cModal)
		cQuery += " 	AND B1_CRVMART = '"+cModal+"' "
	Endif 
	
    If !Empty(cMRP)
	    cQuery += " 	AND B1_CRVGRUP = '"+cMRP+"' "
    Endif 

    If !Empty(cFabric)
        cQuery += " 	AND B1_FABRIC LIKE '%"+AllTrim(Upper(cFabric))+"%' "
    Endif 

	cQuery += "		AND SC6.D_E_L_E_T_ <> '*' " 
	cQuery += " ORDER BY C6_PRODUTO "

    //Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()			
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	Memowrite("C:\temp\Query_CVCOMR01.sql",cQuery) //Gravação de log

	If Select(cTemp) > 0	
		xProcRel()		
	Else 
		MsgAlert("Não foram encontrados registros com os parâmetros informados!","Atenção")	
	Endif 
	
Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 03/04/2025
Consultoria: Proativa
Uso: Carvalhaes
Info: Processa os dados do relatório
*==================================================================*/
Static Function xProcRel()

	Local oFWMsExcel := Nil
    Local cPasta     := GetMV("XX_XARQUI",.F.,"C:\temp\")
	Local cData      := StrTran(DToS(Date()),"/","")
	Local cHoraAtu   := Time()
	Local cHora      := StrTran(cHoraAtu,":","")
	Local cDtHora    := AllTrim(cData+"_"+cHora)
    Local cArquivo   := IIf(!lJob,cPasta+"DEMANDAS_"+AllTrim(cDtHora)+".xlsx","\spool\"+"DEMANDAS_"+AllTrim(cDtHora)+".xlsx")
	Local nItem      := 1
    Local nSugComp   := 0
	Local nDemanda   := 0
	Local nQtdeEst   := 0
	Local nEstTran   := 0 
	Local nSaldo     := 0
	Local nQtdFat    := 0
    Local nSaldo1    := 0
	Local nSaldo2    := 0
	Local nCobEst    := 0
	Local nPrcTot    := 0
	Local nPOAereo   := 0
	Local nAeProc    := 0
	Local nPOMarit   := 0
	Local nMarProc   := 0
	Local nLocal01   := 0
	Local nLocal02   := 0
	Local nQtdePO    := 0
	Local nMedia3    := 0
	Local nPartes    := GetMV("XX_QTDPROD",.F.,10)
	Local nTxEuro    := 0
	Local nTxDolar   := 0
	Local nTxDia     := 0
	Local nConvDia   := 0
    Local nX         := 0
    Local nY         := 0
	Local nJ         := 0
	Local nQtdMax    := 300
    Local a12Meses   := x12Meses()
    Local aProdutos  := {}
	Local aAba2      := {}
	Local aAba3      := {}
	Local aProds     := {}
    Local cProdutos  := ""
    Local cQuery     := ""
	Local cDtIni     := ""
	Local cDtFim     := ""
	Local cObs       := ""
   
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FwMsExcelXlsx():New()
    
    //Aba 01
    oFWMsExcel:AddworkSheet("Demandas") //Não utilizar número junto com sinal de menos. Ex.: 1-

    //Criando a Tabela
    oFWMsExcel:AddTable("Demandas","Relatorio",.F.)

	oFWMsExcel:SetFont("arial")
	oFWMsExcel:SetFontSize(8)

    //Criando Colunas
    oFWMsExcel:AddColumn("Demandas","Relatorio","Data Geração Relatório",1,1) //1
    oFWMsExcel:AddColumn("Demandas","Relatorio","# Linha",1,1) //2
    oFWMsExcel:AddColumn("Demandas","Relatorio","Fornecedor",1,1) //3
    oFWMsExcel:AddColumn("Demandas","Relatorio","Código de Venda",1,1) //4 
    oFWMsExcel:AddColumn("Demandas","Relatorio","Código de Compra",1,1) //5
    oFWMsExcel:AddColumn("Demandas","Relatorio","Descrição Português",1,1) //6
    oFWMsExcel:AddColumn("Demandas","Relatorio","Descrição Inglês",1,1) //7
    oFWMsExcel:AddColumn("Demandas","Relatorio","Unidade de Medida",1,1) //8
    oFWMsExcel:AddColumn("Demandas","Relatorio","MOQ",1,1) //9
    oFWMsExcel:AddColumn("Demandas","Relatorio","Sugestão de Compra",1,1) //10
    oFWMsExcel:AddColumn("Demandas","Relatorio","Demanda",1,1) //11
	oFWMsExcel:AddColumn("Demandas","Relatorio","Estoque 01",1,1) //13
	oFWMsExcel:AddColumn("Demandas","Relatorio","Estoque 02",1,1) //13
    oFWMsExcel:AddColumn("Demandas","Relatorio","Estoque AC (Transitório)",1,1) //13
    oFWMsExcel:AddColumn("Demandas","Relatorio","Estoque Mínimo",1,1) //14
    oFWMsExcel:AddColumn("Demandas","Relatorio","Estoque de Segurança",1,1) //15
    oFWMsExcel:AddColumn("Demandas","Relatorio","Saldo",1,1) //16
    oFWMsExcel:AddColumn("Demandas","Relatorio","Quantidade Faturada nos Ultimos 3 Meses",1,1) //17
    oFWMsExcel:AddColumn("Demandas","Relatorio","Cobertura atual do Estoque",1,1) //18
    oFWMsExcel:AddColumn("Demandas","Relatorio","Preço Total",1,1) //20
	oFWMsExcel:AddColumn("Demandas","Relatorio","Preço Unit Fornecedor",1,1)
	oFWMsExcel:AddColumn("Demandas","Relatorio","Moeda Fornecedor",1,1)
	oFWMsExcel:AddColumn("Demandas","Relatorio","Preço Unit Fornecedor R$ (tx dia)",1,1)
    oFWMsExcel:AddColumn("Demandas","Relatorio","TP",1,1) //22
    oFWMsExcel:AddColumn("Demandas","Relatorio","Modal Transporte MRP",1,1) //23
    oFWMsExcel:AddColumn("Demandas","Relatorio","MRP Item",1,1) //24
    oFWMsExcel:AddColumn("Demandas","Relatorio","Aéreo - Quantidade PO em Aberto",1,1) //25
    oFWMsExcel:AddColumn("Demandas","Relatorio","Aéreo - Quantidade em Processo",1,1) //26
    oFWMsExcel:AddColumn("Demandas","Relatorio","Marítimo - Quantidade PO em Aberto",1,1) //27
    oFWMsExcel:AddColumn("Demandas","Relatorio","Marítimo - Quantidade em Processo",1,1) //28
    oFWMsExcel:AddColumn("Demandas","Relatorio","Validade Padrão",1,1) //29
    oFWMsExcel:AddColumn("Demandas","Relatorio","Leadtime do Produto",1,1) //30
    oFWMsExcel:AddColumn("Demandas","Relatorio","Leadtime do Fornecedor - Aéreo",1,1) //31
    oFWMsExcel:AddColumn("Demandas","Relatorio","Leadtime do Fornecedor - Marítimo",1,1) //32
    oFWMsExcel:AddColumn("Demandas","Relatorio","País de Origem",1,1) //33
    oFWMsExcel:AddColumn("Demandas","Relatorio","Fabricante",1,1) //34
    oFWMsExcel:AddColumn("Demandas","Relatorio","Proibido Aéreo?",1,1) //35
    oFWMsExcel:AddColumn("Demandas","Relatorio","Perigoso",1,1) //36
	oFWMsExcel:AddColumn("Demandas","Relatorio","Material Controlado",1,1) 
    oFWMsExcel:AddColumn("Demandas","Relatorio","Classe de Risco",1,1) //37
    oFWMsExcel:AddColumn("Demandas","Relatorio","NCM",1,1) //38
    oFWMsExcel:AddColumn("Demandas","Relatorio","Última Rev. Comex",1,1) //39
    oFWMsExcel:AddColumn("Demandas","Relatorio","Última Rev. Descrição",1,1) //40
    oFWMsExcel:AddColumn("Demandas","Relatorio","Org. Anuente 1",1,1) //41
    oFWMsExcel:AddColumn("Demandas","Relatorio","Org. Anuente 2",1,1) //42
    oFWMsExcel:AddColumn("Demandas","Relatorio","Org. Anuente 3",1,1) //43
    oFWMsExcel:AddColumn("Demandas","Relatorio","Peso Líq Unit",1,1) //44
    oFWMsExcel:AddColumn("Demandas","Relatorio","Peso Brut Unit",1,1) //45
	oFWMsExcel:AddColumn("Demandas","Relatorio","Observação",1,1) //45
	
	While !((cTemp)->(Eof()))

		nDemanda  := (cTemp)->DEMANDA //Demanda
		nEstTran  := IIf(Empty(Posicione("SB2",1,xFilial("SB2") + (cTemp)->C6_PRODUTO + "AC","B2_QATU")),0,Posicione("SB2",1,xFilial("SB2") + (cTemp)->C6_PRODUTO + "AC","B2_QATU")) //Estoque Transitório
		nLocal01  := IIf(Empty(Posicione("SB2",1,xFilial("SB2") + (cTemp)->C6_PRODUTO + "01","B2_QATU")),0,Posicione("SB2",1,xFilial("SB2") + (cTemp)->C6_PRODUTO + "01","B2_QATU")) //Estoque Armazém 01
		nLocal02  := IIf(Empty(Posicione("SB2",1,xFilial("SB2") + (cTemp)->C6_PRODUTO + "02","B2_QATU")),0,Posicione("SB2",1,xFilial("SB2") + (cTemp)->C6_PRODUTO + "02","B2_QATU")) //Estoque Armazém 02

		//Saldos em PO
		nPOAereo  := IIf((cTemp)->B1_CRVMART <> 'S',xPO((cTemp)->C6_PRODUTO,1,1)/*(cTemp)->PO_AEREO*/,0) //Aéreo - Quantidade PO em Aberto (Sem Importação)
        nAeProc   := IIf((cTemp)->B1_CRVMART <> 'S',xPO((cTemp)->C6_PRODUTO,2,1)/*(cTemp)->PO_AEIMP*/,0) //Aéreo - Quantidade em Processo (Com Importação)
        nPOMarit  := IIf((cTemp)->B1_CRVMART == 'S',xPO((cTemp)->C6_PRODUTO,1,2)/*(cTemp)->PO_MARIT*/,0) //Marítimo - Quantidade PO em Aberto (Sem Importação)
		nMarProc  := IIf((cTemp)->B1_CRVMART == 'S',xPO((cTemp)->C6_PRODUTO,2,2)/*(cTemp)->PO_MARIMP*/,0) //Marítimo - Quantidade em Processo (Com Importação)
		//---

		//Quantidade em PO
		nQtdePO   := nPOAereo + nAeProc + nPOMarit + nMarProc
		// ---

		nQtdeEst  := (nLocal01 + nLocal02) //Estoque Total
		nQtdFat   := (cTemp)->QTD_FAT //Quantidade Faturada nos Ultimos 3 Meses
		nMedia3   := (nQtdFat/3) //Média do consumo nos ultimos 3 meses - Verificar cálculo com o Ricardo 
		nSaldo    := IIf(((nEstTran + nLocal01 + nLocal02) - nDemanda) < 0,0,((nEstTran + nLocal01 + nLocal02) - nDemanda)) //Saldo
		nSaldo1   := (nQtdePO + nEstTran + nLocal01 + nLocal02) - (nDemanda) //Saldo VC
 		nSaldo2   := 0 //(nMedia3 + nEstTran + nLocal01 + nLocal02 + nQtdePO) - nDemanda //Saldo EV

		//Regra validada com o Ricardo no dia 12/01/2026
		If (nQtdePO + nEstTran + nLocal01 + nLocal02)  > nDemanda
			nSugComp := 0 
			cObs     := "Não necessita compra; a soma do PO+EST supera a demanda"
		Else 
			nSugComp  := Abs(IIf(AllTrim((cTemp)->B1_CRVGRUP) == "VC",nSaldo1,nSaldo2)) //Sugestão de Compra
			cObs      := "Comprar " + cValToChar(nSugComp)
		Endif 
		//---

		If nSugComp == 0
			cObs := "Não necessita compra; a soma do PO+EST supera a demanda"
		Else 
			cObs := "Comprar " + cValToChar(nSugComp)
		Endif 

		If lTodos .Or. nSugComp > 0 //Quando for todos ou quando a sugestão for maior que zero

			//Armazenando os produtos da query principal
			aAdd(aProdutos,AllTrim((cTemp)->C6_PRODUTO))
			// ---

			nCobEst   := (nQtdFat / (cTemp)->B1_ESTSEG) //Cobertura Atual do Estoque
			nPrcTot   := (nQtdFat * nSugComp) //Preço Total
			nTxEuro   := Posicione("SM2",1,dDataBase,"M2_MOEDA2")
			nTxDolar  := Posicione("SM2",1,dDataBase,"M2_MOEDA3")

			//Regra para conversão para a taxa do dia em outras moedas
			If AllTrim((cTemp)->ZB_MOEDA) == "USD"
				nTxDia := nTxDolar
			Elseif AllTrim((cTemp)->ZB_MOEDA) == "EUR" 
				nTxDia := nTxEuro
			Else 
				nTxDia := 0
			Endif 
			// ---

			If nTxDia > 0
				nConvDia  := (cTemp)->ZB_PRECO * nTxDia
			Else 
				nConvDia  := (cTemp)->ZB_PRECO
			Endif 
			
			//Criando as Linhas
			oFWMsExcel:AddRow("Demandas","Relatorio",{;
			cValToChar(dDataBase)+"-"+AllTrim(cHoraAtu),; //1
			cValTochar(nItem),; //2
			AllTrim((cTemp)->B1_PROC),; //3
			AllTrim((cTemp)->C6_PRODUTO),; //4
			AllTrim((cTemp)->B5_XCOD),; //5
			AllTrim((cTemp)->B1_DESC),; //6
			AllTrim(MSMM((cTemp)->B1_DESC_I,36)),; //7
			AllTrim((cTemp)->B1_UM),; //8
			cValTochar((cTemp)->B1_CRVLE),; //9
			IIf(AllTrim((cTemp)->B1_CRVGRUP) == "VC",cValTochar(Round(nSugComp,2)),"---"),; //10
			cValTochar(nDemanda),; //11
			cValToChar(nLocal01),;
			cValToChar(nLocal02),;
			cValTochar(nEstTran),; //13
			cValTochar((cTemp)->B1_CRVEMIN),; //14
			cValToChar((cTemp)->B1_ESTSEG),; //15
			cValTochar(nSaldo),; //16
			cValToChar(nQtdFat),; //17
			cValToChar(nCobEst),; //18
			Transform(nPrcTot,"@E 99,999,999,999.99"),; //20
			Transform((cTemp)->ZB_PRECO,"@E 99,999,999,999.99"),; 
			AllTrim((cTemp)->ZB_MOEDA),;
			cValToChar(nConvDia),;
			AllTrim((cTemp)->B1_TIPO),; //22
			IIf(AllTrim((cTemp)->B1_CRVMART) == 'S','Sea','Air'),; //23
			AllTrim((cTemp)->B1_CRVGRUP),; //24
			cValToChar(nPOAereo),; //25
			cValToChar(nAeProc),; //26
			cValToChar(nPOMarit),; //27
			cValToChar(nMarProc),; //28
			cValToChar((cTemp)->B1_PRVALID),; //29
			cValToChar((cTemp)->B1_PE),; //30 
			cValToChar((cTemp)->A2_CRVPZO),; //31
			cValToChar((cTemp)->A2_CRVPZM),; //32
			AllTrim((cTemp)->B1_CRVPROC),; //33
			AllTrim((cTemp)->B1_FABRIC),; //34
			IIf(AllTrim((cTemp)->B1_XPROIB) == 'S','Sim','Não'),; //35
			IIf(AllTrim((cTemp)->B1_CRVDG) == 'S','Sim','Não'),; //36
			IIf(AllTrim((cTemp)->B1_XCONTR) == 'S','Sim','Não'),;
			AllTrim((cTemp)->B1_CRVDG05),; //37
			AllTrim((cTemp)->B1_POSIPI),; //38
			cValToChar(SToD((cTemp)->B1_REVIMP)),; //39
			cValToChar(SToD((cTemp)->B1_CREVDES)),; //40
			AllTrim((cTemp)->B1_ORG_ANU),; //41
			AllTrim((cTemp)->B1_CRVORG2),; //42
			AllTrim((cTemp)->B1_CRVORG3),; //43
			cValToChar((cTemp)->B1_PESO),; //44
			cValToChar((cTemp)->B1_PESBRU),; //45
			IIf(AllTrim((cTemp)->B1_CRVGRUP) == "VC",cObs,"Produto não é VC"); //45
			})
			
			nItem++

		Endif 
		(cTemp)->(DbSkip())
	
	EndDo   
 
    (cTemp)->(DbCloseArea())
	// ----------------------------------------------------------
	
	//Criação do filtros dos dados da aba do Excel - Faturamentos 
    cQuery    := ""
	cProdutos := ""
    cTemp     := GetNextAlias()
	nY        := Len(aProdutos)

	If nY > 0

		//Verifico a quantidade de produtos antes de executar a query, pois dependendo da quantidade o array deverá ser tratado para não dar erro de tamanho da query no Protheus
		If nY > nQtdMax
	
			aProds := QuebrarArray(aProdutos,nPartes)
	
			For nJ := 1 To Len(aProds)
	
				nY        := Len(aProds[nJ])
				cProdutos := ""
	
				//Produtos da query principal 
				For nX := 1 To Len(aProds[nJ])
				
					cProdutos += "'"+aProds[nJ,nX]+"'"
					
					If nX < nY 
					
						cProdutos += ","
					
					Endif 
				
				Next nX
	
				cTemp  := GetNextAlias()
				cQuery := " SELECT DISTINCT SB1.B1_COD,SB5.B5_XCOD,SB1.B1_DESC_I,SB1.B1_DESC,SB1.B1_UM,"
			
				For nX := 1 To Len(a12Meses)
				
					nY := Len(a12Meses)
				
					cDtIni := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "01" //Ano-Mês-Dia (Inicial do mês)
					cDtFim := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "31" //Ano-Mês-Dia (Final do mês)
				
					cQuery += " ("
					cQuery += "  SELECT SUM(D2_QUANT) FROM "+RetSQLName("SD2")+" SD2"
					cQuery += "  WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
					cQuery += "		AND SD2.D2_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'"
					cQuery += "		AND SD2.D2_COD = SB1.B1_COD"
					cQuery += "		AND SD2.D_E_L_E_T_ <> '*'"		
					cQuery += " ) AS "+AllTrim(StrTran(AllTrim(a12Meses[nX,1]),"-",""))
				
					If nX < nY 
					
						cQuery += ","
					
					Endif 
					
				Next nX
				
				cQuery += " FROM "+RetSQLName("SB1")+" SB1"
				cQuery += " LEFT JOIN "+RetSQLName("SB5")+" SB5"
				cQuery += " 	ON B5_FILIAL = '"+xFilial("SB5")+"'"
				cQuery += "		AND B5_COD = B1_COD"
				cQuery += "		AND SB5.D_E_L_E_T_ <> '*'"
				cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
				cQuery += "     AND B1_COD IN ("+cProdutos+")"
				cQuery += "     AND SB1.D_E_L_E_T_ <> '*'"
				
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
			
				While !((cTemp)->(Eof()))
	
					aAdd(aAba2,{(cTemp)->B1_COD,(cTemp)->B5_XCOD,(cTemp)->B1_DESC,MSMM((cTemp)->B1_DESC_I,36),(cTemp)->B1_UM,;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[1,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[2,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[3,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[4,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[5,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[6,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[7,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[8,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[9,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[10,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[11,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[12,1])),"-","")))})
	
					(cTemp)->(DbSkip())
	
				EndDo
	
				(cTemp)->(DbCloseArea())
	
			Next nJ
	
		Else 
			
			//Produtos da query principal 
			For nX := 1 To Len(aProdutos)
			
				cProdutos += "'"+aProdutos[nX]+"'"
				
				If nX < nY 
				
					cProdutos += ","
				
				Endif 
			
			Next nX
	
			cQuery := " SELECT DISTINCT SB1.B1_COD,SB5.B5_XCOD,SB1.B1_DESC_I,SB1.B1_DESC,SB1.B1_UM,"
		
			For nX := 1 To Len(a12Meses)
			
				nY := Len(a12Meses)
			
				cDtIni := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "01" //Ano-Mês-Dia (Inicial do mês)
				cDtFim := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "31" //Ano-Mês-Dia (Final do mês)
			
				cQuery += " ("
				cQuery += "  SELECT SUM(D2_QUANT) FROM "+RetSQLName("SD2")+" SD2"
				cQuery += "  WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
				cQuery += "		AND SD2.D2_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'"
				cQuery += "		AND SD2.D2_COD = SB1.B1_COD"
				cQuery += "		AND SD2.D_E_L_E_T_ <> '*'"		
				cQuery += " ) AS "+AllTrim(StrTran(AllTrim(a12Meses[nX,1]),"-",""))
			
				If nX < nY 
				
					cQuery += ","
				
				Endif 
				
			Next nX
			
			cQuery += " FROM "+RetSQLName("SB1")+" SB1"
			cQuery += " LEFT JOIN "+RetSQLName("SB5")+" SB5"
			cQuery += " 	ON B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += "		AND B5_COD = B1_COD"
			cQuery += "		AND SB5.D_E_L_E_T_ <> '*'"
			cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
			cQuery += "     AND B1_COD IN ("+cProdutos+")"
			cQuery += "     AND SB1.D_E_L_E_T_ <> '*'"
			
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
		
			While !((cTemp)->(Eof()))
	
				aAdd(aAba2,{(cTemp)->B1_COD,(cTemp)->B5_XCOD,(cTemp)->B1_DESC,MSMM((cTemp)->B1_DESC_I,36),(cTemp)->B1_UM,;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[1,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[2,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[3,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[4,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[5,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[6,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[7,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[8,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[9,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[10,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[11,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[12,1])),"-","")))})
	
				(cTemp)->(DbSkip())
	
			EndDo
	
			(cTemp)->(DbCloseArea())
	
		Endif 
	
		If Len(aAba2) > 0
	
			//Aba 02
			oFWMsExcel:AddworkSheet("Faturamento")
	
			//Criando a Tabela
			oFWMsExcel:AddTable("Faturamento","Meses_Faturamento",.F.)
	
			oFWMsExcel:AddColumn("Faturamento","Meses_Faturamento","Código de Venda",1)
			oFWMsExcel:AddColumn("Faturamento","Meses_Faturamento","Código de Compra",1)
			oFWMsExcel:AddColumn("Faturamento","Meses_Faturamento","Descrição Português",1)
			oFWMsExcel:AddColumn("Faturamento","Meses_Faturamento","Descrição Inglês",1)
			oFWMsExcel:AddColumn("Faturamento","Meses_Faturamento","Unidade de Medida",1)
	
			For nX := 1 To Len(a12Meses)
				oFWMsExcel:AddColumn("Faturamento","Meses_Faturamento",a12Meses[nX,1],1)
			Next nX
			
			//Criando as Linhas... Enquanto não for fim do array aAba2
			For nX := 1 To Len(aAba2)
	
				oFWMsExcel:AddRow("Faturamento","Meses_Faturamento",{;
				aAba2[nX,1],;
				aAba2[nX,2],;
				aAba2[nX,3],;
				aAba2[nX,4],;
				aAba2[nX,5],;
				aAba2[nX,6],;
				aAba2[nX,7],;
				aAba2[nX,8],;
				aAba2[nX,9],;
				aAba2[nX,10],;
				aAba2[nX,11],;
				aAba2[nX,12],;
				aAba2[nX,13],;
				aAba2[nX,14],;
				aAba2[nX,15],;
				aAba2[nX,16],;
				aAba2[nX,17];
				})
	
			Next nX
				
		Endif 
		// ---------------------------------------------------------
	
		//Verifico a quantidade de produtos antes de executar a query, pois dependendo da quantidade o array deverá ser tratado para não dar erro de tamanho da query no Protheus
		If Len(aProds) > 0
	
			For nJ := 1 To Len(aProds)
	
				nY        := Len(aProds[nJ])
				cProdutos := ""
	
				//Produtos da query principal 
				For nX := 1 To Len(aProds[nJ])
				
					cProdutos += "'"+aProds[nJ,nX]+"'"
					
					If nX < nY 
					
						cProdutos += ","
					
					Endif 
				
				Next nX
	
				//Criação do filtros dos dados da aba do Excel - Compras 
				cTemp  := GetNextAlias()
				cQuery := " SELECT DISTINCT SB1.B1_COD,SB5.B5_XCOD,SB1.B1_DESC_I,SB1.B1_DESC,SB1.B1_UM,"
	
				For nX := 1 To Len(a12Meses)
	
					nY := Len(a12Meses)
				
					cDtIni := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "01" //Ano-Mês-Dia (Inicial do mês)
					cDtFim := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "31" //Ano-Mês-Dia (Final do mês)
				
					cQuery += " ("
					cQuery += "  SELECT SUM(W3_QTDE) FROM "+RetSQLName("SW3")+" SW3"
					cQuery += "  INNER JOIN "+RetSQLName("SW2")+" SW2"
					cQuery += "		ON SW2.W2_FILIAL =  SW3.W3_FILIAL"
					cQuery += "		AND SW2.W2_PO_NUM = SW3.W3_PO_NUM"
					cQuery += "		AND SW2.D_E_L_E_T_ <> '*'"
					cQuery += "  WHERE SW3.W3_FILIAL = '"+xFilial("SW3")+"'"
					cQuery += "		AND SW2.W2_PO_DT BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'"
					cQuery += "		AND SW3.W3_COD_I = SB1.B1_COD"
					cQuery += "		AND W3_PGI_NUM = ''"
					cQuery += "		AND SW3.D_E_L_E_T_ <> '*'"		
					cQuery += " ) AS "+AllTrim(StrTran(AllTrim(a12Meses[nX,1]),"-",""))
	
					If nX < nY 
					
						cQuery += ","
					
					Endif 
					
				Next nX
	
				cQuery += " FROM "+RetSQLName("SB1")+" SB1"
				cQuery += " LEFT JOIN "+RetSQLName("SB5")+" SB5"
				cQuery += " 	ON B5_FILIAL = '"+xFilial("SB5")+"'"
				cQuery += "		AND B5_COD = B1_COD"
				cQuery += "		AND SB5.D_E_L_E_T_ <> '*'"
				cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
				cQuery += "     AND B1_COD IN ("+cProdutos+")"
				cQuery += "     AND SB1.D_E_L_E_T_ <> '*'"
				
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
	
				While !((cTemp)->(Eof()))
	
					aAdd(aAba3,{(cTemp)->B1_COD,(cTemp)->B5_XCOD,(cTemp)->B1_DESC,MSMM((cTemp)->B1_DESC_I,36),(cTemp)->B1_UM,;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[1,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[2,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[3,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[4,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[5,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[6,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[7,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[8,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[9,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[10,1])),"-",""))),;
					(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[11,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[12,1])),"-","")))})
	
					(cTemp)->(DbSkip())
	
				EndDo
	
				(cTemp)->(DbCloseArea())
	
			Next nJ
	
		Else
		
			//Criação do filtros dos dados da aba do Excel - Compras 
			cTemp  := GetNextAlias()
			cQuery := " SELECT DISTINCT SB1.B1_COD,SB5.B5_XCOD,SB1.B1_DESC_I,SB1.B1_DESC,SB1.B1_UM,"
	
			For nX := 1 To Len(a12Meses)
	
				nY := Len(a12Meses)
			
				cDtIni := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "01" //Ano-Mês-Dia (Inicial do mês)
				cDtFim := AllTrim(cValToChar(Year(a12Meses[nX,2]))) + AllTrim(StrZero(Month(a12Meses[nX,2]),2)) + "31" //Ano-Mês-Dia (Final do mês)
			
				cQuery += " ("
				cQuery += "  SELECT SUM(W3_QTDE) FROM "+RetSQLName("SW3")+" SW3"
				cQuery += "  INNER JOIN "+RetSQLName("SW2")+" SW2"
				cQuery += "		ON SW2.W2_FILIAL =  SW3.W3_FILIAL"
				cQuery += "		AND SW2.W2_PO_NUM = SW3.W3_PO_NUM"
				cQuery += "		AND SW2.D_E_L_E_T_ <> '*'"
				cQuery += "  WHERE SW3.W3_FILIAL = '"+xFilial("SW3")+"'"
				cQuery += "		AND SW2.W2_PO_DT BETWEEN '"+cDtIni+"' AND '"+cDtFim+"'"
				cQuery += "		AND SW3.W3_COD_I = SB1.B1_COD"
				cQuery += "		AND W3_PGI_NUM = ''"
				cQuery += "		AND SW3.D_E_L_E_T_ <> '*'"		
				cQuery += " ) AS "+AllTrim(StrTran(AllTrim(a12Meses[nX,1]),"-",""))
	
				If nX < nY 
				
					cQuery += ","
				
				Endif 
				
			Next nX
	
			cQuery += " FROM "+RetSQLName("SB1")+" SB1"
			cQuery += " LEFT JOIN "+RetSQLName("SB5")+" SB5"
			cQuery += " 	ON B5_FILIAL = '"+xFilial("SB5")+"'"
			cQuery += "		AND B5_COD = B1_COD"
			cQuery += "		AND SB5.D_E_L_E_T_ <> '*'"
			cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"'"
			cQuery += "     AND B1_COD IN ("+cProdutos+")"
			cQuery += "     AND SB1.D_E_L_E_T_ <> '*'"
			
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
	
			While !((cTemp)->(Eof()))
	
				aAdd(aAba3,{(cTemp)->B1_COD,(cTemp)->B5_XCOD,(cTemp)->B1_DESC,MSMM((cTemp)->B1_DESC_I,36),(cTemp)->B1_UM,;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[1,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[2,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[3,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[4,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[5,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[6,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[7,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[8,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[9,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[10,1])),"-",""))),;
				(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[11,1])),"-",""))),(cTemp)->&(AllTrim(StrTran(Upper(AllTrim(a12Meses[12,1])),"-","")))})
	
				(cTemp)->(DbSkip())
	
			EndDo
	
			(cTemp)->(DbCloseArea())
	
		Endif 
	
		If Len(aAba3) > 0	
			
			//Aba 03
			oFWMsExcel:AddworkSheet("Compras")
	
			//Criando a Tabela
			oFWMsExcel:AddTable("Compras","Meses_Compras",.F.)
	
			oFWMsExcel:AddColumn("Compras","Meses_Compras","Codigo de Venda",1)
			oFWMsExcel:AddColumn("Compras","Meses_Compras","Código de Compra",1)
			oFWMsExcel:AddColumn("Compras","Meses_Compras","Descrição Português",1)
			oFWMsExcel:AddColumn("Compras","Meses_Compras","Descrição Inglês",1)
			oFWMsExcel:AddColumn("Compras","Meses_Compras","Unidade de Medida",1)
	
			For nX := 1 To Len(a12Meses)
				oFWMsExcel:AddColumn("Compras","Meses_Compras",a12Meses[nX,1],1)
			Next nX
			
			//Criando as Linhas... Enquanto não for fim do array aAba3
			For nX := 1 To Len(aAba3)
	
				oFWMsExcel:AddRow("Compras","Meses_Compras",{;
				aAba3[nX,1],;
				aAba3[nX,2],;
				aAba3[nX,3],;
				aAba3[nX,4],;
				aAba3[nX,5],;
				aAba3[nX,6],;
				aAba3[nX,7],;
				aAba3[nX,8],;
				aAba3[nX,9],;
				aAba3[nX,10],;
				aAba3[nX,11],;
				aAba3[nX,12],;
				aAba3[nX,13],;
				aAba3[nX,14],;
				aAba3[nX,15],;
				aAba3[nX,16],;
				aAba3[nX,17];
				})
	
			Next nX
				
		Endif 
		// ---
		
		//Aba 04
		oFWMsExcel:AddworkSheet("Parametros")
	
		//Criando a Tabela
		oFWMsExcel:AddTable("Parametros","Rel_Parametros",.F.)
	
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Fornecedor de?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Fornecedor até?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Modal?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","MRP?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Fabricante?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Produto de?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Produto até?",1)
		oFWMsExcel:AddColumn("Parametros","Rel_Parametros","Sugestão?",1)
	
		oFWMsExcel:AddRow("Parametros","Rel_Parametros",{;
							mv_par01,;
							mv_par02,;
							IIf(mv_par03 == 1,"Air",IIf(mv_par03 == 2,"Sea","Todos")),;
							mv_par04,;
							mv_par05,;
							mv_par06,;
							mv_par07,;
							IIf(mv_par08 == 1,"Apenas Comprar","Todos");
							})
		// ----
	
		//Aba 05
		oFWMsExcel:AddworkSheet("Detalhes")
	
		//Criando a Tabela
		oFWMsExcel:AddTable("Detalhes","Rel_Detalhes",.F.)
	
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Data Geração Relatório",1,1) //1
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","# Linha",1,1) //2
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Fornecedor",1,1) //3
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Código de Venda",1,1) //4 
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Código de Compra",1,1) //5
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Descrição Português",1,1) //6
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Descrição Inglês",1,1) //7
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Unidade de Medida",1,1) //8
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","MOQ",1,1) //9
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Sugestão de Compra",1,1) //10
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Demanda",1,1) //11
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Estoque 01",1,1) //13
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Estoque 02",1,1) //13
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Estoque AC (Transitório)",1,1) //13
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Estoque Mínimo",1,1) //14
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Estoque de Segurança",1,1) //15
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Saldo",1,1) //16
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Quantidade Faturada nos Ultimos 3 Meses",1,1) //17
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Cobertura atual do Estoque",1,1) //18
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Preço Total",1,1) //20
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Preço Unit Fornecedor",1,1)
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Moeda Fornecedor",1,1)
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Preço Unit Fornecedor R$ (tx dia)",1,1)
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","TP",1,1) //22
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Modal Transporte MRP",1,1) //23
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","MRP Item",1,1) //24
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Aéreo - Quantidade PO em Aberto",1,1) //25
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Aéreo - Quantidade em Processo",1,1) //26
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Marítimo - Quantidade PO em Aberto",1,1) //27
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Marítimo - Quantidade em Processo",1,1) //28
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Validade Padrão",1,1) //29
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Leadtime do Produto",1,1) //30
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Leadtime do Fornecedor - Aéreo",1,1) //31
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Leadtime do Fornecedor - Marítimo",1,1) //32
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","País de Origem",1,1) //33
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Fabricante",1,1) //34
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Proibido Aéreo?",1,1) //35
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Perigoso",1,1) //36
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Material Controlado",1,1) 
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Classe de Risco",1,1) //37
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","NCM",1,1) //38
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Última Rev. Comex",1,1) //39
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Última Rev. Descrição",1,1) //40
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Org. Anuente 1",1,1) //41
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Org. Anuente 2",1,1) //42
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Org. Anuente 3",1,1) //43
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Peso Líq Unit",1,1) //44
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Peso Brut Unit",1,1) //45
		oFWMsExcel:AddColumn("Detalhes","Rel_Detalhes","Observação",1,1)
	
		oFWMsExcel:AddRow("Detalhes","Rel_Detalhes",{;
							"Data e hora da geração do relatório",; //1
							"Linha do relatório",; //2
							"Código do fornecedor",; //3
							"Campo C6_PRODUTO",; //4
							"Campo B5_XCOD",; //5
							"Campo B1_DESC",; //6
							"Campo B1_DESC_I",; //7
							"Campo B1_UM",; //8
							"Campo B1_CRVLE",; //9
							"O cálculo é formado pelas colunas ((AA+AB+AC+AD)+(L+M+N)-K); [Regra: Se a quantidade da soma das colunas ((AA+AB+AC+AD)+(L+M+N)) for maior que a coluna K, então a quantidade apresentada será 0 (não tem necessidade de compra); caso contrário, será apresentada a quantidade a ser comprada",; //10
							"É a soma da quantidade pendente do produto nos pedidos de vendas em aberto, desconsiderando os pedidos com resíduos eliminados [C6_BLQ = R]",; //11
							"Quantidade total do produto no armazém 01 da filial 01",; //12
							"Quantidade total do produto no armazém 02 da filial 02",; //13
							"Quantidade total do produto no armazém AC da filial 01",; //14
							"Esta informação vem da tabela SB1 do campo B1_CRVEMIN",; //15
							"Campo B1_ESTSEG",; //16
							"O cálculo é formado pelas seguintes colunas = ((L+M+N)-K) [Regra: Se o resultado do cáluclo for maior que zero então o valor é apresentado caso contrário o valor retornado será 0]",; //17
							"Quantidade total de notas faturadas contendo o produto",; //18
							"O cálculo é formado pelas seguintes colunas = (R/P)",; //19
							"O cálculo é formado pelas seguintes colunas = (R * J)",; //20
							"Campo ZB_PRECO",; //21
							"Campo ZB_MOEDA",; //22
							"O cálculo é formado pelas seguintes colunas = (W * Taxa da PTAX do dia) [Regra: Se não houver a PTAX cadastrada ele retornará o valor da coluna W]",; //23
							"Campo B1_TIPO",; //24
							"Campo B1_CRVMART",; //25
							"Campo B1_CRVGRUP",; //26
							"Quantidade de PO no Aéreo sem Processo",; //27
							"Quantidade de PO no Aéreo em Processo",; //28
							"Quantidade de PO no Marítimo sem Processo",; //29
							"Quantidade de PO no Marítimo com Processo",; //30
							"Campo B1_PRVALID",; //31
							"Campo B1_PE",; //32
							"Campo A2_CRVPZO",; //33
							"Campo A2_CRVPZM",; //34
							"Campo B1_CRVPROC",; //35
							"Campo B1_FABRIC",; //36
							"Campo B1_XPROIB",; //37
							"Campo B1_CRVDG",; //38
							"Campo B1_XCONTR",; //39
							"Campo B1_CRVDG05",; //40
							"Campo B1_POSIPI",; //41
							"Campo B1_REVIMP",; //42
							"Campo B1_CREVDES",; //43
							"Campo B1_ORG_ANU",; //44
							"Campo B1_CRVORG2",; //45
							"Campo B1_CRVORG3",; //46
							"Campo B1_PESO",; //47
							"Campo B1_PESBRU",; //48
							"Indicação da ação a ser tomada"; //49
							})
		// ----
	
		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo)
		oFWMsExcel:DeActivate()
	
		If !lJob
			ShellExecute("Open",cArquivo,"","",5) //Abertura da pasta local onde consta o arquivo Excel
		Else 
		
			xEnvMail(cArquivo,cEmail)
	
		Endif 
		
	Else 
		
		If !lJob
			MsgAlert("Não há dados para apresentar no relatório!","Atenção")
		Else
			fConout("CVCOMR01 - ["+DToc(dDatabase)+"-"+Time()+"] - Não há dados para apresentar no relatório!")
		Endif 
		
	Endif 

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Ultimos 12 meses
*==================================================================*/
Static Function x12Meses()

    Local a12Meses := {}
    Local dDataAtu := SToD('  /  /    ')

    dDataAtu := MonthSub(dDataBase,1)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,2)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,3)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,4)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,5)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,6)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,7)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,8)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,9)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,10)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,11)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

    dDataAtu := MonthSub(dDataBase,12)
    aAdd(a12Meses,{SubStr(AllTrim(cMonth(dDataAtu)),1,3) +"-"+AllTrim(cValToChar(Year(dDataAtu))),dDataAtu})

Return(a12Meses)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 16/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Moedas
*==================================================================*/
Static Function xMoeda(nMoeda)

	Local cDescMoeda := ""
	
	If nMoeda == 1
		cDescMoeda := "REAL"	
	Elseif nMoeda == 2
		cDescMoeda := "EURO"
	Elseif nMoeda == 3
		cDescMoeda := "DOLAR"
	Elseif nMoeda == 4
		cDescMoeda := "UFIR"
	Elseif nMoeda == 5
		cDescMoeda := "LIBRA ESTERLINA"
	Endif 

Return(cDescMoeda)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Quebrar o array em partes parte 1
*==================================================================*/
Static Function QuebrarArray(aArray,nPartes)

    Local aResultado := {}
    Local nTotal     := Len(aArray)
    Local nTamParte  := Int(nTotal / nPartes)
    Local nResto     := nTotal % nPartes
    Local nInicio    := 1
    Local nI         := 0
	Local nFim       := 0

    For nI := 1 To nPartes
	
        nFim := nInicio + nTamParte - 1
		
        If nI <= nResto
            nFim++ // Distribui os elementos restantes entre as primeiras partes
        Endif 

        aAdd(aResultado,SubArray(aArray,nInicio,nFim))
		
        nInicio := nFim + 1
		
    Next nI

Return(aResultado)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Quebrar o array em partes parte 2
*==================================================================*/
Static Function SubArray(aOrigem,nInicio,nFim)

    Local aSub := {}
    Local nI   := 0

    For nI := nInicio To nFim
        aAdd(aSub,aOrigem[nI])
    Next nI

Return(aSub)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/11/2025
Consultoria: Proativa
Uso: Calibre
Info: Query Quantidade PO [Aéreo e Marítimo]
-> nProcess = 1 [Aéreo]
-> nProcess = 2 [Marítimo]
-> nOpc = 1 [Pendente]
-> nOpc = 2 [Com processo]
*==================================================================*/
Static Function xPO(cCodProd,nOpc,nProcess)

	Local nQtdPO  := 0
	Local nQtdPO1 := 0
	Local nQtdPO2 := 0
	Local cTemp   := GetNextAlias()
	Local cQuery  := ""
	
	cQuery := "	SELECT DISTINCT"
	cQuery += "		 CASE"
	cQuery += "			WHEN W5_SALDO_Q > 0 THEN W5_HAWB"
	cQuery += "		 ELSE "
	cQuery += "			W6_HAWB END W6_HAWB,"
	cQuery += "		 CASE "
	cQuery += "		 	WHEN W3_SALDO_Q > 0 THEN W3_SALDO_Q"
	cQuery += "		 	WHEN W5_SALDO_Q > 0 THEN W5_SALDO_Q"
	cQuery += "		 ELSE "
	cQuery += "		 	W3_QTDE END	W8_QTDE,"
	cQuery += "		 	RTRIM(W3_PO_NUM) + '|' + RTRIM(W3_COD_I) + '|' + RTRIM(W3_POSICAO) AS CHAVE"
	cQuery += "		 FROM SW3010 SW3"
	cQuery += "		 INNER JOIN "+RetSQLName("SW2")+" SW2"
	cQuery += "		 	ON W2_FILIAL = W3_FILIAL"
	cQuery += "		 	AND W2_PO_NUM = W3_PO_NUM"
	cQuery += "		 	AND SW2.D_E_L_E_T_ <> '*'"
	cQuery += "		 LEFT JOIN "+RetSQLName("SW8")+" SW8"
	cQuery += "		 	ON W8_FILIAL = W3_FILIAL"
	cQuery += "		 	AND W8_PO_NUM = W3_PO_NUM"
	cQuery += "		 	AND W8_SI_NUM = W3_SI_NUM"
	cQuery += "		 	AND W8_COD_I = W3_COD_I"
	cQuery += "		 	AND W8_REG = W3_REG"
	cQuery += "		 	AND W8_POSICAO = W3_POSICAO"
	cQuery += "		 	AND W8_PGI_NUM = W3_PGI_NUM"
	cQuery += "		 	AND SW8.D_E_L_E_T_ <> '*'"
	cQuery += "		 LEFT JOIN "+RetSQLName("SW9")+" SW9"
	cQuery += "		 	ON W9_FILIAL = W8_FILIAL"
	cQuery += "		 	AND W9_INVOICE = W8_INVOICE"
	cQuery += "		 	AND W9_HAWB = W8_HAWB"
	cQuery += "		 	AND SW9.D_E_L_E_T_ <> '*'"
	cQuery += "		 LEFT JOIN "+RetSQLName("SW6")+" SW6"
	cQuery += "		 	ON W6_FILIAL = W9_FILIAL  "
	cQuery += "		 	AND W6_HAWB = W9_HAWB "
	cQuery += "		 	AND SW6.D_E_L_E_T_ <> '*'"
	cQuery += "		 LEFT JOIN "+RetSQLName("SW5")+" SW5"
	cQuery += "		 	ON W5_FILIAL = W3_FILIAL"
	cQuery += "		 	AND W5_PGI_NUM = W3_PGI_NUM"
	cQuery += "		 	AND W5_CC = W3_CC"
	cQuery += "		 	AND W5_SI_NUM = W3_SI_NUM"
	cQuery += "		 	AND W5_COD_I = W3_COD_I"
	cQuery += "		 	AND W5_POSICAO = W3_POSICAO"
	cQuery += "		 	AND W5_REG = W3_REG"
	cQuery += "		 	AND SW5.D_E_L_E_T_ <> '*'"
	cQuery += "		INNER JOIN "+RetSQLName("SB1")+" SB1"
	cQuery += "			ON B1_FILIAL = ''"
	cQuery += "			AND B1_COD = W3_COD_I"
	
	If nProcess == 1
		cQuery += "			AND B1_CRVMART <> 'S'"
	Else
		cQuery += "			AND B1_CRVMART = 'S'"	
	Endif 
	
	cQuery += "			AND SB1.D_E_L_E_T_ <> '*'"
	cQuery += "		 WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += "		 	AND W3_COD_I = '"+cCodProd+"'"
	cQuery += "		 	AND (W3_PGI_NUM = '' AND W3_SALDO_Q > 0"
	cQuery += "		   	OR W3_PGI_NUM <> '' AND W3_SALDO_Q = 0)"
	cQuery += "		 	AND (W5_SALDO_Q > 0 OR W3_SALDO_Q > 0)"
	cQuery += "		 	AND SW3.D_E_L_E_T_ <> '*'"

	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()			
	Endif 
	
	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	Memowrite("C:\temp\Query_xPO1.sql",cQuery)
	
	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())

	While !((cTemp)->(Eof()))

		//Sem importação 
		If nOpc == 1
		
			If Empty((cTemp)->W6_HAWB)
				
				nQtdPO1 += (cTemp)->W8_QTDE
				
			Else 
				
				nQtdPO1 := 0
			
			Endif 
			
		Else 
			
			//Com importação
			If !Empty((cTemp)->W6_HAWB)
				
				nQtdPO1 += (cTemp)->W8_QTDE
				
			Else 
				
				nQtdPO1 := 0
			
			Endif 
		
		Endif 

		(cTemp)->(DbSkip())

	EndDo 

	(cTemp)->(DbCloseArea())

	cTemp   := ""
	cTemp   := GetNextAlias()
	cQuery  := ""

	cQuery := "	SELECT DISTINCT"
	cQuery += "		 W6_HAWB,"
	cQuery += "		 CASE "
	cQuery += "				WHEN W3_SALDO_Q > 0 THEN W3_SALDO_Q"
	cQuery += "			ELSE"
	cQuery += "				W3_QTDE END	W8_QTDE,"
	cQuery += "		 	RTRIM(W3_PO_NUM) + '|' + RTRIM(W3_COD_I) + '|' + RTRIM(W3_POSICAO) AS CHAVE"
	cQuery += "		 	FROM "+RetSQLName("SW3")+" SW3"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW2")+" SW2"
	cQuery += "		 		 	ON W2_FILIAL = W3_FILIAL"
	cQuery += "		 		 	AND W2_PO_NUM = W3_PO_NUM"
	cQuery += "		 		 	AND SW2.D_E_L_E_T_ <> '*'"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW8")+" SW8"
	cQuery += "		 		 	ON W8_FILIAL = W3_FILIAL"
	cQuery += "		 		 	AND W8_PO_NUM = W3_PO_NUM "
	cQuery += "		 		 	AND W8_SI_NUM = W3_SI_NUM"
	cQuery += "		 		 	AND W8_COD_I = W3_COD_I "
	cQuery += "		 		 	AND W8_REG = W3_REG"
	cQuery += "		 			AND W8_POSICAO = W3_POSICAO"
	cQuery += "		 			AND W8_PGI_NUM = W3_PGI_NUM"
	cQuery += "		 		 	AND SW8.D_E_L_E_T_ <> '*'"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW9")+" SW9"
	cQuery += "		 		 	ON W9_FILIAL = W8_FILIAL"
	cQuery += "		 		 	AND W9_INVOICE = W8_INVOICE"
	cQuery += "		 		 	AND W9_HAWB = W8_HAWB"
	cQuery += "		 		 	AND SW9.D_E_L_E_T_ <> '*'"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW6")+" SW6"
	cQuery += "		 		 	ON W6_FILIAL = W9_FILIAL"
	cQuery += "		 		 	AND W6_HAWB = W9_HAWB "
	cQuery += "		 		 	AND SW6.D_E_L_E_T_ <> '*'"
	cQuery += "		 		WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += "		 		   AND W3_COD_I = '"+cCodProd+"'"
	cQuery += "		 		   AND (W3_PGI_NUM = '' AND W3_SALDO_Q > 0"
	cQuery += "		   		   OR W3_PGI_NUM <> '' AND W3_SALDO_Q = 0)"
	cQuery += "		 		   AND W6_DT_ENCE = ''"
	cQuery += "		 		   AND SW3.R_E_C_N_O_ NOT IN ("
	cQuery += "		 		SELECT DISTINCT"
	cQuery += "		 		    SW3.R_E_C_N_O_"
	cQuery += "		 		FROM "+RetSQLName("SW3")+" SW3"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW2")+" SW2"
	cQuery += "		 		 	ON W2_FILIAL = W3_FILIAL"
	cQuery += "		 		 	AND W2_PO_NUM = W3_PO_NUM"
	cQuery += "		 		 	AND SW2.D_E_L_E_T_ <> '*'"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW8")+" SW8"
	cQuery += "		 		 	ON W8_FILIAL = W3_FILIAL"
	cQuery += "		 		 	AND W8_PO_NUM = W3_PO_NUM"
	cQuery += "		 		 	AND W8_SI_NUM = W3_SI_NUM"
	cQuery += "		 		 	AND W8_COD_I = W3_COD_I"
	cQuery += "		 		 	AND W8_REG = W3_REG"
	cQuery += "		 			AND W8_POSICAO = W3_POSICAO"
	cQuery += "		 			AND W8_PGI_NUM = W3_PGI_NUM"
	cQuery += "		 		 	AND SW8.D_E_L_E_T_ <> '*'"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW9")+" SW9"
	cQuery += "		 		 	ON W9_FILIAL = W8_FILIAL"
	cQuery += "		 		 	AND W9_INVOICE = W8_INVOICE"
	cQuery += "		 		 	AND W9_HAWB = W8_HAWB"
	cQuery += "		 		 	AND SW9.D_E_L_E_T_ <> '*'"
	cQuery += "		 		INNER JOIN "+RetSQLName("SW6")+" SW6"
	cQuery += "		 		 	ON W6_FILIAL = W9_FILIAL"
	cQuery += "		 		 	AND W6_HAWB = W9_HAWB "
	cQuery += "		 		 	AND SW6.D_E_L_E_T_ <> '*'"
	cQuery += "				INNER JOIN "+RetSQLName("SB1")+" SB1"
	cQuery += "					ON B1_FILIAL = ''"
	cQuery += "					AND B1_COD = W3_COD_I"
	
	If nProcess == 1
		cQuery += "			AND B1_CRVMART <> 'S'"
	Else
		cQuery += "			AND B1_CRVMART = 'S'"	
	Endif 
	
	cQuery += "					AND SB1.D_E_L_E_T_ <> '*'"
	cQuery += "		 		WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += "		 		   AND W3_COD_I = '"+cCodProd+"'"
	cQuery += "		 		   AND (W3_PGI_NUM = '' AND W3_SALDO_Q > 0"
	cQuery += "		   		   OR W3_PGI_NUM <> '' AND W3_SALDO_Q = 0)"
	cQuery += "		 		   AND W6_DT_ENCE = ''"
	cQuery += "		 		   AND W6_TIPODES NOT IN ('2','3','4','02','03','04')"
	cQuery += "		 		   AND W6_DT_ENTR <> ''"
	cQuery += "		 		   AND W2_HAWB_DA = ''"
	cQuery += "		 		   AND SW3.D_E_L_E_T_ <> '*'"
	cQuery += "		 		   )"
	cQuery += "		 		   AND SW3.D_E_L_E_T_ <> '*'"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()			
	Endif 
	
	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	Memowrite("C:\temp\Query_xPO2.sql",cQuery)
	
	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())

	While !((cTemp)->(Eof()))
	
		//Sem importação 
		If nOpc == 1
		
			If Empty((cTemp)->W6_HAWB)
				
				nQtdPO2 += (cTemp)->W8_QTDE
				
			Else 
				
				nQtdPO2 := 0
			
			Endif 
			
		Else 
			
			//Com importação
			If !Empty((cTemp)->W6_HAWB)
				
				nQtdPO2 += (cTemp)->W8_QTDE
				
			Else 
				
				nQtdPO2 := 0
			
			Endif 
		
		Endif 

		(cTemp)->(DbSkip())

	EndDo 

	(cTemp)->(DbCloseArea())

	nQtdPO := nQtdPO1 + nQtdPO2 //Resultado Final

Return(nQtdPO)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/06/2025
Consultoria: Proativa
Uso: Calibre
Info: Envio de e-mail 
*==================================================================*/
Static Function xEnvMail(cArquivo,cEmail)

	Local cAssunto  := "RELATORIO DE DEMANDAS"
	Local lMailAuth	:= GetMV("MV_RELAUTH",.F.,.T.) //Autenticação com server SMTP
	Local nPortSMTP := 587 //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587
	Local nTimeout  := GetMV("MV_RELTIME") //120 //30
	Local xRet
	Local oServer	
	Local oMessage

	//A porta 25, por ser utilizada há mais tempo, possui uma vulnerabilidade maior a
	//ataques e interceptação de mensagens, além de não exigir autenticação para envio
	//das mensagens, ao contrário da 587 que oferece esta segurança a mais.

	Private cMailConta := Alltrim(GetMV("MV_RELACNT"))        //Conta utilizada para envio do email
	Private cMailServer	:= AllTrim(StrTran(GetMV("MV_RELSERV"),":587",""))       //Servidor SMTP
	Private cMailSenha := Alltrim(GetMV("MV_RELPSW")) //Senha da conta de e-mail utilizada para envio

	// Fallback para ambientes que usam MV_RELAUSR / MV_RELAPSW.
	If Empty(cMailConta)
		cMailConta := GetMV("MV_RELAUSR")
	EndIf
	If Empty(cMailSenha)
		cMailSenha := GetMV("MV_RELAPSW")
	EndIf

	oServer := TMailManager():New()
	oServer:SetUseTLS(.T.) //Indica se será utilizará a comunicação segura através de TLS (.T.) ou não (.F.)
	oServer:SetUseSSL(.T.) //Indica se será utilizará a comunicação segura através de SSL (.T.) ou não (.F.)

	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha,, nPortSMTP ) //inicilizar o servidor

	If xRet <> 0
		fConout("O servidor SMTP nao foi inicializado: " + oServer:GetErrorString( xRet ))
		Return
	Else
		fConout("["+DToc(dDatabase)+"-"+Time()+"] Server inicializado com sucesso...")
	Endif

	xRet := oServer:SetSMTPTimeout(nTimeout) //Indica o tempo de espera em segundos.

	If xRet <> 0
		fConout(cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	Endif

	xRet := oServer:SMTPConnect()

	If xRet <> 0
		fConout("Não foi possível conectar ao server SMTP: " + oServer:GetErrorString( xRet ))
		Return
	Else
		fConout("["+DToc(dDatabase)+"-"+Time()+"] Conexao com o server SMTP realizada com sucesso...")
	Endif

	If lMailAuth

		//O método SMTPAuth ao tentar realizar a autenticação do
		//usuário no servidor de e-mail, verifica a configuração
		//da chave AuthSmtp, na seção [Mail], no arquivo de
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )

		If xRet <> 0
			fConout("Não foi possível autenticar no server SMTP: " + oServer:GetErrorString( xRet ))
			oServer:SMTPDisconnect()
			Return
		Else
			fConout("["+DToc(dDatabase)+"-"+Time()+"] Autenticacao no server realizada com sucesso...")
		Endif

	Endif
	
	oMessage := TMailMessage():New()

	oMessage:Clear()

	oMessage:cDate	  := cValToChar(Date())
	oMessage:cFrom 	  := AllTrim(GetMV("MV_RELFROM",.F.,"no-reply@carvalhaes.net"))
	oMessage:cTo 	  := cEmail
	oMessage:cSubject := cAssunto
	oMessage:cBody 	  := "Segue anexo relatório de Demandas."

	xRet := oMessage:AttachFile(cArquivo)
	
	If xRet < 0
		fConout("Não foi possível anexar o arquivo: " + cArquivo)
	Endif

	xRet := oMessage:Send( oServer )

	If xRet <> 0
		fConout("Nao foi possível enviar o relatorio: " + oServer:GetErrorString( xRet ))
	Else
		fConout("Relatorio enviado com sucesso...")
	Endif

	xRet := oServer:SMTPDisconnect()

	If xRet <> 0
		fConout("Nao foi possivel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	Else
		fConout("["+DToc(dDatabase)+"-"+Time()+"] Server desconectado com sucesso...")
	Endif

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 03/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Perguntas da SX1 
*==================================================================*/
Static Function AjustaSX1(cPerg)

	Local aRegs := {}
	Local nI    := 0
	Local nJ    := 0
	
	aAdd(aRegs,{cPerg,"01","Fornecedor de?"  ,"","","mv_ch1","C",06,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	aAdd(aRegs,{cPerg,"02","Fornecedor até?" ,"","","mv_ch2","C",06,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	aAdd(aRegs,{cPerg,"03","Modal?"          ,"","","mv_ch3","N",01,00,0,"C","","mv_par03","Air","","","","","Sea","","","","","Todos","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","MRP?"            ,"","","mv_ch4","C",06,00,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","ZZ"})
	aAdd(aRegs,{cPerg,"05","Fabricante?"     ,"","","mv_ch5","C",20,00,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"06","Produto de?"     ,"","","mv_ch6","C",30,00,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"07","Produto até?"    ,"","","mv_ch7","C",30,00,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"08","Sugestão?"       ,"","","mv_ch8","N",01,00,0,"C","","mv_par08","Apenas Comprar","","","","","Todos","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	
	For nI := 1 To Len(aRegs)
	
		If !SX1->(DbSeek(cPerg + aRegs[nI,2]))
		
			RecLock("SX1",.T.)
			
			For nJ := 1 To FCount()

				If nJ <= Len(aRegs[nI])
					FieldPut(nJ,aRegs[nI,nJ])
				Endif 
			
			Next nJ 
			
			SX1->(MsUnlock())
	
		Endif 
	
	Next nI

Return


/*/{Protheus.doc} BuscaEmail
	Função que recupera a lista de emails que serão utilizados na rotina
	@type  Static Function
	@author Aldo Barbosa dos Santos
	@since 03/04/2026
	@version version
	@param cTabela > Tabela na SX5 que deverá ser utilizada
	@see (links_or_references)
/*/
Static Function BuscaEmail(cTabela)
	Local aRet := {}
	Local cQry := ""

	cQry += "SELECT * FROM "+RetSqlName("SX5")+" "
	cQry += " WHERE D_E_L_E_T_ = ' ' AND X5_FILIAL = '"+xFilial("SX5")+"' "
	cQry += "   AND X5_TABELA = '"+cTabela+"' AND X5_DESCRI <> ' ' "
	MpSysOpenQuery(cQry, "TMPB")

	Do While TMPB->( ! Eof())
		if IsEmail(TMPB->X5_DESCRI)
			AAdd(aRet, Lower(Alltrim(TMPB->X5_DESCRI)) )
		Endif	
		TMPB->( Dbskip())
	Enddo

	TMPB->( DbCloseArea())

Return( aRet )


/*/{Protheus.doc} ListaEmail
	Retorna a lista dos emails configurados
	@type  Static Function
	@author Aldo Barbosa dos Santos
	@since 03/04/2026
	@version version
	@param aEmails  > Lista dos emails
	@see (links_or_references)
/*/
Static Function ListaEmail(aEmails)
	Local cRet := ""
	Local nA

	For nA := 1 to Len(aEmails)
		cRet += aEmails[nA]+"; "
	Next

Return( cRet )


/*/{Protheus.doc} fConout
	Controla o envio de mensagem para o console quando for via schedule
	@type  Static Function
	@author Aldo Barbosa dos Santos
	@since 03/04/2026
	@version version
	@param aEmails  > Lista dos emails
	@see (links_or_references)
/*/
Static Function fConout(cMsg)
	if IsBlind()
		Conout(cMsg)
	Endif
Return		
