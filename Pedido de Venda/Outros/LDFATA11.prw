#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'FwBrowse.ch'

/*/
{Protheus.doc} User Function LDFATA11
(long_description)
@type  Function
@author user
@since 09/03/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function LDFATA11()

	Local cTitulo  		:= "SUGESTAO DE PESO E VOLUME"
	Local cTpFrete      := ""
	Local cTransp       := ""
	Local cTexto        := "Volume: "
	Local oColumn   	:= Nil
	Local aDadosProduto := {}
	Local nOpcao 		:= 0

	Private cRotina     := AllTrim(FunName())
	Private aProdTela  	:= {}
	Private oProduto 	:= Nil
	Private oTela     	:= Nil
	Private oPanel 		:= Nil
	Private nPesoPed    := 0
	Private nPesoTotal  := 0
	Private nVoluTotal  := 0

	oFont := TFont():New('Times New Roman',,-12,.T.)
	
	If cRotina == "MATA410" .Or. cRotina == "LDFATA12" //Pedido de vendas ou Conferência de Estoque
		cTpFrete   := Alltrim(SC5->C5_TPFRETE)
		cTransp    := AllTrim(Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"))
		nPesoPed   := SC5->C5_PBRUTO
		nVoluTotal := SC5->C5_VOLUME1
/*	Elseif cRotina == "MATA415" //Orçamento
		cTpFrete   := Alltrim(SCJ->CJ_TPFRETE)
		cTransp    := AllTrim(Posicione("SA4",1,xFilial("SA4")+SCJ->CJ_XTRANSP,"A4_NOME"))
		nPesoPed   := SCJ->CJ_XPBRUTO
		nVoluTotal := SCJ->CJ_XVOLUME*/
	EndIf
	
	//Verificando o tipo do frete
	If cTpFrete == "C"
		cTpFrete := "CIF"
	Elseif cTpFrete == "F"
		cTpFrete := "FOB"
	Elseif cTpFrete == "T"
		cTpFrete := "Por conta terceiros"
	Elseif cTpFrete == "R"
		cTpFrete := "Por conta remetente"
	Elseif cTpFrete == "D"
		cTpFrete := "Por conta destinatário"
	Elseif cTpFrete == "S"
		cTpFrete := "Sem frete"
	Endif
	// ---
	
	If cRotina == "MATA410" .Or. cRotina == "LDFATA12" 
	
		DbSelectArea("SC6")

		SC6->(DbSetOrder(1))
		
		If SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM))

			While !SC6->(Eof()) .And. (SC6->C6_FILIAL + SC6->C6_NUM == SC5->C5_FILIAL + SC5->C5_NUM)

				aDadosProduto := RetornaDadosProduto(SC6->C6_PRODUTO)
				nPesoTotal += aDadosProduto[01]
				
				aAdd(aProdTela,{SC6->C6_PRODUTO,SC6->C6_LOCAL,SC6->C6_DESCRI,SC6->C6_QTDVEN,aDadosProduto[01],aDadosProduto[02]})

				SC6->(DbSkip())

			EndDo

		Endif
	
	Elseif cRotina == "MATA415"
		
		DbSelectArea("SCK")

		SCK->(DbSetOrder(1))
		
		If SCK->(DbSeek(SCJ->CJ_FILIAL+SCJ->CJ_NUM))

			While !SCK->(Eof()) .And. (SCK->CK_FILIAL + SCK->CK_NUM == SCJ->CJ_FILIAL + SCJ->CJ_NUM)

				aDadosProduto := RetornaDadosProduto(SCK->CK_PRODUTO)
				nPesoTotal += aDadosProduto[01]
				
				aAdd(aProdTela,{SCK->CK_PRODUTO,SCK->CK_LOCAL,SCK->CK_DESCRI,SCK->CK_QTDVEN,aDadosProduto[01],aDadosProduto[02]})

				SCK->(DbSkip())

			EndDo

		Endif	
		
	Endif 	

		DEFINE DIALOG oTela TITLE cTitulo FROM 100,000 TO 500,1100 PIXEL

		oPanel := tPanel():New(00,00,,oTela,,,,,,100,45)
		
		@007,010 SAY "Peso Total: "+cValToChar(nPesoPed)      SIZE 100,020 OF oPanel FONT oFont PIXEL
		@022,010 SAY cTexto                                   SIZE 100,020 OF oPanel FONT oFont PIXEL
		@020,040 MSGET nVoluTotal PICTURE "@E 999,999,999.99" SIZE 055,011 OF oPanel FONT oFont PIXEL
		@007,150 SAY "Tipo do Frete : "+cTpFrete     	   	  SIZE 100,020 OF oPanel FONT oFont PIXEL
		@020,150 SAY "Transportadora: "+cTransp            	  SIZE 100,020 OF oPanel FONT oFont PIXEL
		
		// Botão para confirmar
		oButton := TButton():New(012,460,"Ok",oTela,{|| nOpcao := 1,oTela:End()},030,018,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		oButton:SetCss("QPushButton{" + ;
		"background-color: white;" + ;
		"background-image:url(rpo:ok.png);" + ;
		"border-style: solid;" + ;
		"border-width: 2px;" + ;
		"border-radius: 12px;" + ;
		"border-color: white;" + ;
		"padding: 6px;" + ;
		"text-align: left;" + ;
		"font: 16px arial, sans-serif;" + ;
		"color: rgb(10, 80, 201);" + ;
		"background-position: center right;" + ;
		"background-repeat: none}" + ;
		"QPushButton:hover {background-color: rgb(10, 80, 201); color: white}")
		
		oPanel:Align := CONTROL_ALIGN_TOP
		
		// Botão para Cancelar
		oButton := TButton():New(012,500,"Sair",oTela,{|| oTela:End() },030,018,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		oButton:SetCss("QPushButton{" + ;
		"background-color: white;" + ;
		"background-image:url(rpo:xclose.png);" + ;
		"border-style: solid;" + ;
		"border-width: 2px;" + ;
		"border-radius: 12px;" + ;
		"border-color: white;" + ;
		"padding: 6px;" + ;
		"text-align: left;" + ;
		"font: 16px arial, sans-serif;" + ;
		"color: rgb(10, 80, 201);" + ;
		"background-position: center right;" + ;
		"background-repeat: none}" + ;
		"QPushButton:hover {background-color: rgb(10, 80, 201); color: white}")

		DEFINE FWBROWSE oProduto DATA ARRAY ARRAY aProdTela NO CONFIG NO REPORT NO LOCATE OF oTela

		Add Column oColumn DATA { || aProdTela[oProduto:At(),1 ] } TITLE "Codigo"          SIZE 010 HEADERCLICK { || .T. } OF oProduto
		Add Column oColumn DATA { || aProdTela[oProduto:At(),2 ] } TITLE "Armazém"         SIZE 010 HEADERCLICK { || .T. } OF oProduto
		Add Column oColumn DATA { || aProdTela[oProduto:At(),3 ] } TITLE "Descrição"       SIZE 050 HEADERCLICK { || .T. } EDIT OF oProduto
		Add Column oColumn DATA { || aProdTela[oProduto:At(),4 ] } TITLE "Quantidade"      SIZE 010 PICTURE "@E 99,999,999,999" OF oProduto
		Add Column oColumn DATA { || aProdTela[oProduto:At(),5 ] } TITLE "Peso"		  	   SIZE 010 TYPE "N" PICTURE "@E 99,999,999,999.9999" HEADERCLICK { || .T. } OF oProduto
		Add Column oColumn DATA { || aProdTela[oProduto:At(),6 ] } TITLE "Especie"	       SIZE 010 HEADERCLICK { || .T. } OF oProduto

		oProduto:GetBackColor( 16777215 )
		oProduto:GetClrAlterRow( 16770250 )
		oProduto:SetLineHeight(20)
		oProduto:SetEditCell(.T.)
		oProduto:aColumns[5]:lEdit    := .T.
		oProduto:aColumns[5]:cReadVar := 'aProdTela[oProduto:At(),5]'
		oProduto:aColumns[5]:bValid   := {|| StaticCall(SugereDadosPV,AcertaPeso)}

		oProduto:Activate()

		ACTIVATE DIALOG oTela CENTERED

		If nOpcao == 1 .And. Len(aProdTela) > 0

			Processa({|| GravaDados()})

		EndIf

Return

/*/
{Protheus.doc} RetornaDadosProduto
(long_description)
@type  Function
@author user
@since 29/01/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function RetornaDadosProduto(cCodProduto)

	Local cQuerySB1	  := ""
	Local cNextAlias  := GetNextAlias()
	Local aRetSB1	  := {}

	cQuerySB1 := "SELECT B1_PESO, B1_UM FROM "+RetSqlName("SB1")+" "
	cQuerySB1 += "WHERE D_E_L_E_T_ = '' AND B1_COD = '"+cCodProduto+"' "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySB1),cNextAlias,.T.,.T.)

	DbSelectArea(cNextAlias)
	(cNextAlias)->(DbGoTop())

	While !(cNextAlias)->(EOF())

		aAdd(aRetSB1,(cNextAlias)->B1_PESO)
		aAdd(aRetSB1,(cNextAlias)->B1_UM)
		(cNextAlias)->(DbSkip())
		
	EndDo

	(cNextAlias)->(DbCloseArea())

Return(aRetSB1)

/*/
{Protheus.doc} GravaDados
(long_description)
@type  Static Function
@author user
@since 11/03/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GravaDados()

	Local aSB1Area	 		:= SB1->(GetArea())
	Local nProdTela         := Len(aProdTela)
	Local nI          		:= 0
	Local nPesoBruto        := 0

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

		For nI := 1 To nProdTela
		
			nPesoBruto += aProdTela[nI,05] * aProdTela[nI,04]

			If SB1->(MsSeek(xFilial("SB1")+ aProdTela[nI,01]))
				
				RecLock("SB1",.F.)
				SB1->B1_PESO := aProdTela[nI,05]
				SB1->(MsUnlock())

			Endif		

		Next nI
		
		If cRotina == "MATA410" .Or. cRotina == "LDFATA12"
			RecLock("SC5",.F.)
			SC5->C5_PBRUTO  := nPesoBruto
			SC5->C5_VOLUME1 := nVoluTotal
			SC5->(MsUnlock())
		/*Elseif cRotina == "MATA415"
			RecLock("SCJ",.F.)
			SCJ->CJ_XPBRUTO  := nPesoBruto
			SCJ->CJ_XVOLUME  := nVoluTotal
			SCJ->(MsUnlock())*/
		Endif	

Return

/*/
{Protheus.doc} AcertaPeso
(long_description)
@type  Static Function
@author user
@since 11/03/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AcertaPeso()

	Local nTotalTela := Len(aProdTela)
	Local nY		 := 01
	
	// -->> Recalcula o Peso Total
	nPesoTotal := 0

	For nY := 01 To nTotalTela

		nPesoTotal += aProdTela[nY,05]

	Next nY
	
	oTela:Refresh()

Return
