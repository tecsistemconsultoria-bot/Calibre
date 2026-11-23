#INCLUDE "TOTVS.CH"

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+---------------+------------------------------------------------------------+
!Descricao      !Impressão de Etiqueta Rótulo.                               !
+---------------+------------------------------------------------------------+
!Autor          !Pedro Vilas Boas                                            !
+---------------+------------------------------------------------------------+
!Data de Criacao!12/2024                                                     !
+---------------+-----------------------------------------------------------*/

User Function xCavEtq2()
local aArea      := GetArea()
Local cRotina    := "XCAVETQ2_"+__cUserId
Local _cPathFile := "c:/etiquetas/"
Local aPergs     := {}

Private _cDir     := ""
Private cNomePC   := ComputerName()
Private cModZM400 := GetMV("XX_ZM400",.F.,"CARS0038")
//Private lZM400    := .F.

//Diretorio Raiz.
_cDir := _cPathFile 
If !ExistDir(_cDir)
	MakeDir(_cDir)
Endif

IF !PergParam(@aPergs)
	Return
ENDIF

sfEtiqueta(aPergs)

RestArea(aArea)

Return()


Static Function sfEtiqueta(aPergs)
Local cModelo	:= "ZEBRA" // Alltrim(aPergs[3])//"ZEBRA"
Local cPorta	:= "LPT1"  //Alltrim(aPergs[4]) // Mapeamento feito através de NET USE
Local cStrEtiq  := ""


Private aArqGerados := {}

cStrEtiq := ""

cStrEtiq := sfStrEtiq(aPergs,cModelo,cPorta)

// Grava os arquivos com as strings das etiquetas
IF !EMPTY(cStrEtiq)
	GeraArqEtq(cStrEtiq)
ENDIF

Return()


// Gera a string com a etiqueta a ser enviada para a impressora Zebra. A string contém código ZPL
Static Function sfStrEtiq(aPergs,cModelo,cPorta)

Local cRet  := ""
Local nX    := 0
Local lLote := .F.

SB1->(DbSetOrder(1))

IF !SB1->(DbSeek(xFilial("SB1")+aPergs[1]))
	Alert("Produto não encontrado")
	Return cRet
Else 

	lLote := IIf(SB1->B1_RASTRO <> "N",.T.,.F.)

ENDIF

If lLote

	SB8->(DbSetOrder(5))

	If !SB8->(DbSeek(xFilial("SB8")+aPergs[1]+aPergs[2]))

		If !ExistLote(aPergs[2])
			Alert("ATENCAO: Este lote de produto nao existe!")
		Else
			Alert("ATENCAO: Este lote nao pertence a este produto!")
		Endif

		Return cRet

	Endif

Endif 

cLogoFab := AllTrim(SB1->B1_FABRIC)

cDtValid := DTOC(SB8->B8_DTVALID)

//Identifico se a impressora Zebra é a ZM400 para seguir com o layout da etiqueta
/*If (cNomePC) $ cModZM400
	lZM400 := .T.
Endif*/

//Criação da string das etiquetas
/*If lZM400

	//cRet += "CT~~CD,~CC^~CT~" + CRLF
	//cRet += "^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR2,2~SD15^JUS^LRN^CI0^XZ" + CRLF
	cRet += "^XA" + CRLF
	cRet += "^MMT" + CRLF
	cRet += "^PW744" + CRLF
	cRet += "^LL0295" + CRLF
	cRet += "^LS0" + CRLF
	cRet += "^FO11,12^GB724,273,2^FS" + CRLF
	cRet += "^FT25,43^A0N,17,16^FH\^FDC\A2digo: B1_COD^FS" + CRLF
	cRet += "^FT25,64^A0N,17,16^FH\^FDDescri\87\C6o: B1_DESC^FS" + CRLF
	cRet += "^FT25,85^A0N,17,16^FH\^FDCONTINUACAO_DESC^FS" + CRLF
	cRet += "^FT25,122^A0N,17,16^FH\^FDObserva\87\E4es: B1_XOBS^FS" + CRLF
	cRet += "^FT25,143^A0N,17,16^FH\^FDCONTINUACAO_OBS^FS" + CRLF
	cRet += "^FT25,184^A0N,17,16^FH\^FDLote: PROD_LOTE^FS" + CRLF
	cRet += "^FT367,184^A0N,17,16^FH\^FDValidade: LOTE_VALID^FS" + CRLF
	cRet += "^FT25,226^A0N,17,16^FH\^FDFabricante: B1_FABRIC^FS" + CRLF
	cRet += "^FT25,249^A0N,17,16^FH\^FDOrigem: B1_CRVPROC^FS" + CRLF

	If Len(cLogoFab) < 7
		cRet += "^FT580,250^A0N,25,25^FH\^FD"+cLogoFab+"^FS"
	Else
		cRet += "^FT380,250^A0N,25,25^FH\^FD"+cLogoFab+"^FS"
	Endif 

	cRet += "^PQ1,0,1,Y^XZ" + CRLF

Else */

	//ZT230 
	//cRet := ""
	//cRet += "CT~~CD,~CC^~CT~"+ CRLF
	//cRet += "^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ"+ CRLF
	cRet += "^XA" + CRLF
	cRet += "^MMT" + CRLF
	cRet += "^PW519" + CRLF
	cRet += "^LL0200" + CRLF
	cRet += "^LS0" + CRLF
	cRet += "^FO21,15^GB498,154,1^FS" + CRLF
	cRet += "^FT30,32^AAN,11,5^FH\^FDC\A2digo: B1_COD^FS" + CRLF
	cRet += "^FT30,44^AAN,11,5^FH\^FDDescri\87\C6o: B1_DESC^FS" + CRLF
	cRet += "^FT30,59^AAN,11,5^FH\^FDCONTINUACAO_DESC^FS" + CRLF
	cRet += "^FT30,84^AAN,11,5^FH\^FDObserva\87\E4es: B1_XOBS^FS" + CRLF
	cRet += "^FT30,94^AAN,11,5^FH\^FDCONTINUACAO_OBS^FS" + CRLF
	cRet += "^FT30,119^AAN,11,5^FH\^FDLote: PROD_LOTE^FS" + CRLF
	cRet += "^FT290,119^AAN,11,5^FH\^FDValidade: LOTE_VALID^FS" + CRLF
	cRet += "^FT30,144^AAN,11,5^FH\^FDFabricante: B1_FABRIC^FS" + CRLF
	cRet += "^FT30,159^AAN,11,5^FH\^FDOrigem: B1_CRVPROC^FS" + CRLF

	If Len(cLogoFab) < 7
		cRet += "^FT290,162^A0N,25,25^FH\^FD"+cLogoFab+"^FS"  + CRLF
	Else
		cRet += "^FT290,162^A0N,25,25^FH\^FD"+cLogoFab+"^FS"  + CRLF
	Endif 

	cRet += "^PQ1,0,1,Y^XZ" + CRLF

//Endif 
// ---

/*If lZM400
	cRet := STRTRAN(cRet,"B1_COD",Alltrim(SB1->B1_COD))
	cRet := STRTRAN(cRet,"B1_DESC",Alltrim(SUBSTR(SB1->B1_DESC,1,40)))
//Else*/
	cRet := STRTRAN(cRet,"B1_COD",Alltrim(SB1->B1_COD))
	cRet := STRTRAN(cRet,"B1_DESC",Alltrim(SUBSTR(SB1->B1_DESC,1,68)))
//Endif

//If lZM400
/*
	If len(Alltrim(SB1->B1_DESC)) > 40
		cRet := STRTRAN(cRet,"CONTINUACAO_DESC",Alltrim(SUBSTR(SB1->B1_DESC,41,40)))
	Else
		cRet := STRTRAN(cRet,"CONTINUACAO_DESC","")
	Endif 

Else*/

	If len(Alltrim(SB1->B1_DESC)) > 68
		cRet := STRTRAN(cRet,"CONTINUACAO_DESC",Alltrim(SUBSTR(SB1->B1_DESC,69,79)))
	Else
		cRet := STRTRAN(cRet,"CONTINUACAO_DESC","")
	Endif 

//Endif

If lLote
	cRet := STRTRAN(cRet,"PROD_LOTE",aPergs[2])
	cRet := STRTRAN(cRet,"LOTE_VALID",cDtValid)
Else
	cRet := STRTRAN(cRet,"PROD_LOTE","")
	cRet := STRTRAN(cRet,"LOTE_VALID","  /  /    ")
Endif 


/*If lZM400

	cRet := STRTRAN(cRet,"B1_XOBS",Alltrim(SUBSTR(SB1->B1_XOBS,1,40)))

	If len(Alltrim(SB1->B1_XOBS)) > 40
		cRet := STRTRAN(cRet,"CONTINUACAO_OBS",Alltrim(SUBSTR(SB1->B1_XOBS,41,40)))
	Else
		cRet := STRTRAN(cRet,"CONTINUACAO_OBS","")
	Endif 

Else*/

	cRet := STRTRAN(cRet,"B1_XOBS",Alltrim(SUBSTR(SB1->B1_XOBS,1,68)))

	If len(Alltrim(SB1->B1_XOBS)) > 68
		cRet := STRTRAN(cRet,"CONTINUACAO_OBS",Alltrim(SUBSTR(SB1->B1_XOBS,69,79)))
	Else
		cRet := STRTRAN(cRet,"CONTINUACAO_OBS","")
	Endif 

//Endif 

cRet := STRTRAN(cRet,"B1_FABRIC",Alltrim(SB1->B1_FABRIC))
cRet := STRTRAN(cRet,"B1_CRVPROC",Alltrim(SB1->B1_CRVPROC))

cRet := Conversao(cRet)

memowrite(GetTempPath()+"\XCAVETQ2.txt",cRet)
//SHOWLOG(cRet)
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

// Função que gera os arquivos contendo os strings que compoem cada etiqueta
Static Function GeraArqEtq (cStrEtiq)
Local cArqNovo := GetNextAlias()
Local nHdlNovo


cArqNovo := Alltrim(cArqNovo) + ".txt"
nHdlNovo := FWFILEWRITER():New(_cDir + cArqNovo,.T.)
If !nHdlNovo:Create()
	MsgAlert("O arquivo de nome "+_cDir+cArqNovo+" nao pode ser criado!!!","Atencao")
Endif
If !nHdlNovo:Write(cStrEtiq)
	MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
Endif
aAdd(aArqGerados, _cDir + cArqNovo)
nHdlNovo:Close()

Return()

Static Function PergParam(aRet)
Local aPergs := {}
Local cProduto := Space(TamSX3("B1_COD")[1])
Local cLote    := Space(TamSX3("B8_LOTECTL")[1])
Local nQtde    := 0
Local dValidade:= STOD('')
Local cModelo  := "ZEBRA"+Space(10)
Local cPort    := "LPT1"+Space(10)
Local lRet     := .F.

aAdd( aPergs ,{1,"Produto : ",cProduto,"@!",'.T.','SB1','.T.',50,.F.})   
aAdd( aPergs ,{1,"Lote : ",cLote,"@!",'.T.','','.T.',50,.F.})
aAdd( aPergs ,{1,"Qtde : ",nQtde,"@E 9,999","Positivo()","",".T.",50,.F.})

If ParamBox(aPergs ,"Parametros ",aRet)      
	lRet := .T.   
EndIf

Return lRet 


Static Function Conversao(cTexto)
Local cRet := cTexto

cRet := STRTRAN(cRet,"á","\A0")
cRet := STRTRAN(cRet,"é","\82")
cRet := STRTRAN(cRet,"í","\A1")
cRet := STRTRAN(cRet,"ó","\A2")
cRet := STRTRAN(cRet,"ú","\A3")
cRet := STRTRAN(cRet,"Á","\B5")
cRet := STRTRAN(cRet,"É","\90")
cRet := STRTRAN(cRet,"Í","\D6")
cRet := STRTRAN(cRet,"Ó","\E3")
cRet := STRTRAN(cRet,"Ú","\E9")

cRet := STRTRAN(cRet,"ã","\C6")
cRet := STRTRAN(cRet,"õ","\E4")
cRet := STRTRAN(cRet,"Ã","\C7")
cRet := STRTRAN(cRet,"Õ","\E5")

cRet := STRTRAN(cRet,"â","\83")
cRet := STRTRAN(cRet,"ê","\88")
cRet := STRTRAN(cRet,"ô","\93")
cRet := STRTRAN(cRet,"Â","\B6")
cRet := STRTRAN(cRet,"Ê","\D2")
cRet := STRTRAN(cRet,"Ô","\E2")

cRet := STRTRAN(cRet,"ç","\87")    
cRet := STRTRAN(cRet,"Ç","\80")

cRet := STRTRAN(cRet,"®","\A9")
cRet := STRTRAN(cRet,"à","\85")
cRet := STRTRAN(cRet,"À","\B7")

Return cRet


Static Function ExistLote(cLote)
Local lRet   := .F.
Local cQuery := ""

cQuery := "Select * From "+RetSqlname("SB8")+" WHERE D_E_L_E_T_ = '' AND B8_LOTECTL = '"+Alltrim(cLote)+"' "

IF SELECT("TMPSB8") > 0
	TMPSB8->(DbCloseArea())
ENDIF

dbUseArea( .T., "TOPCONN",TcGenQry( ,, cQuery ), "TMPSB8", .T., .F. )

lRet := TMPSB8->(!EOF())

TMPSB8->(DbCloseArea())
Return lRet
