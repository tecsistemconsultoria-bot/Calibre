#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

/***********************************************************************
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 12/2024
Consultoria: Proativa
Uso: Calibre
Tipo: Atualizações
Rotina: Estoque/Custos
Função: xCavEtq1
Info: Impressão de Etiqueta Quimica.
************************************************************************/
User Function xCavEtq1()

	Local aArea       := GetArea()
	Local _cPathFile  := "c:/etiquetas/"
	Local aPergs      := {}

	Private _cDir     := ""
	Private cNomePC   := ComputerName()

	//Private cModZM400 := GetMV("XX_ZM400",.F.,"CARS0038")

	//Diretorio Raiz
	_cDir := _cPathFile 

	If !ExistDir(_cDir)
		MakeDir(_cDir)
	Endif

	DbSelectArea("ZZI")

	IF !PergParam(@aPergs)
		Return
	Endif

	sfEtiqueta(aPergs)

	RestArea(aArea)

Return

/*=================================================================
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 13/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Grava os arquivos com as strings das etiquetas
*==================================================================*/
Static Function sfEtiqueta(aPergs)

	Local cModelo	:= "ZEBRA" 
	Local cPorta	:= "LPT1"
	Local cStrEtiq  := ""

	Private aArqGerados := {}

	cStrEtiq := sfStrEtiq(aPergs,cModelo,cPorta)

	If !Empty(cStrEtiq)
		GeraArqEtq(cStrEtiq)
	Endif

Return

/*=================================================================
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 13/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Gera a string com a etiqueta a ser enviada para a impressora 
Zebra. A string contém código ZPL
*==================================================================*/
Static Function sfStrEtiq(aPergs,cModelo,cPorta)

	Local cRet       := ""
	Local aFrasesP   := {}
	Local cFrasesP   := ""
	Local aFrasesH   := {}
	Local cFrasesH   := ""
	Local aPictos    := {}
	Local aPictosZB4 := {}
	Local nX         := 0
	Local VarControl := ""
	Local cDtValid   := ""
	//Local lZM400     := .F.

	SB1->(DbSetOrder(1))
	
	If !SB1->(DbSeek(xFilial("SB1")+aPergs[1]))
		Alert("Produto não encontrado")
		Return(cRet)
	Endif

	SB8->(DbSetOrder(5))
	
	If !SB8->(DbSeek(xFilial("SB8")+aPergs[1]+aPergs[2]))
	
		If !ExistLote(aPergs[2])
			Alert("ATENCAO: Este lote de produto nao existe!")
		Else
			Alert("ATENCAO: Este lote nao pertence a este produto!")
		Endif
		
		Return(cRet)
		
	Endif

	cDtValid := DTOC(SB8->B8_DTVALID)

	SB5->(DbSetOrder(1))

	cTextoH1 := "Importador/Fornecedor: Calibre Scientific Brasil LTDA. CNPJ: 01.530.501/0001-42 - Av. Pres. Getúlio Vargas, 8806, Dist. Industrial, Alvorada, RS | Tel: (11) 4812-5061" 
	cTextoH2 := "Telefone para emergências químicas 24h: ABIQUIM / Pró-Química®: 0800-110-8270" 

	cTextoR1 := "Responsável técnico: Willian Vagner Salla CRQ/RS 051002184 | Rótulo NBR 14725:2024 ver.241202 |"

	If SB1->B1_CRVPF = 'S' .AND. SB1->B1_CRVME = 'S'
		VarControl := "PRODUTO CONTROLADO PELA POLÍCIA FEDERAL E PELO EXÉRCITO"
	Elseif SB1->B1_CRVPF = 'S'
		VarControl := "PRODUTO CONTROLADO PELA POLÍCIA FEDERAL"
	Elseif SB1->B1_CRVME = 'S'
		VarControl := "PRODUTO CONTROLADO PELO EXÉRCITO"
	Endif

	ZZI->(DbSetOrder(1))
	
	aFrasesP := Separa(AllTrim(SB1->B1_XFRASEP)," ")
	
	For nX := 1 to Len(aFrasesP)
	
		If ZZI->(DbSeek(xFilial("ZZI")+aFrasesP[nX]))
			cFrasesP += AllTrim(ZZI->ZZI_COD)+" - "+AllTrim((ZZI->ZZI_TEXTO)+";  ")
		Endif
		
	Next nX

	aFrasesH := Separa(AllTrim(SB1->B1_XFRASEH)," ")
	
	For nX := 1 to Len(aFrasesH)
	
		If ZZI->(DbSeek(xFilial("ZZI")+aFrasesH[nX]))
			cFrasesH += AllTrim(ZZI->ZZI_COD)+" - "+AllTrim((ZZI->ZZI_TEXTO)+";  ")
		Endif
		
	Next nX

	aPictos := Separa(AllTrim(SB1->B1_XPICTOG)," ")


		For nX := 1 To Len(aPictos)
		
			If ZZI->(DbSeek(xFilial("ZZI")+aPictos[nX]))
				aAdd(aPictosZB4,{aPictos[nX],AllTrim(ZZI->ZZI_TEXTO)})
			Endif
			
		Next nX

		cRet += "^XA" + CRLF
		cRet += "^MMT" + CRLF
		cRet += "^PW1314" + CRLF
		cRet += "^LL2041" + CRLF
		cRet += "^LS0" + CRLF

		cRet += "^FO32,15^GB370,1256,4^FS" + CRLF
		cRet += "^FO104,15^GB0,1256,4^FS" + CRLF
		cRet += "^FO372,15^GB0,1256,4^FS" + CRLF
		cRet += "^FO104,758^GB265,0,4^FS" + CRLF

		cRet += "^FT56,1254^A0B,17,16^FH\^FD"+cTextoH1+"^FS" + CRLF
		cRet += "^FT82,1254^A0B,17,16^FH\^FD"+cTextoH2+"^FS" + CRLF
		cRet += "^FT130,1254^A0B,17,17^FH\^FDCódigo: B1_COD^FS" + CRLF
		cRet += "^FT154,1254^A0B,17,17^FH\^FDDescricao: B1_DESC^FS" + CRLF
		cRet += "^FT253,1254^A0B,17,17^FH\^FDPalavra de advertência: B1_XADVERT^FS" + CRLF
		cRet += "^FT277,1254^A0B,4,13^FH\^FDFrases de Perigo: FRASE_PERIGO^FS" + CRLF
		cRet += "^FT134,748^A0B,17,17^FH\^FDPictogramas:^FS" + CRLF
		cRet += "^FT180,1254^A0B,17,17^FH\^FDLote: PROD_LOTE^FS" + CRLF
		cRet += "^FT176,962^A0B,17,17^FH\^FDValidade: LOTE_VALID^FS" + CRLF
		cRet += "^FT301,748^A0B,4,13^FH\^FDFRASE_1_PRECAUCAO^FS" + CRLF

		IF Len(aPictosZB4) > 0
			cRet += "^FO128,606^GFA,02048,02048,00016,:Z64:"+aPictosZB4[1][2] + CRLF
		ELSE
			cRet += "^FO120,534^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 1
			cRet += "^FO128,493^GFA,02048,02048,00016,:Z64:"+aPictosZB4[2][2] + CRLF
		ELSE
			cRet += "^FO120,445^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 2
			cRet += "^FO128,380^GFA,02048,02048,00016,:Z64:"+aPictosZB4[3][2] + CRLF
		ELSE
			cRet += "^FO120,356^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 3
			cRet += "^FO128,267^GFA,02048,02048,00016,:Z64:"+aPictosZB4[4][2] + CRLF
		ELSE
			cRet += "^FO120,268^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 4
			cRet += "^FO128,154^GFA,02048,02048,00016,:Z64:"+aPictosZB4[5][2] + CRLF
		ELSE
			cRet += "^FO120,173^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 5
			cRet += "^FO128,42^GFA,02048,02048,00016,:Z64:"+aPictosZB4[6][2] + CRLF
		ELSE
			cRet += "^FO120,88^GB90,90,2^FS" + CRLF
		ENDIF

		cRet += "^FT393,1254^A0B,17,16^FH\^FD"+cTextoR1+" "+VarControl+"^FS" + CRLF
		cRet += "^FT204,1254^A0B,17,17^FH\^FDIdentidade Química: B1_XNOMONU^FS" + CRLF
		cRet += "^FT229,1254^A0B,17,17^FH\^FDCONTINUACAO_XOBS^FS" + CRLF
		cRet += "^FT301,1254^A0B,4,13^FH\^FDFRASE_1_PERIGO^FS" + CRLF
		cRet += "^FT326,1254^A0B,4,13^FH\^FDFRASE_2_PERIGO^FS" + CRLF
		cRet += "^FT349,1254^A0B,4,13^FH\^FDFRASE_3_PERIGO^FS" + CRLF
		cRet += "^FT326,748^A0B,4,13^FH\^FDFRASE_2_PRECAUCAO^FS" + CRLF
		cRet += "^FT349,748^A0B,4,13^FH\^FDFRASE_3_PRECAUCAO^FS" + CRLF

		cRet += "^FT277,748^A0B,4,13^FH\^FDFrases de Precaução: FRASE_PRECAUCAO^FS" + CRLF

		cRet += "^FO440,15^GB370,1256,4^FS" + CRLF
		cRet += "^FO512,15^GB0,1256,4^FS" + CRLF
		cRet += "^FO779,15^GB0,1256,4^FS" + CRLF
		cRet += "^FO513,758^GB265,0,4^FS" + CRLF

		cRet += "^FT463,1254^A0B,17,16^FH\^FD"+cTextoH1+"^FS" + CRLF
		cRet += "^FT492,1254^A0B,17,16^FH\^FD"+cTextoH2+"^FS" + CRLF
		cRet += "^FT540,1254^A0B,17,17^FH\^FDCódigo: B1_COD^FS" + CRLF
		cRet += "^FT563,1254^A0B,17,17^FH\^FDDescricao: B1_DESC^FS" + CRLF
		cRet += "^FT660,1254^A0B,17,17^FH\^FDPalavra de advertência: B1_XADVERT^FS" + CRLF
		cRet += "^FT685,1254^A0B,4,13^FH\^FDFrases de Perigo: FRASE_PERIGO^FS" + CRLF
		cRet += "^FT541,748^A0B,17,17^FH\^FDPictogramas:^FS" + CRLF
		cRet += "^FT587,1254^A0B,17,17^FH\^FDLote: PROD_LOTE^FS" + CRLF
		cRet += "^FT583,962^A0B,17,17^FH\^FDValidade: LOTE_VALID^FS" + CRLF
		cRet += "^FT709,748^A0B,4,13^FH\^FDFRASE_1_PRECAUCAO^FS" + CRLF

		IF Len(aPictosZB4) > 0
			cRet += "^FO537,606^GFA,02048,02048,00016,:Z64:"+aPictosZB4[1][2] + CRLF
		ELSE
			cRet += "^FO527,534^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 1
			cRet += "^FO537,493^GFA,02048,02048,00016,:Z64:"+aPictosZB4[2][2] + CRLF
		ELSE
			cRet += "^FO527,445^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 2
			cRet += "^FO537,380^GFA,02048,02048,00016,:Z64:"+aPictosZB4[3][2] + CRLF
		ELSE
			cRet += "^FO527,356^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 3
			cRet += "^FO537,267^GFA,02048,02048,00016,:Z64:"+aPictosZB4[4][2] + CRLF
		ELSE
			cRet += "^FO527,268^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 4
			cRet += "^FO537,154^GFA,02048,02048,00016,:Z64:"+aPictosZB4[5][2] + CRLF
		ELSE
			cRet += "^FO527,173^GB90,90,2^FS" + CRLF
		ENDIF

		IF Len(aPictosZB4) > 5
			cRet += "^FO537,42^GFA,02048,02048,00016,:Z64:"+aPictosZB4[6][2] + CRLF
		ELSE
			cRet += "^FO527,88^GB90,90,2^FS" + CRLF
		ENDIF

		cRet += "^FT800,1254^A0B,17,16^FH\^FD"+cTextoR1+" "+VarControl+"^FS" + CRLF
		cRet += "^FT614,1254^A0B,17,17^FH\^FDIdentidade Química: B1_XNOMONU^FS" + CRLF
		cRet += "^FT639,1254^A0B,17,17^FH\^FDCONTINUACAO_XOBS^FS" + CRLF
		cRet += "^FT709,1254^A0B,4,13^FH\^FDFRASE_1_PERIGO^FS" + CRLF
		cRet += "^FT732,1254^A0B,4,13^FH\^FDFRASE_2_PERIGO^FS" + CRLF
		cRet += "^FT757,1254^A0B,4,13^FH\^FDFRASE_3_PERIGO^FS" + CRLF
		cRet += "^FT733,748^A0B,4,13^FH\^FDFRASE_2_PRECAUCAO^FS" + CRLF
		cRet += "^FT757,748^A0B,4,13^FH\^FDFRASE_3_PRECAUCAO^FS" + CRLF
		cRet += "^FT685,748^A0B,4,13^FH\^FDFrases de Precaução: FRASE_PRECAUCAO^FS" + CRLF

		cRet += "^PQ1,0,1,Y^XZ" + CRLF


	//Substituição do Código e da Descrição do produto na etiqueta
	cRet := StrTran(cRet,"B1_COD",AllTrim(SB1->B1_COD))
	cRet := StrTran(cRet,"B1_DESC",AllTrim(SubStr(SB1->B1_DESC,1,40)))
	// ---

	//Substituição da continuação da descrição na etiqueta [Não está em uso verificar necessidade]
	If Len(AllTrim(SB1->B1_DESC)) > 40
		cRet := StrTran(cRet,"DESC_CONTINUACAO",AllTrim(SubStr(SB1->B1_DESC,41,40)))
	Else
		cRet := StrTran(cRet,"DESC_CONTINUACAO","")
	Endif
	// ---

	//Substituição dos dados do lote e da advertência na etiqueta
	cRet := StrTran(cRet,"PROD_LOTE",aPergs[2])
	cRet := StrTran(cRet,"LOTE_VALID",cDtValid)
	cRet := StrTran(cRet,"B1_XADVERT",IIf(AllTrim(SB1->B1_XADVERT) == "1","",IIf(AllTrim(SB1->B1_XADVERT) == "2","PERIGO","ATENÇÃO"))) 
	// ---                                                                                           

	//Substituição das frases de Observação da etiqueta
	If !Empty(SB1->B1_XNOMONU)
	
		cRet := StrTran(cRet,"B1_XNOMONU",AllTrim(SubStr(SB1->B1_XNOMONU,1,38)))
			
		If Len(AllTrim(SB1->B1_XNOMONU)) > 38
			cRet := StrTran(cRet,"CONTINUACAO_XOBS","-"+AllTrim(SubStr(SB1->B1_XNOMONU,39,90)))
		Else
			cRet := StrTran(cRet,"CONTINUACAO_XOBS","")
		Endif
		
	Else
		cRet := StrTran(cRet,"B1_XNOMONU","")
		cRet := StrTran(cRet,"CONTINUACAO_XOBS","")
	Endif
	// ---

	//Substituição de caracteres das frases de Perigo e Precaução da etiqueta
	// If lZM400 //Tratativa para impressora ZM400

		For nX := 1 To 2

			If nX == 1 
				cRet := StrTran(cRet,"FRASE_PERIGO",AllTrim(SubStr(cFrasesH,1,69)))
			Else 
				cRet := StrTran(cRet,"FRASE_PRECAUCAO",AllTrim(SubStr(cFrasesP,1,86)))
			Endif 

			IF Len(AllTrim(cFrasesP)) > 86 .Or. Len(AllTrim(cFrasesH)) > 69

				If nX == 1
					cRet := StrTran(cRet,"FRASE_1_PERIGO",AllTrim(SubStr(cFrasesH,70,82)))
				Else 
					cRet := StrTran(cRet,"FRASE_1_PRECAUCAO",AllTrim(SubStr(cFrasesP,86,108)))
				Endif 

			Else 
				cRet := StrTran(cRet,IIF(nX=1,"FRASE_1_PERIGO","FRASE_1_PRECAUCAO"),"")		
			Endif 

			If Len(AllTrim(cFrasesP)) > 174 .Or. Len(AllTrim(cFrasesH)) > 152

				If nX == 1
					cRet := StrTran(cRet,"FRASE_2_PERIGO",AllTrim(SubStr(cFrasesH,153,82)))
				Else 
					cRet := StrTran(cRet,"FRASE_2_PRECAUCAO",AllTrim(SubStr(cFrasesP,194,108)))
				Endif 

			Else
				cRet := StrTran(cRet,IIF(nX=1,"FRASE_2_PERIGO","FRASE_2_PRECAUCAO"),"")
			Endif 

			If Len(AllTrim(cFrasesP)) > 272 .Or. Len(AllTrim(cFrasesH)) > 235

				If nX == 1
					cRet := StrTran(cRet,"FRASE_3_PERIGO",AllTrim(SubStr(cFrasesH,236,82)))
				Else
					cRet := StrTran(cRet,"FRASE_3_PRECAUCAO",AllTrim(SubStr(cFrasesP,302,108)))
				Endif 

			Else
				cRet := StrTran(cRet,IIF(nX=1,"FRASE_3_PERIGO","FRASE_3_PRECAUCAO"),"")
			Endif 

			If Len(AllTrim(cFrasesP)) > 370 .Or. Len(AllTrim(cFrasesH)) > 318

				If nX == 1
					cRet := StrTran(cRet,"FRASE_4_PERIGO",AllTrim(SubStr(cFrasesH,319,88)))
				Else
					cRet := StrTran(cRet,"FRASE_4_PRECAUCAO",AllTrim(SubStr(cFrasesP,410,108)))
				Endif 

			Else
				cRet := StrTran(cRet,IIF(nX=1,"FRASE_4_PERIGO","FRASE_4_PRECAUCAO"),"")
			Endif 

		Next nX		

	//Conversão dos caracteres da etiqueta
	cRet := Conversao(cRet)
	// ---

	//Gravação do arquivo de log da formação da etiqueta
	MemoWrite(GetTempPath()+"\XCAVETQ1.txt",cRet)
	// ---

	//Tratativa da quantidade de etiquetas para impressão
	If aPergs[3] == 0

		nQtde := 1

	Else 

		nQtde := aPergs[3]

	Endif 
	// ---

	For nX := 1 To nQtde

		MSCBPrinter(cModelo,cPorta,,,.F.,,,,,,.T.)
		MSCBChkStatus(.F.)
		MSCBBegin(1,6)
		MSCBWrite(cRet)
		MSCBEnd()
		MSCBClosePrinter()

	Next nX 

Return(cRet)

/*=================================================================
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 13/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Função que gera os arquivos contendo os strings que compoem 
cada etiqueta
*==================================================================*/
Static Function GeraArqEtq(cStrEtiq)

	Local cArqNovo := GetNextAlias()
	Local nHdlNovo

	cArqNovo := AllTrim(cArqNovo) + ".txt"
	nHdlNovo := FWFILEWRITER():New(_cDir + cArqNovo,.T.)
	
	If !nHdlNovo:Create()
		MsgAlert("O arquivo de nome "+_cDir+cArqNovo+" nao pode ser criado!!!","Atencao")
	Endif
	
	If !nHdlNovo:Write(cStrEtiq)
		MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
	
	aAdd(aArqGerados, _cDir + cArqNovo)

	nHdlNovo:Close()

Return

/*=================================================================
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 13/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Conversão de caracteres do texto
*==================================================================*/
Static Function PergParam(aRet)

	Local aPergs   := {}
	Local cProduto := Space(TamSX3("B1_COD")[1])
	Local cLote    := Space(TamSX3("B8_LOTECTL")[1])
	Local nQtde    := 0
	Local lRet     := .F.

	aAdd( aPergs ,{1,"Produto : ",cProduto,"@!",'.T.','SB1','.T.',50,.F.})   
	aAdd( aPergs ,{1,"Lote : ",cLote,"@!",'.T.','','.T.',50,.F.}) 
	aAdd( aPergs ,{1,"Qtde : ",nQtde,"@E 9,999","Positivo()","",".T.",50,.F.})

	If ParamBox(aPergs ,"Parametros ",aRet)      
		lRet := .T.   
	Endif

Return(lRet)

/*=================================================================
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 13/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Conversão de caracteres do texto
*==================================================================*/
Static Function Conversao(cTexto)

	Local cRet := cTexto

	cRet := StrTran(cRet,"á","\A0")
	cRet := StrTran(cRet,"é","\82")
	cRet := StrTran(cRet,"í","\A1")
	cRet := StrTran(cRet,"ó","\A2")
	cRet := StrTran(cRet,"ú","\A3")
	cRet := StrTran(cRet,"Á","\B5")
	cRet := StrTran(cRet,"É","\90")
	cRet := StrTran(cRet,"Í","\D6")
	cRet := StrTran(cRet,"Ó","\E3")
	cRet := StrTran(cRet,"Ú","\E9")

	cRet := StrTran(cRet,"ã","\C6")
	cRet := StrTran(cRet,"õ","\E4")
	cRet := StrTran(cRet,"Ã","\C7")
	cRet := StrTran(cRet,"Õ","\E5")

	cRet := StrTran(cRet,"â","\83")
	cRet := StrTran(cRet,"ê","\88")
	cRet := StrTran(cRet,"ô","\93")
	cRet := StrTran(cRet,"Â","\B6")
	cRet := StrTran(cRet,"Ê","\D2")
	cRet := StrTran(cRet,"Ô","\E2")

	cRet := StrTran(cRet,"ç","\87")    
	cRet := StrTran(cRet,"Ç","\80")

	cRet := StrTran(cRet,"®","\A9")
	cRet := StrTran(cRet,"à","\85")
	cRet := StrTran(cRet,"À","\B7")

Return(cRet)

/*=================================================================
Autor: Pedro Vilas Boas / Vinicius N. de Oliveira
Data: 13/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Validação do Lote
*==================================================================*/
Static Function ExistLote(cLote)

	Local lRet   := .F.
	Local cQuery := ""

	cQuery := "SELECT * FROM "+RetSQLName("SB8")+" WHERE D_E_L_E_T_ = '' AND B8_LOTECTL = '"+AllTrim(cLote)+"' "

	If Select("TMPSB8") > 0
		TMPSB8->(DbCloseArea())
	Endif

	DbUseArea( .T., "TOPCONN",TcGenQry( ,, cQuery ), "TMPSB8", .T., .F. )

	lRet := TMPSB8->(!EOF())

	TMPSB8->(DbCloseArea())
	
Return(lRet)
