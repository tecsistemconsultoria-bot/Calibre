#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
                            
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MSD2460   º Autor ³  Tiago/Chaus       º Data ³  14/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Este ponto de entrada e executado pela rotina MATA460 ou    º±±
±±º          ³MATA461 - Geracao Nota Fiscal Saida após geração dos dados  º±±
±±º          ³na tabela SD2XXX Itens nota fiscal de saida. O mesmo já     º±±
±±º          ³existia na Politriz e a Chaus fez adequações e alterações   º±±
±±º          ³com o objetivo de:                                          º±±
±±º          ³1. Gravar na tabela ZZA - Ciclo do Pedido, FolowUP pedidos  º±±
±±º          ³  de venda a data, hora, usuário que fez o faturamento do   º±±
±±º          ³  pedido de venda                                           º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/




user function MSD2460()
Private nRetorno, aArea, nRecNo

cAliaAnte := Alias()
nAreaAnte := IndexOrd()
nRegiAnte := RecNo()

DbSelectArea("CFD")
DbSetOrder(2)
DbSeek(xFilial("CFD")+SD2->D2_COD)
Do While !Eof() .and. CFD->CFD_COD==SD2->D2_COD .AND. CFD->CFD_PERCAL<=SUBSTR(DTOC(DDATABASE),4,2)+LEFT(DTOS(DDATABASE),4) 
    If !Empty(CFD->CFD_FCICOD)
		RecLock("SD2",.F.)                 
		SD2->D2_FCICOD :=CFD->CFD_FCICOD
		//SD2->D2_CLASFIS:=CFD->CFD_ORIGEM+SUBSTR(SD2->D2_CLASFIS,2,2)
		MsUnlock()
	Endif
	DbSelectArea("CFD")
	DbSkip()
Enddo

If GetMv("MV_FOLWUPV") == "S" .AND.;
	SD2->D2_TIPO == "N" //Verifica se a nota fiscal de saida e do tipo normal, ou seja, venda, bonificação, etc
	/*
	RecLock("ZZA",.T.)
	//u_GravaZZA(xFilial("ZZA"),SD2->D2_PEDIDO,dDatabase,SD2->D2_ITEMPV,SD2->D2_COD,SD2->D2_QUANT,time(),"19 - PEDIDO FATURADO","01",SubStr(cUsuario,7,15),"MATA460/MSD2460")
	MsUnlock()
	DbCommitAll()         
	*/    
EndIf


dbSelectArea(cAliaAnte)
dbSetOrder(nAreaAnte)
dbGoTo(nRegiAnte)

RETURN()
