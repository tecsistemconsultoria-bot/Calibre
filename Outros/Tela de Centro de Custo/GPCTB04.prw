#include "protheus.ch"
#include "topconn.ch"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPCTB04   ºAutor  ³RAFAEL TRINDADE     º Data ³  11/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta detalhada de saldos de projetos                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACOM                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GPCTB04()
Local cAliasPrj := "CTT"
Private oBrw
Private cPerg := Padr("GPCTB04",10)
Private cCadastro := "Consulta detalhada de projeto"
Private cCCusto   := ""

Private bConsulta := {|| Consulta()}
Private bRelatorio := {|| MsgAlert("Falta Fonte U_GRCTB05()")}

Private aRotina := {{"Pesquisa","AxPesqui",0,1},;
{"Detalhes","eval(bConsulta)",0,2},;
{"Relatorio","eval(bRelatorio)",0,2}}

/*Private aCores := {{"Z15->Z15_SLDATU > 0 .AND. Z15->Z15_SLCATU > 0","BR_VERDE"},;
{"Z15->Z15_SLDATU < -1 .AND. Z15->Z15_SLCATU < -1", "BR_VERMELHO"},;
{"Z15->Z15_SLDATU < -1 .OR. Z15->Z15_SLCATU < -1","BR_AMARELO"}}*/

Private aCores := {{"CTT->CTT_BLOQ <> '1'","BR_VERDE"},;
{"CTT->CTT_BLOQ == '1'", "BR_VERMELHO"}}

//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)

	//Gero a pergunta
	If Pergunte(cPerg,.T.)

		cCCusto := AllTrim(mv_par01)
		
		// Verifica a existencia da pergunta
		SetKey(VK_F12,{|| Filtro(nil,.T.) })

		dbSelectArea(cAliasPrj)
		dbSetOrder(1)

		oBrw := mBrowse(06,01,22,75,cAliasPrj,,,,,,aCores,,,,{|x,y| Filtro(x,.F.)},.F.)

	Endif

Return

Static Function Consulta()
Private bDetalhe := {|| Detalhe()}
Private lDetRea := .F.
Processa(bDetalhe,'Aguarde','Consultando informações...',.t.)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Detalhe   ºAutor  ³Rafael Trindade     º Data ³  11/19/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre tela de consulta detalhada do sistema                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAADV                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure Detalhe()

//Local aAreaZ15 := Z15->(GetArea())
Local nUsado     := 0
Local cCampo     := ""
Local aStruct    := {}
Private aAdvSize := MsAdvSize(.T.)
Private aObjects := {}
Private aInfo
Private oDlgCons // Variavel da tela
Private oEnch // Enchoice do Projeto
Private oResumo // Folder do Resulmo
Private oSCs // GetDados das SCs
Private oPCs // GetDados dos PCs/AEs
Private oReqs // GetDados das Requisicoes
Private oFin // GetDados do Financeiro
Private oRea // GetDados do Realizado
Private oReaCli // GetDados do Realizado no cliente
Private oNfs // GetDados das NFs
Private oFolder // Container das Folders
private aHeader := {}
Private dDtIni := "20000101"
Private dDtFim := dtos(ddatabase+3650)
Private nRegua := 8

ProcRegua(nRegua)

aInfo := { aAdvSize[ 1 ], aAdvSize[ 2 ], aAdvSize[ 3 ], aAdvSize[ 4 ], 3, 3 }

aAdd(aObjects, { 450 , 35, .f., .f.}) // Enchoice
aAdd(aObjects, { 250, 470, .F., .F.}) // Folders    altura, largura

aPosObj := MsObjSize( aInfo, aObjects,.T.)

Define MsDialog oDlgCons Title "Consulta detalhada de Projeto" From aAdvSize[1],aAdvSize[1] TO aAdvSize[6],aAdvSize[5] PIXEL

// Cria campos do Resumo do Projeto

oEnch := MsMGet():New(/*"Z15"*/"CTT",; // Alias da enchoice
,; // Nao utilizado
2,; // Tipo de visualizacao
,; // Nao utilizado
,; // Nao utilizado
,; // Nao utilizado
{"NOUSER",/*"Z15_CUSTO"*/"CTT_CUSTO",/*"Z15_ORC"*/"CTT_VALFAT",/*"Z15_DESCC"*/"CTT_DESC01",/*"Z15_INVCLI"*/"CTT_CCLP"},; // Campos a serem exibidos
{aPosObj[1,1], aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},; // Tamanho
,;// campos que podem ser alterados
,;// Se for diferente de 1 desabilita execução de gatilhos estrangeiros.
,; // nao utilizado
,; // nao utilizado
,; // nao utilizado
oDlgCons) // Objeto aonde sera criado a enchoice

// Cria objeto folder para cada item de consulta do projeto

oFolder := TFolder():New(aPosObj[2][1],; // Top
aPosObj[2][2],; // Left
{"Resumo","SCs","PCs/AEs","NFs","Requisições","Financeiro","Contabilidade"},; // Abas
,;
oDlgCons,; // Aonde sera criado o objeto
1,; // Pasta selecionada
,;
,;
.t.,; // Controla em pixels
,;
aPosObj[2][3],; // Largura
aPosObj[2][4]) // Altura

// Posiciona no CTT
dbSelectArea("CTT")
dbSetOrder(1)
CTT->(dbSeek(xFilial("CTT")+cCCusto))

//dbSelectArea("Z15")

IncProc("Carregando Resumo das informações do sistema")
Resumo()

// Cria grid de SCs
IncProc("Carregando informações das solicitações de compras")
GetSC()

// Cria Grid de PCs
IncProc("Carregando Pedidos e Autorizações de entrega")
GetPC()

IncProc("Carregando Notas Fiscais de Entrada")
// Cria Grid de Nfs
GetNF()

// Cria Grid de Requisicoes
IncProc("Carregando Requis x C.C. do projeto")
GetReq()

IncProc("Carregando adiantamentos à fornecedores")

GetFin()

IncProc("Carregando lançamentos da contabilidade")

GetRea()

IncProc("Montando Objetos")


Activate MSDialog oDlgCons On Init EnchoiceBar(oDlgCons,{|| nOpca := 1, oDlgCons:End()},{|| nOpca := 2, oDlgCons:end()})

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Resumo    ºAutor  ³RAFAEL TRINDADE     º Data ³  11/26/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega o resumo do projeto                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Procedure Resumo()
Local aCols := {}
Local nUsado := 0
Local cCampo := ""
Local aHeader := {}
// Monta aHeader do Resumo
aHeader := {{"Item","","@!",30,0,"","","C","",""},;
{"Valor","","@!",10,0,"","","C","",""}}

aAdd(aCols,{"Limite estabelecido para o orçamento",TRANSFORM(/*CTT->CTT_ZZLMPR*/"0","@E! 999.99%")})
aAdd(aCols,{"Limite do investimento ALBEA",TRANSFORM(/*Z15->Z15_ORC-((100-CTT->CTT_ZZLMPR)/100*(Z15->Z15_ORC)*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Consolidado ALBEA",""})
aAdd(aCols,{"Saldo em SC",TRANSFORM(/*Z15->Z15_SLDSC*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo em PC/AE",TRANSFORM(/*Z15->Z15_SLDPC*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo de Reqs",TRANSFORM(/*Z15->Z15_SLDREQ*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo de Adiantamentos",TRANSFORM(/*Z15->Z15_SLDFIN*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo em Notas Fiscais",TRANSFORM(/*Z15->Z15_SLDNF*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo Realizado na Contabilidade",TRANSFORM(/*Z15->Z15_SLDREA*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo Atual",TRANSFORM(/*Z15->Z15_SLDATU*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Consolidado Cliente",""})
aAdd(aCols,{"Saldo em SC",TRANSFORM(/*Z15->Z15_SLCSC*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo em PC/AE",TRANSFORM(/*Z15->Z15_SLCPC*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo de Adiantamentos",TRANSFORM(/*Z15->Z15_SLCFIN*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo em Nota Fiscal",TRANSFORM(/*Z15->Z15_SLCNF*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo Realizado na Contabilidade",TRANSFORM(/*Z15->Z15_SLCREA*/"0","@E 999,999,999.99")})
aAdd(aCols,{"Saldo Atual Cliente",TRANSFORM(/*Z15->Z15_SLCATU*/"0","@E 999,999,999.99")})

oResumo := TCBrowse():New( 01 , 01, 500, 200,,{'Item','Valor'},{30,10},oFolder:aDialogs[1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)

oResumo:SetArray(aCols)

// Adciona colunas
oResumo:AddColumn(TCColumn():New('Item' ,{||aCols[oResumo:nAt,1]},,,,"LEFT",,.F.,.T.,,,,.F.,))
oResumo:AddColumn(TCColumn():New('Valor',{||aCols[oResumo:nAt,2]},,,,"Right",,.F.,.T.,,,,.F.,))
//@ 207, 010 BUTTON "Excel" SIZE 40,13 Pixel Of oFolder:aDialogs[1] Action DlgToExcel({ {"GETDADOS","Solicitações de Compras",aHeader,aCols}})

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetSC     ºAutor  ³RAFAEL TRINDADE     º Data ³  11/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CARREGA AS SCS DO PROJETO                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure GetSC()
Local nUsado := 0
Local cCampo := ""
Local aCols := {}
Local nTotRexam := 0, nTotCli := 0
Local aCpos := {}

If Select("TSC1") > 0
	TSC1->(dbCloseArea())
End if

aCpos := StrTokArr("C1_NUM,C1_EMISSAO,C1_ITEM,C1_PRODUTO,C1_DESCRI,"+;
"C1_UM,C1_QUANT,TOTAL,TOTREAL,VALLIQ,C1_CC,"+;
"C1_OBS",",")

BeginSql Alias "TSC1"
	column C1_EMISSAO AS DATE
	%noparser%
	SELECT C1_NUM,C1_EMISSAO,C1_ITEM,C1_PRODUTO,C1_DESCRI,
	C1_UM,(C1_QUANT-C1_QUJE) AS C1_QUANT,
	(C1_QUANT-C1_QUJE)*C1_VUNIT AS TOTAL,
	((C1_QUANT-C1_QUJE)*C1_VUNIT)*
	CASE
		WHEN C1_MOEDA != 1 THEN
			(SELECT 
			CASE                      			
				WHEN C1_MOEDA = 2 THEN M2_MOEDA2
				WHEN C1_MOEDA = 3 THEN M2_MOEDA3
				WHEN C1_MOEDA = 4 THEN M2_MOEDA4
				WHEN C1_MOEDA = 5 THEN M2_MOEDA5			
			END FROM %table:SM2% SM2 WHERE SM2.%NOTDEL% AND SM2.M2_DATA = SC1.C1_EMISSAO)
		WHEN C1_MOEDA = 0 THEN 1
		ELSE 1
	END
	 AS TOTREAL,
	 CASE
		WHEN C1_MOEDA = 1 THEN
			((C1_QUANT-C1_QUJE)*C1_VUNIT)/1.2125 // fator para calcular valor liquido
		ELSE
			(SELECT 
				CASE                      			
					WHEN C1_MOEDA = 2 THEN ((C1_QUANT-C1_QUJE)*C1_VUNIT)*M2_MOEDA2
					WHEN C1_MOEDA = 3 THEN ((C1_QUANT-C1_QUJE)*C1_VUNIT)*M2_MOEDA3
					WHEN C1_MOEDA = 4 THEN ((C1_QUANT-C1_QUJE)*C1_VUNIT)*M2_MOEDA4
					WHEN C1_MOEDA = 5 THEN ((C1_QUANT-C1_QUJE)*C1_VUNIT)*M2_MOEDA5			
				END FROM %table:SM2% SM2 WHERE SM2.%NOTDEL% AND SM2.M2_DATA = SC1.C1_EMISSAO)
	END AS VALLIQ,
	C1_EMISSAO,C1_CC,
	C1_OBS FROM %table:SC1% SC1
	WHERE
	SC1.%notdel% AND SC1.C1_FILIAL = %xFilial:SC1%
	AND SC1.C1_CC = %exp:cCCusto%
	AND SC1.C1_EMISSAO between %exp:dDtIni% AND %exp:dDtFim%
	AND SC1.C1_QUJE < SC1.C1_QUANT
	AND SC1.C1_RESIDUO = %exp:''%
	AND SC1.C1_APROV = 'L'
	AND ((SC1.C1_IMPORT = 'S' AND SC1.C1_PEDIDO = %exp:''%) OR (SC1.C1_IMPORT != 'S')) 
	ORDER BY C1_FILIAL, C1_NUM
EndSql

// Monta o aHeader

aHeader := {}

For x := 1 to Len(aCpos)
	IF AllTrim(aCpos[x]) == "TOTREAL"
   		aAdd(aHeader,{"Total R$",;
		"TOTREAL",;
		GetSx3Cache("C1_PRECO","X3_PICTURE"),;
		GetSx3Cache("C1_PRECO","X3_TAMANHO"),;
		GetSx3Cache("C1_PRECO","X3_DECIMAL"),;
		GetSx3Cache("C1_PRECO","X3_VALID"),;
		"",;
		GetSx3Cache("C1_PRECO","X3_TIPO"),;
		"",;
		""})
	ELSEIF AllTrim(aCpos[x]) == "VALLIQ"
		aAdd(aHeader,{"Val Liq R$",;
		"VALLIQ",;
		GetSx3Cache("C1_PRECO","X3_PICTURE"),;
		GetSx3Cache("C1_PRECO","X3_TAMANHO"),;
		GetSx3Cache("C1_PRECO","X3_DECIMAL"),;
		GetSx3Cache("C1_PRECO","X3_VALID"),;
		"",;
		GetSx3Cache("C1_PRECO","X3_TIPO"),;
		"",;
		""})	
	ELSE
		aAdd(aHeader,{;
			AllTrim(GetSx3Cache(aCpos[x],"X3_TITULO")),;
			aCpos[x],;
			GetSx3Cache(aCpos[x],"X3_PICTURE"),;
			GetSx3Cache(aCpos[x],"X3_TAMANHO"),;
			GetSx3Cache(aCpos[x],"X3_DECIMAL"),;
			GetSx3Cache(aCpos[x],"X3_VALID"),;
			"",;
			GetSx3Cache(aCpos[x],"X3_TIPO"),;
			"",;
			"";
		})
		IF AllTrim(aHeader[len(aHeader)][2]) == "C1_MOEDA"
			aHeader[len(aHeader)][3] := "@!"
			aHeader[len(aHeader)][4] := 4
			aHeader[len(aHeader)][5] := 0
			aHeader[len(aHeader)][6] := ""
			aHeader[len(aHeader)][8] := "C"
		ENDIF
	EndIf
Next

dbSelectArea("TSC1")
TSC1->(dbGoTop())

WHILE TSC1->(!EOF())
	aAdd(aCols,Array(len(aHeader)+1))
	For x := 1 to Len(aHeader)
		IF aHeader[x][2] == "C1_MOEDA"
			//aCols[len(aCols)][x] := GETMV("MV_SIMB"+ALLTRIM(STR(TSC1->C1_MOEDA)))
		//ELSE
			aCols[len(aCols)][x] := TSC1->&(alltrim(aHeader[x][2]))
		ENDIF
	Next
	aCols[len(aCols)][len(aHeader)+1] := .F.
	
	// Totalizadores	
	nTotCli += TSC1->VALLIQ
	
	TSC1->(DBSKIP())
END


oSCs := MsNewGetDados():New(001,001,180,500,,,,,,,50000,,,,oFolder:aDialogs[2],aHeader,aCols,,)

@ 190, 001 Say "Total ALBEA (R$)" SIZE 100,010 pixel of oFolDer:aDialogs[2]
@ 187, 040 MsGet nTotRexam SIZE 50,010 PIXEL OF oFolder:aDialogs[2] PICTURE "@E 999,999,999.99" READONLY
@ 190, 100 Say "Total Cliente (R$)" SIZE 100,010 pixel of oFolder:aDialogs[2]
@ 187, 140 MsGet nTotCli SIZE 50,010 PIXEL OF oFolder:aDialogs[2] PICTURE "@E 999,999,999.99" READONLY

@ 187, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oFolder:aDialogs[2] Action DlgToExcel({ {"GETDADOS","Solicitações de Compras",oSCs:aHeader,oScs:aCols}})
// Fim SCs


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetPC     ºAutor  ³RAFAEL TRINDADE     º Data ³  11/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CARREGA AS PCS DO PROJETO                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure GetPC()
Local nUsado := 0
Local aStruct := {}
Local aCols := {}, aCpos
Local nTotRexam := 0, nTotCli := 0
Private nTotReal := 0
// Faz a consulta no banco de dados para obter as informacoes do projeto

// SCs

// Faz a consulta no banco de dados para obter as informacoes do projeto

If Select("TSC7") > 0
	TSC7->(dbCloseArea())
End if  

aCpos := StrTokArr("C7_TIPO,C7_NUM,C7_EMISSAO,C7_FORNECE,C7_LOJA,A2_NREDUZ,"+; 
		"C7_ITEM,C7_PRODUTO,C7_DESCRI,C7_UM,C7_QUANT,C7_MOEDA,C7_PRECO,"+;
		"C7_TOTAL,TOTREAL,VALLIQ,C7_OBS,C7_CC,C7_CONTA",",")

BeginSql Alias "TSC7"
	column C7_EMISSAO AS DATE
	%noparser%
	SELECT 
		CASE
			WHEN C7_TIPO= '1' THEN 'PC'
			WHEN C7_TIPO= '2' THEN 'AE'
		END AS C7_TIPO
		, C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_MOEDA, 
		C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_UM, (C7_QUANT-C7_QUJE) AS C7_QUANT, C7_PRECO,
		C7_TOTAL, C7_OBS, C7_CC, C7_CONTA, C7_QUJE,
        CASE
 			WHEN C7_TXMOEDA > 0 THEN ((C7_QUANT-C7_QUJE)*C7_PRECO)*C7_TXMOEDA
			ELSE (C7_QUANT-C7_QUJE)*C7_PRECO
		END AS TOTREAL,
		CASE
			WHEN C7_MOEDA = 1 THEN
				((C7_QUANT-C7_QUJE)*C7_PRECO)/1.2125 // fator para calcular valor liquido
			ELSE
				CASE
		 			WHEN C7_TXMOEDA > 0 THEN ((C7_QUANT-C7_QUJE)*C7_PRECO)*C7_TXMOEDA
					ELSE ((C7_QUANT-C7_QUJE)*C7_PRECO)
				END
		END AS VALLIQ
	FROM %table:SC7% SC7
	INNER JOIN
		%table:SA2% SA2
		ON
			SA2.%notdel%
			AND SA2.A2_FILIAL = %xfilial:SA2%
			AND A2_COD = C7_FORNECE
			AND A2_LOJA = C7_LOJA
	WHERE
		SC7.%notdel% AND SC7.C7_FILIAL = %xFilial:SC7%
		AND SC7.C7_CC = cCCusto 
		AND SC7.C7_QUJE < SC7.C7_QUANT
		AND SC7.C7_RESIDUO = %exp:''%
		AND SC7.C7_EMISSAO BETWEEN %exp:dDTINI% AND %exp:dDTFIM%
EndSql

// Monta o aHeader

aHeader := {}

For x := 1 to Len(aCpos)
	nUsado++
	IF AllTrim(aCpos[x]) == "TOTREAL"
   		aAdd(aHeader,{"Total R$",;
		"TOTREAL",;
		GetSx3Cache("C7_TOTAL","X3_PICTURE"),;
		GetSx3Cache("C7_TOTAL","X3_TAMANHO"),;
		GetSx3Cache("C7_TOTAL","X3_DECIMAL"),;
		GetSx3Cache("C7_TOTAL","X3_VALID"),;
		"",;
		GetSx3Cache("C7_TOTAL","X3_TIPO"),;
		"",;
		""})
	ELSEIF AllTrim(aCpos[x]) == "VALLIQ"
		aAdd(aHeader,{"Val Liq R$",;
		"VALLIQ",;
		GetSx3Cache("C7_TOTAL","X3_PICTURE"),;
		GetSx3Cache("C7_TOTAL","X3_TAMANHO"),;
		GetSx3Cache("C7_TOTAL","X3_DECIMAL"),;
		GetSx3Cache("C7_TOTAL","X3_VALID"),;
		"",;
		GetSx3Cache("C7_TOTAL","X3_TIPO"),;
		"",;
		""})	
	ELSE
		Aadd(aHeader,{;
			AllTrim(GetSx3Cache(aCpos[x],"X3_TITULO")),;
			aCpos[x],;
			GetSx3Cache(aCpos[x],"X3_PICTURE"),;
			GetSx3Cache(aCpos[x],"X3_TAMANHO"),;
			GetSx3Cache(aCpos[x],"X3_DECIMAL"),;
			GetSx3Cache(aCpos[x],"X3_VALID"),;
			"",;
			GetSx3Cache(aCpos[x],"X3_TIPO"),;
			"",;
			"";
		})
		IF AllTrim(aHeader[len(aHeader)][2]) == "C7_TIPO"
			aHeader[len(aHeader)][3] := "@!"
			aHeader[len(aHeader)][4] := 2
			aHeader[len(aHeader)][5] := 0
			aHeader[len(aHeader)][6] := ""
			aHeader[len(aHeader)][8] := "C"			
		ENDIF
		IF AllTrim(aHeader[len(aHeader)][2]) == "C7_MOEDA"
			aHeader[len(aHeader)][3] := "@!"
			aHeader[len(aHeader)][4] := 4
			aHeader[len(aHeader)][5] := 0
			aHeader[len(aHeader)][6] := ""
			aHeader[len(aHeader)][8] := "C"
		ENDIF
  ENDIF
Next

dbSelectArea("TSC7")
TSC7->(dbGoTop())

WHILE TSC7->(!EOF())
	aAdd(aCols,Array(len(aHeader)+1))
	
	For x := 1 to Len(aHeader)
		IF aHeader[x][2] == "C7_MOEDA"
		//	aCols[len(aCols)][x] := meuGETMV("MV_SIMB"+ALLTRIM(STR(TSC7->C7_MOEDA)))
		//ELSE
			aCols[len(aCols)][x] := TSC7->&(alltrim(aHeader[x][2]))
		END IF
	Next
	
	aCols[len(aCols)][len(aHeader)+1] := .F.
	
	// Totalizadores
	nTotCli += TSC7->VALLIQ
	
	TSC7->(DBSKIP())
END

oPCs := MsNewGetDados():New(001,001,180,500,,,,,,,50000,,,,oFolder:aDialogs[3],aHeader,aCols,,)

@ 190, 001 Say "Total ALBEA (R$)" SIZE 100,010 pixel of oFolDer:aDialogs[3]
@ 187, 040 MsGet nTotRexam SIZE 50,010 PIXEL OF oFolder:aDialogs[3] PICTURE "@E 999,999,999.99" READONLY
@ 190, 100 Say "Total Cliente (R$)" SIZE 100,010 pixel of oFolder:aDialogs[3]
@ 187, 140 MsGet nTotCli SIZE 50,010 PIXEL OF oFolder:aDialogs[3] PICTURE "@E 999,999,999.99" READONLY

@ 187, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oFolder:aDialogs[3] Action DlgToExcel({ {"GETDADOS","Pedidos de Compra/AE",oPCs:aHeader,oPCs:aCols}})

// Fim PCs


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetNF     ºAutor  ³RAFAEL TRINDADE     º Data ³  11/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CARREGA AS NFS DO PROJETO                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure GetNF()
Local nUsado := 0
Local aCols := {}, aCpos
Local nTotRexam := 0, nTotCli := 0

// Faz a consulta no banco de dados para obter as informacoes do projeto

// SCs

// Faz a consulta no banco de dados para obter as informacoes do projeto

If Select("TSD1") > 0
	TSD1->(dbCloseArea())
End if

BeginSql Alias "TSD1"
	%noparser%
	SELECT DISTINCT D1_DTDIGIT ,D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, A2_NREDUZ, D1_ITEM, D1_COD, D1_DESCR, D1_QUANT, D1_VUNIT,
	(D1_TOTAL/1.2125) as D1_TOTAL, (D1_VALDEV/1.2125) AS D1_VALDEV, ((D1_TOTAL-D1_VALDEV)/1.2125) AS TOTREAL 
	FROM %table:SD1% SD1
	INNER JOIN %table:SA2% SA2
		ON SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_FILIAL = %xFilial:SA2% AND SA2.%notdel%
		AND SA2.A2_LOJA = SD1.D1_LOJA
	WHERE
		D1_CC = %exp:cCCusto%
		AND D1_DTDIGIT BETWEEN %exp:dDTINI% AND %exp:dDTFIM%
		AND SD1.%notdel%
		AND D1_FILIAL = %xFilial:SD1%
		AND D1_TES != %exp:''%
	ORDER BY D1_DTDIGIT
EndSql

aCpos := StrTokArr("D1_DTDIGIT,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,A2_NREDUZ,D1_ITEM,D1_COD,D1_DESCR,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_VALDEV",",")

// Monta o aHeader

aHeader := {}
For x := 1 to Len(aCpos)
		nUsado++
		Aadd(aHeader,{;
			AllTrim(GetSx3Cache(aCpos[x],"X3_TITULO")),;
			aCpos[x],;
			GetSx3Cache(aCpos[x],"X3_PICTURE"),;
			GetSx3Cache(aCpos[x],"X3_TAMANHO"),;
			GetSx3Cache(aCpos[x],"X3_DECIMAL"),;
			GetSx3Cache(aCpos[x],"X3_VALID"),;
			"",;
			GetSx3Cache(aCpos[x],"X3_TIPO"),;
			"",;
			"";
		})
		IF GetSX3Cache(aCpos[x],"X3_TIPO") == "D"
			TCSETFIELD("TSD1",aCpos[x],"D")
		END IF
End

// Adiciona o campo calculado do SQL que não estará no dicionário
Aadd(aHeader,;
	{"Valor Real",;
	"TOTREAL",;
	"@E 9,999,999.9999",;
	14,;
	4,;
	"",; // Validação
	"",;
	"N",;
	"",;
	"" })


dbSelectArea("TSD1")
TSD1->(dbGoTop())

WHILE TSD1->(!EOF())
	aAdd(aCols,Array(len(aHeader)+1))
	For x := 1 to Len(aHeader)
		aCols[len(aCols)][x] := TSD1->&(alltrim(aHeader[x][2]))
	Next
	aCols[len(aCols)][len(aHeader)+1] := .F.  
	
	nTotCli += TSD1->TOTREAL
	
	TSD1->(DBSKIP())
END

oNFs := MsNewGetDados():New(001,001,180,500,,,,,,,50000,,,,oFolder:aDialogs[4],aHeader,aCols,,)
//MsGetDb():New(001,001,200,500,2,"AllWaysTrue()","AllWaysTrue()",,,,,,,"TRB3","AllWaysTrue()",,,oFolder:aDialogs[4])

@ 190, 001 Say "Total ALBEA (R$)" SIZE 100,010 pixel of oFolDer:aDialogs[4]
@ 187, 040 MsGet nTotRexam SIZE 50,010 PIXEL OF oFolder:aDialogs[4] PICTURE "@E 999,999,999.99" READONLY
@ 190, 100 Say "Total Cliente (R$)" SIZE 100,010 pixel of oFolder:aDialogs[4]
@ 187, 140 MsGet nTotCli SIZE 50,010 PIXEL OF oFolder:aDialogs[4] PICTURE "@E 999,999,999.99" READONLY
// Fim PCs
@ 187, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oFolder:aDialogs[4] Action DlgToExcel({ {"GETDADOS","Notas Fiscais",oNFs:aHeader,oNFs:aCols}})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetREQ    ºAutor  ³RAFAEL TRINDADE     º Data ³  11/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CARREGA AS REQUISICOES CONTRA O PROJETO                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure GetREQ()
Local nUsado := 0
Local aCols := {}
Local nTotRexam := 0
// Faz a consulta no banco de dados para obter as informacoes do projeto

// SCs

// Faz a consulta no banco de dados para obter as informacoes do projeto

If Select("TSD3") > 0
	TSD3->(dbCloseArea())
End if

BeginSql Alias "TSD3"
	SELECT * FROM %table:SD3% SD3
	WHERE D3_FILIAL = %xFilial:SD3% AND D3_CC = %exp:cCCusto% AND %notdel%
EndSql

// Monta o aHeader
aHeader := {}
aSX3 := FWSX3UTIL():GetAllFields("SD3",.F.)

For nI := 1 to Len(aSX3)	
	If X3USO(GETSX3CACHE(aSX3[nI],"x3_usado")) .AND. cNivel >= GETSX3CACHE(aSX3[nI],"x3_nivel") .OR.;
		AllTrim(aSX3[nI] )  $ "D3_DOC/D3_NUMSEQ/"
		nUsado++
		Aadd(aHeader,{ ALLTRIM(FWX3TITULO(aSX3[nI])), aSX3[nI], PesqPict("SD3",aSX3[nI]),;
			TamSx3(aSX3[nI])[1], TamSx3(aSX3[nI])[2],"AllwaysTrue()",;
			GETSX3CACHE(aSX3[nI],"x3_usado"), FWSX3UTIL():GetFieldType(aSX3[nI]), "SD3", GETSX3CACHE(aSX3[nI],"x3_context") } )
		
		IF FWSX3UTIL():GetFieldType(aSX3[nI]) == "D"
			TCSETFIELD("TSD3",aSX3[nI],"D")
		END IF
	EndIf
Next

dbSelectArea("TSD3")
TSD3->(dbGoTop())

WHILE TSD3->(!EOF())
	aAdd(aCols,Array(len(aHeader)+1))
	For x := 1 to Len(aHeader)
		aCols[len(aCols)][x] := TSD3->&(alltrim(aHeader[x][2]))
	Next
	MsUnlock()
	
	aCols[len(aCols)][len(aHeader)+1] := .F.
	
	nTotRexam += TSD3->D3_CUSTO1
	
	TSD3->(DBSKIP())
END

oReqs := MsNewGetDados():New(001,001,180,500,,,,,,,50000,,,,oFolder:aDialogs[5],aHeader,aCols,,)
@ 190, 001 Say "Total ALBEA (R$)" SIZE 100,010 pixel of oFolDer:aDialogs[5]
@ 187, 040 MsGet nTotRexam SIZE 50,010 PIXEL OF oFolder:aDialogs[5] PICTURE "@E 999,999,999.99" READONLY

@ 187, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oFolder:aDialogs[5] Action DlgToExcel({ {"GETDADOS","Requisições x C.C. de Projetos",oREQs:aHeader,oREQs:aCols}})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetFIN    ºAutor  ³RAFAEL TRINDADE     º Data ³  11/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CARREGA OS ADIANTAMENTOS FEITOS PARA FORNECEDORES COM O     º±±
±±º          ³CENTRO DE CUSTO DO PROJETO.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure GetFIN()
Local nUsado := 0
Local aCols := {}
Local nTotRexam := 0, nTotCli := 0

// Verifica se o titulo esta em aberto
IF SELECT("TSE2") > 0
	TSE2->(dbCloseArea())
Endif

BeginSql Alias "TSE2"

	SELECT *
	FROM %table:SE2% SE2
	WHERE
	E2_SALDO > 0
	AND %notdel%
	AND E2_FILIAL = %xFilial:SE2%
	AND E2_CCD = %exp:cCCusto%
	AND E2_TIPO = 'PA'
EndSql

// Monta o aHeader
aHeader := {}
aSX3 := FWSX3UTIL():GetAllFields("SE2",.F.)

For nI := 1 to Len(aSX3)	
	If X3USO(GETSX3CACHE(aSX3[nI],"x3_usado")) .AND. cNivel >= GETSX3CACHE(aSX3[nI],"x3_nivel") .AND. FWSX3UTIL():GetFieldType(aSX3[nI]) <> "M" 
		nUsado++
		Aadd(aHeader,{ ALLTRIM(FWX3TITULO(aSX3[nI])), aSX3[nI], PesqPict("SE2",aSX3[nI]),;
			TamSx3(aSX3[nI])[1], TamSx3(aSX3[nI])[2],"AllwaysTrue()",;
			GETSX3CACHE(aSX3[nI],"x3_usado"), FWSX3UTIL():GetFieldType(aSX3[nI]), "SE2", GETSX3CACHE(aSX3[nI],"x3_context") } )
		
		IF FWSX3UTIL():GetFieldType(aSX3[nI]) == "D"
			TCSETFIELD("TSE2",aSX3[nI],"D")
		ENDIF
	EndIf
	DbSkip()
Next

dbSelectArea("TSE2")
TSE2->(dbGoTop())

WHILE TSE2->(!EOF())
	aAdd(aCols,Array(len(aHeader)+1))
	For x := 1 to Len(aHeader)
		aCols[len(aCols)][x] := TSE2->&(alltrim(aHeader[x][2]))
	Next
	MsUnlock()
	
	aCols[len(aCols)][len(aHeader)+1] := .F.
	
	nTotCli += TSE2->E2_SALDO	

	TSE2->(DBSKIP())
END

IF Len(aCols) = 0
	aAdd(aCols,Array(len(aHeader)+1))
	aCols[len(aCols)][len(aHeader)+1] := .F.
END IF

oFin := MsNewGetDados():New(001,001,180,500,,,,,,,50000,,,,oFolder:aDialogs[6],aHeader,aCols,,)

@ 190, 001 Say "Total ALBEA (R$)" SIZE 100,010 pixel of oFolDer:aDialogs[6]
@ 187, 040 MsGet nTotRexam SIZE 50,010 PIXEL OF oFolder:aDialogs[6] PICTURE "@E 999,999,999.99" READONLY
@ 190, 100 Say "Total Cliente (R$)" SIZE 100,010 pixel of oFolder:aDialogs[6]
@ 187, 140 MsGet nTotCli SIZE 50,010 PIXEL OF oFolder:aDialogs[6] PICTURE "@E 999,999,999.99" READONLY

@ 187, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oFolder:aDialogs[6] Action DlgToExcel({ {"GETDADOS","Adiantamentos Financeiros",oFIN:aHeader,oFIN:aCols}})
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetREA    ºAutor  ³RAFAEL TRINDADE     º Data ³  11/21/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CARREGA AS CONTABILIZACOES PARA O CENTRO DE CUSTO DO PROJE- º±±
±±º          ³TO TANTO PARA INVESTIMENTO REXAM E CLIENTE                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGACTB                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Procedure GetREA()
Local nUsado := 0
Local aCols := {}, aCpos
Local nTotRexam := 0, nTotCli := 0
Local oScr
Private cItem := Space(30)
Private cForn := CRIAVAR("A2_NREDUZ")
Private nValItem := CRIAVAR("D1_CUSTO")

oScr := TScrollBox():New(oFolder:aDialogs[7], 001, 001,300,500, .T.,.F. )
oScr:Align := CONTROL_ALIGN_ALLCLIENT

aCpos := StrTokArr("CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_HIST,FORN,ITENS,CUSTO,CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_VALOR",",")

If Select("TCT2") > 0
	TCT2->(dbCloseArea())
End if

BeginSql Alias "TCT2"
	column CT2_DATA as Date
	%noparser%
	Select CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, CT2_DEBITO,
	CT2_CREDIT,
	CASE      
        WHEN CT2_DC = 3 AND CT2_CCD = %exp:cCCusto% THEN CT2_VALOR
        WHEN CT2_DC = 3 AND CT2_CCC = %exp:cCCusto% THEN CT2_VALOR*-1
		WHEN CT2_CREDIT = %exp:'1340101'% THEN CT2_VALOR*-1 
		WHEN CT2_DEBITO = %exp:'1340101'% THEN CT2_VALOR
	END AS CT2_VALOR, CT2_HIST, CT2_SEQUEN, R_E_C_N_O_, CT2_ROTINA
	FROM %table:CT2% CT2
	WHERE
		CT2.CT2_FILIAL = %xFilial:CT2% AND
		(CT2_DEBITO = %exp:'1340101'% or CT2_CREDIT = %exp:'1340101'%)
		AND CT2_CCD = %exp:cCCusto%
		AND CT2_LP != '812'
		AND CT2.%notdel%
ENDSQL

dbSelectArea("TCT2")

// Monta o aHeader

aHeader := {}

For x := 1 to Len(aCpos)
	nUsado++
	if aCpos[x] == "ITENS"
		If lDetRea // Adiciona campo de itens da nota fiscal do lançamento
			aAdd(aHeader,;
			{"Itens",; // Título
			"cItem",; // Campo
			"@!",; // Picture
			30,; // Tamanho
			0,; // Decimal
			"",; // Validação
			"",; // Reservado
			"C",; // Tipo
			"",; // Reservado
			"" }) // Reservado
		Endif
	ELSEIF aCpos[x] == "FORN"
		If lDetRea // Adiciona campo de itens da nota fiscal do lançamento
			aAdd(aHeader,;
			{"Fornecedor",; // Título
			"cForn",; // Campo
			"@!",; // Picture
			20,; // Tamanho
			0,; // Decimal
			"",; // Validação
			"",; // Reservado
			"C",; // Tipo
			"",; // Reservado
			"" }) // Reservado
		Endif
	ELSEIF aCpos[x] == "CUSTO"
		If lDetRea // Adiciona campo de itens da nota fiscal do lançamento
			aAdd(aHeader,;
			{"Val Item",; // Título
			"nValItem",; // Campo
			GetSx3Cache("D1_CUSTO","X3_PICTURE"),; // Picture
			GetSx3Cache("D1_CUSTO","X3_TAMANHO"),;
			GetSx3Cache("D1_CUSTO","X3_DECIMAL"),;
			GetSx3Cache("D1_CUSTO","X3_VALID"),;
			"",;
			GetSx3Cache("D1_CUSTO","X3_TIPO",),;
			"",;
			"" })
		Endif
	else
		Aadd(aHeader,{AllTrim(GetSx3Cache(aCpos[x],"X3_TITULO")),;
		aCpos[x],;
		GetSx3Cache(aCpos[x],"X3_PICTURE"),;
		GetSx3Cache(aCpos[x],"X3_TAMANHO"),;
		GetSx3Cache(aCpos[x],"X3_DECIMAL"),;
		GetSx3Cache(aCpos[x],"X3_VALID"),;
		"",;
		GetSx3Cache(aCpos[x],"X3_TIPO",),;
		"",;
		"" })
		IF GetSX3Cache(aCpos[x],"X3_TIPO") == "D"
			TCSETFIELD("TCT2",aCpos[x],"D")
		ENDIF
	endif
Next

dbSelectArea("TCT2")
TCT2->(dbGoTop())

WHILE TCT2->(!EOF())
// Passa em cada linha da contabilidade
	lchave := .f. // Verifica se é a primeira vez que esta passando nesta linha
	aItens := {} // Inicializa a variável que guarda as informações da linha
	IF lDetRea // Verifica se deve mostrar os detalhes ou não
		// Pega informações da nota fiscal de entrada se for a origem do lançamento
		dbSelectArea("CV3") // Abre a tabela de rastreamento de Lançamento contábil
		CV3->(dbSetOrder(2)) // Ordena por Recno Destino
		// Localiza rastreabilidade no CV3
		If CV3->(dbSeek(xFilial("CV3")+Alltrim(str(TCT2->R_E_C_N_O_)),.F.)) // Localiza o Recno do lançamento contabil na tabela de rastro
			IF CV3->CV3_TABORI == "SF1" // Verifica se a origem do lançamento fo nota fiscal
				// Localiza nota fiscal no SF1
				dbSelectArea("SF1") // Se for localiza a nota fiscal na tabela SF1
				SF1->(dbGoTo(val(CV3->CV3_RECORI)))
				IF SF1->(!EOF()) // Se não foi para o final do arquivo
					
					// Localiza itens da NF
					dbSelectArea("SD1")
					SD1->(dbSetOrder(1))

					IF SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
						// Para cada item da nota fiscal
						WHILE SD1->(!EOF()) .AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA 
							
							// Verifica se o item tem o centro de custo do projeto e se não é investimento
							// do cliente, se for deve entrar na outra grid
							IF AllTrim(SD1->D1_CC) == AllTrim(cCCusto)
								// Adiciona itens no array para utilização na hora de montar a tela
								aAdd(aItens,{SD1->D1_DESCR,SD1->D1_FORNECE+SD1->D1_LOJA,(SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6)*iif(TCT2->CT2_VALOR>0,1,-1)})
								// Nota: Note que quando o valor na contabilidade é negativo, o valor calculado na nota também é.
							Endif
							SD1->(dbSkip()) // Vei para o próximo registro do item da nota fiscal
						END
					ENDIF
				ENDIF
			ENDIF
		Endif 
		     
		// Verifica se foi encontrado algum item da nota, se não foi adiciona um
		// item de array com conteúdo vazio, assim não terá error.log
		If Len(aItens) == 0 
			aItens := {{"","",0}}
		Endif

		// Para cada item do array, vai adicionar uma linha no acols da contabilidade
		// Dessa maneira as linhas ficarão duplicadas, porém é feita uma tratativa para que 
		// o valor do lançamento seja feito só na primeira linha do lançamento, desta maneira
		// não afeta o total.
		For y := 1 to Len(aItens)
			// Adiciona uma linha em branco no acols
			aAdd(aCols,Array(len(aHeader)+1))
			// Para cada campo do aHeader faz o preenchimento dos dados
			// aqui é tratado a questão das colunas calculadas, que são aquelas que não
			// vem da query.
			For x := 1 to Len(aHeader)
				IF Alltrim(aHeader[x][1]) == "Itens" .and. lDetRea
					// Imprime itens da nota de entrada
					aCols[len(aCols)][x] := AllTrim(aItens[y][1])
				Elseif Alltrim(aHeader[x][1]) == "Fornecedor" .and. lDetRea
					// Imprime Nome fantasia do Fornecedor
					aCols[len(aCols)][x] := IIF(AllTrim(aItens[y][2])!="",Posicione("SA2",1,xFilial("SA2")+AllTrim(aItens[y][2]),"A2_NREDUZ"),"")
				Elseif Alltrim(aHeader[x][1]) == "Val Item" .and. lDetRea
					// Imprime Valor do item da nota
					aCols[len(aCols)][x] := aItens[y][3]
				Else
					if aHeader[x][2] == "CT2_VALOR"
						If !lchave
							aCols[len(aCols)][x] := TCT2->&(alltrim(aHeader[x][2]))
							lchave := .t.
						Else
							aCols[len(aCols)][x] := 0.00
						End if
					else
						aCols[len(aCols)][x] := TCT2->&(alltrim(aHeader[x][2]))
					end if				
				end if
			Next
			// Adiciona conteúdo da coluna de deletado.
			aCols[len(aCols)][len(aHeader)+1] := .F.
		Next
	Else  // Se não for para mostrar detalhes
		// Neste ponto o sistema passa quando a variável lDetRea está desabilitada
		// esta variável controla o fluxo desta função exibindo ou não os detalhes do lan-
		// çamento com a nota de entrada.
		aAdd(aCols,Array(len(aHeader)+1))
		For x := 1 to Len(aHeader)
			aCols[len(aCols)][x] := TCT2->&(alltrim(aHeader[x][2]))
		Next
		aCols[len(aCols)][len(aHeader)+1] := .F.
	END IF 
	// Faz a soma da coluna de valor do lançamento contabil para ser colocado no
	// campo de total de investimento Rexam
	nTotRexam += TCT2->CT2_VALOR
	TCT2->(DBSKIP())
END

IF Len(aCols) = 0
	aAdd(aCols,Array(len(aHeader)+1))
	aCols[len(aCols)][len(aHeader)+1] := .F.
END IF

// Carrega informações da Rexam e monta objetos da guia

@ 001,001 Say "Lançamentos investimento ALBEA" SIZE 100,010 PIXEL OF oScr
oRea := MsNewGetDados():New(010,001,110,500,,,,,,,50000,,,,oScr,aHeader,aCols,,)

@ 118, 001 Say "Total ALBEA (R$)" SIZE 100,010 pixel of oScr
@ 115, 040 MsGet nTotRexam SIZE 50,010 PIXEL OF oScr PICTURE "@E 999,999,999.99" READONLY

@ 115, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oScr Action DlgToExcel({ {"GETDADOS","Realizado Albea",oRea:aHeader,oRea:aCols}})
@ 115, 250 BUTTON "Detalhes" SIZE 40,13 Pixel of oScr Action DetReaOnClick()

// Cria getdados para dados de investimento do cliente

aCols := {} // Zera o acols

// Consulta banco

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± O mesmo para lancamentos do cliente       ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

If Select("TCT2") > 0
	TCT2->(dbCloseArea())
End if

BeginSql Alias "TCT2"
	column CT2_DATA as Date
	%noparser%
	Select CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, CT2_DEBITO,
	CT2_CREDIT,
	CASE 
		WHEN CT2_DC = 3 AND CT2_CCD = %exp:cCCusto% THEN CT2_VALOR
        WHEN CT2_DC = 3 AND CT2_CCC = %exp:cCCusto% THEN CT2_VALOR*-1
		WHEN CT2_CREDIT = %exp:'1150801'% THEN CT2_VALOR*-1 
		WHEN CT2_DEBITO = %exp:'1150801'% THEN CT2_VALOR
	END AS CT2_VALOR, CT2_HIST, R_E_C_N_O_, CT2_ROTINA
	FROM %table:CT2% CT2
	WHERE
	CT2.CT2_FILIAL = %xFilial:CT2% AND
	(CT2_DEBITO = %exp:'1150801'% or CT2_CREDIT = %exp:'1150801'%)
	and CT2_CCD = %exp:cCCusto% 
	AND CT2_LP != '812'
	AND CT2.%notdel%
ENDSQL

dbSelectArea("TCT2")

dbGoTop()

WHILE TCT2->(!EOF())
// Passa em cada linha da contabilidade
	lchave := .f. // Verifica se é a primeira vez que esta passando nesta linha
	aItens := {} // Inicializa a variável que guarda as informações da linha
	IF lDetRea // Verifica se deve mostrar os detalhes ou não
		// Pega informações da nota fiscal de entrada se for a origem do lançamento
		dbSelectArea("CV3") // Abre a tabela de rastreamento de Lançamento contábil
		CV3->(dbSetOrder(2)) // Ordena por Recno Destino
		// Localiza rastreabilidade no CV3
		If CV3->(dbSeek(xFilial("CV3")+Alltrim(str(TCT2->R_E_C_N_O_)),.F.)) // Localiza o Recno do lançamento contabil na tabela de rastro
			IF CV3->CV3_TABORI == "SF1" // Verifica se a origem do lançamento fo nota fiscal
				// Localiza nota fiscal no SF1
				dbSelectArea("SF1") // Se for localiza a nota fiscal na tabela SF1
				SF1->(dbGoTo(val(CV3->CV3_RECORI)))
				IF SF1->(!EOF()) // Se não foi para o final do arquivo
					
					// Localiza itens da NF
					dbSelectArea("SD1")
					SD1->(dbSetOrder(1))

					IF SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.))
						// Para cada item da nota fiscal
						WHILE SD1->(!EOF()) .AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND.;
							SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA 
							
							// Verifica se o item tem o centro de custo do projeto e se não é investimento
							// do cliente, se for deve entrar na outra grid
							IF AllTrim(SD1->D1_CC) == AllTrim(cCCusto)
								// Adiciona itens no array para utilização na hora de montar a tela
								aAdd(aItens,{SD1->D1_DESCR,SD1->D1_FORNECE+SD1->D1_LOJA,(SD1->D1_TOTAL-SD1->D1_VALICM-SD1->D1_VALIMP5-SD1->D1_VALIMP6)*iif(TCT2->CT2_VALOR>0,1,-1)})
								// Nota: Note que quando o valor na contabilidade é negativo, o valor calculado na nota também é.
							End if
							SD1->(dbSkip()) // Vei para o próximo registro do item da nota fiscal
						END
					END IF
				END IF
			END IF
		End if 
		     
		// Verifica se foi encontrado algum item da nota, se não foi adiciona um
		// item de array com conteúdo vazio, assim não terá error.log
		If Len(aItens) == 0 
			aItens := {{"","",0}}
		End if
		                         
		// Para cada item do array, vai adicionar uma linha no acols da contabilidade
		// Dessa maneira as linhas ficarão duplicadas, porém é feita uma tratativa para que 
		// o valor do lançamento seja feito só na primeira linha do lançamento, desta maneira
		// não afeta o total.
		For y := 1 to Len(aItens)
			// Adiciona uma linha em branco no acols
			aAdd(aCols,Array(len(aHeader)+1))
			// Para cada campo do aHeader faz o preenchimento dos dados
			// aqui é tratado a questão das colunas calculadas, que são aquelas que não
			// vem da query.
			For x := 1 to Len(aHeader)
				IF Alltrim(aHeader[x][1]) == "Itens" .and. lDetRea
					// Imprime itens da nota de entrada
					aCols[len(aCols)][x] := AllTrim(aItens[y][1])
				Elseif Alltrim(aHeader[x][1]) == "Fornecedor" .and. lDetRea
					// Imprime Nome fantasia do Fornecedor
					aCols[len(aCols)][x] := IIF(AllTrim(aItens[y][2])!="",Posicione("SA2",1,xFilial("SA2")+AllTrim(aItens[y][2]),"A2_NREDUZ"),"")
				Elseif Alltrim(aHeader[x][1]) == "Val Item" .and. lDetRea
					// Imprime Valor do item da nota
					aCols[len(aCols)][x] := aItens[y][3]
				Else
					if aHeader[x][2] == "CT2_VALOR"
						If !lchave
							aCols[len(aCols)][x] := TCT2->&(alltrim(aHeader[x][2]))
							lchave := .t.
						Else
							aCols[len(aCols)][x] := 0.00
						End if
					else
						aCols[len(aCols)][x] := TCT2->&(alltrim(aHeader[x][2]))
					end if				
				end if
			Next
			// Adiciona conteúdo da coluna de deletado.
			aCols[len(aCols)][len(aHeader)+1] := .F.
		Next
	Else  // Se não for para mostrar detalhes
		// Neste ponto o sistema passa quando a variável lDetRea está desabilitada
		// esta variável controla o fluxo desta função exibindo ou não os detalhes do lan-
		// çamento com a nota de entrada.
		aAdd(aCols,Array(len(aHeader)+1))
		For x := 1 to Len(aHeader)
			aCols[len(aCols)][x] := TCT2->&(alltrim(aHeader[x][2]))
		Next
		aCols[len(aCols)][len(aHeader)+1] := .F.
	END IF 
	// Faz a soma da coluna de valor do lançamento contabil para ser colocado no
	// campo de total de investimento Rexam
	nTotCli += TCT2->CT2_VALOR
	TCT2->(DBSKIP())
END

IF Len(aCols) = 0
	aAdd(aCols,Array(len(aHeader)+1))
	aCols[len(aCols)][len(aHeader)+1] := .F.
END IF

@ 130,001 Say "Investimento Cliente" SIZE 100,010 PIXEL OF oScr//oFolder:aDialogs[7]
oReaCli := MsNewGetDados():New(140,001,190,500,,,,,,,50000,,,,oScr,aHeader,aCols,,)
@ 198, 001 Say "Total Cliente (R$)" SIZE 100,010 pixel of oScr
@ 195, 040 MsGet nTotCli SIZE 50,010 PIXEL OF oScr PICTURE "@E 999,999,999.99" READONLY

@ 195, 200 BUTTON "Excel" SIZE 40,13 Pixel Of oScr Action DlgToExcel({ {"GETDADOS","Realizado Cliente",oReaCli:aHeader,oReaCli:aCols}})

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPCTB04   ºAutor  ³Microsiga           º Data ³  07/23/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function DetReaOnClick()
	lDetRea := !lDetRea
	GetRea()
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Filtro    ºAutor  ³RAFAEL TRINDADE     º Data ³  07/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra tela de filtro e depois atualiza tela.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Procedure Filtro(oB,lmostra)

//Pergunte(cPerg,lmostra)

DbSelectArea("CTT")

/*IF MV_PAR01 == 2

	CTT->(dbSetFilter({|| POSICIONE("CTT",1,xfilial("CTT")+cCCusto,"CTT_BLOQ")!= "1"},"" ))
	CTT->(dbSetOrder(1))
	If oB != nil
    	oObjBrow := GetObjBrow() //Obtém o ultimo Objeto Browse
		oObjBrow:ResetLen()
		oObjBrow:GoTop()
		oObjBrow:Refresh()
 	Endif
Else*/
	CTT->(dbClearFilter())
//Endif 

Return

/*/ {Prottheus.doc} meugetmv

Retorna conteudo de um parametro

@author Rafael Trindade
@param cParametro, Character, Nome do parametro para retornar conteudo
@since 15/05/2023
/*/

//Static Function meugetmv(cParametro)
//Return GETMV(cParametro)




/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/05/2020
Consultoria: TecSistem
Uso: Regus/Câmara Leal
Info: Gravação e chamada de parâmetros na SX1
*==================================================================*/
Static Function AjustaSx1(cPerg)

	Local aRegs := {}
	Local nX    := 0
	Local nY    := 0

	//A função aAdd adiciona um novo elemento no final do array

	aAdd(aRegs,{cPerg,"01","Centro de Custo?"  ,"","","mv_ch1","C",09,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT"})
	
	DbSelectArea("SX1")

	SX1->(DbSetOrder(1))

	For nX := 1 To Len(aRegs)

		If !DbSeek(cPerg + aRegs[nX,2])

			RecLock("SX1",.T.)

			For nY := 1 To FCount()

				If nY <= Len(aRegs[nX])
					FieldPut(nY,aRegs[nX,nY])
				Endif

			Next nY

			SX1->(MsUnlock())

		Endif

	Next nX

Return
