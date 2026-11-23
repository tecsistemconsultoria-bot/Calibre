#Include 'Protheus.ch'
#Include 'Parmtype.ch'

/***********************************************************************
Autor: Vinicius Nascimento de Oliveira
Data: 17/07/2025
Consultoria: Proativa 
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: MA410MNU
Info: Inclui botões em Outras Ações no Pedido de Vendas
************************************************************************/
User Function MA410MNU()
		
    aAdd(aRotina,{'Vis. Pend II','U_VPendII()',0,2,0,Nil})
	aAdd(aRotina,{"Alt. PV s/Estorno", "U_CVFATA11()",0,4})
	aAdd(aRotina,{"Entrega Urgente","U_CVFATA12()",0,4})
	aAdd(aRotina,{"Altera Frete s/Estorno","U_CVFATA14()",0,4})
	aAdd(aRotina,{"Histórico do Cliente","U_CVFATA07()",0,4})
	aAdd(aRotina,{'Imprime Pré-Danfe',"U_PRENOTA()" ,0,4})
	
Return    
