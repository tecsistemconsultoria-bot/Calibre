#INCLUDE "PROTHEUS.CH"  
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"                               
#INCLUDE "TBICONN.CH" 
                                                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GATPRC    ºAutor  ³Microsiga           º Data ³  10/29/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Esta rotina e exectado vai Gatilho para preenchdimento     º±±
±±º          ³ do campo customizado de Preco de lista Padrao (UB_XPRCTAB) º±±             
±±º          ³ e (C6_XPRCTAB)                                             º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
nVrUnit := MaTabPrVen(	M->UA_TABELA	,aCols[nLinha][nPProd]	,aCols[nLinha][nPQtd]	,M->UA_CLIENTE	,;
										M->UA_LOJA		,M->UA_MOEDA			,NIL					,NIL			,;
										NIL				,.T.					,lProspect				)
		  	


*/


//User Function GatPrc(_Orig,_dest)    
User Function GatPrc(_Orig,_dest,_CodPro,_Cliente,_Loja,_TabPrc)
Local nPProd,nPQtd , _CodPro,_Cliente,_Loja,_TabPrc
Local _Ret
Local aArea   := GetArea() 

_Ret	:= BPrcTab(_TabPrc,_CodPro,_Cliente,_Loja, _dest)

RestArea(aArea)   
Return(_Ret)                                            

Static Function BPrcTab(_TabPr,_Prod, _Cli,_Loj,_dest)
Local _RetPrc := 0 
                                       
SA1->(dbSelectarea("SA1"))
SA1->(dbSetOrder(1)) // Codigo do produto
SA1->(dbSeek( xFilial('SA1')+ _Cli+_Loj,.F. ))
                                                    
teste := " "       
                    
If  _dest <>"PT"
	ACO->(dbSelectarea("ACO"))
	ACO->(dbSetOrder(3)) // ACO_FILIAL+ACO_CODCLI+ACO_LOJA+ACO_CODTAB
	ACO->(dbSeek( xFilial('ACO')+ _Cli+_Loj+_TabPr,.F. ))
	teste := " "
	If ACO->(Found())
		teste := " " 
		ACP->(dbSelectarea("ACP"))
		ACP->(dbSetOrder(4)) // ACP_FILIAL+ACP_CODREG+ACP_CODPRO+ACP_CFAIXA
		ACP->(dbSeek(xFilial("ACP")+ACO->ACO_CODREG+ _Prod,.F. )) 
		teste:= " "
		If ACP->(Found()) .and. ACP->ACP_CRVLIQ > 0   
		
		 _RetPrc := ACP->ACP_CRVLIQ
		// Return(_RetPrc)                         
		EndIf   
	EndIf   
EndIf

teste := " "
If _RetPrc = 0  .OR. _dest ="PT"
	DA1->(dbSelectarea("DA1"))
	DA1->(dbSetOrder(1)) // DA1_FILIAL + DA1_CODTAB + DA1_CODPRO +  DA1_ITEM
	DA1->(dbSeek( xFilial('DA1')+_TabPr+_Prod,.F. ))   
	teste := " "
	Do While DA1->(!Eof()) .AND. xFilial("DA1") == DA1->DA1_FILIAL .and. ;
							  AllTrim(DA1->DA1_CODTAB) == AllTrim(_TabPr) .AND.;
							  AllTrim(DA1->DA1_CODPRO) == AllTrim(_Prod)    	
		
		TESTE := " "
		If DA1->DA1_ATIVO ="2"  // Produto inativo
			DA1->(Dbskip())
	        Loop
		EndIf
		If !empty(DA1->DA1_ESTADO) .AND. DA1->DA1_ESTADO <> SA1->A1_EST     
			DA1->(Dbskip())
	        Loop
		EndIf
		teste := " "
		If DA1->DA1_PRCVEN > 0 

			_RetPrc := DA1->DA1_PRCVEN
			Exit
		EndIf
		DA1->(dbSkip())
	Enddo
EndIf  
teste := " " 
Return(_RetPrc)
