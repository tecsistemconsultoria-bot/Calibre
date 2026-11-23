#include "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
// Fernando Pessoa - TecSistem - 11/05/2026
// Tratativa de caracteres especiais (encoding) em campos memo.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÝÝÝÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝËÝÝÝÝÝÝÑÝÝÝÝÝÝÝÝÝÝÝÝÝ»±±
±±ºPrograma  ³MT410TOK  ºAutor  ³Microsiga           º Data ³  05/05/15   º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÊÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºDesc.     ³ Ponto de entrada exeutado na rotina MATA410 - Ped. de Vendaº±±
±±º          ³ e tem objetivo de validar na confirmacaod o pedido         º±±
±±º          ³ retonando True ou False. Tem como objetivo:                º±±
±±º          ³  1)Validar na alteracao do pedido de venda se houve algum  º±±
±±º          ³    item do pedido deletado e se este item foi produto      º±±
±±º          ³    especial, somente o gerente ou superviso podem excluir  º±±
±±º          ³    o mesmo.                                                º±±
±±º          ³2) Validar na exclusao do pedido de venda se existem no     º±±
±±º          ³   pedido itens com produtos especiais e so deixar excluir  º±±
±±º          ³   se for gerente ou supervisor                             º±±
±±º          ³ Foi implementado o parametro MV_XAPRDEX para desabilitar   º±±
±±º          ³ toda esta validacao ou nao                                 º±±
±±ÌÝÝÝÝÝÝÝÝÝÝØÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝÝ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MT410TOK()
	Local _lRet := .t.
	Local _aArea := GetArea()
	Local cUser  := RetCodUsr() //Retorna o código do usuário logado
	Local CodGer := POSICIONE("SA3",1,XFILIAL("SA3")+M->C5_VEND1,"A3_GEREN")
	Local CodSup := POSICIONE("SA3",1,XFILIAL("SA3")+M->C5_VEND1,"A3_SUPER")
	Local CLTGer := POSICIONE("SA3",1,XFILIAL("SA3")+CodGer,"A3_CODUSR")
	Local CLTSup := POSICIONE("SA3",1,XFILIAL("SA3")+CodSup,"A3_CODUSR")
	Local TpFrete:=	POSICIONE("SA4",1,XFILIAL("SA4")+M->C5_TRANSP,"A4_XTIPFRE")
	Local nTransp:=	POSICIONE("SA4",1,XFILIAL("SA4")+M->C5_TRANSP,"A4_NREDUZ")
	Local pCodPro:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_PRODUTO"})
	Local pQtdOr := aScan(aHeader,{|x| Alltrim(x[2]) == "C6_XQTDOTI"})
	Local pQtdVen:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_QTDVEN"})
	Local pPedWeb:= aScan(aHeader,{|x| Alltrim(x[2]) == "C6_XPEDWEB"})
//Local pOper	  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_OPER'})
	Local pnfori  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_NFORI'})
	Local pBLQ	  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_BLQ'})
	Local pite	  := Ascan(aHeader,{|x| AllTrim(x[2]) == 'C6_ITEM'})

	// --- INICIO CUSTOMIZACAO CFOP ---
	Local pCF      := aScan(aHeader,{|x| Alltrim(x[2]) == "C6_CF"})
	Local cEstCli  := ""
	Local cEstFil  := SM0->M0_ESTCOB // UF da Filial Logada
	Local cCliBusca:= ""
	Local cLojBusca:= ""
	// --- FIM CUSTOMIZACAO CFOP ---

	Local lFrete  := GetMv("MV_XFRTPV",.T.,.F.)
	Local cProd, _xQtdOri, _QtdVen, _Resid
//Local cOper

	Local xXAPRDEX := GetMV("MV_XAPRDEX")
	Local xXLIBVC := GetMV("MV_XLIBVC")
	Local i       := 0
	Local lGrafic  := IsBlind()
	Local lOpInclui := (Type("INCLUI") == "L" .And. INCLUI)
	Local lOpAltera := (Type("ALTERA") == "L" .And. ALTERA)
	Local lExecXDt  := .F.

	// TecSistem - Fernando Pessoa 18/05/2026
	// Controle explícito de operação para não validar data de entrega em exclusão.

//Proativa - Vinicius N. de Oliveira
	Local nPosPdCli := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PEDCLI"})
	Local nX        := 0
	Local cTexto    := ""
	Local cPasta    := GetMV("XX_XARQUI",.F.,"C:\temp\")
Local cObsPed   := ""
Local cObsNovo  := ""

//Se a pasta não existir eu crio na máquina do usuário
	If !ExistDir(cPasta)
		MakeDir(cPasta)
	Endif
// ---

	Private aDados  := {}

	If Len(aCols)<=0
		Return .F.
	Endif

	If Type("M->C5_CRVOBS") == "C" .Or. Type("M->C5_CRVOBS") == "M"
		cObsPed := M->C5_CRVOBS
		If !Empty(cObsPed)
			cObsNovo := fMT410DFixMemo(cObsPed)
			If (ValType(cObsNovo) == "C" .Or. ValType(cObsNovo) == "M") .And. cObsNovo <> cObsPed
				M->C5_CRVOBS := cObsNovo
			EndIf
		EndIf
	EndIf

//CHECA SE TEM O.S E NAO PERMITE ALTERACAO
	DBSELECTAREA("SC9")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SC9")+M->C5_NUM)
	DO WHILE !EOF() .AND. SC9->C9_PEDIDO == M->C5_NUM .AND. SC9->C9_FILIAL == XFILIAL("SC9")
		IF EMPTY(SC9->C9_NFISCAL)
			IF !EMPTY(SC9->C9_ORDSEP)
				Aviso("Atencao! - Carvalhaes:MT410TOK.PRW",;
					"Pedido ["+SC9->C9_PEDIDO+"], tem Ordem de Separacao pendente. Entre em contato com a Logistica.";
					,{"Continuar"},2)
				RestArea(_aArea)
				RETURN .F.
			ENDIF
		ENDIF
		DBSELECTAREA("SC9")
		DBSKIP()
	ENDDO
    //DUPLA CHECAGEM EM ORDEM SEPARCAO
    aOS    := {} 
	DBSELECTAREA("CB8")
	DBSETORDER(2)
	DBSEEK(XFILIAL("CB8")+M->C5_NUM)
	DO WHILE !EOF() .AND. CB8->CB8_PEDIDO == M->C5_NUM .AND. CB8->CB8_FILIAL == XFILIAL("CB8")
		IF EMPTY(CB8->CB8_NOTA)
			Aviso("Atencao! - Carvalhaes:MT410TOK.PRW",;
				"Pedido ["+CB8->CB8_PEDIDO+"], tem Ordem de Separacao pendente ["+CB8->CB8_ORDSEP+"]. Entre em contato com a Logistica.";
				,{"Continuar"},2)
			RestArea(_aArea)
			RETURN .F.
		ENDIF
		If Ascan( aOS, CB8->CB8_ORDSEP ) == 0
	 	   Aadd( aOS, CB8->CB8_ORDSEP )
	    Endif			
		DBSELECTAREA("CB8")
		DBSKIP()
	ENDDO

	FOR I:=1 TO LEN(aOS)
		DBSELECTAREA("CB8")
		DBSETORDER(1)
		DBSEEK(XFILIAL("CB8")+aOS[I])
		DO WHILE !EOF() .AND. CB8->CB8_ORDSEP == aOS[I] .AND. CB8->CB8_FILIAL == XFILIAL("CB8")
			IF EMPTY(CB8->CB8_NOTA)
				MSGSTOP("OS ["+CB8->CB8_ORDSEP+"] Pedido ["+CB8->CB8_PEDIDO+"], tem itens com Ordem de Separacao pendente."+chr(13)+chr(10)+" Entre em contato com a Logistica.")
				RETURN .F.
			ENDIF
			DBSELECTAREA("CB8")
			DBSKIP()
		ENDDO
	NEXT I

	If M->C5_TIPO = "N" .and. Empty(aCols[1][pnfori])
		If empty(TpFrete)
			TpFrete := "A"
		EndIf
		If !empty(M->C5_TRANSP) .and. ;
				TpFrete <> "A" .and. ;
				M->C5_TPFRETE <> TpFrete .and. ;
				ltrim(rtrim(Funname()))<>"TMKA271"

			If M->C5_TPFRETE = "C"
				_DescTpfre	:= "CIF"
			ElseIf M->C5_TPFRETE = "F"
				_DescTpfre	:= "FOB"
			Else
				_DescTpfre	:= M->C5_TPFRETE
			EndIf

			If !lGrafic
				Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," A Transportadora "+ LTrim(Rtrim(nTransp)) + " nao pode ser utilizada para o Tipo de Frete "+;
					_DescTpfre+" , selecione uma tranportadora valida !!",{"Continuar"},2)
			Endif

			_lRet := .F.
		EndIf

// --- INICIO CUSTOMIZACAO CFOP ---
		If _lRet
			// Prioriza Cliente de Entrega. Se vazio, usa o Cliente do Pedido.
			If !Empty(M->C5_CLIENT)
				cCliBusca := M->C5_CLIENT
				cLojBusca := M->C5_LOJAENT
			Else
				cCliBusca := M->C5_CLIENTE
				cLojBusca := M->C5_LOJACLI
			EndIf

			SA1->(dbSelectArea('SA1'))
			SA1->(dbSetOrder(1)) // Filial + Cliente + Loja
			If SA1->(dbSeek( xFilial('SA1') + cCliBusca + cLojBusca ))
				cEstCli := SA1->A1_EST
			EndIf
		EndIf
		// --- FIM CUSTOMIZACAO CFOP ---

		teste := " "
		If _lRet
			For i:= 1 to len(aCols)
				cProd 		:= aCols[i][pCodPro]
				_xQtdOri	:= aCols[i][pQtdOr]
				_QtdVen		:= aCols[i][pQtdVen]
				_Resid      := aCols[i][pBlq]

				// --- INICIO CUSTOMIZACAO CFOP ---
				/*
				If !aCols[i][Len(aCols[i])] 
					If cEstCli == cEstFil .And. pCF > 0
						If Left(aCols[i][pCF], 1) == "6"
							aCols[i][pCF] := "5" + SubStr(aCols[i][pCF], 2)
						EndIf
					EndIf
				EndIf
				*/
				// --- FIM CUSTOMIZACAO CFOP ---

				If paramIXB[1] = 4
					DBSelectArea("SC6")
					DBSetOrder(1)
					DBSeek(xFilial("SC6")+M->C5_NUM+aCols[i][pITE])
					If Found()
						If ALLTRIM(_Resid)=='R' .AND. ALLTRIM(SC6->C6_BLQ)=='R'
							_Resid:=''
						Endif

						iF _xQtdOri > _QtdVen .and. _xQtdOri<>0
							iF ROUND(_QtdVen,3)== ROUND(SC6->C6_QTDVEN,3)
								_xQtdOri := _QtdVen
							Endif
						Endif

					Endif
				Endif

				teste := " "
				If _lRet .and. ltrim(rtrim(Funname()))<>"TMKA271" .and.;
						xXAPRDEX  .and. ;
						(	paramIXB[1] = 1   .or.  paramIXB[1] = 4)  .and.;
						!(cUser $ xXLIBVC)


					If Ltrim(Rtrim(cProd)) = "132751.1606"
						_nReg := 0
					EndIf

					IIF(Select("QRYGER")!= 0, QRYGER->(DbCLoseArea()), )
					cQryGer :="SELECT COUNT(*) as NUMREG   "
					cQryGer +=" FROM  "+RetSqlName("SC7")+" SC7 inner join  "+RetSqlName("SB1")+" SB1 ON SC7.C7_PRODUTO = SB1.B1_COD AND SC7.D_E_L_E_T_ = SB1.D_E_L_E_T_  "
					cQryGer +="where SC7.D_E_L_E_T_ = ' '   "
					cQryGer +="		AND SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
					cQryGer +="		AND SC7.C7_PRODUTO = '"+cProd+"'   "
					cQryGer +="		AND SB1.B1_CRVGRUP ='VC' "
					cQryGer +="		AND SC7.C7_RESIDUO <> 'S' "
					cQryGer +="		AND C7_QUANT > SC7.C7_QUJE "
					cQryGer +="		AND B1_XLINHA NOT IN  ('MC','EP','SV','GG','AM','BN','DG','F1','SG','ME','IS','MO','EQ','EM','MP','FI') "
					cQryGer := ChangeQuery(cQryGer)
					TcQuery cQryGer New Alias "QRYGER"
					QRYGER->(DbGoTop())
					_nReg	:= QRYGER->NUMREG
					QRYGER->(DbCloseArea())
					teste := " "
					DBSelectArea("SB2")
					If _nReg = 0 //Verifica se o prodiuto especial ja foi comprado
						DBSelectArea("SB2")
						DBSetOrder(1)
						DBSeek(xFilial("SB2")+cProd)
						While !Eof() .and. SB2->B2_FILIAL=xFilial("SB2") .and.;
								SB2->B2_COD	 = cProd
							_nReg += SB2->B2_QATU
							dbSelectArea("SB2")
							SB2->(dbSkip())
						EndDo
					EndIf
					teste := " "
					If _nReg > 0
						SB1->(dbSelectarea('SB1'))
						SB1->(dbSetOrder(1)) // Codigo do produto
						SB1->(dbSeek( xFilial('SB1')+cProd))
						If SB1->(Found()) .and. !(SB1->B1_XLINHA $ "MC/EP/SV/GG/AM/BN/DG/F1/SG/ME/IS/MO/EQ/EM/MP/FI" ) .and. LTRIM(RTRIM(SB1->B1_CRVGRUP))="VC"
							teste:=""
							DbSelectarea("ZB6")
							DbSetorder(1)
							DbSeek(xFilial("ZB6")+cUser)
							If !Found()
								iF M->C5_CLIENTE<>'008806' .and. M->C5_CLIENTE<>'002560'


									teste:=" "
									If !( CLTSup == cUser .or. CLTGer == cUser) .and.  Alltrim(_Resid)=='R' .and. paramIXB[1] = 4
										_lRet := .F.

										If !lGrafic
											Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " poderá ser excluído somente pela diretoria devido ser um item sob encomenda(VC) e a compra ja foi iniciada. Envie sua solicitação por e-mail para controlevendas@carvalhaes.net ",{"Continuar"},2)
										Endif

									ElseIf !((CLTSup == cUser .or. CLTGer == cUser)) .and. _xQtdOri > _QtdVen  .and. _xQtdOri <> 0
										_lRet := .F.

										If !lGrafic
											Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " poderá ser diminuido a quantidade somente pela diretoria devido ser um item sob encomenda(VC) e a compra ja foi iniciada. Envie sua solicitação por e-mail para controlevendas@carvalhaes.net ",{"Continuar"},2)
										Endif

									ElseIf paramIXB[1] = 1 .and. !(( CLTSup == cUser .or. CLTGer == cUser))
										_lRet := .F.

										If !lGrafic
											Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " poderá ser excluído somente pela diretoria devido ser um item sob encomenda(VC) e a compra ja foi iniciada. Envie sua solicitação por e-mail para controlevendas@carvalhaes.net ",{"Continuar"},2)
										Endif

									EndIf
								ENdif
							Endif
						EndIf
					EndIf
				EndIf
				iF _lRet
					SB1->(dbSelectarea('SB1'))
					SB1->(dbSetOrder(1)) // Codigo do produto
					SB1->(dbSeek( xFilial('SB1')+cProd))
					If SB1->(Found()) .and. .F. //.and. SB1->B1_XCONTR=='S'
						iF M->C5_CLIENTE=='008806'
//						_lRet := .F.
//						Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " controlado, Transferencia Filial não permitida.",{"Continuar"},2)
						Endif
						If cFilant<>'01'
//						_lRet := .F.
//						Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " controlado, Venda apenas pela Matriz.",{"Continuar"},2)
						Endif
						iF _lRet
							SA1->(dbSelectarea('SA1'))
							SA1->(dbSetOrder(1)) // Cliente
							SA1->(dbSeek( xFilial('SA1')+M->C5_CLIENTE+M->C5_LOJACLI))
							If SA1->(Found())
								If Empty(SA1->A1_XNLIAE)
									_lRet := .F.

									If !lGrafic
										Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " contém substância(s) controlada(s), cliente deve ter a autorização especial(AE) da ANVISA. Verifique se o cliente possui a autorização no link https://consultas.anvisa.gov.br/#/empresas/ e faça o preenchimento do campo N.Licen.AE no cadastro do cliente.",{"Continuar"},2)
									Endif

								Endif
							Endif
							iF !Empty(M->C5_TRANSP)
								SA4->(dbSelectarea('SA4'))
								SA4->(dbSetOrder(1)) // Transportadora
								SA4->(dbSeek( xFilial('SA4')+M->C5_TRANSP))
								If SA4->(Found())
									If Empty(SA4->A4_XNLIAE)
										_lRet := .F.

										If !lGrafic
											Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," O produto "+ LTrim(Rtrim(cProd)) + " contém substância(s) controlada(s) e a transportadora precisa ter a autorização especial(AE) da ANVISA. Verifique se a mesma possui a autorização no link https://consultas.anvisa.gov.br/#/empresas/ e faça o preenchimento do campo N.Licen.AE no cadastro da transportadora.",{"Continuar"},2)
										Endif

									Endif
								Endif
							Endif
						Endif
					Endif
				Endif
			Next
		EndIf
	EndIf
	If ltrim(rtrim(Funname()))<>"AGLPED"
		If _lRet .AND. INCLUI
			//
			//  VALIDA PEDIDO WEB DUPLICADO

			cQryTp := " SELECT C6_XPEDWEB "
			cQryTp += " FROM "+RetSqlName("SC6")+" SC6 "
			cQryTp += " WHERE SC6.D_E_L_E_T_ = ' ' "
			cQryTp +="		  AND C6_XPEDWEB<>''  "
			cQryTp +="		  AND C6_XPEDWEB =  '"+aCols[1][pPedWeb]+"'"
			cQryTp +="		  AND C6_XNUMOG =  '' "
			cQryTp +="		  AND C6_XRASTRE = '' "
			cQryTp +="		  AND C6_NUM <>  '"+M->C5_NUM+"'"
			cQryTp +=" ORDER BY C6_XPEDWEB"

			If Select("QRYTP") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
				dbSelectArea("QRYTP")
				dbCloseArea()
			Endif
			cQryTp:=ChangeQuery(cQryTp)
			TcQuery cQryTp New Alias "QRYTP"
			QRYTP->(DbGotop())
			If !EOF()
				_lRet:=.F.

				If !lGrafic
					Aviso("Atencao! - Carvalhaes:MT410TOK.PRW"," Já Existem pedidos de venda com este Pedido WEB.",{"Continuar"},2)
				Endif

			Endif
			dbSelectArea("QRYTP")
			dbCloseArea()
		EndIf
	ENDIF

//Proativa - Vinicius N. de Oliveira - Varro os dados dos itens do pedido de vendas
	For nX := 1 To Len(aCols)

		If !Empty(aCols[nX,nPosPdCli])
			xFilPedCli(aCols[nX,nPosPdCli])
		Endif

	Next nX

	If Len(aDados) > 1

		For nX := 1 To Len(aDados)

			cTexto += "Pedido Cliente: "+AllTrim(aDados[nX,1])+" / Pedido de Vendas: "+AllTrim(aDados[nX,2])+" / Item do Pedido de Vendas: "+AllTrim(aDados[nX,3]) + Chr(13) + Chr(10)

		Next nX

		If !Empty(cTexto)

			MemoWrite(cPasta+"LOGPEDCLI.txt",cTexto)
			ShellExecute("Open",cPasta+"LOGPEDCLI.txt","","",5) //Abertura da pasta local onde consta o arquivo de log de produtos

		Endif

		If !lGrafic
			_lRet := MsgYesNo("Os pedidos a seguir foram encontrados vinculados a outros pedidos de vendas conforme os detalhes no arquivo txt! Você deseja prosseguir com a operação?","AVISO")
		Else
			_lRet := .T.
		Endif

	Endif
// --- 

//Preenchimento de transportadora
	If !lGrafic
		If lFrete .And. cFilAnt == "01"

			If M->C5_TPFRETE == "C"

				aRetorno := U_CVFATA13(.T.)

				M->C5_TRANSP  := aRetorno[1]
				M->C5_ZFRETE  := aRetorno[2]
				M->C5_ZINFFRE := aRetorno[3]

			Endif

		Endif
	Endif
	// ---

// Tratativa Valor de FOB e CIF - zeramento de valor de frete
	If M->C5_TPFRETE == "C"
		//M->C5_FRETE  := 0   //zera campo 'Vl Frete FOB' - comentao por Ricardo em 31.03.26 (alinhado c/Alisson e Luciano Santos)
	ElseIf M->C5_TPFRETE == "F"
		M->C5_ZFRETE := 0   //zera campo 'Vl Frete CIF' 
		M->C5_FRETE  := 0   //zera campo 'Vl Frete FOB' - adicionado por Ricardo em 31.03.26 (alinhado c/Alisson e Luciano Santos)
	EndIf

//Chamada da validação de data para Frete CIF. 
	If _lRet .AND. M->C5_TIPO == "N" .AND. M->C5_TPFRETE == "C" .AND. (lOpInclui .Or. lOpAltera)
		// TecSistem - Fernando Pessoa 18/05/2026
		// Evita NOFUNCW quando a rotina nao estiver compilada/disponivel no RPO.
		Begin Sequence
			_lRet := custom.fat.xVldDtEntr.U_xVldDtEntr()
			lExecXDt := .T.
		Recover
		End Sequence

		If !lExecXDt .And. FindFunction("U_XVLDDTENTR")
			_lRet := U_xVldDtEntr()
			lExecXDt := .T.
		ElseIf !lExecXDt .And. FindFunction("XVLDDTENTR")
			_lRet := xVldDtEntr()
			lExecXDt := .T.
		EndIf

		If !lExecXDt
			_lRet := .F.
			If !lGrafic
				Aviso("Atencao! - Carvalhaes:MT410TOK.PRW","Rotina de validacao de data (xVldDtEntr) nao encontrada no RPO. Solicite a compilacao/publicacao do fonte xVldDtEntr.tlpp.",{"Continuar"},2)
			EndIf
		EndIf
	EndIf

	If _lRet .And. (Type("M->C5_CRVOBS") == "C" .Or. Type("M->C5_CRVOBS") == "M") .And. !Empty(M->C5_CRVOBS)
		fM4RLC()
	EndIf


	RestArea(_aArea)

Return(_lRet)

Static Function fM4RLC()
	Local cAnt := ""
	Local cNov := ""

	DbSelectArea("SC5")

	If !RecLock("SC5", .F.)
		Return
	EndIf

	If !Empty(SC5->C5_CRVOBS)
		cAnt := SC5->C5_CRVOBS
		cNov := fMT410DFixMemo(cAnt)
		If cNov <> cAnt
			SC5->C5_CRVOBS := cNov
		EndIf
	EndIf

	MsUnlock()
Return

Static Function fMT410DFixMemo(cTexto)
	Local cRet   := cTexto
	Local cTeste := ""

	cRet := StrTran(cRet, Chr(0), "")

	If !fMT410DHasBrokenChars(cRet)
		Return cRet
	EndIf

	cTeste := DecodeUTF8(cRet, "cp1252")

	If (ValType(cTeste) == "C" .Or. ValType(cTeste) == "M") .And. !Empty(cTeste) .And. cTeste <> cRet
		cRet := cTeste
	EndIf

	// Ajuste fino: alguns casos acabam com "ì" e o correto no contexto e "í".
	cRet := StrTran(cRet, Chr(236), Chr(237))

Return cRet

Static Function fMT410DHasBrokenChars(cTexto)
	Local lRet := .F.

	If Empty(cTexto)
		Return .F.
	EndIf

	lRet := (At(Chr(195), cTexto) > 0) .Or. ;
	        (At(Chr(194), cTexto) > 0) .Or. ;
	        (At(Chr(226), cTexto) > 0) .Or. ;
	        (At(Chr(239), cTexto) > 0) .Or. ;
	        (At(Chr(191), cTexto) > 0) .Or. ;
	        (At(Chr(189), cTexto) > 0)

Return lRet


User Function C6VBLQ()
	Local lRet:=.T.


Return lRet

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 03/03/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtra os pedidos dos clientes
*==================================================================*/
Static Function xFilPedCli(cPedcli)

	Local cQuery  := ""
	Local cTemp   := GetNextAlias()
	
	//Query para filtrar os registros da SCK
	cQuery := " SELECT * FROM "+RetSQLName("SC6")
	cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'" 
	cQuery += " 	AND C6_PEDCLI = '"+cPedcli+"'"
	cQuery += "		AND C6_CLI = '"+M->C5_CLIENTE+"'"
	cQuery += "		AND C6_LOJA = '"+M->C5_LOJACLI+"'"
	cQuery += " 	AND D_E_L_E_T_ = ''"

	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)

	DbSelectArea(cTemp)
	
	//Posiciono no primeiro registro da query
	(cTemp)->(DbGoTop())
	
	//Populo os dados da SCK no array
	While !(cTemp)->(EOF())
	
		aAdd(aDados,{cPedcli,(cTemp)->C6_NUM,(cTemp)->C6_ITEM})
		
		(cTemp)->(DbSkip())	
		
	EndDo
	
	(cTemp)->(DbCloseArea())
	
Return

User Function VldEntCIF()
	Local lRet := .T.
	
	// Bloqueia o campo quando for CIF
	If Type("M->C5_TPFRETE") == "C" .And. M->C5_TPFRETE == "C"
		lRet := .F.
	EndIf
	
Return lRet
