#INCLUDE "PROTHEUS.CH"
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GATPICM   ºAutor  ³Microsiga           º Data ³  08/29/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta rotina e executada via gatilho no momento de lancar   º±±
±±º          ³ o produto no Call Center e/ou Pedido de venda e tem        º±± 
±±º          ³ como objetivo preencer os campos UB_XPICM e/ou C6_XPICM    º±±
±±º          ³ com aliquota de ICMS do produto utilizando as funcoes      º±±
±±º          ³ padrao TOTVS de Excesoes Fiscias e de aliquota de ICMS     º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function GatPICM(_Orig)
	LOCAL _nPosB1
	Local _aArea := GetArea()
	Local _Cli
	Local _Loja
	Local _CodTES
	Local _CodPro
	Local nPerIcm := 0

	Local nPosProd 	:= 0
	Local nPosTES	:= 0
	Local nPosQtd	:= 0
	Local nPosPrc	:= 0
	Local nPosVlDes	:= 0
	Local nPosValor	:= 0
	Local aTransp	:= {}
	Local cTipo     := ""
	Local lProspect := .F.


	If _Orig = "CALL"
		nPosProd 	:= aScan(aHeader,{|x|AllTrim(x[2])=="UB_PRODUTO"})
		nPosTES		:= aScan(aHeader,{|x|AllTrim(x[2])=="UB_TES"})
		nPosQtd		:= aScan(aHeader,{|x|AllTrim(x[2])=="UB_QUANT"})
		nPosPrc		:= aScan(aHeader,{|x|AllTrim(x[2])=="UB_VRUNIT"})
		nPosVlDes	:= aScan(aHeader,{|x|AllTrim(x[2])=="UB_VALDESC"})
		nPosValor	:= aScan(aHeader,{|x|AllTrim(x[2])=="UB_VLRITEM"})
		MaFisSave()
		MaFisEnd()
		MaFisIni(Iif(!M->UA_PROSPEC,M->UA_CLIENT,M->UA_CLIENTE),;
			Iif(!M->UA_PROSPEC,M->UA_LOJAENT,M->UA_LOJA),;
			"C",;
			"N",;
			M->UA_TIPOCLI,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461",;
			Nil,;
			Nil,;
			IIF(M->UA_PROSPEC,M->UA_CLIENTE+M->UA_LOJA,""))
		MaFisAdd(   acols[n,nPosProd],;
			acols[n,nPosTES],;
			acols[n,nPosQtd],;
			acols[n,nPosPrc],;
			acols[n,nPosVlDes],;
			"",;
			"",;
			0,;
			0,;
			0,;
			0,;
			0,;
			acols[n,nPosValor],;
			0,;
			0,;
			0)

		nPerIcm := MaFisRet(1,"IT_ALIQICM" )
		MaFisEnd()
		MaFisRestore()
	Elseif _Orig == "MATA415"

		MaFisSave()
		MaFisEnd()

		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial("SA1")+If(!Empty(M->CJ_CLIENT),M->CJ_CLIENT,M->CJ_CLIENTE)+M->CJ_LOJAENT)

		dbSelectArea("SE4")
		dbSetOrder(1)
		MsSeek(xFilial("SE4")+M->CJ_CONDPAG)
		If !Empty(M->CJ_PROSPE) .And. !Empty(M->CJ_LOJPRO)
			cTipo := Posicione("SUS",1,xFilial("SUS") + M->CJ_PROSPE + M->CJ_LOJPRO,"US_TIPO")
			lProspect := .T.
		Endif
		MaFisIni(Iif(Empty(M->CJ_CLIENT),M->CJ_CLIENTE,M->CJ_CLIENT),;// 1-Codigo Cliente/Fornecedor
               M->CJ_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
               "C",;				// 3-C:Cliente , F:Fornecedor
               "N",;				// 4-Tipo da NF
               Iif(lProspect,cTipo,Iif(SCJ->(ColumnPos("CJ_TIPOCLI")) > 0,M->CJ_TIPOCLI,SA1->A1_TIPO)),;		// 5-Tipo do Cliente/Fornecedor
               Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  "MATA461",;
                  Nil,;
                  Nil,;
                  IiF(lProspect,M->CJ_PROSPE+M->CJ_LOJPRO,""),;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  IIf(SCJ->(ColumnPos("CJ_TPFRETE")) > 0,M->CJ_TPFRETE,Nil),;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  Nil,;
                  IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.))
		MaFisAdd(TMP1->CK_PRODUTO,;   	// 1-Codigo do Produto ( Obrigatorio )
               TMP1->CK_TES,;	   	// 2-Codigo do TES ( Opcional )
               TMP1->CK_QTDVEN,;  	// 3-Quantidade ( Obrigatorio )
               TMP1->CK_PRUNIT,;	// 4-Preco Unitario ( Obrigatorio )
               TMP1->CK_VALDESC,; 	// 5-Valor do Desconto ( Opcional )
               "",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
               "",;				// 7-Serie da NF Original ( Devolucao/Benef )
               0,;					// 8-RecNo da NF Original no arq SD1/SD2
               0,;					// 9-Valor do Frete do Item ( Opcional )
               0,;					// 10-Valor da Despesa do item ( Opcional )
               0,;					// 11-Valor do Seguro do item ( Opcional )
               0,;					// 12-Valor do Frete Autonomo ( Opcional )
               TMP1->CK_VALOR,;			// 13-Valor da Mercadoria ( Obrigatorio )
               0,;					// 14-Valor da Embalagem ( Opiconal )
               , , , , , , , , , , , , ,;
                  TMP1->CK_CLASFIS) // 28-Classificacao fiscal)

		nPerIcm := MaFisRet(1,"IT_ALIQICM" )
		MaFisEnd()
		MaFisRestore()

	Else
		nPosProd 	:= aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRODUTO"})
		nPosTES		:= aScan(aHeader,{|x|AllTrim(x[2])=="C6_TES"})
		nPosQtd		:= aScan(aHeader,{|x|AllTrim(x[2])=="C6_QTDVEN"})
		nPosPrc		:= aScan(aHeader,{|x|AllTrim(x[2])=="C6_PRUNIT"})
		nPosVlDes	:= aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALDESC"})
		nPosValor	:= aScan(aHeader,{|x|AllTrim(x[2])=="C6_VALOR"})

		MaFisSave()
		MaFisEnd()
		SA4->(DbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4")+M->C5_TRANSP))
			aADD(aTransp,SA4->A4_EST)
			aADD(aTransp,SA4->A4_TPTRANS)
		Endif
		MaFisIni(Iif(Empty(M->C5_CLIENT),M->C5_CLIENTE,M->C5_CLIENT),;
			M->C5_LOJAENT,;
			IIf(M->C5_TIPO$'DB',"F","C"),;
			M->C5_TIPO,;
			M->C5_TIPOCLI,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			"MATA461",;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			Nil,;
			aTransp,,,,M->C5_CLIENTE,M->C5_LOJACLI,,,M->C5_TPFRETE)
		MaFisAdd(   acols[n,nPosProd],;
			acols[n,nPosTES],;
			acols[n,nPosQtd],;
			acols[n,nPosPrc],;
			acols[n,nPosVlDes],;
			"",;
			"",;
			0,;
			0,;
			0,;
			0,;
			0,;
			acols[n,nPosValor],;
			0,;
			0,;
			0)

		nPerIcm := MaFisRet(1,"IT_ALIQICM" )
		MaFisEnd()
		MaFisRestore()

	EndIf

	RestArea(_aArea)
Return(nPerIcm)
