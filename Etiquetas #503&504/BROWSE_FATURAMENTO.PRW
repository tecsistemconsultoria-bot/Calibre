#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Protheus.ch"

Static __lFilNaoImp := .F.
Static __aFilBrw   := {}

// Fernando Pessoa - Tecsistem - 20/05/2026 - Aplica filtro default no FWBrowse ativo
Static Function BfwAplFilFW(cFilt, lRefresh)

Local oFwBrw := Nil
Local oSub   := Nil
Local lOk    := .F.

DEFAULT lRefresh := .T.

If !FindFunction("FWmBrwActive")
	Return .F.
EndIf

oFwBrw := FWmBrwActive()
If ValType(oFwBrw) != "O" .Or. oFwBrw == Nil
	Return .F.
EndIf

BEGIN SEQUENCE
	oFwBrw:SetFilterDefault(cFilt)
	If lRefresh
		BEGIN SEQUENCE
			oSub := oFwBrw:oBrowse
			If ValType(oSub) == "O" .And. oSub <> Nil
				oSub:Refresh(.T.)
			Else
				oFwBrw:Refresh(.T.)
			EndIf
		RECOVER
			oFwBrw:Refresh(.T.)
		END SEQUENCE
	EndIf
	lOk := .T.
RECOVER
	lOk := .F.
END SEQUENCE

Return lOk

// Fernando Pessoa - Tecsistem - 20/05/2026 - Remove filtro do FWBrowse (sem manter flag de filtro ativo)
Static Function BfwLimpaFilFW(lRefresh)

Local oFwBrw := Nil
Local oSub   := Nil
Local lOk    := .F.

DEFAULT lRefresh := .T.

If !FindFunction("FWmBrwActive")
	Return .F.
EndIf

oFwBrw := FWmBrwActive()
If ValType(oFwBrw) != "O" .Or. oFwBrw == Nil
	Return .F.
EndIf

BEGIN SEQUENCE
	oFwBrw:SetFilterDefault("")
	lOk := .T.
RECOVER
END SEQUENCE

BEGIN SEQUENCE
	oFwBrw:ClearFilter(0)
	lOk := .T.
RECOVER
END SEQUENCE

If lRefresh
	BEGIN SEQUENCE
		oSub := oFwBrw:oBrowse
		If ValType(oSub) == "O" .And. oSub <> Nil
			oSub:Refresh(.T.)
		Else
			oFwBrw:Refresh(.T.)
		EndIf
	RECOVER
		BEGIN SEQUENCE
			oFwBrw:Refresh(.T.)
		RECOVER
		END SEQUENCE
	END SEQUENCE
EndIf

Return lOk

/*
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ?пїЅпїЅ
пїЅпїЅпїЅPrograma  пїЅBRWSF2   пїЅAutor  пїЅValerio Precht      пїЅ Data пїЅ  09/01/10    пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ?пїЅпїЅ
пїЅпїЅпїЅDesc.     пїЅ  mBrowse da SF2 com diversas funcoes de apoio              пїЅпїЅпїЅ
пїЅпїЅпїЅ          пїЅ                                                            пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ?пїЅпїЅ
пїЅпїЅпїЅUso       пїЅ AP                                                        пїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ?пїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
*/

User Function BRWSF2()

Private cCadastro := "Atualiza pesos e volumes"        

// VERMELHO - Aguardando informaпїЅпїЅo de volume
// AMARELO - Volume setado, Aguardando impressao de etiqueta
// OUTRA_COR? -> Volume setado, etiqueta impressa aguardando envio SAC
// VERDE - Volume setado, etiqueta impressa e SAC ENVIADO

aCores  := {      { 'F2_VOLUME1 = 0 ','BR_VERMELHO' 																		},;
				  { 'F2_VOLUME1 > 0 .and. F2_CRVVOLD =  Ctod("  /  /  ")','BR_AMARELO' 										},;                                  
				  { 'F2_VOLUME1 > 0 .and. F2_CRVVOLD <> Ctod("  /  /  ")','BR_VERDE'                                     	}}                  


//aCores  := {      { 'F2_VOLUME1 = 0 ','BR_VERMELHO' 																		},;
//				  { 'F2_VOLUME1 > 0 .and. F2_CRVVOLD =  Ctod("  /  /  ")','BR_AMARELO' 										},;                  
//				  { 'F2_VOLUME1 > 0 .and. F2_CRVVOLD <> Ctod("  /  /  ") .and. F2_CRVSACD =  Ctod("  /  /  ")','BR_AZUL' 	},;                 
//				  { 'F2_VOLUME1 > 0 .and. F2_CRVVOLD <> Ctod("  /  /  ") .and. F2_CRVSACD <> Ctod("  /  /  ")','BR_VERDE' 	}}                  




// Fernando Pessoa - Tecsistem - 19/05/2026 - Browse Faturamento: filtro e impressao DANFE/certificado
Private aRotina		:= {{ "Pesquisa   "  ,"AxPesqui"    ,0,1},;
						{ "Visualiza  "  ,"AxVisual"    ,0,2},;
						{ "Filtrar NFs nao Impressas" ,"U_BFWPEND" ,0,1},;
						{ "Mostrar todas as NFs"      ,"U_BFWTODAS",0,1},;
						{ "Informa vol"  ,"U_INFVOL1"  	,0,6},; 
						{ "Imprime Etiq" ,"U_ETIQ_VOL" 	,0,6},;
						{ "Envia SAC"    ,"U_EnviaSAC" 	,0,6},;
						{ "Legenda"      ,"U_LEGVOL1"   ,0,6}}

Private cDelFunc := ".T." 
Private cString := "SF2"  


dbSelectArea("SF2")
dbSetOrder(3)

Public cModZebra := "000001" //u_modzebra()

IF cFilAnt == "01"
	aADD(aRotina,{ "Imprime Etq Nova" ,"U_PTFAT905(cModZebra)" 	,0,6})
	//aADD(aRotina,{ "Teste" ,"U_PTFAT904" 	,0,3})
Endif

aAdd(aRotina,{ "Imprimir DANFE", "U_BFWDANFE", 0, 6 })          // Fernando Pessoa - Tecsistem - 19/05/2026
aAdd(aRotina,{ "Impressao Certificados", "U_BFWCERT", 0, 6 }) // Fernando Pessoa - Tecsistem - 19/05/2026

mBrowse( 6,1,22,75,'SF2',,,,,,aCores)

BfwFimFil(.F.)

Return

// Fernando Pessoa - Tecsistem - 19/05/2026
User Function BFWDANFE()

Local aArea := GetArea()
Private aFilBrw := {}
Private aIndArq := {}
Private bFiltraBrw

BEGIN SEQUENCE
	SpedDanfe()
RECOVER
END SEQUENCE

RestArea(aArea)

If BfwFilAtivo()
	BfwPosImpPend()
EndIf

Return .T.

// Fernando Pessoa - Tecsistem - 19/05/2026
User Function BFWCERT()

Local aArea := GetArea()

BEGIN SEQUENCE
	U_CVFATA06()
RECOVER
END SEQUENCE

RestArea(aArea)

Return .T.

// Fernando Pessoa - Tecsistem - 19/05/2026
User Function BFWPEND()

If !BfwTemPendImp()
	MsgInfo("Nao existem notas pendentes de impressao","Filtro")
	Return .T.
EndIf

BfwSetFilAtivo(.T.)
FWMsgRun(, {|| BfwAplFil()}, "Aguarde", "Filtrando Pendentes de impressao")

Return .T.

User Function BFWTODAS()

Local aArea := GetArea()

dbSelectArea("SF2")

BfwSetFilAtivo(.F.)
FWMsgRun(, {|| BfwAplFil()}, "Aguarde", "Carregando todas as notas...")

RestArea(aArea)

Return .T.

User Function BFWFLTR()

Local lNovo := !BfwFilAtivo()

If lNovo .And. !BfwTemPendImp()
	MsgInfo("Nao existem notas pendentes de impressao","Filtro")
	Return .T.
EndIf

BfwSetFilAtivo(lNovo)
FWMsgRun(, {|| BfwAplFil()}, "Aguarde", IIf(lNovo, "Filtrando Pendentes de impressao", "Carregando todas as notas..."))

Return .T.

// Fernando Pessoa - Tecsistem - 19/05/2026 - Pendente = F2_CRVIMPD vazio
Static Function BfwEhPendImp()

Local lPend := .T.

dbSelectArea("SF2")

If SF2->(FieldPos("F2_CRVIMPD")) > 0
	lPend := lPend .And. Empty(SF2->F2_CRVIMPD)
EndIf

Return lPend

// Fernando Pessoa - Tecsistem - 20/05/2026 - Valida se existe ao menos uma nota pendente
Static Function BfwTemPendImp()

Local aArea  := GetArea()
Local lTem   := .F.
Local cQuery := ""
Local cAlias := GetNextAlias()

dbSelectArea("SF2")

If SF2->(FieldPos("F2_CRVIMPD")) == 0
	Return .F.
EndIf

If BfwEhSQL()
	cQuery := "SELECT TOP 1 R_E_C_N_O_ RECNO FROM " + RetSqlName("SF2")
	cQuery += " WHERE F2_FILIAL = '" + xFilial("SF2") + "'"
	cQuery += "   AND D_E_L_E_T_ <> '*'"
	cQuery += "   AND F2_CRVIMPD = ''"
	cQuery := ChangeQuery(cQuery)
	BEGIN SEQUENCE
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
		dbSelectArea(cAlias)
		lTem := !Eof()
		(cAlias)->(DbCloseArea())
	RECOVER
		lTem := .F.
		IF Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
	END SEQUENCE
Else
	BEGIN SEQUENCE
		dbSetOrder(3)
		dbGoTop()
		Do While !Eof()
			If BfwEhPendImp()
				lTem := .T.
				Exit
			EndIf
			dbSkip()
		EndDo
	RECOVER
		lTem := .F.
	END SEQUENCE
EndIf

dbSelectArea("SF2")

RestArea(aArea)

Return lTem

// Fernando Pessoa - Tecsistem - 20/05/2026 - Pos-impressao: mantГ©m pendentes ou volta para todos
Static Function BfwPosImpPend()

If !BfwFilAtivo()
	Return
EndIf

If BfwTemPendImp()
	FWMsgRun(, {|| BfwAplFil(.T.)}, "Aguarde", "Atualizando pendentes...")
Else
	BfwSetFilAtivo(.F.)
	FWMsgRun(, {|| BfwAplFil(.T.)}, "Aguarde", "Nao ha mais pendentes. Carregando todos...")
	MsgInfo("Nao existem mais notas pendentes de impressao. A tela sera recarregada com todos os registros.","Filtro")
EndIf

Return

// Fernando Pessoa - Tecsistem - 19/05/2026 - Ambiente com filtro SQL no servidor (TopConnect)
Static Function BfwEhSQL()

Local lRet := .F.
Local cRdd := ""

dbSelectArea("SF2")
cRdd := Upper(AllTrim(SF2->(RddName())))

If cRdd == "TOPCONN"
	Return .T.
EndIf

If Type("TcSrvType") != "U"
	lRet := !(Upper(AllTrim(TcSrvType())) == "CTREE")
EndIf

Return lRet

// Fernando Pessoa - Tecsistem - 20/05/2026 - Limpa estrutura de filtro FilBrowse
Static Function BfwFimFil(lLimpaFW)

DEFAULT lLimpaFW := .T.

// Limpa tambem o filtro default do FWBrowse (quando ativo)
If lLimpaFW
	BEGIN SEQUENCE
		BfwLimpaFilFW(.F.)
	RECOVER
	END SEQUENCE
EndIf

BEGIN SEQUENCE
	If FindFunction("EndFilBrw") .And. ValType(__aFilBrw) == "A" .And. Len(__aFilBrw) > 0
		EndFilBrw("SF2", __aFilBrw)
	EndIf
RECOVER
END SEQUENCE

__aFilBrw := {}

dbSelectArea("SF2")
dbClearFilter()

Return

// Fernando Pessoa - Tecsistem - 19/05/2026 - Filtro @ (campos logicos F2_* = SQL rapido no banco)
Static Function BfwFiltAt(lPendente)

Local cFil  := xFilial("SF2")
Local cFilt := ""

DEFAULT lPendente := .F.

If !lPendente
	Return ".T."
EndIf

cFilt := "@F2_FILIAL='" + cFil + "' AND D_E_L_E_T_ <> '*' AND F2_CRVIMPD = '' "

Return cFilt

// Fernando Pessoa - Tecsistem - 19/05/2026 - Monta expressao de filtro (pendentes de impressao)
Static Function BfwFiltExpr(lPendente)

Local cFiltro := ".T."

DEFAULT lPendente := .F.

If BfwEhSQL() .And. lPendente
	Return BfwFiltAt(.T.)
EndIf

If lPendente .And. SF2->(FieldPos("F2_CRVIMPD")) > 0
	cFiltro := "Empty(F2_CRVIMPD)"
EndIf

Return cFiltro

// Fernando Pessoa - Tecsistem - 19/05/2026 - mBrowse: filtro via FilBrowse (padrao TOTVS)
Static Function BfwAplFil(lRefresh)

Local cFilt := ".T."
Local cFiltFW := ".T."
Local lOk   := .F.

DEFAULT lRefresh := .T.

dbSelectArea("SF2")
dbSetOrder(3)

// Sem filtro: limpa tudo e reposiciona no inicio para evitar estado "arquivo vazio" no browse
If !BfwFilAtivo()
	BfwLimpaFilFW(.F.)
	BfwFimFil(.F.)
	BEGIN SEQUENCE
		dbSeek(xFilial("SF2"))
	RECOVER
		dbGoTop()
	END SEQUENCE
	If lRefresh
		If !BfwLimpaFilFW(.T.)
			BfwAtuGrd()
		EndIf
	EndIf
	Return
EndIf

If BfwFilAtivo() .And. SF2->(FieldPos("F2_CRVIMPD")) > 0
	cFilt := "F2_FILIAL == '" + xFilial("SF2") + "' .And. !Deleted() .And. Empty(F2_CRVIMPD)"
	cFiltFW := BfwFiltAt(.T.)
EndIf

// Prioriza filtro nativo do FWBrowse para manter consistencia em refreshes internos
If BfwAplFilFW(cFiltFW, lRefresh)
	Return
EndIf

// Fallback para mBrowse classico
BfwFimFil(.F.)

If BfwFilAtivo() .And. SF2->(FieldPos("F2_CRVIMPD")) > 0
	If FindFunction("FilBrowse")
		BEGIN SEQUENCE
			FilBrowse("SF2", @__aFilBrw, @cFilt, .F.)
			lOk := .T.
		RECOVER
			lOk := .F.
		END SEQUENCE
	Else
		lOk := .F.
	EndIf
EndIf

If !lOk .And. BfwFilAtivo() .And. SF2->(FieldPos("F2_CRVIMPD")) > 0
	dbSetFilter({|| BfwEhPendImp()},"Pendente impressao DANFE")
EndIf

Return

// Fernando Pessoa - Tecsistem - 19/05/2026 - Atualiza grade sem dbGoTop (evita varrer SF2 inteira)
Static Function BfwAtuGrd()

Local oBrw := Nil
Local oSub := Nil

dbSelectArea("SF2")

If FindFunction("FWmBrwActive")
	oBrw := FWmBrwActive()
EndIf

If (ValType(oBrw) != "O" .Or. oBrw == Nil) .And. FindFunction("GetObjBrow")
	oBrw := GetObjBrow()
EndIf

If ValType(oBrw) == "O" .And. oBrw <> Nil
	BEGIN SEQUENCE
		oBrw:Refresh(.F.)
	RECOVER
		BEGIN SEQUENCE
			oSub := oBrw:oBrowse
			If ValType(oSub) == "O" .And. oSub <> Nil
				oSub:Refresh(.F.)
			EndIf
		RECOVER
		END SEQUENCE
	END SEQUENCE
EndIf

Return

// Fernando Pessoa - Tecsistem - 19/05/2026 - Refresh do browse FW (objeto ja obtido)
Static Function BfwRefBrwObj(oFwBrw, lFull)

DEFAULT lFull := .F.

If ValType(oFwBrw) <> "O" .Or. oFwBrw == Nil
	Return
EndIf

dbSelectArea("SF2")
dbGoTop()

BEGIN SEQUENCE
	If ValType(oFwBrw:oBrowse) == "O"
		oFwBrw:oBrowse:Refresh(lFull)
	Else
		oFwBrw:Refresh(lFull)
	EndIf
RECOVER
END SEQUENCE

Return

// Fernando Pessoa - Tecsistem - 19/05/2026 - Reposiciona browse (fallback legado)
Static Function BfwRefBrw(lFull)

Local oFwBrw := Nil

DEFAULT lFull := .F.

If FindFunction("FWmBrwActive")
	oFwBrw := FWmBrwActive()
	If ValType(oFwBrw) == "O" .And. oFwBrw <> Nil
		BfwRefBrwObj(oFwBrw, lFull)
	EndIf
EndIf

Return

// Fernando Pessoa - Tecsistem - 19/05/2026
Static Function BfwFilAtivo()
Return __lFilNaoImp

Static Function BfwSetFilAtivo(lAtivo)
__lFilNaoImp := lAtivo
Return



////////////////////////////////////////////////
//       ATUALIZA VOLUME                      //
////////////////////////////////////////////////
USER FUNCTION INFVOL1()    

Local area   := GetArea()
Private _Ok := .F.
Private cPesoL  := SF2->F2_PLIQUI
Private cPesoB  := SF2->F2_PBRUTO
Private cVolume := SF2->F2_VOLUME1
Private nPesCub := fBuscaCPO("SZK",2,xFilial("SZK")+SF2->F2_DOC+SF2->F2_SERIE,"ZK_CUB")
Private cTransp := SF2->F2_TRANSP                                                                          
Private cNTran := Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")      
Private cEspec  := IIF(Empty(SF2->F2_ESPECI1),"CAIXA(S)",SF2->F2_ESPECI1) // "CAIXA(S)              "  // SF2->F2_ESPECI1 
Private cObs    := SF2->F2_CRVOBS 
Private cNF := SF2->F2_DOC + " / " + SF2->F2_SERIE                  
Private cCliente     
Private _NumNF :=SF2->F2_DOC
Private _SerNF :=SF2->F2_SERIE
Private _CodCli := SF2->F2_CLIENTE
Private _LjCli  :=   SF2->F2_LOJA
                        
If SF2->F2_VOLUME1 > 0
	If ! (MsgYesNo("JпїЅ foi informado volume/peso para esta nota. Tem certeza que deseja continuar?"  ))
       Return
    Endif
Endif

cCliente := SF2->F2_CLIENTE + "/" + SF2->F2_LOJA + " - "   

If SF2->F2_TIPO = 'B' .Or. SF2->F2_TIPO = 'D'
    Dbselectarea("SA2")
    Dbsetorder(1)
    Dbseek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA, .T.)
	cCliente +=  + SA2->A2_NOME
Else
    Dbselectarea("SA1")
    Dbsetorder(1)
    Dbseek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, .T.)
	cCliente +=  + SA1->A1_NOME
Endif

// Abre a janela na tela

BoxFrt(_NumNF,_SerNF,_CodCli,_LjCli)

// Caso o usuпїЅrio tenha fechado a janela sem preencher os dados...
While _Ok = .F.
	Alert ("Dados em branco, informe corretamente!")     
	BoxFrt(_NumNF,_SerNF,_CodCli,_LjCli)
Enddo

// Restaura o environment (ponteiros)
RestArea(area)  

Return    

Static Function BoxFrt(_NumNF,_SerNF,_CodCli,_LjCli)
Local oOK := LoadBitmap(GetResources(),'br_verde')
Local oNO := LoadBitmap(GetResources(),'br_vermelho')  
Local oTFont := TFont():New('Arial Rounded MT Bold',,18,,.T.)   
Local aBrowse	:= {}
Local cCotacao	:= ""
Local lGrava 	:= .T.
Local lGrvSimFr := .F.
Local bSair 	:= {|| BfwBxFSair(@_Ok,oDlg1) }
Local bGrava 	:= {|| BfwBxFGrav(lGrvSimFr,@lGrava,cCotacao,aBrowse,oBrwFrt:nAt,_NumNF,_SerNF,_CodCli,_LjCli) }
Local bSelTrans := {|| BfwBxFSelT(aBrowse,oBrwFrt:nAt,@cTransp,oGetTran,oTBtnOK,@cNTran,oNomTra,oPanSimFrt,oBrwFrt,oTBtnSelT,@lGrvSimFr) }
						//oTBtnAtFrt:Disable(),;
Local bSimFrete := {|| BfwBxFSimF(oGetPL,oGetPB,oVolum,oEspec,oGetTran,oTBtnOK,nPesCub,cPesoB,cVolume,@cCotacao,@aBrowse,oBrwFrt,oPanSimFrt,oTBtnSelT)}           


// Define os parametros para consulta SimFrete

DEFINE MSDIALOG oDlg1 TITLE "Dados sobre a Nota Fiscal" FROM 000, 000  TO 605, 855 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME                               
oDlg1:lEscClose := .F.
// Desenha a moldura da janela
//@ 005, 005 To 270,500 
//@ 005, 005 To 135,250


oSayNF  	:= TGet():New( 010,010,{|u| If( PCount() == 0, cNF, cNF := u ) },oDlg1,050,010,"@!",{|| },0,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"cNF",,,,,,,"Nota Fiscal",1 )
oSayDesCli  := TGet():New( 010,065,{|u| If( PCount() == 0, cCliente, cCliente := u ) },oDlg1,255,010,"@!",{|| },0,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"cCliente",,,,,,,"Cliente",1 )
oGetPesCub  := TGet():New( 010,325,{|u| If( PCount() == 0, nPesCub, nPesCub := u ) },oDlg1,050,010,"@e 999.9999",{|| },0,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"nPesCub",,,,,,,"Volume MпїЅ",1 )

oGetPL := TGet():New( 035,010,{|u| If( PCount() == 0, cPesoL, cPesoL := u ) },oDlg1,050,010,"@e 99,999.99",{||  },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cPesoL",,,,,,,"Peso Liquido",1 )
oGetPB := TGet():New( 035,065,{|u| If( PCount() == 0, cPesoB, cPesoB := u ) },oDlg1,050,010,"@e 99,999.99",{||  },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cPesoB",,,,,,,"Peso Bruto",1 )

oVolum := TGet():New( 060,010,{|u| If( PCount() == 0, cVolume, cVolume := u ) },oDlg1,050,010,"@e 99999",{||  },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cVolume",,,,,,,"Volumes",1 )
oEspec := TGet():New( 060,065,{|u| If( PCount() == 0, cEspec, cEspec := u ) },oDlg1,050,010,"@!",{||  },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cEspec",,,,,,,"Especie",1 )

oObs   := tMultiget():New(035,120,{| u | if( pCount() > 0, cObs := u, cObs )},oDlg1,300,037,,,,,,.T.,,,,,,,,,,,,"ObservaпїЅпїЅes",1)

oGetTran := TGet():New( 085,010,{|u| If( PCount() == 0, cTransp, cTransp := u ) },oDlg1,050,010,"@!",{|| ((Vazio() .or. (ExistCpo("SA4",,1) .and. VldTransp(cTransp)) .and. oNomTra:Refresh()) ) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cTransp",,,,,,,"Transportadora",1 )
oGetTran:cF3 := "SA4"
oNomTra  := TGet():New( 085,065,{|u| If( PCount() == 0, cNTran, cNTran := u ) },oDlg1,260,010,"@!",{|| },0,,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F.,,"cNTran",,,,,,,"Nome",1 )

oTBtnSelT  := TButton():New( 109, 010, "Seleciona Transp.",oDlg1,bSelTrans, 050,015,,,.F.,.T.,.F.,,.F.,,,.F. )
oTBtnAtFrt := TButton():New( 109, 065, "Consulta SIMFrete",oDlg1,bSimFrete, 050,015,,,.F.,.T.,.F.,,.F.,{|| cPesoB>0 .and. cVolume>0 .and. nPesCub>0 .and. Empty(cCotacao) .and. empty(SF2->F2_CHVNFE) },,.F. )
oTBtnSelT:Disable()
//oTBtnAtFrt:Disable()

oTBtnOK  := TButton():New( 109, 310, "Confirmar",oDlg1,bGrava, 050,015,,,.F.,.T.,.F.,,.F.,{|| cPesoB>0 .and. cPesoL>0 .and. !Empty(cEspec) .and. cPesoB>cPesoL  },,.F. )
oTBtnCan := TButton():New( 109, 370, "Cancelar" ,oDlg1,bSair , 050,015,,,.F.,.T.,.F.,,.F.,,,.F. )

// Se a NF ja foi transmitida, nпїЅo permite alterar nada nos dados
/*
*/
/*
IF !empty(SF2->F2_CHVNFE)
	oGetPL:Disable()
	oGetPB:Disable()
	oVolum:Disable()
	oEspec:Disable()
	oObs:Disable()
	oGetTran:Disable()
	oTBtnAtFrt:Disable()
	oTBtnOK:Disable()
Endif
*/
oPanSimFrt	:= tPanel():Create(oDlg1,125,010,"",oTFont,.F.,,CLR_WHITE,CLR_BLACK,410,170)

// Vetor com elementos do Browse
aBrowse := {{.F.,0,0,CtoD(""),CtoD(""),"",,,0} }

// Cria Browse
oBrwFrt := TCBrowse():New( 09 , 01, 408, 160,, {},{}, oPanSimFrt,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

oBrwFrt:AddColumn(TCColumn():New(""				,{|| If(aBrowse[oBrwFrt:nAt,01],oOK,oNO) },"@!",,,"CENTER",,.T.,.F.,,,,,))
oBrwFrt:AddColumn(TCColumn():New("Valor"		,{|| aBrowse[oBrwFrt:nAT,02] },"@E 999,999.99",,,"RIGHT",,.F.,.F.,,,,,))
oBrwFrt:AddColumn(TCColumn():New("Prazo"		,{|| aBrowse[oBrwFrt:nAT,03] },"@E 999",,,"CENTER",,.F.,.F.,,,,,))
oBrwFrt:AddColumn(TCColumn():New("% Custo"		,{|| aBrowse[oBrwFrt:nAT,09] },"@E 99.99%",,,"RIGHT",,.F.,.F.,,,,,))
oBrwFrt:AddColumn(TCColumn():New("Prev. Coleta"	,{|| aBrowse[oBrwFrt:nAt,04] },"",,,"CENTER",35,.F.,.F.,,,,,))
oBrwFrt:AddColumn(TCColumn():New("Prev. Entrega",{|| aBrowse[oBrwFrt:nAt,05] },"",,,"CENTER",40,.F.,.F.,,,,,))
oBrwFrt:AddColumn(TCColumn():New("Transportadora",{|| aBrowse[oBrwFrt:nAt,06] },"@!",,,"LEFT",,.F.,.F.,,,,,))

// Seta vetor para a browse
oBrwFrt:SetArray(aBrowse)

oPanSimFrt:Hide()
Activate Dialog oDlg1 Centered 

Return

Static Function BfwBxFSair(lOk,oDlg1)
	If MsgNoYes("Confirma o cancelamento?")
		lOk := .T.
		oDlg1:End()
	EndIf
Return .T.

Static Function BfwBxFGrav(lGrvSimFr,lGrava,cCotacao,aBrowse,nAt,_NumNF,_SerNF,_CodCli,_LjCli)
	If lGrvSimFr
		lGrava := GravAPI({cCotacao,aBrowse[nAt,08],aBrowse[nAt,02]})
	EndIf
	Gravar(_NumNF,_SerNF,_CodCli,_LjCli)
Return .T.

Static Function BfwBxFSelT(aBrowse,nAt,cTransp,oGetTran,oTBtnOK,cNTran,oNomTra,oPanSimFrt,oBrwFrt,oTBtnSelT,lGrvSimFr)
	If VldTransp(aBrowse[nAt,07])
		cTransp := aBrowse[nAt,07]
		oGetTran:Refresh()
		oTBtnOK:Enable()
		cNTran := aBrowse[nAt,06]
		oNomTra:Refresh()
		oPanSimFrt:Disable()
		oBrwFrt:Disable()
		oTBtnSelT:Disable()
		lGrvSimFr := .T.
	EndIf
Return .T.

Static Function BfwBxFSimF(oGetPL,oGetPB,oVolum,oEspec,oGetTran,oTBtnOK,nPesCub,cPesoB,cVolume,cCotacao,aBrowse,oBrwFrt,oPanSimFrt,oTBtnSelT)
	oGetPL:Disable()
	oGetPB:Disable()
	oVolum:Disable()
	oEspec:Disable()
	oGetTran:Disable()
	oTBtnOK:Disable()
	FWMsgRun(NIL, {|oSay| ExecAPI({nPesCub,cPesoB,cVolume,SF2->F2_VALBRUT},@cCotacao,@aBrowse) }, "Aguarde...", "Obtendo dados junto пїЅ SimFrete...")
	oBrwFrt:SetArray(aBrowse)
	oPanSimFrt:SetText(" CotaпїЅпїЅo " + cCotacao)
	oTBtnSelT:Enable()
	oPanSimFrt:Refresh()
	oPanSimFrt:Show()
Return .T.

//Static Function Gravar(oDlg1)  
Static Function Gravar(_NumNF,_SerNF,_CodCli,_LjCli)
   

IF cPesoL = 0 .OR. cPesoB = 0 .OR. cEspec = " "  //cVolume = 0 .OR.
	Alert ("Dados incompletos !")                       
	
	ElseIf cPesoL >= cPesoB
	Alert("Peso lпїЅquido maior ou igual ao Peso Bruto !")  
	
ELSE
	DBSelectArea("SF2")
	DBSetOrder(1) //F2_FILIAL+F2_DOC+f2_serie+f2_cliente+f2_loja+f2_formul +f2_tipo      
	dbSeek(xFilial("SF2")+_NumNF+_SerNF+_CodCli+_LjCli)  
	teste := "  "      
	cQuery := "UPDATE  "+RetSqlName("SF2")+" SET   "
	cQuery += " F2_PLIQUI = "+STR(cPesoL)+" , F2_PBRUTO = "+STR(cPesoB)+", "
	cQuery += " F2_VOLUME1 = "+STR(cVolume)+",F2_ESPECI1 = '"+cEspec+"' , F2_TRANSP = '"+cTransp+"' "
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND F2_FILIAL = '"+xFilial("SF2")+"'  AND F2_DOC = '"+_NumNF+"'  " 
	cQuery += "			AND F2_SERIE = '"+_SerNF+"'  AND F2_CLIENTE = '"+_CodCli+"' AND F2_LOJA = '"+_LjCli+"' " 
	teste:= " "
	TCSQLEXEC(cQuery)
								
	teste := " "
	Close(oDlg1)
	_Ok := .T.

ENDIF

Return


////////////////////////////////////////////////
//   LEGENDAS                                 //
////////////////////////////////////////////////
USER Function LEGVOL1() 

BrwLegenda(cCadastro, 'Situaзгo', {{"BR_VERDE"		 ,'Volume setado, etiqueta impressa e SAC enviado'},;
                                   {"BR_VERMELHO"    ,'Aguardando informaзгo de volume'},;
                                   {"BR_AMARELO"     ,'Volume setado, Aguardando impressao de etiqueta'},;
                                   {"BR_AZUL"        ,'Volume setado, etiqueta impressa aguardando envio SAC'}})
Return nil
                                                     




/////////////////////////////////////////////
// ALTERA TRANSPORTADORA SOMENTE NA NF     //
/////////////////////////////////////////////
User Function INFTRAN1()

Local nOpc := 0
Private cTransp := SF2->F2_TRANSP  

@ 000, 000 to 160, 450 Dialog oDlg Title 'Alteraзгo da transportadora '
@ 020,008 Say 'Transportadora'				 
@ 020,058 Get cTransp F3 'SA4' Valid ((Vazio() .or. ExistCpo("SA4",,1)) .and. VldTransp(cTransp) )  Size 050,05

Activate Dialog oDlg Centered On Init EnchoiceBar( oDlg, { || If( .t., nOpc := 1, nOpc := 0 ), If( nOpc == 1, oDlg:End() , Nil ) }, { || nOpc := 0, oDlg:End() },, )

If nOpc == 1
	RecLock('SF2',.f.)
    SF2->F2_TRANSP := cTransp
	SF2->(MsUnLock())
EndIf

Return                                           



Static Function VldTransp(_TRANSP)
Local lRetorno  := .T.                     
Local sData		:= DtoS(SF2->F2_EMISSAO)  
Local aVlTra	:= {}                   
teste := " "
If GETMV("MV_VLDPFME")               

	_cQry  :="	SELECT SD2.D2_COD        AS CODPRO,         "
	_cQry  +="	        SB1.B1_CRVPF 	 AS CRVPF,          "
	_cQry  +="	        SB1.B1_CRVME     AS CRVME,          "
	_cQry  +="	        SB1.B1_XLINHA    AS XLINHA         "
//	_cQry  +="	        SB1.B1_XCONTR    AS XCONTR          "
	//_cQry  +=" FROM SD2010 SD2 INNER JOIN SB1010 SB1 ON SD2.D2_FILIAL = SB1.B1_FILIAL AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_ = SB1.D_E_L_E_T_     "//ALTERADO DYEGO 09/07/14
	_cQry  +=" FROM SD2010 SD2 INNER JOIN SB1010 SB1 ON SB1.B1_FILIAL='"+XFILIAL("SB1")+"' AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_ = SB1.D_E_L_E_T_     "//ALTERADO DYEGO 09/07/14
	_cQry  +=" WHERE SD2.D_E_L_E_T_ = ' ' "
	_cQry  +="			AND SD2.D2_FILIAL   = '"+xFilial("SD2")+"' "
	_cQry  +="	        AND SD2.D2_DOC      = '"+SF2->F2_DOC+"' "
	_cQry  +="			AND SD2.D2_SERIE    = '"+SF2->F2_SERIE+"' "
	//_cQry  +="	        AND SD2.D2_CLIENTE  = '"+SD2->D2_CLIENTE+"' "
	//_cQry  +="	        AND SD2.D2_LOJA     = '"+SD2->D2_LOJA+"' "         
	teste :=  " "
	If Select("QRY") <> 0
		dbSelectArea("QRY")
		dbCloseArea()
	Endif
	TCQUERY _cQry NEW ALIAS "QRY" 
	QRY->(DBGoTop())   
	Do While !(QRY->(EOF()))           
		teste := " "
		If QRY->CRVPF=='S' .AND. !empty(_TRANSP) .AND. lRetorno 
			aVlTra	 := U_VlTrPFEX(_TRANSP,sData,"PF",.t.)
			lRetorno := aVlTra[1][1]	
		EndIf
		If QRY->CRVME=='S'.AND. !empty(_TRANSP) .AND. lRetorno
			aVlTra	 :=U_VlTrPFEX(_TRANSP,sData,"EX",.t.)
			lRetorno :=	aVlTra[1][1]
		EndIf                               
		If (QRY->XLINHA $ '12' ) .AND. !empty(_TRANSP) .AND. lRetorno   //.OR. QRY->XCONTR=='S'
			SA4->(dbSetOrder(1)) // Transportadora
			SA4->(dbSeek( xFilial('SA4')+_TRANSP))
			If SA4->(Found())
				If Empty(SA4->A4_XNLIAE) //.and. QRY->XCONTR=='S'
//					lRetorno := .F.
//					Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(QRY->CODPRO)) + " controlado, Transportadora sem Numero Licenca AE.",{"Continuar"},2)
				Endif
				If ALLTRIM(SA4->A4_XTRAQUI)=='N' .and. QRY->XLINHA $ '12'
					lRetorno := .F.
					Aviso("Atencao! - Carvalhaes:MT410TOK.PRW","Transportadora selecionada nпїЅo transporta quпїЅmicos.",{"Continuar"},2)
				Endif
				IF lRetorno
					cNTran := SA4->A4_NOME
				Endif
			Endif
        Endif
		If  !lRetorno                    
		   	Exit
		EndIf
		dbSelectArea("QRY")
		QRY->(DBSkip())
	End Do         
	teste := " "
	dbSelectArea("QRY")
	dbCloseArea()	
EndIf
	
Return (lRetorno)

// Consulta fretes
static function GravAPI(aParam)
    Local cURI   	:= "https://carvalhaes.simfrete.com"                // URL (IP) DO SERVIDOR
    Local cResource := "/CotacaoService/selecionar"        				// RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)                            	// CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                                            	// CABEпїЅALHO DA REQUISIпїЅпїЅO
    Local cJsonRet  := ""
	Local oJsonRet  := JsonObject():New()
	Local lRet 		:= .T.
	Local nStatus   := 0
    Local cMens     := ""

    // PREENCHE CABEпїЅALHO DA REQUISIпїЅпїЅO
    AAdd(aHeader, "Accept-Encoding: UTF-8")
    AAdd(aHeader, "Content-Type: application/json; charset=utf-8")
  
    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIпїЅпїЅO
    oRest:SetPath(cResource)
    oRest:SetPostParams(GetJson(aParam,2))

    // REALIZA O MпїЅTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        cJsonRet := oRest:GetResult()
		oJsonRet:fromJson(cJsonRet)
        nStatus := oJsonRet:GetJsonObject("status")
		If nStatus <> 0
			lRet  := .F.
			cMens := FwNoAccent(DecodeUtf8(oJsonRet:GetJsonObject("mensagem")))
			FWAlertError(cMens,"Falha no retorno de Dados.")
		Endif
    Else
		FWAlertError("POST: " + oRest:GetLastError(),"Falha na requisiпїЅпїЅo de Dados.")
		lRet  := .F.
        ////Conout("POST: " + oRest:GetLastError())
    EndIf
Return lRet

// Consulta fretes
static function ExecAPI(aParam,cCotacao,aDados)
    Local cURI   	:= "https://carvalhaes.simfrete.com"                // URL (IP) DO SERVIDOR
    Local cResource := "/CotacaoService/consultar"        				// RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)                            	// CLIENTE PARA CONSUMO REST
    Local aHeader   := {}                                            	// CABEпїЅALHO DA REQUISIпїЅпїЅO
    Local cJsonRet  := ""

	cCotacao := ""
	aDados	 := {}

    // PREENCHE CABEпїЅALHO DA REQUISIпїЅпїЅO
    AAdd(aHeader, "Accept-Encoding: UTF-8")
    AAdd(aHeader, "Content-Type: application/json; charset=utf-8")
  
    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIпїЅпїЅO
    oRest:SetPath(cResource)
    oRest:SetPostParams(GetJson(aParam,1))

    // REALIZA O MпїЅTODO POST E VALIDA O RETORNO
    If (oRest:Post(aHeader))
        cJsonRet := oRest:GetResult()
        trataJson(cJsonRet,@cCotacao,@aDados,aParam[04])
    Else
		FWAlertError("POST: " + oRest:GetLastError(),"Falha na requisiпїЅпїЅo de Dados.")
        ////Conout("POST: " + oRest:GetLastError())
    EndIf
Return

static Function trataJson(cJsonRet,cCotacao,aDados,nValTot)
    Local oJsonRet  := JsonObject():New()
    Local nStatus   := 0
    Local cMens     := ""
    Local aResult   := {}
    Local nItem     := 0
	Local dDtColeta
	Local dDtEntrega

    //Conout("** Inicia tratamento Json **")
    oJsonRet:fromJson(cJsonRet)

    nStatus := oJsonRet:GetJsonObject("status")
    //Conout("Status: " + cValtoChar(nStatus))
    If nStatus <> 0
		cMens := FwNoAccent(DecodeUtf8(oJsonRet:GetJsonObject("mensagem")))
		//Conout("Mensagem: " + cMens)
        FWAlertError(cMens,"Falha no retorno de Dados.")
    else
    	cCotacao := oJsonRet:GetJsonObject("numeroCotacao")
        aResult  := oJsonRet:GetJsonObject("resultadoCotacao")
        For nItem := 1 to Len(aResult)
           
			SA4->(DbSetOrder(3))
			IF SA4->(MsSeek(xFilial("SA4") + aResult[nItem]["trechos"][1]["transportadora"]))
				dDtColeta := aResult[nItem]["previsaoColeta"]
				dDtEntrega := aResult[nItem]["previsaoEntrega"]
				IF ValType(dDtColeta)<>"U"
					dDtColeta := FwDateTimeToLocal(dDtColeta)[1]
				else
					dDtColeta := CtoD("")
				Endif
				IF ValType(dDtEntrega)<>"U"
					dDtEntrega := FwDateTimeToLocal(dDtEntrega)[1]
				else
					dDtEntrega := CtoD("")
				Endif
				aADD(aDados,{	.F.,;
								aResult[nItem]["freteTotal"],;
								aResult[nItem]["prazo"],;
								dDtColeta ,;
								dDtEntrega ,;
								SA4->A4_NOME,;
								SA4->A4_COD,;
								aResult[nItem]["row"],;
								Round((aResult[nItem]["freteTotal"]/nValTot)*100,2);
								})
			Endif
        next
        //U_ShowTRB((cAliasTRB))
		IF Len(aDados) > 0
			ASort(aDados,,,{|x,y| x[2] < y[2]})
			aDados[01,01] := .T.
		Endif
    Endif

    //Conout("** Fim tratamento Json **")
Return


// CRIA O JSON QUE SERпїЅ ENVIADO NO CORPO (BODY) DA REQUISIпїЅпїЅO
Static Function GetJson(aParam,nTipo)
    Local bObject   := {|| JsonObject():New()}
    Local oJson     := Eval(bObject)
    Local cWsEmp    := "carvalhaes"
    Local cWsUsr    := "webservice2"
    Local cWsPwd    := "carvalhaes123"
    Local cCEPOri   := ""
    Local cCNPJri   := ""
    Local cNomeOri  := ""
    Local cCEPDes   := ""
    Local cCNPJDes  := ""
    Local cNomeDes  := ""
    Local nM3Tot 	:= 0
    Local nValTot   := 0
    Local nPesTot   := 0
    Local nVolTot 	:= 0
	Local cCot 		:= ""
	Local nRow 		:= 0

	
    oJson["wsEmp"]                  := cWsEmp
    oJson["wsUsr"]                  := cWsUsr
    oJson["wsPwd"]                  := cWsPwd
	IF nTipo == 1
		cCEPOri   := SM0->M0_CEPENT
		cCNPJri   := SM0->M0_CGC
		cNomeOri  := SM0->M0_NOMECOM
		cCEPDes   := IIF(SF2->F2_TIPO $ "DB",SA2->A2_CEP,SA1->A1_CEP)
		cCNPJDes  := IIF(SF2->F2_TIPO $ "DB",SA2->A2_CGC,SA1->A1_CGC)
		cNomeDes  := IIF(SF2->F2_TIPO $ "DB",SA2->A2_NOME,SA1->A1_NOME)
		nM3Tot 	  := aParam[01]
		nValTot   := aParam[04]
		nPesTot   := aParam[02]
		nVolTot   := aParam[03]
		oJson["modal"]        			:= "rod"
		oJson["condicaoFrete"]        	:= "C"
		oJson["origem"]                 := cCEPOri
		oJson["remetenteCnpj"]        	:= cCNPJri
		oJson["remetenteNome"]        	:= cNomeOri
		oJson["destino"]                := cCEPDes
		oJson["destinatarioCnpj"]       := cCNPJDes
		oJson["destinatarioNome"]       := cNomeDes
		oJson["volumeTotal"]        	:= nM3Tot
		oJson["valorTotal"]        		:= nValTot
		oJson["pesoTotal"]        		:= nPesTot
		oJson["quantidadeTotal"]        := nVolTot
	else
		cCot 	  := aParam[01]
		nRow 	  := aParam[02]
		nValTot   := aParam[03]
		oJson["numeroCotacao"]        	:= cCot
		oJson["row"]        			:= nRow
		oJson["freteTotal"]        		:= nValTot
	endif

Return (oJson:ToJson())
