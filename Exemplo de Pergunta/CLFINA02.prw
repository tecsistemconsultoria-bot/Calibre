#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TBIConn.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira (vinicius.ndeoliveira@gmail.com)
Data: 05/02/2021
Consultoria: TecSistem
Uso: Regus/Câmara Leal
Tipo: Atualizações
Rotina: Financeiro
Função: CLFINA02
Info: Relatório de Boletos do Portal de Boletos Regus
************************************************************************/
User Function CLFINA02()

	Local cPerg := Padr("CLFINA02",10)
	
	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//Gero a pergunta
	If Pergunte(cPerg,.T.)
		//Extração dos dados
		FWMsgRun(, {|| xFilDados() }, "Aguarde", "Filtrando dados conforme os parâmetros do relatório...")
	Endif

Return
	
/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/02/2021
Consultoria: TecSistem
Uso: Regus/Câmara Leal
Info: Filtro os dados do relatório
*==================================================================*/
Static Function xFilDados()
	
	Local cQuery     := ""
	Local cTemp      := GetNextAlias()
	Local cEmis1     := ""
	Local cEmis2     := ""
	Local cVencto1   := ""
	Local cVencto2   := ""
	
	Private aBoletos := {}
	
	//Trato as datas conforme aceito pelo banco de dados 
	cEmis1   := Left(DToS(mv_par01),4) + "-" + Substr(DToS(mv_par01),5,2) + "-" + Right(DToS(mv_par01),2)
	cEmis2   := Left(DToS(mv_par02),4) + "-" + Substr(DToS(mv_par02),5,2) + "-" + Right(DToS(mv_par02),2)
	cVencto1 := Left(DToS(mv_par03),4) + "-" + Substr(DToS(mv_par03),5,2) + "-" + Right(DToS(mv_par03),2)
	cVencto2 := Left(DToS(mv_par04),4) + "-" + Substr(DToS(mv_par04),5,2) + "-" + Right(DToS(mv_par04),2)
		
	cQuery := " SELECT" 
	cQuery += " 	 BC.BoletoCobrancaId as ID,"
	cQuery += " 	 BC.TitanId as TITAN,"
	cQuery += " 	 CE.NumeroCentro as CENTRO,"
	cQuery += " 	 CE.Empresa as EMPREGUS,"
	cQuery += " 	 BC.NomeCliente as NOME,"
	cQuery += " 	 BC.Valor as VALOR,"
	cQuery += " 	 SC.Descricao as DESC_STATUS,"
	cQuery += " 	 BC.DataCadastro as EMISSAO,"
	cQuery += " 	 BC.DataVencimento AS VENCIMENTO,"
	cQuery += " 	 BC.CriadoPor as DESCUSER,"
	cQuery += " 	 CASE"
	cQuery += "        WHEN BC.TipoBoletoId = '1' THEN 'Negociacao'"
	cQuery += " 	   WHEN BC.TipoBoletoId = '2' THEN 'Primeiro pagamento'"
	cQuery += " 	   WHEN BC.TipoBoletoId = '3' THEN 'Deposito de garantia'"	
	cQuery += " 	   END TIPO,"      
	cQuery += " 	 CASE"
	cQuery += "        WHEN BC.StatusBoletoCobrancaId = '1'    THEN 'Pendente'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '2'    THEN 'Cadastrar no sistema'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '3'    THEN 'Centro nao existe'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '4'    THEN 'Processado OK'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '5'    THEN 'Processar manual'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '1002' THEN 'Erro sem banco'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '1003' THEN 'Faixa do banco'"
	cQuery += " 	   WHEN BC.StatusBoletoCobrancaId = '1004' THEN 'Bloqueado Microsiga'"
	cQuery += "		   WHEN BC.StatusBoletoCobrancaId = '1005' THEN 'Erro envio boleto'"
	cQuery += " 	   END STATUS_BOLETO,"		 
	cQuery += " 	 ISNULL(IV.InvoiceId,' ') as ID_INVOICE,"
	cQuery += " 	 ISNULL(IV.NumeroInvoice,' ') as ID_NUM_INVOICE,"
	cQuery += " 	 ISNULL(IV.BoletoCobranca_BoletoCobrancaId,' ') as ID_BOLETO"
	cQuery += " 	  FROM Regus.dbo.BoletosCobranca BC"
	cQuery += " 	  JOIN Regus.dbo.Statusboletocobranca SC"
	cQuery += " 	    ON BC.StatusBoletoCobrancaId = SC.Id"
	cQuery += " 	  JOIN Regus.dbo.Centros CE"
	cQuery += " 	    ON BC.CentroId = CE.Id"
	cQuery += " 	  LEFT JOIN Regus.dbo.Invoices IV"
	cQuery += " 	    ON IV.BoletoCobranca_BoletoCobrancaId = BC.BoletoCobrancaId"
	cQuery += " 	 WHERE BC.DataCadastro BETWEEN '"+cEmis1+"' AND '"+cEmis2+"'"
	cQuery += "			AND BC.DataVencimento BETWEEN '"+cVencto1+"' AND '"+cVencto2+"'"
	
	If !Empty(mv_par05) .And. !Empty(mv_par06)	
  		cQuery += "			AND BC.TitanId BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'" 
 	Endif 		
     
 	If !Empty(mv_par07) .And. !Empty(mv_par08) 
		cQuery += "			AND CE.NumeroCentro BETWEEN '"+AllTrim(mv_par07)+"' AND '"+AllTrim(mv_par08)+"'"
	Endif 	

	cQuery += " ORDER BY EMISSAO,EMPREGUS, CENTRO, ID"
	
	//Salvo o arquivo da query na pasta C:\temp
	MemoWrite("C:\temp\boletos.sql",cQuery)
	
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
	
	DbSelectArea(cTemp)
	
	(cTemp)->(DbGoTop())
	
	While !(cTemp)->(EOF())
	
		aAdd(aBoletos,{(cTemp)->ID,(cTemp)->TITAN,(cTemp)->CENTRO,(cTemp)->EMPREGUS,(cTemp)->NOME,;
		(cTemp)->VALOR,(cTemp)->DESC_STATUS,(cTemp)->EMISSAO,(cTemp)->VENCIMENTO,(cTemp)->DESCUSER,;
		(cTemp)->TIPO,(cTemp)->STATUS_BOLETO,(cTemp)->ID_INVOICE,(cTemp)->ID_NUM_INVOICE,(cTemp)->ID_BOLETO})	
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	If Len(aBoletos) > 0
		FWMsgRun(, {|| xRelatorio() }, "Aguarde", "Gerando relatório...") 
	Else
		MsgAlert("Não há dados pra serem apresentados no relatório!")
	Endif 

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/02/2021
Consultoria: TecSistem
Uso: Regus/Câmara Leal
Info: Relatório dos registros atualizados
*==================================================================*/
Static Function xRelatorio()

	Local aItens     := {}
	Local aCabec     := {"ID","TITAN","CENTRO","EMPREGUS","NOME","VALOR","DESC_STATUS","EMISSAO","VENCIMENTO","DESCUSER","TIPO","STATUS_BOLETO","ID_INVOICE","ID_NUM_INVOICE","ID_BOLETO"}
	Local nX         := 0
	Local nY         := 0
	Local cAba       := "BOLETOS"
	Local cTabela    := "BOLETOS"
	Local cHora      := Time()
	Local cPasta     := GetMV("CL_XARQUI",.F.,"C:\temp\")
	Local cArquivo   := cPasta+'RelBol_'+AllTrim(StrTran(cHora,":",""))+'.xml'
	Local oFWMsExcel := Nil

	//Verifico se há a pasta existe no computador do usuário, caso não exista eu crio a mesma
	If !ExistDir(cPasta)
		MakeDir(cPasta)
	Endif

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	//Aba
	oFWMsExcel:AddworkSheet(cAba) //Não utilizar número junto com sinal de menos. Ex.: 1-

	//Criando a Tabela
	oFWMsExcel:AddTable(cAba,cTabela)

	For nX := 1 To Len(aCabec)
		//Adiciono coluna no excel
		oFWMsExcel:AddColumn(cAba,cTabela,aCabec[nX],1,1,.F.)
	Next nX

	For nX := 1 To Len(aBoletos)

		aItens := Array(Len(aBoletos[nX]))

		For nY := 1 To Len(aBoletos[nX])
			aItens[nY] := aBoletos[nX,nY]
		Next nY

		//Adiciono linha no excel
		oFWMsExcel:AddRow(cAba,cTabela,aItens)

	Next nX

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()

	oFWMsExcel:GetXMLFile(cArquivo)

	//Verifico se o arquivo foi criado
	If File(cArquivo)
		ShellExecute("Open",cArquivo,"","",5) //Abro o arquivo xml
	Else
		MsgAlert("Erro na geração do relatório!")
	Endif

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/05/2020
Consultoria: TecSistem
Uso: Regus/Câmara Leal
Info: Gravação e chamada de parâmetros na SX1
*==================================================================*/
Static Function AjustaSx1(cPerg)

	Local aRegs := {}
	Local nX    := 0
	Local nY    := 0

	//A função aAdd adiciona um novo elemento no final do array
	aAdd(aRegs,{cPerg,"01","Emissão De?"     ,"","","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissão Até?"    ,"","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Vencimento De?"  ,"","","mv_ch3","D",08,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Vencimento Até?" ,"","","mv_ch4","D",08,00,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Titan De?"       ,"","","mv_ch5","C",06,00,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Titan Até?"      ,"","","mv_ch6","C",06,00,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Centro De?"      ,"","","mv_ch7","C",04,00,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Centro Até?"     ,"","","mv_ch8","C",04,00,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))

	For nX := 1 To Len(aRegs)

		If !DbSeek(cPerg + aRegs[nX,2])

			RecLock("SX1",.T.)

			For nY := 1 To FCount()

				If nY <= Len(aRegs[nX])
					FieldPut(nY,aRegs[nX,nY])
				Endif

			Next nY

			SX1->(MsUnlock())

		Endif

	Next nX

Return
