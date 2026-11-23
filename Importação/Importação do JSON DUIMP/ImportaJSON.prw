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

Return

/*=================================================================
Autor: Desconhecido
Data: 12/02/2026
Uso: Calibre
Info: 
*==================================================================*/
User Function ImportFile()

	Local cFile 		:= ""
	Local cQuery 		:= ""
	Local cTemp         := ""
	Local cJson			:= ""
	Local cError		:= ""
	Local cItem			:= ""
	Local cProduto		:= ""
	Local cCNPJ			:= ""
	Local cLog			:= ""
	local cFileError	:= ""
	Local cFabrAnt      := ""
	Local cCodForn      := ""
	Local cLojForn      := ""
	Local aAtributos	:= {}
	Local nCont			:= 0
	Local nX            := 0
	Local nSeq          := 0
	Local lErro  		:= .F.
	
	Private oJson		:= Nil
	Private cFornece    := ""
	Private cFornLoja   := ""

	cFile := cGetFile("Arquivos (*.json)|*.json", "Selecione o arquivo",,, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE, .F.)
	cFile := Alltrim(cFile)
	
	If !Empty(cFile)
	
		// Le a string JSON do arquivo do disco:
		cJson := readfile(cFile)
	
		// Cria o objeto JSON e popula ele a partir da string:
		oJson 	:= JSonObject():New()
		cError	:= oJSon:fromJson(cJson)
	
		If !Empty(cError)
		
			FWAlertWarning("Arquivo JSON [" + cFile + "] formato inválido. Erro: " + CRLF + CRLF + cError, "ImportaJSON")
			
		Else
			
			SB1->(dbSetOrder(1))
		
			For nCont := 1 to Len(oJson)
			
				lErro := .F.
				
				If ValType(oJson[nCont]) <> "U"
					
					If ValType(oJson[nCont]:GetJSonObject("CODIGOSINTERNO")[1]) <> "U"
					
						cProduto := oJson[nCont]:GetJSonObject("CODIGOSINTERNO")[1]
						cProduto := PADR(cProduto,Len(SB1->B1_COD))
						
						If !SB1->(DbSeek(FWxFilial("SB1") + cProduto))
						
							cLog += "Código interno não existe no Protheus - "+ AllTrim(cProduto) +"."+ CRLF
							
							lErro := .T.
							
						Endif
						
					Else
						
						cLog += "Código interno não informado."+ CRLF
						
						lErro := .T.
						
					Endif
	
					If ValType(oJson[nCont]:GetJSonObject("CPFCNPJRAIZ")) <> "U"
					
						cCNPJ := oJson[nCont]:GetJSonObject("CPFCNPJRAIZ")
						
					Else
						
						cLog += "Raiz CPF/CNPJ não informada."+ CRLF
						
						lErro := .T.
						
					Endif
	
					If !lErro
					
						cCNPJ := AllTrim(cCNPJ)
						cTemp := GetNextAlias()
						
						cQuery := " SELECT A2_COD, A2_LOJA, A2_CGC"
						cQuery += " FROM "+ RetSQLName("SA2")
						cQuery += " WHERE D_E_L_E_T_ <> '*' AND A2_CGC LIKE '"+ cCNPJ+"%'"
						cQuery += " ORDER BY A2_COD, A2_LOJA"
	
						//Proteção para verificar se há dados já na tabela temporária
						If Select(cTemp) > 0
							(cTemp)->(DbCloseArea())
							cTemp := GetNextAlias()			
						Endif 
	
						//Conversão da query para a sintaxe do banco de dados do cliente
						cQuery := ChangeQuery(cQuery)

						//Execução da query no banco de dados
						DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
						
						If (cTemp)->(!EOF()) .And. cCNPJ $ (cTemp)->A2_CGC
						
							DbSelectArea("SA2")
							SA2->(DbSetOrder(1))
						
							If SA2->(DbSeek(FWxFilial("SA2") + (cTemp)->A2_COD + (cTemp)->A2_LOJA))
							
								cCodForn := SA2->A2_COD 
								cLojForn := SA2->A2_LOJA
							
								(cTemp)->(DbCloseArea())
								
								DbSelectArea("SA5")
								SA5->(DbSetOrder(1))
								
								If SA5->(DbSeek(FWxFilial("SA5") + cCodForn + cLojForn + cProduto))
								
									While !SA5->(EOF()) .And. (SA5->A5_FORNECE + SA5->A5_LOJA + SA5->A5_PRODUTO == cCodForn + cLojForn + cProduto)
									
										If cFabrAnt <> SA5->A5_FABR + SA5->A5_FALOJA
										
											If ValType(oJson[nCont]:GetJSonObject("ATRIBUTOS")) == "A"
												
												aAtributos := {}
												aAtributos := oJson[nCont]:GetJSonObject("ATRIBUTOS")
												cFornece   := SA5->A5_FABR 
												cFornLoja  := SA5->A5_LOJA

												nSeq ++ 
												
												cItem := StrZero(nSeq,3)
												
												Begin Transaction
													CatalogoProd_Inclui(cItem,cCNPJ,aAtributos)
												End Transaction
												
											Endif
	
										Endif 
	
										cFabrAnt := SA5->A5_FABR + SA5->A5_FALOJAS
									
										SA5->(DbSkip())
									
									EndDo

								Else 
									
									If ValType(oJson[nCont]:GetJSonObject("ATRIBUTOS")) == "A"
									
										aAtributos := {}
										aAtributos := oJson[nCont]:GetJSonObject("ATRIBUTOS")
										cFornece   := cCodForn
										cFornLoja  := cLojForn
										
										nSeq ++ 
										
										cItem := StrZero(nSeq,3)
										
										Begin Transaction
											CatalogoProd_Inclui(cItem,cCNPJ,aAtributos)
										End Transaction
									
									Endif
										
									
								Endif 
	
							Endif 
							
						Else
							
							(cTemp)->(dbCloseArea())
							
							cLog += "Raiz CPF/CNPJ - '"+ cCNPJ +"' não existe no Protheus (SA2)."+ CRLF
							
							lErro := .T.
							
						Endif
						
					Endif
					
				Endif
				
			Next nCont
			
		Endif
	
		If !Empty(cLog)
		
			Conout("ERRO na ImportaJSON...")
			Conout(cLog)
	
			cFileError := "c:\temp\importajson_"+DTOS(dDataBase) + "_" + StrTran(time(),":","") +".log"
			
			If File(cFileError)
			
				fErase(cFileError)
				
			Endif
			
			MemoWrite(cFileError,cLog)
			
			If File(cFileError)
			
				FWAlertWarning("Gerado LOG de erro no arquivo: " + cFileError + " - Consulte por favor!", "ImportaJSON")
				
				ShellExecute("Open",cFileError,"","",5)
				
			Else
				
				FWAlertError("ERRO: "+ CRLF + CRLF + cLog,"ImportaJSON")
				
			Endif
			
		Else
			
			FWAlertSuccess("Importação Concluída.", "ImportaJSON")
			
		Endif
	
		FreeObj(oJson)
		
	Else 
		
		FWAlertError("Nenhum arquivo selecionado", "ImportaJSON")
		
	Endif 

Return

/*=================================================================
Autor: Desconhecido
Data: 12/02/2026
Uso: Calibre
Info: 
*==================================================================*/
Static Function ReadFile(cFile)

	Local cBuffer := ""
	Local cLinha  := ""
	Local cTemp	  := ""

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
				
			EndDo
			
			FT_FUSE()
			
		Endif
		
	Endif

	cTemp := DecodeUTF8(cBuffer)
	
	If !Empty(cTemp)
	
		cBuffer := cTemp
		
	Endif

Return(cBuffer)

/*=================================================================
Autor: Desconhecido
Data: 12/02/2026
Uso: Calibre
Info: 
*==================================================================*/
Static Function CatalogoProd_Inclui(cItem,cCNPJ,aAtributos)

	Local oModel    := Nil
	Local oModelEK9 := Nil
	Local oGridEKA  := Nil
	Local oGridEKB  := Nil
	Local oGridEKC  := Nil
	Local nLinha    := 0
	Local cError	:= ""
	Local aError    := {}

	Private OCHANNEL := Nil
	Private aRotina  := {}

	oModel := FWLoadModel("EICCP400")
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	aRotina	:= FWloadmenudef('EICCP400')

	oModelEK9 := oModel:getModel("EK9MASTER")
	oGridEKA  := oModel:getModel("EKADETAIL")
	oGridEKB  := oModel:getModel("EKBDETAIL")
	oGridEKC  := oModel:GetModel("EKCDETAIL")

	// EK9MASTER: esse modelo de dados representa os dados da capa do catálogo de produtos.
	oModelEK9:LoadValue("EK9_CNPJ"  , cCNPJ)
	oModelEK9:LoadValue("EK9_MODALI", "1")
	oModelEK9:setValue("EK9_PRDREF"	, SB1->B1_COD)
	oModelEK9:setValue("EK9_DESC_I"	, SB1->B1_DESC)
	oModelEK9:setValue("EK9_NCM"   	, SB1->B1_POSIPI)
	oModelEK9:setValue("EK9_UNIEST"	, Posicione("SYD",1,xFilial("SYD") + SB1->B1_POSIPI,"YD_UNID"))
	oModelEK9:setValue("EK9_DSCCOM"	, Posicione("SYP",1,xFilial("SYP") + SB1->B1_DESC_GI,"YP_TEXTO"))

	// EKADETAIL: esse modelo de dados é relacionado ao modelo de dados EK9MASTER e representa a "Relação de Produtos" do catálogo de produtos.
	oGridEKA:setValue("EKA_ITEM"  , AllTrim(cItem))
	oGridEKA:setValue("EKA_PRDREF", SB1->B1_COD)
	oGridEKA:AddLine()

	// EKBDETAIL: esse modelo de dados é relacionado ao modelo de dados EK9MASTER e representa a "Relação de Países de Origem e Fabricantes" do catálogo de produtos.
	oGridEKB:LoadValue("EKB_CODFAB", AllTrim(cFornece))
	oGridEKB:LoadValue("EKB_LOJA"  , AllTrim(cFornLoja))
	
	DbSelectArea("SYA")	
	SYA->(DbSetOrder(1))
	
	If SYA->(DbSeek(FWxFilial("SYA") + Posicione("SA2",1,FWxFilial("SA2") + cFornece + cFornLoja,"A2_PAIS")))
		oGridEKB:LoadValue("EKB_PAIS", SYA->YA_PAISDUE)
	Endif

	If !oGridEKB:IsEmpty()
		oGridEKB:AddLine()
	Endif

	// EKCDETAIL: esse modelo de dados é relacionado ao modelo de dados EK9MASTER e representa a "Relação de Atributos" do catálogo de produtos.
	For nLinha := 1 to Len(aAtributos)
	
		oGridEKC:GoLine(nLinha)
		oGridEKC:SetValue("EKC_CODATR", AllTrim(aAtributos[nLinha]:GetJSonObject("ATRIBUTO")))
		oGridEKC:SetValue("EKC_VALOR", AllTrim(aAtributos[nLinha]:GetJSonObject("VALOR")))
		
	Next nLinha

	If oModel:VldData()
	
		oModel:CommitData()
		
	Else
		
		aError := oModel:GetErrorMessage()
		
		For nLinha := 1 To Len(aError)
		
			cError += AllTrim(aError[nLinha])+ CRLF
			
		Next nLinha

		If !ExistDir("C:\temp\")
		
			MakeDir("C:\temp\")
			
		Endif
		
		MemoWrite("C:\temp\Produto_"+AllTrim(SB1->B1_COD)+".log",cError)
		
		ShellExecute("Open","C:\temp\Produto_"+AllTrim(SB1->B1_COD)+".log","","",5)
		
	Endif

	oModel:DeActivate()
	oModel:Destroy()
	
	FwFreeObj(oModel)

Return

