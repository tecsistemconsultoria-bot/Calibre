#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'FwMBrowse.ch'
#Include 'FwMVCDef.ch'
#Include 'FwBrowse.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 27/12/2024
Consultoria: Proativa
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: CVFATA13
Info: Painel de Fretes Consulta
************************************************************************/
User Function CVFATA13(lTransp)

	Local cQuery     := ""
	Local cModal     := ""
	Local cTemp      := ""
	Local cStatus    := ""
	Local cFxPeso    := ""
	Local cInfoFret  := ""
	Local nX         := 1
	Local nY         := 0
	Local nZ         := 0
	Local nFrete     := 0
	Local nPeso      := 0 
	Local nDespesas  := 0
	Local nAdValore  := 0
	Local nGrisVlr   := 0
	Local nPesoExc   := 0
	Local nAdQuim    := 0
	Local nTDA       := 0
	Local nTDE       := 0
	Local lPedVend   := IIf(AllTrim(FunName()) == "MATA410",.T.,.F.)
	Local nValMerc   := IIf(lPedVend,xPedVlr(),xOrcVlr())
	Local aProdutos  := IIf(lPedVend,xPedProd(),xOrcProd())
	Local nFator     := GetMV("XX_FTFRET",.F.,5.02) //Fator informado pelo Mateus
	Local nAliqFret  := 0.12 //Aliquota de ICMS de 12% por dentro
	Local nICMFrete  := 0
	Local lAddAdQui  := xAddAdQui(aProdutos)
	Local lPicto     := .F.
	Local lToxico    := .F.
	Local aRetorno   := {}
	Local aModuFrete := {}

	Private cNota     := ""
	Private cCliente  := IIf(lPedVend,AllTrim(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NOME")),AllTrim(Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_NOME")))
	Private cUFDest   := IIf(lPedVend,AllTrim(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")),AllTrim(Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_EST")))
	Private cMunDest  := IIf(lPedVend,AllTrim(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_COD_MUN")),AllTrim(Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_COD_MUN")))
	Private cUFOrig   := ""
	Private cMunOrig  := ""
	Private cPesoL    := "" 
	Private cPesoB    := "" 
	Private cVolume   := "" 
	Private cEspecie  := ""
	Private cTransp   := ""
	Private oDlg      := Nil
	Private oBrowse   := Nil
	Private oColumn   := Nil
	Private oPanel    := Nil
	Private oPanel2   := Nil
	Private oButton   := Nil
	Private oCampos   := Nil
	Private aFretes   := {}
	Private aVlrMenor := {}

	Default lTransp   := .F.


	If cFilAnt == "01"

		//Carregando dados da empresa logada
		xDadosEmp()
		// --- 

		For nY := 1 To Len(aProdutos)
		
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))

			If SB1->(DbSeek(xFilial("SB1")+aProdutos[nY,1]))

				nPeso += SB1->B1_PESO * aProdutos[nY,2]

				If SB1->B1_XPICTOG $ "GHS06"

					lPicto := .T.

				Endif 

				If AllTrim(SB1->B1_CRVDG06) $ "(6)|(6.1)|(6.3)|6|6.1|6.3"

					lToxico := .T.

				Endif 

			Endif 
		
		Next nY

		//Alias temporário da query de busca de fretes
		cTemp := GetNextAlias()
		// ---

		cQuery += " WITH FRETES AS ("
		cQuery += "     SELECT"
		cQuery += "         ZZJ.ZZJ_FILIAL,"
		cQuery += "         ZZJ.ZZJ_CODIGO,"
		cQuery += "         ZZK.R_E_C_N_O_ AS RECNO_ZZK,"
		cQuery += "         CASE WHEN "+cValToChar(nPeso)+" BETWEEN ZZK.ZZK_FXMIN AND ZZK.ZZK_FXMAX THEN 0 ELSE 1 END AS CLASSE,"
		cQuery += "         CASE" 
		cQuery += "             WHEN "+cValToChar(nPeso)+" BETWEEN ZZK.ZZK_FXMIN AND ZZK.ZZK_FXMAX THEN 0"
		cQuery += "             ELSE CASE" 
		cQuery += "                     WHEN ABS("+cValToChar(nPeso)+" - ZZK.ZZK_FXMIN) < ABS("+cValToChar(nPeso)+" - ZZK.ZZK_FXMAX)"
		cQuery += "                          THEN ABS("+cValToChar(nPeso)+" - ZZK.ZZK_FXMIN)"
		cQuery += "                          ELSE ABS("+cValToChar(nPeso)+" - ZZK.ZZK_FXMAX)"
		cQuery += "                  END"
		cQuery += "         END AS PESAGEM,"        
		cQuery += "         (ZZK.ZZK_FXMAX - ZZK.ZZK_FXMIN) AS LARGURA"
		cQuery += "     FROM "+RetSQLName("ZZJ")+" ZZJ"
		cQuery += "     INNER JOIN "+RetSQLName("ZZK")+" ZZK"
		cQuery += "         ON ZZK.ZZK_FILIAL = ZZJ.ZZJ_FILIAL"
		cQuery += "        AND ZZK.ZZK_CODIGO = ZZJ.ZZJ_CODIGO"
		cQuery += "        AND ZZK.ZZK_ATIVO <> '2'"
		cQuery += "        AND ZZK.D_E_L_E_T_ <> '*'"
		cQuery += "     WHERE ZZJ.ZZJ_FILIAL = '"+xFilial("ZZJ")+"'"
		cQuery += "       AND ZZJ.ZZJ_UFORI  = '"+cUFOrig+"'"
		cQuery += "       AND ZZJ.ZZJ_MUNORI = '"+cMunOrig+"'"
		cQuery += "       AND ZZJ.ZZJ_UFDEST = '"+cUFDest+"'"
		cQuery += "       AND ZZJ.ZZJ_MUNDES = '"+cMunDest+"'"
		cQuery += "       AND ZZJ.ZZJ_ATIVO <> '2'"
		cQuery += "       AND ZZJ.D_E_L_E_T_ <> '*'"
		cQuery += " ),"
		cQuery += " ESCOLHIDAS AS ("
		cQuery += "     SELECT"
		cQuery += "         C.*,"
		cQuery += "         ROW_NUMBER() OVER ("
		cQuery += "             PARTITION BY C.ZZJ_FILIAL, C.ZZJ_CODIGO"
		cQuery += "             ORDER BY" 
		cQuery += "                 C.CLASSE ASC,"      
		cQuery += "                 C.PESAGEM ASC,"   
		cQuery += "                 C.LARGURA ASC,"     
		cQuery += "                 C.RECNO_ZZK ASC"    
		cQuery += "         ) AS RN"
		cQuery += "     FROM FRETES C"
		cQuery += " )"
		cQuery += " SELECT" 
		cQuery += " 	ROUND(ZZK_PESOEX + ("+cValToChar(nValMerc)+" * ZZK_ADVALO / 100),2) AS ADVALOREM,"
		cQuery += " CASE"
		cQuery += " 	WHEN ROUND(("+cValToChar(nValMerc)+" * ZZK_GRIS) /100,2) < "+cValToChar(nFator)+" THEN ZZK_GRISVL"
		cQuery += " ELSE"
		cQuery += " 	ROUND(("+cValToChar(nValMerc)+" * ZZK_GRIS) /100,2) END GRIS,"
		cQuery += " ROUND(("+cValToChar(nValMerc)+" * ZZK_GRIS) /100,2) AS GRISCALC,"
		cQuery += " ZZK_FRPESO AS FRETE,"
		cQuery += " (ZZK_TXCOLE + ZZK_TXENTR + ZZK_COLEXC + ZZK_DESPAC + ZZK_DESPEX + ZZK_PEDAGI + ZZK_TXADM + ZZK_OUTROS) AS DESPESAS,"
		cQuery += " CASE" 
		cQuery += " 	WHEN "+cValToChar(nPeso)+" > ZZK_FXMAX THEN ("+cValToChar(nPeso)+" - ZZK_FXMAX)"
		cQuery += " ELSE"
		cQuery += " 	0 END QTDPESOEX,"
		cQuery += " CASE" 
		cQuery += " 	WHEN "+cValToChar(nPeso)+" > ZZK_FXMAX THEN ("+cValToChar(nPeso)+" - ZZK_FXMAX) * ZZK_PESOEX"
		cQuery += " ELSE"
		cQuery += " 	0 END VLRPESOEX,"	
		cQuery += "     ZZJ.*,"
		cQuery += "     ZZK.*"
		cQuery += " FROM ESCOLHIDAS E"
		cQuery += " JOIN "+RetSQLName("ZZJ")+" ZZJ"
		cQuery += "   ON ZZJ.ZZJ_FILIAL = E.ZZJ_FILIAL"
		cQuery += "  AND ZZJ.ZZJ_CODIGO = E.ZZJ_CODIGO"
		cQuery += " JOIN "+RetSQLName("ZZK")+" ZZK"
		cQuery += "   ON ZZK.R_E_C_N_O_ = E.RECNO_ZZK"
		cQuery += " WHERE E.RN = 1"
		cQuery += " ORDER BY ZZK.ZZK_FRPESO"

		//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
		If Select(cTemp) > 0
			(cTemp)->(DbCloseArea())
			cTemp := GetNextAlias()
		Endif
			
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)

		DbSelectArea(cTemp)
		
		(cTemp)->(DbGoTop())
		
		While !(cTemp)->(EOF())
			
			//Tratamento Status 
			cStatus := "2"		
			// ---
			
			//Tratamento Modal
			If (cTemp)->ZZK_MODAL == "1"		
				cModal := "Rodoviário"			
			Elseif (cTemp)->ZZK_MODAL == "2"		
				cModal := "Aéreo"			
			Elseif (cTemp)->ZZK_MODAL == "3"
				cModal := "Marítimo"			
			Elseif (cTemp)->ZZK_MODAL == "4"		
				cModal := "Ferroviário"		
			Endif 
			// ---
			
			//Faixa
			cFxPeso := AllTrim(cValToChar((cTemp)->ZZK_FXMIN))+"-"+AllTrim(cValToChar((cTemp)->ZZK_FXMAX))
			
			/********** COMPOSIÇÃO DO VALOR DO FRETE *************/
			//Advalorem
			nAdValore := (cTemp)->ADVALOREM 
			// ---
			
			//Gris
			If (cTemp)->GRIS > 0
				nGrisVlr := (cTemp)->GRIS
			Else 
				nGrisVlr := (cTemp)->GRISCALC
			Endif 
			// ---
			
			//Despesas
			nDespesas := nAdValore + nGrisVlr + (cTemp)->DESPESAS
			// --
			
			//Verifico se há peso excedente
			nPesoExc := (cTemp)->VLRPESOEX
			// ---
			
			//Adicional Químico
			If lAddAdQui
				nAdQuim := (cTemp)->ZZK_ADQUIM
			Else
				nAdQuim := 0
			Endif 
			// ---

			If lPedVend
			
				//TDA
				If Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XTDA") == "1"
					nTDA := (cTemp)->ZZK_TXTDA
				Else 
					nTDA := 0
				Endif
				// ---		
				
				//TDE
				If Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XTDE") == "1"
					nTDE := (cTemp)->ZZK_TXTDE
				Else 
					nTDE := 0
				Endif 

			Else 

				//TDA
				If Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XTDA") == "1"
					nTDA := (cTemp)->ZZK_TXTDA
				Else 
					nTDA := 0
				Endif
				// ---		
				
				//TDE
				If Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_XTDE") == "1"
					nTDE := (cTemp)->ZZK_TXTDE
				Else 
					nTDE := 0
				Endif 

			Endif 
			// ---
			
			//Frete 
			nFrete    := (cTemp)->FRETE + nDespesas + nAdQuim + nTDA + nTDE + nPesoExc 
			nICMFrete := (nFrete * nAliqFret) / (1 - nAliqFret) 
			nFrete    := nFrete + nICMFrete
			// ---		
			/****************************************************************/
			
			aAdd(aFretes,{.F.,cStatus,nFrete,(cTemp)->ZZJ_TRANSP,(cTemp)->ZZJ_NOME,cModal,(cTemp)->ZZK_FRPESO,cFxPeso,(cTemp)->ZZK_ADQUIM,(cTemp)->ZZK_PESOEX,;
			(cTemp)->ZZK_ADVALO,(cTemp)->ZZK_GRIS,(cTemp)->ZZK_TXCOLE,(cTemp)->ZZK_TXENTR,(cTemp)->ZZK_COLEXC,(cTemp)->ZZK_DESPAC,(cTemp)->ZZK_DESPEX,(cTemp)->ZZK_NOTADE,;
			(cTemp)->ZZK_TXTDA,(cTemp)->ZZK_TXTDE,(cTemp)->ZZK_PEDAGI,(cTemp)->ZZK_TXADM,(cTemp)->ZZK_TRT,(cTemp)->ZZK_OUTROS,(cTemp)->ZZK_LEAD,AllTrim((cTemp)->ZZK_CODIGO)+"|"+AllTrim((cTemp)->ZZK_ITEM)})	

			nX ++
		
			(cTemp)->(DbSkip())
		
		EndDo

		(cTemp)->(DbCloseArea())

		For nZ := 1 To Len(aFretes)

			aAdd(aVlrMenor,{aFretes[nZ,3],aFretes[nZ,4],aFretes[nZ,26]})

			If AllTrim(aFretes[nZ,4]) == "000879"
                aAdd(aModuFrete, {aFretes[nZ,3], aFretes[nZ,4], aFretes[nZ,26]})
            EndIf

		Next nZ

		aSort(aVlrMenor, , , {|x, y| x[1] < y[1]})

		//MemoWrite("C:\temp\array.txt", VarInfo("aVlrMenor", aVlrMenor,,.F.))

		For nZ := 1 To Len(aFretes)

			If aFretes[nZ,3] <= aVlrMenor[1,1]

				aFretes[nZ,2] := "1"

			Endif 

		Next nZ

		//Preenchimento direto do frete com base no mais barato
		// Preenchimento direto do frete com base na prioridade: Toxico > Picto > Menor Preço
        If lTransp

            If lToxico

				If Len(aModuFrete) > 0

					cTransp   := "000879"
					nFrete    := aModuFrete[1,1]
					cInfoFret := aModuFrete[1,3]

					MsgAlert("Devido a TOXICIDADE do produto, a transportadora foi alterada para Modular.")

				Else 

					
					cTransp   := ""
					nFrete    := 0
					cInfoFret := ""

					MsgAlert("Frete para o trajeto desejado para a transportadora Modular não consta como cadastrado! Favor cadastrar!")

				Endif 
            
            ElseIf lPicto

				If Len(aModuFrete) > 0

					cTransp   := "000879"
					nFrete    := aModuFrete[1,1]
					cInfoFret := aModuFrete[1,3]

				Else 

					cTransp   := ""
					nFrete    := 0
					cInfoFret := ""

					MsgAlert("Frete para o trajeto desejado para a transportadora Modular não consta como cadastrado! Favor cadastrar!")

				Endif 
            
            Else
                cTransp   := aVlrMenor[1,2]
                cInfoFret := aVlrMenor[1,3]
                nFrete    := aVlrMenor[1,1]
            Endif 

            aAdd(aRetorno,cTransp)
            aAdd(aRetorno,nFrete)
            aAdd(aRetorno,cInfoFret)

            Return(aRetorno)

        Endif
		// ---
		
		If Len(aFretes) == 0
			MsgAlert("Não foram encontrados fretes para a nota!","Atenção")	
		Else 
			xCriaTela()	
		Endif 

	Endif 

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/12/2024
Consultoria: Proativa
Uso: Calibre
Info: Cria tela para apresentar os fretes
*==================================================================*/
Static Function xCriaTela()

	Local aArea      := GetArea()
	Local aSize      := MsAdvSize(.F.)
	Local cTitle     := "Painel de Fretes"
	
	DEFINE MSDIALOG oDlg TITLE cTitle FROM aSize[7],000 TO aSize[6],aSize[5] PIXEL STYLE DS_MODALFRAME
	
	oPanel := TPanel():New(00,00,,oDlg,,,,,,100,100)

	@007,010 Say "Nota Fiscal:" Size 100,100 Of oPanel Pixel
	oCampos := TGet():New(008,010,{|u|IIf(PCount() == 0,cNota,cNota := u)},oDlg,010,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cNota",,,,,,,"Nota Fiscal: ",1)
	
	@007,060 Say "Cliente:" Size 100,100 Of oPanel Pixel
	oCampos := TGet():New(008,060,{|u|IIf(PCount() == 0,cCliente,cCliente := u)},oDlg,200,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCliente",,,,,,,"Cliente: ",1)

	@029,010 Say "Peso Liquido:" Size 100,100 Of oPanel Pixel
	oCampos := TGet():New(030,010,{|u|IIf(PCount() == 0,cPesoL,cPesoL := u)},oDlg,010,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cPesoL",,,,,,,"Peso Liquido: ",1)
	
	@028,060 Say "Peso Bruto:" Size 100,100 Of oPanel Pixel
	oCampos := TGet():New(030,060,{|u|IIf(PCount() == 0,cPesoB,cPesoB := u)},oDlg,010,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cPesoB",,,,,,,"Peso Bruto: ",1)

	@049,010 Say "Volume:" Size 100,100 Of oPanel Pixel
	oCampos := TGet():New(052,010,{|u|IIf(PCount() == 0,cVolume,cVolume := u)},oDlg,010,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cVolume",,,,,,,"Volume: ",1)
	
	@049,060 Say "Especie:" Size 100,100 Of oPanel Pixel
	oCampos := TGet():New(052,060,{|u|IIf(PCount() == 0,cEspecie,cEspecie := u)},oDlg,010,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cEspecie",,,,,,,"Especie: ",1)

	oCampos:SetCss("QLineEdit{" + ;
	"border-style: solid;" + ;
	"border-radius: 5px;" + ;
	"border-color: white;" + ;
	"font: 16px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-repeat: no-repeat;" + ;
	"background-attachment: fixed;" + ;
	"QPushButton:hover {background-color: rgb(10, 188, 201); color: white;" + ;
	"padding-left:25px}")
	// ---

	oPanel:Align := CONTROL_ALIGN_TOP
	
	oPanel2  := TPanel():New(00,00,,oDlg,,,,,,60,45)
	
	oButton := TButton():New(010,280,"Cancelar",oPanel2,{|| oDlg:End() },100,016,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	oButton:SetCss("QPushButton{" + ;
	"background-color: white;" + ;
	"border-style: solid;" + ;
	"border-width: 2px;" + ;
	"border-radius: 12px;" + ;
	"border-color: white;" + ;
	"padding: 6px;" + ;
	"text-align: center;" + ;
	"font: 16px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-position: center right;" + ;
	"background-repeat: none}" + ;
	"QPushButton:hover {background-color: rgb(173, 0, 0); color: red}")
	
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	
	// Define o Browse
	oBrowse := FWBrowse():New()
	oBrowse:SetDataArray()
	oBrowse:SetArray(aFretes)
	oBrowse:DisableConfig()
	oBrowse:DisableReport()
	oBrowse:SetOwner(oDlg)
	
	oColumn := oBrowse:AddLegend("aFretes[oBrowse:At(),02] == '1'","GREEN","Custo Baixo")
	oColumn := oBrowse:AddLegend("aFretes[oBrowse:At(),02] == '2'","RED","Custo Alto")

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),03]})
	oColumn:SetTitle("Valor")
	oColumn:SetType("N")
	oColumn:SetSize(020)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})		
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),04]})
	oColumn:SetTitle("Cód.Transp.")
	oColumn:SetType("C")
	oColumn:SetSize(006)
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),05]})
	oColumn:SetTitle("Transportadora")
	oColumn:SetType("C")
	oColumn:SetSize(030)
	oBrowse:SetColumns({oColumn})	
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),06]})
	oColumn:SetTitle("Modal")
	oColumn:SetType("C")
	oColumn:SetSize(010)
	oBrowse:SetColumns({oColumn})		
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),07]})
	oColumn:SetTitle("Frete Peso")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})		
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),08]})
	oColumn:SetTitle("Faixa Peso")
	oColumn:SetType("C")
	oColumn:SetSize(010)
	oBrowse:SetColumns({oColumn})	

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),09]})
	oColumn:SetTitle("Adicional Químico")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})	

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),10]})
	oColumn:SetTitle("Peso Excedente")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})	

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),11]})
	oColumn:SetTitle("Ad Valorem")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99.999")
	oBrowse:SetColumns({oColumn})		
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),12]})
	oColumn:SetTitle("Gris")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99.999")
	oBrowse:SetColumns({oColumn})	
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),13]})
	oColumn:SetTitle("Taxa Coleta")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),14]})
	oColumn:SetTitle("Taxa Entrega")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),15]})
	oColumn:SetTitle("Coleta Excedente")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),16]})
	oColumn:SetTitle("Despacho")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),17]})
	oColumn:SetTitle("Despacho Excedente")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),18]})
	oColumn:SetTitle("%Nota Despacho")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),19]})
	oColumn:SetTitle("Taxa Díficil Acesso")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),20]})
	oColumn:SetTitle("Taxa Díficil Entrega")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),21]})
	oColumn:SetTitle("Pedágio")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),22]})
	oColumn:SetTitle("Taxa ADM")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),23]})
	oColumn:SetTitle("TRT")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),25]})
	oColumn:SetTitle("Lead Time")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 999")
	oBrowse:SetColumns({oColumn})

	oColumn := FWBrwColumn():New()
	oColumn:SetData({||aFretes[oBrowse:At(),24]})
	oColumn:SetTitle("Outros Valores")
	oColumn:SetType("N")
	oColumn:SetSize(010)
	oColumn:SetPicture("@E 99,999,999,999.99")
	oBrowse:SetColumns({oColumn})

	oBrowse:GetBackColor(16777215)
	oBrowse:GetClrAlterRow(16770250)
	oBrowse:SetLineHeight(20)
	
	oBrowse:Activate()
	
	Activate MSDIALOG oDlg Centered
	
	RestArea(aArea)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/12/2024
Consultoria: Proativa
Uso: Calibre
Info: Dados da empresa logada
*==================================================================*/
Static Function xDadosEmp()

	Local aArea    := GetArea()
	Local cQuery   := ""
	Local cTemp    := GetNextAlias()

	cQuery := "SELECT * FROM SYS_COMPANY"
	cQuery += " WHERE M0_CODIGO = '"+cEmpAnt+"'"
	cQuery += " 	AND M0_CODFIL = '"+cFilAnt+"'" //Filial logada
	cQuery += "		AND D_E_L_E_T_ <> '*'"

	If Select(cTemp) > 0
    	(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()
   	Endif
	
	cQuery := ChangeQuery(cQuery)
    
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	DbSelectArea(cTemp)

	cUFOrig  := AllTrim((cTemp)->M0_ESTENT)
	cMunOrig := AllTrim((cTemp)->M0_CODMUN)

	If Len(cMunOrig) > 5
		cMunOrig := SubStr(cMunOrig,3,7)
	Endif 

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 26/02/2025
Consultoria: Proativa
Uso: Calibre
Info: Verifico se deverá adicionar o Adicional Químico no cálculo
*==================================================================*/
Static Function xAddAdQui(aProdutos)

	Local lRet := .F.
	Local nY   := 0
	
	For nY := 1 To Len(aProdutos)
	
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		If SB1->(DbSeek(xFilial("SB1")+aProdutos[nY,1]))

			If SB1->B1_CRVDG == "S" 
				lRet := .T.
			Endif 

		Endif 
	
	Next nY

Return(lRet)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/08/2025
Consultoria: Proativa
Uso: Calibre
Info: Valor total do Pedido de Vendas
*==================================================================*/
Static Function xPedVlr()

	Local nX      := 0
	Local nPosTot := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_VALOR"})
	Local nTotal  := 0
	
	For nX := 1 To Len(aCols)
	
		nTotal += aCols[nX,nPosTot]
	
	Next nX

Return(nTotal)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/08/2025
Consultoria: Proativa
Uso: Calibre
Info: Valor total do Orçamento
*==================================================================*/
Static Function xOrcVlr()

	Local aAreaSCJ  := SCJ->(GetArea())
	Local aAreaSCK  := SCK->(GetArea())
	Local aAreaTMP1 := TMP1->(GetArea())
	Local nTotal    := 0
	
	While !TMP1->(EOF())

		nTotal += TMP1->CK_VALOR

		TMP1->(DbSkip())

	EndDo

	TMP1->(DbGoTop())

	RestArea(aAreaTMP1)
	RestArea(aAreaSCK)
	RestArea(aAreaSCJ)

Return(nTotal)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/08/2025
Consultoria: Proativa
Uso: Calibre
Info: Produtos do Pedido de Vendas
*==================================================================*/
Static Function xPedProd()

	Local nX       := 0
	Local nPosProd := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	Local nPosQtde := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	Local aProds   := {}
	
	For nX := 1 To Len(aCols)
	
		aAdd(aProds,{aCols[nX,nPosProd],aCols[nX,nPosQtde]})
	
	Next nX

Return(aProds)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/08/2025
Consultoria: Proativa
Uso: Calibre
Info: Produtos do Orçamento
*==================================================================*/
Static Function xOrcProd()

	Local aAreaSCJ  := SCJ->(GetArea())
	Local aAreaSCK  := SCK->(GetArea())
	Local aAreaTMP1 := TMP1->(GetArea())
	Local aProds    := {}
	
	While !TMP1->(EOF())

		aAdd(aProds,{TMP1->CK_PRODUTO,TMP1->CK_QTDVEN})

		TMP1->(DbSkip())

	EndDo

	TMP1->(DbGoTop())

	RestArea(aAreaTMP1)
	RestArea(aAreaSCK)
	RestArea(aAreaSCJ)

Return(aProds)
