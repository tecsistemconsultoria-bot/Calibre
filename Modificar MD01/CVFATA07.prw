#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 29/04/2025
Consultoria: Proativa
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: CVFATA07
Info: Histórico do Cliente
************************************************************************/
User Function CVFATA07(cProduto,lAtalho)

	Local aArea  := GetArea()
	Local cPerg  := ""
		
	Private cDescricao := ""
	Private cUM        := ""
	Private cPrazo     := ""
	Private cTpProd    := ""
	Private cItemMRP   := ""
	Private cOrigem    := ""
	Private cPaisOrig  := ""
	Private cNCM       := ""
	Private cCAS       := ""
	Private cCodCompra := ""
	Private cDescComp  := ""
	Private cTabela    := ""
	Private cCodCli    := ""
	Private cLojCli    := ""
	Private cRisco     := ""
	Private cLimCred   := ""
	Private cCredDisp  := ""
	Private cVencCred  := ""
	Private cArmazem   := ""
	Private cLeadTime  := ""
	Private cModal     := ""
	Private cPerigoso  := ""
	Private cOrgAnue1  := ""
	Private cOrgAnue2  := ""
	Private cOrgAnue3  := ""
	Private cFornece   := ""
	Private cLojForn   := ""
	Private cTpCli     := ""
	Private cNum       := ""
	Private cTpFrete   := ""
	Private nAliqIPI   := 0
	Private nAliqICMS  := 0
	Private nPrcNet    := 0
	Private nSaldoAtu  := 0
	Private nSaldoDisp := 0
	Private nSaldoTran := 0
	Private nPOPendent := 0
	Private nEmbPenden := 0
	Private nLeadAir   := 0
	Private nLeadSea   := 0
	Private aSize      := MsAdvSize(.F.)
	Private aCabHist   := {}
	Private aItemHist  := {}
	Private aLotes     := {}
	Private aLibFat    := {}
	Private aTitulos   := {}
	Private aObs       := {}
	Private aImport    := {}
	Private dDtIni     := dDataBase
	Private dDtFim     := dDataBase
	Private lTelaFora  := .F.
	Private lVC        := .F.
	Private lChkObj    := .F.
	Private oFolder    := Nil
	Private oSay       := Nil
	Private oDlg       := Nil
	Private oMSNewGe1  := Nil
	Private oMSNewGe2  := Nil
	Private oMSNewGe3  := Nil
	Private oMSNewGe4  := Nil
	Private oMSNewGe5  := Nil
	Private oMSNewGe6  := Nil
	Private oMSNewGe7  := Nil
	Private oFonteTit  := Nil
	Private oFonteAvis := Nil
	Private oButton    := Nil
	Private oCheck     := Nil

	Default cProduto := ""
	Default lAtalho  := .F.

	If MsgYesNo("Deseja visualizar o histórico do cliente?")

		If !Empty(cProduto) 

			//Chamada da rotina quando estiver em um gatilho na linha do produto na rotina de Orçamento: U_CVFATA07(M->CJ_PRODUTO) 
			//Chamada da rotina quando estiver em um gatilho na linha do produto na rotina de Pedido de Vendas: U_CVFATA07(M->C6_PRODUTO) 

			cPerg := Padr("CVFATA07",10)

			AjustaA(cPerg)

		Elseif !lAtalho

			//Chamada da rotina quando estiver em um menu: U_CVFATA07("",.F.) 
			//Ou apenas: U_CVFATA07()

			lTelaFora := .T.
			cPerg     := Padr("CVFATA07B",10)

			AjustaB(cPerg)

		Else	

			//Chamada da rotina quando estiver em um atalho na rotina de Orçamento: U_CVFATA07("",.T.)
			//Chamada da rotina quando estiver em um atalho na rotina de Pedido de Vendas: U_CVFATA07("",.T.)

			cPerg := Padr("CVFATA07C",10)

			AjustaC(cPerg)

		Endif 

		If Pergunte(cPerg,.T.)

			//Definindo valores conforme parâmetros
			dDtIni := mv_par01
			dDtFim := mv_par02

			If Empty(cProduto) .And. lTelaFora

				cProduto := mv_par03
				cCodCli  := mv_par04
				cLojCli  := mv_par05

			Elseif Empty(cProduto) .And. lAtalho

				cProduto := mv_par03

			Endif 
			// ---
		
			FWMsgRun(,{||xCriaTela(cProduto)},"Aguarde","Realizando a montagem da tela com os dados...")

		Endif 
	
	Endif 

	RestArea(aArea)

Return(cProduto)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 29/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Tela de Histórico de Clientes
*==================================================================*/ 
Static Function xCriaTela(cProduto)

	Local cTitle  := "Histórico do Cliente"
	Local nPosic  := 0
	Local lSmall  := .F.
	
	//Dados do Produto
	If !lTelaFora

		If AllTrim(FunName()) == "MATA410"
			cTabela  := M->C5_TABELA
			cCodCli  := M->C5_CLIENTE
			cLojCli  := M->C5_LOJACLI
			cTpCli   := M->C5_TIPO
			cNum     := M->C5_NUM
			cTpFrete := M->C5_TPFRETE
		Else
			cTabela  := M->CJ_TABELA
			cCodCli  := M->CJ_CLIENTE
			cLojCli  := M->CJ_LOJA
			cTpCli   := M->CJ_TIPOCLI
			cNum     := M->CJ_NUM
			cTpFrete := M->CJ_TPFRETE
		Endif 

	Else

		cTabela    := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_TABELA")
		cTpCli     := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_TIPO")
		cNum       := ""
		cTpFrete   := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_TPFRET")
		cRisco     := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_RISCO")
		cLimCred   := cValToChar(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_LC"))
	    cCredDisp  := cValToChar(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_LC"))
	    cVencCred  := AllToChar(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_VENCLC"))

	Endif 
	
	cDescricao := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"))
	cUM        := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")
	cPrazo     := cValToChar(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_PE"))
	cTpProd    := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_TIPO")
	cItemMRP   := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVGRUP")
	cOrigem    := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_ORIGEM")
	cMarca     := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_FABRIC"))  
    cPaisOrig  := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVPROC"))
	cLeadTime  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_PE")
	cModal     := IIf(AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVMART")) == 'S','Sea','Air')
	cPerigoso  := IIf(AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVDG")) == 'S','Sim','Não')
	cClasse    := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVDG05")
	cOrgAnue1  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_ORG_ANU")
	cOrgAnue2  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVORG2")
	cOrgAnue3  := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVORG3")
	cFornece   := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_PROC")
	cLojForn   := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOJPROC")
	nLeadAir   := Posicione("SA2",1,xFilial("SA2")+cFornece+cLojForn,"A2_CRVPZO")
	nLeadSea   := Posicione("SA2",1,xFilial("SA2")+cFornece+cLojForn,"A2_CRVPZM")
	nAliqIPI   := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_IPI")
	nPrcNet    := IIf(!Empty(Posicione("DA1",1,xFilial("DA1")+cTabela+cProduto,"DA1_PRCVEN")),Posicione("DA1",1,xFilial("DA1")+cTabela+cProduto,"DA1_PRCVEN"),0)
	nSaldoTran := Posicione("SB2",1,xFilial("SB2") + cProduto + "AC","B2_QATU")
	nPOPendent := 0
	nEmbPenden := 0
	cNCM       := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_POSIPI"))
	cCAS       := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVCAS"))
	cCodCompra := AllTrim(Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_XCOD"))
	cDescComp  := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_CRVDEPO"))
	cArmazem   := AllTrim(xFilial("SB2"))
    cTpFrete   := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_TPFRET")
	cRisco     := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_RISCO")
	cLimCred   := AllTrim(cValToChar(Transform(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_LC"),"@E 99,999,999,999.99")))
	cCredDisp  := AllTrim(cValToChar(Transform(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_LC") - Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_SALDUP"),"@E 99,999,999,999.99")))
	cVencCred  := AllToChar(Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojCli,"A1_VENCLC"))

	//Trativa para o tipo VC
	If AllTrim(cItemMRP) == "VC"

		lVC := .T.

	Endif 
	// ---

	//Impostos conforme a Planilha 	[Aliquota ICMS]
	MaFisIni(cCodCli,cLojCli,"C","N",cTpCli,Nil,Nil,Nil,Nil,"MATA461",Nil,Nil,Nil,Nil,Nil,Nil,Nil,{},,,cNum,cCodCli,cLojCli,0,,cTpFrete)
	MaFisAdd(cProduto,"501",1,1,0,,,0,0,0,0,0,1,0)

	nAliqICMS := MaFisRet(1,"IT_ALIQICM")

	MaFisSave()
	MaFisEnd()	
	// --- 

	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))

	If SB2->(DbSeek(xFilial("SB2") + cProduto + cArmazem))

		nSaldoAtu  := SB2->B2_QATU
		nSaldoDisp := SaldoSB2()

	Endif 
	
	//Fonte 
	oFonteTit  := TFont():New("arial",08,,,.T.,,,,.F.,.F.,.F.)
	oFonteAvis := TFont():New("arial",08,,,.T.,,,,.F.,.F.,.T.)

	//Carrega as informações da primeira aba
	FWMsgRun(, {|| aCabHist := xFilAba1(cProduto) }, 'Aguarde', 'Filtrando registros da primeira aba...')

	//Carrega as informações da segunda aba
	FWMsgRun(, {|| aImport := xFilAba2(cProduto) }, 'Aguarde', 'Filtrando registros da segunda aba...')

	Define MSDialog oDlg Title cTitle From aSize[7],000 To aSize[6],aSize[5] Pixel

	@011,004 Folder oFolder Size aSize[3] - 005, aSize[4] - 020 Of oDlg Items "Visão Geral","Importações" Pixel 

	//Visão Geral
	oSay := TSay():New(005,006,{||"*Atenção:"},oFolder:aDialogs[1],,oFonteAvis,,,,.T.,CLR_RED,,200,20)
	oSay := TSay():New(005,036,{||"Todos os dados exibidos são do local 01 (quando RS) ou 02 (quando SP)."},oFolder:aDialogs[1],,oFonteAvis,,,,.T.,,,400,20)

	oSay := TSay():New(015,006,{||"Código:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(015,033,{||AllTrim(cProduto)},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(023,006,{||"Descrição:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(023,043,{||cDescricao},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	//Botão
	oButton := TButton():New(030,006,"Desc.Comp.",oFolder:aDialogs[1],{|| xMemo(cDescComp) },105,014,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	oButton:SetCss("QPushButton{" + ;
	"background-color: white;" + ;
	"border-radius: 12px;" + ;
	"border-style: solid;" + ;
	"border-width: 2px;" + ;
	"border-color: white;" + ;
	"padding: 06px;" + ;
	"text-align: left;" + ;
	"font: 13px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-position: left right;" + ;
	"background-repeat: none}")

	oSay := TSay():New(035,215,{||"| Código de Compra:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(035,284,{||cCodCompra},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,006,{||"UM:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,020,{||cUM},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,030,{||"| Tipo:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,053,{||cTpProd},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,065,{||"| MRP Item:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,102,{||cTpProd},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,115,{||"| Preço NET (tabela):"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,180,{||AllTrim(Transform(nPrcNet,"@E 999,999,999.99"))},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,215,{||"| Origem:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,245,{||cOrigem},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,264,{||"| Marca:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,290,{||cMarca},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,006,{||"País Origem:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,050,{||cPaisOrig},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,115,{||"| Alíq.IPI:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,144,{||cValToChar(nAliqIPI)+"%"},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,160,{||"| Alíq.ICMS:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,200,{||cValToChar(nAliqICMS)+"%"},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,215,{||"| NCM:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,237,{||cNCM},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,264,{||"| CAS:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,286,{||cCAS},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,330,{||"| Prazo Entrega:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,380,{||cPrazo},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	//Saldo em Estoque
	oSay := TSay():New(006,300,{||"Saldo em Estoque"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,CLR_RED,,200,20)

	oSay := TSay():New(015,300,{||"Saldo Atual Disponível:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(015,375,{||cValToChar(nSaldoDisp)},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(023,300,{||"Saldo Atual:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(023,340,{||cValToChar(nSaldoAtu)},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	//Cálculo para padronizar os títulos de acordo com a tela
	If aSize[5] == 1526

		nPosic := 416

	Elseif aSize[5] >= 1526

		nPosic := (aSize[5] - 1526) + 225 //416

	Elseif aSize[5] < 1526

		nPosic := 415 //430 //385 
		lSmall := .T.

	Endif 
	// ---

	//Financeiro
	If !lSmall

		oSay := TSay():New(165,nPosic /*416*/,{||"Risco:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(165,nPosic + 24  /*440*/,{||cRisco},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

		oSay := TSay():New(165,nPosic + 34  /*450*/,{||"| Lim.Cred:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(165,nPosic + 74  /*490*/,{||cLimCred},oFolder:aDialogs[1],,,,,,.T.,,,400,20)
		oSay := TSay():New(165,nPosic + 110 /*540*/,{||"| Lim.Cred.Disp.:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(165,nPosic + 170 /*600*/,{||cCredDisp},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

		oSay := TSay():New(165,nPosic + 200 /*650*/,{||"| Venc.Lim.Cre.:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(165,nPosic + 260 /*710*/,{||cVencCred},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	Else 

		oSay := TSay():New(160,nPosic /*416*/,{||"Risco:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(160,nPosic + 24 /*440*/,{||cRisco},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

		oSay := TSay():New(160,nPosic + 34 /*450*/,{||"| Lim.Cred:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(160,nPosic + 74 /*490*/,{||cLimCred},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

		oSay := TSay():New(170,nPosic /*540*/,{||"Lim.Cred.Disp.:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(170,nPosic + 60 /*600*/,{||cCredDisp},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

		oSay := TSay():New(170,nPosic + 90 /*650*/,{||"| Venc.Lim.Cre.:"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,,,400,20)
		oSay := TSay():New(170,nPosic + 150 /*710*/,{||cVencCred},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	Endif 
	// ---

	//Títulos das grids
	oSay := TSay():New(056,006,{||"_________________________________________________________________________________________________________________"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,CLR_RED,,1000,20)
	oSay := TSay():New(/*064*/085,006,{||"Histórico"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,CLR_RED,,200,20)
	oSay := TSay():New(009,/*416*/nPosic,{||"Lotes Existentes"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,CLR_RED,,200,20)
	oSay := TSay():New(080,/*416*/nPosic,{||"Liberados para Faturar"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,CLR_RED,,200,20)
	oSay := TSay():New(180,/*416*/nPosic,{||"Titulos a vencer / Vencidos"},oFolder:aDialogs[1],,oFonteTit,,,,.T.,CLR_RED,,200,20)

	oCheck := TCheckBox():New(/*062*/070,115,"Mostrar todos os produtos",{|u| IIf(PCount() > 0 ,C := u,lChkObj)},oFolder:aDialogs[1],215,10,,/*bLClicked*/,,/*bValid*/,/*nClrText*/,/*nClrPane*/,,.T.)
	oCheck:bLClicked := {|| IIf(Len(aCabHist) > 0,xItens1(oMSNewGe1:aCols,oMSNewGe1:nAt,oMSNewGe1:aHeader,cProduto),)}
	
	//Montagem das grids da aba 1
	fMSNewGe1(cProduto,lSmall) //Grid Histórico [Cabeçalho]
	fMSNewGe2(lSmall) //Grid Histórico [Itens]
	fMSNewGe3(cProduto,lSmall) //Grid Lotes
 	fMSNewGe4(cProduto,cCodCli,cLojCli,lSmall) //Grid Liberados para Faturar
	fMSNewGe5(cCodCli,cLojCli,lSmall) //Grid Titulos a Vencer / Vencidos
	fMSNewGe6(lSmall) //Grid de Observações 
	// ---
	
	//Importações
	oSay := TSay():New(005,006,{||"*Atenção:"},oFolder:aDialogs[2],,oFonteAvis,,,,.T.,CLR_RED,,200,20)
	oSay := TSay():New(005,036,{||"Todos os dados exibidos são do local 01 (quando RS) ou 02 (quando SP)."},oFolder:aDialogs[2],,oFonteAvis,,,,.T.,,,400,20)

	oSay := TSay():New(015,006,{||"Código:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(015,033,{||AllTrim(cProduto)},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(023,006,{||"Descrição:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(023,043,{||cDescricao},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	//Botão
	oButton := TButton():New(030,006,"Desc.Comp.",oFolder:aDialogs[2],{|| xMemo(cDescComp) },105,014,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	oButton:SetCss("QPushButton{" + ;
	"background-color: white;" + ;
	"border-radius: 12px;" + ;
	"border-style: solid;" + ;
	"border-width: 2px;" + ;
	"border-color: white;" + ;
	"padding: 06px;" + ;
	"text-align: left;" + ;
	"font: 13px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-position: left right;" + ;
	"background-repeat: none}")

	oSay := TSay():New(035,115,{||"| Código de Compra:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(035,179,{||cCodCompra},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,006,{||"UM:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,020,{||cUM},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,030,{||"| Tipo:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,053,{||cTpProd},oFolder:aDialogs[1],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,065,{||"| MRP Item:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,102,{||cTpProd},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,115,{||"| Preço NET (tabela):"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,180,{||AllTrim(Transform(nPrcNet,"@E 999,999,999.99"))},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,215,{||"| Origem:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,245,{||cOrigem},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(045,264,{||"| Marca:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(045,290,{||cMarca},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,006,{||"País Origem:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,050,{||cPaisOrig},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,115,{||"| Alíq.IPI:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,144,{||cValToChar(nAliqIPI)+"%"},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,160,{||"| Alíq.ICMS:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,200,{||cValToChar(nAliqICMS)+"%"},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,215,{||"| NCM:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,237,{||cNCM},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,264,{||"| CAS:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,286,{||cCAS},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(055,330,{||"| Prazo Entrega:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,380,{||cPrazo},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	//Saldos
	oSay := TSay():New(006,400,{||"Saldos das Importações"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,CLR_RED,,200,20)

	oSay := TSay():New(015,400,{||"Saldo em Trânsito:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(015,465,{||IIf(!lVC,cValToChar(nSaldoTran),"---")},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(023,400,{||"POs Pendentes:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(023,455,{||IIf(!lVC,cValToChar(nPOPendent),"---")},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(031,400,{||"Embarques Pendentes:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(031,475,{||IIf(!lVC,cValToChar(nEmbPenden),"---")},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	//Dados para Importação
	oSay := TSay():New(006,/*510*/490,{||"Dados para Importação"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,CLR_RED,,200,20)

	oSay := TSay():New(015,/*510*/490,{||"Leadtime do Produto:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(015,/*585*/560,{||cLeadTime},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(023,/*510*/490,{||"Modal Transp. MRP (Air/Sea):"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(023,580,{||cModal},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(031,/*510*/490,{||"Leadtime do Fornecedor (Air):"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(031,585,{||cValToChar(nLeadAir)},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(039,/*510*/490,{||"Leadtime do Fornecedor (Sea):"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(039,585,{||cValToChar(nLeadSea)},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(047,/*510*/490,{||"Perigoso:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(047,520,{||cPerigoso},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(047,/*550*/530,{||"| Classe Risco:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(047,580,{||cClasse},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	//Anuências do Item
	oSay := TSay():New(047,/*670*/400,{||"Anuências do Item"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,CLR_RED,,200,20)

	oSay := TSay():New(055,/*670*/400,{||"Org.Anuente 1:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(055,453,{||cOrgAnue1},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(063,/*670*/400,{||"Org.Anuente 2:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(063,453,{||cOrgAnue2},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	oSay := TSay():New(071,/*670*/400,{||"Org.Anuente 3:"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,,,400,20)
	oSay := TSay():New(071,453,{||cOrgAnue3},oFolder:aDialogs[2],,,,,,.T.,,,400,20)

	//Títulos das grids
	oSay := TSay():New(080,006,{||"________________________________________________________________________________________________________________________________________________________________________________________________________________"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,CLR_RED,,1000,20)
	oSay := TSay():New(090,006,{||"Importações em Andamento"},oFolder:aDialogs[2],,oFonteTit,,,,.T.,CLR_RED,,200,20)

	//Montagem da grid da aba 2
	If !lVC
		fMSNewGe7()
	Else
		oSay := TSay():New(080,005,{||">> Por Favor, consulte o time de Comex"},oFolder:aDialogs[2],,oFonteAvis,,,,.T.,CLR_RED,,400,20)
	Endif 

	//Ativação da janela Principal
	oDlg:Activate(,,,.T.)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Cabeçalho da tela de Histórico
*==================================================================*/ 
Static Function fMSNewGe1(cProduto,lSmall)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"C5_EMISSAO","CVO_DOC","AFT_TIPO","C6_VALOR","EEC_STTDES","C5_CRVPGTO","C5_VEND1","C5_VEND2"}
	Local aAlterFields := {}
	Local nInicio      := aSize[3] - 225 //260

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))

			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""}) 
		
		Endif
		
	Next nX

	oMSNewGe1 := MsNewGetDados():New(090,005,130,IIf(lSmall,nInicio,aSize[3] - 350),GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[1],aHeaderEx,aCabHist)

	oMSNewGe1:bChange := {|| IIf(Len(aCabHist) > 0,xItens1(oMSNewGe1:aCols,oMSNewGe1:nAt,oMSNewGe1:aHeader,cProduto),)}

	//Proteção contra erros na primeira leitura
	If Len(aItemHist) == 0
		xItens1(oMSNewGe1:aCols,oMSNewGe1:nAt,oMSNewGe1:aHeader,cProduto)
	Endif 
	// ---

	//Bloqueio de adição de linha 
	oMSNewGe1:oBrowse:bAdd := {|| oMSNewGe1:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe1:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Itens da tela de Histórico
*==================================================================*/ 
Static Function fMSNewGe2(lSmall)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"CK_ITEM","CK_PRODUTO","CK_QTDVEN","CK_PRCVEN","CK_VALOR","CK_TES","CK_PEDCLI","CK_ENTREG"}
	Local aAlterFields := {}
	Local nInicio      := aSize[3] - 225 //260
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/,SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		Endif 
		
	Next nX
	
	oMSNewGe2 := MsNewGetDados():New(135,005,/*215*/180,IIf(lSmall,nInicio,aSize[3] - 350),GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[1],aHeaderEx,aItemHist)

	//Bloqueio de adição de linha 
	oMSNewGe2:oBrowse:bAdd := {|| oMSNewGe2:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe2:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Grid Lotes Existentes
*==================================================================*/ 
Static Function fMSNewGe3(cProduto,lSmall)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"B8_DTVALID","B8_LOTECTL","NPH_QTDDIS","B8_SALDO"}
	Local aAlterFields := {}
	Local nInicio      := aSize[3] - 220 //255

	//Populo o array com as informações para preencher a grid
	xLotes(cProduto)
	// ---
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		Endif 
		
	Next nX
	
	oMSNewGe3 := MsNewGetDados():New(015,IIf(lSmall,nInicio,aSize[3] - 345),080,aSize[3] - 010,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[1],aHeaderEx,aLotes)

	//Bloqueio de adição de linha 
	oMSNewGe3:oBrowse:bAdd := {|| oMSNewGe3:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe3:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Grid Liberados para Faturar
*==================================================================*/ 
Static Function fMSNewGe4(cProduto,cCodCli,cLojCli,lSmall)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"C9_CRVENT","C9_PEDIDO","C9_ITEM","C9_QTDLIB","C9_CLIENTE","C9_LOJA"}
	Local aAlterFields := {}
	Local nInicio      := aSize[3] - 220 //255

	//Populo o array com as informações para preencher a grid
	xLibFat(cProduto)
	// ---
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		Endif 
		
	Next nX
	
	oMSNewGe4 := MsNewGetDados():New(090,IIf(lSmall,nInicio,aSize[3] - 345),150,aSize[3] - 010,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[1],aHeaderEx,aLibFat)

	//Bloqueio de adição de linha 
	oMSNewGe4:oBrowse:bAdd := {|| oMSNewGe4:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe4:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Grid Títulos a Vencer / Vencidos
*==================================================================*/ 
Static Function fMSNewGe5(cCodCli,cLojCli,lSmall)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"E1_VENCTO","E1_EMISSAO","E1_NUM","E1_PARCELA","E1_VALOR"}
	Local aAlterFields := {}
	Local nInicio      := aSize[3] - 220 //255

	//Populo o array com as informações para preencher a grid
	xTitulos(cCodCli,cLojCli)
	// ---
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		Endif 
		
	Next nX
	
	oMSNewGe5 := MsNewGetDados():New(190,IIf(lSmall,nInicio,aSize[3] - 345),230,aSize[3] - 010,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[1],aHeaderEx,aTitulos)

	//Bloqueio de adição de linha 
	oMSNewGe5:oBrowse:bAdd := {|| oMSNewGe5:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe5:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Grid de Observações
*==================================================================*/ 
Static Function fMSNewGe6(lSmall)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"C5_MENNOTA","C5_CRVOBS"}
	Local aAlterFields := {}
	Local nInicio      := aSize[3] - 225 //260
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))

			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		
		Endif 
		
	Next nX
	
	oMSNewGe6 := MsNewGetDados():New(/*220*/190,005,230/*290*/,IIf(lSmall,nInicio,aSize[3] - 350),GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[1],aHeaderEx,aObs)

	//Bloqueio de adição de linha 
	oMSNewGe6:oBrowse:bAdd := {|| oMSNewGe6:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe6:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Cabeçalho Importações
*==================================================================*/  
Static Function fMSNewGe7()
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"W2_PO_DT","W3_PO_NUM","W2_NR_PRO","W2_DT_PRO","W6_DT_EMB","W1_DTENTR_","CBL_QTDEMB","W1_SALDO_Q"/*"W3_SALDO_Q"*/,"W6_HAWB","W6_DT_HAWB","W6_DI_NUM","W1_XPEDIDO"}
	Local aAlterFields := {""}
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		Endif
		
	Next nX
	
	oMSNewGe7 := MsNewGetDados():New(105,005,230,aSize[3] - 10,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue","AllwaysTrue","+Field1+Field2",aAlterFields,,999,"AllwaysTrue","","AllwaysTrue",oFolder:aDialogs[2],aHeaderEx,aImport)
	
	//Bloqueio de adição de linha 
	oMSNewGe7:oBrowse:bAdd := {|| oMSNewGe6:AddLine(.F.,.F.) }

	//Atualização do browse
	oMSNewGe7:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 02/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro dados do cabeçalho da primeira aba
*==================================================================*/  
Static Function xFilAba1(cProduto)

	Local aArea   := GetArea()
	Local aDados  := {}
	Local cQuery  := ""
	Local cStatus := ""
	Local cTemp   := GetNextAlias()
	
	cQuery := " SELECT DISTINCT" 
	cQuery += " 	CJ_FILIAL  AS FILIAL,"
	cQuery += " 	CJ_EMISSAO AS EMISSAO,"
	cQuery += " 	CJ_NUM     AS NUMERO,"
	cQuery += "		''         AS SERIE,"
	cQuery += " 	'ORC'      AS TIPO,"
	cQuery += " 	(SELECT" 
	cQuery += " 		SUM(CK_VALOR)"
	cQuery += " FROM "+RetSQLName("SCK")
	cQuery += " 	WHERE CK_FILIAL = SCJ.CJ_FILIAL"
	cQuery += " 	AND CK_NUM = SCJ.CJ_NUM"
	cQuery += "		AND CK_PRODUTO = '"+cProduto+"'"
	cQuery += " 	AND D_E_L_E_T_ <> '*') AS VLR_TOTAL,"
	cQuery += "     CJ_STATUS AS STATUS,"
	cQuery += " 	E4_DESCRI AS CONDPAG,"
	cQuery += " 	CJ_CRVVEND AS VENDINT,"
	cQuery += " 	A1_CRVVEN2 AS VENDEXT"
	cQuery += " FROM "+RetSQLName("SCJ")+" SCJ"
	cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1"
	cQuery += " 	ON A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " 	AND A1_COD = CJ_CLIENTE"
	cQuery += " 	AND A1_LOJA = CJ_LOJA"
	cQuery += " 	AND SA1.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN "+RetSQLName("SCK")+" SCK"
	cQuery += "		ON CK_FILIAL = CJ_FILIAL"
	cQuery += "		AND CK_NUM = CJ_NUM" 
	cQuery += "		AND SCK.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN "+RetSQLName("SE4")+" SE4"
	cQuery += " 	ON E4_FILIAL = ''"
	cQuery += " 	AND E4_CODIGO = CJ_CONDPAG"
	cQuery += " 	AND SE4.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE CJ_FILIAL = '"+xFilial("SCJ")+"'"
	cQuery += " 	AND CJ_CLIENTE = '"+cCodCli+"'"
	cQuery += " 	AND CJ_LOJA = '"+cLojCli+"'"
	cQuery += " 	AND CJ_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"'"
	cQuery += " 	AND CK_PRODUTO = '"+cProduto+"'"
	cQuery += " 	AND SCJ.D_E_L_E_T_ <> '*'"
	cQuery += " UNION ALL"
	cQuery += " SELECT DISTINCT" 
	cQuery += " 	C5_FILIAL  AS FILIAL,"
	cQuery += " 	C5_EMISSAO AS EMISSAO,"
	cQuery += " 	C5_NUM     AS NUMERO,"
	cQuery += "		''         AS SERIE,"
	cQuery += " 	'PV'       AS TIPO,"
	cQuery += " 	(SELECT" 
	cQuery += " 		SUM(C6_VALOR)"
	cQuery += " FROM "+RetSQLName("SC6") 
	cQuery += " 	WHERE C6_FILIAL = SC5.C5_FILIAL"
	cQuery += " 	AND C6_NUM = SC5.C5_NUM"
	cQuery += "		AND C6_PRODUTO = '"+cProduto+"'"
	cQuery += " 	AND D_E_L_E_T_ <> '*') AS VLR_TOTAL,"
	cQuery += "     ''        AS STATUS,"
	cQuery += " 	E4_DESCRI AS CONDPAG,"
	cQuery += " 	C5_VEND1 AS VENDINT,"
	cQuery += " 	C5_VEND2 AS VENDEXT"
	cQuery += " FROM "+RetSQLName("SC5")+" SC5"
	cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1"
	cQuery += " 	ON A1_FILIAL = ''"
	cQuery += " 	AND A1_COD = C5_CLIENTE"
	cQuery += " 	AND A1_LOJA = C5_LOJACLI"
	cQuery += " 	AND SA1.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN "+RetSQLName("SE4")+" SE4"
	cQuery += " 	ON E4_FILIAL = '"+xFilial("SE4")+"'"
	cQuery += " 	AND E4_CODIGO = C5_CONDPAG"
	cQuery += " 	AND SE4.D_E_L_E_T_ <> '*'"
	cQuery += "	INNER JOIN "+RetSQLName("SC6")+" SC6"
	cQuery += "		ON C6_FILIAL = C5_FILIAL"
	cQuery += "		AND C6_NUM = C5_NUM" 
	cQuery += "		AND SC6.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"
	cQuery += " 	AND C5_CLIENTE = '"+cCodCli+"'"
	cQuery += " 	AND C5_LOJACLI = '"+cLojCli+"'"
	cQuery += " 	AND C5_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"'"
	cQuery += "		AND C6_PRODUTO = '"+cProduto+"'"
	cQuery += " 	AND SC5.D_E_L_E_T_ <> '*'"
	cQuery += " UNION ALL"
	cQuery += " SELECT DISTINCT" 
	cQuery += " 	F2_FILIAL  AS FILIAL,"
	cQuery += " 	F2_EMISSAO AS EMISSAO,"
	cQuery += " 	F2_DOC     AS NUMERO,"
	cQuery += "		F2_SERIE   AS SERIE,"
	cQuery += " 	'NF'       AS TIPO,"
	cQuery += " 	(SELECT" 
	cQuery += " 		SUM(D2_TOTAL)"
	cQuery += " FROM "+RetSQLName("SD2") 
	cQuery += " 	WHERE D2_FILIAL = SF2.F2_FILIAL"
	cQuery += " 	AND D2_DOC = SF2.F2_DOC"
	cQuery += "		AND D2_SERIE = SF2.F2_SERIE"
	cQuery += "		AND D2_CLIENTE = SF2.F2_CLIENTE"
	cQuery += "		AND D2_LOJA = SF2.F2_LOJA"
	cQuery += "		AND D2_COD = '"+cProduto+"'"
	cQuery += " 	AND D_E_L_E_T_ <> '*') AS VLR_TOTAL,"
	cQuery += "     ''        AS STATUS,"
	cQuery += " 	E4_DESCRI AS CONDPAG,"
	cQuery += " 	F2_VEND1 AS VENDINT,"
	cQuery += " 	F2_VEND2 AS VENDEXT"
	cQuery += " FROM "+RetSQLName("SF2")+" SF2"
	cQuery += " INNER JOIN "+RetSQLName("SA1")+" SA1"
	cQuery += " 	ON A1_FILIAL = ''"
	cQuery += " 	AND A1_COD = F2_CLIENTE"
	cQuery += " 	AND A1_LOJA = F2_LOJA"
	cQuery += " 	AND SA1.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN "+RetSQLName("SE4")+" SE4"
	cQuery += " 	ON E4_FILIAL = '"+xFilial("SE4")+"'"
	cQuery += " 	AND E4_CODIGO = F2_COND"
	cQuery += " 	AND SE4.D_E_L_E_T_ <> '*'"
	cQuery += "	INNER JOIN "+RetSQLName("SD2")+" SD2"
	cQuery += "		ON D2_FILIAL = F2_FILIAL"
	cQuery += "		AND D2_DOC = F2_DOC" 
	cQuery += "		AND D2_SERIE = F2_SERIE"
	cQuery += "		AND D2_CLIENTE = F2_CLIENTE"
	cQuery += "		AND D2_LOJA = F2_LOJA"
	cQuery += "		AND SD2.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"
	cQuery += " 	AND F2_CLIENTE = '"+cCodCli+"'"
	cQuery += " 	AND F2_LOJA = '"+cLojCli+"'"
	cQuery += " 	AND F2_EMISSAO BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"'"
	cQuery += "		AND D2_COD = '"+cProduto+"'"
	cQuery += " 	AND SF2.D_E_L_E_T_ <> '*'"	
	cQuery += " ORDER BY EMISSAO"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())
		
		//Status
		If AllTrim((cTemp)->TIPO) == "PV"
		
			cStatus := xStatusPV((cTemp)->NUMERO)
			
		Elseif AllTrim((cTemp)->STATUS) == "A"
			
			cStatus := "Aberto"
			
		Elseif AllTrim((cTemp)->STATUS) == "B"
		
			cStatus := "Aprovado"
			
		Elseif AllTrim((cTemp)->STATUS) == "C"
		
			cStatus := "Cancelado"
			
		Elseif AllTrim((cTemp)->STATUS) == "D"
		
			cStatus := "Não Orçado"
			
		Endif 
		// ---
	
		aAdd(aDados,{SToD((cTemp)->EMISSAO),IIf((cTemp)->TIPO == "NF",AllTrim((cTemp)->NUMERO)+"-"+AllTrim((cTemp)->SERIE),(cTemp)->NUMERO),(cTemp)->TIPO,(cTemp)->VLR_TOTAL,cStatus,AllTrim((cTemp)->CONDPAG),AllTrim((cTemp)->VENDINT),AllTrim((cTemp)->VENDEXT),.F.})	
	
		(cTemp)->(DbSkip())	
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	RestArea(aArea)

Return(aDados)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 02/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro dados do cabeçalho da segunda aba
*==================================================================*/  
Static Function xFilAba2(cProduto)

	Local aArea   := GetArea()
	Local aDados  := {}
	Local cQuery  := ""
	Local cTemp   := GetNextAlias()
	
	cQuery += " SELECT DISTINCT"
	cQuery += " 	W2_PO_DT," 
	cQuery += " 	W2_PO_NUM," 
	cQuery += " 	W2_NR_PRO," 
	cQuery += " 	W2_DT_PRO,"
	cQuery += " 	("
	cQuery += " 	SELECT W6_DT_EMB AS W6_DT_EMB"
	cQuery += " 	FROM ("
	cQuery += " 	   SELECT DISTINCT TOP 1 G.R_E_C_N_O_, W6_DT_EMB"
	cQuery += " 	   FROM "+RetSQLName("SW3")+" G"
	cQuery += " 	  INNER JOIN "+RetSQLName("SW6")+" H"
	cQuery += " 		   ON W6_FILIAL = W3_FILIAL"
	cQuery += " 		   AND W6_PO_NUM = W3_PO_NUM"
	cQuery += " 		   AND H.D_E_L_E_T_ <> '*'"
	cQuery += " 	   WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += " 	       AND W3_PO_NUM = SW2.W2_PO_NUM"
	cQuery += " 		   AND W3_COD_I = '"+cProduto+"'"
	cQuery += " 		   AND W3_PGI_NUM = ''"
	cQuery += " 		   AND G.D_E_L_E_T_ <> '*'"
	cQuery += " 	) AS SUBQUERY"
	cQuery += " 	) AS W6_DT_EMB,"
	cQuery += " 	W1_DTENTR_," 
	cQuery += " 	W3_QTDE,"
	cQuery += " 	W3_SALDO_Q," 
	cQuery += " 	("
	cQuery += " 	SELECT W6_HAWB AS W6_HAWB"
	cQuery += " 	FROM ("
	cQuery += " 	   SELECT DISTINCT TOP 1 G.R_E_C_N_O_, W6_HAWB"
	cQuery += " 	   FROM "+RetSQLName("SW3")+" G"
	cQuery += " 	  INNER JOIN "+RetSQLName("SW6")+" H"
	cQuery += " 		   ON W6_FILIAL = W3_FILIAL"
	cQuery += " 		   AND W6_PO_NUM = W3_PO_NUM"
	cQuery += " 		   AND H.D_E_L_E_T_ <> '*'"
	cQuery += " 	   WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += " 	       AND W3_PO_NUM = SW2.W2_PO_NUM"
	cQuery += " 		   AND W3_COD_I = '"+cProduto+"'"
	cQuery += " 		   AND W3_PGI_NUM = ''"
	cQuery += " 		   AND G.D_E_L_E_T_ <> '*'"
	cQuery += " 	) AS SUBQUERY"
	cQuery += " 	) AS W6_HAWB,"
	cQuery += " 	("
	cQuery += " 	SELECT W6_DT_HAWB AS W6_DT_HAWB"
	cQuery += " 	FROM ("
	cQuery += " 	   SELECT DISTINCT TOP 1 G.R_E_C_N_O_, W6_DT_HAWB"
	cQuery += " 	   FROM "+RetSQLName("SW3")+" G"
	cQuery += " 	  INNER JOIN "+RetSQLName("SW6")+" H"
	cQuery += " 		   ON W6_FILIAL = W3_FILIAL"
	cQuery += " 		   AND W6_PO_NUM = W3_PO_NUM"
	cQuery += " 		   AND H.D_E_L_E_T_ <> '*'"
	cQuery += " 	   WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += " 	       AND W3_PO_NUM = SW2.W2_PO_NUM"
	cQuery += " 		   AND W3_COD_I = '"+cProduto+"'"
	cQuery += " 		   AND W3_PGI_NUM = ''"
	cQuery += " 		   AND G.D_E_L_E_T_ <> '*'"
	cQuery += " 	) AS SUBQUERY"
	cQuery += " 	) AS W6_DT_HAWB," 
	cQuery += " 	("
	cQuery += " 	SELECT W6_DI_NUM AS W6_DI_NUM"
	cQuery += " 	FROM ("
	cQuery += " 	   SELECT DISTINCT TOP 1 G.R_E_C_N_O_, W6_DI_NUM"
	cQuery += " 	   FROM "+RetSQLName("SW3")+" G"
	cQuery += " 	  INNER JOIN "+RetSQLName("SW6")+" H"
	cQuery += " 		   ON W6_FILIAL = W3_FILIAL"
	cQuery += " 		   AND W6_PO_NUM = W3_PO_NUM"
	cQuery += " 		   AND H.D_E_L_E_T_ <> '*'"
	cQuery += " 	   WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += " 	       AND W3_PO_NUM = SW2.W2_PO_NUM"
	cQuery += " 		   AND W3_COD_I = '"+cProduto+"'"
	cQuery += " 		   AND W3_PGI_NUM = ''"
	cQuery += " 		   AND G.D_E_L_E_T_ <> '*'"
	cQuery += " 	) AS SUBQUERY"
	cQuery += " 	) AS W6_DI_NUM,"
	cQuery += " 	W1_XPEDIDO"
	cQuery += " FROM "+RetSQLName("SW2")+" SW2"
	cQuery += " INNER JOIN "+RetSQLName("SW3")+" SW3"
	cQuery += " 	ON W2_FILIAL = W3_FILIAL"
	cQuery += " 	AND W2_PO_NUM = W3_PO_NUM"
	cQuery += " 	AND SW2.D_E_L_E_T_ <> '*'"
	cQuery += " INNER JOIN "+RetSQLName("SW1")+" SW1"
	cQuery += " 	ON W1_FILIAL = W3_FILIAL"
	cQuery += " 	AND W1_PO_NUM = W3_PO_NUM"
	cQuery += " 	AND W1_COD_I = W3_COD_I"
	cQuery += " 	AND SW1.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE W3_FILIAL = '"+xFilial("SW3")+"'"
	cQuery += " 	AND W3_COD_I = '"+cProduto+"'"
	cQuery += "     AND W2_PO_DT BETWEEN '"+DToS(dDtIni)+"' AND '"+DToS(dDtFim)+"'"
	cQuery += " 	AND SW2.D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY W2_PO_DT"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())
	
		aAdd(aDados,{SToD((cTemp)->W2_PO_DT),(cTemp)->W2_PO_NUM,(cTemp)->W2_NR_PRO,SToD((cTemp)->W2_DT_PRO),SToD((cTemp)->W6_DT_EMB),SToD((cTemp)->W1_DTENTR_),(cTemp)->W3_QTDE,(cTemp)->W3_SALDO_Q,(cTemp)->W6_HAWB,SToD((cTemp)->W6_DT_HAWB),(cTemp)->W6_DI_NUM,(cTemp)->W1_XPEDIDO,.F.})	
	
		(cTemp)->(DbSkip())	
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	RestArea(aArea)

Return(aDados)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 02/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Status do pedido de vendas
*==================================================================*/  
Static Function xStatusPV(cNumero)
	
	Local aArea     := GetArea()
	Local cStatus   := ""
	Local cQuery    := ""
	Local cTemp     := GetNextAlias()
	Local lFaturado := .T.
	Local lFaturar  := .F.
	
	cQuery := " SELECT * FROM "+RetSQLName("SC5")+" SC5"
	cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6"
	cQuery += " 	ON C6_FILIAL = C5_FILIAL"
	cQuery += "		AND C6_NUM = C5_NUM"
	cQuery += "		AND C6_CLI = C5_CLIENTE"
	cQuery += " 	AND C6_LOJA = C5_LOJACLI"
	cQuery += "		AND SC6.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"
	cQuery += "		AND C5_NUM = '"+cNumero+"'"
	cQuery += "		AND C5_NOTA = ''"
	cQuery += "		AND C6_NOTA = ''"
	cQuery += "		AND SC5.D_E_L_E_T_ <> '*'"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())
	
		lFaturado := .F.
	
		(cTemp)->(DbSkip())	
	
	EndDo

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	If !lFaturado
	
		lFaturar := IIf(!Empty(Posicione("SC9",3,xFilial("SC9")+cNumero,"C9_PEDIDO")),.T.,.F.)
			
		If lFaturar

			If xBlqSC9(cNumero)
				cStatus := "Liberado para Faturamento"
			Else 
				cStatus := "Pedido com Bloqueio"
			Endif 

		Elseif (cTemp)->C6_BLQ == "R"
			cStatus := "Resíduo Eliminado"			
		Elseif !Empty((cTemp)->C5_BLQPAG) .Or. !Empty((cTemp)->C5_BLQFRT) .Or. !Empty((cTemp)->C5_BLQTRAN) .Or. !Empty((cTemp)->C5_BLQDESC)
			cStatus := "Pedido com Bloqueio"
		Else 
			cStatus := "Pendente de Liberação"
		Endif

	Else 
		cStatus := "NF.Emitida"		
	Endif 

	(cTemp)->(DbCloseArea())	
	
	RestArea(aArea)

Return(cStatus) 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 02/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro dos itens de acordo com o registro posicionado
*==================================================================*/ 
Static Function xItens1(aLinha,nLinha,aHeader,cProduto)
	
	Local nPosTipo := aScan(aHeader,{|x| AllTrim(x[2]) == "AFT_TIPO"})
	Local nPosNum  := aScan(aHeader,{|x| AllTrim(x[2]) == "CVO_DOC"})
	Local cTipo    := AllTrim(aLinha[nLinha][nPosTipo])
	Local cNumero  := AllTrim(aLinha[nLinha][nPosNum])
	Local lAtuGrid := .F.
	
	//Limpo as variáveis
	If Len(aItemHist) > 0
		oMSNewGe2:aCols := {}
		aItemHist       := {}
		lAtuGrid        := .T.
	Endif 
	// ---

	//Gravando registro do checkbox
	If oCheck:lModified .And. !lChkObj

		lChkObj := .T.

	Elseif oCheck:lModified .And. lChkObj

		lChkObj := .F.
	
	Endif
	// ---  

	If cTipo == "PV"

		//Pego informação do Pedido de Vendas
		xObs(cNumero)
		// ---
	
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		
		If SC6->(DbSeek(xFilial("SC6")+AvKey(cNumero,"C6_NUM")))

			While !SC6->(EOF()) .And. (SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6")+AvKey(cNumero,"C6_NUM"))

				If !lChkObj

					If AllTrim(cProduto) == AllTrim(SC6->C6_PRODUTO)
						aAdd(aItemHist,{AllTrim(SC6->C6_ITEM),AllTrim(SC6->C6_PRODUTO),SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR,AllTrim(SC6->C6_TES),AllTrim(SC6->C6_PEDCLI),SC6->C6_ENTREG,.F.})
					Endif 

				Else 

					aAdd(aItemHist,{AllTrim(SC6->C6_ITEM),AllTrim(SC6->C6_PRODUTO),SC6->C6_QTDVEN,SC6->C6_PRCVEN,SC6->C6_VALOR,AllTrim(SC6->C6_TES),AllTrim(SC6->C6_PEDCLI),SC6->C6_ENTREG,.F.})

				Endif 

				SC6->(DbSkip())
			
			EndDo 		
		
		Endif 		
	
	Else

		//Atualizo as grids
		If Len(aObs) > 0

			aObs := {}
			oMSNewGe6:aCols := aObs
			oMSNewGe6:Refresh()

		Endif
		
		DbSelectArea("SCK")
		SCK->(DbSetOrder(1))
		
		If SCK->(DbSeek(xFilial("SCK")+AvKey(cNumero,"CK_NUM")))

			While !SCK->(EOF()) .And. (SCK->CK_FILIAL + SCK->CK_NUM == xFilial("SCK")+AvKey(cNumero,"CK_NUM"))

				If !lChkObj
			
					If AllTrim(cProduto) == AllTrim(SCK->CK_PRODUTO)
						aAdd(aItemHist,{AllTrim(SCK->CK_ITEM),AllTrim(SCK->CK_PRODUTO),SCK->CK_QTDVEN,SCK->CK_PRCVEN,SCK->CK_VALOR,AllTrim(SCK->CK_TES),AllTrim(SCK->CK_PEDCLI),SCK->CK_ENTREG,.F.})
					Endif 

				Else

					aAdd(aItemHist,{AllTrim(SCK->CK_ITEM),AllTrim(SCK->CK_PRODUTO),SCK->CK_QTDVEN,SCK->CK_PRCVEN,SCK->CK_VALOR,AllTrim(SCK->CK_TES),AllTrim(SCK->CK_PEDCLI),SCK->CK_ENTREG,.F.})

				Endif 

				SCK->(DbSkip())
			
			EndDo 		
		
		Endif 		
	
	Endif 

	//Para evitar erros quando estiver vazio o array
	If Len(aItemHist) == 0

		aAdd(aItemHist,{"","",0,0,0,"","",SToD("  /  /    "),.F.})

	Endif
	// --- 

	//Atualizo as grids
	If lAtuGrid
		oMSNewGe2:aCols := aItemHist
		oMSNewGe2:Refresh()
	Endif 

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro os lotes do produto
*==================================================================*/
Static Function xLotes(cProduto)

	Local aArea  := GetArea()
	Local cTemp  := GetNextAlias()
	Local cQuery := ""
	
	cQuery := " SELECT * FROM "+RetSQLName("SB8") 
	cQuery += " WHERE B8_FILIAL = '"+xFilial("SB8")+"'"
	cQuery += " 	AND B8_PRODUTO = '"+cProduto+"'"
	cQuery += "		AND B8_SALDO > 0"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY B8_LOTECTL"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())

		aAdd(aLotes,{SToD((cTemp)->B8_DTVALID),(cTemp)->B8_LOTECTL,((cTemp)->B8_SALDO - (cTemp)->B8_EMPENHO),(cTemp)->B8_SALDO,.F.})

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro os produtos liberados para faturar
*==================================================================*/
Static Function xLibFat(cProduto)

	Local aArea  := GetArea()
	Local cTemp  := GetNextAlias()
	Local cQuery := ""
	
	cQuery := " SELECT * FROM "+RetSQLName("SC9") 
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery += "		AND C9_PRODUTO = '"+cProduto+"'"
	cQuery += "     AND C9_NFISCAL = ''"
	cQuery += "		AND C9_SERIENF = ''"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY C9_CRVENT"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())

		aAdd(aLibFat,{SToD((cTemp)->C9_CRVENT),(cTemp)->C9_PEDIDO,(cTemp)->C9_ITEM,(cTemp)->C9_QTDLIB,(cTemp)->C9_CLIENTE,(cTemp)->C9_LOJA,.F.})

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro os titulos em aberto no Contas a Receber
*==================================================================*/
Static Function xTitulos(cCodCli,cLojCli)

	Local aArea  := GetArea()
	Local cTemp  := GetNextAlias()
	Local cQuery := ""
	
	cQuery := " SELECT * FROM "+RetSQLName("SE1") 
	cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
	cQuery += " 	AND E1_CLIENTE = '"+cCodCli+"'"
	cQuery += "		AND E1_LOJA = '"+cLojCli+"'"
	cQuery += "		AND E1_SALDO > 0"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY E1_VENCREA"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())

		aAdd(aTitulos,{SToD((cTemp)->E1_VENCTO),SToD((cTemp)->E1_EMISSAO),(cTemp)->E1_NUM,(cTemp)->E1_PARCELA,(cTemp)->E1_VALOR,.F.})

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 09/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro os Pedidos para ver se há Bloqueios 
*==================================================================*/
Static Function xBlqSC9(cNumero)

	Local aArea   := GetArea()
	Local lBlqRet := .F.
	Local cTemp   := GetNextAlias()
	Local cQuery  := ""
	
	cQuery := " SELECT * FROM "+RetSQLName("SC9") 
	cQuery += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery += " 	AND C9_PEDIDO = '"+cNumero+"'"
	cQuery += "		AND C9_BLCRED = ''"
	cQuery += "		AND C9_BLOQUEI = ''"
	cQuery += "		AND C9_BLEST = ''"
	cQuery += "		AND C9_BLQPAG = ''"
	cQuery += "		AND C9_BLQFRT = ''"
	cQuery += "		AND C9_BLQTRAN = ''"
	cQuery += "		AND C9_BLQDESC = ''"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())

		lBlqRet := .T.

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return(lBlqRet)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro os Pedidos de Vendas para pegar as mensagens 
*==================================================================*/
Static Function xObs(cPedido)

	Local cTemp    := GetNextAlias()
	Local cQuery   := ""
	Local lAtuGrid := .F.
	
	//Limpo as variáveis
	If Len(aObs) > 0
		oMSNewGe6:aCols := {}
		aObs            := {}
		lAtuGrid        := .T.
	Endif 
	// ---

	cQuery := " SELECT"
	cQuery += " ISNULL(CAST(CAST(C5_CRVOBS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS C5_CRVOBS,"
	cQuery += " C5_MENNOTA"
	cQuery += " FROM "+RetSQLName("SC5") 
	cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"
	cQuery += " 	AND C5_NUM = '"+cPedido+"'"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())

		aAdd(aObs,{(cTemp)->C5_MENNOTA,(cTemp)->C5_CRVOBS,.F.})

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	//Atualizo as grids
	If lAtuGrid
		oMSNewGe6:aCols := aObs
		oMSNewGe6:Refresh()
	Endif 

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Memo
*==================================================================*/
Static Function xMemo(cDescComp)

	Local oDlgMemo  := Nil 
	Local oMemo     := Nil 
	Local cDescMemo := "Descrição Completa"

	Define MsDialog oDlgMemo Title cDescMemo From 000,000 TO 200,650 Pixel

	oMemo := TMultiget():New(006,006,{|u|IIf(PCount() > 0, cDescComp := u,cDescComp)},oDlgMemo,320,092,,,,,,.T.)

	//Ativação da janela Principal
	oDlgMemo:Activate(,,,.T.)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Perguntas da SX1 
*==================================================================*/
Static Function AjustaA(cPerg)

	Local aRegs := {}
	Local nI    := 0
	Local nJ    := 0
	
	aAdd(aRegs,{cPerg,"01","Emissão de?"  ,"","","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissão até?" ,"","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	
	For nI := 1 To Len(aRegs)
	
		If !SX1->(DbSeek(cPerg + aRegs[nI,2]))
		
			RecLock("SX1",.T.)
			
			For nJ := 1 To FCount()

				If nJ <= Len(aRegs[nI])
					FieldPut(nJ,aRegs[nI,nJ])
				Endif 
			
			Next nJ 
			
			SX1->(MsUnlock())
	
		Endif 
	
	Next nI

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Perguntas da SX1 
*==================================================================*/
Static Function AjustaB(cPerg)

	Local aRegs := {}
	Local nI    := 0
	Local nJ    := 0
	
	aAdd(aRegs,{cPerg,"01","Emissão de?"  ,"","","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissão até?" ,"","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Produto?"     ,"","","mv_ch3","C",30,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Cliente?"     ,"","","mv_ch4","C",06,00,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"05","Loja?"        ,"","","mv_ch5","C",02,00,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	
	For nI := 1 To Len(aRegs)
	
		If !SX1->(DbSeek(cPerg + aRegs[nI,2]))
		
			RecLock("SX1",.T.)
			
			For nJ := 1 To FCount()

				If nJ <= Len(aRegs[nI])
					FieldPut(nJ,aRegs[nI,nJ])
				Endif 
			
			Next nJ 
			
			SX1->(MsUnlock())
	
		Endif 
	
	Next nI

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Perguntas da SX1 
*==================================================================*/
Static Function AjustaC(cPerg)

	Local aRegs := {}
	Local nI    := 0
	Local nJ    := 0
	
	aAdd(aRegs,{cPerg,"01","Emissão de?"  ,"","","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissão até?" ,"","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Produto?"     ,"","","mv_ch3","C",30,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	
	For nI := 1 To Len(aRegs)
	
		If !SX1->(DbSeek(cPerg + aRegs[nI,2]))
		
			RecLock("SX1",.T.)
			
			For nJ := 1 To FCount()

				If nJ <= Len(aRegs[nI])
					FieldPut(nJ,aRegs[nI,nJ])
				Endif 
			
			Next nJ 
			
			SX1->(MsUnlock())
	
		Endif 
	
	Next nI

Return
