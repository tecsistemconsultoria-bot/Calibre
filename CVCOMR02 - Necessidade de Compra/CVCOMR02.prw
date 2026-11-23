#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

// Ordens conforme ambiente (prefixo Filial+Produto nas buscas)
#DEFINE XM440_ORD_SC6 2
#DEFINE XM440_ORD_SD4 1
#DEFINE XM440_ORD_SC2 1
#DEFINE XM440_ORD_SB2 1

// Grupo de perguntas (deve ser identico ao cadastro SX1 e ao cPerg do TReport)
#DEFINE XM440_GRUPO "CVCOMR02"

// Larguras de coluna (caracteres) para layout mais compacto no Excel/PDF
#DEFINE XM440_W_COD   15
#DEFINE XM440_W_DESC  40
#DEFINE XM440_W_TP    4
#DEFINE XM440_W_GRUPO 8
#DEFINE XM440_W_UM    4
#DEFINE XM440_W_NUM   11
#DEFINE XM440_W_DATA  10
#DEFINE XM440_W_TXT12 12
#DEFINE XM440_W_TXT32 32
#DEFINE XM440_W_OBS   38

/*/{Protheus.doc} CVCOMR02
User Function CVCOMR02 / fonte CVCOMR02.prw.
Relatorio customizado (base conceitual MATR440) - necessidade de compra por saldo,
entrada prevista, PV (SC6), empenhos (SD4) e estoque de seguranca.
Identificacao do relatório no TReport: CVCOMR02. Grupo de perguntas SX1 (Pergunte): CVCOMR02. Parametros: MV_CH1=data limite (SC6.C6_CRVENT / SC2.C2_DATPRI quando preenchida);
MV_CH2=somente pendentes (Sim=WHERE EXISTS PV/SD4/OP + loop; Nao=faixa SB1 inteira);
MV_CH3=estoque seguranca na coluna e na qtd a comprar. Normalizacao alinha MV_CHx com mv_par.

IMPORTANTE: nao reutilize o mesmo X1_VARIAVL em pergunta Data e Numerica (ex.: MV_CH1 em D e N).
Registros excluidos na SX1 nao entram na sequencia do Pergunte.
/*/
User Function CVCOMR02()

	Local oReport
	// Garante tipagem base dos parametros no escopo da rotina para a TRParamPage.
	// Evita DTOC com argumento invalido quando algum MV_PAR vem sem tipo esperado.
	Private mv_par01 := ""
	Private mv_par02 := ""
	Private mv_par03 := ""
	Private mv_par04 := ""
	Private mv_par05 := ""
	Private mv_par06 := ""
	Private mv_par07 := ""
	Private mv_par08 := ""
	Private mv_par09 := 1
	// mv_parNN = N-esima pergunta ativa (ex.: com 07-17 excluidos, data MV_CH1 cai em mv_par07)
	Private mv_par18 := CtoD( "" )
	// Variaveis nomeadas na SX1 (TRParamPage usa estes nomes, nao so mv_parNN)
	Private MV_CH1 := CtoD( "" )
	Private MV_CH2 := 1
	Private MV_CH3 := 1

	oReport := ReportDef()
	// Auto-provisiona SX1 do grupo caso nao exista (primeira execucao / ambiente novo).
	xM440EnsSX()
	// Carrega parametros em memoria sem abrir o Pergunte.
	// Mantem a entrada pela tela de impressao (Outras Acoes > Parametros).
	Pergunte( XM440_GRUPO, .F. )
	xM440NormalizePergunte()
	// Corpo um pouco maior que o padrao (layout mais legivel no Excel)
	oReport:nFontBody := IIf( IsBlind(), 11, 9 )
	oReport:PrintDialog()
	// Apos fechar a tela de impressao (parametros podem ter sido alterados sem gerar ainda).
	xM440NormalizePergunte()

Return

/*/{Protheus.doc} ReportDef
Monta definicao do TReport e colunas.
/*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local cAliasSB1 := GetNextAlias()
	Local cTitSaldo := "Saldo Atual (" + AllTrim( cFilAnt ) + ")"
	Local cTitRel   := "CVCOMR02 - Necessidade de Compra"
	Local cSubRel   := "Itens por filial/armazem padrao com PV, OP/empenho e estoque seguranca"

	// Usa cPerg nativo do TReport para exibir parametros em Outras Acoes.
	oReport := TReport():New( "CVCOMR02", cTitRel, XM440_GRUPO, { |oReport| ReportPrint( oReport, cAliasSB1 ) }, cSubRel )
	oReport:SetTotalInLine( .F. )
	oReport:SetTotalText( "TOTAL GERAL VLR. ESTIMADO" )
	oReport:SetLandscape()

	oSection1 := TRSection():New( oReport, "Produtos", { "SB1" } )

	oSection1:SetHeaderPage()

	TRCell():New( oSection1, "B1_COD",   "SB1", /*cTitulo*/, /*cPicture*/, XM440_W_COD, /*lPix*/, { || cCod },,,"RIGHT" )
	TRCell():New( oSection1, "B1_DESC",  "SB1", /*cTitulo*/, /*cPicture*/, XM440_W_DESC, /*lPix*/, { || cDesc },,,"RIGHT" )
	TRCell():New( oSection1, "B1_TIPO",  "SB1", "TP", /*cPicture*/, XM440_W_TP, /*lPix*/, { || cTipo },,,"RIGHT" )
	TRCell():New( oSection1, "B1_GRUPO", "SB1", /*cTitulo*/, /*cPicture*/, XM440_W_GRUPO, /*lPix*/, { || cGrupo },,,"RIGHT" )
	TRCell():New( oSection1, "B1_UM",    "SB1", /*cTitulo*/, /*cPicture*/, XM440_W_UM, /*lPix*/, { || cUM },,,"RIGHT" )

	TRCell():New( oSection1, "XSALDO", "   ", cTitSaldo, PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || nSalAtu },,,"RIGHT" )
	TRCell():New( oSection1, "XPREV",  "   ", "Entrada" + CRLF + "Prevista", PesqPict( "SB2", "B2_SALPEDI" ), XM440_W_NUM, /*lPix*/, { || nEntPrv },,,"RIGHT" )
	TRCell():New( oSection1, "XPV",    "   ", "PVs" + CRLF + "Pendentes", PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || nPVPend },,,"RIGHT" )
	TRCell():New( oSection1, "XSD4",   "   ", "Saldo OPs" + CRLF + "Pendentes", PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || nOPPend },,,"RIGHT" )

	TRCell():New( oSection1, "B1_EMIN", "SB1", "Ponto" + CRLF + "Pedido", /*cPicture*/, XM440_W_NUM, /*lPix*/, { || nPontoPed },,,"RIGHT" )
	TRCell():New( oSection1, "XDTPP",   "   ", "Data" + CRLF + "P.P.", /*cPicture*/, XM440_W_DATA, /*lPix*/, { || xM440FmtDataBr( dDataPP ) },,,"CENTER" )

	// Excel/TRCell: nao usar so nEstSegCol (avaliação pode descolar); força 0 se lSegSim=.F.
	TRCell():New( oSection1, "XESTS", "   ", "Est." + CRLF + "Seguranca", PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || IIf( lSegSim, xM440GetEstSeg( cCod ), 0 ) },,,"RIGHT" )
	TRCell():New( oSection1, "B1_CRVLE", "SB1", "Lote" + CRLF + "Econom.", PesqPict( "SB1", "B1_CRVLE" ), XM440_W_NUM, /*lPix*/, { || nLoteEc },,,"RIGHT" )

	TRCell():New( oSection1, "B1_TOLER", "SB1", "% Tol.", PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || nPctTol },,,"RIGHT" )
	TRCell():New( oSection1, "XTOLERQ", "   ", "Toler." + CRLF + "(qtd)", PesqPict( "SB1", "B1_CRVLE" ), XM440_W_NUM, /*lPix*/, { || nTolerQtd },,,"RIGHT" )

	TRCell():New( oSection1, "B1_QE", "SB1", "Qtd/Emb.", PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || nQEmb },,,"RIGHT" )
	TRCell():New( oSection1, "XQTD",  "   ", "Qtd a" + CRLF + "Comprar", PesqPict( "SB1", "B1_LE" ), XM440_W_NUM, /*lPix*/, { || nQtdComp },,,"RIGHT" )

	TRCell():New( oSection1, "B1_UPRC", "SB1", "Ult.Preco" + CRLF + "de Compra", PesqPict( "SB1", "B1_UPRC" ), XM440_W_NUM, /*lPix*/, { || nUprc },,,"RIGHT" )
	TRCell():New( oSection1, "XVLR",  "   ", "Vlr.Estim." + CRLF + "Compra", TM( 0, 16 ), XM440_W_NUM, /*lPix*/, { || nVlrEst },,,"RIGHT" )

	TRCell():New( oSection1, "B1_UCOM", "SB1", "Ultima" + CRLF + "Compra", /*cPicture*/, XM440_W_DATA, /*lPix*/, { || xM440FmtDataBr( dUltCom ) },,,"CENTER" )

	TRCell():New( oSection1, "XPRZEN", "   ", "Prazo de Entrega (Dias)", PesqPict( "SB1", "B1_PE" ), XM440_W_NUM, /*lPix*/, { || nPrazoEnt },,,"RIGHT" )
	TRCell():New( oSection1, "B1_PRVALID", "SB1", "Prazo" + CRLF + "Validade", "9999", XM440_W_NUM, /*lPix*/, { || nPrValid },,,"RIGHT" )

	TRCell():New( oSection1, "XFIL",  "   ", "Filial", X3Picture( "B2_FILIAL" ), XM440_W_TP + 2, /*lPix*/, { || cFilExib } )
	TRCell():New( oSection1, "XLOC",  "   ", "Armazem", X3Picture( "B2_LOCAL" ), XM440_W_TP + 2, /*lPix*/, { || cLocExib } )

	TRCell():New( oSection1, "XA2REV", "   ", "Fornecedor" + CRLF + "Revenda", /*cPicture*/, XM440_W_TXT12, /*lPix*/, { || cA2Rev } )
	TRCell():New( oSection1, "B1_FABRIC", "SB1", "Marca", /*cPicture*/, XM440_W_TXT12, /*lPix*/, { || cMarca } )
	TRCell():New( oSection1, "XFORN", "   ", "Fornecedor", /*cPicture*/, XM440_W_TXT32, /*lPix*/, { || cFornTxt } )
	TRCell():New( oSection1, "B1_IMPORT", "SB1", "Importado", /*cPicture*/, XM440_W_TXT12, /*lPix*/, { || cImport } )
	TRCell():New( oSection1, "B1_CRVGRUP", "SB1", "MRP RS", /*cPicture*/, XM440_W_TP + 2, /*lPix*/, { || cMrpRs } )

	TRCell():New( oSection1, "XOBS", "   ", "Observacao", /*cPicture*/, XM440_W_OBS, /*lPix*/, { || cObs } )

	TRFunction():New( oSection1:Cell( "XVLR" ), NIL, "SUM", /*oBreak*/, , /*cPicture*/, /*uFormula*/, .F., .T. )

Return oReport

/*/{Protheus.doc} xM440NormVarData
Garante variavel tipo D para a TRParamPage (DTOC). cNom = nome publico (ex.: MV_CH1).
/*/
Static Function xM440NormVarData( cNom )

	Local xVal := NIL
	Local cAux := ""

	If Empty( cNom )
		Return
	EndIf

	Begin Sequence
		xVal := &( cNom )
		Do Case
		Case ValType( xVal ) == "D"
			// ok
		Case ValType( xVal ) == "C"
			cAux := AllTrim( xVal )
			If Empty( cAux )
				&( cNom ) := CtoD( "" )
			ElseIf Len( cAux ) == 8
				&( cNom ) := StoD( cAux )
			Else
				&( cNom ) := CtoD( cAux )
			EndIf
		Case ValType( xVal ) == "N"
			If xVal > 0
				&( cNom ) := StoD( StrZero( xVal, 8 ) )
			Else
				&( cNom ) := CtoD( "" )
			EndIf
		OtherWise
			&( cNom ) := CtoD( "" )
		EndCase
	Recover
		&( cNom ) := CtoD( "" )
	End Sequence

Return

/*/{Protheus.doc} xM440PNVal
Converte parametro numerico/lista para N (0 se indefinido).
/*/
Static Function xM440PNVal( xU )

	If ValType( xU ) == "N"
		Return xU
	EndIf
	If ValType( xU ) == "C"
		Return Val( AllTrim( xU ) )
	EndIf
	If ValType( xU ) == "L"
		Return IIf( xU, 1, 0 )
	EndIf

Return 0

/*/{Protheus.doc} xM440MNLst
Mescla mv_par e X1_VARIAVL tipo N (lista Sim=1 / Nao=2). TRParamPage costuma atualizar
MV_CHx; o Pergunte grava na sequencia — podem divergir. Se qualquer lado for 2 (Nao), fixa 2 nos dois.
/*/
Static Function xM440MNLst( cSeq, cNom )

	Local nS   := 0
	Local nN   := 0
	Local nF   := 0
	Local cUpN := Upper( AllTrim( cNom ) )

	Begin Sequence
		nS := xM440PNVal( &( cSeq ) )
		nN := xM440PNVal( &( cNom ) )
		// Lista Sim=1 / Nao=2 nas perguntas MV_CH2 e MV_CH3 (CVCOMR02)
		If cUpN == "MV_CH2" .Or. cUpN == "MV_CH3"
			If nS == 2 .Or. nN == 2
				nF := 2
			ElseIf nS == 1 .Or. nN == 1
				nF := 1
			Else
				nF := 0
			EndIf
		Else
			nF := IIf( nN <> 0, nN, nS )
			If nF == 0 .And. nS <> 0
				nF := nS
			EndIf
		EndIf
		&( cSeq ) := nF
		&( cNom ) := nF
	Recover
	End Sequence

Return

/*/{Protheus.doc} xM440MCStr
Mescla texto entre mv_par e X1_VARIAVL (qualquer um preenchido replica no outro).
/*/
Static Function xM440MCStr( cSeq, cNom )

	Local cS := ""
	Local cN := ""

	Begin Sequence
		If ValType( &( cSeq ) ) == "C"
			cS := &( cSeq )
		Else
			cS := AllTrim( Str( &( cSeq ) ) )
		EndIf
		If ValType( &( cNom ) ) == "C"
			cN := &( cNom )
		Else
			cN := AllTrim( Str( &( cNom ) ) )
		EndIf
		cS := AllTrim( cS )
		cN := AllTrim( cN )
		If !Empty( cN )
			&( cSeq ) := cN
			&( cNom ) := cN
		ElseIf !Empty( cS )
			&( cNom ) := cS
			&( cSeq ) := cS
		EndIf
	Recover
	End Sequence

Return

/*/{Protheus.doc} xM440MSNom
Mescla o n-esimo parametro (mv_parNN) com X1_VARIAVL. O TRParam pode preencher so MV_CHx;
o Excel da TRPrint e o Pergunte usam os dois canais — nunca sobrescrever MV_CHx com mv_par
“stale” (ex.: mv_par09 := 1 inicial apos usuario marcar Nao=2 em MV_CH3).
Ignora MV_CH0 (repetido nas perguntas 01-06).
/*/
Static Function xM440MSNom( cSeq, cNom, cTp )

	cTp := Upper( Left( AllTrim( cTp ), 1 ) )

	If Empty( cSeq ) .Or. Empty( cNom )
		Return
	EndIf
	If Upper( AllTrim( cNom ) ) == "MV_CH0"
		Return
	EndIf

	Begin Sequence
		Do Case
		Case cTp == "D"
			xM440NormVarData( cSeq )
			xM440NormVarData( cNom )
			xM440SyncTwoDates( cNom, cSeq )
		Case cTp == "N"
			xM440MNLst( cSeq, cNom )
		Case cTp == "L"
			xM440MNLst( cSeq, cNom )
		OtherWise
			xM440MCStr( cSeq, cNom )
		EndCase
	Recover
	End Sequence

Return

/*/{Protheus.doc} xM440SyncTwoDates
Alinha duas variaveis que representam a mesma pergunta tipo Data (ex.: MV_CH1 e mv_par07).
/*/
Static Function xM440SyncTwoDates( cA, cB )

	Local xA := NIL
	Local xB := NIL

	If Empty( cA ) .Or. Empty( cB )
		Return
	EndIf
	If Upper( AllTrim( cA ) ) == Upper( AllTrim( cB ) )
		Return
	EndIf

	xM440NormVarData( cA )
	xM440NormVarData( cB )

	Begin Sequence
		xA := &( cA )
		xB := &( cB )
		If ValType( xA ) == "D" .And. ( ValType( xB ) <> "D" .Or. Empty( xB ) )
			&( cB ) := xA
		ElseIf ValType( xB ) == "D" .And. ( ValType( xA ) <> "D" .Or. Empty( xA ) )
			&( cA ) := xB
		ElseIf ValType( xA ) == "D" .And. ValType( xB ) == "D"
			If Empty( xA ) .And. !Empty( xB )
				&( cA ) := xB
			ElseIf Empty( xB ) .And. !Empty( xA )
				&( cB ) := xA
			EndIf
		EndIf
	Recover
	End Sequence

	xM440NormVarData( cA )
	xM440NormVarData( cB )

Return

/*/{Protheus.doc} xM440NormalizePergunte
Registros SX1 ativos, na ordem do Pergunte. Mescla mv_par01.. com X1_VARIAVL (MV_CH1..)
em ambos os sentidos, para TRParam + Excel + ReportPrint verem o mesmo valor.
/*/
Static Function xM440NormalizePergunte()

	Local cGrp   := AllTrim( XM440_GRUPO )
	Local nTamG  := 10
	Local aTamG  := TamSX3( "X1_GRUPO" )
	Local cGrpK  := ""
	Local aAtiv  := {}
	Local aLin   := NIL
	Local nI     := 0
	Local nTot   := 0
	Local cSeq   := ""
	Local cVar   := ""
	Local cTpSX  := ""

	xM440EnsSX()

	If ValType( aTamG ) == "A" .And. Len( aTamG ) >= 1
		nTamG := aTamG[1]
	EndIf
	cGrpK := PadR( cGrp, nTamG )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	If SX1->( dbSeek( cGrpK, .T. ) )
		While !SX1->( Eof() ) .And. AllTrim( SX1->X1_GRUPO ) == cGrp .And. xM440S1Atv()
			If SX1->( FieldPos( "X1_VARIAVL" ) ) > 0
				cVar := AllTrim( SX1->X1_VARIAVL )
			Else
				cVar := ""
			EndIf
			AAdd( aAtiv, { Val( AllTrim( SX1->X1_ORDEM ) ), cVar, AllTrim( SX1->X1_TIPO ) } )
			SX1->( dbSkip() )
		EndDo
	EndIf

	nTot := Len( aAtiv )
	For nI := 1 To nTot
		aLin  := aAtiv[ nI ]
		cSeq  := "mv_par" + StrZero( nI, 2 )
		cVar  := aLin[ 2 ]
		cTpSX := aLin[ 3 ]
		If Empty( cVar ) .Or. Upper( AllTrim( cVar ) ) == "MV_CH0"
			If Left( Upper( AllTrim( cTpSX ) ), 1 ) == "D"
				xM440NormVarData( cSeq )
			EndIf
			Loop
		EndIf
		xM440MSNom( cSeq, cVar, cTpSX )
	Next nI

Return

/*/{Protheus.doc} xM440S1Atv
Valida se o registro corrente da SX1 esta ativo (nao deletado).
/*/
Static Function xM440S1Atv()

	Local nPos := 0
	Local cDel := ""

	nPos := SX1->( FieldPos( "D_E_L_E_T_" ) )
	If nPos <= 0
		Return .T.
	EndIf

	cDel := SX1->( FieldGet( nPos ) )

Return ( AllTrim( cDel ) == "" )

/*/{Protheus.doc} xM440S1Set
Seta campo da SX1 apenas se existir no dicionario.
/*/
Static Function xM440S1Set( cCampo, uValor )

	Local nPos := 0

	nPos := SX1->( FieldPos( AllTrim( cCampo ) ) )
	If nPos > 0
		SX1->( FieldPut( nPos, uValor ) )
	EndIf

Return

/*/{Protheus.doc} xM440EnsSX
Cria o grupo de perguntas SX1 (XM440_GRUPO) na primeira execucao, caso nao exista
nenhum registro ativo para o grupo.
/*/
Static Function xM440EnsSX()

	Local cGrp   := AllTrim( XM440_GRUPO )
	Local nTamG  := 10
	Local aTamG  := TamSX3( "X1_GRUPO" )
	Local cGrpK  := ""
	Local nAtiv  := 0
	Local nI     := 0
	Local aLin   := {}
	Local aPergs := {}

	// Estrutura padrao esperada pelo fonte:
	// 01-06 faixas (MV_PAR01..06), 07 data limite (MV_CH1),
	// 08 pendentes (MV_CH2), 09 estoque seguranca (MV_CH3).
	aPergs := { ;
		{ "01", "Do Produto ?", "De Producto ?", "From Product ?", "MV_CH0", "C", 30, 0, 0, "G", "", "MV_PAR01" }, ;
		{ "02", "Ate o Produto ?", "A Producto ?", "To Product ?", "MV_CH0", "C", 30, 0, 0, "G", "", "MV_PAR02" }, ;
		{ "03", "Do Grupo ?", "De Grupo ?", "From Group ?", "MV_CH0", "C", 4, 0, 0, "G", "", "MV_PAR03" }, ;
		{ "04", "Ate o Grupo ?", "A Grupo ?", "To Group ?", "MV_CH0", "C", 4, 0, 0, "G", "", "MV_PAR04" }, ;
		{ "05", "Do Tipo ?", "De Tipo ?", "From Type ?", "MV_CH0", "C", 2, 0, 0, "G", "", "MV_PAR05" }, ;
		{ "06", "Ate o Tipo ?", "A Tipo ?", "To Type ?", "MV_CH0", "C", 2, 0, 0, "G", "", "MV_PAR06" }, ;
		{ "07", "Data Limite PV e OP ?", "Data Limite PV e OP ?", "Date Limit PV e OP ?", "MV_CH1", "D", 8, 0, 0, "G", "", "MV_PAR07" }, ;
		{ "08", "So Itens Pendentes em PV e OP?", "So Itens Pendentes em PV e OP?", "So Items Pendentes em PV e OP?", "MV_CH2", "N", 1, 0, 1, "C", "", "MV_PAR08" }, ;
		{ "09", "Considera Est. Seguranca ?", "Considera Sto. Seguridad ?", "Consider Safety Stock ?", "MV_CH3", "N", 1, 0, 1, "C", "", "MV_PAR09" }  ;
	}

	If ValType( aTamG ) == "A" .And. Len( aTamG ) >= 1
		nTamG := aTamG[1]
	EndIf
	cGrpK := PadR( cGrp, nTamG )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	If SX1->( dbSeek( cGrpK, .T. ) )
		While !SX1->( Eof() ) .And. AllTrim( SX1->X1_GRUPO ) == cGrp
			If xM440S1Atv()
				nAtiv++
				Exit
			EndIf
			SX1->( dbSkip() )
		EndDo
	EndIf

	If nAtiv > 0
		Return
	EndIf

	For nI := 1 To Len( aPergs )
		aLin := aPergs[nI]

		If RecLock( "SX1", .T. )
			xM440S1Set( "X1_GRUPO", cGrp )
			xM440S1Set( "X1_ORDEM", aLin[1] )
			xM440S1Set( "X1_PERGUNT", aLin[2] )
			xM440S1Set( "X1_PERSPA", aLin[3] )
			xM440S1Set( "X1_PERENG", aLin[4] )
			xM440S1Set( "X1_VARIAVL", aLin[5] )
			xM440S1Set( "X1_TIPO", aLin[6] )
			xM440S1Set( "X1_TAMANHO", aLin[7] )
			xM440S1Set( "X1_DECIMAL", aLin[8] )
			xM440S1Set( "X1_PRESEL", aLin[9] )
			xM440S1Set( "X1_GSC", aLin[10] )
			xM440S1Set( "X1_VALID", aLin[11] )
			xM440S1Set( "X1_VAR01", aLin[12] )
			xM440S1Set( "X1_DEF01", "" )
			xM440S1Set( "X1_DEFSPA1", "" )
			xM440S1Set( "X1_DEFENG1", "" )
			xM440S1Set( "X1_VAR02", "" )
			xM440S1Set( "X1_DEF02", "" )
			xM440S1Set( "X1_DEFSPA2", "" )
			xM440S1Set( "X1_DEFENG2", "" )
			xM440S1Set( "X1_CNT01", "" )
			xM440S1Set( "X1_CNT02", "" )
			xM440S1Set( "X1_CNT03", "" )
			xM440S1Set( "X1_CNT04", "" )
			xM440S1Set( "X1_CNT05", "" )

			If aLin[1] == "08" .Or. aLin[1] == "09"
				xM440S1Set( "X1_VAR01", "1" )
				xM440S1Set( "X1_DEF01", "Sim" )
				xM440S1Set( "X1_DEFSPA1", "Si" )
				xM440S1Set( "X1_DEFENG1", "Yes" )
				xM440S1Set( "X1_VAR02", "2" )
				xM440S1Set( "X1_DEF02", "Nao" )
				xM440S1Set( "X1_DEFSPA2", "No" )
				xM440S1Set( "X1_DEFENG2", "No" )
			EndIf

			MsUnlock()
		EndIf
	Next nI

Return

/*/{Protheus.doc} xM440SqlFiltroPend
Restringe SB1 a produtos com pendencia em PV (SC6), empenho (SD4) ou OP (SC2).
Se dLim preenchida: SC6.C6_CRVENT e SC2.C2_DATPRI respeitam a data limite informada.
/*/
Static Function xM440SqlFiltroPend( cFilC6, cFilD4, cFilC2, dLim )

	Local cF := ""

	cF := " AND ( "
	cF += " EXISTS ( SELECT 1 FROM " + RetSqlName( "SC6" ) + " SC6 "
	cF += " WHERE SC6.C6_FILIAL = '" + cFilC6 + "' "
	cF += " AND SC6.C6_PRODUTO = SB1.B1_COD "
	cF += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
	cF += " AND SC6.C6_BLQ <> 'R' "
	cF += " AND SC6.D_E_L_E_T_ = ' ' "
	If !Empty( dLim )
		cF += " AND SC6.C6_CRVENT <= '" + DtoS( dLim ) + "' "
	EndIf
	cF += " ) OR "

	cF += " EXISTS ( SELECT 1 FROM " + RetSqlName( "SD4" ) + " SD4 "
	cF += " WHERE SD4.D4_FILIAL = '" + cFilD4 + "' "
	cF += " AND SD4.D4_COD = SB1.B1_COD "
	cF += " AND SD4.D4_QUANT <> 0 "
	cF += " AND SD4.D_E_L_E_T_ = ' ' "
	cF += " ) OR "

	cF += " EXISTS ( SELECT 1 FROM " + RetSqlName( "SC2" ) + " SC2 "
	cF += " WHERE SC2.C2_FILIAL = '" + cFilC2 + "' "
	cF += " AND SC2.C2_PRODUTO = SB1.B1_COD "
	cF += " AND SC2.D_E_L_E_T_ = ' ' "
	cF += " AND ( SC2.C2_DATRF IS NULL OR LTRIM( RTRIM( ISNULL( CONVERT( VARCHAR(20), SC2.C2_DATRF ), '' ) ) ) = '' ) "
	If !Empty( dLim )
		cF += " AND SC2.C2_DATPRI <= '" + DtoS( dLim ) + "' "
	EndIf
	cF += " ) "
	cF += " ) "

Return cF

/*/{Protheus.doc} xM440SqlJoinAgregados
LEFT JOINs com totais por produto (uma passagem no SQL Server por tabela de movimento).
Evita N seeks/loops em SC6, SD4, SC2 e SB2 no AdvPL. Regras alinhadas a xM440SumPV,
xM440SumSD4, xM440TemOPPend e seek SB2 (sem filtro D_E_L_E_T_ nas rotinas antigas).
C2_DATRF: mesmo criterio de xM440SqlFiltroPend (SQL Server).
/*/
Static Function xM440SqlJoinAgregados( cFilB2, cFilC6, cFilD4, cFilC2, dLim )

	Local cJ := ""

	// PV pendente por produto (SC6)
	/*cJ += " LEFT JOIN ( SELECT T6.C6_PRODUTO, SUM( T6.C6_QTDVEN - T6.C6_QTDENT ) AS XM440_QTDPV "
	cJ += " FROM " + RetSqlName( "SC6" ) + " T6 "
	cJ += " WHERE T6.C6_FILIAL = '" + cFilC6 + "' "
	cJ += " AND T6.C6_QTDENT < T6.C6_QTDVEN "
	cJ += " AND T6.C6_BLQ <> 'R' "
	If !Empty( dLim )
		cJ += " AND T6.C6_CRVENT <= '" + DtoS( dLim ) + "' "
	EndIf
	cJ += " GROUP BY T6.C6_PRODUTO ) XM440AG6 ON XM440AG6.C6_PRODUTO = SB1.B1_COD "*/

	// Saldo empenho (SD4)
	cJ += " LEFT JOIN ( SELECT T4.D4_COD, SUM( T4.D4_QUANT ) AS XM440_QTDSD4 "
	cJ += " FROM " + RetSqlName( "SD4" ) + " T4 "
	cJ += " WHERE T4.D4_FILIAL = '" + cFilD4 + "' "
	cJ += " AND T4.D4_QUANT <> 0 "
	cJ += " AND T4.D_E_L_E_T_ = ' ' "
	cJ += " GROUP BY T4.D4_COD ) XM440AG4 ON XM440AG4.D4_COD = SB1.B1_COD "

	// Existe OP pendente (SC2) — flag por produto (mesmo criterio de xM440SqlFiltroPend)
	cJ += " LEFT JOIN ( SELECT DISTINCT T2.C2_PRODUTO AS C2_PRODUTO "
	cJ += " FROM " + RetSqlName( "SC2" ) + " T2 "
	cJ += " WHERE T2.C2_FILIAL = '" + cFilC2 + "' "
	cJ += " AND T2.D_E_L_E_T_ = ' ' "
	cJ += " AND ( T2.C2_DATRF IS NULL OR LTRIM( RTRIM( ISNULL( CONVERT( VARCHAR(20), T2.C2_DATRF ), '' ) ) ) = '' ) "
	If !Empty( dLim )
		cJ += " AND T2.C2_DATPRI <= '" + DtoS( dLim ) + "' "
	EndIf
	cJ += " ) XM440AG2 ON XM440AG2.C2_PRODUTO = SB1.B1_COD "

	// Saldo fisico e entrada prevista (SB2 — filial operacional + codigo + local padrao)
	cJ += " LEFT JOIN " + RetSqlName( "SB2" ) + " XM440SB2 "
	cJ += " ON XM440SB2.B2_FILIAL = '" + cFilB2 + "' "
	cJ += " AND XM440SB2.B2_COD = SB1.B1_COD "
	cJ += " AND RTRIM( XM440SB2.B2_LOCAL ) = RTRIM( SB1.B1_LOCPAD ) "

Return cJ

/*/{Protheus.doc} xM440QryGetN
Le campo numerico do alias da query (estrutura dinamica).
/*/
Static Function xM440QryGetN( cAlias, cCampo )

	Local nF := 0

	dbSelectArea( cAlias )
	nF := FieldPos( cCampo )
	If nF == 0
		Return 0
	EndIf

Return FieldGet( nF )

/*/{Protheus.doc} xM440PadCod
Alinha tamanho do codigo produto ao SX3 (seek compativel com SC6/SD4/SC2/SB2).
Nao usa AllTrim/LTrim: codigos gravados com espacos a esquerda devem bater com a chave do indice.
/*/
Static Function xM440PadCod( cProd )

Return PadR( cProd, TamSX3( "B1_COD" )[1] )

/*/{Protheus.doc} xM440PadLoc
Alinha local (SB2) ao SX3.
/*/
Static Function xM440PadLoc( cLoc )

Return PadR( RTrim( AllTrim( cLoc ) ), TamSX3( "B2_LOCAL" )[1] )

/*/{Protheus.doc} xM440NormData
Converte data tipo D, C (AAAAMMDD ou formato do SET DATE) ou N (AAAAMMDD) para D.
Necessario porque TOPCONN/TcGenQry costuma trazer campos de data da SQL como C.
/*/
Static Function xM440NormData( uData )

	Local dRet := CtoD( "" )
	Local cAux := ""

	Do Case
	Case ValType( uData ) == "D"
		If !Empty( uData )
			dRet := uData
		EndIf
	Case ValType( uData ) == "C"
		cAux := AllTrim( uData )
		If Len( cAux ) == 8
			dRet := StoD( cAux )
		EndIf
		If Empty( dRet ) .And. !Empty( cAux )
			dRet := CtoD( cAux )
		EndIf
	Case ValType( uData ) == "N"
		If uData > 0
			dRet := StoD( StrZero( uData, 8 ) )
		EndIf
	EndCase

Return dRet

/*/{Protheus.doc} xM440FmtDataBr
Data em texto DD/MM/AAAA para colunas do TReport (evita AAAAMMDD na exportacao Excel).
/*/
Static Function xM440FmtDataBr( uData )

	Local cRet  := ""
	Local dAux  := xM440NormData( uData )

	If !Empty( dAux )
		cRet := StrZero( Day( dAux ), 2 ) + "/" + StrZero( Month( dAux ), 2 ) + "/" + StrZero( Year( dAux ), 4 )
	EndIf

Return cRet

/*/{Protheus.doc} ReportPrint
Processa registros, calculos e impressao.
/*/
Static Function ReportPrint( oReport, cAliasSB1 )

	Local oSection1 := oReport:Section( 1 )
	Local cSelect   := ""
	Local cFilB2    := xFilial( "SB2" )
	Local cFilC6    := xFilial( "SC6" )
	Local cFilD4    := xFilial( "SD4" )
	Local cFilC2    := xFilial( "SC2" )
	Local cFilA2    := xFilial( "SA2" )
	Local cFilSB1   := xFilial( "SB1" )
	Local dLim      := CtoD( "" )
	Local cLocPad   := ""
	Local aRev      := { Space( 1 ) }
	Local aForn     := { "" }

	Private lSegSim  := .F.
	Private lSomPend := .T.
	Private cCod     := ""
	Private cDesc    := ""
	Private cTipo    := ""
	Private cGrupo   := ""
	Private cUM      := ""
	Private nSalAtu    := 0
	Private nEntPrv    := 0
	Private nPVPend    := 0
	Private nOPPend    := 0
	Private nPontoPed  := 0
	Private dDataPP    := CtoD( "" )
	Private nEstSegCol := 0
	Private nLoteEc    := 0
	Private nPctTol    := 0
	Private nTolerQtd  := 0
	Private nQEmb      := 0
	Private nQtdComp   := 0
	Private nUprc      := 0
	Private nVlrEst    := 0
	Private dUltCom    := CtoD( "" )
	Private nPrazoEnt  := 0
	Private nPrValid   := 0
	Private cFilExib   := ""
	Private cLocExib   := ""
	Private cA2Rev     := ""
	Private cMarca     := ""
	Private cFornTxt   := ""
	Private cImport    := ""
	Private cMrpRs     := ""
	Private cObs       := ""

	// Sempre remescla mv_par x MV_CHx antes de ler (ultima palavra = pergunte / TRParam).
	xM440NormalizePergunte()
	// Data limite: MV_CH1 (SX1) + fallback mv_par07 (mesma pergunta na sequencia).
	dLim := xM440ParDate( MV_CH1 )
	If Empty( dLim )
		dLim := xM440ParDate( mv_par07 )
	EndIf
	// Estoque seguranca (MV_CH3 / mv_par09): coluna e nQtdComp so se Sim nos dois canais coerentes.
	lSegSim := xM440SXSim( "MV_CH3", "mv_par09" )
	// So pendentes (MV_CH2 / mv_par08): SQL + loop; padrao Sim se ambos canais zerados (nao informado).
	lSomPend := xM440SXSim( "MV_CH2", "mv_par08" )
	If !lSomPend .And. xM440PNVal( MV_CH2 ) == 0 .And. xM440PNVal( mv_par08 ) == 0
		lSomPend := .T.
	EndIf

	If Empty( cFilSB1 )
		cFilSB1 := cFilAnt
	EndIf

	cSelect := " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_UM, SB1.B1_LOCPAD, SB1.B1_PROC, SB1.B1_LOJPROC, "
	cSelect += " SB1.B1_FABRIC, SB1.B1_IMPORT, SB1.B1_CRVGRUP, SB1.B1_UPRC, SB1.B1_UCOM, SB1.B1_PE, "
	cSelect += " SB1.B1_PRVALID, SB1.B1_CRVLE, SB1.B1_QE, SB1.B1_TOLER, SB1.B1_EMIN, SB1.B1_ESTFOR, SB1.B1_LE, "
	//cSelect += " ISNULL( XM440AG6.XM440_QTDPV, 0 ) AS XM440_PV, "

	cSelect += " (SELECT (COALESCE(SUM(C6_QTDVEN),0) - COALESCE(SUM(C6_QTDENT),0)) FROM "+RetSQLName("SC6")+" A"
	cSelect += " INNER JOIN "+RetSQLName("SC5")+" B"
	cSelect += "		ON C5_FILIAL = C6_FILIAL"
	cSelect += "		AND C5_NUM = C6_NUM"
	cSelect += " 	AND B.D_E_L_E_T_ <> '*'"
	cSelect += "  INNER JOIN "+RetSQLName("SF4")+" F4"
	cSelect += "		ON F4_FILIAL = C6_FILIAL"
	cSelect += "		AND F4_CODIGO = C6_TES"
	cSelect += "		AND F4_ESTOQUE = 'S'"
	cSelect += "		AND F4.D_E_L_E_T_ <> '*'"
	cSelect += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'"
	cSelect += " 	AND C6_PRODUTO = SB1.B1_COD"

	If xFilial("SC6") == '01'
		cSelect += "		AND C6_TES NOT IN ('5A2')"
	Else
		cSelect += "		AND C6_TES NOT IN ('522')"
	Endif 

	cSelect += "		AND C6_BLQ <> 'R'"
	cSelect += "		AND A.D_E_L_E_T_ <> '*'"
	cSelect += " ) AS XM440_PV,"

	cSelect += " ISNULL( XM440AG4.XM440_QTDSD4, 0 ) AS XM440_SD4, "
	cSelect += " CASE WHEN XM440AG2.C2_PRODUTO IS NULL THEN 0 ELSE 1 END AS XM440_OPC, "
	cSelect += " ISNULL( XM440SB2.B2_QATU, 0 ) AS XM440_QATU, "
	cSelect += " ISNULL( XM440SB2.B2_SALPEDI, 0 ) AS XM440_SALPEDI "
	cSelect += " FROM " + RetSqlName( "SB1" ) + " SB1 "
	cSelect += xM440SqlJoinAgregados( cFilB2, cFilC6, cFilD4, cFilC2, dLim )
	cSelect += " WHERE SB1.B1_FILIAL = '  ' AND "
	cSelect += " SB1.B1_COD    >= '" + xM440PadCod( xM440ParC( mv_par01 ) ) + "' AND SB1.B1_COD    <= '" + xM440PadCod( xM440ParC( mv_par02 ) ) + "' AND "
	cSelect += " SB1.B1_GRUPO  >= '" + xM440ParC( mv_par03 ) + "' AND SB1.B1_GRUPO  <= '" + xM440ParC( mv_par04 ) + "' AND "
	cSelect += " SB1.B1_TIPO   >= '" + xM440ParC( mv_par05 ) + "' AND SB1.B1_TIPO   <= '" + xM440ParC( mv_par06 ) + "' AND "
	cSelect += " SB1.B1_MSBLQL <> '1' AND SB1.B1_CONTRAT <> 'S' AND SB1.B1_TIPO <> 'BN' AND "
	cSelect += " SB1.D_E_L_E_T_ = ' ' "
	If lSomPend
		// MV_CH2=Sim: so produtos com pendencia em PV (SC6) OU empenho (SD4) OU OP (SC2).
		cSelect += xM440SqlFiltroPend( cFilC6, cFilD4, cFilC2, dLim )
	EndIf
	cSelect += " ORDER BY SB1.B1_COD "

	// Workaround: evita travamento em BeginQuery() (Embedded SQL do TReport)
	// abrindo o alias diretamente via TOPCONN/TcGenQry.
	If Select( cAliasSB1 ) > 0
		( cAliasSB1 )->( dbCloseArea() )
	EndIf

	Begin Sequence
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cSelect ), cAliasSB1, .F., .T. )
	Recover
		ConOut( "CVCOMR02: falha ao abrir query principal SB1." )
		Return NIL
	End Sequence

	oReport:SetMeter( ( cAliasSB1 )->( LastRec() ) )
	oSection1:Init()

	dbSelectArea( cAliasSB1 )
	While !oReport:Cancel() .And. !( cAliasSB1 )->( Eof() )

		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf

		cCod    := xM440PadCod( ( cAliasSB1 )->B1_COD )
		cDesc 	:= PadR( ( cAliasSB1 )->B1_DESC, TamSX3( "B1_DESC" )[1] )
		cTipo   := PadR( ( cAliasSB1 )->B1_TIPO, TamSX3( "B1_TIPO" )[1] )
		cGrupo  := PadR( ( cAliasSB1 )->B1_GRUPO, TamSX3( "B1_GRUPO" )[1] )
		cUM     := PadR( ( cAliasSB1 )->B1_UM, TamSX3( "B1_UM" )[1] )
		cLocPad := xM440PadLoc( ( cAliasSB1 )->B1_LOCPAD )

		// Totais SC6/SD4/SC2 e SB2 ja trazidos na query (LEFT JOIN agregados)
		nSalAtu := xM440QryGetN( cAliasSB1, "XM440_QATU" )
		nEntPrv := xM440QryGetN( cAliasSB1, "XM440_SALPEDI" )
		nPVPend := xM440QryGetN( cAliasSB1, "XM440_PV" )
		nOPPend := xM440QryGetN( cAliasSB1, "XM440_SD4" )

		If lSomPend .And. nPVPend == 0 .And. nOPPend == 0 .And. xM440QryGetN( cAliasSB1, "XM440_OPC" ) == 0
			( cAliasSB1 )->( dbSkip() )
			Loop
		EndIf

		nPontoPed := xM440GetN( cAliasSB1, "B1_EMIN" )
		dDataPP   := xM440DataPP( cAliasSB1 )
		nLoteEc   := xM440GetN( cAliasSB1, "B1_CRVLE" )
		nPctTol   := xM440GetN( cAliasSB1, "B1_TOLER" )
		nQEmb     := xM440GetN( cAliasSB1, "B1_QE" )
		nUprc     := ( cAliasSB1 )->B1_UPRC
		dUltCom   := ( cAliasSB1 )->B1_UCOM
		nPrValid  := ( cAliasSB1 )->B1_PRVALID
		cMarca    := ( cAliasSB1 )->B1_FABRIC
		cImport   := ( cAliasSB1 )->B1_IMPORT
		cMrpRs    := ( cAliasSB1 )->B1_CRVGRUP
		cFilExib  := AllTrim( cFilAnt )
		cLocExib  := cLocPad

		nEstSegCol := IIf( lSegSim, xM440GetEstSeg( cCod ), 0 )

		nTolerQtd := 0
		If xM440GetN( cAliasSB1, "B1_CRVLE" ) <> 0 .Or. nPctTol <> 0
			nTolerQtd := ( xM440GetN( cAliasSB1, "B1_CRVLE" ) * nPctTol / 100 )
		EndIf

		nQtdComp := xM440QtdComprar( nSalAtu, nEntPrv, nPVPend, nOPPend, nEstSegCol )

		If nQtdComp > 0
			cObs := "Comprar " + AllTrim( Transform( nQtdComp, PesqPict( "SB1", "B1_LE" ) ) )
		Else
			cObs := "Nao necessita compra. (Saldo Atual+Entrada Prevista) atende (PVs+OPs); "
			If lSegSim
				cObs += "Foi considerado o estoque de seguranca."
			Else
				cObs += "Nao foi considerado o estoque de seguranca."
			EndIf
		EndIf

		xM440DadosSA2( cFilA2, ( cAliasSB1 )->B1_PROC, ( cAliasSB1 )->B1_LOJPROC, aRev, aForn )
		cA2Rev   := aRev[1]
		cFornTxt := aForn[1]

		nVlrEst := IIf( nUprc == 0, 0, nQtdComp * nUprc )

		nPrazoEnt := xM440GetN( cAliasSB1, "B1_PE" )

		oSection1:PrintLine()

		( cAliasSB1 )->( dbSkip() )

	EndDo

	oSection1:Finish()

Return NIL

/*/{Protheus.doc} xM440ParC
Converte parametro SX para string segura em SQL/comparacoes.
/*/
Static Function xM440ParC( uPar )

	Local cRet := ""

	Do Case
	Case ValType( uPar ) == "C"
		cRet := uPar
	Case ValType( uPar ) == "N"
		cRet := AllTrim( Str( uPar ) )
	Case ValType( uPar ) == "D"
		cRet := DtoS( uPar )
	OtherWise
		cRet := ""
	EndCase

Return cRet

/*/{Protheus.doc} xM440ParDate
Data limite (par07): aceita D, string AAAAMMDD ou string vazia.
/*/
Static Function xM440ParDate( uPar )

	Local dRet := CtoD( "" )

	Do Case
	Case ValType( uPar ) == "D"
		dRet := uPar
	Case ValType( uPar ) == "C"
		If Len( AllTrim( uPar ) ) == 8
			dRet := StoD( uPar )
		ElseIf !Empty( uPar )
			dRet := CtoD( uPar )
		EndIf
	Case ValType( uPar ) == "N"
		If uPar > 0
			dRet := StoD( StrZero( uPar, 8 ) )
		EndIf
	EndCase

Return dRet

/*/{Protheus.doc} xM440ParLogico
Lista SX Sim/Nao: N=1 Sim, N=2 Nao; C pode vir SIM/NAO/1/2 do combobox.
/*/
Static Function xM440ParLogico( uPar )

	Local lRet := .F.
	Local cAux := ""

	Do Case
	Case ValType( uPar ) == "L"
		lRet := uPar
	Case ValType( uPar ) == "N"
		lRet := ( uPar == 1 )
	Case ValType( uPar ) == "C"
		cAux := Upper( AllTrim( uPar ) )
		If cAux == "N" .Or. cAux == "NAO" .Or. cAux == "NÃO" .Or. cAux == "2" ;
				.Or. cAux == "NO" .Or. cAux == "FALSE"
			lRet := .F.
		Else
			lRet := ( cAux == "S" .Or. cAux == "SIM" .Or. cAux == "1" .Or. cAux == "Y" .Or. cAux == "YES" .Or. cAux == "TRUE" )
		EndIf
	EndCase

Return lRet

/*/{Protheus.doc} xM440SXSim
Lista SX (Sim=1/Nao=2): .T. se algum canal (X1_VARIAVL ou mv_par da mesma pergunta) indica
Sim e nenhum indica Nao(2). cNom/cSeq = nomes das variaveis (ex.: MV_CH2, mv_par08).
/*/
Static Function xM440SXSim( cNom, cSeq )

	Local lRet := .F.
	Local nA   := 0
	Local nB   := 0

	If Empty( cNom ) .Or. Empty( cSeq )
		Return .F.
	EndIf

	Begin Sequence
		nA := xM440PNVal( &( cNom ) )
		nB := xM440PNVal( &( cSeq ) )
		If nA == 2 .Or. nB == 2
			lRet := .F.
		Else
			lRet := ( xM440ParLogico( &( cNom ) ) .Or. xM440ParLogico( &( cSeq ) ) )
		EndIf
	Recover
		lRet := .F.
	End Sequence

Return lRet

/*/{Protheus.doc} xM440QtdComprar
(SA+EP) - (PV+OP+SEG); se negativo, compra o modulo; senao zero.
/*/
Static Function xM440QtdComprar( nSA, nEP, nPV, nOP, nSEG )

	Local nCalc := ( nSA + nEP ) - ( nPV + nOP + nSEG )

Return IIf( nCalc < 0, Abs( nCalc ), 0 )

/*/{Protheus.doc} xM440GetEstSeg
Le estoque de seguranca direto da SB1 para evitar dependencia de estrutura
interna usada por RetFldProd/CalcEstSeg no ambiente.
/*/
Static Function xM440GetEstSeg( cCod )

	Local nRet := 0
	Local cFil := xFilial( "SB1" )

	dbSelectArea( "SB1" )
	dbSetOrder( 1 )
	If SB1->( dbSeek( cFil + cCod ) )
		If SB1->( FieldPos( "B1_ESTSEG" ) ) > 0
			nRet := SB1->B1_ESTSEG
		EndIf
	EndIf

Return nRet

/*/{Protheus.doc} xM440GetN
/*/
Static Function xM440GetN( cAlias, cCampo )

Return RetFldProd( xM440PadCod( ( cAlias )->B1_COD ), cCampo, cAlias )

/*/{Protheus.doc} xM440GetD
/*/
Static Function xM440GetD( cAlias, cCampo )

Return RetFldProd( xM440PadCod( ( cAlias )->B1_COD ), cCampo, cAlias )

/*/{Protheus.doc} xM440DataPP
/*/
Static Function xM440DataPP( cAlias )

	If ( cAlias )->( FieldPos( "B1_DTINIPP" ) ) > 0
		Return ( cAlias )->B1_DTINIPP
	EndIf
Return CtoD( "" )

/*/{Protheus.doc} xM440DadosSA2
/*/
Static Function xM440DadosSA2( cFilA2, cProc, cLoja, aA2Rev, aFornTxt )

	Local cP := AllTrim( cProc )
	Local cL := AllTrim( cLoja )
	Local cN := ""
	Local cM := ""

	aA2Rev[1]   := Space( 1 )
	aFornTxt[1] := ""

	If Empty( cP )
Return
	EndIf

	dbSelectArea( "SA2" )
	dbSetOrder( 1 )
	If SA2->( dbSeek( cFilA2 + cP + cL ) )
		If SA2->( FieldPos( "A2_CRVREV" ) ) > 0
			aA2Rev[1] := SA2->A2_CRVREV
		EndIf
		cN := AllTrim( SA2->A2_NREDUZ )
		cM := AllTrim( SA2->A2_NOME )
		// B1_PROC+B1_LOJPROC - A2_NREDUZ - A2_NOME (ex.: USP01 - US - PHARMACOPEIA CONSULT)
		aFornTxt[1] := AllTrim( cP + cL ) + " - " + cN + " - " + cM
	Else
		aFornTxt[1] := AllTrim( cP + cL )
	EndIf

Return

/*/{Protheus.doc} xM440SumPV
Soma (C6_QTDVEN - C6_QTDENT) em SC6 - leitura por indice XM440_ORD_SC6.
/*/
Static Function xM440SumPV( cFil, cProd, dLim )

	Local nAcum := 0
	Local cChave := cFil + xM440PadCod( cProd )
	Local nGuard := 0
	Local nMaxGuard := 20000

	dbSelectArea( "SC6" )
	dbSetOrder( XM440_ORD_SC6 )
	If SC6->( dbSeek( cChave, .T. ) )
		While !SC6->( Eof() ) .And. SC6->C6_FILIAL + SC6->C6_PRODUTO == cChave
			nGuard++
			If nGuard > nMaxGuard
				Exit
			EndIf
			If SC6->C6_QTDENT < SC6->C6_QTDVEN .And. SC6->C6_BLQ <> "R" 
				If Empty( dLim ) .Or. SC6->C6_CRVENT <= dLim
					nAcum += SC6->C6_QTDVEN - SC6->C6_QTDENT
				EndIf
			EndIf
			SC6->( dbSkip() )
		EndDo
	EndIf

Return nAcum

/*/{Protheus.doc} xM440SumSD4
Soma D4_QUANT <> 0 - indice XM440_ORD_SD4.
/*/
Static Function xM440SumSD4( cFil, cProd )

	Local nAcum := 0
	Local cChave := cFil + xM440PadCod( cProd )
	Local nGuard := 0
	Local nMaxGuard := 20000

	dbSelectArea( "SD4" )
	dbSetOrder( XM440_ORD_SD4 )
	If SD4->( dbSeek( cChave, .T. ) )
		While !SD4->( Eof() ) .And. SD4->D4_FILIAL + SD4->D4_COD == cChave
			nGuard++
			If nGuard > nMaxGuard
				Exit
			EndIf
			If SD4->D4_QUANT <> 0
				nAcum += SD4->D4_QUANT
			EndIf
			SD4->( dbSkip() )
		EndDo
	EndIf

Return nAcum

/*/{Protheus.doc} xM440TemOPPend
OP pendente quando C2_DATRF vazio; filtro C2_DATPRI <= dLim quando dLim preenchida.
/*/
Static Function xM440TemOPPend( cFil, cProd, dLim )

	Local lTem := .F.
	Local cChave := cFil + xM440PadCod( cProd )
	Local nGuard := 0
	Local nMaxGuard := 20000

	dbSelectArea( "SC2" )
	dbSetOrder( XM440_ORD_SC2 )
	If SC2->( dbSeek( cChave, .T. ) )
		While !SC2->( Eof() ) .And. SC2->C2_FILIAL + SC2->C2_PRODUTO == cChave
			nGuard++
			If nGuard > nMaxGuard
				Exit
			EndIf
			If Empty( SC2->C2_DATRF )
				If Empty( dLim ) .Or. SC2->C2_DATPRI <= dLim
					lTem := .T.
					Exit
				EndIf
			EndIf
			SC2->( dbSkip() )
		EndDo
	EndIf

Return lTem
