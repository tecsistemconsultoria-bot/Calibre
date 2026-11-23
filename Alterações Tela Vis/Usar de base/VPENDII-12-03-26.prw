#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include "Protheus.ch"
#Include "TOPCONN.CH"
#include "rwmake.ch"

/***********************************************************************
Autor: Rafael
Data: 13/12/2010
Consultoria:  
Uso: Calibre
Tipo: Atualiza็๕es
Rotina: Faturamento
Fun็ใo: VPendII
Info: Vis. Pend II
************************************************************************/
User Function VPendII(_Orig)

	Local _aArea   := GetArea()
	Local xESTICM  := GetMV("MV_ESTICM")
	Local lCalcIPI := .F.

	Static oDlg
	Static oLbx
	Static oSayNPed
	Static oSayEmiss
	Static oSayDesCli
	Static oSayDesTran
	Static oSayDesPgt
	Static oSayFatur
	Static oSayTpLib
	Static oSayTPFrete
	Static oSayMenNota
	Static oSayVinc
	Static oSayPdVin
	Static oMemo
	Static oSayVLTOT
	Private cNPed
	Private aLbx := {}

	Private _NumPed
	Private cDesCli
	Private cDesTran
	Private cDesPgt
	Private cFatur
	Private cTpLib
	Private cTPFrete
	Private cMenNota
	Private cMenNII
	Private cVinc
	Private cFrete
	Private nVLTOT := 0
	Private _TipPV
	Private _vVlDEsc :=   0
	Private _actxt:=''
	
	If _Orig = "RN" .or. _Orig = "RNA"
		_TipPV	 := Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_TIPO")
		_CodTran := Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_TRANSP")
		_CodCP	 := Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_CONDPAG")
		_vVlDEsc := Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_DESCONT")
		//	MSGBOX(StrZero(_vVlDEsc),"ZB4","STOP")
		_NumPed	 := ZB4->ZB4_NUMC5
		If !(_TipPV $ "D|B")
			cDesCli  := Posicione("SA1",1,xFilial("SA1")+ZB4->ZB4_CLIENT,"A1_NOME")
		Else
			cDesCli  := Posicione("SA2",1,xFilial("SA2")+ZB4->ZB4_CLIENT,"A2_NOME")
		EndIf
		cDtEmis  := DtoS(ZB4->ZB4_EMISSA)
		cEmiss   := SubStr(cDtEmis,7,2)+"/"+SubStr(cDtEmis,5,2)+"/"+SubStr(cDtEmis,1,4)
		cDesTran := Posicione("SA4",1,xFilial("SA4")+_CodTran,"A4_NREDUZ")
		cDesPgt  := Posicione("SE4",1,XFILIAL("SE4")+_CodCP,"E4_DESCRI")
		cFatur   := IIF(AllTrim(Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_XFATURA")) =='N','Nใo','Sim')
		cTpLib	 := IIF(AllTrim(Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_TIPLIB"))=='1','Libera Por Item','Libera por Pedido')
		cVinc    := Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_XPEDVIN")
		cFrete	 := Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_TPFRETE")
		If !(_TipPV $ "D|B")
			cMenNota := SUBSTR(Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_MENNOTA"),1,40)
			cMenNII	 := SUBSTR(Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_MENNOTA"),41,40)
		Else
			cMenNota := SUBSTR(Posicione("SC5",1,xFilial("SC5")+ZB4->ZB4_NUMC5,"C5_MENNOTA"),1,100)
		EndIf
		cVendInt := SUBSTR(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"SA3->A3_NOME"),1,30)
		cVendExt := SUBSTR(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"SA3->A3_NOME"),1,30)
		cGerent  := SUBSTR(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"SA3->A3_NOME"),1,30)

	Else
		_NumPed	:= SC5->C5_NUM
		_TipPV	 := Posicione("SC5",1,xFilial("SC5")+_NumPed,"C5_TIPO")
		If !(_TipPV $ "D|B")
			cDesCli  := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE,"A1_NOME")
		Else
			cDesCli  := Posicione("SA2",1,xFilial("SA2")+SC5->C5_CLIENTE,"A2_NOME")
		EndIf
		cDtEmis  := DtoS(SC5->C5_EMISSAO)
		cEmiss   := SubStr(cDtEmis,7,2)+"/"+SubStr(cDtEmis,5,2)+"/"+SubStr(cDtEmis,1,4)
		cDesTran := Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NREDUZ")
		cDesPgt  := Posicione("SE4",1,XFILIAL("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")
		cFatur   := IIF(AllTrim(SC5->C5_XFATURA)=='N','Nใo','Sim')
		cTpLib	 := IIF(AllTrim(SC5->C5_TIPLIB)=='1','Libera Por Item','Libera por Pedido')
		cVinc    := SC5->C5_XPEDVIN
		cFrete	 := AllTrim(SC5->C5_TPFRETE)
		If !(_TipPV $ "D|B")
			cMenNota := SUBSTR(SC5->C5_MENNOTA,1,40)
			cMenNII	 := SUBSTR(SC5->C5_MENNOTA,41,40)
		Else
			cMenNota := SUBSTR(SC5->C5_MENNOTA,1,100)
		EndiF

		cVendInt := SUBSTR(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"SA3->A3_NOME"),1,30)
		cVendExt := SUBSTR(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND2,"SA3->A3_NOME"),1,30)
		cGerent  := SUBSTR(Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND3,"SA3->A3_NOME"),1,30)
		_vVlDEsc := SC5->C5_DESCONT
		//	MSGBOX(StrZero(_vVlDEsc),"SC5","STOP")
	EndIf
	teste := " "
	aLbx := GLbxII(_Orig)
	If Empty(aLbx)

		MsgInfo("O pedido "+_NumPed+", nใo possui itens a liberar. O mesmo jแ pode ser faturado.",;
			"MA410MNU.PRW - CARVALHAES")
		Return Nil
	EndIf

	cNPed    := AllTrim(_NumPed)

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

//If _Orig = "RNA"
	_VlFret := 0

	_VlFret	:=	Posicione("SC5",1,xFilial("SC5")+_NumPed,"C5_FRETE")
	_vVlDEsc := Posicione("SC5",1,xFilial("SC5")+_NumPed,"C5_DESCONT")
	_actxt:=SC5->C5_CRVOBS
	nVlTotPV := 0
	IIF(Select("QRYTOT")!= 0, QRYTOT->(DbCLoseArea()), )
	cQRYTOT := " SELECT SUM(C6_VALOR) AS VLTOTAL"
	cQRYTOT += " FROM " + RetSqlName("SC6") + " SC6 "
	cQRYTOT += " WHERE SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cQRYTOT += " 		AND SC6.D_E_L_E_T_ <> '*' "
	If _Orig = "RNA"
		cQRYTOT += "       AND SC6.C6_NUM = '"+ZB4->ZB4_NUMC5+"' "
	Else
		cQRYTOT += "       AND SC6.C6_NUM = '"+_NumPed+"' "
	EndIf
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
	If _Orig = "RNA"
		cQRYTOT += "       AND SC6.C6_NUM = '"+ZB4->ZB4_NUMC5+"' "
	Else
		cQRYTOT += "       AND SC6.C6_NUM = '"+_NumPed+"' "
	EndIf
	cQRYTOT += "       AND SC6.C6_BLQ <> 'R' "
	cQRYTOT += "       AND SC6.C6_TES = SF4.F4_CODIGO "
	cQRYTOT := ChangeQuery(cQRYTOT)
	TcQuery cQRYTOT New Alias "QRYTOT"
	QRYTOT->(DbGoTop())
	nVLTOT := 0
	While !QRYTOT->(Eof())
		nVLTOT := nVLTOT + QRYTOT->VLTOTAL
		If _VlFret > 0
			_VlFreItem	:= ( (_VlFret*QRYTOT->VLTOTAL) /   nVlTotPV   )
			If QRYTOT->ALIQIPI > 0      //O produto tem IPI   e Frete
				nVLTOT   := nVLTOT + QRYTOT->VLIPI + _VlFreItem + (_VlFreItem*(QRYTOT->ALIQIPI/100))
				lCalcIPI := .T.
			Else  				// O produto nao tem IPI mais tem frete
				nVLTOT := nVLTOT + _VlFreItem
			EndIf
		Else //Pedido nao tem Frete
			nVLTOT   := nVLTOT + QRYTOT->VLIPI

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
			dbSeek(xFilial("SC6")+_NumPed+C6_ITEM)
			If Found()
				// Calculo ST e Outros Impostos
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
				_nAliqIcm        :=        MaFisRet(1,"IT_ALIQICM")
				_nValIcm                     := MaFisRet(1,"IT_VALICM" )
				_nBaseIcm       := MaFisRet(1,"IT_BASEICM")
				_nValIpi                      := MaFisRet(1,"IT_VALIPI" )
				_nBaseIpi        := MaFisRet(1,"IT_BASEICM")
				_nValMerc       := MaFisRet(1,"IT_VALMERC")
				_nValSol                      := MaFisRet(1,"IT_VALSOL" )

				_nValSol:=round(( _nValMerc+_nValIpi) *(1+(QRYTOT->PERST/100)),2)
				_xxnPerIcm:= Val(Subs(xESTICM,AT(SA1->A1_EST,xESTICM)+2,2)) //+ 2

				_nValSol:=ROUND(((_nValSol*_xxnPerIcm)/100)-_nValIcm,2)

				nVLTOT := nVLTOT  	+_nValSol

				lCalcIPI := .T.

				MaFisEnd()
				MaFisRestore()

			Endif
		Endif

		dbSelectArea("QRYTOT")
		QRYTOT->(dbSkip())
	End

	teset :=  ""
	//	MSgBOX(STRZERO(round(QRYTOT->VLTOTAL,2),5,2)+ " =====" + STRZERO (_vVlDEsc,5,2))
	If _vVlDEsc > 0
		nVLTOT := ROUND(nVLTOT,2) - _vVlDEsc
	EndIf
	QRYTOT->(DbCloseArea())

//EndIf 

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

	//Cแlculo do IPI do Pedido de Vendas - Vinicius N. de Oliveira - 21/07/2025
	If !lCalcIPI
		nVLTOT := nVLTOT + xIPI()
	Endif 
	// --- 

	DEFINE MSDIALOG oDlg TITLE "Visualiza Pendentes" FROM 000, 000  TO 550, 1350 COLORS 0, 16777215 PIXEL

	@ 008, 012 SAY "Pedido :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	If !(_TipPV $ "D|B")
		@ 018, 012 SAY "Cliente:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
	Else
		@ 018, 012 SAY "Fornedor:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
	EndIf
	@ 008, 176 SAY "Transportadora:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 176 SAY "Pagamento:" SIZE 032, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 012 SAY "Obs. NF: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	If !(_TipPV $ "D|B")
		@ 028, 176 SAY "Vend.Int.: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 028, 310 SAY "Vend.Ex/Rep.: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 028, 500 SAY "Ger./Coord.: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	EndIf
	@ 008, 310 SAY "Frete: " SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 400 SAY "Tp.Liber.: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 310 SAY "Fatura? " SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	//If _Orig = "RNA"
	@ 018, 500 SAY "VlTot.c/ipi+ST+frete: " SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	//EndIf
	If !empty(cVinc)
		@ 018, 400 SAY "Vinculo:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 028, 400 SAY "Ped.Vinc:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	EndIf

	@ 008, 034 SAY oSayNPed VAR cNPed SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 034 SAY oSayDesCli VAR cDesCli SIZE 139, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 218 SAY oSayDesTran VAR cDesTran SIZE 135, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 218 SAY oSayDesPgt VAR cDesPgt SIZE 134, 007 OF oDlg COLORS 0, 16777215 PIXEL
	If !(_TipPV $ "D|B")
		@ 028, 042 SAY oSayMenNota VAR cMenNota SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 035, 042 SAY oSayMenNII VAR cMenNII SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
	Else
		@ 028, 042 SAY oSayMenNota VAR cMenNota SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
	EndIf

	If !(_TipPV $ "D|B")
		@ 028, 218 SAY oSayVendInt VAR cVendInt SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 028, 345 SAY oSayVendExt VAR cVendExt SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 028, 560 SAY oSayGerent VAR cGerent SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	EndIf
	@ 008, 330 SAY oSayTPFrete VAR cTPFrete SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 442 SAY oSayTpLib VAR cTpLib SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 330 SAY oSayFatur VAR cFatur SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
	//If _Orig = "RNA"
	@ 018, 560 SAY oSayVLTOT VAR nVLTOT SIZE 140, 007 PICTURE "@E 9,999,999.99" OF oDlg COLORS 0, 16777215 PIXEL
	//EndIf

	If !empty(cVinc)
		@ 018, 442 SAY oSayVinc VAR cVinc SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 028, 442 SAY oSayPdVin VAR cPedVinc SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
	EndIf

	@ 042,012 SAY "Obs.Interna:" SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 042,045 GET oMemo  VAR _actxt MEMO SIZE 300,030 OF oDlg PIXEL


	If _Orig = "RNA"
		@ 075, 005 LISTBOX oLbx VAR cLbx FIELDS HEADER OemtoAnsi("Blq"),;
			OemtoAnsi("Item"),;
			Padr(OemtoAnsi("Dt.Emis"),8),;
			Padr(OemtoAnsi("TES"),06),;
			Padr(OemtoAnsi("Cod.Produto"),15),;
			OemtoAnsi("Desc. Produto"),;
			Padr(OemtoAnsi("Dt p/Fatur"),8),;
			Padr(OemtoAnsi("Vendido"),7),;
			Padr(OemtoAnsi("Prc Unit"),7),;
			Padr(OemtoAnsi("Prc.Pad"),7),;
			Padr(OemtoAnsi("Total"),7),;
			Padr(OemtoAnsi("%Des.Real"),10),;
			Padr(OemtoAnsi("%Des.Padrao"),10),;
			Padr(OemtoAnsi("Prc Tabela"),08),;
			Padr(OemtoAnsi("Carga"),08),;   //dyego 23/09/14
		Padr(OemtoAnsi("Data"),08),;   //dyego 23/09/14
		Padr(OemtoAnsi("Hora"),08),;   //dyego 23/09/14
		SIZE 670, 180 OF oDlg COLORS 0, 16777215 ON DBLCLICK SugEstorno() PIXEL
	Else
		@ 075, 005 LISTBOX oLbx VAR cLbx FIELDS HEADER OemtoAnsi("Item"),;
			Padr(OemtoAnsi("Dt.Emis"),8),;
			Padr(OemtoAnsi("Cod.Produto"),15),;
			OemtoAnsi("Desc. Produto"),;
			Padr(OemtoAnsi("Dt p/Fatur"),8),;
			Padr(OemtoAnsi("Vendido"),7),;
			Padr(OemtoAnsi("Saldo Est."),7),;
			Padr(OemtoAnsi("Entregue"),8),;
			Padr(OemtoAnsi("Reservar"),8),;
			Padr(OemtoAnsi("Reservado"),8),;
			Padr(OemtoAnsi("TES"),4),;
			Padr(OemtoAnsi("Status"),11),;
			Padr(OemtoAnsi("Carga"),08),;   //dyego 23/09/14
		Padr(OemtoAnsi("Data"),08),;   //dyego 23/09/14
		Padr(OemtoAnsi("Hora"),08),;   //dyego 23/09/14
		SIZE 670, 180 OF oDlg COLORS 0, 16777215 ON DBLCLICK SugEstorno() PIXEL
	EndIf
	@ 256, 430 BUTTON oBtCancela PROMPT "Cancelar" SIZE 051, 012 OF oDlg ACTION oDlg:End() PIXEL

	oLbx:SetArray(aLbx)
	If _Orig = "RNA"
		oLbx:bLine:={||{aLbx[oLbx:nAt,1],;
			aLbx[oLbx:nAt,2],;
			aLbx[oLbx:nAt,3],;
			aLbx[oLbx:nAt,4],;
			aLbx[oLbx:nAt,5],;
			aLbx[oLbx:nAt,6],;
			aLbx[oLbx:nAt,7],;
			aLbx[oLbx:nAt,8],;
			aLbx[oLbx:nAt,9],;
			aLbx[oLbx:nAt,10],;
			aLbx[oLbx:nAt,11],;
			aLbx[oLbx:nAt,12],;
			aLbx[oLbx:nAt,13],;
			aLbx[oLbx:nAt,14],;
			aLbx[oLbx:nAt,15],;
			aLbx[oLbx:nAt,16],;
			aLbx[oLbx:nAt,17]}}
	Else
		oLbx:bLine:={||{alltrim(aLbx[oLbx:nAt,1]),;
			alltrim(aLbx[oLbx:nAt,2]),;
			alltrim(aLbx[oLbx:nAt,3]),;
			alltrim(aLbx[oLbx:nAt,4]),;
			alltrim(aLbx[oLbx:nAt,5]),;
			aLbx[oLbx:nAt,6],;
			aLbx[oLbx:nAt,7],;
			aLbx[oLbx:nAt,8],;
			aLbx[oLbx:nAt,9],;
			aLbx[oLbx:nAt,10],;
			aLbx[oLbx:nAt,11],;
			aLbx[oLbx:nAt,12],;
			aLbx[oLbx:nAt,13],;
			aLbx[oLbx:nAt,14],;
			aLbx[oLbx:nAt,15]}}
	EndIf

	ACTIVATE MSDIALOG oDlg

	RestArea(_aArea)

Return Nil

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณ GetaLbx  บAutor ณ Rafael-www.chaus.com.br ณ Data ณ 13/12/10 บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDescricao ณ Fun็ใo responsแvel por buscar os ํtens do pedidos que aindaบฑฑ
	ฑฑบ          ณ faltam ser liberados.                                      บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ Faturamento/OMS                                            บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

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
	teste:=""
	While QRYSC6->(!EoF())
		_SaldoEst := GetSaldo(QRYSC6->PRODUTO,QRYSC6->ARMAZEM)
		_Bloqueado := IIF( empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. !empty(SC9->C9_CARGA),0, QRYSC6->QTDVEN-(QRYSC6->QTDENT+QRYSC6->LIBERADO))
		_DtEntreg := SubStr(QRYSC6->ENTREGA,7,2)+"/"+SubStr(QRYSC6->ENTREGA,5,2)+"/"+SubStr(QRYSC6->ENTREGA,1,4)
		_PrzoEntr := StoD(QRYSC6->DTENTREGA)
		_cPrzoEntr := SubStr(DtoS(_PrzoEntr),7,2)+"/"+SubStr(DtoS(_PrzoEntr),5,2)+"/"+SubStr(DtoS(_PrzoEntr),1,4)
		If !empty(QRYSC6->C6_NOTA)
			_QStatus  := "7-Faturado"
		Else
			_QStatus  := GetStatus(QRYSC6->PEDIDO,QRYSC6->ITEM)
		EndIf

		AADD(aRetorno,{QRYSC6->ITEM,QRYSC6->PRODUTO,SubStr(QRYSC6->DESCPROD,1,30),_DtEntreg,_cPrzoEntr,QRYSC6->QTDVEN,;
			_SaldoEst,QRYSC6->QTDENT,_Bloqueado,QRYSC6->LIBERADO,_QStatus})

		QRYSC6->(DbSkip())
	EndDo

	QRYSC6->(DbCloseArea())

Return(aRetorno)

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณ SugEstorno บAutor ณRafael-www.chaus.com.br ณData ณ13/12/10 บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDescricao ณ Fun็ใo responsแvel por gerar uma tela que mostra todos os  บฑฑ
	ฑฑบ          ณ pedidos possํveis de estorno para que o primeiro pedido    บฑฑ
	ฑฑบ          ณ possa ser atendido completamente.                          บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ Faturamento/OMS                                            บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SugEstorno()

	Local cCItem
	Local cFLib
	Local cCProd
	Local cDescProd
	Local aLbx1 := {}

	Static oDlgSugEst
	Static oLbx1
	Static oSayCIte
	Static oSayFLib
	Static oSayLCProd
	Static oSaylDesProd
	Static oSayDtEntre
	Static oSayNPed


	cCItem    := aLbx[oLbx:nAt,1]
	cCProd    := aLbx[oLbx:nAt,3]
	cDescProd := aLbx[oLbx:nAt,4]
	cFLib     := aLbx[oLbx:nAt,5]
	cDtEntre  := aLbx[oLbx:nAt,6]

	aLbx1 :=  GetaLbx1(cCProd,cNPed)

	If Empty(aLbx1)
		MsgInfo("Nใo existe pedidos a serem sugeridos para estorno.","MA410MNU.PRW - CARVALHAES")
		Return Nil
	EndIf

	DEFINE MSDIALOG oDlgSugEst TITLE "Sugere Estorno" FROM 000, 000  TO 550, 1250 COLORS 0, 16777215 PIXEL

	@ 008, 014 SAY "Pedido: " SIZE 025, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 008, 125 SAY "Item:" SIZE 015, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 020, 014 SAY "Cod. Produto:" SIZE 034, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 020, 125 SAY "Desc. Produto:" SIZE 041, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 008, 204 SAY "Falta a Liberar:" SIZE 039, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 032, 014 SAY "Data p/ Faturar:" SIZE 039, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 008, 037 SAY oSayNPed VAR cNPed SIZE 064, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 008, 144 SAY oSayCIte VAR cCItem SIZE 025, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 008, 243 SAY oSayFLib VAR cFLib  SIZE 028, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 020, 053 SAY oSayLCProd VAR cCProd SIZE 068, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 020, 166 SAY oSaylDesProd VAR cDescProd SIZE 118, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 032, 053 SAY oSayDtEntre VAR cDtEntre SIZE 118, 007 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 046, 007 LISTBOX oLbx1 VAR cLbx1 FIELDS HEADER Padr(OemtoAnsi("Pedido"),8),;
		Padr(OemtoAnsi("Cliente"),20),;
		Padr(OemtoAnsi("Vendedor"),10),;
		Padr(OemtoAnsi("Emissao"),8),;
		Padr(OemtoAnsi("Dt p/Fatur"),10),;
		Padr(OemtoAnsi("Vendido"),7),;
		Padr(OemtoAnsi("Entregue"),8),;
		Padr(OemtoAnsi("Reservado"),9),;
		Padr(OemtoAnsi("Lote"),4),;
		Padr(OemtoAnsi("Reservar"),8),;
		SIZE 600, 192 OF oDlgSugEst COLORS 0, 16777215 PIXEL
	@ 256, 350 BUTTON oBtCancela PROMPT "Cancelar" SIZE 051, 012 OF oDlgSugEst ACTION oDlgSugEst:End() PIXEL

	oLbx1:SetArray(aLbx1)
	oLbx1:bLine:={||{aLbx1[oLbx1:nAt,1],;
		aLbx1[oLbx1:nAt,2],;
		aLbx1[oLbx1:nAt,3],;
		aLbx1[oLbx1:nAt,4],;
		aLbx1[oLbx1:nAt,5],;
		aLbx1[oLbx1:nAt,6],;
		aLbx1[oLbx1:nAt,7],;
		aLbx1[oLbx1:nAt,8],;
		aLbx1[oLbx1:nAt,9],;
		aLbx1[oLbx1:nAt,10]}}


	ACTIVATE MSDIALOG oDlgSugEst

Return Nil

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณ GetaLbx1 บAutor ณ Rafael-www.chaus.com.br ณ Data ณ13/12/10 บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDescricao ณ Fun็ใo responsแvel por buscar os ํtens dos pedidos que     บฑฑ
	ฑฑบ          ณ podem ser estornados.                                      บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณ Faturamento/OMS                                            บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

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
	cQryPedEst += "			         AND SC9.C9_CARGA = ' ' ) AS BLOQ  "
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
	cQryPedEst += " AND C9_CARGA = '' "
	cQryPedEst += " AND F4.F4_ESTOQUE = 'S' "
	cQryPedEst += " AND C6_QTDVEN-(C9_QTDLIB+C6_QTDENT)>=0 "
	cQryPedEst += " ORDER BY C6.C6_XEMISSA "

	cQryPedEst := ChangeQuery(cQryPedEst)
	TcQuery cQryPedEst New Alias "QRYPEDEST"

	TESTE:=""

	QRYPEDEST->(DbGoTop())

	While QRYPEDEST->(!EoF())
		dEmiss     := DtoS(Posicione("SC5",1,xFilial("SC5")+QRYPEDEST->PEDIDO,"C5_EMISSAO"))
		_cEmiss    := Substr(QRYPEDEST->EMISSAO,7,2)+"/"+Substr(QRYPEDEST->EMISSAO,5,2)+"/"+Substr(QRYPEDEST->EMISSAO,1,4)
		_cDEntreg  := Substr(QRYPEDEST->ENTREGA,7,2)+"/"+Substr(QRYPEDEST->ENTREGA,5,2)+"/"+Substr(QRYPEDEST->ENTREGA,1,4)
		_cCliente  := Posicione("SA1",1,xFilial("SA1")+QRYPEDEST->CLIENTE,"A1_NOME")
		_cVendedor := Posicione("SA3",1,xFilial("SA3")+QRYPEDEST->VENDEDOR,"A3_NOME")
		AADD(aRetorno,{QRYPEDEST->PEDIDO,_cCliente,_cVendedor,_cEmiss,_cDEntreg,QRYPEDEST->QTDVEN,QRYPEDEST->QTDENT,;
			QRYPEDEST->QTDLIB,QRYPEDEST->LOTE,QRYPEDEST->BLOQ})
		QRYPEDEST->(DbSkip())
	EndDo

	QRYPEDEST->(DbCloseArea())

Return (aRetorno)
//----------------------------------------------
Static Function GetSaldo(_Prod,_Local)
	Local cRetorno:= 0
	Local cQRYSLD := ""
	Local lQry


	DbSelectArea("SB2")
	DbSetOrder(1)        //B2_FILIA+B2_COD+B2_LOCAL
	If DBSeek(xFilial("SB2")+_Prod+_Local)
		cRetorno:= SaldoSb2(,.F.)
	EndIf

Return cRetorno

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
		ElseIf empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. empty(SC9->C9_CARGA)
			_Stat := "5-Aguardando Carga"
		ElseIf empty(SC9->C9_BLCRED) .and. empty(SC9->C9_BLEST) .and. !empty(SC9->C9_CARGA)
			_Stat := "6-Carregado Aguardando Faturamento"
		EndIf
	EndIf


Return(_Stat)
Static Function GLbxII(_Orig)

	Local aRetorno 		:= {}
	Local cQrySC6 		:= ""
	Local _SaldoEst 	:= 0
	Local _Bloqueado 	:= 0
	Local aSC9			:= {}
	Local aVlPFEX		:= {}
	Local aVlTra		:= {}

	Local xRESEST	:= GetMV("MV_RESEST")
	Local xXPDEMAX	:= GetMV("MV_XPDEMAX")

	Local aLastQuery
	Local cLike
	Local cQuery
	Local cError
	Local cTCSqlError

	Local cAlias
	Local bError
	Local bErrorBlock

	Local oError

	Local cNewStatus := ""


	bError      := { |e| oError := e , BREAK(e) }
	bErrorBlock    := ErrorBlock( bError )



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
		STAPV,  
		C9_CARGA, 
	     DAK_DATA , DAK_HORA ,
		C9_BLCRED, 
		C9_BLEST,  
		BLQDESC , BLQTRAN,BLQFRT,BLQPAG, BLQDTV   , 
		BLQREGCOM,
		NovoStatus  
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
		SC9.C9_BLQDESC AS BLQDESC , SC9.C9_BLQTRAN AS BLQTRAN, SC9.C9_BLQFRT AS BLQFRT, SC9.C9_BLQPAG AS BLQPAG, SC9.C9_BLQDTV AS BLQDTV,   

		CASE WHEN SC6.C6_NOTA <> ' '  OR (C5_NOTA <>' ' AND C5_LIBEROK = 'S')  
				THEN 11 //'11 -  Faturado'   
				ELSE CASE WHEN C9_FILIAL IS NULL   
						   THEN 1 //'01 - Em carteira '      
						   ELSE CASE WHEN (  SC9.C9_BLEST = ' ' and  SC9.C9_BLCRED <> ' ') 
								     THEN 5 // '05 - Reservado,em anali.de cred'      
								     ELSE CASE WHEN (SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST <> ' ' ) or (SC9.C9_BLCRED <> ' ' AND SC9.C9_BLEST <> ' ' )  
											   THEN 7 // '07 - Aguardando estoque '      
  											   ELSE CASE WHEN SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' AND SC9.C9_CARGA = ' '    
													THEN 9 //'09 - Aguardando carga'   
													ELSE CASE WHEN SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' ' AND SC9.C9_CARGA <> ' '     
															   THEN 10 //'10 - Em separacao '  
															   ELSE 0 //' ' 
														 END 
										  			END  
											END 
								 END 
					  END 
		END  AS STAPV, 
		
		  
		SC9.C9_CARGA,     			 
		
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
        DAK_DATA , DAK_HORA ,
		dbo.u_StatusPedItem(SC6.C6_FILIAL, SC6.C6_NUM, SC6.C6_ITEM) NovoStatus
     
FROM %table:SC5% SC5 
			INNER JOIN %table:SC6% SC6 ON SC6.C6_FILIAL =  %xfilial:SC6% AND SC5.C5_NUM = SC6.C6_NUM AND SC6.C6_BLQ<>'R ' AND SC6.%notDel%   
			INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL= %xfilial:SB1%  AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.%notDel%    
			LEFT JOIN  %table:SC9% SC9 ON SC9.C9_FILIAL =  %xfilial:SC9% AND SC5.C5_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM AND SC6.C6_PRODUTO = SC9.C9_PRODUTO AND SC9.%notDel%    
			LEFT JOIN  %table:DAK% DAK ON DAK.DAK_FILIAL =  %xfilial:DAK% AND C9_CARGA = DAK.DAK_COD AND DAK.%notDel%  
WHERE SC5.%notDel%  
		AND SC5.C5_FILIAL =  %xfilial:SC5%
		AND SC5.C5_NUM = %exp:_NumPed%  ) AA 

GROUP BY PEDIDO,XPEDVIN,TIPLIB,XFATURA,EMISSAO,TES,DLIBEST,CLIENTE,LOJACLI,CLIENT,LOJAENT,TABELA,TRANSP,CONDPAG,PRODUTO,DESCPROD,ARMAZEM,ITEM,BLQ,ENTREGA,PRZENT,DTENTREGA,C6_NOTA,C6_SERIE,STAPV, C9_CARGA,	C9_BLCRED, C9_BLEST,BLQDESC,BLQTRAN,BLQFRT,BLQPAG,BLQDTV , BLQREGCOM, DAK_DATA , DAK_HORA , NovoStatus
ORDER BY ITEM , PRODUTO

	ENDSQL

//aLastQuery := GetLastQuery()    chaus
//cLastQuery := aLastQuery[2]
	MemoWrite("C:\temp\MA410MNU.txt",getlastquery()[2])

	teste := " "
	While  cAliasSC6->(!EoF())
		teste := " "
		_SaldoEst := GetSaldo(cAliasSC6->PRODUTO,cAliasSC6->ARMAZEM)
		cNewStatus := Alltrim(cAliasSC6->(NovoStatus))
		teste := " "
		_DtEntreg := SubStr(cAliasSC6->ENTREGA,7,2)+"/"+SubStr(cAliasSC6->ENTREGA,5,2)+"/"+SubStr(cAliasSC6->ENTREGA,1,4)
		_PrzoEntr := StoD(cAliasSC6->DTENTREGA)
		_cPrzoEntr := SubStr(DtoS(_PrzoEntr),7,2)+"/"+SubStr(DtoS(_PrzoEntr),5,2)+"/"+SubStr(DtoS(_PrzoEntr),1,4)

		//_QStatus  := cAliasSC6->STAPV

		_QStatus  := ""

		Do Case
		Case cAliasSC6->STAPV == 1
			_QStatus:= '01 - Em carteira '
		Case cAliasSC6->STAPV == 5
			_QStatus:= '05 - Reservado,em anali.de cred'
		Case cAliasSC6->STAPV == 7
			_QStatus:= '07 - Aguardando estoque'
		Case cAliasSC6->STAPV == 9
			_QStatus:= '09 - Aguardando carga'
		Case cAliasSC6->STAPV == 10
			_QStatus:= '10 - Em separacao'
		Case cAliasSC6->STAPV == 11
			_QStatus := '11 -  Faturado'
		Case cAliasSC6->STAPV == 0
			_QStatus:= ' '
		EndCase
//MGV	     
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


		teste := " "

		If SubStr(_QStatus,1,2) = '11'
			_QStatus  := "11 - Faturado, NF: "+cAliasSC6->C6_NOTA
		ElseIF SubStr(_QStatus,1,2) = '01'
			_QStatus  := "01 - Em carteira"
		ElseIF SubStr(_QStatus,1,2) = "05"
			If cAliasSC6->XFATURA = "N"
				_QStatus  := "05.A- Aguar.FAT SIM, reservado,em anali.de cred"
			Else
				_QStatus  := "05 - Reservado,em anali.de cred"
			EndIf
		ElseIf SubStr(_QStatus,1,2) = "07"   //MGV
			_QStatus  := "07 - Aguardando  estoque
		ElseIf SubStr(_QStatus,1,2) = "09"
			_QStatus  := "09 - Aguardando carga"
		ElseIf SubStr(_QStatus,1,2) = "10"
			_QStatus  := "10 - Em separacao"
		EndIf


		teste := " "



		If cAliasSC6->TIPLIB = "2" .and. ;//Liberacao por pedido
			PVTdLib(cAliasSC6->PEDIDO, cAliasSC6->ITEM) .AND. SubStr(_QStatus,1,2) <>'01' .AND.;
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
			//_Bloqueado := 0
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
			teste := ""
			If Substr(Ltrim(Rtrim(_QStatus)),1,2) = "06"  .and. !(xRESEST)
				_Bloqueado := cAliasSC6->QTDVEN-(cAliasSC6->QTDENT)
			EndIf

		EndIf


		//POSICIONE("SZI",1,XFILIAL("SZI")+SF2->F2_CRVROM,"ZI_DATA")
		_CRVROM := Posicione('SF2',2,XFILIAL('SF2')+cAliasSC6->CLIENTE+cAliasSC6->LOJACLI+cAliasSC6->C6_NOTA+cAliasSC6->C6_SERIE ,'F2_CRVROM')
		dDtaCol := DtoS(POSICIONE("SZI",1,XFILIAL("SZI")+_CRVROM,"ZI_DATA"))
		If Substr(Ltrim(Rtrim(_QStatus)),1,2) = "11" .AND. !empty(dDtaCol)
			_QStatus  := '12 - Coletado em '+Substr(dDtaCol,7,2)+"/"+Substr(dDtaCol,5,2)+"/"+Substr(dDtaCol,1,4)+" , NF:"+cAliasSC6->C6_NOTA
		EndIf

		_C5NOTA := ltrim(rtrim(POSICIONE("SC5",1,XFILIAL("SC5")+cAliasSC6->PEDIDO,"C5_NOTA")))

		If cAliasSC6->BLQ = "R"
			_QStatus  := '13 - Item do Pedido cancelado/Encerrado'
			_Bloqueado:= 0

		Else
			iF SubStr(_QStatus,1,2) <> "10"
				If  SubStr(_QStatus,1,2) <> '11'
				/*
				If POSICIONE("SB1",1,XFILIAL("SB1")+cAliasSC6->PRODUTO,"B1_CRVPF") =='S' .AND. cAliasSC6->BLQ <> "R"    
					aVlPFEX	:= U_VlDPFEX(cAliasSC6->CLIENTE,cAliasSC6->LOJACLI,cAliasSC6->PRODUTO,Dtos(ddatabase),"SC6",cAliasSC6->QTDVEN,"PF",.f.,"MA410MNU.PRW")  
					    
					If !Empty(cAliasSC6->TRANSP) 
						aVlTra := U_VlTrPFEX(cAliasSC6->TRANSP,cAliasSC6->EMISSAO,"PF",.f.)	
					Endif
					
					If	!aVlPFEX[1][1]
						_QStatus  := 'P - Bloqueio PF ' + aVlPFEX[1][2]
					else
						aVlPFEX	:= U_VlDPFEX(cAliasSC6->CLIENT,cAliasSC6->LOJAENT,cAliasSC6->PRODUTO,Dtos(ddatabase),"SC6",cAliasSC6->QTDVEN,"PF",.f.,"MA410MNU.PRW")  
					Endif

					IF !aVlPFEX[1][1]
						_QStatus  := 'P - Bloqueio PF ' + aVlPFEX[1][2]
					ElseIf !EMPTY(cAliasSC6->TRANSP)  .AND. !(aVlTra[1][1])  
						If  !(aVlTra[1][1])        
					   		_QStatus  := 'P - Bloqueio Transportadora PF '+aVlTra[1][2]
				   		Endif
					EndIf 
				EndIf 
				*/
				/*
				If POSICIONE("SB1",1,XFILIAL("SB1")+cAliasSC6->PRODUTO,"B1_CRVME") =='S' .AND. cAliasSC6->BLQ <> "R"
					aVlPFEX	:= U_VlDPFEX(cAliasSC6->CLIENTE,cAliasSC6->LOJACLI,cAliasSC6->PRODUTO,Dtos(ddatabase),"SC6",cAliasSC6->QTDVEN,"EX",.f.,"MA410MNU.PRW")  
					aVlTra := U_VlTrPFEX(cAliasSC6->TRANSP,cAliasSC6->EMISSAO,"EX",.f.)
					If	!aVlPFEX[1][1]
						_QStatus  := 'E - Bloqueio EX ' + aVlPFEX[1][2]
					ElseIf !(aVlTra[1][1])  .AND. !EMPTY(cAliasSC6->TRANSP)           
				   		_QStatus  := 'E - Bloqueio Transportadora EX '+aVlTra[1][2]
					EndIf
				EndIf 
				*/
				/*
				teste := " "
				If !(Substr(_QStatus,1,1) $ 'P/E') .AND. !EMPTY(_BLQREGCOM) //Nao tem bloqueio Federal e Exercito    
					_TxtStat := "BLQ.REG"      
					 _Entrou := .F. 
					If !Empty(cAliasSC6->BLQDESC)
						_Entrou := .T.     
						_TxtStat+= " DESCONTO "
					EndIf
				     
					If !Empty(cAliasSC6->BLQTRAN)
						If _Entrou
						_TxtStat+= "/TRANSP"
						Else                      
						 	_Entrou := .T. 
							_TxtStat+= " TRANSP"
						EndIf
					EndIf
					
					If !Empty(cAliasSC6->BLQFRT)
						If _Entrou
						_TxtStat+= "/FRETE"
						Else                      
						 	_Entrou := .T. 
							_TxtStat+= " FRETE"
						EndIf
					EndIf 	  
				
				
					If !Empty(cAliasSC6->BLQPAG)
						If _Entrou
						_TxtStat+= "/COD.PAG"
						Else                      
						 	_Entrou := .T. 
							_TxtStat+= " COD.PAG"
						EndIf
					EndIf 
					         
					If !Empty(cAliasSC6->BLQDTV)
						If _Entrou
						_TxtStat+= "/DT.VALID"
						Else                      
						 	_Entrou := .T. 
							_TxtStat+= " DT.VALID"
						EndIf
					EndIf 
					
		   			_QStatus  :=	_TxtStat
				 
				   //	_QStatus  := _BLQREGCOM
				EndIf 
				*/



				EndIf
			EndIf
		EndIf



		_DtEmi := SubStr(cAliasSC6->EMISSAO,7,2)+'/'+ SubStr(cAliasSC6->EMISSAO,5,2)+'/'+SubStr(cAliasSC6->EMISSAO,1,4)

		_DATA_HORA := cAliasSC6->DAK_DATA   + cAliasSC6->DAK_HORA
		If Empty(_DATA_HORA)
			_DATA_HORA := "00000000000"
		Endif

		_DtCarga   := SubStr(_DATA_HORA,1,8)
		_HoraCarga := Substr(_DATA_HORA, 9, 8)

		_DtCarga   := SubStr(_DtCarga,7,2)+'/'+ SubStr(_DtCarga,5,2)+'/'+SubStr(_DtCarga,1,4)



		teste := " "
		If _Orig = "RNA"

			If  U_GatPDesc("VISPEN", cAliasSC6->PRODUTO, cAliasSC6->QTDVEN , SC5->C5_CLIENTE,SC5->C5_LOJACLI, SC5->C5_TABELA, SC5->C5_CONDPAG)    >  xXPDEMAX
				_pDesc	:=  U_GatPDesc("VISPEN", cAliasSC6->PRODUTO, cAliasSC6->QTDVEN , SC5->C5_CLIENTE,SC5->C5_LOJACLI, SC5->C5_TABELA, SC5->C5_CONDPAG)
			Else
				_pDesc	:=  xXPDEMAX
			EndIf


			_PrcTab :=	cAliasSC6->XPRCTAB
			_PrUnitPad	:= round( _PrcTab - ((_pDesc/100)*_PrcTab),2)
			teste := " "
			_BlqDesc:=" "

			If !Empty(cAliasSC6->BLQDESC)
				_BlqDesc:= "X"
			Else
				_BlqDesc:= " "
			EndIf
			 /*	
		ElseIf cAliasSC6->XDESC > _pDesc 
			_BlqDesc:= "X"
		ElseIf !Empty(cAliasSC6->BLQDESC)
	   		_BlqDesc:= "X"
		EndIf
		       */                
			teste := " "
			AADD(aRetorno,{_BlqDesc,cAliasSC6->ITEM ,_DtEmi ,cAliasSC6->TES,cAliasSC6->PRODUTO,SubStr(cAliasSC6->DESCPROD,1,30),_DtEntreg,cAliasSC6->QTDVEN,;
				cAliasSC6->PRCVEN,_PrUnitPad,cAliasSC6->VALOR,cAliasSC6->XDESC,_pDesc ,_PrcTab, cAliasSC6->C9_CARGA, _DtCarga, _HoraCarga})
			teste := " "

		Else
			teste := " "
			// valida se produto esta bloqueado para inventแrio.
			If _Bloqueado>0
				DbSelectArea('SB2')
				If !Empty(FbuscaCpo("SB2",1,xFilial("SB2")+cAliasSC6->PRODUTO+cAliasSC6->ARMAZEM,"B2_DINVFIM"))
					_QStatus  := 'I - Bloqueio Inventario '
				Endif
			Endif

			_QStatus := cNewStatus
			AADD(aRetorno,{cAliasSC6->ITEM ,_DtEmi ,cAliasSC6->PRODUTO,SubStr(cAliasSC6->DESCPROD,1,30),_DtEntreg,cAliasSC6->QTDVEN,;
				_SaldoEst,cAliasSC6->QTDENT,_Bloqueado,nQtdLib,cAliasSC6->TES,_QStatus, cAliasSC6->C9_CARGA, _DtCarga, _HoraCarga})
		EndIf

		dbSelectArea("cAliasSC6")
		cAliasSC6->(DbSkip())
	EndDo


	If lQuery
		dbSelectArea("cAliasSC6")
		dbCloseArea()
	EndIf

//cAliasSC6->(DbCloseArea())

/*RECOVER
    
aLastQuery    := GetLastQuery()
cLastQuery    := aLastQuery[2]
               
cError        := oError:Description
cTCSqlError   := TCSqlError()
    
END SEQUENCE
ErrorBlock( bErrorBlock )
*/
	teste := " "
Return(aRetorno)

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


User Function APedVe()
	Local cAliaAnte := Alias()
	Local nAreaAnte := IndexOrd()
	Local nRegiAnte := RecNo()
	Local _cFatSN
	Local aFatSN:={'S','N'}
	Local cFtSNOg
	Local cTpLOg
	Local aTpLib :={'1 - Libera Item','2 - Libera Pedido'}
	Local cPedVin
	Local cCPgto
	Local cTransp
	Local cTTFret
	Local aTTFret	:={'C - CIF','F - FOB','T - Redespacho','S - Sem Frete'}
	Local cMenNot
	Local aUser  := PswRet()
	Local _actxt:=''
//Local  ia := Len(aUser[1][10])  //Grupo de usuarios                   
	Local oFont := tfont():new("Fatura Sim ou Nao",,-11,.t.)
	Local _SegTPPV := .F.
	Local ia := 0

	cFatSN 	:= SC5->C5_XFATURA
	cFtSNOg	:= SC5->C5_XFATURA
	cTpLOg	:= SC5->C5_TIPLIB
	cPedVin	:= SC5->C5_XPEDVIN
	cCPgto	:= SC5->C5_CONDPAG
	cTransp	:= SC5->C5_TRANSP
	cMenNot	:= SC5->C5_MENNOTA
	_actxt  := SC5->C5_CRVOBS
	teste := " "
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


//@ 010, 010 TO 100,350 DIALOG oDlg TITLE "Alteracao Pedido de Venda"         
	DEFINE MSDIALOG _oDlg TITLE "Alteracao Pedido de Venda" FROM 000, 000 TO 450, 600 PIXEL
	@ 008, 005 SAY "Pedido :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
//@ 008, 060 SAY "Emissao: " SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 005 SAY "Cliente:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 034 SAY oSayNPed VAR cNPed SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
//@ 008, 080 SAY oSayEmiss VAR cEmiss SIZE 140, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 034 SAY oSayDesCli VAR cDesCli SIZE 139, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 005 SAY "Fatura S/N :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	oCombo := tComboBox():new(028,60,{|u|if(pcount()>0,cFatSN:=u,cFatSN)},aFatSN, 35, 20,_oDlg,,,,,,.t.,oFont,,,,,,,,"cFatSN")
//mgv1   
//If _SegTPPV
	@ 028, 110 SAY "Tip Liberacao :" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
	oCombo := tComboBox():new(028,160,{|u|if(pcount()>0,cTpLib:=u,cTpLib)},aTpLib, 80, 20,_oDlg,,,,,,.t.,oFont,,,,,,,,"cTpLib")
//EndIf	
	@ 045,005 SAY "Vinculo  :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045,034 MSGET oGetPedV VAR cPedVin Picture "@!" SIZE 060,10 PIXEL OF oDlg F3 "SZ0" //VALID VldTransp(SC5->C5_TRANSP,SC5->C5_CLIENTE, SC5->C5_LOJACLI)
//@ 042,110 SAY "Cod.Pagt:" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
//@ 042,160 MSGET oGetCP VAR cCPgto Picture "@!" SIZE 060,10 PIXEL OF oDlg F3 "SE4" //VALID VldTransp(SC5->C5_TRANSP,SC5->C5_CLIENTE, SC5->C5_LOJACLI)
//@ 056,012 SAY "Transp :" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL        
//@ 056,034 MSGET oGetTran VAR cTransp Picture "@!" SIZE 060,10 PIXEL OF oDlg F3 "SA4" Valid VldTra(SC5->C5_NUM,cTransp)
//@ 056,110 SAY "Tip. Frete" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL  
//oCombo := tComboBox():new(056,160,{|u|if(pcount()>0,cTTFret:=u,cTTFret)},aTTFret, 80, 20,_oDlg,,,,,,.t.,oFont,,,,,,,,"cTTFret")   
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
Return()


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
	teste := " "
	Do While !Eof() .and. xFilial("SC6") = SC6->C6_FILIAL .AND.;
			SC6->C6_NUM = _NumPV
		tste := " "
		dbSelectArea("SB1")  // Itens do Pedido
		SB1->(dbSetOrder(1)) //
		SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		If SB1->B1_CRVPF=="S"
			If !empty(_cTransp)
				tste := " "
				aVlTra  := U_VlTrPFEX(_cTransp,sData,"PF",.t.)
				_Ret	:= aVlTra[1][1]
				Exit
			EndIf
		EndIf
		If SB1->B1_CRVME=='S'
			If !empty(_cTransp)  .and. _Ret
				tste := " "
				aVlTra  := U_VlTrPFEX(_cTransp,sData,"EX",.t.)
				_Ret 	:= aVlTra[1][1]
				Exit
			EndIf
		EndIf

		SC6->(dbSelectArea("SC6"))
		SC6->(dbSkip())
	EndDo
Return(_Ret)

Static Function MudaPed(_FatSN,_TpLib,_FSNOg, _TpLOg,_PedVin,_CPgto,_cTranp,_TTFret,_MenNot,_SegTPPV,_actxt)




	If _FatSN <> _FSNOg

		dbSelectArea("SC5")  // Itens do Pedido
		dbSetOrder(1) // C5_FILIAL+C5_NUM
		dbSeek(xFilial("SC5")+SC5->C5_NUM)
		RecLock("SC5",.F.)
		SC5->C5_XFATURA := _FatSN
		//SC5->C5_TIPLIB	:= SUBSTR(LTRIM(RTRIM(_TpLib)),1,1)
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

//mgv1     
//If _SegTPPV
	If SUBSTR(LTRIM(RTRIM(_TpLib)),1,1) <> _TpLOg
		dbSelectArea("SC5")  // Itens do Pedido
		dbSetOrder(1) // C5_FILIAL+C5_NUM
		dbSeek(xFilial("SC5")+SC5->C5_NUM)
		RecLock("SC5",.F.)
		SC5->C5_TIPLIB	:= SUBSTR(LTRIM(RTRIM(_TpLib)),1,1)
		MsUnLock()
	EndIf
//EndIf

	dbSelectArea("SC5")  // Itens do Pedido
	dbSetOrder(1) // C5_FILIAL+C5_NUM
	dbSeek(xFilial("SC5")+SC5->C5_NUM)
	RecLock("SC5",.F.)
	SC5->C5_XPEDVIN	:= _PedVin
	SC5->C5_MENNOTA	:=_MenNot
	SC5->C5_CRVOBS	:=_actxt
	MsUnLock()
	_oDlg:End()
Return()

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

User  Function VldTransp( _TRANSP,_Cli,_Loja)
	Local lRetorno := .t.
	Local sData     :=Dtos(SC5->C5_EMISSAO)
	Local aVlTra 	:= {}
	Local _cQry


	_cQry  :="	SELECT SC9.C9_PEDIDO     AS PEDIDO,    	"
	_cQry  +="			SC9.C9_CLIENTE   AS CLIENTE,   	"
	_cQry  +="			SC9.C9_LOJA      /AS LOJA,   	"
	_cQry  +="			SC9.C9_PRODUTO	 AS CODPRO,	  	"
	_cQry  +="			SB1.B1_CRVPF 	 AS CRVPF,    	"
	_cQry  +="			SB1.B1_CRVME     AS CRVME,    	"
	_cQry  +="			SUM(SC9.C9_QTDLIB) AS QTDLIB 	"
//_cQry  +=" FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SB1")+" SB1 ON SC9.C9_FILIAL = SB1.B1_FILIAL AND SC9.C9_PRODUTO = SB1.B1_COD AND SC9.D_E_L_E_T_ = SB1.D_E_L_E_T_  "//ALTERADO DYEGO 09/07/14
	_cQry  +=" FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+XFILIAL("SB1")+"' AND SC9.C9_PRODUTO = SB1.B1_COD AND SC9.D_E_L_E_T_ = SB1.D_E_L_E_T_  "//ALTERADO DYEGO 09/07/14
	_cQry  +=" WHERE SC9.D_E_L_E_T_ = ' ' "
	_cQry  +="			AND SC9.C9_FILIAL = '"+xFilial("SC9")+"' "
	_cQry  +="	        AND SC9.C9_PEDIDO = '"+SC5->C5_NUM+"'  "
	_cQry  +="	        AND SC9.C9_CLIENTE = '"+_Cli+"'  "
	_cQry  +="	        AND SC9.C9_LOJA   =  '"+_Loja+"'     "
	_cQry  +="GROUP BY SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA, SC9.C9_PRODUTO, SB1.B1_CRVPF, SB1.B1_CRVME "
	teste := " "
	If Select("QRY") <> 0
		dbSelectArea("QRY")
		dbCloseArea()
	Endif
	TCQUERY _cQry NEW ALIAS "QRY"
	QRY->(DBGoTop())
	Do While !(QRY->(EOF()))
		teste := ""
		//_TRANSP	:= SC5->C5_TRANSP
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
	End Do
	teste := " "
	dbSelectArea("QRY")
	dbCloseArea()
Return(lRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/07/2025
Consultoria: Proativa
Uso: Calibre
Info: Cแlculo de IPI conforme a planilha 
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
			nIPI    += SC6->C6_VALOR * nAliqIPI / 100
		
			MaFisSave()
			MaFisEnd()		
			
			SC6->(DbSkip())

		EndDo

	Endif 

Return(nIPI)

