#Include 'Totvs.ch'
#Include 'RestFul.ch'
#Include 'FWMVCDef.ch'
#Include 'CLBAPI.ch'

Static cNomeApi   := "CLBAPI10"
Static cMetodo    := "incluicliente"
Static cVersaoApi := "v1.08"
Static cDescrApi  := "Inclusao de Cliente"

Static _cEmp    := "01"	// empresa padrï¿½o para testes
Static _cFil    := "01"	// filial padrï¿½o para testes

Static bTimeStamp := {|| Strzero(Year(Date()),4)+"-"+Strzero(Month(Date()),2)+"-"+Strzero(Day(Date()),2)+"T"+Time()+"Z" }


/*/{Protheus.doc} CLBAPI10
Rotina para testes da de inclusao de cliente
@type user function
@author Aldo Barbosa dos Santos
@since 09/04/2026
@see (links_or_references)
/*/
User Function CLBAPI10() // Funcao para testes da API

	_BaseLocal := .F.
	if _BaseLocal
		_cEmp := "99"
	Endif	

	if Select("SX2") == 0
		wfprepenv(_cEmp,_cFil)
	Endif

	cJsonIn := '{ '

	if _BaseLocal
		//cJsonIn += '"a1_cod": "A00001",' '
		cJsonIn += '"a1_loja": "01", '
		cJsonIn += '"a1_email": "cliente@exemplo.com.br", '
		cJsonIn += '"a1_pessoa": "F", '
		cJsonIn += '"a1_cgc": "9149352-8", '
		cJsonIn += '"a1_tipo": "A", '
		//cJsonIn += '"a1_tipdoc": "2", '
		cJsonIn += '"a1_nome": "EMPRESA EXEMPLO LTDA", '
		cJsonIn += '"a1_nreduz": "EMPRESA EXEMPLO", '
		cJsonIn += '"a1_ddd": "11", '
		cJsonIn += '"a1_tel": "999999999", '
		cJsonIn += '"a1_contato": "JOAO DA SILVA", '
		cJsonIn += '"a1_pais": "586", '
		cJsonIn += '"a1_codpais": "1058", '
		cJsonIn += '"a1_bairro": "CENTRO", '
		cJsonIn += '"a1_end": "RUA DA PAZ", '
		cJsonIn += '"a1_complem": "SALA 10", '
		cJsonIn += '"a1_mun": "SAO PAULO", '
		cJsonIn += '"a1_bairroc": "", '
		cJsonIn += '"a1_endcob": "RUA DA PAZ", '
		cJsonIn += '"a1_munc": "SAO PAULO", '
		cJsonIn += '"a1_retiva": "N", '
		cJsonIn += '"a1_ciudad": "3397", '
		cJsonIn += '"a1_depto": "11", '
		cJsonIn += '"a1_distr": "145", '
	Else
		//cJsonIn += '"a1_cod": "A00001",' '
		cJsonIn += '"a1_loja": "01", '
		cJsonIn += '"a1_email": "cliente@exemplo.com.br", '
		// cJsonIn += '"a1_pessoa": "F", '
		cJsonIn += '"a1_cgc": "11414450850", '
		cJsonIn += '"a1_tipo": "R", '
		cJsonIn += '"a1_inscr": "", '
		cJsonIn += '"a1_inscrm": "", '
		//cJsonIn += '"a1_sativ1": "COM", '
		//cJsonIn += '"a1_crvbol": "S", '
		//cJsonIn += '"a1_contrib": "S", '
		//cJsonIn += '"a1_xfatpar": "N", '
		//cJsonIn += '"a1_xmultpv": "N", '
		cJsonIn += '"a1_nome": "EMPRESA EXEMPLO LTDA", '
		cJsonIn += '"a1_nreduz": "EMPRESA EXEMPLO", '
		cJsonIn += '"a1_ddd": "11", '
		cJsonIn += '"a1_tel": "999999999", '
		cJsonIn += '"a1_contato": "JOAO DA SILVA", '
		cJsonIn += '"a1_pais": "586", '
		cJsonIn += '"a1_codpais": "1058", '
		//cJsonIn += '"a1_cep": "01001000", '
		cJsonIn += '"a1_bairro": "CENTRO", '
		cJsonIn += '"a1_end": "RUA DA PAZ", '
		cJsonIn += '"a1_complem": "SALA 10", '
		cJsonIn += '"a1_est": "SP", '
		//cJsonIn += '"a1_cod_mun": "3550308", '
		cJsonIn += '"a1_mun": "SAO PAULO", '
		//cJsonIn += '"a1_cepc": "01001000", '
		// cJsonIn += '"a1_bairroc": "", '
		// cJsonIn += '"a1_endcob": "RUA DA PAZ", '
		// cJsonIn += '"a1_munc": "SAO PAULO", '
		// cJsonIn += '"a1_estc": "SP" '
		//cJsonIn += '"a1_conta": "1.1.1.01", '
		//cJsonIn += '"a1_tpfret": "0", '
		//cJsonIn += '"a1_naturez": "VENDA", '
		//cJsonIn += '"a1_cond": "001", '
		//cJsonIn += '"a1_vend": "0001", '
		//cJsonIn += '"a1_tabela": "001", '
		//cJsonIn += '"a1_transp": "0001", '
		//cJsonIn += '"a1_dtcad": "2026-04-04", '
		//cJsonIn += '"a1_hrcad": "14:30", '
	
			cJsonIn := '{ "a1_cgc": "29502477000157",  "a1_loja": "01",  "a1_tipo": "F",  "a1_pessoa": "J", '+;
			 '"a1_nome": "TECSISTEM SOLUÇÕES EM SISTEMAS DE INFORMAÇÃO LTDA",  "a1_nreduz": "TECSISTEM SOLUÇÕES EM SISTEMAS DE INFORMAÇÃO LTDA", '+;
			 '"a1_email": "tecsistemconsultoria@gmail.com",  "a1_ddd": "11",  "a1_tel": "947417467",  "a1_contato": "VINICIUS NASCIMENTO DE OLIVEIRA", '+;
			 '"a1_bairro": "JARDIM SANTA CECILIA",  "a1_end": "RUA ITAIOPOLIS, 189",  "a1_cep": "07123430",  "a1_cod_mun": "00105",  "a1_est": "SP",  "a1_inscr": "ISENTO",  "a1_xdtfun": "2026-10-03",  "a1_tpfret": "F",  "a1_endcob": "RUA ITAIOPOLIS, 189",  "a1_munc": "SAO PAULO",  "a1_estc": "SP",  "a1_cepc": "07123430",  "a1_conta": "11201001",  "a1_naturez": "1.1.1.02",  "a1_crvbol": "1",  "a1_contrib": "2",  "a1_vend": "000000",  "a1_tabela": "V07",  "a1_cond": "001",  "a1_sativ1": "000001",  "a1_xfatpar": "N",  "a1_xmultpv": "N" '
	Endif

	// cJsonIn += '"ai0_recbol": "1", '
	// cJsonIn += '"ai0_emabol": "aaa@bbb.com" '
	cJsonIn += '}'

	oJson := GravaDados(cJsonIn)
	cJson := oJsonIn:toJson()
	cJson := EncodeUTF8(cJson, "cp1252")

Return


/*/{Protheus.doc} CLBAPI10
WebService API de Produtos
@type user function
@author Aldo Barbosa dos Santos
@since 09/04/2026
@see (links_or_references)
	Info: 			WebService API de Produtos
	Parametro: 		Json  			Exemplo  : { "Articulo":"2749763" }
					 Se nï¿½o passado nenhum parï¿½metro a API retornarï¿½ todos os produtos
/*/
WSRESTFUL CLBAPI10 DESCRIPTION "Inclusao de Cliente"

WSMETHOD POST incluicliente DESCRIPTION "Inclusao de Cliente" WSSYNTAX "incluicliente/{json}"

END WSRESTFUL 


/*/{Protheus.doc} CLBAPI10
WebService API de Produtos
@type user function
@author Aldo Barbosa dos Santos
@since 09/04/2026
@see (links_or_references)
/*/
WSMETHOD POST incluicliente WSSERVICE CLBAPI10

	Local cJsonIn     := self:GetContent()
	//Local cResposta := ""
	
	Private lResult   := .T.
	Private oJson

	cJsonIn:= DecodeUTF8(cJsonIn, "cp1252")

	ErrorBlock({|e| ChkErro( e , @lResult) } )

	Begin Sequence

		If Select("SX6") == 0
			wfprepenv(_cEmp,_cFil)
		Endif

		ChkFile("SA1")

		// ativa contexto Json
		::SetContentType( 'application/json' )

		Conout2( "### Inicio API "+cNomeApi+"/"+cMetodo+" "+cVersaoApi)
		Conout2( " Parametros informados ")
		Conout2( "   {json} ")
		Conout2(" > Iniciando Rotina "+cNomeApi+" "+cDescrApi)

		// realiza a gravaï¿½ï¿½o dos dados e gera uma resposta
		oJson := GravaDados(cJsonIn)

		if ! oJson['_success']
			lResult := .F.
			self:SetRestFault(400, oJson['_message'])
		Endif

		cJson := oJson:toJson()
		cJson := EncodeUTF8(cJson, "cp1252")

		Conout2(" > Processamento realizado")

		if oJson['_success'] 
			self:setResponse(cJson)
		Endif

		lRet := .T.

		Conout2("### Final do processamento")
	
	End Sequence	

Return( lResult )


/*/{Protheus.doc} GeraDados
Funï¿½ï¿½o que le os produtos e gera um json conforme parametros
@type user function
@author Aldo Barbosa dos Santos
@since 09/04/2026
@see (links_or_references)
/*/
// Static Function GravaDados(cJsonIn)
// 	Local nA

// 	Private aDadosSA1 := {}
// 	Private aDadosAI0 := {}
// 	Private oJsonIn := JsonObject():New()
// 	Private oJson

// 	Private lMsErroAuto := .F.
// 	Private lAutoErrNoFile := .T.
// 	Private lMsHelpAuto :=.T.

// 	if Select("SX2") == 0
// 		wfprepenv(_cEmp,_cFil)
// 	Endif

// 	ChkFile("AI0")
// 	ChkFile("SA1")

// 	// instancia a classe de retorno dos produtos
// 	oJson := JsonObject():New()
// 	oJson['_api_name']     := cNomeApi
// 	oJson['_api_method']    := cMetodo
// 	oJson['_api_version']  := cVersaoApi
//     oJson['_timestamp']    := Eval(bTimeStamp)
// 	oJson['_success']       := .T.
// 	oJson['_message']      := ""

// 	// converte o texto em um objeto
//  	oJsonIn:FromJson(cJsonIn)

// 	if ValType(oJsonIn) <> "J"
// 		oJson["_success"]      := .F.
// 		oJson["_message"]     := Erro423		//'Error 423 - Falha na estrutura do Json: '+cJsonIn
// 	Else	
// 		// campos contidos no json
// 		aNames := oJsonIn:GetNames()

// 		// criaï¿½ï¿½o dos vetores para execauto
// 		For nA := 1 to Len(aNames)
// 			cCampo := Upper(Alltrim(aNames[nA]))

// 			if Left(cCampo,3) == "A1_" .and. SA1->( FieldPos(cCampo)) > 0
// 				// se for campo iniciando com A1_ e o campo existir adiciona no vetor da SA1
// 				uDado  := oJsonIn[aNames[nA]]
// 				AAdd(aDadosSA1, {cCampo, uDado, Nil} )
// 			Elseif Left(cCampo,3) == "AI0" .and. AI0->( FieldPos(cCampo)) > 0
// 				// se for campo iniciando com AI0 e o campo existir adiciona no vetor da AI0
// 				uDado  := oJsonIn[aNames[nA]]
// 				AAdd(aDadosAI0, {cCampo, uDado, Nil} )
// 			Endif
// 		Next

// 		// processsa os campos com dados default conforme planilha enviada
// 		// DadosDefault()

// 		if oJson["_success"]
// 			// ATUALMENTE DESABILITADO - validaï¿½ï¿½o dos dados do cadastro de clientes
// 			//ValidaDados(aDadosSA1)
// 		Endif

// 		if oJson["_success"]

// 			Begin Transaction
// 				// Chamada para cadastrar o cliente
// 				lMsErroAuto := .F.
// 				MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aDadosSA1, 3, aDadosAI0)

// 				If lMsErroAuto  
// 					DISARMTRANSACTION()

// 					aAutoErro 	:= GETAUTOGRLOG()
// 					cErroCon    := XLOG(aAutoErro)

// 					oJson["_success"]   := .F.
// 					oJson["_message"]   := Erro425+cErroCon		//	'Error 425 Falha na execuï¿½ï¿½o da inclusï¿½o do cliente: '

// 				Else
// 					oJson["_success"]   := .T.
// 					oJson["_message"]   := ProcOk				//"Processo concluido com sucesso"
// 					oJson['a1_cod']     := SA1->A1_COD
// 					oJson['a1_nome']    := SA1->A1_NOME
// 					oJson['a1_nreduz']  := SA1->A1_NREDUZ
// 				EndIf

// 			End Transaction	
// 		Endif
// 	Endif

// 	oJson['_message'] := cValToCHar(oJson['_message'] )

// Return( oJson )

/*/{Protheus.doc} GravaDados
Autor: Nicolas B Fernandes
Ultima Att: 16/07/2026 - Fernando Pessoa - Tecsistem
Consultoria: Tecsistem
Uso: Cliente
Tipo: api
Rotina: CRM / Faturamento
Funcao: CLBAPI10
Info: Processa JSON e cadastra/altera cliente via MATA030/CRMA980.
Ajustes: SoftObrig (A1_CONDPAG), validacao CC2, IE/ISENTO, mensagens inclusao/alteracao.
/*/
Static Function GravaDados(cJsonIn)
	Local nA, nI, nR
	Local nOpc           := 3 
	Local cCgc           := ""
	Local nPosNome       := 0
	Local nPosReduz      := 0
	Local nPos           := 0
	Local cPaisOriginal  := ""
	Local cCodPaisDestino:= ""
	Local aCopiaEnd      := {}
	Local aOrdem         := {}
	Local aNovoSA1       := {}
	Local nPosInscr      := 0
	//Local nPosContrib    := 0
	Local cPessoa        := ""
	Local aDefaults      := {}
	Local cTabela        := ""
	Local aDadosAI0      := {}
	Local aBkpObrig      := {}

	Private aDadosSA1    := {}
	Private oJsonIn      := JsonObject():New()
	Private oJson

	Private lMsErroAuto  := .F.
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto  := .T.

	If Select("SX2") == 0
		wfprepenv(_cEmp,_cFil)
	EndIf

	ChkFile("SA1")

	oJson := JsonObject():New()
	oJson['_api_name']    := cNomeApi
	oJson['_api_method']  := cMetodo
	oJson['_api_version'] := cVersaoApi
	oJson['_timestamp']   := Eval(bTimeStamp)
	oJson['_success']     := .T.
	oJson['_message']     := ""

	oJsonIn:FromJson(cJsonIn)

	If ValType(oJsonIn) <> "J" .or. Len(oJsonIn:GetNames()) == 0
		oJson["_success"] := .F.
		oJson["_message"] := Erro423
	Else    
		aNames := oJsonIn:GetNames()

		// 1. Montagem Inicial (valores do JSON tem prioridade)
		For nA := 1 to Len(aNames)
			cCampo := Upper(Alltrim(aNames[nA]))

			// aliases comuns
			If cCampo == "A1_NATUREZA"
				cCampo := "A1_NATUREZ"
			EndIf
			// A1_CONDPAG e exclusivo do SIGAEEC - nao mapear A1_COND para ele.
			// Se vier a1_condpag no JSON, segue como A1_CONDPAG (opcional).
			
			If cCampo == "A1_CGC"
				cCgc := oJsonIn[aNames[nA]]
			EndIf

			If Left(cCampo,3) == "A1_" .and. SA1->(FieldPos(cCampo)) > 0
				// evita duplicar se alias ja tiver sido montado
				If AScan(aDadosSA1, {|x| x[1] == cCampo}) > 0
					Loop
				EndIf
				uDado  := oJsonIn[aNames[nA]]
				// campos data enviados como texto (ISO YYYY-MM-DD) precisam ir como tipo Data para o MVC
				If GetSX3Cache(cCampo, "X3_TIPO") == "D" .And. ValType(uDado) == "C"
					uDado := fStrToDate(uDado)
				EndIf
				AAdd(aDadosSA1, {cCampo, uDado, Nil} )
			EndIf
		Next

		// A1_PESSOA - so calcula se nao veio no JSON
		If !Empty(cCgc)
			nPos := AScan(aDadosSA1, {|x| x[1] == "A1_PESSOA"})
			cPessoa := IIf(Len(Alltrim(cCgc)) <= 11, "F", "J")
			If nPos == 0
				AAdd(aDadosSA1, {"A1_PESSOA", cPessoa, Nil})
			ElseIf Empty(aDadosSA1[nPos, 2])
				aDadosSA1[nPos, 2] := cPessoa
			Else
				cPessoa := aDadosSA1[nPos, 2]
			EndIf
		EndIf

		// IE padrao para PJ quando nao informada
		If cPessoa == "J"
			nPosInscr := AScan(aDadosSA1, {|x| x[1] == "A1_INSCR"})
			If nPosInscr == 0
				AAdd(aDadosSA1, {"A1_INSCR", "ISENTO", Nil})
			ElseIf Empty(aDadosSA1[nPosInscr, 2])
				aDadosSA1[nPosInscr, 2] := "ISENTO"
			EndIf
		EndIf

		// Campos que DEVEM vir no JSON - sem default. Se faltar, nao inclui o cliente.
		// Obs.: A1_CONDPAG NAO entra aqui (reservado SIGAEEC; na CRMA980 fica em branco).
		aDefaults := { ;
			"A1_TPFRET", ;
			"A1_CONTA", ;
			"A1_NATUREZ", ;
			"A1_CRVBOL", ;
			"A1_CONTRIB", ;
			"A1_VEND", ;
			"A1_TABELA", ;
			"A1_COND", ;
			"A1_SATIV1", ;
			"A1_XFATPAR", ;
			"A1_XMULTPV", ;
			"A1_XDTFUN" ;
		}
		cTabela := ""  // reutilizado como lista de campos faltantes
		For nI := 1 To Len(aDefaults)
			nPos := AScan(aDadosSA1, {|x| x[1] == aDefaults[nI]})
			If nPos == 0 .Or. Empty(aDadosSA1[nPos, 2])
				If !Empty(cTabela)
					cTabela += ", "
				EndIf
				cTabela += Lower(aDefaults[nI])
			EndIf
		Next nI

		If !Empty(cTabela)
			oJson["_success"] := .F.
			oJson["_message"] := "Error 431 - Campos obrigatorios nao informados no JSON: " + cTabela
		EndIf

		// Fernando Pessoa - Tecsistem - 16/07/2026
		// Se contribuinte = 2 (Nao), garante IE = ISENTO ANTES da validacao de UF (A1_EST),
		// evitando erro "IE invalida para esta unidade federativa".
		If oJson["_success"]
			nPosContrib := AScan(aDadosSA1, {|x| x[1] == "A1_CONTRIB"})
			If nPosContrib > 0 .And. Alltrim(cValToChar(aDadosSA1[nPosContrib, 2])) == "2"
				nPosInscr := AScan(aDadosSA1, {|x| x[1] == "A1_INSCR"})
				If nPosInscr == 0
					AAdd(aDadosSA1, {"A1_INSCR", "ISENTO", Nil})
				Else
					aDadosSA1[nPosInscr, 2] := "ISENTO"
				EndIf
			EndIf
		EndIf

		If oJson["_success"]

		// Regra de Pais Original e Destino
		nPosPais := AScan(aDadosSA1, {|x| x[1] == "A1_PAIS"})
		If nPosPais == 0 .Or. Empty(aDadosSA1[nPosPais, 2])
			cPaisOriginal := "BRASIL"
			AAdd(aDadosSA1, {"A1_PAIS", "", Nil}) 
			nPosPais := Len(aDadosSA1)
		Else
			cPaisOriginal := aDadosSA1[nPosPais, 2]
		EndIf

		nPosCodPais := AScan(aDadosSA1, {|x| x[1] == "A1_CODPAIS"})
		If nPosCodPais == 0 .Or. Empty(aDadosSA1[nPosCodPais, 2])
			If Upper(Alltrim(cPaisOriginal)) == "BRASIL"
				cCodPaisDestino := "01058"
			Else
				ChkFile("CCH")
				cCodPaisDestino := Posicione("CCH", 2, xFilial("CCH") + PadR(cPaisOriginal, TamSX3("CCH_PAIS")[1]), "CCH_CODIGO")
			EndIf

			cCodPaisDestino := PadR(cCodPaisDestino, TamSX3("A1_CODPAIS")[1])
			
			If nPosCodPais == 0
				AAdd(aDadosSA1, {"A1_CODPAIS", cCodPaisDestino, Nil}) 
			Else
				aDadosSA1[nPosCodPais, 2] := cCodPaisDestino
			EndIf
		EndIf
		aDadosSA1[nPosPais, 2] := xPais(cPaisOriginal)

		// Fernando Pessoa - Tecsistem - 16/07/2026
		// Valida A1_COD_MUN x A1_EST na CC2 e preenche A1_MUN (mesmo gatilho da CRMA980).
		// Evita inconsistencia tipo COD_MUN de SP com EST=RS (quebra validacao de IE).
		nPos := AScan(aDadosSA1, {|x| x[1] == "A1_COD_MUN"})
		If nPos > 0 .And. !Empty(aDadosSA1[nPos, 2])
			ChkFile("CC2")
			cTabela := PadR(Alltrim(cValToChar(aDadosSA1[nPos, 2])), TamSX3("A1_COD_MUN")[1])
			nPosPais := AScan(aDadosSA1, {|x| x[1] == "A1_EST"}) // reutiliza var local
			cPaisOriginal := IIf(nPosPais > 0, Alltrim(cValToChar(aDadosSA1[nPosPais, 2])), "")

			If !Empty(cPaisOriginal)
				CC2->(DbSetOrder(1)) // FILIAL+EST+CODMUN
				If CC2->(DbSeek(xFilial("CC2") + PadR(cPaisOriginal, TamSX3("A1_EST")[1]) + cTabela))
					nPosCodPais := AScan(aDadosSA1, {|x| x[1] == "A1_MUN"})
					If nPosCodPais == 0
						AAdd(aDadosSA1, {"A1_MUN", CC2->CC2_MUN, Nil})
					Else
						aDadosSA1[nPosCodPais, 2] := CC2->CC2_MUN
					EndIf
				Else
					oJson["_success"] := .F.
					oJson["_message"] := "Error 431 - a1_cod_mun [" + Alltrim(cTabela) + "] incompativel com a1_est [" + cPaisOriginal + "] (CC2)."
				EndIf
			EndIf
		EndIf

		// Endereco de cobranca: usa o JSON se veio; senao espelha o endereco principal
		If oJson["_success"]
			aCopiaEnd := { ;
				{"A1_BAIRRO", "A1_BAIRROC"}, ;
				{"A1_END",    "A1_ENDCOB"}, ;
				{"A1_MUN",    "A1_MUNC"}, ;
				{"A1_EST",    "A1_ESTC"}, ;
				{"A1_CEP",    "A1_CEPC"} ;
				}
			For nI := 1 To Len(aCopiaEnd)
				nPosOrig := AScan(aDadosSA1, {|x| x[1] == aCopiaEnd[nI][1]})
				nPosDest := AScan(aDadosSA1, {|x| x[1] == aCopiaEnd[nI][2]})
				// nao sobrescreve valor que veio no JSON
				If nPosDest > 0 .And. !Empty(aDadosSA1[nPosDest, 2])
					Loop
				EndIf
				If nPosOrig > 0 .And. !Empty(aDadosSA1[nPosOrig, 2])
					If nPosDest == 0
						AAdd(aDadosSA1, {aCopiaEnd[nI][2], aDadosSA1[nPosOrig, 2] , Nil})
					Else
						aDadosSA1[nPosDest, 2] := aDadosSA1[nPosOrig, 2]
					EndIf
				EndIf
			Next nI
		EndIf // fim validacao CC2 ok - espelhamento endereco

		// A1_NREDUZ - so preenche se nao veio no JSON
		nPosNome  := AScan(aDadosSA1, {|x| x[1] == "A1_NOME"})
		nPosReduz := AScan(aDadosSA1, {|x| x[1] == "A1_NREDUZ"})
		If nPosNome > 0 .And. (nPosReduz == 0 .Or. Empty(aDadosSA1[nPosReduz, 2]))
			If nPosReduz == 0
				AAdd(aDadosSA1, {"A1_NREDUZ", Left(aDadosSA1[nPosNome, 2], Len(SA1->A1_NREDUZ)), Nil})
			Else
				aDadosSA1[nPosReduz, 2] := Left(aDadosSA1[nPosNome, 2], Len(SA1->A1_NREDUZ))
			EndIf
		EndIf

		// A1_XDTFUN - obrigatorio no JSON (validado acima).
		// Converte string ISO/etc para tipo Data quando necessario.
		nPos := AScan(aDadosSA1, {|x| x[1] == "A1_XDTFUN"})
		If nPos > 0
			If ValType(aDadosSA1[nPos, 2]) == "C"
				aDadosSA1[nPos, 2] := fStrToDate(aDadosSA1[nPos, 2])
			EndIf
		EndIf

		// --- PIPELINE DE ORDENACAO BASICA ---
		// INSCR/CONTRIB antes de EST para a validacao de IE x UF nao falhar
		aOrdem := {"A1_CGC", "A1_PESSOA", "A1_TIPO", "A1_CONTRIB", "A1_INSCR", "A1_PAIS", "A1_CODPAIS", "A1_EST", "A1_COD_MUN", "A1_MUN", "A1_CEP"}
		For nI := 1 To Len(aOrdem)
			nPos := AScan(aDadosSA1, {|x| x[1] == aOrdem[nI]})
			If nPos > 0
				AAdd(aNovoSA1, aDadosSA1[nPos])
			EndIf
		Next nI
		For nI := 1 To Len(aDadosSA1)
			If AScan(aOrdem, aDadosSA1[nI][1]) == 0
				AAdd(aNovoSA1, aDadosSA1[nI])
			EndIf
		Next nI
		aDadosSA1 := aNovoSA1 

		// Upsert
		If !Empty(cCgc)
			SA1->(DbSetOrder(3)) 
			If SA1->(DbSeek(xFilial("SA1") + cCgc))
				nOpc := 4 
			EndIf
		EndIf

		If oJson["_success"]

			// Remove A1_CONDPAG do vetor se veio vazio (nao forcar no ExecAuto)
			nPos := AScan(aDadosSA1, {|x| x[1] == "A1_CONDPAG"})
			If nPos > 0 .And. Empty(aDadosSA1[nPos, 2])
				aDel(aDadosSA1, nPos)
				aSize(aDadosSA1, Len(aDadosSA1)-1)
			EndIf

			// trunca textos maiores que o tamanho do campo e elimina os acentos
			For nR := 1 to Len(aDadosSA1)
				cCampo := aDadosSA1[nR,1]
				if "A1_" $ cCampo .and. GetSX3Cache(cCampo, "X3_TIPO") == "C" .and. Valtype(aDadosSA1[nR,2]) == "C"
					aDadosSA1[nR,2] := TruncaTexto(aDadosSA1[nR,2],cCampo)
				Endif
			Next

			Begin Transaction
				// ---------------------------------------------------------------------
				// Fernando Pessoa - Tecsistem - 16/07/2026
				// SoftObrig: desliga X3_OBRIGAT de campos exclusivos de outros modulos
				// (ex.: A1_CONDPAG / SIGAEEC) somente durante o ExecAuto da API.
				// Na CRMA980 esses campos ficam em branco; no MVC o dicionario ainda exige.
				// ---------------------------------------------------------------------
				aBkpObrig := SoftObrig(.F., {"A1_CONDPAG"})

				lMsErroAuto := .F.
				MSExecAuto({|a,b| MATA030(a,b)}, aDadosSA1, nOpc, aDadosAI0)

				SoftObrig(.T., {"A1_CONDPAG"}, aBkpObrig) // restaura X3_OBRIGAT - Fernando Pessoa - Tecsistem - 16/07/2026

				cCodGrv := Posicione("SA1",3,xFilial("SA1")+cCgc,"A1_COD")

				If lMsErroAuto  
					DISARMTRANSACTION()

					aAutoErro   := GETAUTOGRLOG()
					cErroCon    := XLOG(aAutoErro)

					oJson["_success"]   := .F.
					oJson["_message"]   := Erro425+cErroCon

				Else
					oJson["_success"]   := .T.
					// Fernando Pessoa - Tecsistem - 16/07/2026
					If nOpc == 4
						oJson["_message"] := "Cliente alterado com sucesso, pois ja existia registro cadastrado no Protheus"
					Else
						oJson["_message"] := "Cliente incluido com sucesso no Protheus"
					EndIf
					oJson['a1_cod']     := SA1->A1_COD
					oJson['a1_nome']    := SA1->A1_NOME
					oJson['a1_nreduz']  := SA1->A1_NREDUZ
				EndIf

			End Transaction	
		Endif

		EndIf // fim: validacao campos obrigatorios do JSON
	EndIf

	oJson['_message'] := cValToCHar(oJson['_message'] )

Return( oJson )
/*/{Protheus.doc} ValidaDados
Valida os campos obrigatorios antes de execuar o execauto
@type user function
@author Aldo Barbosa dos Santos
@since 19/04/2026
@see (links_or_references)
/*/
Static Function ValidaDados(aDadosSA1)
	Local aObrSA1 := {}
	Local cMsg   := ""
	Local nA

	// carrega vetor dos campos obrigatorios da SA1
	SX3->( DbsetOrder(1))
	SX3->( Dbseek("SA1"))
	Do While SX3->( ! Eof()) .and. SX3->X3_ARQUIVO == 'SA1'
		if CpoObrigat(SX3->X3_CAMPO) .and. SA1->( FieldPos(SX3->X3_CAMPO)) > 0
			Aadd(aObrSA1, Upper(Alltrim(SX3->X3_CAMPO)))
		Endif
		SX3->( Dbskip())	
	Enddo

	// analisa se todos os campos obrigatï¿½rios da SA1 estï¿½o presentes 
	For nA := 1 to Len(aObrSA1)
		if Ascan(aDadosSA1, {|e| Alltrim(Upper(e[1])) == aObrSA1[nA] }) == 0
			cMsg += Erro431+": ["+aObrSA1[nA]+"] / "	//"Error 431 - Campo obrigatï¿½rio nï¿½o informado"
		Endif
	Next

	if ! Empty(cMsg)
		oJson["_success"]      := .F.
		oJson["_message"]     := cMsg		//'Error 423 - Falha na estrutura do Json: '+cJsonIn
	Endif

Return


/*/{Protheus.doc} DadosDefault
Atualiza os dados default para os campos conforme planilha enviada
@type user function
@author Aldo Barbosa dos Santos
@since 19/04/2026
@see (links_or_references)
/*/
Static Function DadosDefault(cCampo)
	Local aDefault := {}
	Local nA

	// analisa a necessidade de incluir os campos abaixo no vetor
	Aadd(aDefault, "A1_CODPAIS")	//	C, 5	Pais Bacen.	Sim	dado concatenado: '0' + A1_CODPAIS
	Aadd(aDefault, "A1_CONTA")		//	C, 20	C. Contabil	Sim	dado fixo '11201001'
	Aadd(aDefault, "A1_TPFRET")		//	C, 1	Tipo Frete	Sim	dado fixo 'F'
	Aadd(aDefault, "A1_NATUREZ")	//	C, 10	Natureza	Sim	dado fixo '1.1.1.01'
	Aadd(aDefault, "A1_COND")		//	C, 3	Cond. Pagto	Sim	dado fixo '000'
	Aadd(aDefault, "A1_VEND")		//	C, 6	Vend Interno	Sim	dado fixo '000000'
	Aadd(aDefault, "A1_TABELA")		//	C, 3	Tabela Preco	Sim	se A1_TIPO = R, dado serï¿½ 'V08', senï¿½o dado serï¿½ 'V07'
	Aadd(aDefault, "A1_TRANSP")		//	C, 6	Transp.	Sim	dado fixo '000000'
	Aadd(aDefault, "A1_DTCAD")		//	D	Dt Cadastro	Sim	preenchido pelo Protheus, na inclusï¿½o
	Aadd(aDefault, "A1_HRCAD")		//	C, 5	Hr Cadastro 	Sim	preenchido pelo Protheus, na inclusï¿½o
	For nA := 1 to Len(aDefault)
		posSA1 := Ascan(aDadosSA1,{|e| Upper(e[1]) == Upper(aDefault[nA])})
		if posSA1 > 0
			// DESABILITADO - Defaults - se o campo foi enviado na API regrava com o default
			//aDadosSA1[posSA1,2]  := CriaDefault(Upper(aDefault[nA]))
		Else
			// se o campo nï¿½o foi enviado na API cria com o default
			AAdd(aDadosSA1, {Upper(aDefault[nA]), CriaDefault(Upper(aDefault[nA])), Nil} )				
		Endif
	Next

Return


/*/{Protheus.doc} CriaDefault
Cria o dado decault para o campo informado
@type user function
@author Aldo Barbosa dos Santos
@since 19/04/2026
@see (links_or_references)
/*/
Static Function CriaDefault(cCampo)

	Local uRet := ""

	if cCampo == "A1_CODPAIS"
		//	C, 5	Pais Bacen.	Sim	dado concatenado: '0' + A1_CODPAIS
 		nPos := Ascan( aDadosSA1, {|e| Upper(e[1]) == "A1_PAIS" } )
		if nPos > 0
			uRet := "01058"
		Endif
	Elseif cCampo == "A1_CONTA"
		//	C, 20	C. Contabil	Sim	dado fixo '11201001'
		uRet := '11201001'
	Elseif cCampo == "A1_TPFRET"
		//	C, 1	Tipo Frete	Sim	dado fixo 'F'
		uRet := 'F'
	Elseif cCampo == "A1_NATUREZ"
		//	C, 10	Natureza	Sim	dado fixo '1.1.1.01'
		uRet := '1.1.1.01'
	Elseif cCampo == "A1_COND"
		//	C, 3	Cond. Pagto	Sim	dado fixo '000'
		uRet := '000'
	Elseif cCampo == "A1_VEND"
		//	C, 6	Vend Interno	Sim	dado fixo '000000'
		uRet := '000000'
	Elseif cCampo == "A1_TABELA"
		//	C, 3	Tabela Preco	Sim	se A1_TIPO = R, dado serï¿½ 'V08', senï¿½o dado serï¿½ 'V07'
 		nPos := Ascan( aDadosSA1, {|e| Upper(e[1]) == "A1_TIPO" } )
		if nPos > 0
			if aDadosSA1[nPos,2] == "R"
				uRet := "V08"
			Else	
				uRet := "V07"
			Endif	
		Endif

	Elseif cCampo == "A1_TRANSP"
		//	C, 6	Transp.	Sim	dado fixo '000000'
		uRet := '000000'
	
	Elseif cCampo == "A1_DTCAD"
		//	D	Dt Cadastro	Sim	preenchido pelo Protheus, na inclusï¿½o
		uRet := Date()
	
	Elseif cCampo == "A1_HRCAD"
		//	C, 5	Hr Cadastro 	Sim	preenchido pelo Protheus, na inclusï¿½o
		uRet := Left(Time(),Len(SA1->A1_HRCAD))

	Endif

Return( uRet )


/*/{Protheus.doc} Conout2
Funcao que inclui os dados da API e executa um Conout padronizado
@type user function
@author Aldo Barbosa dos Santos
@since 12/04/2026
@see (links_or_references)
/*/
Static Function Conout2(cTexto)

	cTexto := "### " +cNomeApi+" - "+Dtoc(Date())+" "+Time()+" - "+cTexto

	Conout(cTexto)

Return


/*/{Protheus.doc} ChkErro
	Controle de Erros
	@type  Static Function
	@author Aldo Barbosa dos Santos
	@since 30/01/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkErro(e, lResult)
	Local nErro := 420
	Local cErro := Erro420		// "Error 420 - Falha de erro generico nao documentado."
	Local cMsg1 := e:ErrorStack
	Local cMsg2 := e:Description

	Conout2(cMsg1)
	Conout2(cMsg2)

	SetRestFault(nErro, cErro+" / "+cMsg1+" / "+cMsg2)

	if Type("oJson") <> "U"
		oJson['_message'] := cMsg1
		oJson['_success']  := .F.
	Endif

	lResult := .F.

	Break

Return


/*/{Protheus.doc} XLOG
Retorna o erro de exceauto em formado texto amigï¿½vel
@type user function
@author Aldo Barbosa dos Santos
@since 12/04/2026
@see (links_or_references)
/*/
/*/{Protheus.doc} SoftObrig
Desliga/restaura X3_OBRIGAT temporariamente para campos exclusivos de outros
modulos (ex.: A1_CONDPAG do SIGAEEC), evitando falso obrigatorio no ExecAuto
da CRMA980/MATA030 via API.
@author Fernando Pessoa - Tecsistem
@since 16/07/2026
@type Static Function
@param lRestaura, L, .T.=restaura backup / .F.=desliga obrigatoriedade
@param aCampos, A, lista de campos
@param aBkp, A, backup [{campo,x3_obrigat}] usado na restauracao
@return A, backup gerado quando lRestaura=.F.
/*/
Static Function SoftObrig(lRestaura, aCampos, aBkp)
	Local aArea  := SX3->(GetArea())
	Local aRet   := {}
	Local nI
	Local cCampo

	Default lRestaura := .F.
	Default aCampos   := {}
	Default aBkp      := {}

	SX3->(DbSetOrder(2)) // X3_CAMPO

	If !lRestaura
		For nI := 1 To Len(aCampos)
			cCampo := PadR(Upper(Alltrim(aCampos[nI])), Len(SX3->X3_CAMPO))
			If SX3->(DbSeek(cCampo))
				AAdd(aRet, {Alltrim(SX3->X3_CAMPO), SX3->X3_OBRIGAT})
				RecLock("SX3", .F.)
				SX3->X3_OBRIGAT := " "
				MsUnlock()
			EndIf
		Next nI
	Else
		For nI := 1 To Len(aBkp)
			cCampo := PadR(Upper(Alltrim(aBkp[nI,1])), Len(SX3->X3_CAMPO))
			If SX3->(DbSeek(cCampo))
				RecLock("SX3", .F.)
				SX3->X3_OBRIGAT := aBkp[nI,2]
				MsUnlock()
			EndIf
		Next nI
		aRet := aBkp
	EndIf

	RestArea(aArea)

	If FindFunction("FwCleanSX3Cache")
		FwCleanSX3Cache()
	EndIf

Return aRet


/*/{Protheus.doc} fStrToDate
Converte uma data enviada como texto no JSON para o tipo Data do ADVPL.
Aceita os formatos ISO "YYYY-MM-DD", "YYYYMMDD" e "DD/MM/YYYY".
@type Static Function
@author Nicolas B Fernandes
@since 15/07/2026
/*/
Static Function fStrToDate(cData)
	Local dRet := CToD("")
	Local cAux := Alltrim(cValToChar(cData))

	If Empty(cAux)
		Return dRet
	EndIf

	If "-" $ cAux .And. Len(cAux) >= 10
		// ISO: YYYY-MM-DD
		dRet := SToD(SubStr(cAux,1,4) + SubStr(cAux,6,2) + SubStr(cAux,9,2))
	ElseIf "/" $ cAux
		// DD/MM/YYYY (formato do SET DATE)
		dRet := CToD(cAux)
	ElseIf Len(cAux) == 8 .And. IsDigit(SubStr(cAux,1,1))
		// YYYYMMDD
		dRet := SToD(cAux)
	Else
		dRet := CToD(cAux)
	EndIf

Return dRet


Static Function XLOG(aAutoErro)  
	LOCAL cRet  := ""
	LOCAL cLinha := ""
	LOCAL nX

	// Retorna todas as linhas relevantes do log de erro do ExecAuto/MVC,
	// incluindo "Mensagem do erro" e "Mensagem da solucao", que sao essenciais
	// para diagnosticar a real causa da falha na inclusao.
 	FOR nX := 1 to Len(aAutoErro)
		cLinha := StrTran(StrTran(aAutoErro[nX], CHR(13), " "), CHR(10), " ")
		cLinha := Alltrim(cLinha)
		If !Empty(cLinha)
			cRet += cLinha + "; "
		EndIf
	NEXT nX

RETURN cRet


Static Function xPais(cPais)

	Local aArea    := GetArea()
	Default cCodPais := "105"

	If AllTrim(cPais) == 'AFEGANISTAO'
		cCodPais := '013'
	Elseif AllTrim(cPais) == 'AFRICA DO SUL'
		cCodPais := '756'
	Elseif AllTrim(cPais) == 'ALBANIA'
		cCodPais := '017'
	Elseif AllTrim(cPais) == 'ALEMANHA'
		cCodPais := '023'
	Elseif AllTrim(cPais) == 'ANDORRA'
		cCodPais := '037'
	Elseif AllTrim(cPais) == 'ANGOLA'
		cCodPais := '040'
	Elseif AllTrim(cPais) == 'ANTIGA E BARBUDA'
		cCodPais := '043'
	Elseif AllTrim(cPais) == 'ARABIA SAUDITA'
		cCodPais := '053'
	Elseif AllTrim(cPais) == 'ARGELIA'
		cCodPais := '059'
	Elseif AllTrim(cPais) == 'ARGENTINA'
		cCodPais := '063'
	Elseif AllTrim(cPais) == 'ARMENIA'
		cCodPais := '064'
	Elseif AllTrim(cPais) == 'AUSTRALIA'
		cCodPais := '069'
	Elseif AllTrim(cPais) == 'AUSTRIA'
		cCodPais := '072'
	Elseif AllTrim(cPais) == 'AZERBAIJAO'
		cCodPais := '073'
	Elseif AllTrim(cPais) == 'BAHAMAS'
		cCodPais := '077'
	Elseif AllTrim(cPais) == 'BANGLADEXE'
		cCodPais := '081'
	Elseif AllTrim(cPais) == 'BARBADOS'
		cCodPais := '083'
	Elseif AllTrim(cPais) == 'BAREM'
		cCodPais := '080'
	Elseif AllTrim(cPais) == 'BELGICA'
		cCodPais := '087'
	Elseif AllTrim(cPais) == 'BELIZE'
		cCodPais := '088'
	Elseif AllTrim(cPais) == 'BENIM'
		cCodPais := '229'
	Elseif AllTrim(cPais) == 'BIELORRUSSIA'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'BOLIVIA'
		cCodPais := '097'
	Elseif AllTrim(cPais) == 'BOSNIA E HERZEGOVINA'
		cCodPais :='098'
	Elseif AllTrim(cPais) == 'BOTSUANA'
		cCodPais := '101'
	Elseif AllTrim(cPais) == 'BRASIL'
		cCodPais := '105'
	Elseif AllTrim(cPais) == 'BRUNEI'
		cCodPais := '108'
	Elseif AllTrim(cPais) == 'BULGARIA'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'BURQUINA FASO'
		cCodPais := '310'
	Elseif AllTrim(cPais) == 'BURUNDI'
		cCodPais := '115'
	Elseif AllTrim(cPais) == 'BUTAO'
		cCodPais := '119'
	Elseif AllTrim(cPais) == 'CABO VERDE'
		cCodPais := '127'
	Elseif AllTrim(cPais) == 'CAMAROES'
		cCodPais := '145'
	Elseif AllTrim(cPais) == 'CAMBOJA'
		cCodPais := '141'
	Elseif AllTrim(cPais) == 'CANADA'
		cCodPais := '149'
	Elseif AllTrim(cPais) == 'CATAR'
		cCodPais := '154'
	Elseif AllTrim(cPais) == 'CAZAQUISTAO'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'CHADE'
		cCodPais := '788'
	Elseif AllTrim(cPais) == 'CHILE'
		cCodPais := '158'
	Elseif AllTrim(cPais) == 'CHINA'
		cCodPais := '160'
	Elseif AllTrim(cPais) == 'CHIPRE'
		cCodPais := '163'
	Elseif AllTrim(cPais) == 'COLOMBIA'
		cCodPais := '169'
	Elseif AllTrim(cPais) == 'COMORES'
		cCodPais := '173'
	Elseif AllTrim(cPais) == 'CONGO-BRAZZAVILLE'
		cCodPais := '177'
	Elseif AllTrim(cPais) == 'COREIA DO NORTE'
		cCodPais := '190'
	Elseif AllTrim(cPais) == 'COREIA DO SUL'
		cCodPais := '187'
	Elseif AllTrim(cPais) == 'COSOVO'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'COSTA DO MARFIM'
		cCodPais := '193'
	Elseif AllTrim(cPais) == 'COSTA RICA'
		cCodPais := '196'
	Elseif AllTrim(cPais) == 'CROACIA'
		cCodPais := '195'
	Elseif AllTrim(cPais) == 'CUAITE'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'CUBA'
		cCodPais := '199'
	Elseif AllTrim(cPais) == 'DINAMARCA'
		cCodPais := '232'
	Elseif AllTrim(cPais) == 'DOMINICA'
		cCodPais := '235'
	Elseif AllTrim(cPais) == 'EGITO'
		cCodPais := '240'
	Elseif AllTrim(cPais) == 'EMIRADOS ARABES UNIDOS'
		cCodPais := '244'
	Elseif AllTrim(cPais) == 'EQUADOR'
		cCodPais := '239'
	Elseif AllTrim(cPais) == 'ERITREIA'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'ESLOVAQUIA'
		cCodPais := '247'
	Elseif AllTrim(cPais) == 'ESLOVENIA'
		cCodPais := '246'
	Elseif AllTrim(cPais) == 'ESPANHA'
		cCodPais := '245'
	Elseif AllTrim(cPais) == 'ESSUATINI'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'ESTADO DA PALESTINA'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'ESTADOS UNIDOS'
		cCodPais := '249'
	Elseif AllTrim(cPais) == 'ESTONIA'
		cCodPais := '251'
	Elseif AllTrim(cPais) == 'ETIOPIA'
		cCodPais := '253'
	Elseif AllTrim(cPais) == 'FIJI'
		cCodPais := '870'
	Elseif AllTrim(cPais) == 'FILIPINAS'
		cCodPais := '267'
	Elseif AllTrim(cPais) == 'FINLANDIA'
		cCodPais := '271'
	Elseif AllTrim(cPais) == 'FRANï¿½A'
		cCodPais := '275'
	Elseif AllTrim(cPais) == 'GABAO'
		cCodPais := '281'
	Elseif AllTrim(cPais) == 'GAMBIA'
		cCodPais := '285'
	Elseif AllTrim(cPais) == 'GANA'
		cCodPais := '289'
	Elseif AllTrim(cPais) == 'GEORGIA'
		cCodPais := '291'
	Elseif AllTrim(cPais) == 'GRANADA'
		cCodPais := '297'
	Elseif AllTrim(cPais) == 'GRECIA'
		cCodPais := '301'
	Elseif AllTrim(cPais) == 'GUATEMALA'
		cCodPais := '317'
	Elseif AllTrim(cPais) == 'GUIANA'
		cCodPais := '337'
	Elseif AllTrim(cPais) == 'GUINE'
		cCodPais := '329'
	Elseif AllTrim(cPais) == 'GUINE EQUATORIAL'
		cCodPais := '331'
	Elseif AllTrim(cPais) == 'GUINE-BISSAU'
		cCodPais := '334'
	Elseif AllTrim(cPais) == 'HAITI'
		cCodPais := '341'
	Elseif AllTrim(cPais) == 'HONDURAS'
		cCodPais := '345'
	Elseif AllTrim(cPais) == 'HUNGRIA'
		cCodPais := '355'
	Elseif AllTrim(cPais) == 'IEMEN'
		cCodPais := '357'
	Elseif AllTrim(cPais) == 'ILHAS MARECHAL'
		cCodPais := '476'
	Elseif AllTrim(cPais) == 'INDIA'
		cCodPais := '361'
	Elseif AllTrim(cPais) == 'INDONESIA'
		cCodPais := '365'
	Elseif AllTrim(cPais) == 'IRAO'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'IRAQUE'
		cCodPais := '369'
	Elseif AllTrim(cPais) == 'IRLANDA'
		cCodPais := '375'
	Elseif AllTrim(cPais) == 'ISLANDIA'
		cCodPais := '379'
	Elseif AllTrim(cPais) == 'ISRAEL'
		cCodPais := '383'
	Elseif AllTrim(cPais) == 'ITALIA'
		cCodPais := '386'
	Elseif AllTrim(cPais) == 'JAMAICA'
		cCodPais := '391'
	Elseif AllTrim(cPais) == 'JAPAO'
		cCodPais := '399'
	Elseif AllTrim(cPais) == 'JIBUTI'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'JORDANIA'
		cCodPais := '403'
	Elseif AllTrim(cPais) == 'LAUS'
		cCodPais := '420'
	Elseif AllTrim(cPais) == 'LESOTO'
		cCodPais := '426'
	Elseif AllTrim(cPais) == 'LETONIA'
		cCodPais := '427'
	Elseif AllTrim(cPais) == 'LIBANO'
		cCodPais := '431'
	Elseif AllTrim(cPais) == 'LIBERIA'
		cCodPais := '434'
	Elseif AllTrim(cPais) == 'LIBIA'
		cCodPais := '438'
	Elseif AllTrim(cPais) == 'LISTENSTAINE'
		cCodPais := '440'
	Elseif AllTrim(cPais) == 'LITUANIA'
		cCodPais := '442'
	Elseif AllTrim(cPais) == 'LUXEMBURGO'
		cCodPais := '445'
	Elseif AllTrim(cPais) == 'MACEDONIA DO NORTE'
		cCodPais := '449'
	Elseif AllTrim(cPais) == 'MADAGASCAR'
		cCodPais := '450'
	Elseif AllTrim(cPais) == 'MALASIA'
		cCodPais := '455'
	Elseif AllTrim(cPais) == 'MALAUI'
		cCodPais := '458'
	Elseif AllTrim(cPais) == 'MALDIVAS'
		cCodPais := '461'
	Elseif AllTrim(cPais) == 'MALI'
		cCodPais := '464'
	Elseif AllTrim(cPais) == 'MALTA'
		cCodPais := '467'
	Elseif AllTrim(cPais) == 'MARROCOS'	
		cCodPais := '474'
	Elseif AllTrim(cPais) == 'MAURICIA'
		cCodPais := '485'
	Elseif AllTrim(cPais) == 'MAURITANIA'
		cCodPais := '488'
	Elseif AllTrim(cPais) == 'MEXICO'
		cCodPais := '493'
	Elseif AllTrim(cPais) == 'MIANMAR'
		cCodPais := '093'
	Elseif AllTrim(cPais) == 'MICRONESIA'
		cCodPais := '499'
	Elseif AllTrim(cPais) == 'MOCAMBIQUE'
		cCodPais := '505'
	Elseif AllTrim(cPais) == 'MOLDAVIA'
		cCodPais := '494'
	Elseif AllTrim(cPais) == 'MONACO'
		cCodPais := '495'
	Elseif AllTrim(cPais) == 'MONGOLIA'
		cCodPais := '497'
	Elseif AllTrim(cPais) == 'MONTENEGRO'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'NAMIBIA'
		cCodPais := '507'
	Elseif AllTrim(cPais) == 'NAURU'
		cCodPais := '508'
	Elseif AllTrim(cPais) == 'NEPAL'
		cCodPais := '517'
	Elseif AllTrim(cPais) == 'NICARAGUA'
		cCodPais := '521'
	Elseif AllTrim(cPais) == 'NIGER'
		cCodPais := '525'
	Elseif AllTrim(cPais) == 'NIGERIA'
		cCodPais := '528'
	Elseif AllTrim(cPais) == 'NORUEGA'
		cCodPais := '538'
	Elseif AllTrim(cPais) == 'NOVA ZELANDIA'
		cCodPais := '548'
	Elseif AllTrim(cPais) == 'OMA'
		cCodPais := '556'
	Elseif AllTrim(cPais) == 'PAISES BAIXOS'
		cCodPais := '573'
	Elseif AllTrim(cPais) == 'PALAU'
		cCodPais := '575'
	Elseif AllTrim(cPais) == 'PANAMA'
		cCodPais := '580'
	Elseif AllTrim(cPais) == 'PAPUA NOVA GUINE'
		cCodPais := '583'
	Elseif AllTrim(cPais) == 'PAQUISTAO'
		cCodPais := '576'
	Elseif AllTrim(cPais) == 'PARAGUAI'
		cCodPais := '586'
	Elseif AllTrim(cPais) == 'PERU'
		cCodPais := '589'
	Elseif AllTrim(cPais) == 'POLONIA'
		cCodPais := '603'
	Elseif AllTrim(cPais) == 'PORTUGAL'
		cCodPais := '607'
	Elseif AllTrim(cPais) == 'QUENIA'
		cCodPais := '623'
	Elseif AllTrim(cPais) == 'QUIRGUISTAO'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'QUIRIBATI'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'REINO UNIDO'
		cCodPais := '628'
	Elseif AllTrim(cPais) == 'REPUBLICA CENTRO-AFRICANA'
		cCodPais := '640'
	Elseif AllTrim(cPais) == 'REPUBLICA CHECA'
		cCodPais := '791'
	Elseif AllTrim(cPais) == 'REPUBLICA DEMOCRATICA DO CONGO'
		cCodPais := '888'
	Elseif AllTrim(cPais) == 'REPUBLICA DOMINICANA'
		cCodPais := '647'
	Elseif AllTrim(cPais) == 'ROMENIA'
		cCodPais := '670'
	Elseif AllTrim(cPais) == 'RUANDA'
		cCodPais := '675'
	Elseif AllTrim(cPais) == 'RUSSIA'
		cCodPais := '676'
	Elseif AllTrim(cPais) == 'SALOMAO'
		cCodPais := '677'
	Elseif AllTrim(cPais) == 'SALVADOR'
		cCodPais := '687'
	Elseif AllTrim(cPais) == 'SAMOA'
		cCodPais := '690'
	Elseif AllTrim(cPais) == 'SANTA LUCIA'
		cCodPais := '715'
	Elseif AllTrim(cPais) == 'SAO CRISTOVAO E NEVES'
		cCodPais := '695'
	Elseif AllTrim(cPais) == 'SAO MARINHO'
		cCodPais := '697'
	Elseif AllTrim(cPais) == 'SAO TOME E PRINCIPE'
		cCodPais := '720'
	Elseif AllTrim(cPais) == 'SAO VICENTE E GRANADINAS'
		cCodPais := '705'
	Elseif AllTrim(cPais) == 'SEICHELES'
		cCodPais := '731'
	Elseif AllTrim(cPais) == 'SENEGAL'
		cCodPais := '728'
	Elseif AllTrim(cPais) == 'SERRA LEOA'
		cCodPais := '735'
	Elseif AllTrim(cPais) == 'SERVIA'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'SINGAPURA'
		cCodPais := '741'
	Elseif AllTrim(cPais) == 'SIRIA'
		cCodPais := '744'
	Elseif AllTrim(cPais) == 'SOMALIA'
		cCodPais := '748'
	Elseif AllTrim(cPais) == 'SRI LANCA'
		cCodPais := '750'
	Elseif AllTrim(cPais) == 'SUDAO'
		cCodPais := '759'
	Elseif AllTrim(cPais) == 'SUDAO DO SUL'
		cCodPais := '759'
	Elseif AllTrim(cPais) == 'SUECIA'
		cCodPais := '764'
	Elseif AllTrim(cPais) == 'SUICA'
		cCodPais := '767'
	Elseif AllTrim(cPais) == 'SURINAME'
		cCodPais := '770'
	Elseif AllTrim(cPais) == 'TAILANDIA'
		cCodPais := '776'
	Elseif AllTrim(cPais) == 'TAIUA'
		cCodPais := '#N/D'
	Elseif AllTrim(cPais) == 'TAJIQUISTAO'
		cCodPais := '772'
	Elseif AllTrim(cPais) == 'TANZANIA'
		cCodPais := '780'
	Elseif AllTrim(cPais) == 'TIMOR-LESTE'
		cCodPais := '795'
	Elseif AllTrim(cPais) == 'TOGO'
		cCodPais := '800'
	Elseif AllTrim(cPais) == 'TONGA'
		cCodPais := '810'
	Elseif AllTrim(cPais) == 'TRINDADE E TOBAGO'
		cCodPais := '815'
	Elseif AllTrim(cPais) == 'TUNISIA'
		cCodPais := '820'
	Elseif AllTrim(cPais) == 'TURCOMENISTAO'
		cCodPais := '824'
	Elseif AllTrim(cPais) == 'TURQUIA'
		cCodPais := '827'
	Elseif AllTrim(cPais) == 'TUVALU'
		cCodPais := '828'
	Elseif AllTrim(cPais) == 'UCRANIA'
		cCodPais := '831'
	Elseif AllTrim(cPais) == 'UGANDA'
		cCodPais := '833'
	Elseif AllTrim(cPais) == 'URUGUAI'
		cCodPais := '845'
	Elseif AllTrim(cPais) == 'USBEQUISTAO'
		cCodPais := '847'
	Elseif AllTrim(cPais) == 'VANUATU'
		cCodPais := '551'
	Elseif AllTrim(cPais) == 'VATICANO'
		cCodPais := '848'
	Elseif AllTrim(cPais) == 'VENEZUELA'
		cCodPais := '850'
	Elseif AllTrim(cPais) == 'VIETNAME'
		cCodPais := '858'
	Elseif AllTrim(cPais) == 'ZAMBIA'
		cCodPais := '890'
	Elseif AllTrim(cPais) == 'ZIMBABUE'
		cCodPais := '665'
	Endif 

	RestArea(aArea)

Return(cCodPais)


/*/{Protheus.doc} RemoveAcento
	Remove os acentos dos textos
	@type  Static Function
	@author Aldo Barbosa dos Santos
	@since 04/10/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RemoveAcento(cTexto)

    Local aComAen  As Array
    Local aSemAen  As Array
    Local nI       As Numeric
    Local cRet     := ""

    // Validação defensiva do parâmetro recebido
    Default cTexto := ""

    If ! Empty(cTexto)
        // 2. Mapeamento de caracteres acentuados (Maiúsculos e Minúsculos)
        aComAen := { "Á", "À", "Ã", "Â", "Ä", "á", "à", "ã", "â", "ä", ;
            		"É", "È", "Ê", "Ë", "é", "è", "ê", "ë", ;
            		"Í", "Ì", "Î", "Ï", "í", "ì", "î", "ï", ;
            		"Ó", "Ò", "Õ", "Ô", "Ö", "ó", "ò", "õ", "ô", "ö", ;
            		"Ú", "Ù", "Û", "Ü", "ú", "ù", "û", "ü", ;
            		"Ç", "ç", "Ñ", "ñ"  }

        aSemAen := { "A", "A", "A", "A", "A", "a", "a", "a", "a", "a", ;
            		"E", "E", "E", "E", "e", "e", "e", "e", ;
            		"I", "I", "I", "I", "i", "i", "i", "i", ;
            		"O", "O", "O", "O", "O", "o", "o", "o", "o", "o", ;
            		"U", "U", "U", "U", "u", "u", "u", "u", ;
            		"C", "c", "N", "n" }

        cRet := cTexto

        // Substituição direta de cada caractere
        For nI := 1 To Len(aComAen)
            If aComAen[nI] $ cRet
                cRet := StrTran(cRet, aComAen[nI], aSemAen[nI])
            EndIf
        Next nI
    EndIf

Return cRet


/*/{Protheus.doc} TruncaTexto
	Truca o texto até o tamanho máximo do campo do Protheus
	@type  Static Function
	@author Aldo Barbosa dos Santos
	@since 04/10/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function TruncaTexto(uDado, cCampo)
	Local cRet := ""
	Local nTam := 0

	Default uDado := ""
	Default cCampo := ""

	cRet := uDado

	if "A1_MUN" $ cCampo
		lteste := .T.
	Endif

	if ValType("uDado") == "C" .and. "A1_" $ cCampo
		cRet := RemoveAcento(uDado)
		nTam := GetSX3Cache(cCampo, "X3_TAMANHO")
		//if Len(Alltrim(uDado)) > nTam
			cRet := Alltrim(Padr(uDado,nTam))
		//Endif
	Endif

Return( cRet )	




