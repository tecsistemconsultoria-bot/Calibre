
#Include "TOTVS.ch"
#Include "RestFul.CH"

Static cNomeApi := "WkImpDif"
Static lModoTeste := .F.  // .T. somente na rotina de teste manual (sem HTTP)
Static cUltErro   := ""   // ultima falha/erro, mostrada na tela no teste manual


/*/{Protheus.doc} fWKDifImp
Rotina de teste manual (fora do fluxo HTTP), util para debugar a regra de
negocio via SmartClient sem precisar disparar uma requisicao REST real.
@author Nicolas B Fernandes
/*/
User Function fWKDifImp()
	Local cEmp    := "01"
	Local cFil    := "01"
	Local cJsonIn := ""
	Local uRet

	If Select("SX2") == 0
		WfPrepEnv(cEmp, cFil)
	EndIf

	// Json de exemplo, apenas para teste manual
	cJsonIn := '{"Produtos": [{"Sku": "90201","PrecoDe": 40,"PrecoPor": 50,' + ;
		'"ProdutoVarianteId": 293922,"Quantidade": 0,"CentroDistribuicaoId": 0}], ' + ;
		'"Usuario": {"Cnpj": "75095679000149","Cpf": "","Nome": "aaa","Telefone": ""}, ' + ;
		'"EnderecoEntrega": {"Complemento": "","Estado": "PE","Logradouro": "","Id": 0}, ' + ;
		'"checkout": true}'

	lModoTeste := .T.
	cUltErro   := ""

	uRet := ImpostoDif(cJsonIn)

	lModoTeste := .F.

	Conout2("Retorno do teste manual: " + cValToChar(uRet))

	Aviso("Teste manual - " + cNomeApi, ;
		"RETORNO:" + CRLF + cValToChar(uRet) + CRLF + CRLF + ;
		"ULTIMO ERRO/FALHA:" + CRLF + If(Empty(cUltErro), "(nenhum)", cUltErro), ;
		{"Ok"}, 3)

Return( .T. )


WSRESTFUL WkImpDif DESCRIPTION 'Integracao Impostos Plataforma Wake - Valor + Diferencial'
	WSMETHOD POST ImpostoDif;
		DESCRIPTION 'Retorna o preco do produto com impostos e o valor diferencial';
		WSSYNTAX '';
		PRODUCES APPLICATION_JSON

	WSMETHOD GET Ping;
		DESCRIPTION 'Endpoint de diagnostico - nao depende de nada, so confirma que o deploy esta ativo';
		WSSYNTAX '';
		PRODUCES APPLICATION_JSON
END WSRESTFUL


/*/{Protheus.doc} Ping (WSMETHOD)
Endpoint de diagnostico. Nao chama RPCSetEnv, nao acessa banco, nao usa
Private/Local complexo - serve para confirmar se o WSRESTFUL esta sendo
roteado corretamente e se o RPO em uso ja e o compilado mais recente.
Chame via GET, ex: http://servidor:porta/rest/WkImpDif/Ping
Se isso tambem devolver o erro generico 500 do framework, o problema NAO
esta na regra de negocio - e de infraestrutura/deploy/roteamento.
/*/
WSMETHOD GET Ping WSSERVICE WkImpDif
	::SetContentType('application/json')
	::SetStatus(200)
	::SetResponse('{"pong": true, "versao": "' + cValToChar(Date()) + ' ' + Time() + '"}')
Return .T.


/*/{Protheus.doc} ImpostoDif (WSMETHOD)
Endpoint HTTP. Delega toda a regra de negocio para a funcao estatica
ImpostoDif e garante que QUALQUER erro fatal seja capturado.
Padrao adotado: ErrorBlock grava a descricao do erro numa variavel
(cErroFatal), o Begin Sequence/End Sequence apenas interrompe o fluxo
quando o erro estoura, e o resultado e conferido DEPOIS do End Sequence -
sem uso de "Recover Using", que nao e o padrao usado nesta base.

IMPORTANTE: NAO chamamos RPCSetEnv/RPCClearEnv aqui. O job REST do
AppServer ja prepara o ambiente (empresa/filial) antes de rotear para
este WSMETHOD. Chamar RPCSetEnv novamente numa thread que ja esta com
ambiente preparado e um erro classico de Protheus que quebra em nivel de
engine - nao vira uma excecao normal capturavel pelo ErrorBlock, e e
justamente isso que gera o {"code":500,"message":"Internal Server
Error"} generico do framework, sem cair no nosso Json de erro
controlado.
/*/
WSMETHOD POST ImpostoDif WSSERVICE WkImpDif
	Local cJsonIn    := ""
	Local cRet       := ""
	Local cErroJson  := ""
	Local cErroFatal := ""
	Local bErrorAnt  := ErrorBlock({|oError| cErroFatal := oError:Description + " | " + oError:ErrorStack, Break(oError)})

	Conout2("WSMETHOD invocado #####################################")

	Begin Sequence

		cJsonIn := ::GetContent()

		Conout2("Recebendo requisicao #####################################")

		::SetContentType('application/json')

		cRet := ImpostoDif(cJsonIn)

	End Sequence

	// Restaura o bloco de erro original do sistema
	ErrorBlock(bErrorAnt)

	If ! Empty(cErroFatal)
		Conout2("CRASH CAPTURADO: " + cErroFatal)

		cErroJson := '{"code": 500, "message": "' + LimpaMsg(cErroFatal) + '"}'

		::SetStatus(500)
		::SetContentType('application/json')
		::SetResponse(cErroJson)

	ElseIf cRet == "[]"
		// Falha de validacao/negocio: a regra de negocio ja chamou
		// SetRestFault com o codigo e a mensagem corretos. Devolvemos .F.
		// para o framework responder com esse erro, e nao com 200 + "[]".
		Conout2("Requisicao finalizada com falha (SetRestFault ja disparado).")

		Return .F.

	ElseIf Empty(cRet)
		// Defesa extra: nao deveria acontecer (ImpostoDif sempre
		// retorna "[]" ou um Json valido), mas se acontecer, devolvemos
		// um erro controlado ao inves de corpo vazio.
		Conout2("ALERTA: cRet veio vazio sem excecao fatal registrada.")

		::SetStatus(500)
		::SetContentType('application/json')
		::SetResponse('{"erro": true, "status": 500, "mensagem": "Resposta vazia da regra de negocio."}')

	Else
		::SetStatus(200)
		::SetResponse(cRet)
		Conout2("Requisicao finalizada com sucesso #######################")
	EndIf

Return .T.


/*/{Protheus.doc} ImpostoDif (regra de negocio)
Recebe o Json cru, valida, calcula (ou consome cache) e devolve o Json
de resposta ja formatado. Em caso de falha de validacao ou de negocio,
dispara SetRestFault com o codigo/mensagem adequados e devolve "[]" (o
WSMETHOD, ao ver "[]", devolve .F. para o framework responder com o erro).
Nunca devolve resposta parcial: se qualquer produto falhar, a resposta
inteira e descartada.

Gravacao na ZZL:
  ZZL_VALOR  = preco final com imposto
  ZZL_VLRDIF = preco final - PrecoPor (valor da API), para qualquer tipo de cliente
O campo "Valor" do Json de resposta carrega o DIFERENCIAL (ZZL_VLRDIF),
nao o preco final.
/*/
Static Function ImpostoDif(cJsonIn)
	Local nA
	Local cJson       := ""
	Local nCentroPad  := SuperGetMV("ES_WKCD", .F., 25)
	Local nCentro     := nCentroPad
	Local lCheckout   := .T.
	Local cSku, cIdWake, cProduto
	Local nPreco, nPrcFinal, nRevend, nSeg
	Local nValor, nDiferencial
	Local aVetTmp
	Local aRetorno    := {}
	Local bErroAnt

	Private oJsonIn          := JsonObject():New()
	Private oUsuario
	Private oEnderecoEntrega
	Private aProdutos        := {}
	Private cCnpj            := ""
	Private cCpf             := ""
	Private cCliente         := ""
	Private cEstado          := ""
	Private cErro            := ""
	Private cTabela          := ""   // tabela de preco do cliente, resolvida 1x por requisicao

	bErroAnt := ErrorBlock({|e| ChkErro(e)})

	Begin Sequence

		aProdutos := ValidaJson(cJsonIn)

		// Se a validacao falhou, ValidaJson ja disparou o SetRestFault
		// com o codigo/mensagem correto - so encerramos o fluxo aqui.
		If Len(aProdutos) == 0
			Break
		EndIf

		// Verifica se "checkout" e true ou false; se nao vier (ou vier
		// com tipo estranho), assume true
		If oJsonIn:HasProperty("checkout")
			If ValType(oJsonIn["checkout"]) == "L"
				lCheckout := oJsonIn["checkout"]
			ElseIf ValType(oJsonIn["checkout"]) == "C"
				lCheckout := (Lower(Alltrim(oJsonIn["checkout"])) == "true")
			EndIf
		EndIf

		cEstado := oEnderecoEntrega["Estado"]
		cTabela := TabelaPreco()

		For nA := 1 To Len(aProdutos)
			cSku     := cValToChar(aProdutos[nA]["Sku"])
			cIdWake  := cValToChar(aProdutos[nA]["ProdutoVarianteId"])
			cProduto := Padr(cSku, Len(SB1->B1_COD))

			// Zera o centro a cada produto, para nao herdar o do anterior
			nCentro := nCentroPad
			If PegaNum(aProdutos[nA], "CentroDistribuicaoId") <> 0
				nCentro := PegaNum(aProdutos[nA], "CentroDistribuicaoId")
			EndIf

			If lCheckout
				// FLUXO CHECKOUT=TRUE: recalcula, grava cache na ZZL e retorna

				SB1->(DbSetOrder(1))
				If ! SB1->(DbSeek(xFilial("SB1") + cProduto))
					Conout2("Sku nao localizado no fluxo de calculo: [" + cSku + "]")
					FalhaRest(404, "Sku [" + Alltrim(cSku) + "] nao localizado no cadastro de produtos.")
					Break
				EndIf

				nPreco := BuscaPreco(cProduto)
				If nPreco <= 0
					FalhaRest(420, "Preco de venda nao encontrado para o Sku [" + Alltrim(cSku) + "].")
					Break
				EndIf

				// Reaproveita o preco final ja calculado na ZZL (pula o calculo de
				// imposto, que e a parte lenta) se nada que o afeta mudou
				nSeg := Seconds()
				nPrcFinal := PrecoZZL(cSku, cIdWake, nPreco, PegaNum(aProdutos[nA], "PrecoPor"))
				If nPrcFinal <= 0
					nPrcFinal := ProcessaImpostos(cProduto, nPreco)
					If nPrcFinal <= 0
						// ProcessaImpostos ja disparou o SetRestFault
						Break
					EndIf
					Conout2("Tempo calculo de imposto Sku [" + cSku + "]: " + cValToChar(Round(Seconds() - nSeg, 3)) + "s")
				EndIf

				// "Valor" = preco final, com imposto.
				// "Diferencial" = diferenca entre o preco final e o preco base
				// (o imposto isolado).
				nValor       := nPrcFinal

				// A Wake exibe o PrecoPor e, abaixo, "+ impostos" (o Valor que
				// devolvemos). Entao o diferencial e sempre o nosso preco final
				// menos o PrecoPor deles, para qualquer tipo de cliente.
				nDiferencial := nPrcFinal - PegaNum(aProdutos[nA], "PrecoPor")
				nRevend      := If(Alltrim(SA1->A1_TIPO) == "R", nDiferencial, 0)

				// Tratamento tabela customizada ZZL (cache do checkout)
				DbSelectArea("ZZL")
				ZZL->(DbSetOrder(1)) // 1: Filial + SKU + IDWAKE

				If BuscaZZL(cSku, cIdWake)
					RecLock("ZZL", .F.)
				Else
					RecLock("ZZL", .T.)
					ZZL->ZZL_FILIAL := xFilial("ZZL")
					ZZL->ZZL_SKU    := cSku
					ZZL->ZZL_PRODID := cIdWake
				EndIf

				ZZL->ZZL_CENTRO := cValToChar(nCentro)
				ZZL->ZZL_PRECOD := ConvZZL("ZZL_PRECOD", PegaNum(aProdutos[nA], "PrecoDe"))
				ZZL->ZZL_PRECOP := ConvZZL("ZZL_PRECOP", PegaNum(aProdutos[nA], "PrecoPor"))
				ZZL->ZZL_QNTD   := cValToChar(aProdutos[nA]["Quantidade"])
				ZZL->ZZL_VALOR  := Round(nValor, 2)
				ZZL->ZZL_VLRDIF := Round(nDiferencial, 2)
				GravaCampo("ZZL_REVEND", Round(nRevend, 2))
				GravaCampo("ZZL_PRCTAB", cTabela)
				GravaCampo("ZZL_VLRTAB", Round(nPreco, 2))
				GravaCampo("ZZL_TIPOCL", Alltrim(SA1->A1_TIPO))
				GravaCampo("ZZL_CGC", Alltrim(cCliente))
				ZZL->(MsUnlock())
			Else
				// FLUXO CHECKOUT=FALSE: ignora calculo, consome o cache da ZZL

				DbSelectArea("ZZL")
				ZZL->(DbSetOrder(1))

				If BuscaZZL(cSku, cIdWake)
					nValor       := ZZL->ZZL_VALOR
					nDiferencial := ZZL->ZZL_VLRDIF
					nCentro      := Val(ZZL->ZZL_CENTRO)

					RecLock("ZZL", .F.)
					ZZL->(DbDelete())
					ZZL->(MsUnlock())
				Else
					Conout2("Falha Fluxo False: Produto sem cache na ZZL. Sku [" + cSku + "] ID [" + cIdWake + "]")
					FalhaRest(404, "Produto nao encontrado no cache ZZL. Sku: " + cSku)
					Break
				EndIf
			EndIf

			// Gera o item do json de resposta
			aVetTmp := {}
			Aadd(aVetTmp, {"ProdutoVarianteId", cIdWake})
			Aadd(aVetTmp, {"Nome", If(lCheckout, "Calculo de Impostos", "Consulta ZZL - Cache")})
			Aadd(aVetTmp, {"CentroDistribuicaoId", nCentro})
			Aadd(aVetTmp, {"Valor", Round(nDiferencial, 2)})

			Aadd(aRetorno, aVetTmp)
		Next

	End Sequence

	// Restaura o bloco de erro de quem chamou
	ErrorBlock(bErroAnt)

	// Se algum produto falhou, nao devolvemos resposta parcial
	If Len(aRetorno) <> Len(aProdutos)
		aRetorno := {}
	EndIf

	cJson := If(Len(aRetorno) > 0, Formatar(aRetorno), "[]")

Return( cJson )


/*/{Protheus.doc} Formatar
Monta manualmente o array Json de resposta a partir de um vetor de pares
{chave, valor}, escapando strings para evitar Json invalido.
/*/
Static Function Formatar(aVet)
	Local cRet := ""
	Local nA, nB

	If Len(aVet) == 0
		Return "[]"
	EndIf

	For nA := 1 To Len(aVet)
		cRet += "{"
		For nB := 1 To Len(aVet[nA])
			cRet += '"' + aVet[nA, nB, 1] + '":'
			If Valtype(aVet[nA, nB, 2]) == "C"
				cRet += '"' + EscapeJson(aVet[nA, nB, 2]) + '", '
			Else
				cRet += cValToChar(aVet[nA, nB, 2]) + ', '
			EndIf
		Next
		cRet := Left(cRet, Len(cRet) - 2)
		cRet += "}, "
	Next
	cRet := Left(cRet, Len(cRet) - 2)
	cRet := "[" + cRet + "]"

Return( cRet )


/*/{Protheus.doc} SoNumero
Remove qualquer caractere que nao seja digito (ponto, traco, barra, espaco
etc), usado para normalizar CNPJ/CPF recebidos do Json antes de buscar o
cliente na SA1 (campo A1_CGC guarda apenas numeros).
/*/
Static Function SoNumero(cTexto)
	Local cRet := ""
	Local nA

	For nA := 1 To Len(cTexto)
		If SubStr(cTexto, nA, 1) $ "0123456789"
			cRet += SubStr(cTexto, nA, 1)
		EndIf
	Next

Return( cRet )


/*/{Protheus.doc} EscapeJson
Escapa caracteres especiais (barra invertida, aspas, quebras de linha e
tabs) para permitir montagem manual de Json sem gerar payload invalido.
IMPORTANTE: a ordem dos StrTran importa - a barra invertida precisa ser
escapada primeiro, senao os escapes seguintes seriam escapados de novo.
/*/
Static Function EscapeJson(cTexto)
	Local cRet := cValToChar(cTexto)

	cRet := StrTran(cRet, "\", "\\")
	cRet := StrTran(cRet, '"', '\"')
	cRet := StrTran(cRet, CRLF, "\n")
	cRet := StrTran(cRet, Chr(13), "\n")
	cRet := StrTran(cRet, Chr(10), "\n")
	cRet := StrTran(cRet, Chr(9), "\t")

Return( cRet )


/*/{Protheus.doc} ProcessaImpostos
Calcula o preco final com impostos para o produto/cliente/TES informados.
O motor de calculo (U_xCalcPrc x MaFisIni/Add/Ret/End) e configuravel via
parametro ES_WKCALC ao inves de flag fixa no codigo.
/*/
Static Function ProcessaImpostos(cProd, nPreco)
	Local nPrcFinal   := 0
	Local cTesPad     := SuperGetMV("ES_WKTES", .F., "501")
	Local cTes        := ""
	Local lUsaCalcPrc := SuperGetMV("ES_WKCALC", .F., .T.) // .T.=U_xCalcPrc | .F.=MaFisIni/Add/Ret/End

	cTes := U_xMaTesInt(2, "01", SA1->A1_COD, SA1->A1_LOJA, "C", cProd, "", Nil)

	If Empty(cTes)
		cTes := cTesPad
	EndIf

	If lUsaCalcPrc
		nPrcFinal := U_xCalcPrc(nPreco, SA1->A1_COD, SA1->A1_LOJA, cTes, SA1->A1_TIPO, cProd, .T.)
	Else
		MaFisIni(SA1->A1_COD, SA1->A1_LOJA, "C", "N", SA1->A1_TIPO, Nil, Nil, Nil, "SB1", "MATA461")
		MaFisAdd(cProd, cTes, 1, nPreco, 0, 0, 0, 0, 0, 0, 0, 0, nPreco, 0, 0, 0)
		nPrcFinal := MaFisRet(1, "NF_TOTAL")
		MaFisEnd()
	EndIf

	If nPrcFinal <= 0
		Conout2("Nao foi possivel calcular o preco final.")
		FalhaRest(420, "Nao foi possivel calcular o preco final para o Cliente [" + ;
			Alltrim(SA1->A1_COD) + "] Produto [" + Alltrim(cProd) + "]")
	EndIf

Return( nPrcFinal )


/*/{Protheus.doc} ValidaJson
Valida a estrutura do Json recebido (tags obrigatorias, cliente existente,
produtos existentes). Em caso de falha, dispara SetRestFault com a
mensagem REAL do erro (nao mais uma mensagem generica) e retorna vetor
vazio, sinalizando para a rotina chamadora encerrar o fluxo.
/*/
Static Function ValidaJson(cJsonIn)
	Local nA
	Local aPrdJson    := {}
	Local cProdutoVal := ""
	Local cErroJson   := ""

	Conout2("Validando dados")

	If Empty(cJsonIn)
		cErro := "Error 601 - Nao foram recebidos os dados necessarios para processar esta requisicao."
	EndIf

	If Empty(cErro)
		// FromJson devolve Nil quando da certo, ou o texto do erro quando o Json e invalido
		cErroJson := oJsonIn:FromJson(cJsonIn)
		If ValType(cErroJson) == "C" .And. ! Empty(cErroJson)
			cErro := "Error 602 - Os dados recebidos nao sao um Json valido: " + LimpaMsg(cErroJson)
		EndIf
	EndIf

	If Empty(cErro)
		If ! oJsonIn:HasProperty("Produtos") .Or. ! oJsonIn:HasProperty("Usuario") .Or. ! oJsonIn:HasProperty("EnderecoEntrega")
			cErro := "Error 603 - Nao foram localizadas as tags obrigatorias no Json recebido {Produtos/Usuario/EnderecoEntrega}."
		EndIf
	EndIf

	If Empty(cErro)
		aPrdJson := oJsonIn["Produtos"]
		If ValType(aPrdJson) <> "A" .Or. Len(aPrdJson) == 0
			cErro := "Error 604 - A tag 'Produtos' nao contem um vetor de dados."
		EndIf
	EndIf

	If Empty(cErro)
		oUsuario := oJsonIn["Usuario"]
		If ValType(oUsuario) <> "J"
			cErro := "Error 605 - A tag 'Usuario' nao contem um objeto valido."
		ElseIf ! oUsuario:HasProperty("Cnpj") .And. ! oUsuario:HasProperty("Cpf")
			cErro := "Error 606 - Nao foi localizado o CNPJ ou CPF do cliente."
		EndIf
	EndIf

	If Empty(cErro)
		If oUsuario:HasProperty("Cnpj")
			cCnpj := SoNumero(cValToChar(oUsuario["Cnpj"]))
		EndIf
		If oUsuario:HasProperty("Cpf")
			cCpf := SoNumero(cValToChar(oUsuario["Cpf"]))
		EndIf

		cCliente := Padr(If(! Empty(cCnpj), cCnpj, cCpf), Len(SA1->A1_CGC))
		If Empty(Alltrim(cCliente))
			cErro := "Error 607 - As tags [Cnpj] e [Cpf] estao vazias."
		EndIf
	EndIf

	If Empty(cErro)
		SA1->(DbSetOrder(3))
		If ! SA1->(DbSeek(xFilial("SA1") + cCliente))
			cErro := "Error 608 - Cliente nao encontrado. Documento: [" + Alltrim(cCliente) + "]"
		EndIf
	EndIf

	If Empty(cErro)
		oEnderecoEntrega := oJsonIn["EnderecoEntrega"]
		If ValType(oEnderecoEntrega) <> "J"
			cErro := "Error 609 - A tag 'EnderecoEntrega' nao contem um objeto valido."
		ElseIf ! oEnderecoEntrega:HasProperty("Estado")
			cErro := "Error 610 - A tag [Estado] nao foi localizada no objeto 'EnderecoEntrega'."
		EndIf
	EndIf

	If Empty(cErro)
		For nA := 1 To Len(aPrdJson)
			If ValType(aPrdJson[nA]) <> "J" .Or. ! aPrdJson[nA]:HasProperty("Sku") .Or. ! aPrdJson[nA]:HasProperty("Quantidade") .Or. ! aPrdJson[nA]:HasProperty("ProdutoVarianteId")
				cErro := "Error 611 - Um ou mais produtos enviados nao possuem as tags [Sku], [Quantidade] ou [ProdutoVarianteId]."
				Exit
			EndIf

			SB1->(DbSetOrder(1))
			cProdutoVal := Padr(cValToChar(aPrdJson[nA]["Sku"]), Len(SB1->B1_COD))
			If ! SB1->(DbSeek(xFilial("SB1") + cProdutoVal))
				cErro := "Error 612 - Sku [" + Alltrim(cProdutoVal) + "] nao localizado no cadastro de produtos."
				Exit
			EndIf
		Next
	EndIf

	If ! Empty(cErro)
		aPrdJson := {}
		Conout2("Ocorreu uma falha de validacao: " + cErro)
		FalhaRest(420, cErro)
	EndIf

Return( aPrdJson )


/*/{Protheus.doc} BuscaPreco
Retorna o preco de venda vigente do produto, escolhendo a tabela de preco
pelo tipo do cliente (A1_TIPO). O cliente ja esta posicionado na SA1, pois
foi localizado pelo CNPJ/CPF recebido no Json (ver ValidaJson).
  A1_TIPO = "R" (Revendedor)         -> tabela do parametro ES_WKPRCR (padrao V08)
  A1_TIPO = "F" (Cons. Final) / demais -> tabela do parametro ES_WKPRCF (padrao V07)
Dentro da tabela, considera apenas itens ativos (DA1_ATIVO diferente de "2")
e ja vigentes (DA1_DATVIG vazia ou menor/igual a data de hoje). Se houver
mais de um item valido para o produto, usa o de vigencia mais recente.
/*/
Static Function BuscaPreco(cCod)
	Local cTipoCli := Alltrim(SA1->A1_TIPO)
	Local cLista   := cTabela
	Local cChave   := ""
	Local dMelhor  := CtoD("")
	Local lAchou   := .F.
	Local nRet     := 0

	Conout2("Tipo do cliente [" + cTipoCli + "] - usando tabela de preco [" + cLista + "]")

	DbSelectArea("DA1")
	DA1->(DbSetOrder(1)) // Filial + Tabela + Produto + Indice Lote + Item

	cLista := Padr(cLista, Len(DA1->DA1_CODTAB))
	cCod   := Padr(cCod, Len(DA1->DA1_CODPRO))
	cChave := xFilial("DA1") + cLista + cCod

	If DA1->(DbSeek(cChave))
		While ! DA1->(Eof()) .And. DA1->(DA1_FILIAL + DA1_CODTAB + DA1_CODPRO) == cChave
			If DA1->DA1_ATIVO <> "2" .And. (Empty(DA1->DA1_DATVIG) .Or. DA1->DA1_DATVIG <= Date())
				If ! lAchou .Or. DA1->DA1_DATVIG >= dMelhor
					lAchou  := .T.
					dMelhor := DA1->DA1_DATVIG
					nRet    := DA1->DA1_PRCVEN
				EndIf
			EndIf

			DA1->(DbSkip())
		EndDo
	EndIf

Return( nRet )


/*/{Protheus.doc} PrecoZZL
Devolve o preco final (ZZL_VALOR) ja gravado na ZZL para o SKU/ID Wake, se o
registro ainda valer: mesma tabela de
preco (ZZL_PRCTAB), mesmo tipo de cliente (ZZL_TIPOCL), mesmo valor de tabela
(ZZL_VLRTAB) e mesmo PrecoPor (ZZL_PRECOP). Devolve 0 se for preciso recalcular.
ATENCAO: a chave da ZZL nao tem cliente nem UF, entao o reaproveitamento nao
detecta mudanca de UF/cliente/aliquota.
/*/
Static Function PrecoZZL(cSku, cIdWake, nPreco, nPrecoPor)
	Local nRet := 0

	If ZZL->(FieldPos("ZZL_PRCTAB")) == 0 .Or. ZZL->(FieldPos("ZZL_VLRTAB")) == 0 .Or. ZZL->(FieldPos("ZZL_TIPOCL")) == 0
		Return( 0 )
	EndIf

	DbSelectArea("ZZL")
	ZZL->(DbSetOrder(1))

	If BuscaZZL(cSku, cIdWake) .And. ! ZZL->(Deleted())
		If Alltrim(ZZL->ZZL_PRCTAB) == cTabela .And. ;
			Alltrim(ZZL->ZZL_TIPOCL) == Alltrim(SA1->A1_TIPO) .And. ;
			Round(Val(cValToChar(ZZL->ZZL_VLRTAB)), 2) == Round(nPreco, 2) .And. ;
			Round(Val(cValToChar(ZZL->ZZL_PRECOP)), 2) == Round(nPrecoPor, 2)

			nRet := Val(cValToChar(ZZL->ZZL_VALOR))
			Conout2("Cache ZZL reaproveitado (sem recalculo de imposto). Sku [" + cSku + "] ID [" + cIdWake + "]")
		EndIf
	EndIf

Return( nRet )


/*/{Protheus.doc} TabelaPreco
Devolve o codigo da tabela de preco do cliente posicionado na SA1:
"R" -> ES_WKPRCR (padrao V08) | demais -> ES_WKPRCF (padrao V07).
/*/
Static Function TabelaPreco()
	Local cLista := If(Alltrim(SA1->A1_TIPO) == "R", ;
		SuperGetMV("ES_WKPRCR", .F., "V08"), SuperGetMV("ES_WKPRCF", .F., "V07"))

Return( Alltrim(cLista) )


/*/{Protheus.doc} GravaCampo
Grava o valor num campo da ZZL (posicionada e travada) convertendo para o
tipo do campo; se o campo nao existir no ambiente, ignora sem erro.
/*/
Static Function GravaCampo(cCampo, uValor)
	If ZZL->(FieldPos(cCampo)) > 0
		ZZL->&(cCampo) := ConvZZL(cCampo, uValor)
	EndIf
Return


/*/{Protheus.doc} PegaNum
Le uma tag numerica do Json de forma segura: se a tag nao existir, ou nao
for numero nem texto numerico, devolve 0 em vez de quebrar a rotina.
/*/
Static Function PegaNum(oObj, cChave)
	Local nRet := 0
	Local uVal

	If oObj:HasProperty(cChave)
		uVal := oObj[cChave]

		If ValType(uVal) == "N"
			nRet := uVal
		ElseIf ValType(uVal) == "C"
			nRet := Val(uVal)
		EndIf
	EndIf

Return( nRet )


/*/{Protheus.doc} ConvZZL
Devolve o valor no tipo do campo da ZZL: se o campo estiver como caractere
no ambiente (ex: producao), converte com cValToChar; se for numerico, devolve
o proprio numero. Assim o fonte funciona nos dois cenarios.
/*/
Static Function ConvZZL(cCampo, nValor)
	Local nPos := ZZL->(FieldPos(cCampo))
	Local uRet := nValor

	If nPos > 0 .And. ValType(ZZL->(FieldGet(nPos))) == "C"
		uRet := cValToChar(nValor)
	EndIf

Return( uRet )


/*/{Protheus.doc} BuscaZZL
Posiciona a ZZL no registro do SKU + ID Wake + CNPJ/CPF do cliente da
requisicao (cCliente), usando o indice 2 (Filial + SKU + ID Wake + ZZL_CGC).
Se o campo ZZL_CGC nao existir no ambiente, busca so por SKU + ID Wake no
indice 1 (primeiro registro da chave).
/*/
Static Function BuscaZZL(cSku, cIdWake)
	Local lAchou := .F.

	If ZZL->(FieldPos("ZZL_CGC")) > 0
		ZZL->(DbSetOrder(2))
		lAchou := ZZL->(DbSeek(ChaveZZL(cSku, cIdWake) + Padr(Alltrim(cCliente), Len(ZZL->ZZL_CGC))))
		ZZL->(DbSetOrder(1))
	Else
		ZZL->(DbSetOrder(1))
		lAchou := ZZL->(DbSeek(ChaveZZL(cSku, cIdWake)))
	EndIf

Return( lAchou )


/*/{Protheus.doc} ChaveZZL
Monta a chave de busca da ZZL (SKU + ID Wake) de acordo com o indice 1 da
tabela: se o indice comecar pela filial, inclui xFilial na frente; se nao
comecar (indice apenas SKU + ID Wake), busca so com SKU + ID Wake.
Deve ser chamada com a ZZL aberta e com DbSetOrder(1) ja feito.
OBS: xFilial devolve espacos mesmo em tabela compartilhada, por isso nao da
para incluir a filial "por garantia": a chave precisa bater com o indice.
/*/
Static Function ChaveZZL(cSku, cIdWake)
	Local cChave := Padr(cSku, Len(ZZL->ZZL_SKU)) + Padr(cIdWake, Len(ZZL->ZZL_PRODID))

	If "_FILIAL" $ Upper(ZZL->(IndexKey()))
		cChave := xFilial("ZZL") + cChave
	EndIf

Return( cChave )


/*/{Protheus.doc} LimpaMsg
Deixa o texto seguro para ir no corpo de uma resposta Json: troca quebras de
linha e tabs por separadores, aspas duplas por apostrofo e barra invertida por
barra normal, e corta textos muito longos. Sem isso, a pilha de erro do
Protheus (que tem quebra de linha e aspas) pode gerar um Json invalido e o
framework devolve o 500 generico, escondendo a mensagem real.
/*/
Static Function LimpaMsg(cTexto)
	Local cRet := cValToChar(cTexto)

	cRet := StrTran(cRet, CRLF, " | ")
	cRet := StrTran(cRet, Chr(13), " ")
	cRet := StrTran(cRet, Chr(10), " | ")
	cRet := StrTran(cRet, Chr(9), " ")
	cRet := StrTran(cRet, '"', "'")
	cRet := StrTran(cRet, "\", "/")

	If Len(cRet) > 1500
		cRet := Left(cRet, 1500) + "..."
	EndIf

Return( cRet )


/*/{Protheus.doc} FalhaRest
Somente na versao de TESTE: registra a falha em cUltErro (para a rotina de
teste manual mostrar na tela) e so chama SetRestFault quando a execucao vem
do REST de verdade (nao no teste manual pelo SmartClient).
/*/
Static Function FalhaRest(nCodigo, cMensagem)
	cUltErro := cValToChar(nCodigo) + " - " + cMensagem

	If ! lModoTeste
		SetRestFault(nCodigo, cMensagem)
	EndIf

Return


/*/{Protheus.doc} ChkErro
Handler de erro instalado via ErrorBlock dentro de ImpostoDif.
Registra o erro no log e devolve via SetRestFault, interrompendo o fluxo.
/*/
Static Function ChkErro(e)
	Local cErroMsg := "Error 500 - Falha inesperada na execucao."
	Local cMsg1    := e:ErrorStack
	Local cMsg2    := e:Description

	Conout2(cErroMsg)
	Conout2(cMsg1)
	Conout2(cMsg2)

	// Devolve o erro REAL no code 500 / message, ja limpo para nao quebrar o Json
	FalhaRest(500, LimpaMsg(cErroMsg + " / " + cMsg2 + " / " + cMsg1))

	Break
Return


/*/{Protheus.doc} Conout2
Log padronizado com identificacao da API, data e hora.
/*/
Static Function Conout2(cTexto)
	cTexto := "### " + cNomeApi + " - " + Dtoc(Date()) + " " + Time() + " - " + cTexto
	Conout(cTexto)
Return
