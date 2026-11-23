#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'FwMBrowse.ch'
#Include 'FwMVCDef.ch'
#Include 'FwBrowse.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 03/07/2025
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: CVFATA10
Info: Alerta com a mensagem no campo B5_XMSGPRO
************************************************************************/
User Function CVFATA10()

	Local aArea      := GetArea()
	Local oDlgMemo   := Nil 
	Local oMemo      := Nil 
	Local cDescMemo  := "Mensagem do Time de Produtos"
	Local cDescComp  := ""
	Local cRetorno   := ""
	Local lGrafic    := IsBlind()

	If !lGrafic

		If AllTrim(FunName()) == "MATA415"

			cDescComp  := Posicione("SB5",1,xFilial("SB5")+TMP1->CK_PRODUTO,"B5_XMSGPRO")
			cRetorno   := TMP1->CK_PRODUTO

		Else 

			cDescComp  := Posicione("SB5",1,xFilial("SB5")+M->C6_PRODUTO,"B5_XMSGPRO")
			cRetorno   := M->C6_PRODUTO
			
		Endif 

		If !Empty(cDescComp) .AND. !Left(cDescComp,1) == "-"

			Define MsDialog oDlgMemo Title cDescMemo From 000,000 TO 200,650 Pixel

			oMemo := TMultiget():New(006,006,{|u|IIf(PCount() > 0, cDescComp := u,cDescComp)},oDlgMemo,320,092,,,,,,.T.)

			//Ativação da janela Principal
			oDlgMemo:Activate(,,,.T.)

		Endif

	Else 

		If AllTrim(FunName()) == "MATA415"

			cRetorno := TMP1->CK_PRODUTO

		Else 

			cRetorno := M->C6_PRODUTO

		Endif

	Endif 

	RestArea(aArea)

Return(cRetorno)
