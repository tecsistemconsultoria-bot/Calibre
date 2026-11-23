#Include 'Parmtype.ch'
#Include "Protheus.ch"
#Include "TOPCONN.CH"
#include "rwmake.ch"

/***********************************************************************
Autor: Rafael
Data: 13/12/2010
Consultoria:  
Uso: Calibre
Tipo: Atualiza??es
Rotina: Faturamento
Fun??o: VPendII
Info: Vis. Pend II
------------------------------------------------------------------------
Alteracoes recentes:
- Otávio Barreiro - 28/10/2026
  Reservado (grid e Exibir Reservas) volta a ser a qtd liberada (C9_QTDLIB)
  como na versao 12/03/26. Numeracao da grid pelo C6_ITEM (01/02);
  sufixo 01A/01B so em faturamento parcial.
  Exibir Reservas sem SC0: Lote=C9_LOTECTL; lista toda liberacao SC9.
- Fernando Pessoa / Tecsistem - 06/08/2026
  Status apos Reservado; 09 so com Reservado>0; Exibir Reservas:
  coluna Reservado=C0_QUANT, inclui C9_RESERVA, filtra C9_RESERVA<>vazio.
- Fernando Pessoa / Tecsistem - 04/08/2026
  Quebra de linha em faturamento parcial (status por C9_NFISCAL;
  gera linha faturada + linha pendente). Funcoes VPIAddLin/VPIStatNF/VPIHasSC9A.
- Fernando Pessoa / Tecsistem - 30/07/2026
  VL Frete CIF; Tem contrato Sim/Nao; Reservado via SC0/C9_RESERVA;
  Status 12 via SZJ/SZI; remover bloqueio grid vazia; Aguardando OS (C9_ORDSEP).
************************************************************************/
User Function VPendII()

	Local _aArea   := GetArea()
	Local xESTICM  := GetMV("MV_ESTICM")
	Local bSavErr

	Static oDlg
	Static oLbx
	Static oSayNPed
	Static oSayEmiss
	Static oSayHora
	Static oSayDesCli
	Static oSayDesTran
	Static oSayDesPgt
	Static oSayFatur
	Static oSayTpLib
	Static oSayTPFrete
	Static oSayMenNota
	Static oSayMenNII
	Static oSayVinc
	Static oSayPdVin
	Static oSayVendInt
	Static oSayVendExt
	Static oSayGerent
	Static oSayVlFrete
	Static oSayXLead
	Static oSayXContr
	Static oSayXLimFat
	Static oSayXLimLot
	Static oSayMoeda
	Static oSayFatPar
	Static oSayMultPV
	Static oMemo
	Static oMemoNF
	Static oSayVLTOT
	Static oBtnReserva
	Static oSayVlFreCif
	Static oSayTipoPed
	Static oSayFreq
	Static oGrpCab1
	Static oGrpCab2
	Static oGrpCab3

	Private oVPIFatal := Nil
	Private cLblFrete := ""
	Private nVlFrete  := 0
	Private nVlFreCif := 0
	Private nXLead    := 0
	Private cXContr   := ""
	Private nXLimFat  := 0
	Private nXLimLot  := 0
	Private cTipoPed  := ""
	Private cFreq     := ""
	Private cObsNF    := ""
	Private cNPed
	Private aLbx := {}
	Private cPedVinc := ""

	Private _NumPed
	Private cDesCli
	Private cCoCli
	Private cLoja
	Private cFornc
	Private cFatPar := ""
	Private cMultPv := ""
	Private cDesTran
	Private cDesPgt
	Private cFatur
	Private cTpLib
	Private cTPFrete
	Private cMenNota
	Private cMenNII
	Private cVinc
	Private cFrete
	Private cCodTran
	Private cMoeda
	Private cEmiss
	Private cHora
	Private cVendInt
	Private cVendExt
	Private cGerent
	Private cJunCli
	Private cJunTransp
	Private nVLTOT := 0
	Private _TipPV
	Private _vVlDEsc :=   0
	Private _actxt:=''
	Private cLbx    := ""

	bSavErr := ErrorBlock({|e| oVPIFatal := e, .T.})

	If Select("SC5") == 0 .Or. Empty(SC5->C5_NUM)
		MsgAlert("Posicione no pedido de venda antes de abrir a Vis. Pend II.", "Vis. Pend II - VPENDII")
		RestArea(_aArea)
		Return Nil
	EndIf

	ConOut("[VPendII] Inicio pedido " + AllTrim(SC5->C5_NUM))

	_NumPed	:= SC5->C5_NUM
	_TipPV	 := VPISafePo("SC5", 1, xFilial("SC5") + _NumPed, "C5_TIPO")

	If !(_TipPV $ "D|B")
		cDesCli  := VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE, "A1_NOME")
		cCoCli   := VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE, "A1_COD")
		cLoja    := VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE, "A1_LOJA")
		cFatPar  := VPISimNao(VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE, "A1_XFATPAR"))
		cMultPv  := VPISimNao(VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE, "A1_XMULTPV"))
		cXContr  := VPISimNao(VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_XCONTR")) // Fernando Pessoa / Tecsistem - 30/07/2026
		nXLimFat := VPIVal(VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_XLIMFAT"))
		nXLimLot := VPIVal(VPISafePo("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_XLIMLOT"))
	Else
		cFornc   := VPISafePo("SA2", 1, xFilial("SA2") + SC5->C5_CLIENTE, "A2_COD")
		cDesCli  := VPISafePo("SA2", 1, xFilial("SA2") + SC5->C5_CLIENTE, "A2_NOME")
	EndIf

	cEmiss   := VPIDtFmt(SC5->C5_EMISSAO)
	cHora    := SC5->C5_CRVHORA
	cDesTran := VPISafePo("SA4", 1, xFilial("SA4") + SC5->C5_TRANSP, "A4_NREDUZ")
	cCodTran := SC5->C5_TRANSP
	cMoeda   := AllTrim(VPISafePo("NJ7", 1, xFilial("NJ7") + cValToChar(SC5->C5_MOEDA), "NJ7_DESCRI"))
	cDesPgt  := VPISafePo("SE4", 1, XFILIAL("SE4") + SC5->C5_CONDPAG, "E4_DESCRI")
	cFatur   := VPISimNao(SC5->C5_XFATURA)
	cTpLib	 := IIF(AllTrim(SC5->C5_TIPLIB) == '1', 'Libera Por Item', 'Libera por Pedido')
	cVinc    := SC5->C5_XPEDVIN
	cFrete	 := AllTrim(SC5->C5_TPFRETE)
	cTipoPed := VPITpPed(VPISafePo("SC5", 1, xFilial("SC5") + _NumPed, "C5_XTPPED"))
	cFreq    := VPIFreq(VPIFldC("SC5", "C5_XFREQ"))
	If Empty(cFreq)
		cFreq := VPIFreq(VPIFldC("SC5", "C5_ZFREQ"))
	EndIf
	cObsNF   := AllTrim(SC5->C5_MENNOTA)
	nXLead   := VPILeadTr(cFrete, SC5->C5_TRANSP, SC5->C5_ZINFFRE)

	If !(_TipPV $ "D|B")
		cMenNota := SUBSTR(SC5->C5_MENNOTA, 1, 40)
		cMenNII	 := SUBSTR(SC5->C5_MENNOTA, 41, 40)
	Else
		cMenNota := SUBSTR(SC5->C5_MENNOTA, 1, 100)
	EndiF

	cVendInt := SUBSTR(VPISafePo("SA3", 1, xFilial("SA3") + SC5->C5_VEND1, "A3_NOME"), 1, 30)
	cVendExt := SUBSTR(VPISafePo("SA3", 1, xFilial("SA3") + SC5->C5_VEND2, "A3_NOME"), 1, 30)
	cGerent  := SUBSTR(VPISafePo("SA3", 1, xFilial("SA3") + SC5->C5_VEND3, "A3_NOME"), 1, 30)
	_vVlDEsc := SC5->C5_DESCONT
	nVlFrete := SC5->C5_FRETE
	nVlFreCif := VPIVal(VPISafePo("SC5", 1, xFilial("SC5") + _NumPed, "C5_ZFRETE"))
	cLblFrete := ""
	If Type("RetTitle") == "B"
		cLblFrete := AllTrim(RetTitle("C5_FRETE"))
	EndIf
	If Empty(cLblFrete)
		cLblFrete := "Vl Frete"
	EndIf
	cNPed    := AllTrim(_NumPed)

	aLbx := {}

	VPIWait("Aguarde", "Carregando itens, status e totais do pedido...", {|| VPICarga(xESTICM)})

	ConOut("[VPendII] GLbxII retornou " + cValToChar(Len(aLbx)) + " linha(s)")

	// Fernando Pessoa / Tecsistem - 30/07/2026
	// Abre a tela mesmo sem itens na grid (pedido ja liberado p/faturar,
	// TES sem movimento de estoque etc.) â€” sem MsgInfo que bloqueava a visualizacao.
	ConOut("[VPendII] VPendTot concluido nVLTOT=" + cValToChar(nVLTOT))

	cJunCli:= IIf(!(_TipPV $ "D|B"), cCoCli+"-"+cLoja+" - "+cDesCli, cFornc+" - "+cDesCli)
	cJunTransp := cCodTran+" - "+cDesTran

	DEFINE MSDIALOG oDlg TITLE "Detalhes de Pedido de Venda Calibre" FROM 000, 000  TO 580, 1350 COLORS 0, 16777215 PIXEL

	// Cabecalho reorganizado em tres blocos conforme definicao do cliente.
	@ 003, 005 GROUP oGrpCab1 TO 098, 225 OF oDlg PIXEL
	@ 003, 230 GROUP oGrpCab2 TO 098, 425 OF oDlg PIXEL
	@ 003, 430 GROUP oGrpCab3 TO 098, 675 OF oDlg PIXEL

	// Bloco 1: identificacao, moeda, vendedores e total.
	@ 008, 012 SAY "Pedido:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 040 SAY oSayNPed VAR cNPed SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 075 SAY "Emissao:" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 110 SAY oSayEmiss VAR cEmiss SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 155 SAY "Hora Emissao:" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 198 SAY oSayHora VAR cHora SIZE 024, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 018, 012 SAY IIf(_TipPV $ "D|B", "Fornecedor:", "Cliente:") SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 050 SAY oSayDesCli VAR cJunCli SIZE 170, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 028, 012 SAY "Moeda:" SIZE 027, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 040 SAY oSayMoeda VAR cMoeda SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 098 SAY "Pagamento:" SIZE 038, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 138 SAY oSayDesPgt VAR cDesPgt SIZE 082, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 038, 012 SAY "Vend.Int.:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 038, 055 SAY oSayVendInt VAR cVendInt SIZE 165, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 048, 012 SAY "Vend.Ext/Rep.:" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 048, 067 SAY oSayVendExt VAR cVendExt SIZE 153, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 058, 012 SAY "Ger./Coord.:" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 058, 060 SAY oSayGerent VAR cGerent SIZE 160, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 012 SAY "Vl Total c/IPI + ST + Frete (FOB):" SIZE 110, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 125 SAY oSayVLTOT VAR nVLTOT SIZE 090, 007 PICTURE "@E 9,999,999.99" OF oDlg COLORS 0, 16777215 PIXEL

	// Bloco 2: regras comerciais do pedido.
	@ 008, 237 SAY "Fatura?" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 270 SAY oSayFatur VAR cFatur SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 305 SAY "Tipo Liberacao:" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 360 SAY oSayTpLib VAR cTpLib SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 018, 237 SAY "Fat Parcial:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 268 SAY oSayFatPar VAR cFatPar SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 305 SAY "Mul PV NF:" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 360 SAY oSayMultPV VAR cMultPv SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 028, 237 SAY "Tipo Pedido:" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 268 SAY oSayTipoPed VAR cTipoPed SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 305 SAY "Frequencia:" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 360 SAY oSayFreq VAR cFreq SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 038, 237 SAY "Tem contrato:" SIZE 043, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 038, 283 SAY oSayXContr VAR cXContr SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 038, 305 SAY "Data Lim.Fat:" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 038, 360 SAY oSayXLimFat VAR nXLimFat SIZE 008, 007 PICTURE "99" OF oDlg COLORS 0, 16777215 PIXEL
	@ 038, 370 SAY "Val.Min.Lote:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 038, 410 SAY oSayXLimLot VAR nXLimLot SIZE 014, 007 PICTURE "@E 999" OF oDlg COLORS 0, 16777215 PIXEL

	// Bloco 3: frete, lead time e observacoes.
	@ 008, 437 SAY "Transportadora:" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 492 SAY oSayDesTran VAR cJunTransp SIZE 165, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 018, 437 SAY "Tipo Frete:" SIZE 038, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 478 SAY oSayTPFrete VAR cTPFrete SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 515 SAY "Vl Frete (FOB):" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 567 SAY oSayVlFrete VAR nVlFrete SIZE 032, 007 PICTURE "@E 9,999,999.99" OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 602 SAY "VL Frete CIF:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL // Fernando Pessoa / Tecsistem - 30/07/2026
	@ 018, 645 SAY oSayVlFreCif VAR nVlFreCif SIZE 028, 007 PICTURE "@E 999,999.99" OF oDlg COLORS 0, 16777215 PIXEL

	@ 028, 437 SAY "Lead Time Transp. (dias uteis):" SIZE 100, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 540 SAY oSayXLead VAR nXLead SIZE 035, 007 PICTURE "@E 999" OF oDlg COLORS 0, 16777215 PIXEL

	@ 038, 437 SAY "Obs. NF:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 046, 437 GET oMemoNF VAR cObsNF MEMO SIZE 220, 015 OF oDlg PIXEL
	@ 064, 437 SAY "Obs. Interna:" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 072, 437 GET oMemo VAR _actxt MEMO SIZE 220, 022 OF oDlg PIXEL

	@ 115, 005 LISTBOX oLbx VAR cLbx FIELDS HEADER OemtoAnsi("Item"),;
		Padr(OemtoAnsi("Cod.Produto"),15),;
		OemtoAnsi("Desc. Produto"),;
		Padr(OemtoAnsi("Armazem"),10),;
		Padr(OemtoAnsi("Dt p/Fatur"),10),;
		Padr(OemtoAnsi("Dt Entrega"),10),;
		Padr(OemtoAnsi("Qtd Vendida"),11),;
		Padr(OemtoAnsi("Saldo Est."),10),;
		Padr(OemtoAnsi("Saldo Disp."),11),;
		Padr(OemtoAnsi("Qtd Entregue"),12),;
		Padr(OemtoAnsi("Qtd. Saldo"),10),;
		Padr(OemtoAnsi("Reservado"),10),;
		Padr(OemtoAnsi("Status"),22),; // Fernando Pessoa / Tecsistem - 06/08/2026 - movido apos Reservado
		Padr(OemtoAnsi("TES"),4),;
		Padr(OemtoAnsi("CFOP"),06),;
		Padr(OemtoAnsi("Prazo Entrega"),14),;
		Padr(OemtoAnsi("Marit/Aereo"),12),;
		Padr(OemtoAnsi("PE atualizado"),14),;
		Padr(OemtoAnsi("Processo Imp."),14),;
		Padr(OemtoAnsi("PO"),12),;
		Padr(OemtoAnsi("Numero OS"),10),;
		Padr(OemtoAnsi("OS Data Emissao"),16),;
		Padr(OemtoAnsi("OS Hora Emissao"),16),;
		Padr(OemtoAnsi("Carga"),08),;   //dyego 23/09/14
		Padr(OemtoAnsi("Data"),08),;   //dyego 23/09/14
		Padr(OemtoAnsi("Hora"),08) ;
		SIZE 660, 170 OF oDlg COLORS 0, 16777215 PIXEL
	oLbx:SetArray(aLbx)

	oLbx:bLine := {|| VPILinBx(oLbx:nAt)}

	@ 100, 610 BUTTON oBtnReserva PROMPT "Exibir Reservas" SIZE 051, 012 OF oDlg ACTION VPIBtnRs() PIXEL

	ConOut("[VPendII] Abrindo dialog pedido " + AllTrim(_NumPed))
	ACTIVATE MSDIALOG oDlg
	ConOut("[VPendII] Dialog encerrado pedido " + AllTrim(_NumPed))
	oVPIFatal := Nil

	ErrorBlock(bSavErr)

	If ValType(oVPIFatal) == "O"
		VPIAlrt(VPIMsgEr(oVPIFatal, IIf(!Empty(_NumPed), _NumPed, SC5->C5_NUM)))
	EndIf

	RestArea(_aArea)

Return Nil

/*=================================================================
Info: Carga da grid e totais (executada dentro do VPIWait)
*==================================================================*/
Static Function VPICarga(xESTICM)

	aLbx := GLbxII()

	If !Empty(aLbx)
		VPendTot(xESTICM, .F.)
	EndIf

Return Nil

/*=================================================================
Info: Barra/mensagem de processamento (FWMsgRun / MsAguarde)
*==================================================================*/
Static Function VPIWait(cTitulo, cMsg, bAction, oDlgPai)

	Local lDisab := .F.
	Local lFeito := .F.

	Default cTitulo := "Aguarde"
	Default cMsg    := "Processando..."
	Default bAction := {|| Nil}
	Default oDlgPai := Nil

	If ValType(bAction) != "B"
		Return Nil
	EndIf

	If ValType(oDlgPai) == "O"
		BEGIN SEQUENCE
			oDlgPai:Disable()
			lDisab := .T.
		RECOVER
			lDisab := .F.
		END SEQUENCE
	EndIf

	BEGIN SEQUENCE
		If FindFunction("FWMsgRun")
			FWMsgRun(Nil, bAction, cTitulo, cMsg)
			lFeito := .T.
		EndIf
	RECOVER
		lFeito := .F.
	END SEQUENCE

	If !lFeito
		BEGIN SEQUENCE
			If FindFunction("MsAguarde")
				MsAguarde(bAction, cMsg)
				lFeito := .T.
			EndIf
		RECOVER
			lFeito := .F.
		END SEQUENCE
	EndIf

	If !lFeito
		Eval(bAction)
	EndIf

	If lDisab
		BEGIN SEQUENCE
			oDlgPai:Enable()
		RECOVER
		END SEQUENCE
	EndIf

Return Nil

/*=================================================================
Info: Exibe alerta na tela (Web ou Desktop) e grava log no AppServer
*==================================================================*/
Static Function VPIAlrt(cMsg)

	Default cMsg := ""

	VPIWrLog(cMsg)
	ConOut("[VPendII] ERRO: " + cMsg)

	If Type("FWAlertMessage") == "B"
		FWAlertMessage(cMsg, "Vis. Pend II - VPENDII")
	ElseIf Type("ApMsgAlert") == "B"
		ApMsgAlert(cMsg, "Vis. Pend II - VPENDII")
	Else
		MsgAlert(cMsg, "Vis. Pend II - VPENDII")
	EndIf

Return Nil

/*=================================================================
Autor:
Data: 02/04/2026
Consultoria:
Uso: Calibre
Info: Calcula totais do pedido (antes do dialog)
*==================================================================*/
Static Function VPendTot(xESTICM,lCalcIPI)

	Local cQRYVinc := ""
	Local cQRYTOT := ""
	Local nVlTotPV := 0
	Local _VlFret := 0
	Local _VlFreItem := 0

	Default lCalcIPI := .F.

	If !empty(cVinc)
		cQRYVinc := " SELECT C5_NUM "
		cQRYVinc += " FROM " + RetSqlName("SC5") + " SC5 "
		cQRYVinc += " WHERE SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
		cQRYVinc += " 		AND SC5.C5_XPEDVIN = '" +cVinc+ "' "
		cQRYVinc += " 		AND SC5.D_E_L_E_T_ <> '*' "
		cQRYVinc += "       AND SC5.C5_NUM <> '"+_NumPed+"' "
		cQRYVinc := ChangeQuery(cQRYVinc)
		TcQuery cQRYVinc New Alias "QRYVIN"
		QRYVIN->(DbGoTop())
		cPedVinc := " "
		While QRYVIN->(!EoF())
			cPedVinc += "/"+QRYVIN->C5_NUM
			QRYVIN->(DbSkip())
		EndDo
		QRYVIN->(DbCloseArea())
	EndIf

	_VlFret	:= SC5->C5_FRETE
	_vVlDEsc := SC5->C5_DESCONT
	_actxt:=SC5->C5_CRVOBS

	IIF(Select("QRYTOT")!= 0, QRYTOT->(DbCLoseArea()), )
	cQRYTOT := " SELECT SUM(C6_VALOR) AS VLTOTAL"
	cQRYTOT += " FROM " + RetSqlName("SC6") + " SC6 "
	cQRYTOT += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cQRYTOT += " 		AND SC6.D_E_L_E_T_ <> '*' "
	cQRYTOT += "       AND SC6.C6_NUM = '"+_NumPed+"' "
	cQRYTOT += "       AND SC6.C6_BLQ <> 'R' "

	cQRYTOT := ChangeQuery(cQRYTOT)
	TcQuery cQRYTOT New Alias "QRYTOT"
	QRYTOT->(DbGoTop())
	nVlTotPV := QRYTOT->VLTOTAL
	QRYTOT->(DbCloseArea())

	IIF(Select("QRYTOT")!= 0, QRYTOT->(DbCLoseArea()), )
	cQRYTOT := " SELECT C6_VALOR AS VLTOTAL, ((CASE WHEN F4_IPI = 'S' THEN C6_XPIPI/100 ELSE 0 END))*C6_VALOR AS VLIPI, (CASE WHEN F4_IPI = 'S' THEN C6_XPIPI ELSE 0 END) AS ALIQIPI, C6_PICMRET AS PERST, C6_ITEM  "
	cQRYTOT += " FROM " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4 "
	cQRYTOT += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cQRYTOT += " 		AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
	cQRYTOT += " 		AND SC6.D_E_L_E_T_ <> '*' "
	cQRYTOT += " 		AND SF4.D_E_L_E_T_ <> '*' "
	cQRYTOT += "       AND SC6.C6_NUM = '"+_NumPed+"' "
	cQRYTOT += "       AND SC6.C6_BLQ <> 'R' "
	cQRYTOT += "       AND SC6.C6_TES = SF4.F4_CODIGO "
	cQRYTOT := ChangeQuery(cQRYTOT)
	
	TcQuery cQRYTOT New Alias "QRYTOT"
	QRYTOT->(DbGoTop())
	
	nVLTOT := 0
	
	While !QRYTOT->(Eof())
		nVLTOT := nVLTOT + QRYTOT->VLTOTAL
		If _VlFret > 0 .And. nVlTotPV > 0
			_VlFreItem	:= ( (_VlFret*QRYTOT->VLTOTAL) / nVlTotPV )
			If QRYTOT->ALIQIPI > 0      //O produto tem IPI e frete
				nVLTOT := nVLTOT + QRYTOT->VLIPI + _VlFreItem + (_VlFreItem*(QRYTOT->ALIQIPI/100))
				lCalcIPI := .T.
			Else  						// O produto nao tem IPI mais tem frete
				nVLTOT := nVLTOT + _VlFreItem
			EndIf
		Else //Pedido nao tem Frete
			nVLTOT := nVLTOT + QRYTOT->VLIPI

			If QRYTOT->VLIPI > 0
				lCalcIPI := .T.
			Endif
		EndIf

		// TEM ST Subst. Tributaria
		If QRYTOT->PERST >0
			nxTotSol := nxTotIcm := nxBasIcm := nxSubTot := nxTotIPI := nxVlrIPI := nxICMS := nxTotICMS := nxTotalGeral := nxPesoItem := nxTotalItem := nxTotalNota := 0
			dbSelectArea("SC5")
			dbSetOrder(01)
			dbSeek(xFilial("SC5")+_NumPed)
			dbSelectArea("SA1")
			dbSetOrder(01)
			dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
			dbSelectArea("SC6")
			dbSetOrder(01)
			dbSeek(xFilial("SC6")+_NumPed+QRYTOT->C6_ITEM)
			If Found()
				// Calculo ST e outros impostos
				MaFisSave()
				MaFisEnd()
				MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C","N",SC5->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")
				MaFisAdd(        SC6->C6_PRODUTO,;
					SC6->C6_TES,;
					SC6->C6_QTDVEN,;
					SC6->C6_PRUNIT,;
					SC6->C6_VALDESC,;
					"",;
					"",;
					0,;
					0,;
					0,;
					0,;
					0,;
					(SC6->C6_QTDVEN*SC6->C6_PRUNIT),;
					0,;
					0,;
					0)
				_nAliqIcm := MaFisRet(1,"IT_ALIQICM")
				_nValIcm  := MaFisRet(1,"IT_VALICM" )
				_nBaseIcm := MaFisRet(1,"IT_BASEICM")
				_nValIpi  := MaFisRet(1,"IT_VALIPI" )
				_nBaseIpi := MaFisRet(1,"IT_BASEICM")
				_nValMerc := MaFisRet(1,"IT_VALMERC")
				_nValSol  := MaFisRet(1,"IT_VALSOL" )

				_nValSol := round(( _nValMerc+_nValIpi) *(1+(QRYTOT->PERST/100)),2)
				_xxnPerIcm := Val(Subs(xESTICM,AT(SA1->A1_EST,xESTICM)+2,2))
				_nValSol := ROUND(((_nValSol*_xxnPerIcm)/100)-_nValIcm,2)

				nVLTOT := nVLTOT + _nValSol
				lCalcIPI := .T.

				MaFisEnd()
				MaFisRestore()
			Endif
		Endif

		dbSelectArea("QRYTOT")
		QRYTOT->(dbSkip())
	End

	If _vVlDEsc > 0
		nVLTOT := ROUND(nVLTOT,2) - _vVlDEsc
	EndIf
	
	QRYTOT->(DbCloseArea())

	DO CASE
	CASE cFrete == 'F'
		cTPFrete := "FOB"
	CASE cFrete == 'C'
		cTPFrete := "CIF"
	CASE cFrete == 'T'
		cTPFrete := "Redespacho"
	CASE cFrete == 'S'
		cTPFrete := "Sem Frete"
	END DO

	//Calculo do IPI do Pedido de Vendas
	If lCalcIPI <> .T.
		nVLTOT := nVLTOT + xIPI()
	Endif

Return(lCalcIPI)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function GetaLbx()

	Local aRetorno 		:= {}
	Local cQrySC6 		:= ""
	Local _SaldoEst 	:= 0
	Local _Bloqueado 	:= 0

	cQrySC6 := " SELECT C6.C6_NUM 		AS PEDIDO,  "
	cQrySC6 += "		C6.C6_QTDVEN 	AS QTDVEN,   "
	cQrySC6 += "		C6.C6_QTDENT 	AS QTDENT,   "
	cQrySC6 += "		C6.C6_CRVENT 	AS ENTREGA, "
	cQrySC6 += "		C6.C6_ITEM 		AS ITEM,	"
	cQrySC6 += "		C6.C6_PRODUTO 	AS PRODUTO, "
	cQrySC6 += "		C6.C6_LOCAL 	AS ARMAZEM, "
	cQrySC6 += "		B1.B1_DESC 		AS DESCPROD, "
	cQrySC6 += "		C6.C6_TES		AS TES, "
	cQrySC6 += "        (cast(B1.B1_PE as int)+cast(B1.B1_CRVPA as int)) AS SOMA, "
	cQrySC6 += "		C6.C6_CRVENT AS PRZENT,"
	cQrySC6 += "        C6.C6_ENTREG  AS DTENTREGA, "
	cQrySC6 += "		C6.C6_NOTA, "
	cQrySC6 += " coalesce( (SELECT SUM(C9.C9_QTDLIB) AS  C9_QTDLIB FROM "+RetSqlName("SC9")+" C9 "
	cQrySC6 += " 			WHERE C9.D_E_L_E_T_ = '' "
	cQrySC6 += " 					AND C9.C9_FILIAL = C6.C6_FILIAL "
	cQrySC6 += " 					AND C9_NFISCAL = '' "
	cQrySC6 += " 					AND C9_BLEST = '' "
	cQrySC6 += " 					AND C9_CARGA = '' "
	cQrySC6 += "					AND C9_BLCRED <> '09' "
	cQrySC6 += " 					AND C9_PEDIDO = C6.C6_NUM "
	cQrySC6 += " 					AND C9_ITEM = C6.C6_ITEM  "
	cQrySC6 += " 	    	 GROUP BY C9_PEDIDO,C9_ITEM ),0) AS LIBERADO "
	cQrySC6 += " FROM "+RetSqlName("SC6")+" C6 "
	cQrySC6 += "		INNER JOIN "+RetSqlName("SB1")+" B1 ON C6.C6_PRODUTO = B1.B1_COD AND "
	cQrySC6 += "   						   		B1.B1_FILIAL='"+XFILIAL("SB1")+"' AND " //ALTERADO DYEGO 09/07/14
	cQrySC6 += "								C6.D_E_L_E_T_ = B1.D_E_L_E_T_ "
	cQrySC6 += " WHERE C6.C6_FILIAL = '"+xFilial("SC6")+"' "
	cQrySC6 += " 	AND C6.C6_NUM = '"+SC5->C5_NUM+"' "
	cQrySC6 += " 	AND C6.D_E_L_E_T_ = '' "
	cQrySC6 += " ORDER BY C6_NUM "

	cQrySC6 := ChangeQuery(cQrySC6)
	TcQuery cQrySC6 New Alias "QRYSC6"
	QRYSC6->(DbGoTop())
	
	While QRYSC6->(!EoF())
		_SaldoEst := GetSaldo(QRYSC6->PRODUTO,QRYSC6->ARMAZEM)
		_Bloqueado := IIF( empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. !empty(SC9->C9_CARGA),0, QRYSC6->QTDVEN-(QRYSC6->QTDENT+QRYSC6->LIBERADO))
		_DtFat := SubStr(QRYSC6->ENTREGA,7,2)+"/"+SubStr(QRYSC6->ENTREGA,5,2)+"/"+SubStr(QRYSC6->ENTREGA,1,4)
		_PrzoEntr := StoD(QRYSC6->DTENTREGA)
		_cPrzoEntr := SubStr(DtoS(_PrzoEntr),7,2)+"/"+SubStr(DtoS(_PrzoEntr),5,2)+"/"+SubStr(DtoS(_PrzoEntr),1,4)
		If !empty(QRYSC6->C6_NOTA)
			_QStatus  := "7-Faturado"
		Else
			_QStatus  := GetStatus(QRYSC6->PEDIDO,QRYSC6->ITEM)
		EndIf

		aAdd(aRetorno,{QRYSC6->ITEM,QRYSC6->PRODUTO,SubStr(QRYSC6->DESCPROD,1,30),_DtFat,_cPrzoEntr,QRYSC6->QTDVEN,;
			_SaldoEst,QRYSC6->QTDENT,_Bloqueado,QRYSC6->LIBERADO,_QStatus})

		QRYSC6->(DbSkip())
	EndDo

	QRYSC6->(DbCloseArea())

Return(aRetorno)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function GetaLbx1(cProd,cPed)

	Local aRetorno := {}
	Local cQryPedEst := ""

	cQryPedEst := " SELECT C9.C9_QTDLIB AS QTDLIB,
	cQryPedEst += " 		C6.C6_QTDVEN AS QTDVEN, "
	cQryPedEst += " 		C6.C6_CLI AS CLIENTE, "
	cQryPedEst += " 		C9.C9_LOTECTL AS LOTE, "
	cQryPedEst += "			C6.C6_XEMISSA AS EMISSAO,  "
	cQryPedEst += "			C6.C6_QTDENT AS QTDENT, "
	cQryPedEst += " 		C9.C9_PEDIDO AS PEDIDO, "
	cQryPedEst += " 		C6.C6_CRVENT AS ENTREGA, "
	cQryPedEst += " 		C6.C6_TES	 AS TES,
	cQryPedEst += " 		C5.C5_VEND1 AS VENDEDOR,"
	cQryPedEst += " 	   (SELECT SUM(SC9.C9_QTDLIB) "
	cQryPedEst += "			FROM "+RetSqlName("SC9")+" SC9 "
	cQryPedEst += "         WHERE  SC9.D_E_L_E_T_ = ' ' 	"
	cQryPedEst += "			         AND SC9.C9_FILIAL = C9.C9_FILIAL "
	cQryPedEst += "			         AND SC9.C9_PEDIDO = C9.C9_PEDIDO "
	cQryPedEst += "			         AND SC9.C9_ITEM   = C9.C9_ITEM "
	cQryPedEst += "			         AND SC9.C9_PRODUTO = C9.C9_PRODUTO "
	cQryPedEst += "			         AND SC9.C9_SEQUEN  = C9.C9_SEQUEN "
	cQryPedEst += "			         AND SC9.C9_NFISCAL = ' '  "
	cQryPedEst += "			         AND SC9.C9_BLEST <> ' ' "
	cQryPedEst += "			         AND SC9.C9_ORDSEP = ' ' ) AS BLOQ  "
	cQryPedEst += " FROM "+RetSqlName("SC9")+" C9 "
	cQryPedEst += " INNER JOIN "+RetSqlName("SC6")+" C6 ON C9.C9_FILIAL = C6.C6_FILIAL AND "
	cQryPedEst += " 						C9.C9_PEDIDO = C6.C6_NUM AND "
	cQryPedEst += " 						C9.C9_ITEM = C6.C6_ITEM AND "
	cQryPedEst += " 						C9.D_E_L_E_T_ = C6.D_E_L_E_T_ "
	cQryPedEst += " INNER JOIN "+RetSqlName("SC5")+" C5 ON C9.C9_FILIAL = C5.C5_FILIAL AND "
	cQryPedEst += " 						C9.C9_PEDIDO = C5.C5_NUM AND "
	cQryPedEst += " 						C9.D_E_L_E_T_ = C5.D_E_L_E_T_ "
	cQryPedEst += "	INNER JOIN "+RetSqlName("SF4")+" F4 ON F4_FILIAL = '"+XFILIAL("SF4")+"'  AND C6.C6_TES = F4.F4_CODIGO AND C6.D_E_L_E_T_ = F4.D_E_L_E_T_  "	//ALTERADO POR DYEGO 7/8/14
	cQryPedEst += " WHERE C9.D_E_L_E_T_ = '' "
	cQryPedEst += " AND C9_FILIAL = '"+xFilial("SC9")+"' "
	cQryPedEst += " AND C9_NFISCAL = '' "
	cQryPedEst += " AND C9_BLEST = '' "
	cQryPedEst += " AND C9_PRODUTO = '"+cProd+"' "
	cQryPedEst += " AND C9_PEDIDO <> '"+cPed+"' "
	cQryPedEst += " AND C9_ORDSEP = '' "
	// Ticket #10XX - Aldo 22/10/26
	// eliminar a limitação de exibição de itens com tes que movimenta estoque
	//cQryPedEst += " AND F4.F4_ESTOQUE = 'S' "
	cQryPedEst += " AND C6_QTDVEN-(C9_QTDLIB+C6_QTDENT)>=0 "
	cQryPedEst += " ORDER BY C6.C6_XEMISSA "

	cQryPedEst := ChangeQuery(cQryPedEst)
	TcQuery cQryPedEst New Alias "QRYPEDEST"

	QRYPEDEST->(DbGoTop())

	While QRYPEDEST->(!EoF())
		dEmiss     := DtoS(Posicione("SC5",1,xFilial("SC5")+QRYPEDEST->PEDIDO,"C5_EMISSAO"))
		_cEmiss    := Substr(QRYPEDEST->EMISSAO,7,2)+"/"+Substr(QRYPEDEST->EMISSAO,5,2)+"/"+Substr(QRYPEDEST->EMISSAO,1,4)
		_cDEntreg  := Substr(QRYPEDEST->ENTREGA,7,2)+"/"+Substr(QRYPEDEST->ENTREGA,5,2)+"/"+Substr(QRYPEDEST->ENTREGA,1,4)
		_cCliente  := Posicione("SA1",1,xFilial("SA1")+QRYPEDEST->CLIENTE,"A1_NOME")
		_cVendedor := Posicione("SA3",1,xFilial("SA3")+QRYPEDEST->VENDEDOR,"A3_NOME")
		aAdd(aRetorno,{QRYPEDEST->PEDIDO,_cCliente,_cVendedor,_cEmiss,_cDEntreg,QRYPEDEST->QTDVEN,QRYPEDEST->QTDENT,;
			QRYPEDEST->QTDLIB,QRYPEDEST->LOTE,QRYPEDEST->BLOQ})
		QRYPEDEST->(DbSkip())
	EndDo

	QRYPEDEST->(DbCloseArea())

Return(aRetorno)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function GetSaldo(_Prod,_Local)

Return VPIBQAtu(_Prod, _Local)

/*=================================================================
Info: Chave padrao SB2 (filial + produto + armazem)
*==================================================================*/
Static Function VPIB2Key(cProd,cLocal)

Return xFilial("SB2") + PadR(AllTrim(cProd), TamSx3("B2_COD")[1]) + PadR(AllTrim(cLocal), TamSx3("B2_LOCAL")[1])

/*=================================================================
Info: Posiciona SB2 pelo produto/armazem
*==================================================================*/
Static Function VPIB2Pos(cProd,cLocal)

	Local cChave := ""

	Default cProd  := ""
	Default cLocal := ""

	If Empty(AllTrim(cProd)) .Or. Empty(AllTrim(cLocal))
		Return .F.
	EndIf

	cChave := VPIB2Key(cProd, cLocal)

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))

Return SB2->(DbSeek(cChave))

/*=================================================================
Info: Saldo fisico do armazem (coluna Saldo Est.) - somente B2_QATU
*==================================================================*/
Static Function VPIBQAtu(cProd,cLocal)

	Local nRet   := 0
	Local cChave := ""

	Default cProd  := ""
	Default cLocal := ""

	If Empty(AllTrim(cProd)) .Or. Empty(AllTrim(cLocal))
		Return 0
	EndIf

	cChave := VPIB2Key(cProd, cLocal)

	If VPIB2Pos(cProd, cLocal)
		nRet := SB2->B2_QATU
	Else
		nRet := VPIVal(Posicione("SB2", 1, cChave, "B2_QATU"))
	EndIf

Return nRet

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function GetStatus(_PV,_item)

	Local _Stat := " "
	
	DbSelectarea("SC9")
	DbSetorder(1)       //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	DbSeek(xFilial("SC9")+_PV+_item,.t.)
	
	If !Found()
		_Stat := "1-Em Carteira"
	ElseIf Found()
		IF SC9->C9_BLCRED ="02" .or. SC9->C9_BLCRED ="01"
			_Stat := "2-Blq.Credito"
		ElseIf SC9->C9_BLCRED ="09"
			_Stat := "3-Rejeitado Credito"
		ElseIf empty(SC9->C9_BLCRED) .and. SC9->C9_BLEST = "02"
			_Stat := "4-Blq Estoque"
		ElseIf empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. empty(SC9->C9_ORDSEP)
			_Stat := "5-Aguardando OS"
		ElseIf empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. !empty(SC9->C9_ORDSEP)
			_Stat := "6-Carregado Aguardando Faturamento"
		EndIf
	EndIf

Return(_Stat)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function GLbxII()

	Local aRetorno 		:= {}
	Local cQrySC6 		:= ""
	Local _SaldoEst 	:= 0
	Local _SaldoDisp 	:= 0
	Local _Bloqueado 	:= 0
	Local aSC9			:= {}
	Local aVlPFEX		:= {}
	Local aVlTra		:= {}
	Local aOrdSep       := {}

	Local xRESEST	:= GetMV("MV_RESEST")
	Local xXPDEMAX	:= GetMV("MV_XPDEMAX")

	Local aLastQuery
	Local cLike
	Local cQuery
	Local cError
	Local cTCSqlError

	Local cAlias

	Local oError

	Local cLastRowKey := ""
	Local aCacheDtCol := {}
	Local aCacheSomarQtd := {}
	Local aCachePO       := {}
	Local aCachePEAtu    := {}
	Local aCacheProc     := {}
	Local aCache6Itm     := {}
	Local aCachePrzEam   := {}
	Local aCachePVLib    := {}
	Local aCacheSC0      := {}
	Local aCacheSC9A     := {}
	Local aFatParc       := {}
	Local aPendParc      := {}
	Local cKeySzi := ""
	Local cKeyQtd := ""
	Local cKeyPO  := ""
	Local cKeySC0 := ""
	Local cItemKey := ""
	Local cNFUso  := ""
	Local cSerUso := ""
	Local cStaSave := ""
	Local nQuantifat := 0
	Local nQtdFat := 0
	Local nQtdRest := 0
	Local lParc := .F.
	Local lJaFat := .F.
	Local lJaPend := .F.
	Local lAtualFat := .F.
	Local lTemSC9A := .F.
	Local uTmp := Nil
	Local cRowKey := ""
	Local _cPO      := ""
	Local _cPEAtu   := ""
	Local _cProcImp := ""
	Local _cXPrzFor := ""
	Local _nXPE     := 0
	Local _cXPE     := ""
	Local _cXVinSW  := ""
	Local _cCF      := ""
	Local a6Itm     := {}
	Local xQtdVen   := Nil
	Local xQtdEnt   := Nil
	Local xQtdSal   := Nil
	Local xReser    := Nil
	Local xSalEst   := Nil
	Local xSalDis   := Nil
	Local cStaLin   := ""
	Local aOSLin    := {}
	Local cCargaLin := ""
	Local cDtCgLin  := ""
	Local cHrCgLin  := ""
	Local cItemAnt  := ""
	Local cPrdant   := ""
	Local nLetra    := 65
	Local nQtdLib   := 0
	Local nResSC0   := 0

	BEGIN SEQUENCE

	lQuery  := .T.
	cAliasSC6 := GetNextAlias()
	BEGINSQL ALIAS "cAliasSC6"
%noParser%

SELECT PEDIDO,                          
		XPEDVIN, 
		TIPLIB,                                            
		XFATURA, 
		EMISSAO,                                                
		TES,     
		DLIBEST,        
		CLIENTE, 
		LOJACLI,                                                     
		CLIENT, 
		LOJAENT,                                                     
		TABELA,	      
		TRANSP,    
		CONDPAG, 
		PRODUTO, 
		DESCPROD,
		ARMAZEM, 
		ITEM,  
		BLQ,	
		MAX(QTDVEN)				AS QTDVEN,  
		MAX(QTDENT)				AS QTDENT,  
		SUM(QTDLIB)				AS QTDLIB,  
		MAX(PRCVEN)				AS PRCVEN,                       
		MAX(XPRCTAB)			AS XPRCTAB, 
		MAX(VALOR)				AS VALOR,   
		MAX(XDESC)				AS XDESC, 	
		ENTREGA,  
		PRZENT,  
		DTENTREGA, 
		C6_NOTA,     
		C6_SERIE,
		C9_NFISCAL,
		STAPV,  
		C9_CARGA, 
	     DAK_DATA , DAK_HORA ,
		C9_BLCRED, 
		C9_BLEST,
		C9_ORDSEP,
		CB7_DTEMIS,
		CB7_HREMIS,
		BLQDESC , BLQTRAN,BLQFRT,BLQPAG, BLQDTV   , 
		BLQREGCOM
FROM (
 	SELECT SC5.C5_NUM									AS PEDIDO,
		SC5.C5_XPEDVIN                                  AS XPEDVIN, 
		SC5.C5_TIPLIB									AS TIPLIB,  
		SC5.C5_XFATURA									AS XFATURA, 
		SC6.C6_XEMISSA									AS EMISSAO,     
		SC6.C6_TES										AS TES, 
		SC5.C5_DLIBEST									AS DLIBEST,     
		SC5.C5_CLIENTE									AS CLIENTE,     
		SC5.C5_LOJACLI									AS LOJACLI,   
		SC5.C5_CLIENT									AS CLIENT,     
		SC5.C5_LOJAENT									AS LOJAENT,   
		SC5.C5_TABELA 									AS TABELA,   	
		SC5.C5_TRANSP									AS TRANSP,    
		SC5.C5_CONDPAG									AS CONDPAG,  
 		SC6.C6_PRODUTO									AS PRODUTO ,      
		SB1.B1_DESC 									AS DESCPROD,	   
		SC6.C6_LOCAL 									AS ARMAZEM,       
		SC6.C6_ITEM										AS ITEM, 
		SC6.C6_BLQ 										AS BLQ, 

		SC9.C9_SEQUEN   		    					AS SEQUEN,	 //Dyego 18/02/16		
		SC6.C6_QTDVEN 									AS QTDVEN,  
		SC6.C6_PRCVEN									AS PRCVEN, 
		SC6.C6_VALOR									AS VALOR, 
		SC6.C6_XDESC	 								AS XDESC,        
		SC6.C6_XPRCTAB									AS XPRCTAB, 
		SC6.C6_QTDENT 									AS QTDENT,  
		SC9.C9_QTDLIB									AS QTDLIB,  
		SC6.C6_CRVENT 									AS ENTREGA, 
		(cast(SB1.B1_PE as int)+cast(SB1.B1_CRVPA as int)) 				AS SOMA,     
		SC6.C6_CRVENT 									AS PRZENT,    
		SC6.C6_ENTREG  									AS DTENTREGA,  
		SC6.C6_NOTA,                                                      
		SC6.C6_SERIE,
		SC9.C9_NFISCAL,	                                                  
		SC9.C9_BLQDESC AS BLQDESC , SC9.C9_BLQTRAN AS BLQTRAN, SC9.C9_BLQFRT AS BLQFRT, SC9.C9_BLQPAG AS BLQPAG, SC9.C9_BLQDTV AS BLQDTV,   

		// Fernando Pessoa / Tecsistem - 04/08/2026
		// Status 11 por liberacao (C9_NFISCAL), nao mais C6_NOTA no item inteiro.
		// Evita marcar parcela pendente como faturada em faturamento parcial.
		CASE WHEN SC9.C9_NFISCAL <> ' '  
				THEN 11 //'11 - Faturado' (por liberacao SC9)
				ELSE CASE WHEN C9_FILIAL IS NULL   
						   THEN CASE WHEN SC6.C6_QTDENT >= SC6.C6_QTDVEN AND SC6.C6_QTDVEN > 0
									 THEN 11 // totalmente entregue, sem SC9 aberto
									 ELSE 1 //'01 - Em carteira '
								END
						   ELSE CASE WHEN (  SC9.C9_BLEST = ' ' and  SC9.C9_BLCRED <> ' ') 
								     THEN 5 // '05 - Reservado,em anali.de cred'      
								     ELSE CASE WHEN (SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST <> ' ' ) or (SC9.C9_BLCRED <> ' ' AND SC9.C9_BLEST <> ' ' )  
											   THEN 7 // '07 - Aguardando estoque '      
  											   ELSE CASE WHEN SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' AND SC9.C9_ORDSEP = ' '    
													THEN 9 //'09 - Aguardando OS' - Fernando Pessoa / Tecsistem - 30/07/2026 (C9_ORDSEP) 
													ELSE CASE WHEN SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' AND SC9.C9_ORDSEP <> ' '     
															   THEN 10 //'10 - Em separacao '   
															   ELSE 0 //' ' 
														 END 
										  			END  
											END 
								 END 
					  END 
		END  AS STAPV, 
		
		  
		SC9.C9_CARGA,SC9.C9_ORDSEP,
		CB7.CB7_DTEMIS AS CB7_DTEMIS,
		CB7.CB7_HREMIS AS CB7_HREMIS,
		
		CASE WHEN  SC9.C9_BLCRED  = '09'   
				THEN 9 // '09'  		   
			WHEN  SC9.C9_BLCRED  <>  '09' AND SC9.C9_BLCRED  <>  '10' AND SC9.C9_BLCRED  <>  ' '  		  
				THEN 1
			 WHEN SC9.C9_BLCRED <> ' '     
					THEN 99 // '99'  
			 WHEN SC9.C9_BLCRED <> ' ' AND SC9.C9_BLEST = ' ' 
			        THEN 99 // '99'   
			 ELSE 0 // ' ' 
		END AS C9_BLCRED ,
			 				
		CASE WHEN SC9.C9_BLEST  <>  ' '  
				THEN 99 // '99' 
			 WHEN SC9.C9_BLEST  =  ' ' AND SC9.C9_BLCRED <> ' ' 
				THEN 99 //'99' 
				ELSE 0 //' ' 
		END AS C9_BLEST,
         
	   CASE WHEN (C9_BLQDESC <> ' '  )THEN 121 // '12 - BLQ REG.COM DESCONTO'   
           	  ELSE    
	     		 CASE WHEN (C9_BLQTRAN <> '' OR C5_BLQTRAN <> '')  THEN 122 //'12 - BLQ REG.COM TRANSPORTADORA'  
       	        ELSE      
	         	     	CASE WHEN (C9_BLQFRT <> ' ' or C5_BLQFRT<>'' )  THEN 123 //  '12 - BLQ REG.COM FRETE'   
	           	     	 	   ELSE CASE WHEN (C9_BLQPAG <> ' ' OR C5_BLQPAG <> ' ' )  THEN 124 // '12 - BLQ REG. COND.PAGAMENTO '		 	 
								         ELSE 	    	
										     CASE WHEN  C9_BLQDTV <> ' '  THEN 125 // '12 - BLQ REG. DT VENCIDA'  
												  ELSE 0 // ' '                                            
							   				 END													  											      
								     END     
	            	       END  	   		 
	              END  		             			    				
		END  AS BLQREGCOM    ,          
        DAK_DATA , DAK_HORA
     
FROM %table:SC5% SC5 
			INNER JOIN %table:SC6% SC6 ON SC6.C6_FILIAL =  %xfilial:SC6% AND SC5.C5_NUM = SC6.C6_NUM AND SC6.C6_BLQ<>'R ' AND SC6.%notDel%   
			INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL= %xfilial:SB1%  AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.%notDel%    
			INNER JOIN %table:SF4% SF4 ON SF4.F4_FILIAL = %xfilial:SF4% AND SC6.C6_TES = SF4.F4_CODIGO /*AND SF4.F4_ESTOQUE = 'S'*/ AND SF4.%notDel%
			LEFT JOIN  %table:SC9% SC9 ON SC9.C9_FILIAL =  %xfilial:SC9% AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.%notDel%
			LEFT JOIN  %table:CB7% CB7 ON CB7.CB7_FILIAL =  %xfilial:CB7% AND SC9.C9_ORDSEP = CB7.CB7_ORDSEP AND CB7.%notDel%
			LEFT JOIN  %table:DAK% DAK ON DAK.DAK_FILIAL =  %xfilial:DAK% AND C9_CARGA = DAK.DAK_COD AND DAK.%notDel%  
WHERE SC5.%notDel%  
		AND SC5.C5_FILIAL =  %xfilial:SC5%
		AND SC5.C5_NUM = %exp:_NumPed%  ) AA 

GROUP BY PEDIDO,XPEDVIN,TIPLIB,XFATURA,EMISSAO,TES,DLIBEST,CLIENTE,LOJACLI,CLIENT,LOJAENT,TABELA,TRANSP,CONDPAG,PRODUTO,DESCPROD,ARMAZEM,ITEM,BLQ,ENTREGA,PRZENT,DTENTREGA,C6_NOTA,C6_SERIE,C9_NFISCAL,STAPV, C9_CARGA,C9_ORDSEP,CB7_DTEMIS,CB7_HREMIS,C9_BLCRED, C9_BLEST,BLQDESC,BLQTRAN,BLQFRT,BLQPAG,BLQDTV , BLQREGCOM, DAK_DATA , DAK_HORA
ORDER BY ITEM , PRODUTO , CASE WHEN C9_NFISCAL <> ' ' THEN 0 ELSE 1 END

	ENDSQL




	// Debug SQL desativado para reduzir I/O na abertura da rotina
	//MemoWrite("C:\temp\MA410MNU.txt",getlastquery()[2])

	nLetra   := 65
	cItemAnt := " "
	cPrdant  := " "
	While  cAliasSC6->(!EoF())

		_SaldoEst  := 0
		_SaldoDisp := 0
		nQtdLib    := 0
		
		_DtFat := VPIDtFmt(cAliasSC6->ENTREGA)
		_cPrzoEntr := VPIDtFmt(cAliasSC6->DTENTREGA)

		_QStatus  := ""

		Do Case
		Case cAliasSC6->STAPV == 1
			_QStatus:= '01 - Em carteira '
		Case cAliasSC6->STAPV == 5
			_QStatus:= '05 - Reservado,em anali.de cred'
		Case cAliasSC6->STAPV == 7
			_QStatus:= '07 - Aguardando estoque'
		Case cAliasSC6->STAPV == 9
			_QStatus:= '09 - Aguardando OS'
		Case cAliasSC6->STAPV == 10
			_QStatus:= '10 - Em separacao'
		Case cAliasSC6->STAPV == 11
			_QStatus := '11 -  Faturado'
		Case cAliasSC6->STAPV == 0
			_QStatus:= ' '
		EndCase
     
		_BLCRED := ""
		Do Case
		Case cAliasSC6->C9_BLCRED == 9
			_BLCRED:= '9'
		Case cAliasSC6->C9_BLCRED == 1
			_BLCRED:= '1'
		Case cAliasSC6->C9_BLCRED == 99
			_BLCRED:= '99'
		Case cAliasSC6->C9_BLCRED == 0
			_BLCRED:= ' '
		EndCase

		_BLEST := ""
		Do Case
		Case cAliasSC6->C9_BLEST == 99
			_BLEST:= '99'
		Case cAliasSC6->C9_BLEST == 0
			_BLEST:= ' '
		EndCase

		_BLQREGCOM := ""
		Do Case
		Case cAliasSC6->BLQREGCOM == 121
			_BLQREGCOM := '12 - BLQ REG.COM DESCONTO'
		Case cAliasSC6->BLQREGCOM == 122
			_BLQREGCOM := '12 - BLQ REG.COM TRANSPORTADORA'
		Case cAliasSC6->BLQREGCOM == 123
			_BLQREGCOM := '12 - BLQ REG.COM FRETE'
		Case cAliasSC6->BLQREGCOM == 124
			_BLQREGCOM := '12 - BLQ REG. COND.PAGAMENTO '
		Case cAliasSC6->BLQREGCOM == 125
			_BLQREGCOM := '12 - BLQ REG. DT VENCIDA'
		EndCase

		If SubStr(_QStatus,1,2) = '11'
			cNFUso  := AllTrim(cAliasSC6->C9_NFISCAL)
			cSerUso := AllTrim(cAliasSC6->C6_SERIE)
			If Empty(cNFUso)
				cNFUso := AllTrim(cAliasSC6->C6_NOTA)
			EndIf
			cKeyQtd := AllTrim(cAliasSC6->PEDIDO)+"|"+AllTrim(cAliasSC6->ITEM)+"|"+AllTrim(cAliasSC6->PRODUTO)+"|"+AllTrim(cAliasSC6->ARMAZEM)+"|"+cNFUso+"|"+cSerUso
			nQuantifat := CacheGet(aCacheSomarQtd,cKeyQtd,Nil)
			If nQuantifat == Nil
				nQuantifat := SomarQtd(AllTrim(cAliasSC6->PEDIDO),AllTrim(cAliasSC6->ITEM),AllTrim(cAliasSC6->PRODUTO),AllTrim(cAliasSC6->ARMAZEM),cNFUso,cSerUso)
				CachePut(@aCacheSomarQtd,cKeyQtd,nQuantifat)
			EndIf
			If nQuantifat <= 0
				nQuantifat := cAliasSC6->QTDENT
			EndIf
			_QStatus  := "11 - Faturado, NF: "+cNFUso+" (Qtd.: "+cValToChar(nQuantifat)+")"
		ElseIF SubStr(_QStatus,1,2) = '01'
			_QStatus  := "01 - Em carteira"
		ElseIF SubStr(_QStatus,1,2) = "05"
			If cAliasSC6->XFATURA = "N"
				_QStatus  := "05.A- Aguar.FAT SIM, reservado,em anali.de cred"
			Else
				_QStatus  := "05 - Reservado,em anali.de cred"
			EndIf
		ElseIf SubStr(_QStatus,1,2) = "07"   //MGV
			_QStatus  := "07 - Aguardando estoque"
		ElseIf SubStr(_QStatus,1,2) = "09"
			_QStatus  := "09 - Aguardando OS"
		ElseIf SubStr(_QStatus,1,2) = "10"
			_QStatus  := "10 - Em separacao"
		EndIf

		If cAliasSC6->TIPLIB = "2" .and. ;//Liberacao por pedido
			VPIPVLib(cAliasSC6->PEDIDO, cAliasSC6->ITEM, @aCachePVLib) .AND. SubStr(_QStatus,1,2) <>'01' .AND.;
				!(cAliasSC6->XFATURA = "N" .AND.  EMPTY(cAliasSC6->C6_NOTA))   .and.;
				SubStr(_QStatus,1,2) <>'05'   .and. ;
				!((_BLCRED = ' ' .AND. _BLEST <> ' ' ) .or. (_BLCRED <> ' ' .AND. _BLEST <> ' ' ))  .and.;
				cAliasSC6->PRZENT <= DtoS(ddatabase) .AND.;                  //SubStr(_QStatus,1,2) <>'02'   .AND.;
				SubStr(_QStatus,1,2) <> '11' 		//SubStr(_QStatus,1,2) <> '11'

			_QStatus  := "04 - Reservado,aguardando lib.total "
		Else
			If SubStr(_QStatus,1,2) <> "10"
				If SubStr(_QStatus,1,2) = "01"
					_QStatus  := "01 - Em carteira"
				ElseIf _BLCRED = "09"
					_QStatus  := "06.1 - Rejeitado Credito "
				ElseIf _BLCRED = "1"  .and. !(xRESEST)
					_QStatus  := "06 - Bloqueado Credito "
					nQtdLib := 0
					_Bloqueado := cAliasSC6->QTDVEN-(cAliasSC6->QTDENT)
				ElseIf cAliasSC6->PRZENT > DtoS(ddatabase) .and. empty(cAliasSC6->C6_NOTA) .AND. !((_BLCRED = ' ' .AND. _BLEST <> ' ' ) .or. (_BLCRED <> ' ' .AND. _BLEST <> ' ' ))
					_QStatus  := '02 - Reservado,aguardando data p/fat'
				ElseIf cAliasSC6->XFATURA = "N" .AND.  EMPTY(cAliasSC6->C6_NOTA)  .and. empty(_BLEST)
					_QStatus  := '03 - Reservado,aguardando fat sim '
				ElseIf cAliasSC6->XFATURA = "N" .AND. EMPTY(cAliasSC6->C6_NOTA)  .and. !(empty(_BLEST))     .and.  empty(_BLCRED)
					_QStatus  := '07 - Aguardando Estoque fat sim,'
				EndIf
			EndIf
		EndIf
		If Substr(Ltrim(Rtrim(_QStatus)),1,2) = "07"   //mgv
			
			_Bloqueado := cAliasSC6->QTDLIB

			nQtdLib  := 0
		ElseIf Substr(Ltrim(Rtrim(_QStatus)),1,2) = "11"    //Faturado
			_Bloqueado := 0

			nQtdLib  := 0
		Else
			If  !(xRESEST)
				If Substr(Ltrim(Rtrim(_QStatus)),1,2) <> "06"
					nQtdLib  :=   cAliasSC6->QTDLIB
				EndIf
			Else
				nQtdLib  :=   cAliasSC6->QTDLIB
			EndIf
			_Bloqueado := IIF( empty(_BLCRED) .and. empty(_BLEST) .and. !empty(cAliasSC6->C9_CARGA),0, cAliasSC6->QTDVEN-(cAliasSC6->QTDENT+cAliasSC6->QTDLIB ))
			
			If Substr(Ltrim(Rtrim(_QStatus)),1,2) = "06"  .and. !(xRESEST)
				_Bloqueado := cAliasSC6->QTDVEN-(cAliasSC6->QTDENT)
			EndIf

		EndIf

		// Fernando Pessoa / Tecsistem - 30/07/2026
		// Status 12: prioriza NF da liberacao (C9_NFISCAL); so valida coleta via SZJ/SZI.
		cNFUso  := AllTrim(cAliasSC6->C9_NFISCAL)
		cSerUso := AllTrim(cAliasSC6->C6_SERIE)
		If Empty(cNFUso)
			cNFUso := AllTrim(cAliasSC6->C6_NOTA)
		EndIf
		cKeySzi := cNFUso+"|"+cSerUso
		dDtaCol := CacheGet(aCacheDtCol,cKeySzi,Nil)
		If dDtaCol == Nil
			dDtaCol := GetDtColSZJ(cNFUso,cSerUso)
			CachePut(@aCacheDtCol,cKeySzi,dDtaCol)
		EndIf

		If Substr(Ltrim(Rtrim(_QStatus)),1,2) = "11" .AND. !Empty(dDtaCol) .AND. Len(AllTrim(dDtaCol)) >= 8
			cKeyQtd := AllTrim(cAliasSC6->PEDIDO)+"|"+AllTrim(cAliasSC6->ITEM)+"|"+AllTrim(cAliasSC6->PRODUTO)+"|"+AllTrim(cAliasSC6->ARMAZEM)+"|"+cNFUso+"|"+cSerUso
			nQuantifat := CacheGet(aCacheSomarQtd,cKeyQtd,Nil)
			If nQuantifat == Nil
				nQuantifat := SomarQtd(AllTrim(cAliasSC6->PEDIDO),AllTrim(cAliasSC6->ITEM),AllTrim(cAliasSC6->PRODUTO),AllTrim(cAliasSC6->ARMAZEM),cNFUso,cSerUso)
				CachePut(@aCacheSomarQtd,cKeyQtd,nQuantifat)
			EndIf
			If nQuantifat <= 0
				nQuantifat := cAliasSC6->QTDENT
			EndIf
			_QStatus  := '12 - Coletado em '+Substr(dDtaCol,7,2)+"/"+Substr(dDtaCol,5,2)+"/"+Substr(dDtaCol,1,4)+" , NF:"+cNFUso+" (Qtd.: "+cValToChar(nQuantifat)+")"
		EndIf

		If cAliasSC6->BLQ = "R"
			_QStatus  := '13 - Item do Pedido cancelado/Encerrado'
			_Bloqueado:= 0
		EndIf

		_DtEmi := SubStr(cAliasSC6->EMISSAO,7,2)+'/'+ SubStr(cAliasSC6->EMISSAO,5,2)+'/'+SubStr(cAliasSC6->EMISSAO,1,4)

		_DATA_HORA := cAliasSC6->DAK_DATA   + cAliasSC6->DAK_HORA
		
		If Empty(_DATA_HORA)
			_DATA_HORA := "00000000000"
		Endif

		// Fernando Pessoa / Tecsistem - 30/07/2026
		// Reservado = SC0.C0_QUANT via SC9.C9_RESERVA = SC0.C0_NUM
		_Reservado := 0
		If cAliasSC6->QTDENT <> cAliasSC6->QTDVEN .And. Empty(AllTrim(cAliasSC6->C9_NFISCAL))
			cKeySC0 := AllTrim(cAliasSC6->PEDIDO)+"|"+AllTrim(cAliasSC6->ITEM)
			_Reservado := CacheGet(aCacheSC0,cKeySC0,Nil)
			If _Reservado == Nil
				_Reservado := VPIQtdSC0(AllTrim(cAliasSC6->PEDIDO),AllTrim(cAliasSC6->ITEM))
				CachePut(@aCacheSC0,cKeySC0,_Reservado)
			EndIf
		EndIf
		If Empty(_Reservado)
			_Reservado := 0
		EndIf

		// Otávio Barreiro - 28/10/2026
		// Reservado volta a ser a qtd liberada (C9_QTDLIB), como na versao 12/03/26.
		// nResSC0 guarda so a reserva SC0, usada na regra do status 09.
		nResSC0 := _Reservado
		_Reservado := nQtdLib

		_QtdeSald  := cAliasSC6->QTDVEN-(cAliasSC6->QTDENT)

		If cAliasSC6->QTDENT == cAliasSC6->QTDVEN
			_SaldoEst := "---"
			_SaldoDisp:= "---"
			_QtdeSald := "---"
			_Reservado:= "---"
		EndIf

		If cAliasSC6->BLQ = "R"
			_SaldoEst := "---"
			_SaldoDisp:= "---"
			_QtdeSald := "---"
			_Reservado:= "---"
		EndIf

		_DtCarga   := SubStr(_DATA_HORA,1,8)
		_HoraCarga := Substr(_DATA_HORA, 9, 8)

		_DtCarga   := SubStr(_DtCarga,7,2)+'/'+ SubStr(_DtCarga,5,2)+'/'+SubStr(_DtCarga,1,4)

		// Garante mascara visual para itens entregues/cancelados
		If cAliasSC6->QTDENT == cAliasSC6->QTDVEN .Or. cAliasSC6->BLQ = "R"
			_SaldoEst := "---"
			_SaldoDisp:= "---"
			_QtdeSald := "---"
			_Reservado:= "---"
		EndIf

		// Fernando Pessoa / Tecsistem - 06/08/2026
		// "09 - Aguardando OS" so quando Reservado (SC0) > 0
		If Left(AllTrim(_QStatus), 2) == "09"
			If nResSC0 <= 0
				_QStatus := "Liberado"
			EndIf
		EndIf

		aOrdSep := {AllTrim(cAliasSC6->C9_ORDSEP),VPIDtStr(cAliasSC6->CB7_DTEMIS),AllTrim(cAliasSC6->CB7_HREMIS)}
	
		// valida se produto esta bloqueado para invent?rio.
		If _Bloqueado>0
			DbSelectArea('SB2')
			If !Empty(FbuscaCpo("SB2",1,xFilial("SB2")+cAliasSC6->PRODUTO+cAliasSC6->ARMAZEM,"B2_DINVFIM"))
				_QStatus  := 'I - Bloqueio Inventario '
			Endif
		Endif

		cRowKey := AllTrim(cAliasSC6->PEDIDO)+"|"+AllTrim(cAliasSC6->ITEM)+"|"+AllTrim(cAliasSC6->PRODUTO)+"|"+AllTrim(cAliasSC6->ARMAZEM)+"|"+AllTrim(cAliasSC6->TES)+"|"+AllTrim(cAliasSC6->C9_CARGA)+"|"+AllTrim(_QStatus)
		If cRowKey == cLastRowKey
			dbSelectArea("cAliasSC6")
			cAliasSC6->(DbSkip())
			Loop
		EndIf
		cLastRowKey := cRowKey

		_cXVinSW  := ""
		_nXPE     := 0
		_cXPE     := ""
		_cXPrzFor := ""
		_cPO      := ""
		_cPEAtu   := ""
		_cProcImp := ""
		_cCF      := ""

		BEGIN SEQUENCE
			a6Itm     := VPI6Itm(cAliasSC6->PEDIDO, cAliasSC6->ITEM, @aCache6Itm)
			_cXVinSW  := a6Itm[1]
			_nXPE     := a6Itm[2]
			_cXPE     := IIf(Empty(_nXPE), "", Transform(_nXPE, "99,999"))
			_cXPrzFor := CacheGet(aCachePrzEam, AllTrim(cAliasSC6->PRODUTO), Nil)
			If _cXPrzFor == Nil
				_cXPrzFor := VPIPrzEam(AllTrim(cAliasSC6->PRODUTO))
				CachePut(@aCachePrzEam, AllTrim(cAliasSC6->PRODUTO), _cXPrzFor)
			EndIf
			_cCF      := a6Itm[4]

			If !Empty(_cXVinSW)
				cKeyPO := AllTrim(cAliasSC6->PRODUTO)+"|"+_cXVinSW
				_cPO := CacheGet(aCachePO,cKeyPO,Nil)
				If _cPO == Nil
					_cPO := VPIGetPO(_cXVinSW, AllTrim(cAliasSC6->PRODUTO))
					CachePut(@aCachePO,cKeyPO,_cPO)
				EndIf

				If !Empty(_cPO)
					_cPEAtu := CacheGet(aCachePEAtu,cKeyPO,Nil)
					If _cPEAtu == Nil
						_cPEAtu := VPIxDtEn(AllTrim(cAliasSC6->PRODUTO), _cPO)
						CachePut(@aCachePEAtu,cKeyPO,_cPEAtu)
					EndIf

					_cProcImp := CacheGet(aCacheProc,cKeyPO,Nil)
					If _cProcImp == Nil
						_cProcImp := VPIxProc(AllTrim(cAliasSC6->PRODUTO), _cPO)
						CachePut(@aCacheProc,cKeyPO,_cProcImp)
					EndIf
				EndIf
			EndIf
		RECOVER
		END SEQUENCE

		// Fernando Pessoa / Tecsistem - 04/08/2026
		// Faturamento parcial: quebra em linha faturada + linha pendente
		lParc := (cAliasSC6->QTDENT > 0 .And. cAliasSC6->QTDENT < cAliasSC6->QTDVEN .And. AllTrim(cAliasSC6->BLQ) <> "R")
		nQtdFat  := cAliasSC6->QTDENT
		nQtdRest := cAliasSC6->QTDVEN - cAliasSC6->QTDENT
		cItemKey := AllTrim(cAliasSC6->PEDIDO)+"|"+AllTrim(cAliasSC6->ITEM)
		lJaFat   := (AScan(aFatParc, {|x| x == cItemKey}) > 0)
		lJaPend  := (AScan(aPendParc,{|x| x == cItemKey}) > 0)
		lAtualFat := (Left(AllTrim(_QStatus),2) $ "11|12")

		If lParc .And. lAtualFat
			// 1) parcela ja faturada/coletada
			xQtdVen := nQtdFat
			xQtdEnt := nQtdFat
			xQtdSal := "---"
			xReser  := "---"
			xSalEst := "---"
			xSalDis := "---"
			cStaLin := _QStatus
			aOSLin  := aOrdSep
			cCargaLin := cAliasSC6->C9_CARGA
			cDtCgLin  := _DtCarga
			cHrCgLin  := _HoraCarga
			VPIAddLin(@aRetorno, cAliasSC6->PRODUTO, SubStr(cAliasSC6->DESCPROD,1,30), cAliasSC6->ARMAZEM,;
				_DtFat, _cPrzoEntr, xQtdVen, xSalEst, xSalDis, xQtdEnt, xQtdSal, xReser,;
				cAliasSC6->TES, _cCF, _cXPE, _cXPrzFor, _cPEAtu, _cProcImp, _cPO, cStaLin,;
				aOSLin, cCargaLin, cDtCgLin, cHrCgLin, AllTrim(cAliasSC6->ITEM), @cItemAnt, @nLetra, .T.)
			If !lJaFat
				aAdd(aFatParc, cItemKey)
			EndIf

			// 2) se nao houver SC9 aberto, injeta pendencia em carteira
			If !lJaPend
				uTmp := CacheGet(aCacheSC9A, cItemKey, Nil)
				If uTmp == Nil
					lTemSC9A := VPIHasSC9A(AllTrim(cAliasSC6->PEDIDO), AllTrim(cAliasSC6->ITEM))
					CachePut(@aCacheSC9A, cItemKey, lTemSC9A)
				Else
					lTemSC9A := uTmp
				EndIf
				If !lTemSC9A
					xQtdVen := nQtdRest
					xQtdEnt := 0
					xQtdSal := nQtdRest
					xReser  := 0
					xSalEst := VPIBQAtu(AllTrim(cAliasSC6->PRODUTO), AllTrim(cAliasSC6->ARMAZEM))
					xSalDis := VPIBDisp(AllTrim(cAliasSC6->PRODUTO), AllTrim(cAliasSC6->ARMAZEM))
					cStaLin := "01 - Em carteira"
					aOSLin  := {"","",""}
					VPIAddLin(@aRetorno, cAliasSC6->PRODUTO, SubStr(cAliasSC6->DESCPROD,1,30), cAliasSC6->ARMAZEM,;
						_DtFat, _cPrzoEntr, xQtdVen, xSalEst, xSalDis, xQtdEnt, xQtdSal, xReser,;
						cAliasSC6->TES, _cCF, _cXPE, _cXPrzFor, _cPEAtu, _cProcImp, _cPO, cStaLin,;
						aOSLin, "", "", "", AllTrim(cAliasSC6->ITEM), @cItemAnt, @nLetra, .T.)
					aAdd(aPendParc, cItemKey)
				EndIf
			EndIf

		ElseIf lParc .And. !lAtualFat
			// Pendente/liberado: garante linha da parcela ja faturada antes
			If !lJaFat
				cStaSave := _QStatus
				cNFUso   := AllTrim(cAliasSC6->C6_NOTA)
				cSerUso  := AllTrim(cAliasSC6->C6_SERIE)
				cStaLin  := VPIStatNF(AllTrim(cAliasSC6->PEDIDO), AllTrim(cAliasSC6->ITEM), AllTrim(cAliasSC6->PRODUTO),;
					AllTrim(cAliasSC6->ARMAZEM), cNFUso, cSerUso, nQtdFat, @aCacheDtCol, @aCacheSomarQtd)
				xQtdVen := nQtdFat
				xQtdEnt := nQtdFat
				xQtdSal := "---"
				xReser  := "---"
				xSalEst := "---"
				xSalDis := "---"
				aOSLin  := {"","",""}
				VPIAddLin(@aRetorno, cAliasSC6->PRODUTO, SubStr(cAliasSC6->DESCPROD,1,30), cAliasSC6->ARMAZEM,;
					_DtFat, _cPrzoEntr, xQtdVen, xSalEst, xSalDis, xQtdEnt, xQtdSal, xReser,;
					cAliasSC6->TES, _cCF, _cXPE, _cXPrzFor, _cPEAtu, _cProcImp, _cPO, cStaLin,;
					aOSLin, "", "", "", AllTrim(cAliasSC6->ITEM), @cItemAnt, @nLetra, .T.)
				aAdd(aFatParc, cItemKey)
				_QStatus := cStaSave
			EndIf

			// Linha da parcela pendente (qtds do saldo)
			If !lJaPend
				If _SaldoEst != "---"
					_SaldoEst := VPIBQAtu(AllTrim(cAliasSC6->PRODUTO), AllTrim(cAliasSC6->ARMAZEM))
				EndIf
				If _SaldoDisp != "---"
					_SaldoDisp := VPIBDisp(AllTrim(cAliasSC6->PRODUTO), AllTrim(cAliasSC6->ARMAZEM))
				EndIf
				xQtdVen := nQtdRest
				xQtdEnt := 0
				xQtdSal := nQtdRest
				xReser  := _Reservado
				xSalEst := _SaldoEst
				xSalDis := _SaldoDisp
			Else
				xQtdVen := "---"
				xQtdEnt := "---"
				xQtdSal := "---"
				xReser  := "---"
				xSalEst := "---"
				xSalDis := "---"
			EndIf
			cStaLin := _QStatus
			aOSLin  := aOrdSep
			VPIAddLin(@aRetorno, cAliasSC6->PRODUTO, SubStr(cAliasSC6->DESCPROD,1,30), cAliasSC6->ARMAZEM,;
				_DtFat, _cPrzoEntr, xQtdVen, xSalEst, xSalDis, xQtdEnt, xQtdSal, xReser,;
				cAliasSC6->TES, _cCF, _cXPE, _cXPrzFor, _cPEAtu, _cProcImp, _cPO, cStaLin,;
				aOSLin, cAliasSC6->C9_CARGA, _DtCarga, _HoraCarga, AllTrim(cAliasSC6->ITEM), @cItemAnt, @nLetra, .T.)
			If !lJaPend
				aAdd(aPendParc, cItemKey)
			EndIf

		Else
			// Fluxo normal (sem faturamento parcial)
			If !(cPrdant == cAliasSC6->PRODUTO)
				If _SaldoEst != "---"
					_SaldoEst := VPIBQAtu(AllTrim(cAliasSC6->PRODUTO), AllTrim(cAliasSC6->ARMAZEM))
				EndIf
				If _SaldoDisp != "---"
					_SaldoDisp := VPIBDisp(AllTrim(cAliasSC6->PRODUTO), AllTrim(cAliasSC6->ARMAZEM))
				EndIf
				xQtdVen := cAliasSC6->QTDVEN
				xQtdEnt := cAliasSC6->QTDENT
				xQtdSal := _QtdeSald
				xReser  := _Reservado
				xSalEst := _SaldoEst
				xSalDis := _SaldoDisp
				VPIAddLin(@aRetorno, cAliasSC6->PRODUTO, SubStr(cAliasSC6->DESCPROD,1,30), cAliasSC6->ARMAZEM,;
					_DtFat, _cPrzoEntr, xQtdVen, xSalEst, xSalDis, xQtdEnt, xQtdSal, xReser,;
					cAliasSC6->TES, _cCF, _cXPE, _cXPrzFor, _cPEAtu, _cProcImp, _cPO,;
					_QStatus, aOrdSep, cAliasSC6->C9_CARGA, _DtCarga, _HoraCarga, AllTrim(cAliasSC6->ITEM), @cItemAnt, @nLetra, .F.)
			Else
				VPIAddLin(@aRetorno, cAliasSC6->PRODUTO, SubStr(cAliasSC6->DESCPROD,1,30), cAliasSC6->ARMAZEM,;
					_DtFat, _cPrzoEntr, "---", "---", "---", "---", "---", "---",;
					cAliasSC6->TES, _cCF, "---", "---", "---", "---", "---",;
					_QStatus, aOrdSep, cAliasSC6->C9_CARGA, _DtCarga, _HoraCarga, AllTrim(cAliasSC6->ITEM), @cItemAnt, @nLetra, .F.)
			EndIf
		EndIf

		cPrdant := cAliasSC6->PRODUTO

		dbSelectArea("cAliasSC6")

		cAliasSC6->(DbSkip())

	EndDo

	If lQuery
		dbSelectArea("cAliasSC6")
		dbCloseArea()
	EndIf

	RECOVER USING oError
		If lQuery .And. Select(cAliasSC6) > 0
			dbSelectArea(cAliasSC6)
			dbCloseArea()
		EndIf
		VPILog("GLbxII erro: " + IIf(ValType(oError)=="O", AllTrim(cValToChar(oError:Description)), "desconhecido"))
	END SEQUENCE

Return(aRetorno)

/*=================================================================
Autor:
Data: 02/04/2026
Consultoria:
Uso: Calibre
Info: Cache simples para evitar I/O repetido
*==================================================================*/
Static Function CacheGet(aCache,cKey,uDefault)

	Local nPos := ASCan(aCache,{|aLinha| aLinha[1] == cKey})

	If nPos > 0
		Return(aCache[nPos][2])
	EndIf

Return(uDefault)

/*=================================================================
Autor:
Data: 02/04/2026
Consultoria:
Uso: Calibre
Info: Cache simples para evitar I/O repetido
*==================================================================*/
Static Function CachePut(aCache,cKey,uValue)

	Local nPos := ASCan(aCache,{|aLinha| aLinha[1] == cKey})

	If nPos > 0
		aCache[nPos][2] := uValue
	Else
		aAdd(aCache,{cKey,uValue})
	EndIf

Return(uValue)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function PVTdLib(_NumPV,_Item)

	Local _nRet := .F.
	Local _NumRegTOt
	Local _NumRegOK
	Local cQry  , cQuery

	IIF(Select("SQL")!= 0, SQL->(DbCLoseArea()), )
	cQuery 	:= " SELECT COUNT(*) AS NUMREG "
	cQuery 	+= " FROM "+RetSqlName('SC9')+ "  SC9 "
	cQuery 	+= " WHERE SC9.D_E_L_E_T_ = ' ' "
	cQuery 	+= "		AND C9_PEDIDO = '"+_NumPV+"' "
	cQuery 	+= "		AND C9_CARGA = ' ' "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL', .F., .T.)

	DbSelectArea("SQL")
	DbGoTop()
	_NumRegTOt := SQL->NUMREG
	SQL->(DbCLoseArea())

	IIF(Select("SQL1")!= 0, SQL1->(DbCLoseArea()), )
	cQuery 	:= " SELECT COUNT(*) AS NUMREOK "
	cQuery 	+= " FROM "+ RetSqlName('SC9')+ "  SC9 "
	cQuery 	+= " WHERE SC9.D_E_L_E_T_ = ' ' "
	cQuery 	+= "		AND C9_PEDIDO = '"+_NumPV+"' "
	cQuery 	+= "		AND C9_CARGA = ' ' "
	cQuery 	+= "		AND C9_BLCRED = ' ' "
	cQuery 	+= "		AND  C9_BLEST = ' ' "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL1', .F., .T.)
	
	DbSelectArea("SQL1")
	DbGoTop()
	
	_NumRegOK := SQL1->NUMREOK
	
	SQL1->(DbCLoseArea())

	If _NumRegOK <> _NumRegTOt
		_nRet := .T.
	EndIf

	If !_nRet
		IIF(Select("SQL2")!= 0, SQL2->(DbCLoseArea()), )
		cQry 	:= "SELECT 	SC6.C6_QTDVEN-(SC6.C6_QTDEMP+SC6.C6_QTDENT) AS  QTD,  "
		cQry 	+= "		SC6.C6_QTDVEN,   "
		cQry 	+= "		SC9.QTLIB    "
		cQry 	+= "FROM "+ RetSqlName('SC6')+ " SC6 INNER JOIN "+ RetSqlName('SC5')+ " SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM  AND SC6.C6_BLQ<>'R ' AND SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_  "
		cQry 	+= "								 INNER JOIN ( SELECT C9.C9_FILIAL			 AS FILIAL,  "
		cQry 	+= "														C9.C9_PEDIDO		 AS PEDIDO,	 "
		cQry 	+= "														C9.C9_PRODUTO		 AS PRODUTO, "
		cQry 	+= "														C9.C9_ITEM			 AS ITEM, 	 "
		cQry 	+= "														SUM(C9.C9_QTDLIB)    AS QTLIB    "
		cQry 	+= "												FROM "+ RetSqlName('SC9')+ " C9 "
		cQry 	+= "												WHERE C9.D_E_L_E_T_ = ' '          "
		cQry 	+= "														AND C9.C9_CARGA 	= ' '   "
		cQry 	+= "														AND C9.C9_BLCRED 	= ' '   "
		cQry 	+= "														AND  C9.C9_BLEST   = ' '   "
		cQry 	+= "												GROUP BY C9.C9_FILIAL, C9.C9_PEDIDO,C9.C9_PRODUTO,C9.C9_ITEM)  SC9 ON SC9.FILIAL = SC6.C6_FILIAL  "
		cQry 	+= "														   																AND SC9.PEDIDO = SC6.C6_NUM  "
		cQry 	+= "																														AND SC9.PRODUTO= SC6.C6_PRODUTO  "
		cQry 	+= "																														AND SC9.ITEM	  = SC6.C6_ITEM   "
		cQry 	+= "WHERE SC6.D_E_L_E_T_ 	= ' '   "
		cQry 	+= "		AND SC6.C6_FILIAL 	= '"+xFilial("SC6")+"'  "
		cQry 	+= "				AND SC6.C6_NUM 	= '"+_NumPV+"'  "
		cQry 	+= "				AND SC6.C6_ITEM 	= '"+_Item+"' "
		cQry 	+= "				AND SC5.C5_TIPLIB	= '2'  "
		cQry := ChangeQuery(cQry)
		
		TCQUERY cQry NEW ALIAS "SQL2"
		
		DbSelectArea("SQL2")
		DbGoTop()
		
		If SQL2->C6_QTDVEN <> SQL2->QTLIB
			_nRet := .T.
		EndIf
		
		SQL2->(DbCLoseArea())
		
	EndIf

Return(_nRet)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function SomarQtd(cPedido, cItem, cProduto, cLocal, cNota, cSerie)

	Local nRetorno := 0

	IIF(Select("SQLQT")!= 0, SQLQT->(DbCLoseArea()), )
	cQuery  := " SELECT SUM(SC9.C9_QTDLIB) AS Total_Quantidade "
	cQuery += " FROM " + RetSqlName('SC9') + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName('SC6') + " SC6 "
	cQuery += "     ON SC6.C6_FILIAL = SC9.C9_FILIAL "
	cQuery += "     AND SC6.C6_NUM = SC9.C9_PEDIDO "
	cQuery += "     AND SC6.C6_ITEM = SC9.C9_ITEM "
	cQuery += "     AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cQuery += "     AND SC6.C6_LOCAL = SC9.C9_LOCAL "
	cQuery += "     AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName('SF4') + " SF4 "
	cQuery += "     ON SF4.F4_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SF4.F4_CODIGO = SC6.C6_TES "
 	// Ticket #10XX - Aldo 22/10/26
	// eliminar a limitação de exibição de itens com tes que movimenta estoque
	//cQuery += "     AND SF4.F4_ESTOQUE = 'S' "
	cQuery += "     AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 "
	cQuery += "     ON SF2.F2_FILIAL = SC9.C9_FILIAL "
	cQuery += "     AND SF2.F2_DOC = SC9.C9_NFISCAL "
	cQuery += "     AND SF2.F2_SERIE = SC9.C9_SERIENF "
	cQuery += "     AND SF2.F2_CLIENTE = SC9.C9_CLIENTE "
	cQuery += "     AND SF2.F2_LOJA = SC9.C9_LOJA "
	cQuery += "     AND SF2.F2_TIPO = 'N' "
	cQuery += "     AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SC9.C9_PEDIDO = '" + cPedido + "' "
	cQuery += "     AND SC9.C9_ITEM = '" + cItem + "' "
	cQuery += "     AND SC9.C9_NFISCAL = '" + cNota + "' "
	cQuery += "     AND SC9.C9_SERIENF = '" + cSerie + "' "
	cQuery += "     AND SC9.C9_PRODUTO = '" + cProduto + "' "
	cQuery += "     AND SC9.C9_LOCAL = '" + cLocal + "' "
	cQuery += "     AND SC9.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQLQT', .F., .T.)

	DbSelectArea("SQLQT")
	DbGoTop()
	nRetorno := SQLQT->Total_Quantidade
	If Empty(nRetorno)
		nRetorno := 0
	EndIf
	
	SQLQT->(DbCLoseArea())

Return(nRetorno)

/*=================================================================
Info: Inclui linha na grid com numeracao 01 / 01A / 01B
      Posicao 27 da linha = C6_ITEM real (nao exibida)
Autor: Fernando Pessoa / Tecsistem - 04/08/2026
*==================================================================*/
Static Function VPIAddLin(aRet, cProd, cDesc, cArm, dFat, dEnt, xQVen, xSEst, xSDis, xQEnt, xQSal, xRes,;
	cTes, cCF, cXPE, cPrz, cPE, cProc, cPO, cSta, aOS, cCarga, cDtCg, cHrCg, cItem, cItemAnt, nLetra, lSufixo)

	Local cCod := ""
	Local cOS1 := ""
	Local cOS2 := ""
	Local cOS3 := ""

	Default aOS    := {"","",""}
	Default cCarga := ""
	Default cDtCg  := ""
	Default cHrCg  := ""
	Default cSta   := ""
	Default lSufixo := .F.

	If Len(aOS) >= 1
		cOS1 := aOS[1]
	EndIf
	If Len(aOS) >= 2
		cOS2 := aOS[2]
	EndIf
	If Len(aOS) >= 3
		cOS3 := aOS[3]
	EndIf

	// Otávio Barreiro - 28/10/2026
	// Codigo pelo item do PV (C6_ITEM): mesmo produto em itens diferentes = 01 e 02;
	// sufixo A/B so no faturamento parcial (lSufixo), para o mesmo item.
	If !lSufixo .Or. !(cItemAnt == cItem)
		cCod := cItem
		nLetra := 65
	Else
		cCod := cItem + Chr(nLetra)
		nLetra++
	EndIf

	aAdd(aRet, {cCod, cProd, cDesc, cArm, dFat, dEnt, xQVen, xSEst, xSDis, xQEnt, xQSal, xRes,;
		cSta, cTes, cCF, cXPE, cPrz, cPE, cProc, cPO, cOS1, cOS2, cOS3, cCarga, cDtCg, cHrCg, cItem})

	cItemAnt := cItem

Return Nil

/*=================================================================
Info: Status 11/12 para parcela faturada (NF + coleta SZJ/SZI)
Autor: Fernando Pessoa / Tecsistem - 04/08/2026
*==================================================================*/
Static Function VPIStatNF(cPed, cItem, cProd, cArm, cNota, cSerie, nQtd, aCacheDtCol, aCacheSomarQtd)

	Local cSta := ""
	Local cKey := ""
	Local dCol := ""
	Local nQtdNf := 0

	Default cNota  := ""
	Default cSerie := ""
	Default nQtd   := 0

	If Empty(cNota)
		cSta := "11 - Faturado (Qtd.: " + cValToChar(nQtd) + ")"
		Return cSta
	EndIf

	cKey := AllTrim(cNota)+"|"+AllTrim(cSerie)
	dCol := CacheGet(aCacheDtCol, cKey, Nil)
	If dCol == Nil
		dCol := GetDtColSZJ(AllTrim(cNota), AllTrim(cSerie))
		CachePut(@aCacheDtCol, cKey, dCol)
	EndIf

	cKey := AllTrim(cPed)+"|"+AllTrim(cItem)+"|"+AllTrim(cProd)+"|"+AllTrim(cArm)+"|"+AllTrim(cNota)+"|"+AllTrim(cSerie)
	nQtdNf := CacheGet(aCacheSomarQtd, cKey, Nil)
	If nQtdNf == Nil
		nQtdNf := SomarQtd(AllTrim(cPed), AllTrim(cItem), AllTrim(cProd), AllTrim(cArm), AllTrim(cNota), AllTrim(cSerie))
		CachePut(@aCacheSomarQtd, cKey, nQtdNf)
	EndIf
	If nQtdNf <= 0
		nQtdNf := nQtd
	EndIf

	If !Empty(dCol) .And. Len(AllTrim(dCol)) >= 8
		cSta := "12 - Coletado em "+Substr(dCol,7,2)+"/"+Substr(dCol,5,2)+"/"+Substr(dCol,1,4)+" , NF:"+AllTrim(cNota)+" (Qtd.: "+cValToChar(nQtdNf)+")"
	Else
		cSta := "11 - Faturado, NF: "+AllTrim(cNota)+" (Qtd.: "+cValToChar(nQtdNf)+")"
	EndIf

Return cSta

/*=================================================================
Info: Existe SC9 aberto (sem NF) para o item do pedido?
Autor: Fernando Pessoa / Tecsistem - 04/08/2026
*==================================================================*/
Static Function VPIHasSC9A(cPedido, cItem)

	Local lRet   := .F.
	Local cQuery := ""
	Local cAlias := ""
	Local aArea  := GetArea()

	Default cPedido := ""
	Default cItem   := ""

	If Empty(cPedido) .Or. Empty(cItem)
		RestArea(aArea)
		Return lRet
	EndIf

	cAlias := GetNextAlias()
	cQuery := " SELECT TOP 1 SC9.C9_ITEM "
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
	cQuery += "   AND SC9.C9_PEDIDO = '" + cPedido + "' "
	cQuery += "   AND SC9.C9_ITEM = '" + cItem + "' "
	cQuery += "   AND RTRIM(SC9.C9_NFISCAL) = '' "
	cQuery += "   AND SC9.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	BEGIN SEQUENCE
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .F., .T.)
		If Select(cAlias) > 0 .And. !(cAlias)->(Eof())
			lRet := .T.
		EndIf
	RECOVER
		lRet := .F.
	END SEQUENCE

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return lRet

/*=================================================================
Autor: Fernando Pessoa / Tecsistem
Data: 30/07/2026
Uso: Calibre
Info: Data de coleta via SZJ/SZI. Sem registro na SZJ para a NF, retorna vazio
      (evita Status 12 com data fantasma via F2_CRVROM/SZI).
*==================================================================*/
Static Function GetDtColSZJ(cNota,cSerie)

	Local cRet   := ""
	Local cQuery := ""
	Local cAlias := ""
	Local cNum   := ""
	Local aArea  := GetArea()

	Default cNota  := ""
	Default cSerie := ""

	If Empty(cNota)
		RestArea(aArea)
		Return cRet
	EndIf

	cAlias := GetNextAlias()
	cQuery := " SELECT TOP 1 SZJ.ZJ_NUM, SZI.ZI_DATA "
	cQuery += " FROM " + RetSqlName("SZJ") + " SZJ "
	cQuery += " INNER JOIN " + RetSqlName("SZI") + " SZI "
	cQuery += "   ON SZI.ZI_FILIAL = '" + xFilial("SZI") + "' "
	cQuery += "  AND SZI.ZI_NUM = SZJ.ZJ_NUM "
	cQuery += "  AND SZI.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SZJ.ZJ_FILIAL = '" + xFilial("SZJ") + "' "
	cQuery += "   AND SZJ.ZJ_NOTA = '" + cNota + "' "
	If !Empty(cSerie)
		cQuery += "   AND SZJ.ZJ_SERIE = '" + cSerie + "' "
	EndIf
	cQuery += "   AND SZJ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	BEGIN SEQUENCE
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .F., .T.)
		If Select(cAlias) > 0 .And. !(cAlias)->(Eof())
			cNum := AllTrim((cAlias)->ZJ_NUM)
			If !Empty(cNum)
				cRet := VPIDtStr((cAlias)->ZI_DATA)
			EndIf
		EndIf
	RECOVER
		cRet := ""
	END SEQUENCE

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return cRet

/*=================================================================
Info: Quantidade reservada em SC0 via SC9.C9_RESERVA = SC0.C0_NUM
Autor: Fernando Pessoa / Tecsistem - 30/07/2026
*==================================================================*/
Static Function VPIQtdSC0(cPedido, cItem)

	Local nRet   := 0
	Local cQuery := ""
	Local cAlias := ""
	Local aArea  := GetArea()

	Default cPedido := ""
	Default cItem   := ""

	If Empty(cPedido) .Or. Empty(cItem)
		RestArea(aArea)
		Return nRet
	EndIf

	// Campo C9_RESERVA pode nao existir em todos os ambientes
	DbSelectArea("SC9")
	If SC9->(FieldPos("C9_RESERVA")) == 0
		RestArea(aArea)
		Return nRet
	EndIf

	cAlias := GetNextAlias()
	cQuery := " SELECT SUM(SC0.C0_QUANT) AS QTDRES "
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("SC0") + " SC0 "
	cQuery += "   ON SC0.C0_FILIAL = '" + xFilial("SC0") + "' "
	cQuery += "  AND RTRIM(SC0.C0_NUM) = RTRIM(SC9.C9_RESERVA) "
	cQuery += "  AND SC0.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
	cQuery += "   AND SC9.C9_PEDIDO = '" + cPedido + "' "
	cQuery += "   AND SC9.C9_ITEM = '" + cItem + "' "
	cQuery += "   AND RTRIM(SC9.C9_RESERVA) <> '' "
	cQuery += "   AND SC9.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	BEGIN SEQUENCE
		DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .F., .T.)
		If Select(cAlias) > 0 .And. !(cAlias)->(Eof())
			nRet := VPIVal((cAlias)->QTDRES)
		EndIf
	RECOVER
		nRet := 0
	END SEQUENCE

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return nRet

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
User Function APedVe()

	Local cAliaAnte := Alias()
	Local nAreaAnte := IndexOrd()
	Local nRegiAnte := RecNo()
	Local _cFatSN
	Local aFatSN    := {'S','N'}
	Local cFtSNOg
	Local cTpLOg
	Local aTpLib    := {'1 - Libera Item','2 - Libera Pedido'}
	Local cPedVin
	Local cCPgto
	Local cTransp
	Local cTTFret
	Local aTTFret	:= {'C - CIF','F - FOB','T - Redespacho','S - Sem Frete'}
	Local cMenNot
	Local aUser     := PswRet()
	Local _actxt    := ''                 
	Local oFont     := tfont():new("Fatura Sim ou Nao",,-11,.t.)
	Local _SegTPPV  := .F.
	Local ia        := 0

	cFatSN 	:= SC5->C5_XFATURA
	cFtSNOg	:= SC5->C5_XFATURA
	cTpLOg	:= SC5->C5_TIPLIB
	cPedVin	:= SC5->C5_XPEDVIN
	cCPgto	:= SC5->C5_CONDPAG
	cTransp	:= SC5->C5_TRANSP
	cMenNot	:= SC5->C5_MENNOTA
	_actxt  := SC5->C5_CRVOBS
	
	For ia := 1 to Len(aUser[1][10])   //Codigo do Grupo de usuarios
		If aUser[1][10][ia] $ "000002/000009/000013/000035"                 //000002- Grupos Diretoria/000009-Gerencia Comercial/000013-Gerencia Logistica/000035-Libera ALtera sem Estorno
			_SegTPPV := .T.
		EndIf
	Next ia

	If SC5->C5_TIPLIB = '1'
		cTpLib := aTpLib[1]
	Else
		cTpLib := aTpLib[2]
	EndIf

	If SC5->C5_TPFRETE = 'C'
		cTTFret	:= aTTFret[1]
	ElseIf SC5->C5_TPFRETE = 'F'
		cTTFret	:= aTTFret[2]
	ElseIf SC5->C5_TPFRETE = 'T'
		cTTFret	:= aTTFret[3]
	ElseIf SC5->C5_TPFRETE = 'S'
		cTTFret	:= aTTFret[4]
	EndIf

	cNPed    := AllTrim(SC5->C5_NUM)
	cDesCli  := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,"A1_NOME")
	cDtEmis  := DtoS(SC5->C5_EMISSAO)
	cEmiss   := SubStr(cDtEmis,7,2)+"/"+SubStr(cDtEmis,5,2)+"/"+SubStr(cDtEmis,1,4)

	If !VAtlPV(SC5->C5_NUM)
		MsgBox("Pedido de Venda na Carga. Nao e possivel fazer alteracoes do mesmo","ERRO-MA410MNU.PRW-CARVALHAES","STOP")
		dbSelectArea(cAliaAnte)
		dbSetOrder(nAreaAnte)
		dbGoTo(nRegiAnte)
		Return()
	EndIf

	DEFINE MSDIALOG _oDlg TITLE "Alteracao Pedido de Venda" FROM 000, 000 TO 450, 600 PIXEL
	@ 008, 005 SAY "Pedido :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 018, 005 SAY "Cliente:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 034 SAY oSayNPed VAR cNPed SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 018, 034 SAY oSayDesCli VAR cDesCli SIZE 139, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 005 SAY "Fatura S/N :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	oCombo := tComboBox():new(028,60,{|u|if(pcount()>0,cFatSN:=u,cFatSN)},aFatSN, 35, 20,_oDlg,,,,,,.t.,oFont,,,,,,,,"cFatSN")

	@ 028, 110 SAY "Tip Liberacao :" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
	oCombo := tComboBox():new(028,160,{|u|if(pcount()>0,cTpLib:=u,cTpLib)},aTpLib, 80, 20,_oDlg,,,,,,.t.,oFont,,,,,,,,"cTpLib")
	@ 045,005 SAY "Vinculo  :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045,034 MSGET oGetPedV VAR cPedVin Picture "@!" SIZE 060,10 PIXEL OF oDlg F3 "SZ0" //VALID VldTransp(SC5->C5_TRANSP,SC5->C5_CLIENTE, SC5->C5_LOJACLI)

	@ 070,005 SAY "Mens. NF:" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070,034 MSGET oGetMen VAR cMenNot Picture "@!" SIZE 300,10 PIXEL OF oDlg // F3 "SA4"

	@ 085,005 SAY "Obs.Interna:" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 085,034 GET oMemo  VAR _actxt MEMO SIZE 200,100 OF oDlg PIXEL

	@ 200, 250 BUTTON "Sair" SIZE 030, 012 OF _oDlg ACTION _oDlg:End() PIXEL
	@ 200, 100 Button "Alterar Pedido" Size 130, 012 PIXEL OF _oDlg Action(MudaPed(cFatSN,cTpLib, cFtSNOg,cTpLOg,cPedVin,cCPgto,cTransp,cTTFret,cMenNot,_SegTPPV,_actxt)) //When !empty(cDesCli)

	ACTIVATE MSDIALOG _oDlg CENTERED

	dbSelectArea(cAliaAnte)
	dbSetOrder(nAreaAnte)
	dbGoTo(nRegiAnte)
	
Return

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function VldTra(_NumPV,_cTransp)

	Local _Ret := .T.
	Local sData
	Local aVlTra := {}

	dbSelectArea("SC5")  // Itens do Pedido
	dbSetOrder(1) //
	dbSeek(xFilial("SC5")+_NumPV)
	
	sData	:= DtoS(SC5->C5_EMISSAO)

	dbSelectArea("SC6")  // Itens do Pedido
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+_NumPV))
	
	Do While !Eof() .and. xFilial("SC6") = SC6->C6_FILIAL .AND.	SC6->C6_NUM = _NumPV
		
		dbSelectArea("SB1")  // Itens do Pedido
		SB1->(dbSetOrder(1)) //
		SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		
		If SB1->B1_CRVPF=="S"
			If !empty(_cTransp)
				
				aVlTra  := U_VlTrPFEX(_cTransp,sData,"PF",.t.)
				_Ret	:= aVlTra[1][1]
				Exit
			EndIf
		EndIf
		
		If SB1->B1_CRVME=='S'
			If !empty(_cTransp)  .and. _Ret
				
				aVlTra  := U_VlTrPFEX(_cTransp,sData,"EX",.t.)
				_Ret 	:= aVlTra[1][1]
				Exit
			EndIf
		EndIf

		SC6->(dbSelectArea("SC6"))
		SC6->(dbSkip())
	EndDo
	
Return(_Ret)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function MudaPed(_FatSN,_TpLib,_FSNOg, _TpLOg,_PedVin,_CPgto,_cTranp,_TTFret,_MenNot,_SegTPPV,_actxt)

	If _FatSN <> _FSNOg

		dbSelectArea("SC5")  // Itens do Pedido
		dbSetOrder(1) // C5_FILIAL+C5_NUM
		dbSeek(xFilial("SC5")+SC5->C5_NUM)
		RecLock("SC5",.F.)
		SC5->C5_XFATURA := _FatSN
		MsUnLock()

		dbSelectArea("SC9")  // Itens do Pedido
		dbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM
		dbSeek(xFilial("SC9")+SC5->C5_NUM)
		
		Do While !Eof() .and. xFilial("SC9") = SC9->C9_FILIAL .AND.;
				SC9->C9_PEDIDO = SC5->C5_NUM
			RecLock("SC9",.F.)
			SC9->C9_XFATURA := _FatSN
			MsUnLock()
			dbSelectArea("SC9")
			dbSkip()
		EndDo
	EndIf

	If SUBSTR(LTRIM(RTRIM(_TpLib)),1,1) <> _TpLOg
		dbSelectArea("SC5")  // Itens do Pedido
		dbSetOrder(1) // C5_FILIAL+C5_NUM
		dbSeek(xFilial("SC5")+SC5->C5_NUM)
		RecLock("SC5",.F.)
		SC5->C5_TIPLIB	:= SUBSTR(LTRIM(RTRIM(_TpLib)),1,1)
		MsUnLock()
	EndIf
	
	dbSelectArea("SC5")  // Itens do Pedido
	dbSetOrder(1) // C5_FILIAL+C5_NUM
	dbSeek(xFilial("SC5")+SC5->C5_NUM)
	
	RecLock("SC5",.F.)
	SC5->C5_XPEDVIN	:= _PedVin
	SC5->C5_MENNOTA	:=_MenNot
	SC5->C5_CRVOBS	:=_actxt
	MsUnLock()
	
	_oDlg:End()
	
Return

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function VAtlPV(_nPed)

	Local _nRet := .T.
	Local _NumReg := 0

	IIF(Select("SQL")!= 0, SQL->(DbCLoseArea()), )
	cQuery 	:= " SELECT COUNT(*) AS NUMGEG "
	cQuery 	+= " FROM "+ RetSqlName('SC9')+ " SC9  "
	cQuery 	+= " WHERE SC9.D_E_L_E_T_ = ' '  "
	cQuery 	+= "		AND SC9.C9_PEDIDO = '"+_nPed+"'  "
	cQuery 	+= "		AND C9_CARGA <> ' ' "
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SQL', .F., .T.)

	DbSelectArea("SQL")
	DbGoTop()
	
	_NumReg := SQL->NUMGEG
	
	SQL->(DbCLoseArea())

	If _NumReg > 0
		_nRet := .F.
	EndIf

Return(_nRet)

/*=================================================================
Autor: Desconhecido
Data: 27/03/2026
Consultoria: 
Uso: Calibre
Info: 
*==================================================================*/ 
User Function VldTransp( _TRANSP,_Cli,_Loja)

	Local lRetorno  := .t.
	Local sData     :=Dtos(SC5->C5_EMISSAO)
	Local aVlTra 	:= {}
	Local _cQry

	_cQry  :="	SELECT SC9.C9_PEDIDO     AS PEDIDO,    	"
	_cQry  +="			SC9.C9_CLIENTE   AS CLIENTE,   	"
	_cQry  +="			SC9.C9_LOJA      AS LOJA,   	"
	_cQry  +="			SC9.C9_PRODUTO	 AS CODPRO,	  	"
	_cQry  +="			SB1.B1_CRVPF 	 AS CRVPF,    	"
	_cQry  +="			SB1.B1_CRVME     AS CRVME,    	"
	_cQry  +="			SUM(SC9.C9_QTDLIB) AS QTDLIB 	"
	_cQry  +=" FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+XFILIAL("SB1")+"' AND SC9.C9_PRODUTO = SB1.B1_COD AND SC9.D_E_L_E_T_ = SB1.D_E_L_E_T_  "//ALTERADO DYEGO 09/07/14
	_cQry  +=" WHERE SC9.D_E_L_E_T_ = ' ' "
	_cQry  +="			AND SC9.C9_FILIAL = '"+xFilial("SC9")+"' "
	_cQry  +="	        AND SC9.C9_PEDIDO = '"+SC5->C5_NUM+"'  "
	_cQry  +="	        AND SC9.C9_CLIENTE = '"+_Cli+"'  "
	_cQry  +="	        AND SC9.C9_LOJA   =  '"+_Loja+"'     "
	_cQry  +="GROUP BY SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA, SC9.C9_PRODUTO, SB1.B1_CRVPF, SB1.B1_CRVME "
	
	If Select("QRY") <> 0
		dbSelectArea("QRY")
		dbCloseArea()
	Endif
	
	TCQUERY _cQry NEW ALIAS "QRY"
	
	QRY->(DBGoTop())
	
	Do While !(QRY->(EOF()))
			
		If QRY->CRVPF=='S'  .AND. !empty(_TRANSP) .AND. lRetorno
			aVlTra 	:= U_VlTrPFEX(_TRANSP,sData,"PF",.t.)
			lRetorno :=	aVlTra[1][1]
		EndIf
		
		If QRY->CRVME=='S' .AND. !empty(_TRANSP) .AND. lRetorno
			aVlTra 	 := U_VlTrPFEX(_TRANSP,sData,"EX",.t.)
			lRetorno :=	aVlTra[1][1]
		EndIf
		
		If  !lRetorno
			Exit
		EndIf
		
		dbSelectArea("QRY")
		QRY->(DBSkip())
		
	EndDo
	
	dbSelectArea("QRY")
	dbCloseArea()
	
Return(lRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/07/2025
Consultoria: Proativa
Uso: Calibre
Info: C?lculo de IPI conforme a planilha 
*==================================================================*/ 
Static Function xIPI()

	Local nIPI     := 0
	Local nAliqIPI := 0
	Local cPedido  := SC5->C5_FILIAL+SC5->C5_NUM

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	If SC6->(DbSeek(cPedido))
	
		//Linha dos produtos 
		While !SC6->(EOF()) .And. (SC6->C6_FILIAL + SC6->C6_NUM == cPedido)

			//Impostos conforme a Planilha 	
			MaFisIni(SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C",SC5->C5_TIPO,SC5->C5_TIPOCLI,Nil,Nil,Nil,Nil,"MATA461",Nil,Nil,Nil,Nil,Nil,Nil,Nil,{},,,SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,0,,SC5->C5_TPFRETE)
			MaFisAdd(SC6->C6_PRODUTO,SC6->C6_TES,SC6->C6_QTDVEN,SC6->C6_PRCVEN,0,,,0,0,0,0,0,SC6->C6_VALOR,0)
					
			nAliqIPI := MaFisRet(1,"IT_ALIQIPI")
			nIPI     += SC6->C6_VALOR * nAliqIPI / 100
		
			MaFisSave()
			MaFisEnd()		
			
			SC6->(DbSkip())

		EndDo

	Endif 

Return(nIPI)

/*=================================================================
Info: Saldo disponivel (coluna Saldo Disp.) = B2_QATU - (B2_QEMP + B2_RESERVA)
      Independente de VPIBQAtu / Saldo Est.
*==================================================================*/
Static Function VPIBDisp(cProd,cLocal)

	Local nAtu := 0
	Local nEmp := 0
	Local nRes := 0
	Local cP   := AllTrim(cProd)
	Local cL   := AllTrim(cLocal)

	If Empty(cP) .Or. Empty(cL)
		Return 0
	EndIf

	If !VPIB2Pos(cP, cL)
		Return 0
	EndIf

	nAtu := SB2->B2_QATU

	BEGIN SEQUENCE
		nEmp := SB2->B2_QEMP
	RECOVER
		nEmp := 0
	END SEQUENCE

	BEGIN SEQUENCE
		nRes := SB2->B2_RESERVA
	RECOVER
		BEGIN SEQUENCE
			nRes := SB2->B2_QFIM
		RECOVER
			nRes := 0
		END SEQUENCE
	END SEQUENCE

	If nEmp < 0
		nEmp := 0
	EndIf

	If nRes < 0
		nRes := 0
	EndIf

Return Max(0, nAtu - (nEmp + nRes))

/*=================================================================
Autor: 
Data: 26/03/2026
Consultoria: TecSistem Solu??es em Sistemas de Informa??o
Uso: Calibre
Info: 
*==================================================================*/
Static Function xOrdemSep(_Cliente,_Loja,_Pedido,_Item) 
	
	Local aRetorno := {}
	Local cOrdem   := ""
	Local cOrdSep  := ""
	Local cDtemis  := ""
	Local cHremis  := ""

	DbSelectArea("SC9")  		//Pedidos Liberados
	SC9->(DbSetOrder(2))        //C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM  Filial+Cliente+Loja+Pedido+Item
	
	If SC9->(DBSeek(xFilial("SC9")+_Cliente+_Loja+_Pedido+_Item))
	
		cOrdem := SC9->C9_ORDSEP

		DbSelectArea("CB7") //Cabecalho de ordem separacao
		CB7->(DbSetOrder(1))  //CB7_FILIAL+CB7_ORDSEP	Numero Ordem
		
		If CB7->(DBSeek(xFilial("CB7")+cOrdem))
		
			cOrdSep := CB7->CB7_ORDSEP
			cDtemis  := DtoS(CB7->CB7_DTEMIS)
			cHremis  := CB7->CB7_HREMIS     

			aRetorno := {cOrdSep,cDtemis,cHremis}
			
		Else

			aRetorno := {cOrdSep,cDtemis,cHremis}
		
		EndIf
	Else
		aRetorno := {cOrdSep,cDtemis,cHremis}
	EndIf

Return(aRetorno)

/*=================================================================
Info: Carga das reservas (xTodos) dentro do VPIWait
*==================================================================*/
Static Function VPIResCar(cPedido, cProduto, cItem, cItemBase, aLbx, nRowSel, cTesProd)

	// Otávio Barreiro - 28/10/2026 - a grid ja traz o C6_ITEM real (posicao 27)
	Local cItemRef := cItemBase

	xTodos(cProduto, cTesProd, cPedido, cItemRef)

Return cItemRef

/*=================================================================
Autor: 
Data: 26/03/2026
Consultoria: TecSistem Solu??es em Sistemas de Informa??o
Uso: Calibre
Info: 
*==================================================================*/
Static Function ExReserv(cCliente,cLoja,cPedido,cItem,aLbx)

	Local cProduto      := ""
	Local cDescProd     := ""
	Local cTesProd      := ""
	Local cItemBase     := ItemBaseRes(cItem)
	Local cItemRef      := ""
	Local nRowSel       := 0
	Local cTitulo       := "EXIBIR RESERVAS - PEDIDO DE VENDAS: " + AllTrim(cPedido)
	Local nX            := 0
	Local cFiltro       := "3. Todos"
	Local aFiltros      := {"1. Prontos para faturar","2. Com bloqueio (mas c/ est)","3. Todos"}
	Local lRet          := .T.
	Local cTotQtd       := ""
	Local cTotVal       := ""
	Local cLbxRes       := ""
	Local bOldError     := ErrorBlock({|e| Break(e)})
	Local oErr          := Nil
	Local oCmb1         := Nil
	Local oBtnAtualizar := Nil

	Private aItem        := {}
	Private oTela        := Nil
	Private oProduto     := Nil
	Private oSayTotQtd   := Nil
	Private oSayTotVal   := Nil
	Private nTotQtdRes   := 0
	Private nTotValRes   := 0
	Private aCacheStatFin := {}

	BEGIN SEQUENCE

		For nX := 1 To Len(aLbx)
			If AllTrim(aLbx[nX][1]) == AllTrim(cItem)
				nRowSel  := nX
				cProduto := AllTrim(aLbx[nX][2])
				cDescProd := AllTrim(aLbx[nX][3])
				cTesProd := AllTrim(aLbx[nX][14]) // TES (apos mover Status)
				If Len(aLbx[nX]) >= 27 .And. !Empty(aLbx[nX][27])
					cItemBase := AllTrim(aLbx[nX][27])
				EndIf
				Exit
			EndIf
		Next nX

		If Empty(cProduto)
			MsgBox("Produto nao localizado para o item selecionado.")
			BREAK
		EndIf

		cItemRef := cItemBase

		VPIWait("Aguarde", "Carregando reservas do produto...", ;
			{|| cItemRef := VPIResCar(cPedido, cProduto, cItem, cItemBase, aLbx, nRowSel, cTesProd)}, oDlg)

		If Empty(aItem)
			MsgBox("Nao foram encontradas reservas para este Produto/Pedido!")
			lRet := .F.
		EndIf

		If lRet

			cTotQtd := Transform(nTotQtdRes, "@E 999,999,999.99")
			cTotVal := "R$ " + Transform(nTotValRes, "@E 999,999,999.99")

			//------------------------------------------------------------------
			// Mesmo padrao visual do dialog principal
			//------------------------------------------------------------------
			DEFINE MSDIALOG oTela TITLE cTitulo FROM 000, 000 TO 560, 1350 ;
				COLORS 0, 16777215 PIXEL

			//------------------------------------------------------------------
			// Cabecalho
			//------------------------------------------------------------------
			@ 008, 012 SAY "Codigo:" SIZE 028, 007 OF oTela COLORS 0, 16777215 PIXEL
			@ 008, 050 SAY cProduto SIZE 080, 007 OF oTela COLORS 0, 16777215 PIXEL

			@ 018, 012 SAY "Descricao:" SIZE 028, 007 OF oTela COLORS 0, 16777215 PIXEL
			@ 018, 050 SAY cDescProd SIZE 200, 007 OF oTela COLORS 0, 16777215 PIXEL

			@ 032, 012 SAY "Filtro:" SIZE 028, 007 OF oTela COLORS 0, 16777215 PIXEL

			@ 028, 050 MSCOMBOBOX oCmb1 VAR cFiltro ITEMS aFiltros ;
				SIZE 120, 030 OF oTela PIXEL

			@ 032, 190 SAY "Total Qtd:" SIZE 040, 007 OF oTela COLORS 0, 16777215 PIXEL
			@ 032, 252 SAY oSayTotQtd VAR cTotQtd SIZE 060, 007 OF oTela COLORS 0, 16777215 PIXEL

			@ 046, 190 SAY "Total Valor:" SIZE 040, 007 OF oTela COLORS 0, 16777215 PIXEL
			@ 046, 252 SAY oSayTotVal VAR cTotVal SIZE 100, 007 OF oTela COLORS 0, 16777215 PIXEL

			@ 030, 370 BUTTON oBtnAtualizar PROMPT "Atualizar" SIZE 055, 012 OF oTela PIXEL ;
				ACTION ( AplicarFiltro(cFiltro,cProduto,cTesProd,cPedido,cItemRef), ;
						 cTotQtd := Transform(nTotQtdRes, "@E 999,999,999.99"), ;
						 cTotVal := "R$ " + Transform(nTotValRes, "@E 999,999,999.99"), ;
						 oSayTotQtd:Refresh(), ;
						 oSayTotVal:Refresh(), ;
						 oProduto:Refresh() )

			//------------------------------------------------------------------
			// Listbox
			// Altura reduzida para obrigar scrollbar vertical quando houver
			// mais linhas que a area visivel, mantendo visual parecido com o
			// dialog principal.
			//------------------------------------------------------------------
			@ 075, 005 LISTBOX oProduto VAR cLbxRes FIELDS HEADER ;
				Padr("Filial",8),;
				Padr("Pedido",10),;
				"Item",;
				Padr("Emissao",10),;
				Padr("Dt p/Fatur",10),;
				Padr("Dt Entrega",10),;
				"Cliente",;
				"Loja",;
				Padr("Nome Cliente",25),;
				Padr("Vendedor",20),;
				"Reservado",; // Otávio Barreiro - 28/10/2026 - volta a ser C9_QTDLIB
				"Pr Unit",;
				"Total",;
				"Blq.Cred",;
				Padr("Status FIN",10),;
				"Blq.Est",;
				Padr("Numero OS",18),;
				Padr("Lote",15),; // Otávio Barreiro - 28/10/2026 - C9_LOTECTL
				Padr("Reserva",12),;
				Padr("Emissao Reserva",16) ; // C0_EMISSAO - sem SC0 fica em branco (Otávio Barreiro - 28/10/2026)
				SIZE 660, 120 OF oTela COLORS 0, 16777215 PIXEL

			oProduto:SetArray(aItem)

			oProduto:bLine := {|| VPIResLin(oProduto:nAt)}

			oProduto:Refresh()

			ACTIVATE MSDIALOG oTela CENTERED

		EndIf

	RECOVER USING oErr
		If ValType(oTela) == "O"
			BEGIN SEQUENCE
				oTela:End()
			RECOVER
			END SEQUENCE
			oTela := Nil
		EndIf
		BEGIN SEQUENCE
			If ValType(oDlg) == "O"
				oDlg:Enable()
			EndIf
		RECOVER
		END SEQUENCE
		MsgStop("Erro ao abrir Exibir Reservas: " + AllTrim(cValToChar(oErr:Description)))
	END SEQUENCE

	ErrorBlock(bOldError)

Return

/*=================================================================
Autor:
Data: 31/03/2026
Consultoria:
Uso: Calibre
Info: Converte item exibido (01A/01B) para item real (01)
*==================================================================*/
Static Function ItemBaseRes(cItemView)

	Local cItem := AllTrim(cItemView)
	Local cLast := ""

	While Len(cItem) > 0
		cLast := Upper(SubStr(cItem,Len(cItem),1))
		If !(cLast >= "A" .And. cLast <= "Z")
			Exit
		EndIf
		cItem := Left(cItem,Len(cItem)-1)
	EndDo

	If Empty(cItem)
		cItem := AllTrim(cItemView)
	EndIf

Return(cItem)

/*=================================================================
Autor: 
Data: 26/03/2026
Consultoria: TecSistem Solu??es em Sistemas de Informa??o
Uso: Calibre
Info: 
*==================================================================*/
Static Function AplicarFiltro(cFiltro,cProduto,cTesProd,cPedido,cItem)

	Local bOldError := ErrorBlock({|e| Break(e)})
	Local oErr      := Nil

	BEGIN SEQUENCE
		If SubStr(cFiltro,1,1) == "1" 
	   
			VPIWait("Aguarde", "Filtrando reservas prontas para faturar...", {|| PrtFat(cProduto,cTesProd,cPedido,cItem)}, oTela)
			
		Elseif SubStr(cFiltro,1,1) == "2"
	   
			VPIWait("Aguarde", "Filtrando reservas com bloqueio...", {|| BlqEst(cProduto,cTesProd,cPedido,cItem)}, oTela)
			
		Else
		   
			VPIWait("Aguarde", "Filtrando todas as reservas...", {|| xTodos(cProduto,cTesProd,cPedido,cItem)}, oTela)
			
		Endif 

		If ValType(oProduto) == "O"
			oProduto:nAt := 1
			oProduto:SetArray(aItem)
			oProduto:bLine := {|| VPIResLin(oProduto:nAt)}
			oProduto:Refresh()
		EndIf
		If ValType(oTela) == "O"
			oTela:Refresh()
		EndIf
	RECOVER USING oErr
		MsgStop("Erro ao atualizar reservas: "+AllTrim(cValToChar(oErr:Description)))
	END SEQUENCE

	ErrorBlock(bOldError)
	
Return

/*=================================================================
Info: JOINs auxiliares da tela Exibir Reservas
Autor: Fernando Pessoa / Tecsistem - 07/08/2026 - incluÃ­do SC0 (lote/emissao/qtd)
*==================================================================*/
Static Function VPIResJoi()

	Local cJoin := ""

	// Otávio Barreiro - 28/10/2026 - removido INNER JOIN SC0 (lista toda liberacao SC9)
	cJoin += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cJoin += "     ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cJoin += "     AND SA1.A1_COD = SC9.C9_CLIENTE "
	cJoin += "     AND SA1.A1_LOJA = SC9.C9_LOJA "
	cJoin += "     AND SA1.D_E_L_E_T_ = ' ' "
	cJoin += " LEFT JOIN " + RetSqlName("SA3") + " SA3 "
	cJoin += "     ON SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
	cJoin += "     AND SA3.A3_COD = SC5.C5_VEND1 "
	cJoin += "     AND SA3.D_E_L_E_T_ = ' ' "

Return cJoin

/*=================================================================
Info: Status FIN (C9_XSTATUS virtual) via U_LIBCRE01
*==================================================================*/
Static Function VPIStatFin(cPedido, cItem)

	Local cRet := ""
	Local cKey := ""

	Default cPedido := ""
	Default cItem   := ""

	If Empty(cPedido) .Or. Empty(cItem)
		Return cRet
	EndIf

	If ValType(aCacheStatFin) == "A"
		cKey := AllTrim(cPedido) + "|" + AllTrim(cItem)
		cRet := CacheGet(aCacheStatFin, cKey, Nil)
		If cRet != Nil
			Return cRet
		EndIf
	EndIf

	BEGIN SEQUENCE
		If FindFunction("U_LIBCRE01")
			cRet := AllTrim(cValToChar(U_LIBCRE01(cPedido, cItem)))
		EndIf
	RECOVER
		cRet := ""
	END SEQUENCE

	If ValType(aCacheStatFin) == "A"
		CachePut(@aCacheStatFin, cKey, cRet)
	EndIf

Return cRet

/*=================================================================
Info: Campos SELECT padrao da grid Exibir Reservas
Autor: Fernando Pessoa / Tecsistem - 07/08/2026
       Reservado=C9_QTDLIB; Lote=C9_LOTECTL - sem SC0 (Otávio Barreiro - 28/10/2026)
*==================================================================*/
Static Function VPIResSel()

	Local cRet := ""

	cRet := " SELECT SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_ITEM, SC9.C9_CLIENTE, SC9.C9_LOJA, "
	cRet += " SC9.C9_QTDLIB, SC9.C9_BLCRED, SC9.C9_BLEST, SC9.C9_ORDSEP, SC9.C9_RESERVA, "
	cRet += " SC9.C9_LOTECTL, "
	cRet += " SC6.C6_PRCVEN, SC6.C6_XEMISSA, SC6.C6_CRVENT, SC6.C6_ENTREG, SC5.C5_VEND1, SA1.A1_NOME, SA3.A3_NOME "

Return cRet

/*=================================================================
Info: Monta linha da grid Exibir Reservas
Autor: Fernando Pessoa / Tecsistem - 07/08/2026
*==================================================================*/
Static Function VPIResRow(cAlias)

	Local cVend := AllTrim((cAlias)->C5_VEND1)
	Local nQtdR := 0

	If !Empty((cAlias)->A3_NOME)
		cVend += " - " + AllTrim((cAlias)->A3_NOME)
	EndIf

	nQtdR := VPIVal((cAlias)->C9_QTDLIB)

Return {;
	(cAlias)->C9_FILIAL,;
	(cAlias)->C9_PEDIDO,;
	(cAlias)->C9_ITEM,;
	VPIDtFmt((cAlias)->C6_XEMISSA),;
	VPIDtFmt((cAlias)->C6_CRVENT),;
	VPIDtFmt((cAlias)->C6_ENTREG),;
	(cAlias)->C9_CLIENTE,;
	(cAlias)->C9_LOJA,;
	SubStr(AllTrim((cAlias)->A1_NOME), 1, 30),;
	cVend,;
	Transform(nQtdR, "@E 999,999,999.99"),;
	"R$ " + Transform((cAlias)->C6_PRCVEN, "@E 999,999,999.99"),;
	"R$ " + Transform((nQtdR * (cAlias)->C6_PRCVEN), "@E 999,999,999.99"),;
	(cAlias)->C9_BLCRED,;
	VPIStatFin((cAlias)->C9_PEDIDO, (cAlias)->C9_ITEM),;
	(cAlias)->C9_BLEST,;
	(cAlias)->C9_ORDSEP,;
	AllTrim((cAlias)->C9_LOTECTL),;
	AllTrim((cAlias)->C9_RESERVA),;
	""}

/*=================================================================
Info: bLine da grid Exibir Reservas
*==================================================================*/
Static Function VPIResLin(nAt)

	Local aVazio := {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""}

	If ValType(aItem) != "A" .Or. nAt <= 0 .Or. nAt > Len(aItem) .Or. Len(aItem[nAt]) < 20
		Return aVazio
	EndIf

Return {;
	AllTrim(aItem[nAt, 1]),;
	AllTrim(aItem[nAt, 2]),;
	AllTrim(aItem[nAt, 3]),;
	AllTrim(aItem[nAt, 4]),;
	AllTrim(aItem[nAt, 5]),;
	AllTrim(aItem[nAt, 6]),;
	AllTrim(aItem[nAt, 7]),;
	AllTrim(aItem[nAt, 8]),;
	AllTrim(aItem[nAt, 9]),;
	AllTrim(aItem[nAt,10]),;
	AllTrim(aItem[nAt,11]),;
	AllTrim(aItem[nAt,12]),;
	AllTrim(aItem[nAt,13]),;
	AllTrim(aItem[nAt,14]),;
	AllTrim(aItem[nAt,15]),;
	AllTrim(aItem[nAt,16]),;
	AllTrim(aItem[nAt,17]),;
	AllTrim(aItem[nAt,18]),;
	AllTrim(aItem[nAt,19]),;
	AllTrim(aItem[nAt,20])}

/*=================================================================
Autor: 
Data: 26/03/2026
Consultoria: TecSistem Solu??es em Sistemas de Informa??o
Uso: Calibre
Info: 
*==================================================================*/
Static Function PrtFat(cProduto,cTesProd,cPedido,cItem)

	Local cQuery := ""
	Local cTemp  := GetNextAlias()
	Local aDados := {}
	
	If ValType(aItem) == "A"
		aSize(aItem,0)
	Else
		aItem := {}
	EndIf
	aCacheStatFin := {}
	nTotQtdRes := 0
	nTotValRes := 0

	cQuery := VPIResSel()
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
	cQuery += "     ON SC6.C6_FILIAL = SC9.C9_FILIAL "
	cQuery += "     AND SC6.C6_NUM = SC9.C9_PEDIDO "
	cQuery += "     AND SC6.C6_ITEM = SC9.C9_ITEM "
	cQuery += "     AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cQuery += "     AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
	cQuery += "     ON SC5.C5_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SC5.C5_NUM = SC6.C6_NUM "
	cQuery += "     AND SC5.C5_TIPO = 'N' "
	cQuery += "     AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
	cQuery += "     ON SF4.F4_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SF4.F4_CODIGO = SC6.C6_TES "
	// Ticket #10XX - Aldo 22/10/26
	// eliminar a limitação de exibição de itens com tes que movimenta estoque
	//	cQuery += "     AND SF4.F4_ESTOQUE = 'S' "
	cQuery += "     AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += VPIResJoi()
	cQuery += " WHERE SC9.C9_PRODUTO = '"+cProduto+"' "
	cQuery += "     AND (SC9.C9_PEDIDO <> '"+cPedido+"' OR (SC9.C9_PEDIDO = '"+cPedido+"' AND SC9.C9_ITEM = '"+cItem+"')) "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLCRED,'')))  = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLOQUEI,''))) = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLEST,'')))   = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLWMS,'')))   = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLTMS,'')))   = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLQPAG,'')))  = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLQFRT,'')))  = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLQTRAN,''))) = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLQDESC,''))) = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_XBLPVTO,''))) = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_BLQDTV,'')))  = '' "
	cQuery += "     AND LTRIM(RTRIM(ISNULL(SC9.C9_XBLQRC,'')))  = '' "
	cQuery += "     AND LTRIM(RTRIM(SC9.C9_NFISCAL)) = '' "
	cQuery += "     AND SC9.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SC9.C9_PEDIDO, SC9.C9_ITEM "
	
	If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
        cTemp := GetNextAlias()    
    Endif 
    
    cQuery := ChangeQuery(cQuery)
	
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
    
    DbSelectArea(cTemp)
    (cTemp)->(DbGoTop())
    
    While !(cTemp)->(Eof())

		aDados := VPIResRow(cTemp)

		aAdd(aItem,aDados)
		nTotQtdRes += VPIVal((cTemp)->C9_QTDLIB)
		nTotValRes += (VPIVal((cTemp)->C9_QTDLIB) * (cTemp)->C6_PRCVEN)
        
		(cTemp)->(DbSkip())
		
    EndDo

    (cTemp)->(DbCloseArea())

Return 

/*=================================================================
Autor: 
Data: 26/03/2026
Consultoria: TecSistem Solu??es em Sistemas de Informa??o
Uso: Calibre
Info: 
*==================================================================*/
Static Function BlqEst(cProduto,cTesProd,cPedido,cItem)

	Local cQuery := ""
	Local cTemp  := GetNextAlias()
	Local aDados := {}

	If ValType(aItem) == "A"
		aSize(aItem,0)
	Else
		aItem := {}
	EndIf
	nTotQtdRes := 0
	nTotValRes := 0
	aCacheStatFin := {}

	cQuery := VPIResSel()
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
	cQuery += "     ON SC6.C6_FILIAL = SC9.C9_FILIAL "
	cQuery += "     AND SC6.C6_NUM = SC9.C9_PEDIDO "
	cQuery += "     AND SC6.C6_ITEM = SC9.C9_ITEM "
	cQuery += "     AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cQuery += "     AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
	cQuery += "     ON SC5.C5_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SC5.C5_NUM = SC6.C6_NUM "
	cQuery += "     AND SC5.C5_TIPO = 'N' "
	cQuery += "     AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
	cQuery += "     ON SF4.F4_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SF4.F4_CODIGO = SC6.C6_TES "
	// Ticket #10XX - Aldo 22/10/26
	// eliminar a limitação de exibição de itens com tes que movimenta estoque
	//cQuery += "     AND SF4.F4_ESTOQUE = 'S' "
	cQuery += "     AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += VPIResJoi()
	cQuery += " WHERE SC9.C9_PRODUTO = '"+cProduto+"' "
	cQuery += "     AND (SC9.C9_PEDIDO <> '"+cPedido+"' OR (SC9.C9_PEDIDO = '"+cPedido+"' AND SC9.C9_ITEM = '"+cItem+"')) "
	cQuery += "     AND ( "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLEST,'')))   <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLCRED,'')))  <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLOQUEI,''))) <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLWMS,'')))   <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLTMS,'')))   <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLQPAG,'')))  <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLQFRT,'')))  <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLQTRAN,''))) <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLQDESC,''))) <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_XBLPVTO,''))) <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_BLQDTV,'')))  <> '' OR "
	cQuery += "           LTRIM(RTRIM(ISNULL(SC9.C9_XBLQRC,'')))  <> '' "
	cQuery += "         ) "
	cQuery += "     AND LTRIM(RTRIM(SC9.C9_NFISCAL)) = '' "
	cQuery += "     AND SC9.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SC9.C9_PEDIDO, SC9.C9_ITEM "
	
	If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
        cTemp := GetNextAlias()    
    Endif 
    
    cQuery := ChangeQuery(cQuery)
	
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
    
    DbSelectArea(cTemp)
    (cTemp)->(DbGoTop())
    
    While !(cTemp)->(Eof())
        
		aDados := VPIResRow(cTemp)

		aAdd(aItem,aDados)
		nTotQtdRes += VPIVal((cTemp)->C9_QTDLIB)
		nTotValRes += (VPIVal((cTemp)->C9_QTDLIB) * (cTemp)->C6_PRCVEN)
        
		(cTemp)->(DbSkip())
		
    EndDo

    (cTemp)->(DbCloseArea())

Return 

/*=================================================================
Autor: 
Data: 26/03/2026
Consultoria: TecSistem Solu??es em Sistemas de Informa??o
Uso: Calibre
Info: 
*==================================================================*/
Static Function xTodos(cProduto,cTesProd,cPedido,cItem)

	Local cQuery := ""
	Local cTemp  := GetNextAlias()
	Local aDados := {}

	If ValType(aItem) == "A"
		aSize(aItem,0)
	Else
		aItem := {}
	EndIf
	nTotQtdRes := 0
	nTotValRes := 0
	aCacheStatFin := {}

	cQuery := VPIResSel()
	cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
	cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
	cQuery += "     ON SC6.C6_FILIAL = SC9.C9_FILIAL "
	cQuery += "     AND SC6.C6_NUM = SC9.C9_PEDIDO "
	cQuery += "     AND SC6.C6_ITEM = SC9.C9_ITEM "
	cQuery += "		AND SC6.C6_PRODUTO = SC9.C9_PRODUTO"
	cQuery += "     AND SC6.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
	cQuery += "     ON SC5.C5_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SC5.C5_NUM = SC6.C6_NUM "
	cQuery += "     AND SC5.C5_TIPO = 'N' "
	cQuery += "     AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
	cQuery += "     ON SF4.F4_FILIAL = SC6.C6_FILIAL "
	cQuery += "     AND SF4.F4_CODIGO = SC6.C6_TES "
	// Ticket #10XX - Aldo 22/10/26
	// eliminar a limitação de exibição de itens com tes que movimenta estoque
	//cQuery += "     AND SF4.F4_ESTOQUE = 'S' "
	cQuery += "     AND SF4.D_E_L_E_T_ = ' ' "
	cQuery += VPIResJoi()
	cQuery += " WHERE SC9.C9_PRODUTO = '"+cProduto+"'"
	cQuery += "     AND ( "
	cQuery += "           (SC9.C9_PEDIDO = '"+cPedido+"' AND SC9.C9_ITEM = '"+cItem+"') "
	cQuery += "           OR SC9.C9_PEDIDO <> '"+cPedido+"' "
	cQuery += "         ) "
	cQuery += "     AND LTRIM(RTRIM(SC9.C9_NFISCAL)) = '' "
	cQuery += "     AND SC9.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SC9.C9_PEDIDO, SC9.C9_ITEM "
	
	If Select(cTemp) > 0
        (cTemp)->(DbCloseArea())
        cTemp := GetNextAlias()    
    Endif 
    
    cQuery := ChangeQuery(cQuery)
	
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
    
    DbSelectArea(cTemp)
    (cTemp)->(DbGoTop())
    
    While !(cTemp)->(Eof())
        
		aDados := VPIResRow(cTemp)

		aAdd(aItem,aDados)
		nTotQtdRes += VPIVal((cTemp)->C9_QTDLIB)
		nTotValRes += (VPIVal((cTemp)->C9_QTDLIB) * (cTemp)->C6_PRCVEN)
        
		(cTemp)->(DbSkip())
		
    EndDo

    (cTemp)->(DbCloseArea())

Return

/*=================================================================
Info: Converte data para string sem derrubar a rotina
*==================================================================*/
Static Function VPIDtStr(uData)

	Local cRet  := ""
	Local dData := CtoD("")
	Local oErr

	If Empty(uData)
		Return ""
	EndIf

	BEGIN SEQUENCE
		If ValType(uData) == "D"
			dData := uData
		Else
			dData := StoD(AllTrim(cValToChar(uData)))
		EndIf
		If !Empty(dData)
			cRet := DtoS(dData)
		EndIf
	RECOVER USING oErr
		cRet := ""
	END SEQUENCE

Return cRet

/*=================================================================
Info: Data no formato DD/MM/AAAA para exibicao na grid
*==================================================================*/
Static Function VPIDtFmt(uData)

	Local cDta := VPIDtStr(uData)
	Local cRet := ""

	If !Empty(cDta)
		cRet := SubStr(cDta, 7, 2) + "/" + SubStr(cDta, 5, 2) + "/" + SubStr(cDta, 1, 4)
	EndIf

Return cRet

/*=================================================================
Info: CFOP do item SC6 sem depender do recno corrente
*==================================================================*/
Static Function VPI6CF(cPedido, cItem)

	Local cRet := ""

	BEGIN SEQUENCE
		cRet := AllTrim(Posicione("SC6", 1, xFilial("SC6") + cPedido + cItem, "C6_CF"))
	RECOVER
		cRet := ""
	END SEQUENCE

Return cRet

/*=================================================================
Info: Linha segura da grid (evita erro por indice/coluna invalida)
*==================================================================*/
Static Function VPILinBx(nAt)

	Local aVaz := {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""}

	If nAt < 1 .Or. nAt > Len(aLbx) .Or. Len(aLbx[nAt]) < 26
		Return aVaz
	EndIf

Return {AllTrim(aLbx[nAt, 1]),;
	AllTrim(aLbx[nAt, 2]),;
	AllTrim(aLbx[nAt, 3]),;
	AllTrim(aLbx[nAt, 4]),;
	AllTrim(aLbx[nAt, 5]),;
	aLbx[nAt, 6],;
	aLbx[nAt, 7],;
	aLbx[nAt, 8],;
	aLbx[nAt, 9],;
	aLbx[nAt, 10],;
	aLbx[nAt, 11],;
	aLbx[nAt, 12],;
	aLbx[nAt, 13],;
	aLbx[nAt, 14],;
	aLbx[nAt, 15],;
	aLbx[nAt, 16],;
	aLbx[nAt, 17],;
	aLbx[nAt, 18],;
	aLbx[nAt, 19],;
	aLbx[nAt, 20],;
	aLbx[nAt, 21],;
	aLbx[nAt, 22],;
	aLbx[nAt, 23],;
	aLbx[nAt, 24],;
	aLbx[nAt, 25],;
	aLbx[nAt, 26]}

/*=================================================================
Info: Acao segura do botao Exibir Reservas (oLbx ja existe)
*==================================================================*/
Static Function VPIBtnRs()

	Local cItem := ""

	If ValType(oLbx) == "O" .And. oLbx:nAt > 0 .And. oLbx:nAt <= Len(aLbx)
		cItem := aLbx[oLbx:nAt, 1]
	ElseIf Len(aLbx) > 0
		cItem := aLbx[1, 1]
	EndIf

	ExReserv(IIf(!(_TipPV $ "D|B"), cCoCli, cFornc), cLoja, _NumPed, cItem, aLbx)

Return Nil

/*=================================================================
Info: Campo customizado do item SC6 sem depender do recno corrente
*==================================================================*/
Static Function VPI6Fld(cPedido, cItem, cCampo)

	Local uRet := ""

	Default cPedido := ""
	Default cItem   := ""
	Default cCampo  := ""

	If Empty(cPedido) .Or. Empty(cItem) .Or. Empty(cCampo)
		Return uRet
	EndIf

	BEGIN SEQUENCE
		uRet := Posicione("SC6", 1, xFilial("SC6") + cPedido + cItem, cCampo)
	RECOVER
		uRet := ""
	END SEQUENCE

Return uRet

/*=================================================================
Info: Mensagem de erro para exibicao em tela (nao fecha o MATA410)
*==================================================================*/
Static Function VPIMsgEr(oErr, cPedido)

	Local cMsg := "Nao foi possivel abrir a Vis. Pend II." + CRLF + CRLF
	Local cAux := ""

	Default cPedido := ""
	Default oErr    := Nil

	cMsg += "Pedido: " + AllTrim(cPedido) + CRLF

	If ValType(oErr) == "O"
		cAux := VPIErrPr(oErr, "DESCRIPTION")
		If !Empty(cAux)
			cMsg += CRLF + "Erro: " + AllTrim(cValToChar(cAux))
		EndIf
		cAux := VPIErrPr(oErr, "OPERATION")
		If !Empty(cAux)
			cMsg += CRLF + "Operacao: " + AllTrim(cValToChar(cAux))
		EndIf
		cAux := VPIErrPr(oErr, "PROCNAME")
		If !Empty(cAux)
			cMsg += CRLF + "Rotina: " + AllTrim(cValToChar(cAux))
		EndIf
		cAux := VPIErrPr(oErr, "PROCLINE")
		If ValType(cAux) == "N" .And. cAux > 0
			cMsg += CRLF + "Linha: " + cValToChar(cAux)
		EndIf
	Else
		cMsg += CRLF + "Erro desconhecido ao processar o pedido."
	EndIf

Return cMsg

/*=================================================================
Info: Le propriedade do objeto de erro sem derrubar a rotina
*==================================================================*/
Static Function VPIErrPr(oErr, cProp)

	Local uRet := ""

	Default cProp := ""

	If ValType(oErr) != "O" .Or. Empty(cProp)
		Return uRet
	EndIf

	BEGIN SEQUENCE
		Do Case
		Case Upper(cProp) == "DESCRIPTION"
			uRet := oErr:Description
		Case Upper(cProp) == "OPERATION"
			uRet := oErr:Operation
		Case Upper(cProp) == "PROCNAME"
			uRet := oErr:ProcName
		Case Upper(cProp) == "PROCLINE"
			uRet := oErr:ProcLine
		EndCase
	RECOVER
		uRet := ""
	END SEQUENCE

Return uRet

/*=================================================================
Info: Campos customizados SC6 em uma unica leitura (com cache)
*==================================================================*/
Static Function VPI6Itm(cPedido, cItem, aCache)

	Local cKey := ""
	Local aRet := {"", 0, "", ""}

	Default cPedido := ""
	Default cItem   := ""
	Default aCache  := {}

	If Empty(cPedido) .Or. Empty(cItem)
		Return aRet
	EndIf

	cKey := AllTrim(cPedido) + "|" + AllTrim(cItem)
	aRet := CacheGet(aCache, cKey, Nil)

	If aRet != Nil
		Return aRet
	EndIf

	aRet := {"", 0, "", ""}

	BEGIN SEQUENCE
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(xFilial("SC6") + cPedido + cItem))
			aRet[1] := AllTrim(SC6->C6_XVINSW1)
			aRet[2] := VPIVal(SC6->C6_XPE)
			aRet[3] := AllTrim(SC6->C6_XPRZFOR)
			aRet[4] := AllTrim(SC6->C6_CF)
		EndIf
	RECOVER
		aRet := {"", 0, "", ""}
	END SEQUENCE

	CachePut(@aCache, cKey, aRet)

Return aRet

/*=================================================================
Info: PVTdLib com cache por pedido/item
*==================================================================*/
Static Function VPIPVLib(cPedido, cItem, aCache)

	Local cKey := ""
	Local lRet := .F.

	Default cPedido := ""
	Default cItem   := ""
	Default aCache  := {}

	If Empty(cPedido) .Or. Empty(cItem)
		Return lRet
	EndIf

	cKey := AllTrim(cPedido) + "|" + AllTrim(cItem)
	lRet := CacheGet(aCache, cKey, Nil)

	If lRet != Nil
		Return lRet
	EndIf

	lRet := PVTdLib(cPedido, cItem)
	CachePut(@aCache, cKey, lRet)

Return lRet

/*=================================================================
Info: Grava log de erro no StartPath do AppServer
*==================================================================*/
Static Function VPIWrLog(cMsg)

	Local cArq := ""

	Default cMsg := ""

	cArq := GetSrvProfString("StartPath", "") + "VPendII_erro.log"
	MemoWrite(cArq, DToC(Date()) + " " + Time() + CRLF + cMsg)

Return Nil

/*=================================================================
Info: Log de rastreamento (ativar/desativar com lVPITrace)
*==================================================================*/
Static Function VPILog(cMsg)

	Local cArq := GetSrvProfString("StartPath", "") + "VPendII_trace.log"
	Local nH

	nH := FOpen(cArq, 2)
	If nH < 0
		nH := FCreate(cArq)
	EndIf
	If nH >= 0
		FSeek(nH, 0, 2)
		FWrite(nH, DToC(Date()) + " " + Time() + " | " + AllTrim(cValToChar(cMsg)) + CRLF)
		FClose(nH)
	EndIf

Return Nil

/*=================================================================
Info: Converte valor para numerico (aceita C ou N do Posicione)
*==================================================================*/
Static Function VPIVal(uVal)

	If ValType(uVal) == "N"
		Return uVal
	EndIf

	If ValType(uVal) == "C"
		Return Val(AllTrim(uVal))
	EndIf

Return 0

/*=================================================================
Info: Converte S/N para Sim/Nao com acento correto na tela
Autor: Fernando Pessoa / Tecsistem - 30/07/2026
*==================================================================*/
Static Function VPISimNao(cVal)

	Local cRet := ""
	Local cKey := Upper(AllTrim(cValToChar(cVal)))

	Default cVal := ""

	If Empty(cKey)
		Return cRet
	EndIf

	Do Case
	Case cKey $ "S|SIM"
		cRet := "Sim"
	Case cKey $ "N|NAO"
		cRet := "N" + Chr(227) + "o"
	Otherwise
		cRet := AllTrim(cValToChar(cVal))
	EndCase

Return cRet

/*=================================================================
Info: Descricao da frequencia (C5_ZFREQ / C5_XFREQ)
Autor: Fernando Pessoa / Tecsistem - 30/07/2026
*==================================================================*/
Static Function VPIFreq(cVal)

	Local cRet := ""
	Local cKey := ""

	Default cVal := ""

	If ValType(cVal) == "L"
		Return cRet
	EndIf

	cKey := Upper(AllTrim(cValToChar(cVal)))

	If Empty(cKey) .Or. cKey $ ".T.|.F."
		Return cRet
	EndIf

	Do Case
	Case cKey == "P"
		cRet := "Pontual"
	Case cKey == "M"
		cRet := "Mensal"
	Case cKey == "B"
		cRet := "Bimestral"
	Case cKey == "T"
		cRet := "Trimestral"
	Case cKey == "S"
		cRet := "Semestral"
	Case cKey == "A"
		cRet := "Anual"
	Otherwise
		cRet := AllTrim(cValToChar(cVal))
	EndCase

Return cRet

/*=================================================================
Info: Le valor de campo do alias atual como texto, ignorando logico
Autor: Fernando Pessoa / Tecsistem - 30/07/2026
*==================================================================*/
Static Function VPIFldC(cAlias, cCampo)

	Local uRet  := ""
	Local nArea := Select()

	Default cAlias  := ""
	Default cCampo  := ""

	If Empty(cAlias) .Or. Empty(cCampo)
		Return ""
	EndIf

	If Select(cAlias) == 0 .Or. (cAlias)->(FieldPos(cCampo)) == 0
		Return ""
	EndIf

	BEGIN SEQUENCE
		DbSelectArea(cAlias)
		uRet := (cAlias)->&(cCampo)
	RECOVER
		uRet := ""
	END SEQUENCE

	If nArea > 0
		DbSelectArea(nArea)
	EndIf

	If ValType(uRet) == "L"
		Return ""
	EndIf

Return AllTrim(cValToChar(uRet))

/*=================================================================
Info: Descricao do tipo de pedido (C5_XTPPED)
Autor: Fernando Pessoa / Tecsistem - 30/07/2026
*==================================================================*/
Static Function VPITpPed(cVal)

	Local cRet := ""
	Local cKey := AllTrim(cValToChar(cVal))

	Default cVal := ""

	If Empty(cKey)
		Return cRet
	EndIf

	Do Case
	Case cKey == "1"
		cRet := "Pontual"
	Case cKey == "2"
		cRet := "Programado"
	Otherwise
		cRet := cKey
	EndCase

Return cRet

/*=================================================================
Info: Posicione seguro - nao derruba a rotina se campo/tabela falhar
*==================================================================*/
Static Function VPISafePo(cAlias, nOrd, cChave, cCampo)

	Local uRet := ""

	Default cAlias  := ""
	Default nOrd    := 1
	Default cChave  := ""
	Default cCampo  := ""

	If Empty(cAlias) .Or. Empty(cCampo)
		Return uRet
	EndIf

	BEGIN SEQUENCE
		uRet := Posicione(cAlias, nOrd, cChave, cCampo)
	RECOVER
		uRet := ""
	END SEQUENCE

Return uRet

/*=================================================================
Info: PO via C6_XVINSW1 -> SW1.W1_PO_NUM (regra informada)
*==================================================================*/
Static Function VPIGetPO(cSiNum, cProduto)

	Local cRet   := ""
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	Default cSiNum    := ""
	Default cProduto  := ""

	If Empty(cSiNum) .Or. Empty(cProduto)
		Return cRet
	EndIf

	BEGIN SEQUENCE

	cQuery := " SELECT TOP 1 W1_PO_NUM "
	cQuery += " FROM " + RetSqlName("SW1") + " SW1 "
	cQuery += " WHERE SW1.W1_FILIAL = '" + xFilial("SW1") + "' "
	cQuery += "   AND SW1.W1_SI_NUM = '" + cSiNum + "' "
	cQuery += "   AND SW1.W1_COD_I = '" + cProduto + "' "
	cQuery += "   AND SW1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .F., .T.)
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If !(cAlias)->(Eof())
		cRet := AllTrim((cAlias)->W1_PO_NUM)
	EndIf

	(cAlias)->(DbCloseArea())

	RECOVER
		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
		cRet := ""
	END SEQUENCE

Return cRet

/*=================================================================
Info: P.E. atualizada - CVEICR04: HAWB(SW7) -> W6_PRVENTR; senao W3_DT_ENTR
*==================================================================*/
Static Function VPIxDtEn(cProduto, cPONum)

	Local cRet   := ""
	Local cHawb  := ""
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	Default cProduto := ""
	Default cPONum   := ""

	If Empty(cProduto) .Or. Empty(cPONum)
		Return cRet
	EndIf

	cHawb := VPIxProc(cProduto, cPONum)

	If !Empty(cHawb)
		cRet := VPIW6PE(cHawb)
		If !Empty(cRet)
			Return cRet
		EndIf
	EndIf

	BEGIN SEQUENCE

	cQuery := " SELECT TOP 1 W3_DT_ENTR "
	cQuery += " FROM " + RetSqlName("SW3") + " SW3 "
	cQuery += " WHERE SW3.W3_FILIAL = '" + xFilial("SW3") + "' "
	cQuery += "   AND SW3.W3_PO_NUM = '" + cPONum + "' "
	cQuery += "   AND SW3.W3_COD_I = '" + cProduto + "' "
	cQuery += "   AND SW3.W3_CTCUSTO <> '' "
	cQuery += "   AND SW3.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .F., .T.)
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If !(cAlias)->(Eof())
		cRet := VPIDtFmt(VPIDtStr((cAlias)->W3_DT_ENTR))
	EndIf

	(cAlias)->(DbCloseArea())

	RECOVER
		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
		cRet := ""
	END SEQUENCE

Return cRet

/*=================================================================
Info: Previsao de entrega do processo (SW6.W6_PRVENTR via HAWB)
*==================================================================*/
Static Function VPIW6PE(cHawb)

	Local uDta := ""

	Default cHawb := ""

	If Empty(cHawb)
		Return ""
	EndIf

	BEGIN SEQUENCE
		uDta := Posicione("SW6", 1, xFilial("SW6") + AllTrim(cHawb), "W6_PRVENTR")
	RECOVER
		uDta := ""
	END SEQUENCE

	If Empty(uDta)
		Return ""
	EndIf

Return VPIDtFmt(VPIDtStr(uDta))

/*=================================================================
Info: Lead time da transportadora em dias uteis.
      CIF = ZZK_LEAD (chave C5_ZINFFRE)
      FOB = SA4.A4_XLEAD (transportadora C5_TRANSP)
      Mesma origem adotada por MT410TOK/xVldDtEntr e CVFATA13.
*==================================================================*/
Static Function VPILeadTr(cTipoFrete, cTransp, cZzkKey)

	Local nRet := 0
	Local cKey := ""

	Default cTipoFrete := ""
	Default cTransp    := ""
	Default cZzkKey    := ""

	BEGIN SEQUENCE
		If AllTrim(cTipoFrete) == "F"
			If !Empty(AllTrim(cTransp))
				nRet := VPIVal(VPISafePo("SA4", 1, xFilial("SA4") + AllTrim(cTransp), "A4_XLEAD"))
			EndIf
		ElseIf AllTrim(cTipoFrete) == "C"
			cKey := StrTran(AllTrim(cZzkKey), "|", "")
			If !Empty(cKey)
				nRet := VPIVal(VPISafePo("ZZK", 2, xFilial("ZZK") + cKey, "ZZK_LEAD"))
			EndIf
		EndIf
	RECOVER
		nRet := 0
	END SEQUENCE

Return nRet

/*=================================================================
Info: Marit/Aereo - mesma regra do U_PRZEAM() para C6_XPRZFOR virtual
*==================================================================*/
Static Function VPIPrzEam(cProduto)

	Local cRet  := ""
	Local cMart := ""
	Local cProc := ""
	Local cLoj  := ""
	Local cKey  := ""

	Default cProduto := ""

	If Empty(cProduto)
		Return cRet
	EndIf

	cKey := PadR(AllTrim(cProduto), TamSx3("B1_COD")[1])

	BEGIN SEQUENCE
		cMart := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cKey, "B1_CRVMART"))
		cProc := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cKey, "B1_PROC"))
		cLoj  := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cKey, "B1_LOJPROC"))

		If cMart == "S"
			cRet := "Maritimo " + cValToChar(Posicione("SA2", 1, xFilial("SA2") + cProc + cLoj, "A2_CRVPZM")) + " Dias"
		ElseIf cMart == "N"
			cRet := "Aereo " + cValToChar(Posicione("SA2", 1, xFilial("SA2") + cProc + cLoj, "A2_CRVPZO")) + " Dias"
		EndIf
	RECOVER
		cRet := ""
	END SEQUENCE

Return cRet

/*=================================================================
Info: Processo Import. - mesma regra do CVEICR04 (WK_HAWB / W7_HAWB)
*==================================================================*/
Static Function VPIxProc(cProduto, cPONum)

	Local cRet   := ""
	Local cQuery := ""
	Local cAlias := GetNextAlias()

	Default cProduto := ""
	Default cPONum   := ""

	If Empty(cProduto) .Or. Empty(cPONum)
		Return cRet
	EndIf

	BEGIN SEQUENCE

	cQuery := " SELECT TOP 1 W7_HAWB "
	cQuery += " FROM " + RetSqlName("SW7") + " SW7 "
	cQuery += " WHERE SW7.W7_FILIAL = '" + xFilial("SW7") + "' "
	cQuery += "   AND SW7.W7_PO_NUM = '" + cPONum + "' "
	cQuery += "   AND SW7.W7_COD_I = '" + cProduto + "' "
	cQuery += "   AND SW7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY W7_HAWB DESC "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(, , cQuery), cAlias, .F., .T.)
	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If !(cAlias)->(Eof())
		cRet := AllTrim((cAlias)->W7_HAWB)
	EndIf

	(cAlias)->(DbCloseArea())

	RECOVER
		If Select(cAlias) > 0
			(cAlias)->(DbCloseArea())
		EndIf
		cRet := ""
	END SEQUENCE

Return cRet

