//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include 'FWMVCDEF.CH'
#Include "Totvs.ch"

//Constantes
#Define STR_PULA Chr(13)+Chr(10)

// Alinhamento/Fomato para FWMsExcelEX
Static nLeft      := 1
Static nGeneral   := 1
Static nDateTime  := 4

/*/{Protheus.doc} TELANFE
Gera arquivo Excel com 2 abas:
1) NFs EMITIDAS  (SF2)
2) NFs CANCELADAS (SF3)

Sem interface grafica. Destinado a ser chamado por rotina agendada.
@author Equipe Calibre
@since 19/03/2026
/*/
User Function TELANFE()
	Local aArea    := GetArea()
	Local cArquivo := ""
	Local cArquivoSrv := ""
	Local cArquivoAttach := ""
	Local cAssunto := ""
	Local cCorpo   := ""
	Local cDataArq := ""
	Local cNomeArq := ""
	Local aEmail   := {}
	Local nX       := 0
	Local lManual  := .F.
	Local cTabela  := "XD"	

	if IsBlind() .or. Select("SX2") == 0
		RPCSetEnv("01","01",,,"FAT")
	Endif

	aEmail := BuscaEmail(cTabela)

	For nX := 1 To Len(aEmail) 
		IF aEmail[nX] <> '' .AND. !lManual

			fGerarExcel(@cArquivo, @cArquivoSrv)

			If IsBlind()
				cDataArq  := fDataDDMMYYYY(dDataBase-1)
				cNomeArq  := "Notas_Fiscais_" + cDataArq

				// Fonte oficial do anexo: protheus_data\system.
				cArquivoAttach := cArquivoSrv
				If Empty(cArquivoAttach)
					cArquivoAttach := "\spool\"+cNomeArq+".xml"
				EndIf

				If !File(cArquivoAttach)
					MsgAlert("Nao foi possivel salvar o arquivo no protheus_data\system para anexar no e-mail.")
					Return .F.
				EndIf

				cAssunto := "Notas Fiscais " + DToC(dDataBase-1)
				cCorpo   := "Segue em anexo relatorio de notas fiscais, referente a emissao " + DToC(dDataBase-1)
				xEnvMail(cArquivoAttach, cArquivoSrv, aEmail[nX], cAssunto, cCorpo)
			Else
				ShellExecute("Open",cArquivo,"","",5) //Abertura da pasta local onde consta o arquivo Excel
				RestArea(aArea)
				lManual := .T. // Para evitar loop de envio de e-mails, caso o usu�rio gere o arquivo manualmente
			EndIf

			RestArea(aArea)
		ENDIF   
	Next nX
Return

/*-------------------------------------------------------------------------------*
 | Func:  fGerarExcel                                                            |
 | Desc:  Gera a planilha em C:\temp                                             |
 *-------------------------------------------------------------------------------*/
Static Function fGerarExcel(cArquivo, cArquivoSrvOut)
	Local cPasta     := GetMV("XX_XARQUI",.F.,"C:\temp\")
	Local oExcel      := Nil
	Local cAliasE     := GetNextAlias()
	Local cAliasC     := GetNextAlias()
	Local cQueryE     := ""
	Local cQueryC     := ""
	Local cDataBase   := DToS(dDataBase)
	Local cDataArq     := fDataDDMMYYYY(dDataBase-1)
	Local cNomeArq    := "Notas_Fiscais_" + cDataArq
	Local cNomeArqSrv := IIf(!IsBlind(),cPasta+cNomeArq+".xml","\spool\"+cNomeArq+".xml")

	Default cArquivo := ""
	Default cArquivoSrvOut := ""

	cArquivo := cNomeArqSrv

	oExcel := FWMsExcelEx():New()
	oExcel:SetCelFont("Arial")
	oExcel:SetCelSizeFont(10)

	// -------------------------------------------------
	// ABA 1 - NFs EMITIDAS (SF2)
	// -------------------------------------------------
	oExcel:AddWorkSheet("NFs EMITIDAS")
	oExcel:AddTable("NFs EMITIDAS", "NFsEmitidas")
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Numero"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Serie Docto." , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Cliente"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Loja"          , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Cond. Pagto"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "DT Emissao"    , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vl.Frete FOB" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vlr.Mercad"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Tipo da nota" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Msg Nota"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Volume 1"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Cubagem m3"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Transp."      , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Redespacho"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Valor Fatura" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Hora"         , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Obs.NF"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Data digit."  , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Nome Cliente"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Nome Transp."  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Condicao Pgt" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Tipo Fretel"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Dt Impressao"  , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Hora Imp."    , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "No.Impressao" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "NF Eletr."    , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Data Etq Vol" , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Hr Etiq Vol"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Base IR"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "NF Exp."      , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Cod.NF IcmSt" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Chave NFe"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Tipo de fret" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Ordem Sep."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vendedor"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "No.Romaneio"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Tp Doc Motor" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Data Coleta"  , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "No.Doc.Motor" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Hora Coleta"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Motorista"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "NF Vinculada" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Cod.NT Fecp"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Dt.R.Cambial" , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "V.Reintegra"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "B.C.Reinteg"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Serie MDFe"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Número MDFe"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "GNRE FECP"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "GNRE DIFAL"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Dt.Exec.Serv" , nLeft, nDateTime)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vlr.FUNDESA" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vlr. IMA-MT" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vlr. FASE-MT" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Lib p/ Sefaz" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Base FCP Cmp" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Base FCP Pr." , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Base FCP ST" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Mun.Prest."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "UF. Prest."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Frete CFOP"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Cod Intermed" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Vl.Frete CIF" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Status Entr." , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "NF Origem"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Usr Inclusao" , nLeft, nGeneral)
	oExcel:AddColumn("NFs EMITIDAS", "NFsEmitidas", "Usr Ult Alt"  , nLeft, nGeneral)

	cQueryE := ""
	cQueryE += " SELECT * FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + STR_PULA
	cQueryE += " WHERE SF2.F2_EMISSAO = '" + cDataBase + "' " + STR_PULA
	cQueryE	+= "   AND SF2.D_E_L_E_T_ = '' " + STR_PULA
	cQueryE += " ORDER BY SF2.F2_DOC, SF2.F2_SERIE "
	cQueryE := ChangeQuery(cQueryE)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryE), cAliasE, .F., .T.)
	(cAliasE)->(DbGoTop())
	While !(cAliasE)->(Eof())
		oExcel:AddRow("NFs EMITIDAS", "NFsEmitidas", {;
			AllTrim((cAliasE)->F2_DOC),;
			AllTrim((cAliasE)->F2_SERIE),;
			AllTrim((cAliasE)->F2_CLIENTE),;
			AllTrim((cAliasE)->F2_LOJA),;
			AllTrim((cAliasE)->F2_COND),;
			fDataBr((cAliasE)->F2_EMISSAO),;
			fNumExcel((cAliasE)->F2_FRETE, .T.),;
			fNumExcel((cAliasE)->F2_VALMERC, .T.),;
			AllTrim((cAliasE)->F2_TIPO),;
			AllTrim(fGetField(cAliasE, "F2_MENNOTA")),;
			fNumExcel((cAliasE)->F2_VOLUME1, .F.),;
			fNumExcel((cAliasE)->F2_VOLUME2, .F.),;
			AllTrim((cAliasE)->F2_TRANSP),;
			AllTrim((cAliasE)->F2_REDESP),;
			fNumExcel((cAliasE)->F2_VALFAT, .T.),;
			AllTrim((cAliasE)->F2_HORA),;
			AllTrim((cAliasE)->F2_CRVOBS),;
			fDataBr((cAliasE)->F2_DTDIGIT),;
			AllTrim(fGetField(cAliasE, "F2_CRVCLI")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVTRAN")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVPAG")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVFRET")) ,;
			fDataBr((cAliasE)->F2_CRVIMPD),;
			AllTrim((cAliasE)->F2_CRVIMPH),;
			fNumExcel((cAliasE)->F2_CRVIMP, .F.),;
			AllTrim((cAliasE)->F2_NFELETR),;
			fDataBr((cAliasE)->F2_CRVVOLD),;
			AllTrim((cAliasE)->F2_CRVVOLT),;
			fNumExcel((cAliasE)->F2_BASEIRR, .T.),;
			AllTrim((cAliasE)->F2_TPNFEXP),;
			AllTrim((cAliasE)->F2_NFICMST),;
			AllTrim((cAliasE)->F2_CHVNFE),;
			AllTrim((cAliasE)->F2_TPFRETE),;
			AllTrim((cAliasE)->F2_ORDSEP),;
			AllTrim(fGetField(cAliasE, "F2_CRVVEND")) ,;
			AllTrim((cAliasE)->F2_CRVROM),;
			AllTrim(fGetField(cAliasE, "F2_CRVTPDO")) ,;
			fDataBr(fGetField(cAliasE, "F2_CRVDTCO")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVMDOC")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVROMH")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVMOTO")) ,;
			AllTrim((cAliasE)->F2_CRVVINC),;
			AllTrim((cAliasE)->F2_NTFECP),;
			fDataBr((cAliasE)->F2_DTTXREF),;
			fNumExcel((cAliasE)->F2_VREINT, .T.),;
			fNumExcel((cAliasE)->F2_BSREIN, .T.),;
			AllTrim((cAliasE)->F2_SERMDF),;
			AllTrim((cAliasE)->F2_NUMMDF),;
			AllTrim((cAliasE)->F2_GNRFECP),;
			AllTrim((cAliasE)->F2_GNRDIF),;
			fDataBr((cAliasE)->F2_DTESERV),;
			fNumExcel((cAliasE)->F2_VALFUND, .T.),;
			fNumExcel((cAliasE)->F2_VALIMA, .T.),;
			fNumExcel((cAliasE)->F2_VALFASE, .T.),;
			AllTrim((cAliasE)->F2_XLIBNFE),;
			fNumExcel((cAliasE)->F2_BSFCCMP, .T.),;
			fNumExcel((cAliasE)->F2_BASFECP, .T.),;
			fNumExcel((cAliasE)->F2_BSFCPST, .T.),;
			AllTrim((cAliasE)->F2_MUNPRES),;
			AllTrim((cAliasE)->F2_ESTPRES),;
			AllTrim((cAliasE)->F2_FRTCFOP),;
			AllTrim((cAliasE)->F2_CODA1U),;
			fNumExcel((cAliasE)->F2_ZFRETE, .T.),;
			AllTrim(fGetField(cAliasE, "F2_XEDIPRO")) ,;
			AllTrim((cAliasE)->F2_XNFORIG),;
			fUserFromLog(fGetField(cAliasE, "F2_USERLGI")) ,;
			fUserFromLog(fGetField(cAliasE, "F2_USERLGA")) }) 
		(cAliasE)->(DbSkip())
	EndDo
	(cAliasE)->(DbCloseArea())

	// -------------------------------------------------
	// ABA 2 - NFs CANCELADAS (SF3)
	// Deduplicacao por nota/serie/cliente/loja/data emissao
	// -------------------------------------------------
	oExcel:AddWorkSheet("NFs CANCELADAS")
	oExcel:AddTable("NFs CANCELADAS", "NFsCanceladas")
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "DT Entrada"      , nLeft, nDateTime)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "DT Emissão"       , nLeft, nDateTime)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Nota Fiscal"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Serie N.F."      , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Clien/Fornec"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Loja"            , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "N§ Doc.Pre."     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Al. Cof ST"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Al. Pis ST"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "NF Eletr."       , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Md5 Cat79"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Num. RPS"        , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Tipo PRODEPE"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr FECOP-RN"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "V.FECOP-ST/R"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr FECP-MG"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "V.FECP-ST/MG"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "V.Reintegra"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "B.C.Reinteg"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr FECP-MT"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "V.FECP-ST/MT"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vl.ISS CPM"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Alq.ISS CPM"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vl.Fumipeq"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base Fumipeq"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Aliq.Fumipeq"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Valor Famad"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Sér.SAT"        , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base CPRB"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Valor CPRB"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Alíquota CPR"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr FECP Dif"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Difal ICMS"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base. Destin"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Cliente Dest"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Loja Dest"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "BS.ICMS Ori."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr.FUNDESA"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr. IMA-MT"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr.FASE-MT"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Prc Medio P."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Bas.INSS.Pt"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Perc.INSS.Pt"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Val.INSS.Pt"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "C. Trib. Mun"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Aliq IPI"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Protocolo"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Cód. Ativ."     , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base FCP Pr."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base FCP ST"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base FCP Ant"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Base FCP Cmp"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr. FCP Ant"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Bas.FUNRURAL"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "Vlr FUNRURAL"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs CANCELADAS", "NFsCanceladas", "DT Cancelamento" , nLeft, nDateTime)

	// GROUP BY para deduplicar por NF (SF3 grava por CFOP e pode gerar múltiplas linhas).
	// Para manter os campos consistentes, os demais campos usam MAX().
	cQueryC := ""
	cQueryC += " SELECT " + STR_PULA
	cQueryC += "  SF3.F3_ENTRADA, " + STR_PULA
	cQueryC += "  SF3.F3_EMISSAO, " + STR_PULA
	cQueryC += "  SF3.F3_NFISCAL, " + STR_PULA
	cQueryC += "  SF3.F3_SERIE, " + STR_PULA
	cQueryC += "  SF3.F3_CLIEFOR, " + STR_PULA
	cQueryC += "  SF3.F3_LOJA, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_DOCPRE)   AS F3_DOCPRE, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ALIQCF3) AS F3_ALIQCF3, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ALIQPS3) AS F3_ALIQPS3, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_NFELETR) AS F3_NFELETR, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_MDCAT79) AS F3_MDCAT79, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_NUMRPS)  AS F3_NUMRPS, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_TPPRODE) AS F3_TPPRODE, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFECPRN)  AS F3_VFECPRN, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFESTRN)  AS F3_VFESTRN, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFECPMG)  AS F3_VFECPMG, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFESTMG)  AS F3_VFESTMG, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VREINT)   AS F3_VREINT, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BSREIN)   AS F3_BSREIN, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFECPMT)  AS F3_VFECPMT, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFESTMT)  AS F3_VFESTMT, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALCPM)   AS F3_VALCPM, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ALQCPM)   AS F3_ALQCPM, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALFMP)   AS F3_VALFMP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BASEFMP) AS F3_BASEFMP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ALQFMP)   AS F3_ALQFMP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALFMD)   AS F3_VALFMD, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_SERSAT)   AS F3_SERSAT, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BASECPB) AS F3_BASECPB, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALCPB)   AS F3_VALCPB, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ALIQCPB)  AS F3_ALIQCPB, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFCPDIF)  AS F3_VFCPDIF, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_DIFAL)     AS F3_DIFAL, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BASEDES)  AS F3_BASEDES, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_CLIDEST)  AS F3_CLIDEST, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_LOJDEST)   AS F3_LOJDEST, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BSICMOR)  AS F3_BSICMOR, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALFUND)  AS F3_VALFUND, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALIMA)   AS F3_VALIMA, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALFASE)  AS F3_VALFASE, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_PRCMEDP)  AS F3_PRCMEDP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BASEINP) AS F3_BASEINP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_PERCINP) AS F3_PERCINP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALINP)  AS F3_VALINP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_TRIBMUN)  AS F3_TRIBMUN, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ALIQIPI)  AS F3_ALIQIPI, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_PROTOC)   AS F3_PROTOC, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_ATIVCPB)  AS F3_ATIVCPB, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BASFECP)  AS F3_BASFECP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BSFCPST)  AS F3_BSFCPST, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BFCPANT)  AS F3_BFCPANT, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BSFCCMP)  AS F3_BSFCCMP, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VFCPANT)  AS F3_VFCPANT, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_BASEFUN)  AS F3_BASEFUN, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_VALFUN)   AS F3_VALFUN, " + STR_PULA
	cQueryC += "  MAX(SF3.F3_DTCANC)   AS F3_DTCANC " + STR_PULA
	cQueryC += " FROM " + RetSqlName("SF3") + " SF3 (NOLOCK) " + STR_PULA
	cQueryC += " WHERE SF3.F3_DTCANC = '" + cDataBase + "' " + STR_PULA
	cQueryC += "   AND SF3.F3_DTCANC <> '' " + STR_PULA
	cQueryC += "   AND SF3.D_E_L_E_T_ = '' " + STR_PULA
	cQueryC += " GROUP BY SF3.F3_ENTRADA, SF3.F3_EMISSAO, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA " + STR_PULA
	cQueryC += " ORDER BY SF3.F3_NFISCAL, SF3.F3_SERIE "
	cQueryC := ChangeQuery(cQueryC)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryC), cAliasC, .F., .T.)
	(cAliasC)->(DbGoTop())
	While !(cAliasC)->(Eof())
		oExcel:AddRow("NFs CANCELADAS", "NFsCanceladas", {;
			fDataBr((cAliasC)->F3_ENTRADA),;        // DT Entrada
			fDataBr((cAliasC)->F3_EMISSAO),;        // DT Emissão
			AllTrim((cAliasC)->F3_NFISCAL),;        // Nota Fiscal
			AllTrim((cAliasC)->F3_SERIE),;          // Serie N.F.
			AllTrim((cAliasC)->F3_CLIEFOR),;       // Clien/Fornec
			AllTrim((cAliasC)->F3_LOJA),;           // Loja
			AllTrim((cAliasC)->F3_DOCPRE),;        // N§ Doc.Pre.
			fNumExcel((cAliasC)->F3_ALIQCF3, .F.),; // Al. Cof ST
			fNumExcel((cAliasC)->F3_ALIQPS3, .F.),; // Al. Pis ST
			AllTrim((cAliasC)->F3_NFELETR),;        // NF Eletr.
			AllTrim((cAliasC)->F3_MDCAT79),;        // Md5 Cat79
			AllTrim((cAliasC)->F3_NUMRPS),;         // Num. RPS
			AllTrim((cAliasC)->F3_TPPRODE),;       // Tipo PRODEPE
			fNumExcel((cAliasC)->F3_VFECPRN, .T.),; // Vlr FECOP-RN
			fNumExcel((cAliasC)->F3_VFESTRN, .T.),; // V.FECOP-ST/R
			fNumExcel((cAliasC)->F3_VFECPMG, .T.),; // Vlr FECP-MG
			fNumExcel((cAliasC)->F3_VFESTMG, .T.),; // V.FECP-ST/MG
			fNumExcel((cAliasC)->F3_VREINT, .T.),;  // V.Reintegra
			fNumExcel((cAliasC)->F3_BSREIN, .T.),;  // B.C.Reinteg
			fNumExcel((cAliasC)->F3_VFECPMT, .T.),; // Vlr FECP-MT
			fNumExcel((cAliasC)->F3_VFESTMT, .T.),; // V.FECP-ST/MT
			fNumExcel((cAliasC)->F3_VALCPM, .T.),; // Vl.ISS CPM
			fNumExcel((cAliasC)->F3_ALQCPM, .F.),;  // Alq.ISS CPM
			fNumExcel((cAliasC)->F3_VALFMP, .T.),; // Vl.Fumipeq
			fNumExcel((cAliasC)->F3_BASEFMP, .T.),; // Base Fumipeq
			fNumExcel((cAliasC)->F3_ALQFMP, .F.),;  // Aliq.Fumipeq
			fNumExcel((cAliasC)->F3_VALFMD, .T.),; // Valor Famad
			AllTrim((cAliasC)->F3_SERSAT),;        // Sér.SAT
			fNumExcel((cAliasC)->F3_BASECPB, .T.),; // Base CPRB
			fNumExcel((cAliasC)->F3_VALCPB, .T.),;  // Valor CPRB
			fNumExcel((cAliasC)->F3_ALIQCPB, .F.),; // Alíquota CPR
			fNumExcel((cAliasC)->F3_VFCPDIF, .T.),; // Vlr FECP Dif
			fNumExcel((cAliasC)->F3_DIFAL, .T.),;   // Difal ICMS
			fNumExcel((cAliasC)->F3_BASEDES, .T.),; // Base. Destin
			AllTrim((cAliasC)->F3_CLIDEST),;       // Cliente Dest
			AllTrim((cAliasC)->F3_LOJDEST),;       // Loja Dest
			fNumExcel((cAliasC)->F3_BSICMOR, .T.),; // BS.ICMS Ori.
			fNumExcel((cAliasC)->F3_VALFUND, .T.),; // Vlr.FUNDESA
			fNumExcel((cAliasC)->F3_VALIMA, .T.),;  // Vlr. IMA-MT
			fNumExcel((cAliasC)->F3_VALFASE, .T.),; // Vlr.FASE-MT
			fNumExcel((cAliasC)->F3_PRCMEDP, .F.),; // Prc Medio P.
			fNumExcel((cAliasC)->F3_BASEINP, .T.),; // Bas.INSS.Pt
			fNumExcel((cAliasC)->F3_PERCINP, .F.),; // Perc.INSS.Pt
			fNumExcel((cAliasC)->F3_VALINP, .T.),;  // Val.INSS.Pt
			AllTrim((cAliasC)->F3_TRIBMUN),;       // C. Trib. Mun
			fNumExcel((cAliasC)->F3_ALIQIPI, .F.),; // Aliq IPI
			AllTrim((cAliasC)->F3_PROTOC),;        // Protocolo
			AllTrim((cAliasC)->F3_ATIVCPB),;       // Cód. Ativ.
			fNumExcel((cAliasC)->F3_BASFECP, .T.),; // Base FCP Pr.
			fNumExcel((cAliasC)->F3_BSFCPST, .T.),; // Base FCP ST
			fNumExcel((cAliasC)->F3_BFCPANT, .T.),; // Base FCP Ant
			fNumExcel((cAliasC)->F3_BSFCCMP, .T.),; // Base FCP Cmp
			fNumExcel((cAliasC)->F3_VFCPANT, .T.),; // Vlr. FCP Ant
			fNumExcel((cAliasC)->F3_BASEFUN, .T.),; // Bas.FUNRURAL
			fNumExcel((cAliasC)->F3_VALFUN, .T.),;  // Vlr FUNRURAL
			fDataBr((cAliasC)->F3_DTCANC)})         // DT Cancelamento
		(cAliasC)->(DbSkip())
	EndDo
	(cAliasC)->(DbCloseArea())

	// -------------------------------------------------
	// ABA 3 - NFs n�o transmitidas (SF2)
	// -------------------------------------------------

	oExcel:AddWorkSheet("NFs N TRANSMITIDAS")
	oExcel:AddTable("NFs N TRANSMITIDAS", "NFsnTransf")
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Numero"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Serie Docto." , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Cliente"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Loja"          , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Cond. Pagto"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "DT Emissao"    , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vl.Frete FOB" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vlr.Mercad"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Tipo da nota" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Msg Nota"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Volume 1"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Cubagem m3"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Transp."      , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Redespacho"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Valor Fatura" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Hora"         , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Obs.NF"       , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Data digit."  , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Nome Cliente"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Nome Transp."  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Condicao Pgt" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Tipo Fretel"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Dt Impressao"  , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Hora Imp."    , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "No.Impressao" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "NF Eletr."    , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Data Etq Vol" , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Hr Etiq Vol"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Base IR"      , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "NF Exp."      , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Cod.NF IcmSt" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Chave NFe"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Tipo de fret" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Ordem Sep."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vendedor"     , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "No.Romaneio"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Tp Doc Motor" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Data Coleta"  , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "No.Doc.Motor" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Hora Coleta"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Motorista"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "NF Vinculada" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Cod.NT Fecp"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Dt.R.Cambial" , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "V.Reintegra"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "B.C.Reinteg"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Serie MDFe"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Número MDFe"  , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "GNRE FECP"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "GNRE DIFAL"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Dt.Exec.Serv" , nLeft, nDateTime)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vlr.FUNDESA" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vlr. IMA-MT" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vlr. FASE-MT" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Lib p/ Sefaz" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Base FCP Cmp" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Base FCP Pr." , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Base FCP ST" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Mun.Prest."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "UF. Prest."   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Frete CFOP"   , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Cod Intermed" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Vl.Frete CIF" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Status Entr." , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "NF Origem"    , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Usr Inclusao" , nLeft, nGeneral)
	oExcel:AddColumn("NFs N TRANSMITIDAS", "NFsnTransf", "Usr Ult Alt"  , nLeft, nGeneral)

	cQueryE := ""
	cQueryE += " SELECT * FROM " + RetSqlName("SF2") + " SF2 (NOLOCK) " + STR_PULA
	cQueryE += " WHERE F2_SERIE <> 'NFS' "+ STR_PULA
	cQueryE += "   AND SF2.F2_EMISSAO = '" + cDataBase + "' " + STR_PULA
	cQueryE	+= "   AND F2_CHVNFE = '' " + STR_PULA
	cQueryE	+= "   AND SF2.D_E_L_E_T_ = '' " + STR_PULA
	cQueryE += " ORDER BY SF2.F2_DOC, SF2.F2_SERIE "
	cQueryE := ChangeQuery(cQueryE)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryE), cAliasE, .F., .T.)
	(cAliasE)->(DbGoTop())
	While !(cAliasE)->(Eof())
		oExcel:AddRow("NFs N TRANSMITIDAS", "NFsnTransf", {;
			AllTrim((cAliasE)->F2_DOC),;
			AllTrim((cAliasE)->F2_SERIE),;
			AllTrim((cAliasE)->F2_CLIENTE),;
			AllTrim((cAliasE)->F2_LOJA),;
			AllTrim((cAliasE)->F2_COND),;
			fDataBr((cAliasE)->F2_EMISSAO),;
			fNumExcel((cAliasE)->F2_FRETE, .T.),;
			fNumExcel((cAliasE)->F2_VALMERC, .T.),;
			AllTrim((cAliasE)->F2_TIPO),;
			AllTrim(fGetField(cAliasE, "F2_MENNOTA")),;
			fNumExcel((cAliasE)->F2_VOLUME1, .F.),;
			fNumExcel((cAliasE)->F2_VOLUME2, .F.),;
			AllTrim((cAliasE)->F2_TRANSP),;
			AllTrim((cAliasE)->F2_REDESP),;
			fNumExcel((cAliasE)->F2_VALFAT, .T.),;
			AllTrim((cAliasE)->F2_HORA),;
			AllTrim((cAliasE)->F2_CRVOBS),;
			fDataBr((cAliasE)->F2_DTDIGIT),;
			AllTrim(fGetField(cAliasE, "F2_CRVCLI")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVTRAN")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVPAG")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVFRET")) ,;
			fDataBr((cAliasE)->F2_CRVIMPD),;
			AllTrim((cAliasE)->F2_CRVIMPH),;
			fNumExcel((cAliasE)->F2_CRVIMP, .F.),;
			AllTrim((cAliasE)->F2_NFELETR),;
			fDataBr((cAliasE)->F2_CRVVOLD),;
			AllTrim((cAliasE)->F2_CRVVOLT),;
			fNumExcel((cAliasE)->F2_BASEIRR, .T.),;
			AllTrim((cAliasE)->F2_TPNFEXP),;
			AllTrim((cAliasE)->F2_NFICMST),;
			AllTrim((cAliasE)->F2_CHVNFE),;
			AllTrim((cAliasE)->F2_TPFRETE),;
			AllTrim((cAliasE)->F2_ORDSEP),;
			AllTrim(fGetField(cAliasE, "F2_CRVVEND")) ,;
			AllTrim((cAliasE)->F2_CRVROM),;
			AllTrim(fGetField(cAliasE, "F2_CRVTPDO")) ,;
			fDataBr(fGetField(cAliasE, "F2_CRVDTCO")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVMDOC")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVROMH")) ,;
			AllTrim(fGetField(cAliasE, "F2_CRVMOTO")) ,;
			AllTrim((cAliasE)->F2_CRVVINC),;
			AllTrim((cAliasE)->F2_NTFECP),;
			fDataBr((cAliasE)->F2_DTTXREF),;
			fNumExcel((cAliasE)->F2_VREINT, .T.),;
			fNumExcel((cAliasE)->F2_BSREIN, .T.),;
			AllTrim((cAliasE)->F2_SERMDF),;
			AllTrim((cAliasE)->F2_NUMMDF),;
			AllTrim((cAliasE)->F2_GNRFECP),;
			AllTrim((cAliasE)->F2_GNRDIF),;
			fDataBr((cAliasE)->F2_DTESERV),;
			fNumExcel((cAliasE)->F2_VALFUND, .T.),;
			fNumExcel((cAliasE)->F2_VALIMA, .T.),;
			fNumExcel((cAliasE)->F2_VALFASE, .T.),;
			AllTrim((cAliasE)->F2_XLIBNFE),;
			fNumExcel((cAliasE)->F2_BSFCCMP, .T.),;
			fNumExcel((cAliasE)->F2_BASFECP, .T.),;
			fNumExcel((cAliasE)->F2_BSFCPST, .T.),;
			AllTrim((cAliasE)->F2_MUNPRES),;
			AllTrim((cAliasE)->F2_ESTPRES),;
			AllTrim((cAliasE)->F2_FRTCFOP),;
			AllTrim((cAliasE)->F2_CODA1U),;
			fNumExcel((cAliasE)->F2_ZFRETE, .T.),;
			AllTrim(fGetField(cAliasE, "F2_XEDIPRO")) ,;
			AllTrim((cAliasE)->F2_XNFORIG),;
			fUserFromLog(fGetField(cAliasE, "F2_USERLGI")) ,;
			fUserFromLog(fGetField(cAliasE, "F2_USERLGA")) }) 
		(cAliasE)->(DbSkip())
	EndDo
	(cAliasE)->(DbCloseArea())

	oExcel:Activate()

	// Grava��o principal: gerar apenas uma vez no protheus_data\system.
	// Evita inconsist�ncia ao chamar GetXMLFile m�ltiplas vezes no mesmo objeto.
	/*If File(cNomeArqSrv)
		FErase(cNomeArqSrv)
	EndIf*/

	oExcel:GetXMLFile(cNomeArqSrv)
	oExcel:DeActivate()

	If File(cNomeArqSrv)
		cArquivoSrvOut := cNomeArqSrv
		cArquivo := cNomeArqSrv
		//MsgInfo("Arquivo salvo no protheus_data (server): " + cNomeArqSrv)
	Else
		MsgAlert("Falha ao gravar arquivo no protheus_data\system: " + cNomeArqSrv)
	EndIf

Return !Empty(cArquivoSrvOut)

/*-------------------------------------------------------------------------------*
 | Func:  xEnvMail                                                             |
 | Desc:  Envia e-mail com anexo usando SMTP (baseado em CVFATR03.prw)            |
 *-------------------------------------------------------------------------------*/
Static Function xEnvMail(cArquivo, cArquivoSrv, cEmail, cAssunto, cCorpo)
	Local cAssuntoFinal := If(Empty(cAssunto), "Relatorio", cAssunto)
	Local cBodyFinal    := If(Empty(cCorpo), "Segue em anexo relatorio de notas fiscais.", cCorpo)
	Local lMailAuth	:= GetMV("MV_RELAUTH",.F.,.T.) // autentica no SMTP
	Local nPortSMTP	:= 587
	Local nTimeout	:= GetMV("MV_RELTIME")
	Local xRet
	Local oServer
	Local oMessage

	Local cMailConta := Alltrim(GetMV("MV_RELACNT"))
	Local cMailServer := AllTrim(GetMV("MV_RELSERV"))
	Local cMailSenha := Alltrim(GetMV("MV_RELPSW"))
	Local nPosPort    := AT(":", cMailServer)
	Local cErroMail   := ""
	Local cNomeArq    := ""

	// Fallback para ambientes que usam MV_RELAUSR / MV_RELAPSW.
	If Empty(cMailConta)
		cMailConta := GetMV("MV_RELAUSR")
	EndIf
	If Empty(cMailSenha)
		cMailSenha := GetMV("MV_RELAPSW")
	EndIf

	// Se MV_RELSERV vier no formato host:porta, separa e usa a porta informada.
	If nPosPort > 0
		nPortSMTP   := Val(SubStr(cMailServer, nPosPort+1))
		cMailServer := AllTrim(SubStr(cMailServer, 1, nPosPort-1))
	EndIf

	If Empty(cArquivo) .Or. Empty(cEmail)
		Return .F.
	EndIf


	If !File(cArquivo)
		MsgAlert("Arquivo de anexo N�o encontrado: " + cArquivo)
		Return .F.
	EndIf

	oServer := TMailManager():New()
	oServer:SetUseTLS(.T.)
	oServer:SetUseSSL(.T.)

	xRet := oServer:Init( "", cMailServer, Alltrim(GetMV("MV_RELFROM")), cMailSenha,, nPortSMTP )
	        
	If xRet <> 0
		cErroMail := oServer:GetErrorString(xRet)
		MsgAlert("Falha ao inicializar SMTP: " + cValToChar(xRet) + " - " + cErroMail)
		Return .F.
	EndIf

	xRet := oServer:SetSMTPTimeout(nTimeout)
	If xRet <> 0
		// Mantém execução; timeout não costuma ser fatal.
	EndIf

	xRet := oServer:SMTPConnect()
	If xRet <> 0
		cErroMail := oServer:GetErrorString(xRet)
		MsgAlert("Falha ao conectar SMTP: " + cValToChar(xRet) + " - " + cErroMail)
		Return .F.
	EndIf

	If lMailAuth
		xRet := oServer:SmtpAuth(cMailConta,cMailSenha)
		If xRet <> 0
			cErroMail := oServer:GetErrorString(xRet)
			MsgAlert("Falha na autenticação SMTP: " + cValToChar(xRet) + " - " + cErroMail)
			oServer:SMTPDisconnect()
			Return .F.
		EndIf
	EndIf

	oMessage := TMailMessage():New()
	oMessage:Clear()

	oMessage:cDate	  := cValToChar(Date())
	oMessage:cFrom 	  := AllTrim(GetMV("MV_RELFROM",.F.,"no-reply@carvalhaes.net"))
	oMessage:cTo 	  := cEmail
	oMessage:cSubject := cAssuntoFinal
	oMessage:cBody 	  := cBodyFinal

	xRet := oMessage:AttachFile(cArquivo)
	If xRet < 0
		// Fallback de anexo somente no protheus_data\system.
		If xRet < 0 .And. !Empty(cArquivoSrv) .And. File(cArquivoSrv)
			cArquivo := cArquivoSrv
			xRet := oMessage:AttachFile(cArquivo)
		EndIf

		If xRet < 0
			// Último fallback no AppServer: pasta system do protheus_data.
			If !Empty(cNomeArq) .And. File("system\" + cNomeArq)
				cArquivo := "system\" + cNomeArq
				xRet := oMessage:AttachFile(cArquivo)
			EndIf
		EndIf

		If xRet < 0
			MsgAlert("Falha ao anexar arquivo: " + cArquivo + " | Retorno: " + cValToChar(xRet))
			oServer:SMTPDisconnect()
			Return .F.
		EndIf
	EndIf

	xRet := oMessage:Send(oServer)
	If xRet <> 0
		cErroMail := oServer:GetErrorString(xRet)
		MsgAlert("Falha ao enviar e-mail: " + cValToChar(xRet) + " - " + cErroMail)
		oServer:SMTPDisconnect()
		Return .F.
	EndIf

	oServer:SMTPDisconnect()

Return .T.

/*-------------------------------------------------------------------------------*
 | Func:  fDataBr                                                                |
 | Desc:  Converte data AAAAMMDD para DD/MM/AAAA                                |
 *-------------------------------------------------------------------------------*/
Static Function fDataBr(cData)
	Local cRet := ""

	If !Empty(cData)
		If ValType(cData) == "D"
			cRet := DToC(cData)
		Else
			cRet := DToC(SToD(cData))
		EndIf
	EndIf

Return cRet

/*-------------------------------------------------------------------------------*
 | Func:  fNumExcel                                                             |
 | Desc:  Formata numero para Excel (com ou sem prefixo R$)                     |
 *-------------------------------------------------------------------------------*/
Static Function fNumExcel(xNum, lMoeda)
	Local cRet := ""
	Local nValor := 0

	If Empty(xNum)
		Return ""
	EndIf

	If ValType(xNum) == "N"
		nValor := xNum
	Else
		nValor := Val(xNum)
	EndIf

	cRet := AllTrim(Transform(nValor, "@E 999,999,999,999,999.99"))

	If lMoeda
		cRet := "R$ " + cRet
	EndIf

Return cRet

/*-------------------------------------------------------------------------------*
 | Func:  fGetField                                                             |
 | Desc:  Retorna valor do campo se existir na workarea; caso contrario ''   |
 *-------------------------------------------------------------------------------*/
Static Function fGetField(cAlias, cCampo)
	Local nPos  := 0
	Local xRet  := ""

	If ValType(cCampo) <> "C" .Or. Len(AllTrim(cCampo)) == 0
		Return xRet
	EndIf

	// FieldPos/FieldGet dependem do cursor já aberto via DbUseArea.
	If (cAlias)->(FieldPos(cCampo)) > 0
		nPos := (cAlias)->(FieldPos(cCampo))
		xRet := (cAlias)->(FieldGet(nPos))
	EndIf

Return xRet

/*-------------------------------------------------------------------------------*
 | Func:  fDataDDMMYYYY                                                         |
 | Desc:  Retorna data no formato DDMMYYYY (ex.: 20032026)                      |
 *-------------------------------------------------------------------------------*/
Static Function fDataDDMMYYYY(dData)
	Local cRet := ""

	If ValType(dData) == "D"
		cRet := StrZero(Day(dData), 2) + StrZero(Month(dData), 2) + Str(Year(dData), 4)
	EndIf

Return cRet

/*-------------------------------------------------------------------------------*
 | Func:  fUserFromLog                                                           |
 | Desc:  Resolve nome do usuario a partir do log criptografado da SF2           |
 *-------------------------------------------------------------------------------*/
Static Function fUserFromLog(cUserLog)
	Local cRet := ""
	Local cUsr := ""
	Local cEmb := ""

	If ValType(cUserLog) <> "C"
		Return cRet
	EndIf

	// IMPORTANTE: nao aplicar AllTrim no valor criptografado antes do EMBARALHA.
	// Espacos fazem parte do conteudo esperado para decodificacao.
	If Empty(cUserLog)
		Return cRet
	EndIf

	// Mesma regra usada no X3_RELACAO dos campos virtuais F2_ZUSERI/F2_ZUSERA.
	cEmb := EMBARALHA(cUserLog, 1)
	cUsr := SubStr(cEmb, 3, 6)
	If !Empty(cUsr)
		cRet := AllTrim(USRFULLNAME(AllTrim(cUsr)))
	EndIf

Return cRet

/*-------------------------------------------------------------------------------*
 | Func:  fGetEmailsSX5                                                          |
 | Desc:  Busca e-mails na SX5010/X5_DESCRI (X5_TABELA='XY')                    |
 *-------------------------------------------------------------------------------*/
/*Static Function fGetEmailsSX5()
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local cEmails := ""
	Local cEmail  := ""

	cQuery := ""
	cQuery += " SELECT X5_DESCRI " + STR_PULA
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 (NOLOCK) " + STR_PULA
	cQuery += " WHERE SX5.D_E_L_E_T_ <> '*' " + STR_PULA
	cQuery += "   AND SX5.X5_TABELA = 'XD' " + STR_PULA
	cQuery += "   AND SX5.X5_DESCRI <> '' " + STR_PULA
	cQuery += " ORDER BY SX5.X5_CHAVE "
	cQuery := ChangeQuery(cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
	(cAlias)->(DbGoTop())

	While !(cAlias)->(Eof())
		cEmail := AllTrim((cAlias)->X5_DESCRI)
		If !Empty(cEmail)
			If !Empty(cEmails)
				cEmails += ","
			EndIf
			cEmails += cEmail
		EndIf
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

Return cEmails*/

Static Function BuscaEmail(cTabela)
	Local aRet := {}
	Local cQry := ""

	cQry += "SELECT * FROM "+RetSqlName("SX5")+" "
	cQry += " WHERE D_E_L_E_T_ = ' ' AND X5_FILIAL = '"+xFilial("SX5")+"' "
	cQry += "   AND X5_TABELA = '"+cTabela+"' AND X5_DESCRI <> ' ' "
	MpSysOpenQuery(cQry, "TMPB")

	Do While TMPB->( ! Eof())
		if IsEmail(TMPB->X5_DESCRI)
			AAdd(aRet, Lower(Alltrim(TMPB->X5_DESCRI)) )
		Endif	
		TMPB->( Dbskip())
	Enddo

	TMPB->( DbCloseArea())

Return( aRet )
