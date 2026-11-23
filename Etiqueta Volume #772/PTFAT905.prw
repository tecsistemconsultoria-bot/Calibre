#INCLUDE"totvs.ch"




user function PTFAT905(cLocImp)
	Local lContinua := .T.
	If Empty(SF2->F2_CRVVOLD)
		If !FwAlertYesNo("Etiqueta ja foi impressa em " + Dtoc(SF2->F2_CRVVOLD) + " as " + SF2->F2_CRVVOLT + "h. Deseja reimprimi-la ?","Etiqueta já impressa")
			lContinua := .F.
		else
			RecLock("SF2",.F.)
			SF2->F2_CRVVOLD := MsDate()
			SF2->F2_CRVVOLT := Time()
			MsUnLock("SF2")
		Endif
	Endif

	IF lContinua
		printEtq(cLocImp,SF2->F2_SERIE,SF2->F2_DOC)
	Endif

Return



static function printEtq(cLocImp,cSerie,cNF)
	Local aArea     := GetArea()
	Local cEmissao  := DtoC(MsDate()) + " - " + Time()
	Local nVol      := 0
	Local nTotVol   := 0
	Local cNReduz   := ""
	Local cNome     := ""
	Local cEnd      := ""
	Local cMun      := ""
	Local cUF       := ""
	Local cMsgNF    := ""
	Local aAux      := {}
	Local _i        := 0
	Local xI        := 0
	Local cNRTrans  := ""
	Local cNmTrans  := ""
	Local cCodeBar  := ""

	SF2->(DbSetOrder(1))
	SF2->(MsSeek(xFilial("SF2") + cNF + cSerie ))
	cDoc := cNF
	nTotVol := SF2->F2_VOLUME1
	cMsgNF := SF2->F2_MENNOTA
	IF SF2->F2_TIPO $ "D|B"
		SA2->(DbSetOrder(1))
		SA2->(MsSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA ))
		cNReduz := Alltrim(SA2->A2_NREDUZ)
		cNome   := Alltrim(SA2->A2_NOME)
	else
		SA1->(DbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ))
		cNReduz := Alltrim(SA1->A1_NREDUZ)
		cNome   := Alltrim(SA1->A1_NOME)
		cEnd    := Alltrim(SA1->A1_END) + " - " + TRANSFORM(SA1->A1_CEP, PESQPICT("SA1","A1_CEP"))
		cMun    := Alltrim(SA1->A1_MUN)
		cUF     := SA1->A1_EST
	endif

	SA4->(DbSetOrder(1))
	IF SA4->(MsSeek(xFilial("SA4") + SF2->F2_TRANSP ))
		If (SA4->A4_COD == '000029' .OR. SA4->A4_COD == '000249')
			cNRTrans := Alltrim(cNome) + "-" + Alltrim(SA4->A4_NREDUZ)
		Else
			cNRTrans := Alltrim(SA4->A4_NREDUZ)
		End if
		cNmTrans    := Alltrim(Left(SA4->A4_NOME,27))
	Endif


	IF CB5SetImp(cLocImp)
//
//		CB5->(DbSetOrder(1))
		//CB5->(MsSeek(xFilial("CB5") + cLocImp))

		For xI := 1 to nTotVol
			nVol++
			cCodeBar  := Strzero(xI,3) + Strzero(nTotVol,3) + cDoc

			//MSCBWrite("~SD25")	// Seta o Darkness
			/*
			IF "ZM400" $ CB5->CB5_DESCRI
				MSCBWrite("~TA-001") // Seta o posicionamento final da etiqueta em -1mm
			endif
			*/

			MSCBBEGIN(1,2)

			IF "ZM400" $ CB5->CB5_DESCRI
				MSCBWrite("^PW1248")	// Seta a largura da etiqueta
			else
				MSCBWrite("^PW820")	// Seta a largura da etiqueta
			endif
			MSCBWrite("^LL639")	// Seta a altura da etiqueta

			MSCBSAY(18,14,cEmissao,"N","Q","001,001")

			MSCBBOX(50,02,100,11,5)
			MSCBSAY(52.5,4,"NOTA","N","D","001,001")
			MSCBSAY(51.5,7,"FISCAL","N","D","001,001")
			MSCBSAY(61,02,AllTrim(cDoc),"N","V","001,001")

			IF "ZM400" $ CB5->CB5_DESCRI
				MSCBBOX(50,11,100,20,55)
			else
				MSCBBOX(50,11,100,20,50)
			endif
			MSCBSAY(53,13.5,"VOLUME","N","E","001,001",.T.)
			MSCBSAY(70,10.8,StrZero(nVol,3)+"/"+StrZero(nTotVol,3),"N","V","001,001",.T.)

			MSCBLineH(04,20,100,4)
			MSCBSAY(04,21,"DESTINO","N","E","001,001")
			MSCBSAY(04,24,cNReduz,"N","U","001,001")
			MSCBSAY(04,30.5,cNome,"N","S","001,001")
			MSCBSAY(04,35,cEnd,"N","R","001,001")
			MSCBSAY(04,39,cMun + " - " + cUF,"N","T","001,001")

			MSCBLineH(04,46,100,4)
			MSCBSAY(04,47,"INFORMACOES","N","E","001,001")
			aAux := zMemoToA(cMsgNF,54)
			For _i := 1 to Min(Len(aAux),3)
				MSCBSAY(04,46+(_i*4),aAux[_i],"N","R","001,001")
			Next

			MSCBLineH(04,64,100,4)
			MSCBSAY(04,65,"TRANSPORTADORA","N","E","001,001")
			MSCBSAY(04,68,cNRTrans,"N","R","001,001")
			MSCBSAY(04,72,cNmTrans,"N","R","001,001")

			IF "ZM400" $ CB5->CB5_DESCRI
				MSCBSAYBAR(065, 066,  cCodeBar,   "N",   "MB01",     12,         .F.,        .F.,        .F.,  			, 		,     )
			else
				MSCBSAYBAR(056, 066,  cCodeBar,   "N",   "MB01",     12,         .F.,        .F.,        .F.,  			, 	2	,  2  )
			endif

			MSCBEND()

		Next _i
		MSCBCLOSEPRINTER()

	else
		fwAlertError("Não foi possivel iniciar o Local de Impressão. Favor revisar os parametros informados","Local de Impressão Inválido")
	Endif


	RestArea(aArea)
Return


static Function zMemoToA(cTexto, nMaxCol, cQuebra, lTiraBra)
	Local aArea     := GetArea()
	Local aTexto    := {}
	Local aAux      := {}
	Local nAtu      := 0
	Default cTexto  := ''
	Default nMaxCol := 80
	Default cQuebra := ';'
	Default lTiraBra:= .T.

	//Quebrando o Array, conforme -Enter-
	aAux:= StrTokArr(cTexto,Chr(13))

	//Correndo o Array e retirando o tabulamento
	For nAtu:=1 TO Len(aAux)
		aAux[nAtu]:=StrTran(aAux[nAtu],Chr(10),'')
	Next

	//Correndo as linhas quebradas
	For nAtu:=1 To Len(aAux)

		//Se o tamanho de Texto, for maior que o número de colunas
		If (Len(aAux[nAtu]) > nMaxCol)

			//Enquanto o Tamanho for Maior
			While (Len(aAux[nAtu]) > nMaxCol)
				//Pegando a quebra conforme texto por parâmetro
				nUltPos:=RAt(cQuebra,SubStr(aAux[nAtu],1,nMaxCol))

				//Caso não tenha, a última posição será o último espaço em branco encontrado
				If nUltPos == 0
					nUltPos:=Rat(' ',SubStr(aAux[nAtu],1,nMaxCol))
				EndIf

				//Se não encontrar espaço em branco, a última posição será a coluna máxima
				If(nUltPos==0)
					nUltPos:=nMaxCol
				EndIf

				//Adicionando Parte da Sring (de 1 até a Úlima posição válida)
				aAdd(aTexto,SubStr(aAux[nAtu],1,nUltPos))

				//Quebrando o resto da String
				aAux[nAtu] := SubStr(aAux[nAtu], nUltPos+1, Len(aAux[nAtu]))
			EndDo

			//Adicionando o que sobrou
			aAdd(aTexto,aAux[nAtu])
		Else
			//Se for menor que o Máximo de colunas, adiciona o texto
			aAdd(aTexto,aAux[nAtu])
		EndIf
	Next

	//Se for para tirar os brancos
	If lTiraBra
		//Percorrendo as linhas do texto e aplica o AllTrim
		For nAtu:=1 To Len(aTexto)
			aTexto[nAtu] := Alltrim(aTexto[nAtu])
		Next
	EndIf

	RestArea(aArea)
Return aTexto
