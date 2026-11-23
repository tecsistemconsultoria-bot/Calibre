#include "rwmake.ch"
#INCLUDE "ap5mail.ch"
                      
/*
+-------+--------------+---------+---------------------------+---------+-------------+
|Função | SF2460I      | Autor:  | Rodrigo Carvalhaes        | Data:   | 06/09/04    |
+-------+--------------+---------+---------------------------+---------+-------------+
|Descricao:   | Rotina para solicitar Peso Bruto / Liquido / Qtde. de Volumes        |
|-------------+----------------------------------------------------------------------+ 
|DETALHES DO P.E.                                                                    |
|Descrição:	Na função que gera registros em SF2 (Cabeçalho das Notas Ficais de Saída)|
| e acumula valores. Após a Atualização de todos os arquivos						 |
|Retorno Esperado:      Nenhum.														 |
|-------------+----------------------------------------------------------------------+
| Uso:        | Módulo Faturamento                                                   |
+-------------+----------------------------------------------------------------------+
|            ALTERAÇÕES FEITAS DESDE A CRIAÇÃO DO PROGRAMA:                          |
+--------------------+-----------+---------------------------------------------------+
|Programador         | Data      | Descrição                                         |
+--------------------+-----------+---------------------------------------------------+    
|Rodrigo Carvalhaes  | 23/09/04  | Permitido no.volumes zerado cfe solic.Leandro     |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 20/11/04  | Coloca observações da NF na tela para edição      |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 10/12/04  | Incluido validacao caso a nota utilize fornecedor |
+--------------------+-----------+---------------------------------------------------+        
|Rodrigo Carvalhaes  | 05/12/05  | Incluido validacao se peso liquido é maior que o  |
} peso bruto dá um alert.
+--------------------+-----------+---------------------------------------------------+ 
|Rodrigo Carvalhaes  | 05/12/05  | Gravado direto valor dos juros no se2             |
+--------------------+-----------+---------------------------------------------------+
|Rodrigo Carvalhaes  | 07/12/05  | Inserido Reclock no GravJuros e get/rest area     |
+--------------------+-----------+---------------------------------------------------+      
|Rodrigo Carvalhaes  | 26/05/07  | Gravado se o cliente gera Bloqueto ou não         |
+--------------------+-----------+---------------------------------------------------+    
|Rodrigo Carvalhaes  | 07/08/07  | Corrigido bloqueto nas "N" parcelas               |
+--------------------+-----------+---------------------------------------------------+   
|Rodrigo Carvalhaes  | 03/04/08  | Incluido log para debug (arquivo boleto.log)      |                                                        	
+--------------------+-----------+---------------------------------------------------+      
|Rodrigo Carvalhaes  | 24/02/10  | Retirado janela de volumes                        |                                                        	
+--------------------+-----------+---------------------------------------------------+    
*/      

//----> TO DO LIST:  

*---------------------------------* 
User Function SF2460I()
*---------------------------------* 

Local area   := GetArea()
Local lFrete  := GetMv("MV_XFRTNF",.T.,.F.)
local xRECSC5 := SC5->(RECNO())
LOCAL xORDSC5 := SC5->(INDEXORD())
local xRECSD2 := SD2->(RECNO())
LOCAL xORDSD2 := SD2->(INDEXORD())

Private _Ok := .F.                 


// Chama static function para gravar juros no se2
GravJuro()      

// Envia email dos certificads de analise
MailLote()

//Apenas os tipos Normal / Devolução e Beneficiamento entrarão na regra
If lFrete

	If SF2->F2_TIPO $ 'NDB'
		FWMsgRun(,{||U_CVFATA02()},"Aguarde","Filtrando os fretes...") //Painel de Fretes
	Endif 

Endif 
// ---
DBSELECTAREA("SD2")
DBSETORDER(3)
DBSEEK(XFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
IF FOUND()
   DBSELECTAREA("SC5")
   DBSETORDER(1)
   DBSEEK(XFILIAL("SC5")+SD2->D2_PEDIDO)
   IF FOUND()
      DBSELECTAREA("SC5")
      IF FIELDPOS("C5_XREVFRE") <> 0
        //Réplica de dados do pedido para a nota fiscal - Vinicius N. de Oliveira - 08/12/2025
        If !Empty(SC5->C5_XREVFRE)
	       DBSELECTAREA("SF2")
	       RECLOCK("SF2",.F.)
	       SF2->F2_ZINFFRE := SC5->C5_ZINFFRE
	       SF2->F2_CRVOBS  := SC5->C5_XCRVOBS
	       SF2->F2_ZFRETE  := SC5->C5_ZFRETE
	       MSUNLOCK()
	       DBSELECTAREA("SC5")
	       RecLock("SC5",.F.)
	       SC5->C5_XREVFRE := "N" //Reseto a revisão após a geração da nota 
	       SC5->(MsUnlock())
	    ENDIF   
	  ENDIF	
   ENDIF
ENDIF

DBSELECTAREA("SC5")
DBSETORDER(xORDSC5)
GO xRECSC5 

DBSELECTAREA("SD2")
DBSETORDER(xORDSD2)
GO xRECSD2
	  // ---
// Restaura o environment (ponteiros)
RestArea(area)

Return    
   
Static Function GravJuro()
**********************************************************************************
* Grava os juros no se1 com base na taxa de permanência configurada no sistema
*
**********************************************************************************            
_LogFile  := "bloqueto.log"
_nVlrRst  := 0
_nVltTit  := SE1->E1_VALOR
_nPorcJur := GetMv("MV_TXPER")
_nVlrRst  := (( _nVltTit * _nPorcJur) / 100)         
iF SF2->F2_COND=="225"  // CARTAO CREDITO NAO GERAR BOLETO
	_Boleto   := "2"
Else	
	_Boleto   := SA1->A1_CRVBOL   
Endif	
_Titulo   := SE1->E1_NUM  
_Prefixo  := SE1->E1_PREFIXO                        
_Parcela  := SE1->E1_PARCELA
//_Area     := GetArea()    
_cLog     := ""          

                                        
cLog := DtoC(dDatabase)+" - "+TIME()+ " - SA1->A1_COD: " + SA1->A1_COD + " SA1->A1_CRVBOL: " + SA1->A1_CRVBOL

dbSelectArea("SE1")                   // * Contas a Receber    
dbSetOrder(1)                         // (e1_filial, e1_prefixo, e1_num, e1_parcela, e1_tipo, r_e_c_n_o_, d_e_l_e_t_)
dbGoTop()                             
// Atencao! NAO pode incluir deste DbSeek a parcela pois senao ele posiciona o while no ultimo registro!!!
DbSeek(xFilial('SE1')+_Prefixo+_Titulo)  // e1_filial, e1_prefixo, e1_num, e1_parcela, e1_tipo, r_e_c_n_o_, d_e_l_e_t_

Do While SE1->E1_NUM == _Titulo
	// Gravação dos campos no titulos corrente.
	RecLock("SE1",.F.)
	SE1->E1_PORCJUR := _nPorcJur
	SE1->E1_VALJUR  := _nVlrRst       
	SE1->E1_CRVBOL  := _Boleto
	MsUnLock("SE1")               
	cLog := cLog + " Prefixo+Titulo+Parcela -  " + _Prefixo + _Titulo + _Parcela + "_Boleto: " + _Boleto
	cLog := cLog + Chr(10) + Chr(13) // Nova linha no log 
DbSkip()
EndDo                 
Return()  




//---------------------------------//
// envia email para qualidade      //
//---------------------------------//
Static Function MailLote()
Dbselectarea("SA1")
Dbsetorder(1)
Dbseek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA, .t.)

ccTexto := "" 
ccMailTo := Alltrim(GetMv("MV_QUALID"))  // "valerio@eaglers.com.br,rodrigo@carvalhaes.net"
ccAssunto:= "Certificados de analise da NF " + SF2->F2_DOC

If SA1->A1_CRVCA <> .t.
   Return() 
Endif 

Dbselectarea("SD2")
Dbsetorder(3)
DbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE,.f.)

ccTextoItem := ""   

Do while .not. eof()

    If SD2->D2_FILIAL <> xFilial("SD2")
       Exit
    Endif

	If SD2->D2_DOC <> SF2->F2_DOC
		Exit
	Endif     
	
	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek( xFilial("SB1") + SD2->D2_COD, .t.)

    If SB1->B1_RASTRO = "L"        
       ccTextoItem += ccTexto + "Referencia: " + SB1->B1_COD + "          Lote: " + SD2->D2_LOTECTL + CHR(13)+CHR(10)
    Endif

    Dbselectarea("SD2")

	Dbskip()
	Loop
Enddo

ccTexto := SA1->A1_NOME   + CHR(13)+CHR(10) + CHR(13)+CHR(10)   
ccTexto  += "Segue em anexo os certificados de análise referente aos seguintes produtos:" + CHR(13)+CHR(10) + CHR(13)+CHR(10)
ccTexto  += ccTextoItem
ccTexto  += CHR(13)+CHR(10) + CHR(13)+CHR(10)
             

If ccTextoItem <> "" 
   EmailTo(ccMailTo,ccAssunto,ccTexto)
Endif

Return()

//-----------------------//
// Envia email           //
//-----------------------//
Static Function EmailTo(ccPara,ccAssunto,ccTexto) 

Local cServer   := GetMV("MV_RELSERV" )
Local cAccount  := Alltrim(GetMV("MV_RELACNT"))
Local cPassword := Alltrim(GetMV("MV_RELPSW"))
Local lAuth     := GetMV("MV_RELAUTH")
Local cAssunto  := ccAssunto
Local cMensagem := ccTexto
Local cEmailTo  := ccPara
Local cEmailBcc := ""
Local cError    := ""
Local lResult   := .f.
Local cTipo     := Space(0)
Local nStart
Local nn
Local nPos 
Local lMsgError := .f.  //  Mauricio-Chaus  
Local lFechaTb  := .f.

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
If lResult .And. lAuth
	lResult := MailAuth(cAccount, cPassword)
	If !lResult
		If lMsgError
			GET MAIL ERROR cError
			//Conout("Erro de autenticacao de e-mail."+cError)
		Endif
		Return Nil
	Endif
Else
	If !lResult
		If lMsgError
			GET MAIL ERROR cError
			//Conout("Erro de conexao com servidor SMTP. "+cError)
		Endif
		Return Nil
	Endif
EndIf
If lResult
  	SEND MAIL FROM cAccount ;
  	          TO cEmailTo;
  	          BCC cEmailBcc;
  	          SUBJECT cAssunto;
  	          BODY cMensagem;        
	          RESULT lResult
  	If !lResult
  		GET MAIL ERROR cError
		//Conout("Erro no envio do e-mail."+cError)
  	EndIf
  	DISCONNECT SMTP SERVER
EndIf
Return
       
