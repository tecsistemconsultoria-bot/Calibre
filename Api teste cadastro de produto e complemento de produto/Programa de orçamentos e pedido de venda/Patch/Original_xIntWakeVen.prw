
#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'TbiConn.ch'
#Include 'RestFul.ch' 

/*
================================================================================
 Programa..: xIntWakeVen
 Autor.....: Fernando Pessoa - TecSistem
 Data......: 14/07/2026
 Descricao.: Consome a API de Vendas da Wake (GET /pedidos) e grava no Protheus
             via ExecAuto:
               - situacaoPedidoId == 7 .......: Orcamento  (MATA415 / SCJ + SCK)
               - situacaoPedidoId <> 7 .......: Pedido Venda (MATA410 / SC5 + SC6)

 Autorizacao.: Enviada no header (fixa) -> Authorization: calib-...
 Parametros..: dataInicial e dataFinal = primeiro e ultimo dia do mes corrente.

 Campos novos: C5_XIDWAK (SC5) e CJ_XIDWAK (SCJ) recebem a tag "pedidoId".
================================================================================
*/

//----------------------------------------------------------------------
// Constantes de configuracao da integracao
//----------------------------------------------------------------------
#Define WAKE_URL     "https://api.fbits.net"
#Define WAKE_PATH    "/pedidos/"
#Define WAKE_AUTH    "calib-c55842ab-9896-4e81-b21e-f717ab6b116d"
#Define WAKE_EMPRESA "01"
#Define WAKE_FILIAL  "01"
// Pasta padrao do arquivo de log na estacao do usuario (Web Agent)
#Define WAKE_LOG_DIR "C:\temp\"
// Pasta padrao do log na estacao (copia via Web Agent). No servidor usa \temp\
#Define WAKE_LOG_DIR "C:\temp\"

/*=================================================================
Info: Ponto de entrada da integracao (executada via JOB/Schedule).
      Processa automaticamente os pedidos do MES CORRENTE: do primeiro
      ao ultimo dia do mes da data de execucao.

      Regra de gravacao:
        - situacaoPedidoId == 7 .....: Orcamento    (MATA415 / SCJ + SCK)
        - situacaoPedidoId <> 7 .....: Pedido Venda (MATA410 / SC5 + SC6)

      OBS: As mensagens em tela (resumo do retorno e resultado da
      gravacao) sao mantidas apenas para a fase de validacao e serao
      removidas depois, ficando somente a gravacao do log.
*==================================================================*/
User Function xIntWakeVen()

	Local aArea    := Nil
	Local lJob     := ( Select("SX2") == 0 ) //Se dicionario nao aberto, veio de Job
	Local dHoje    := Date()
	Local nMes     := 0
	Local nAno     := 0
	Local nProxMes := 0
	Local nProxAno := 0
	Local dDtIni   := CToD("")
	Local dDtFim   := CToD("")
	Local cDataIni := ""
	Local cDataFim := ""

	//Se veio de Job/Schedule, prepara o ambiente RPC (Empresa/Filial)
	If lJob
		RPCSetType(3)
		RPCSetEnv(WAKE_EMPRESA, WAKE_FILIAL)
	EndIf

	aArea := GetArea()

	//Usa a data base do ambiente quando disponivel
	If Type("dDataBase") == "D" .And. !Empty(dDataBase)
		dHoje := dDataBase
	EndIf

	//Periodo do mes corrente (primeiro ao ultimo dia)
	nMes := Month(dHoje)
	nAno := Year(dHoje)

	nProxMes := nMes + 1
	nProxAno := nAno
	If nProxMes > 12
		nProxMes := 1
		nProxAno++
	EndIf

	dDtIni := SToD(StrZero(nAno,4) + StrZero(nMes,2) + "01")             //Primeiro dia do mes
	dDtFim := SToD(StrZero(nProxAno,4) + StrZero(nProxMes,2) + "01") - 1 //Ultimo dia do mes

	cDataIni := WkDtApi(dDtIni)
	cDataFim := WkDtApi(dDtFim)

	ConOut("[" + DTOC(Date()) + " " + Time() + "] xIntWakeVen - Iniciando integracao Wake. Periodo: " + cDataIni + " a " + cDataFim)

	WkExec(cDataIni, cDataFim)

	ConOut("[" + DTOC(Date()) + " " + Time() + "] xIntWakeVen - Integracao finalizada.")

	RestArea(aArea)

	//Encerra o ambiente somente quando executado via Job
	If lJob
		RpcClearEnv()
	EndIf

Return

/*=================================================================
Info: Converte data (tipo Date) para o formato exigido pela API
      da Wake: AAAA-MM-DD.
*==================================================================*/
Static Function WkDtApi(dData)

	Local cDtS := DToS(dData)

Return SubStr(cDtS, 1, 4) + "-" + SubStr(cDtS, 5, 2) + "-" + SubStr(cDtS, 7, 2)

/*=================================================================
Info: Monta um resumo (texto) com a quantidade de pedidos e
      orcamentos existentes no retorno da API.
*==================================================================*/
Static Function WkResumo(oJson)

	Local nX   := 0
	Local nSit := 0
	Local nPed := 0
	Local nOrc := 0
	Local cRet := ""

	For nX := 1 To Len(oJson)
		nSit := IIf(AttIsMemberOf(oJson[nX], "SITUACAOPEDIDOID"), oJson[nX]:SITUACAOPEDIDOID, 0)
		If nSit == 7
			nOrc++
		Else
			nPed++
		EndIf
	Next nX

	cRet := "A API retornou " + cValToChar(Len(oJson)) + " registro(s):" + CRLF
	cRet += " - Pedidos de Venda: " + cValToChar(nPed) + CRLF
	cRet += " - Orcamentos......: " + cValToChar(nOrc) + CRLF

Return cRet

/*=================================================================
Info: Consome a API da Wake (GET /pedidos) e retorna o array de
      objetos ja deserializado. Retorna Nil em caso de erro.
*==================================================================*/
Static Function WkGet(cDataIni, cDataFim)

	Local oRest    := Nil
	Local aHeadOut := {}
	Local cJson    := ""
	Local cPath    := ""
	Local oJson    := Nil

	//Monta o endpoint com os parametros de data
	cPath := WAKE_PATH + "?dataInicial=" + cDataIni + "&dataFinal=" + cDataFim

	//Header fixo exigido pela Wake
	aAdd(aHeadOut, "Content-Type: application/json")
	aAdd(aHeadOut, "Authorization: " + WAKE_AUTH)

	oRest := FWRest():New(WAKE_URL)
	oRest:setPath(cPath)

	ConOut("WkGet - Consultando: " + WAKE_URL + cPath)

	If !oRest:Get(aHeadOut)
		ConOut("WkGet - ERRO na chamada da API: " + oRest:GetLastError())
		If !IsBlind()
			MsgStop("Erro ao consultar a API da Wake:" + CRLF + oRest:GetLastError(), "Integracao Wake")
		EndIf
		Return Nil
	EndIf

	cJson := oRest:GetResult()

	If Empty(cJson)
		ConOut("WkGet - Retorno da API vazio.")
		Return Nil
	EndIf

	//Parse do JSON (a raiz eh um array de pedidos)
	FWJsonDeserialize(cJson, @oJson)

	If ValType(oJson) <> "A"
		ConOut("WkGet - JSON invalido ou fora do formato esperado (array).")
		Return Nil
	EndIf

	ConOut("WkGet - Total de pedidos retornados: " + cValToChar(Len(oJson)))

Return oJson

/*=================================================================
Info: Consome a API e processa (grava). Usado no modo automatico
      (Job/Schedule).
*==================================================================*/
Static Function WkExec(cDataIni, cDataFim)

	Local oJson := Nil
	Local cLog  := ""

	oJson := WkGet(cDataIni, cDataFim)

	If ValType(oJson) <> "A" .Or. Len(oJson) == 0

		//Registra no log que nenhum pedido foi encontrado no periodo
		cLog += "Integracao Wake - " + DTOC(Date()) + " " + Time() + CRLF
		cLog += "Periodo consultado: " + cDataIni + " a " + cDataFim + CRLF
		cLog += "Nenhum pedido/orcamento encontrado no periodo consultado." + CRLF

		ConOut("WkExec - Nenhum pedido para processar. Periodo: " + cDataIni + " a " + cDataFim)
		WkLog(cLog)

		If !IsBlind()
			MsgInfo("Nenhum pedido/orcamento encontrado no periodo:" + CRLF + cDataIni + " a " + cDataFim, "Integracao Wake")
		EndIf

		Return
	EndIf

	//Mensagem informativa sobre o retorno da API (mantida apenas para validacao)
	If !IsBlind()
		MsgInfo(WkResumo(oJson), "Integracao Wake - Retorno da API")
	EndIf

	WkProc(oJson, .T.)

Return

/*=================================================================
Info: Percorre o array de pedidos ja consultado, grava cada um na
      rotina correta (pedido/orcamento), gera arquivo de log e,
      quando houver interface, exibe o resultado em tela.
*==================================================================*/
Static Function WkProc(oJson, lMostraTela)

	Local nX       := 0
	Local nOk      := 0
	Local nErro    := 0
	Local cLog     := ""
	Local oPedido  := Nil
	Local nSit     := 0
	Local lRet     := .F.

	Default lMostraTela := .F.

	cLog += "Integracao Wake - " + DTOC(Date()) + " " + Time() + CRLF
	cLog += "Registros recebidos da API: " + cValToChar(Len(oJson)) + CRLF

	//Percorre cada pedido retornado pela API
	For nX := 1 To Len(oJson)

		oPedido := oJson[nX]

		//Situacao do pedido define a rotina (7 = orcamento / demais = pedido)
		nSit := IIf(AttIsMemberOf(oPedido, "SITUACAOPEDIDOID"), oPedido:SITUACAOPEDIDOID, 0)

		cLog += CRLF + "==============================================" + CRLF
		cLog += "Pedido Wake (pedidoId): " + cValToChar(IIf(AttIsMemberOf(oPedido,"PEDIDOID"), oPedido:PEDIDOID, 0)) + CRLF
		cLog += "situacaoPedidoId......: " + cValToChar(nSit) + CRLF

		If nSit == 7
			lRet := WkOrc(oPedido, @cLog)
		Else
			lRet := WkPed(oPedido, @cLog)
		EndIf

		If lRet
			nOk++
		Else
			nErro++
		EndIf

	Next nX

	cLog += CRLF + "==============================================" + CRLF
	cLog += "Total processados com sucesso/ignorados: " + cValToChar(nOk)   + CRLF
	cLog += "Total com erro.........................: " + cValToChar(nErro) + CRLF

	ConOut(cLog)

	//Gera o arquivo de log em disco
	WkLog(cLog)

	//Exibe o resultado em tela (somente com interface)
	If lMostraTela .And. !IsBlind()
		WkShow(cLog)
	EndIf

Return

/*=================================================================
Info: Grava o arquivo de log no mesmo fluxo de API_PRODUTOS.prw.

      1) Grava no AppServer em caminho relativo (\temp\), sem letra de
         unidade (obrigatorio para o CpyS2T).
      2) Com interface (SmartClient / Web Agent): cria a pasta na
         estacao (ES_WKLOG ou C:\temp\) e copia o arquivo para la.
         Se a copia funcionar, apaga o arquivo do servidor.
      3) Em job (IsBlind): o arquivo permanece no servidor.

      Retorna o caminho final (local se copiado; servidor se nao).
*==================================================================*/
Static Function WkLog(cLog)

	Local cPastaCli := AllTrim(SuperGetMV("ES_WKLOG", .F., WAKE_LOG_DIR))
	Local cPastaSrv := "\temp\"
	Local cData     := DToS(Date())
	Local cHora     := StrTran(Time(), ":", "")
	Local cNomeArq  := "Log_Wake_" + cData + "_" + cHora + ".txt"
	Local cArqSrv   := ""
	Local cArqCli   := ""
	Local lCopiaOk  := .F.
	Local cDirSrv   := "\temp"
	Local cDirCli   := ""

	If Empty(cPastaCli)
		cPastaCli := WAKE_LOG_DIR
	EndIf
	If !Right(cPastaCli, 1) $ "\/"
		cPastaCli += "\"
	EndIf

	cDirCli := Left(cPastaCli, Len(cPastaCli) - 1)
	cArqSrv := cPastaSrv + cNomeArq
	cArqCli := cPastaCli + cNomeArq

	// 1) Pasta temp no AppServer (caminho relativo; MakeDir/MemoWrite no RootPath)
	If !ExistDir(cDirSrv)
		If MakeDir(cDirSrv) != 0
			ConOut("WkLog - Nao foi possivel criar pasta no servidor: " + cDirSrv)
		Else
			ConOut("WkLog - Pasta criada no servidor: " + cDirSrv)
		EndIf
	EndIf

	If !MemoWrite(cArqSrv, cLog)
		ConOut("WkLog - Falha ao gravar o log no servidor: " + cArqSrv)
		Return ""
	EndIf
	ConOut("WkLog - Log temporario no servidor: " + cArqSrv)

	// 2) SmartClient / Web Agent: cria pasta na ESTACAO e copia para C:\temp\ (ou ES_WKLOG)
	If !IsBlind()
		WaitRun('cmd /c if not exist "' + cDirCli + '" mkdir "' + cDirCli + '"', 5)

		// 1o param SEM letra de unidade; 4o param .F. = nao exibe mensagem de erro do CpyS2T
		lCopiaOk := .F.
		BEGIN SEQUENCE
			lCopiaOk := CpyS2T(cArqSrv, cPastaCli, .F., .F.)
		RECOVER
			lCopiaOk := .F.
			ConOut("WkLog - Excecao no CpyS2T (Web Agent/path). Mantido no servidor: " + cArqSrv)
		END SEQUENCE

		If lCopiaOk
			ConOut("WkLog - Log copiado para a maquina local: " + cArqCli)
			FErase(cArqSrv)
			Return cArqCli
		EndIf

		ConOut("WkLog - Falha no CpyS2T para " + cPastaCli + ;
		       " (verifique o Web Agent). Mantido no servidor: " + cArqSrv)
		Return cArqSrv
	EndIf

	// Job / blind: arquivo permanece no servidor
Return cArqSrv

/*=================================================================
Info: Exibe o log do processamento em uma janela (somente testes).
*==================================================================*/
Static Function WkShow(cLog)

	Local oDlg  := Nil
	Local oMemo := Nil
	Local oBtn  := Nil
	Local cTexto := cLog

	DEFINE MSDIALOG oDlg TITLE "Resultado da Integracao Wake" FROM 000,000 TO 400,700 PIXEL

	@ 005,005 GET oMemo VAR cTexto MEMO SIZE 340,175 OF oDlg PIXEL
	oMemo:lReadOnly := .T.

	@ 185,290 BUTTON oBtn PROMPT "Fechar" SIZE 050,015 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*=================================================================
Info: Retorna o documento do cliente a partir do objeto usuario.
      Prioriza o CPF (pessoa fisica); se estiver vazio/ausente, usa
      o CNPJ (pessoa juridica). Retorna "" se nenhum estiver preenchido.
*==================================================================*/
Static Function WkDoc(oPedido)

	Local cDoc := ""
	Local oUsr := Nil

	If AttIsMemberOf(oPedido, "USUARIO") .And. ValType(oPedido:USUARIO) == "O"

		oUsr := oPedido:USUARIO

		If AttIsMemberOf(oUsr, "CPF") .And. ValType(oUsr:CPF) == "C" .And. !Empty(AllTrim(oUsr:CPF))
			cDoc := AllTrim(oUsr:CPF)
		ElseIf AttIsMemberOf(oUsr, "CNPJ") .And. ValType(oUsr:CNPJ) == "C" .And. !Empty(AllTrim(oUsr:CNPJ))
			cDoc := AllTrim(oUsr:CNPJ)
		EndIf

	EndIf

Return cDoc

/*=================================================================
Info: Localiza o cliente na SA1 pelo CPF/CNPJ (A1_CGC).
      Retorna array {A1_COD, A1_LOJA}. Vazio se nao encontrar.
*==================================================================*/
Static Function WkCli(cCGC)

	Local aArea   := GetArea()
	Local aRet    := {"", ""}
	Local cTemp   := GetNextAlias()
	Local cQuery  := ""

	//Limpa mascara do documento
	cCGC := AllTrim(cCGC)
	cCGC := StrTran(cCGC, ".", "")
	cCGC := StrTran(cCGC, "/", "")
	cCGC := StrTran(cCGC, "-", "")

	If Empty(cCGC)
		RestArea(aArea)
		Return aRet
	EndIf

	cQuery := "SELECT A1_COD, A1_LOJA "
	cQuery += "  FROM " + RetSQLName("SA1") + " SA1 "
	cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "   AND SA1.A1_CGC    = '" + cCGC + "' "
	cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SA1.R_E_C_N_O_ "

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTemp, .T., .T.)

	If !(cTemp)->(Eof())
		aRet[1] := (cTemp)->A1_COD
		aRet[2] := (cTemp)->A1_LOJA
	EndIf

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return aRet

/*=================================================================
Info: Verifica se o pedido da Wake ja foi importado, buscando o
      pedidoId no campo informado (C5_XIDWAK ou CJ_XIDWAK).
      Retorna o numero do documento ja gravado ou "" se nao existir.
*==================================================================*/
Static Function WkDup(cTabela, cCampoId, cCampoNum, cIdWake)

	Local aArea   := GetArea()
	Local cTemp   := GetNextAlias()
	Local cQuery  := ""
	Local cRet    := ""

	If Empty(cIdWake)
		RestArea(aArea)
		Return cRet
	EndIf

	cQuery := "SELECT " + cCampoNum + " AS NUMDOC "
	cQuery += "  FROM " + RetSQLName(cTabela) + " "
	cQuery += " WHERE " + cCampoId  + " = '" + AllTrim(cIdWake) + "' "
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
	EndIf

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTemp, .T., .T.)

	If !(cTemp)->(Eof())
		cRet := AllTrim((cTemp)->NUMDOC)
	EndIf

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return cRet

/*=================================================================
Info: Grava PEDIDO DE VENDA (MATA410 - SC5/SC6).
      Utilizado quando situacaoPedidoId <> 7.
*==================================================================*/
Static Function WkPed(oPedido, cLog)

	Local aArea    := GetArea()
	Local aCabec   := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local aCli     := {}
	Local aLog     := {}
	Local oItens   := Nil
	Local oItem    := Nil
	Local nX       := 0
	Local cCGC     := ""
	Local cIdWake  := ""
	Local cErro    := ""
	//Local cNumExist := ""
	Local lRet     := .F.

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	//Documento do cliente: usa CPF (pessoa fisica) ou CNPJ (pessoa juridica),
	//o que estiver preenchido no retorno da API.
	cCGC := WkDoc(oPedido)

	cIdWake := cValToChar(IIf(AttIsMemberOf(oPedido,"PEDIDOID"), oPedido:PEDIDOID, 0))

	//Anti-duplicidade: se este pedidoId ja existe na SC5, nao grava novamente.
	//(Se existir apenas na SCJ como orcamento, ainda assim gera o pedido aqui.)
	cNumExist := WkDup("SC5", "C5_XIDWAK", "C5_NUM", cIdWake)
	If !Empty(cNumExist)
		cLog += "IGNORADO: Pedido Wake " + cIdWake + " ja importado (Pedido de Venda " + cNumExist + ")." + CRLF
		ConOut("WkPed - Pedido Wake " + cIdWake + " ja existe (SC5 " + cNumExist + "). Ignorado.")
		RestArea(aArea)
		Return .T.
	EndIf

	//Localiza o cliente pelo A1_CGC
	aCli := WkCli(cCGC)

	If Empty(aCli[1])
		cLog += "ERRO: Cliente nao encontrado na SA1 para o CPF/CNPJ: " + cCGC + CRLF
		RestArea(aArea)
		Return .F.
	EndIf

	//Itens do pedido
	If !AttIsMemberOf(oPedido, "ITENS") .Or. ValType(oPedido:ITENS) <> "A" .Or. Len(oPedido:ITENS) == 0
		cLog += "ERRO: Pedido sem itens (tag itens)." + CRLF
		RestArea(aArea)
		Return .F.
	EndIf

	oItens := oPedido:ITENS

	//---------------------------------------------------------------
	// Cabecalho (SC5)
	//---------------------------------------------------------------
	aAdd(aCabec, {"C5_FILIAL" , WAKE_FILIAL , Nil})
	aAdd(aCabec, {"C5_TIPO"   , "N"         , Nil})
	aAdd(aCabec, {"C5_CLIENTE", aCli[1]     , Nil}) //A1_COD retornado pelo CPF
	aAdd(aCabec, {"C5_LOJACLI", aCli[2]     , Nil}) //A1_LOJA retornado pelo CPF
	aAdd(aCabec, {"C5_XFATURA", "S"         , Nil})
	aAdd(aCabec, {"C5_TIPLIB" , "2"         , Nil})
	aAdd(aCabec, {"C5_XIDWAK" , cIdWake     , Nil}) //ID do pedido na Wake
	aAdd(aCabec, {"C5_EMISSAO", dDataBase   , Nil})

	//---------------------------------------------------------------
	// Itens (SC6)
	//---------------------------------------------------------------
	For nX := 1 To Len(oItens)

		oItem := oItens[nX]
		aLinha := {}

		aAdd(aLinha, {"C6_ITEM"   , StrZero(nX, 2)                          , Nil})
		aAdd(aLinha, {"C6_PRODUTO", AllTrim(AllToChar(oItem:SKU))           , Nil}) //tag sku
		aAdd(aLinha, {"C6_OPER"   , "01"                                    , Nil})
		aAdd(aLinha, {"C6_QTDVEN" , oItem:QUANTIDADE                        , Nil}) //tag quantidade
		aAdd(aLinha, {"C6_PRCVEN" , oItem:VALORITEM                         , Nil}) //tag valorItem (valor unitario)
		//C6_VALOR: deixamos o sistema calcular (quantidade x preco unitario)

		aAdd(aItens, aLinha)

	Next nX

	//Garante a filial correta para a inclusao
	cFilAnt := WAKE_FILIAL

	//---------------------------------------------------------------
	// ExecAuto - Inclusao do Pedido de Venda
	//---------------------------------------------------------------
	Begin Transaction

		MSExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3) // 3 = Inclusao

		If lMsErroAuto

			aLog := GetAutoGRLog()
			For nX := 1 To Len(aLog)
				cErro += aLog[nX] + CRLF
			Next nX

			cLog += "ERRO ao gravar PEDIDO DE VENDA (Wake " + cIdWake + "):" + CRLF + cErro + CRLF
			ConOut("WkPed - Erro Execauto Pedido Wake " + cIdWake + ":" + CRLF + cErro)

			DisarmTransaction()
			RollBackSx8()
			lRet := .F.

		Else

			cLog += "OK: Pedido de Venda incluido - Numero: " + SC5->C5_NUM + " (Wake " + cIdWake + ")" + CRLF
			ConOut("WkPed - Pedido incluido: " + SC5->C5_NUM)
			ConfirmSx8()
			lRet := .T.

		EndIf

	End Transaction

	RestArea(aArea)

Return lRet

/*=================================================================
Info: Grava ORCAMENTO (MATA415 - SCJ/SCK).
      Utilizado quando situacaoPedidoId == 7.
*==================================================================*/
Static Function WkOrc(oPedido, cLog)

	Local aArea    := GetArea()
	Local aCabec   := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local aCli     := {}
	Local aLog     := {}
	Local oItens   := Nil
	Local oItem    := Nil
	Local nX       := 0
	Local cCGC     := ""
	Local cIdWake  := ""
	Local cErro    := ""
	Local cChave   := ""
	//Local cNumExist := ""
	Local lRet     := .F.

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	//Documento do cliente: usa CPF (pessoa fisica) ou CNPJ (pessoa juridica),
	//o que estiver preenchido no retorno da API.
	cCGC := WkDoc(oPedido)

	cIdWake := cValToChar(IIf(AttIsMemberOf(oPedido,"PEDIDOID"), oPedido:PEDIDOID, 0))

	//Anti-duplicidade: se este pedidoId ja existe na SCJ, nao grava novamente.
	//(Se existir apenas na SC5 como pedido, ainda assim gera o orcamento aqui.)
	cNumExist := WkDup("SCJ", "CJ_XIDWAK", "CJ_NUM", cIdWake)
	If !Empty(cNumExist)
		cLog += "IGNORADO: Pedido Wake " + cIdWake + " ja importado (Orcamento " + cNumExist + ")." + CRLF
		ConOut("WkOrc - Pedido Wake " + cIdWake + " ja existe (SCJ " + cNumExist + "). Ignorado.")
		RestArea(aArea)
		Return .T.
	EndIf

	//Localiza o cliente pelo A1_CGC
	aCli := WkCli(cCGC)

	If Empty(aCli[1])
		cLog += "ERRO: Cliente nao encontrado na SA1 para o CPF/CNPJ: " + cCGC + CRLF
		RestArea(aArea)
		Return .F.
	EndIf

	//Itens do orcamento
	If !AttIsMemberOf(oPedido, "ITENS") .Or. ValType(oPedido:ITENS) <> "A" .Or. Len(oPedido:ITENS) == 0
		cLog += "ERRO: Orcamento sem itens (tag itens)." + CRLF
		RestArea(aArea)
		Return .F.
	EndIf

	oItens := oPedido:ITENS

	//---------------------------------------------------------------
	// Cabecalho (SCJ)
	//---------------------------------------------------------------
	aAdd(aCabec, {"CJ_FILIAL" , WAKE_FILIAL , Nil})
	aAdd(aCabec, {"CJ_EMISSAO", dDataBase   , Nil})
	aAdd(aCabec, {"CJ_CLIENTE", aCli[1]     , Nil}) //A1_COD  (cliente)
	aAdd(aCabec, {"CJ_LOJA"   , aCli[2]     , Nil}) //A1_LOJA (loja do cliente)
	aAdd(aCabec, {"CJ_CLIENT" , aCli[1]     , Nil}) //A1_COD  (cliente de entrega)
	aAdd(aCabec, {"CJ_LOJAENT", aCli[2]     , Nil}) //A1_LOJA (loja de entrega)
	aAdd(aCabec, {"CJ_XIDWAK" , cIdWake     , Nil}) //ID do pedido na Wake

	//---------------------------------------------------------------
	// Itens (SCK)
	//---------------------------------------------------------------
	For nX := 1 To Len(oItens)

		oItem := oItens[nX]
		aLinha := {}

		aAdd(aLinha, {"CK_ITEM"   , StrZero(nX, 2)                          , Nil})
		aAdd(aLinha, {"CK_PRODUTO", AllTrim(AllToChar(oItem:SKU))           , Nil}) //tag sku
		aAdd(aLinha, {"CK_OPER"   , "01"                                    , Nil})
		aAdd(aLinha, {"CK_QTDVEN" , oItem:QUANTIDADE                        , Nil}) //tag quantidade
		aAdd(aLinha, {"CK_PRCVEN" , oItem:VALORITEM                         , Nil}) //tag valorItem (valor unitario)
		//CK_VALOR: deixamos o sistema calcular (quantidade x preco unitario)

		aAdd(aItens, aLinha)

	Next nX

	//Garante a filial correta para a inclusao
	cFilAnt := WAKE_FILIAL

	//---------------------------------------------------------------
	// ExecAuto - Inclusao do Orcamento
	//---------------------------------------------------------------
	Begin Transaction

		MSExecAuto({|x, y, z| MATA415(x, y, z)}, aCabec, aItens, 3) // 3 = Inclusao

		If lMsErroAuto

			aLog := GetAutoGRLog()
			For nX := 1 To Len(aLog)
				cErro += aLog[nX] + CRLF
			Next nX

			cLog += "ERRO ao gravar ORCAMENTO (Wake " + cIdWake + "):" + CRLF + cErro + CRLF
			ConOut("WkOrc - Erro Execauto Orcamento Wake " + cIdWake + ":" + CRLF + cErro)

			DisarmTransaction()
			RollBackSx8()
			lRet := .F.

		Else

			//Reposiciona na SCJ para recuperar o numero gerado
			cChave := xFilial("SCJ") + aCli[1] + aCli[2] + DTOS(dDataBase)

			DbSelectArea("SCJ")
			SCJ->(DbSetOrder(3)) //Indice 3: CJ_FILIAL + CJ_CLIENTE + CJ_LOJA + DTOS(CJ_EMISSAO)

			If SCJ->(DbSeek(cChave))
				cLog += "OK: Orcamento incluido - Numero: " + SCJ->CJ_NUM + " (Wake " + cIdWake + ")" + CRLF
				ConOut("WkOrc - Orcamento incluido: " + SCJ->CJ_NUM)
			Else
				cLog += "OK: Orcamento incluido (Wake " + cIdWake + ")" + CRLF
			EndIf

			ConfirmSx8()
			lRet := .T.

		EndIf

	End Transaction

	RestArea(aArea)

Return lRet
