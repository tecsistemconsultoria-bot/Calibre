#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 23/04/2025
Consultoria: Proativa
Uso: Calibre
Tipo: Ponto de Entrada
Rotina: Faturamento
Função: A410CONS
Info: Inclusão de botão em outras ações no pedido de vendas
************************************************************************/
User Function A410CONS()

	Local aBotao := {}

	If INCLUI .Or. ALTERA
		SetKey(VK_F6,{||U_GETMOEDA(Nil,"M->C5_MOEDA","",Nil)})
		//SetKey(118,{||U_CVFATA07("",.T.)})
	Else
		SetKey(VK_F6,Nil)
		//Setkey(118,Nil)
	Endif

	aAdd(aBotao,{'Simular Frete', {||U_CVFATA13()}, "Simular Frete","Simular Frete"} )

	aAdd(aBotao,{'Historico do Cliente', {||U_CVFATA07("",.T.)}, "Historico do Cliente","Historico do Cliente"} )

	//aAdd(aBotao,{'Imprime Pré-Danfe', {||U_PRENOTA()}, "Imprime Pré-Danfe","Imprime Pré-Danfe"} )

Return(aBotao)
