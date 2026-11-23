#Include 'Totvs.ch'
#Include 'FwMVCDef.ch'
#Include 'TopConn.ch'

//-----------------------------------------------------------------
/*/{Protheus.doc} ImportaJSON
EIC - Importa Catálogo de Produtos

@type		Function
@author 	Cassandra Van Ham
@since 		20/06/2025
@return		nil, nulo
/*/
//-----------------------------------------------------------------
User Function ImportaJSON()
	Local bBlocoExec := {|| U_ImportFile()}
	TNewProcess():New("ImportaJSON" , "Catálogo de Produtos", bBlocoExec, "Importa Arquivo no formato JSON.", /*cPerg*/, /*aInfoCustom*/, /*lPanelAux*/, /*nSizePanelAux*/, /*cDescriAux*/,.T.)
Return Nil


//-----------------------------------------------------------------
User Function ImportFile()
	Local cFile 		:= ""
	Local cQuery 		:= ""
	Local cJson			:= ""
	Local cError		:= ""
	Local cItem			:= ""
	Local cProduto		:= ""
	Local cCNPJ			:= ""
	Local _cLog			:= ""
	local cFileError	:= ""
	Local aAtributos	:= {}
	Local nCont			:= 0
	Local lErro  		:= .F.
	Private oJson		:= Nil

	cFile := cGetFile("Arquivos (*.json)|*.json", "Selecione o arquivo",,, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE, .F.)
	cFile := Alltrim(cFile)
	If Empty(cFile)
		FWAlertError("Nenhum arquivo selecionado", "ImportaJSON")
		Return Nil
	EndIf

	// Le a string JSON do arquivo do disco:
	cJson := readfile(cFile)

	// Cria o objeto JSON e popula ele a partir da string:
	oJson := JSonObject():New()
	cError:= oJSon:fromJson(cJson)

	If !Empty(cError)
		FWAlertWarning("Arquivo JSON formato inválido.", "ImportaJSON")
	Else
		SB1->(dbSetOrder(1))
		For nCont:=1 to Len(oJson)
			lErro := .F.
			If ValType(oJson[nCont]) <> "U"
				If ValType(oJson[nCont]:GetJSonObject("SEQ")) <> "U"
					cItem		:= oJson[nCont]:GetJSonObject("SEQ")
					cItem		:= StrZero(cItem,3)
				Else
					_cLog 		+= "Sequencia não informada."+ CRLF
					lErro		:= .T.
				Endif
				If ValType(oJson[nCont]:GetJSonObject("CODIGOSINTERNO")[1]) <> "U"
					cProduto	:= oJson[nCont]:GetJSonObject("CODIGOSINTERNO")[1]
					cProduto    := PADR(cProduto,Len(SB1->B1_COD))
					If !SB1->(dbSeek( FWxFilial("SB1") + cProduto ))
						_cLog 		+= "Código interno não existe no Protheus - "+ Alltrim(cProduto) +"."+ CRLF
						lErro		:= .T.
					Endif
				Else
					_cLog 		+= "Código interno não informado."+ CRLF
					lErro		:= .T.
				Endif

				If ValType(oJson[nCont]:GetJSonObject("CPFCNPJRAIZ")) <> "U"
					cCNPJ 		:= oJson[nCont]:GetJSonObject("CPFCNPJRAIZ")
				Else
					_cLog 		+= "Raiz CPF/CNPJ não informada."+ CRLF
					lErro		:= .T.
				Endif

				If !lErro
					cCNPJ := Alltrim(cCNPJ)
					cQuery:= " SELECT A2_COD, A2_LOJA, A2_CGC"
					cQuery+= " FROM "+ RetSQLName("SA2")
					cQuery+= " WHERE D_E_L_E_T_ = ' ' AND A2_CGC LIKE '"+ cCNPJ+"%'"
					cQuery+= " ORDER BY A2_COD, A2_LOJA"

					If Select("QRYSA2") <> 0
						QRYSA2->(dbCloseArea())
					Endif

					TcQuery cQuery Alias "QRYSA2" New
					If QRYSA2->(!Eof()) .and. cCNPJ $ QRYSA2->A2_CGC
						SA2->(dbSeek( FWxFilial("SA2") + QRYSA2->A2_COD + QRYSA2->A2_LOJA ))
						QRYSA2->(dbCloseArea())

						If ValType(oJson[nCont]:GetJSonObject("ATRIBUTOS")) == "A"
							aAtributos := oJson[nCont]:GetJSonObject("ATRIBUTOS")
							BEGIN TRANSACTION
								CatalogoProd_Inclui(cItem, cCNPJ, aAtributos)
							END TRANSACTION
						Endif
					Else
						QRYSA2->(dbCloseArea())
						_cLog += "Raiz CPF/CNPJ - '"+ cCNPJ +"' não existe no Protheus (SA2)."+ CRLF
						lErro		:= .T.
					Endif
				Endif
			Endif
		Next
	Endif

	If !Empty(_cLog)
		Conout("ERRO na ImportaJSON...")
		Conout(_cLog)
		
		cFileError		:= "c:\temp\importajson_"+DTOS(dDataBase) + "_" + strtran(time(),":","") +".log"
		if file(cFileError)
			fErase(cFileError)
		endif
		MemoWrite(cFileError,_cLog)
		if file(cFileError)
			FWAlertWarning("Gerado LOG de erro no arquivo: " + cFileError + " - Consulte por favor!", "ImportaJSON")
		else
			FWAlertError("ERRO: "+ CRLF + CRLF + _cLog,"ImportaJSON")
		endif
	Else
		FWAlertSuccess("Importação Concluída.", "ImportaJSON")
	Endif

	FreeObj(oJson)

Return Nil

//-----------------------------------------------------------------
Static Function ReadFile(cFile)
	Local cBuffer := ""
	Local cLinha  := ""

	If File(cFile)
		If FT_FUSE(cFile) < 0
			FWAlertError("Falha na abertura do arquivo ["+cFile+"].", "ImportaJSON")
		Else
			FT_FGOTOP()
			Do While !FT_FEOF()
				cLinha  := ""
				cLinha  := FT_FREADLN()
				cBuffer += Upper(Alltrim(cLinha))
				FT_FSKIP()
			Enddo
			FT_FUSE()
		Endif
	EndIf

	cBuffer := DecodeUTF8(cBuffer)

Return cBuffer

//-----------------------------------------------------------------
Static Function CatalogoProd_Inclui(cItem, cCNPJ, aAtributos)
	Local oModel    := Nil
	Local oModelEK9 := Nil
	Local oGridEKA  := Nil
	Local oGridEKB  := Nil
	Local oGridEKC  := Nil
	Local nLinha   := 0
	Local cError	:= ""
	Local aError    := {}

	Private OCHANNEL	:= Nil
	Private aRotina 	:= {}

	oModel:= FWLoadModel("EICCP400")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	aRotina		:= FWloadmenudef('EICCP400')

	oModelEK9 	:= oModel:getModel("EK9MASTER")
	oGridEKA  	:= oModel:getModel("EKADETAIL")
	oGridEKB 	:= oModel:getModel("EKBDETAIL")
	oGridEKC  	:= oModel:GetModel("EKCDETAIL")

	// EK9MASTER: esse modelo de dados representa os dados da capa do catálogo de produtos.
	oModelEK9:LoadValue("EK9_CNPJ"  	, cCNPJ)
	oModelEK9:LoadValue("EK9_MODALI"	, "1")
	oModelEK9:setValue("EK9_PRDREF"	, SB1->B1_COD)
	oModelEK9:setValue("EK9_DESC_I"	, SB1->B1_DESC)
	oModelEK9:setValue("EK9_NCM"   	, SB1->B1_POSIPI)
	oModelEK9:setValue("EK9_UNIEST"	, Posicione("SYD",1,xFilial("SYD") + SB1->B1_POSIPI,"YD_UNID"))
	oModelEK9:setValue("EK9_DSCCOM"	, Posicione("SYP",1,xFilial("SYP") + SB1->B1_DESC_GI,"YP_TEXTO"))

	// EKADETAIL: esse modelo de dados é relacionado ao modelo de dados EK9MASTER e representa a "Relação de Produtos" do catálogo de produtos.
	oGridEKA:setValue("EKA_ITEM"  , Alltrim(cItem))
	oGridEKA:setValue("EKA_PRDREF", SB1->B1_COD)
	oGridEKA:AddLine()

	// EKBDETAIL: esse modelo de dados é relacionado ao modelo de dados EK9MASTER e representa a "Relação de Países de Origem e Fabricantes" do catálogo de produtos.
	oGridEKB:LoadValue("EKB_CODFAB", Alltrim(SA2->A2_COD))
	oGridEKB:LoadValue("EKB_LOJA"  , Alltrim(SA2->A2_LOJA))

	If SYA->(dbSeek( FWxFilial("SYA") + SA2->A2_PAIS ))
		oGridEKB:LoadValue("EKB_PAIS"  , SYA->YA_PAISDUE)
	Endif

	If !oGridEKB:IsEmpty()
		oGridEKB:AddLine()
	Endif

	// EKCDETAIL: esse modelo de dados é relacionado ao modelo de dados EK9MASTER e representa a "Relação de Atributos" do catálogo de produtos.
	For nLinha := 1 to Len(aAtributos)
		oGridEKC:GoLine(nLinha)
		oGridEKC:SetValue("EKC_CODATR", Alltrim(aAtributos[nLinha]:GetJSonObject("ATRIBUTO")))
		oGridEKC:SetValue("EKC_VALOR", Alltrim(aAtributos[nLinha]:GetJSonObject("VALOR")))
	Next nLinha

	If oModel:VldData()
		oModel:CommitData()
	Else
		aError := oModel:GetErrorMessage()
		For nLinha:=1 to Len(aError)
			cError += Alltrim(aError[nLinha])+ CRLF
		Next

		If !ExistDir("c:\temp\")
			MakeDir("c:\temp\")
		Endif
		MemoWrite("c:\temp\Produto_"+Alltrim(SB1->B1_COD)+".log",cError)
	Endif

	oModel:DeActivate()
	oModel:Destroy()
	FwFreeObj(oModel)

Return Nil
