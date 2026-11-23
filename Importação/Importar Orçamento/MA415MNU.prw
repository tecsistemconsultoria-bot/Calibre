#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Vinicius Nascimento de Oliveira
Data: 29/09/2025
Consultoria: Proativa 
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: MA415MNU
Info: Inclui botões em Outras Ações no Orçamento
************************************************************************/
User Function MA415MNU()
		
	aAdd(aRotina,{"Histórico do Cliente","U_CVFATA07()",0,4})
	aAdd(aRotina,{OemtoAnsi('Efetiva Orçamento'),"U_PTFAT904()",0,4,0,Nil})
    aAdd(aRotina,{OemtoAnsi('Envia e-mail'),"U_PTFAT906()",0,4,0,Nil})
	aAdd(aRotina,{OemtoAnsi('Importar Orçamento CSV'),"U_CVFATA15()",0,4,0,Nil})
	
Return    
