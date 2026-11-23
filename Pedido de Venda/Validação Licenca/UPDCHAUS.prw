/*
****************************************************************************************************
** Fun��o          * UPDCHAUS.PRW  * Autor * CHAUS CONSULTORIA         	Data :  * 18/03/2013	  **
************************************************************************************************* **
** Descri��o      * Projeto Melhorias Licen�a PF e Melhorias Exercito.                            **
**                * 01- Implementa��o Modelo 3 Cliente x Produtos PF			     		      **
**                * 02- Implementa��o Modelo 3 Cliente x Produtos Exercito                 		  **
****************************************************************************************************
****************************************************************************************************
** Uso             * Comercial - Faturamento, OMS, Call Center 									  **
****************************************************************************************************
** ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL, RELACIONAR ABAIXO CONFORME A PROXIMA LINHA.  **
****************************************************************************************************
** ANALISTA                * DATA      * MOTIVO DA ALTERACAO   	 						   		  **
****************************************************************************************************
****************************************************************************************************
****************************************************************************************************
*/

#INCLUDE "PROTHEUS.CH"
#include "Rwmake.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#DEFINE X3_USADO_EMUSO "���������������"
#DEFINE X3_USADO_NAOUSADO "���������������"
#DEFINE X3_OBRIGA "��"
#DEFINE X3_NAOOBRIGA "��"
#define STR0004 "Quanto �s altera��es?"

/*
*********************************************************************************
*********************************************************************************
*********************************************************************************
*********************************************************************************
** Fun��o    * AFAT008A  * Autor * CHAUS CONSULTORIA  *       Data 18/03/2013  **
*********************************************************************************
*********************************************************************************
** Descri��o * Funcao Cadastro de Cliente x Licenca x Orgao Responsavel (ZP1)  **
*********************************************************************************
** Uso       * Projeto Melhorias Licen�a PF e Melhorias Exercito.		       **
*********************************************************************************
*********************************************************************************
*********************************************************************************
*********************************************************************************
*/

User Function AFAT008A()

/*
*************************************************************************
**  Declaracao de Variaveis                                            **
*************************************************************************
*/

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZP1"

dbSelectArea("ZP1")
dbSetOrder(1)

AxCadastro(cString,"Cliente x Licenca x Orgao Responsavel (ZP1)",cVldExc,cVldAlt)

//AxCadastro(cString,"Cliente x Licenca x Orgao Responsavel (ZP1)",cVldExc,'U_AFATVldInc()')

Return



/*
****************************************************************************************
****************************************************************************************
****************************************************************************************
****************************************************************************************
** Fun��o    * AFAT008B  * Autor * CHAUS CONSULTORIA  *       Data 18/03/2013  		  **
****************************************************************************************
****************************************************************************************
** Descri��o * Funcao Cadastro Produto x Cliente x Licenca x Orgao Responsavel (ZP2)  **
****************************************************************************************
** Uso       * Projeto Melhorias Licen�a PF e Melhorias Exercito.		       		  **
****************************************************************************************
****************************************************************************************
****************************************************************************************
****************************************************************************************
*/

User Function AFAT008B()


/*
*************************************************************************
**  Declaracao de Variaveis                                            **
*************************************************************************
*/

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZP2"

dbSelectArea("ZP2")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Produto x Cliente x Licenca x Orgao Responsavel (ZP2)",cVldExc,cVldAlt)

Return




Static Function VDTValCli(_TpVal,cCliente,cLoja,sData)
Local cQryCli
Local nRet := " "

cQryCli	:=" SELECT ZP1_DTVLD, ZP1_DTPROT , ZP1_LICENC, ZP1_PROTOC "
cQryCli	+=" FROM "+RetSqlName("ZP1")+" ZP1  "
cQryCli	+=" WHERE ZP1.D_E_L_E_T_ = ' '  "
cQryCli	+="			AND ZP1_FILIAL = '"+xFilial("ZP1")+"' "
cQryCli	+="			AND ZP1_CODCLI = '"+cCliente+"' "
cQryCli	+="			AND ZP1_LOJA   = '"+cLoja+"' "
If _TpVal ="PF"
	cQryCli	+="		AND ZP1_ORGAO = '1' "
ElseIf _TpVal ="EX"
	cQryCli	+=" AND ZP1_ORGAO = '2' "
ElseIf _TpVal ="PC"
	cQryCli	+=" AND ZP1_ORGAO = '3' "
EndIf
If Select("QRYCLI") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
	dbSelectArea("QRYCLI")
	dbCloseArea()
Endif

cQryCli:=ChangeQuery(cQryCli)
TcQuery cQryCli New Alias "QRYCLI"
QRYCLI->(DbGotop())
teste := " "
If Eof() // Nao tem registro
	teste := " "
	nRet := "SR"
ElseIf QRYCLI->ZP1_DTVLD < sData //.and.  QRYCLI->ZP1_DTPROT <  sData
	nRet := "VE"      //LICENCA VENCIDA PF
//ElseIf QRYCLI->ZP1_DTPROT >= sData .and. empty(QRYCLI->ZP1_PROTOC)
//	nRet := "SPVE"     //SEM NUMERO DE PROTOCOLO PF !!"
ElseIf QRYCLI->ZP1_DTVLD >= sData  .and.  empty(QRYCLI->ZP1_LICENC) //Esta dentro da Validade verifica se tem Licenca preenchida
	nRet := "SLVE"         //SEM NUMERO LICENCA PF !!
EndIf

dbSelectArea("QRYCLI")
dbCloseArea()

Return(nRet)

Static Function VDTValPRD(_TpVal,cCliente,cLoja,sData,_CodTip)
Local cQryCli
Local nRet := " "

cQryCli	:=" SELECT ZP2_DTVLD, ZP2_LICENC, ZP2_CODTIP, ZP2_DESCTP "
cQryCli	+=" FROM "+RetSqlName("ZP2")+" ZP2  "
cQryCli	+=" WHERE ZP2.D_E_L_E_T_ = ' '  "
cQryCli	+="			AND ZP2_FILIAL = '"+xFilial("ZP2")+"' "
cQryCli	+="			AND ZP2_CODCLI = '"+cCliente+"' "
cQryCli	+="			AND ZP2_LOJA   = '"+cLoja+"' "
cQryCli	+="			AND ZP2_CODTIP   = '"+_CodTip+"' "
If _TpVal ="PF"
	cQryCli	+="		AND ZP2_ORGAO = '1' "
ElseIf _TpVal ="EX"
	cQryCli	+=" AND ZP2_ORGAO = '2' "
ElseIf _TpVal ="PC"
	cQryCli	+=" AND ZP2_ORGAO = '3' "
EndIf
If Select("QRYCLI") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
	dbSelectArea("QRYCLI")
	dbCloseArea()
Endif

cQryCli:=ChangeQuery(cQryCli)
TcQuery cQryCli New Alias "QRYCLI"
QRYCLI->(DbGotop())
teste := " "
If Eof() // Nao tem registro
	teste := " "
	nRet := "SR"
ElseIf  empty(QRYCLI->ZP2_LICENC) //Esta dentro da Validade verifica se tem Licenca preenchida
	nRet := "SLVE"         //SEM NUMERO LICENCA PF !!
EndIf

dbSelectArea("QRYCLI")
dbCloseArea()

Return(nRet)


User Function VlTrPFEX(_cTransp,sData,_TpVal,lMMen)
//Local _Ret 		:= .T.
Local _Ret 		:= {}
Local _aArea 	:=GetArea()



DbSelectarea("SA4")
DbSetorder(1)
DbSeek(xFilial("SA4")+_cTransp,.t.)
If !found()
	Add(_Ret,{.F.,""})
	If lMMen
		MSGBOX("Codigo da Transportadora inexistente !!","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
	EndIf
Else
	teste :=  " "
	If _TpVal="PF" .and. !IsBlind()
		teste := " "
		
		If empty(DtoS(SA4->A4_XPFDT))
			If lMMen
				MSGBOX("SEM NUMERO DE LICENCA - TRANSPORTADORA PF !! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta sem numero de licenca preenchido ","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
			AADD(_Ret,{.F.,"SEM NUMERO DE LICENCA - TRANSPORTADORA PF "})
			//_Ret := .F.
			
		ElseIf 	DtoS(SA4->A4_XPFDT) < sData .and. DtoS(SA4->A4_DTPROTP) < sData
			If lMMen
				MSGBOX("LICENCA VENCIDA TRANSPORTADORA PF !! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta com a licenca Vencida na Policia Federal","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
			AADD(_Ret,{.F.,"LICENCA VENCIDA TRANSPORTADORA PF !!"})
			//	_Ret := .F.
		ElseIf DtoS(SA4->A4_DTPROTP) >= sData .and. empty(SA4->A4_XNUMPRO)
			If lMMen
				MSGBOX("SEM NUMERO DE PROTOCOLO PF !! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta sem  numero na Policia Federal","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
			AADD(_Ret,{.F.,"SEM NUMERO DE PROTOCOLO PF !!"})
			//_Ret := .F.
		ElseIf DtoS(SA4->A4_XPFDT) >= sData .and. empty(SA4->A4_XNUMPF)
			If lMMen
				MSGBOX("SEM NUMERO DE LICENCA - TRANSPORTADORA PF !! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta sem numero de licenca preenchido ","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
			AADD(_Ret,{.F.,"SEM NUMERO DE LICENCA - TRANSPORTADORA PF !!"})
			//_Ret := .F.
		EndIf
	ElseIf _TpVal="EX"
		teste := " "
		If 	Dtos(SA4->A4_XDTME) < sData .and. DtoS(SA4->A4_XDTPME) < sData
			//	_Ret := .F.
			AAdd(_Ret,{.F.,"LICENCA VENCIDA TRANSPORTADORA ME!!"})
			If lMMen
				MSGBOX("LICENCA VENCIDA TRANSPORTADORA ME!! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta com a licenca Vencida no Ministerio do Exercito ","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
		ElseIf DtoS(SA4->A4_XDTPME) >= sData .and. empty(SA4->A4_XNUMPME)
			If lMMen
				MSGBOX("SEM NUMERO DE PROTOCOLO EXERCITO !! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta sem  numero de protocolo do exercito ","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
			AADD(_Ret,{.F.,"SEM NUMERO DE PROTOCOLO EXERCITO !! "})
			//_Ret := .F.
		ElseIf Dtos(SA4->A4_XDTME) >= sData .and. empty(SA4->A4_XNUMME)
			If lMMen
				MSGBOX("SEM NUMERO DE LICENCA - TRANSPORTADORA ME !! "+" A Transportadora "+SA4->A4_COD+"-"+Ltrim(Rtrim(SA4->A4_NOME))+;
				" Esta sem numero de licenca preenchido ","Validacao PF-UPDCHAUS.PRW-Carvalhaes","STOP")
			EndIf
			AADD(_Ret,{.F.,"SEM NUMERO DE PROTOCOLO EXERCITO !! "})
			//_Ret := .F.
		EndIf
	EndIf
EndIf

If  len(_Ret) = 0
	AADD(_Ret,{.T.,""})
EndIf
RestArea(_aArea)
Return(_Ret)

User Function VlDPFEX(cCliente,cLoja,cProd,sData,cAlias,nQtde,_TpVal,lMMen,_Orig)
//Local _Ret 		:= .T.
Local _Ret 		:= {}
Local _aArea 	:=GetArea()
Local aTpPro 	:= {}
Local _CodTip 	:= " "
Local _QtdPer  	:= 0
Local _QtJaVen 	:= 0
Local _2UnMed  	:= POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_SEGUM")
Local _FtConv   := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CONV")
Local _TpConv	:= POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_TIPCONV")
Local _DescTpP
Local _VlDtLiCl

aTpPro  := RetTpXPro(cProd,_TpVal)
_CodTip := aTpPro[1][1]
_QtdPer := aTpPro[1][2]
_DescTpP  := POSICIONE("ZP0",1,xFilial("ZP0")+_CodTip+"1","ZP0_DESCTP")
_VlDtLiCl := VDTValCli(_TpVal,cCliente,cLoja,sData)
teste := " "

SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1") + cProd))
SA1->(DbSetOrder(1))
SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja))

aRetBlq := StrTokarr2(GetMV("MV_CRVBPF"),"|")
aRetBlq[03] := CtoD(aRetBlq[03])
If Len(_Ret) == 0 .and. aRetBlq[02] == "S" .and. MsDate() >= aRetBlq[03] .and. Alltrim(SB1->B1_CRVPF) $ aRetBlq[04]
	IF Alltrim(cFilAnt) $ aRetBlq[01] .or. Left(SA1->A1_CGC,12) == "0153050100"+aRetBlq[01]
		AADD(_Ret,{.F.,"FILIAL BLOQUEADA PF"})
		teste := " "
		If lMMen
			MSGBOX("Est� habilitado o bloqueio para venda de produtos com Controle da PF nesta(ou para esta) Filial.","STOP")
		EndIf
	Endif
Endif

aRetBlq := StrTokarr2(GetMV("MV_CRVBORG"),"|")
aRetBlq[03] := CtoD(aRetBlq[03])
If Len(_Ret) == 0 .and. aRetBlq[02] == "S" .and. MsDate() >= aRetBlq[03] .and. Alltrim(SB1->B1_ORG_ANU) $ aRetBlq[04]
	IF Alltrim(cFilAnt) $ aRetBlq[01] .or. Left(SA1->A1_CGC,12) == "0153050100"+aRetBlq[01]
		AADD(_Ret,{.F.,"FILIAL BLOQUEADA ORG ANU"})
		teste := " "
		If lMMen
			MSGBOX("Est� habilitado o bloqueio para venda de produtos destes Org�os Anuentes nesta(ou para esta) Filial.","STOP")
		EndIf
	Endif
Endif

aRetBlq := StrTokarr2(GetMV("MV_CRVBME"),"|")
aRetBlq[03] := CtoD(aRetBlq[03])
If Len(_Ret) == 0 .and. aRetBlq[02] == "S" .and. MsDate() >= aRetBlq[03] .and. Alltrim(SB1->B1_CRVME) $ aRetBlq[04]
	IF Alltrim(cFilAnt) $ aRetBlq[01] .or. Left(SA1->A1_CGC,12) == "0153050100"+aRetBlq[01]
		AADD(_Ret,{.F.,"FILIAL BLOQUEADA ME"})
		teste := " "
		If lMMen
			MSGBOX("Est� habilitado o bloqueio para venda de produtos com Controle ME nesta(ou para esta) Filial.","STOP")
		EndIf
	Endif
Endif

aRetBlq := StrTokarr2(GetMV("MV_CRVBPC"),"|")
aRetBlq[03] := CtoD(aRetBlq[03])
If Len(_Ret) == 0 .and. aRetBlq[02] == "S" .and. MsDate() >= aRetBlq[03] .and. Alltrim(SB1->B1_XCIVSP) $ aRetBlq[04]
	IF Alltrim(cFilAnt) $ aRetBlq[01] .or. Left(SA1->A1_CGC,12) == "0153050100"+aRetBlq[01]
		AADD(_Ret,{.F.,"FILIAL BLOQUEADA POL.CIV."})
		teste := " "
		If lMMen
			MSGBOX("Est� habilitado o bloqueio para venda de produtos com Controle da Pol�cia Civil nesta(ou para esta) Filial.","STOP")
		EndIf
	Endif
Endif


IF Len(_Ret) == 0
	If cCliente $ GetMv("MV_XCLITRA")  // operacao com filial
		
	Else
		If _TpVal="PF" .and. !IsBlind()
			/*
			Policia Federal
			1) Se o cliente nao estiver no cadastro, ver quantidade minina do tipo de produtos
			2) Se o cliente estetivar cadastrado nao precisa ver limite + precisa ver data de vencimento e se  tem grupo associado ao cliente contrario prioreidad 1
			*/
			teste := " "
			If  empty(_VlDtLiCl) .and. .F.	 //Valida a data de validade da licenca, se estiver vazio esta tudo OK com a licenca
				teste := " "
				If RetTpxCli(cCliente,cLoja,_CodTip,_TpVal) > 0
					_QtdPer := 99999999999.99   //Nao tem limite para o Tipo de Produto x Cliente
				EndIf
				teste := " "
				_QtJaVen := RetQtdVen(cCliente,cLoja,sData,cProd,nQtde,_FtConv,_TpConv,_CodTip)
				teste := " "
				If .t.//_QtJaVen >_QtdPer
					AADD(_Ret,{.F.,"NAO POSSUI LICENCA PARA ESTE GRUPO"})
					//_Ret := .F.
					If lMMen
						MSGBOX("NAO POSSUI LICENCA PARA ESTE GRUPO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						"Validacao PF 01 -UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
	//					" controlado pela PF,estourou a cota mensal de compra maxima para este produto e de "+;
	//					Ltrim(Rtrim(Str(_QtdPer)))+" "+_2UnMed,"Validacao PF 01 -UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				EndIf
				Teste := " "
			Else  //Nao tem registro ou data de validade vencida, pega o valor minimo
				teste := " "
				_QtJaVen := RetQtdVen(cCliente,cLoja,sData,cProd,nQtde,_FtConv,_TpConv,_CodTip)
				teste := " "
				If .t. //_QtJaVen >_QtdPer
					//_Ret := .F.
					
					If _VlDtLiCl="VE"   //Data de validade vencida
						AADD(_Ret,{.F.,"LICENCA VENCIDA PF"})
						teste := " "
						If lMMen
							MSGBOX("LICENCA VENCIDA PF !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto: "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PF","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIf _VlDtLiCl="VP"
						teste := " "
						AADD(_Ret,{.F.,"LICENCA VENCIDA PF E PROTOCOLO VENCIDO !!"})
						If lMMen
							MSGBOX("LICENCA VENCIDA PF E PROTOCOLO VENCIDO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PF","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIf _VlDtLiCl="SPVE"
						teste := " "
						AADD(_Ret,{.F.,"SEM NUMERO DE PROTOCOLO PF !!"})
						If lMMen
							MSGBOX("SEM NUMERO DE PROTOCOLO PF !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PF","Validacao PF-UPDCHAUS"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIf _VlDtLiCl="SLVE"
						AADD(_Ret,{.F.,"SEM NUMERO LICENCA PF !!"})
						If lMMen
							MSGBOX("SEM NUMERO LICENCA PF !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PF","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIF _VlDtLiCl="SR"  
						teste := " "
						AADD(_Ret,{.F.,"NAO POSSUI LICENCA PF !!"})
						If lMMen
							MSGBOX("NAO POSSUI LICENCA PF !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PF, estourou a cota mensal de compra maxima de "+;
							ltrim(rtrim(Str(_QtdPer)))+" "+_2UnMed,"Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ELSE
						// VALIDA TIPO DE PRODUTO
						_VlDtLiCl:=VDTValPRD(_TpVal,cCliente,cLoja,sData,_CodTip)

						If _VlDtLiCl="VE"   //Data de validade vencida
							AADD(_Ret,{.F.,"LICENCA VENCIDA PF TIPO PRODUTO"})
							teste := " "
							If lMMen
								MSGBOX("LICENCA VENCIDA PF TIPO PRODUTO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto: "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
								" controlado pela PF","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
							EndIf
						ElseIf _VlDtLiCl="SLVE"
							AADD(_Ret,{.F.,"SEM NUMERO LICENCA PF TIPO PRODUTO !!"})
							If lMMen
								MSGBOX("SEM NUMERO LICENCA PF TIPO PRODUTO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
								" controlado pela PF","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
							EndIf
						ElseIF _VlDtLiCl="SR"  
							teste := " "
							AADD(_Ret,{.F.,"NAO POSSUI LICENCA PF TIPO PRODUTO !!"})
							If lMMen
								MSGBOX("NAO POSSUI LICENCA PF  TIPO PRODUTO!! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
								" controlado pela PF, estourou a cota mensal de compra maxima de "+;
								ltrim(rtrim(Str(_QtdPer)))+" "+_2UnMed,"Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
							EndIf
						Endif
					EndIf
				EndIf
				teste := " "
			EndIf
		ElseIf _TpVal="PC" .and. !IsBlind() .AND. .F. //DESABILITADO EM 24/08/22 
			/*
			Policia CIVIL SP
			1) Se o cliente nao estiver no cadastro, ver quantidade minina do tipo de produtos
			2) Se o cliente estetivar cadastrado nao precisa ver limite + precisa ver data de vencimento e se  tem grupo associado ao cliente contrario prioreidad 1
			*/
			teste := " "
			If  empty(_VlDtLiCl) .and. .F.	 //Valida a data de validade da licenca, se estiver vazio esta tudo OK com a licenca
				teste := " "
				teste := " "
				teste := " "
				If .t.//_QtJaVen >_QtdPer
					AADD(_Ret,{.F.,"NAO POSSUI LICENCA PARA ESTE GRUPO PC"})
					//_Ret := .F.
					If lMMen
						MSGBOX("NAO POSSUI LICENCA PARA ESTE GRUPO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						"Validacao POLICIA CIVIL - SP 01 -UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
	//					" controlado pela PF,estourou a cota mensal de compra maxima para este produto e de "+;
	//					Ltrim(Rtrim(Str(_QtdPer)))+" "+_2UnMed,"Validacao PF 01 -UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				EndIf
				Teste := " "
			Else  //Nao tem registro ou data de validade vencida, pega o valor minimo
				teste := " "
				_QtJaVen := RetQtdVen(cCliente,cLoja,sData,cProd,nQtde,_FtConv,_TpConv,_CodTip)
				teste := " "
				If .f. //_QtJaVen >_QtdPer  //desabilitado 24/08;22
					//_Ret := .F.
					
					If _VlDtLiCl="VE"   //Data de validade vencida
						AADD(_Ret,{.F.,"LICENCA VENCIDA PF"})
						teste := " "
						If lMMen
							MSGBOX("LICENCA VENCIDA PF !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto: "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PC-SP","Validacao PC-SP-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIf _VlDtLiCl="VP"
						teste := " "
						AADD(_Ret,{.F.,"LICENCA VENCIDA PC-SP E PROTOCOLO VENCIDO !!"})
						If lMMen
							MSGBOX("LICENCA VENCIDA PF E PROTOCOLO VENCIDO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PC-SP","Validacao PC-SP-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIf _VlDtLiCl="SPVE"
						teste := " "
						AADD(_Ret,{.F.,"SEM NUMERO DE PROTOCOLO PC-SP !!"})
						If lMMen
							MSGBOX("SEM NUMERO DE PROTOCOLO PC-SP !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PC-SP","Validacao PC-SP-UPDCHAUS"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIf _VlDtLiCl="SLVE"
						AADD(_Ret,{.F.,"SEM NUMERO LICENCA PC-SP !!"})
						If lMMen
							MSGBOX("SEM NUMERO LICENCA PC-SP !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PC-SP","Validacao PC-SP-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					ElseIF _VlDtLiCl="SR"  
						teste := " "
						AADD(_Ret,{.F.,"NAO POSSUI LICENCA PC-SP !!"})
						If lMMen
							MSGBOX("NAO POSSUI LICENCA PC-SP !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela PF, estourou a cota mensal de compra maxima de "+;
							ltrim(rtrim(Str(_QtdPer)))+" "+_2UnMed,"Validacao PC-SP-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					EndIf
				EndIf
				teste := " "
			EndIf
		ElseIf _TpVal="EX"
			/* 1)Se nao tiver licenca ou licenca vencida nao pode vender.
			2)Tem que validar por pediod/nota/etc
			3) Bloqueio de todos os produtos que nao esta na licenca do cliente
			*/
			teste := " "
			If empty(_VlDtLiCl)	 //Tem licenca
				_QtdPer := RetTpxCli(cCliente,cLoja,_CodTip,_TpVal)
				teste := " "
				If nQtde > _QtdPer .AND. .F.   // TIRADO VALIDA��O DE QUANTIDA SE H� LICEN�A RICARDO 22/04/19
					//	_Ret := .F.
					
					If _QtdPer > 0
						AADD(_Ret,{.F.,"GRUPO/PRODITO ESTOURO FATURAMENTO MAXIMO !!"})
						If lMMen
							
							MSGBOX("EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela Exercito,estourou faturamento maximo para este produto que e de "+;
							Ltrim(Rtrim(Str(_QtdPer)))+" "+_2UnMed,"Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					Else
						AADD(_Ret,{.F.,"SEM LICENCA DO EXERCITO !!"})
						If lMMen
							MSGBOX("EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
							" controlado pela Exercito nao tem licenca ","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
						EndIf
					EndIf
				EndIf
			Else
				//_Ret := .F.
				If _VlDtLiCl="VE"   //Data de validade vencida
					AADD(_Ret,{.F.,"LICENCA VENCIDA EXERCITO !!"})
					If lMMen
						MSGBOX("LICENCA VENCIDA EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						" controlado pela EXERCITO","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				ElseIf _VlDtLiCl="VP //Protocolo vencido
					AADD(_Ret,{.F.,"PROTOCOLO E LICENCA VENCIDA EXERCITO !!"})
					If lMMen
						MSGBOX("PROTOCOLO E LICENCA VENCIDA EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						" controlado pela EXERCITO","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				ElseIf _VlDtLiCl="SPVE"
					teste := " "
					AADD(_Ret,{.F.,"SEM NUMERO DE PROTOCOLO EXERCITO !!"})
					If lMMen
						MSGBOX("SEM NUMERO DE PROTOCOLO EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						" controlado pela EXERCITO","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				ElseIf _VlDtLiCl="SLVE"
					teste := " "
					AADD(_Ret,{.F.,"SEM NUMERO LICENCA EXERCITO !!"})
					If lMMen
						MSGBOX("SEM NUMERO LICENCA EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						" controlado pela EXERCITO ","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				Else  //Nao posui licenca
					AADD(_Ret,{.F.,"NAO POSSUI LICENCA EXERCITO !!"})
					If lMMen
						MSGBOX("NAO POSSUI LICENCA EXERCITO !! - Cliente: "+LTrim(Rtrim(cCliente))+" Produto : "+LTrim(Rtrim(cProd))+" do Grupo/Tipo "+Ltrim(Rtrim(_CodTip))+"-"+Ltrim(Rtrim(_DescTpP))+;
						" controlado pela EXERCITO ","Validacao PF-UPDCHAUS/"+LTRIM(Rtrim(_Orig))+"-Carvalhaes","STOP")
					EndIf
				EndIf
			EndIf
		EndIf
	Endif
Endif

If  LEn(_Ret)=0
	AADD(_Ret,{.T.,""}) //Retorno, Tipo de Erro"
EndIf

RestArea(_aArea)
Return(_Ret)


Static Function RetQtdVen(cCliente,cLoja,sData,cProd,nQtde,_FtConv,_TpConv,_CodTip)
Local _nRet := 0

teste := " "

cQrySD2	:=" SELECT SUM(CASE WHEN SB1.B1_TIPCONV = 'M'  "
cQrySD2	+=" 				THEN  SD2.D2_QUANT * SB1.B1_CONV "
cQrySD2	+="					ELSE SD2.D2_QUANT / SB1.B1_CONV  END)   AS QTDEMES, "
cQrySD2	+="			MAX(SB1.B1_TIPCONV) 							AS TIPCONV, "
cQrySD2	+="			MAX(SB1.B1_CONV)								AS CONV  "
cQrySD2	+=" FROM "+RetSqlName("SD2")+" SD2 INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+XFILIAL("SB1")+"' AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "  //ALTERADO POR DYEGO 09/07/14
cQrySD2	+="									INNER JOIN "+RetSqlName("ZP4")+" ZP4 ON SD2.D2_FILIAL = ZP4.ZP4_FILIAL AND SD2.D2_COD = ZP4.ZP4_CODPRO AND ZP4.D_E_L_E_T_ = SD2.D_E_L_E_T_ "
cQrySD2	+="									INNER JOIN "+RetSqlName("SF4")+" SF4 ON  SF4.F4_FILIAL = '"+XFILIAL("SF4")+"' AND SD2.D2_TES = SF4.F4_CODIGO AND SD2.D_E_L_E_T_ = SF4.D_E_L_E_T_  " //ALTERADO POR DYEGO 7/8/14
cQrySD2	+=" WHERE   	SD2.D_E_L_E_T_				= ' ' "
cQrySD2	+="			AND SD2.D2_FILIAL				= '"+xFilial("SD2")+ "' "
cQrySD2 +=" 		AND SD2.D2_CLIENTE				= '"+cCliente+"' "
cQrySD2 +=" 		AND SD2.D2_LOJA					= '"+cLoja+"' "
cQrySD2 +=" 		AND SUBSTRING(SD2.D2_EMISSAO,1,6)	= '"+substring(sData,1,6)+"' "
cQrySD2 +=" 		AND SD2.D2_TIPO ='N' "
cQrySD2 +=" 		AND SB1.B1_CONV <> 0  "
cQrySD2 +=" 		AND ZP4.ZP4_CODTIP = '"+_CodTip+"' "
cQrySD2 +="			AND SF4.F4_ESTOQUE = 'S' "


teste := " "
If Select("QRYSD2") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
	dbSelectArea("QRYSD2")
	dbCloseArea()
Endif
cQrySD2:=ChangeQuery(cQrySD2)
TcQuery cQrySD2 New Alias "QRYSD2"
QRYSD2->(DbGotop())
TESTE := " "
_nRet:=QRYSD2->QTDEMES + IIF(_TpConv="M",_FtConv*nQtde,nQtde/_FtConv)
teste := " "
dbSelectArea("QRYSD2")
dbCloseArea()

Return(_nRet)



Static Function RetTpXPro(cProd,_TpVal)
Local _aRet := {}
Local cQryTp

cQryTp := " SELECT ZP4_CODTIP, "
cQryTp += "		ZP4_QTDPER "
cQryTp += " FROM "+RetSqlName("ZP4")+" ZP4 "
cQryTp += " WHERE ZP4.D_E_L_E_T_ = ' ' "
cQryTp +="			AND ZP4_CODPRO ='"+cProd+"'  "
If _TpVal ="PF"
	cQryTp	+="		AND ZP4_ORGAO = '1' "
ElseIf _TpVal ="EX"
	cQryTp	+=" AND ZP4_ORGAO = '2' "
EndIf


If Select("QRYTP") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
	dbSelectArea("QRYTP")
	dbCloseArea()
Endif
cQryTp:=ChangeQuery(cQryTp)
TcQuery cQryTp New Alias "QRYTP"
QRYTP->(DbGotop())
AADD(_aRet,{QRYTP->ZP4_CODTIP,QRYTP->ZP4_QTDPER})
dbSelectArea("QRYTP")
dbCloseArea()

Return(_aRet)

Static Function RetTpxCli(cCliente,cLoja,cTipPro,_TpVal)
Local _aRet :=0
Local cQTpCli

cQTpCli :=" SELECT ZP2.ZP2_CODTIP, "
cQTpCli +="		ZP0.ZP0_QTDMAX  "
cQTpCli +=" FROM "+RetSqlName("ZP2")+" ZP2 INNER JOIN "+RetSqlName("ZP0")+" ZP0 ON ZP2.ZP2_FILIAL = ZP0.ZP0_FILIAL AND ZP2.ZP2_CODTIP  = ZP0.ZP0_CODTIP AND ZP2.ZP2_ORGAO = ZP0.ZP0_ORGAO AND ZP2.D_E_L_E_T_ = ZP0.D_E_L_E_T_ "
cQTpCli +=" WHERE ZP2.D_E_L_E_T_ = ' ' "
cQTpCli +="			AND ZP2.ZP2_FILIAL = '"+xFilial("ZP2")+"' "
cQTpCli +="			AND ZP2.ZP2_CODCLI = '"+cCliente+"' "
cQTpCli +="			AND ZP2.ZP2_LOJA  = '"+cLoja+"' "
If _TpVal ="PF"
	cQTpCli	+="		AND ZP2_ORGAO = '1' "
ElseIf _TpVal ="EX"
	cQTpCli	+=" 	AND ZP2_ORGAO = '2' "
ElseIf _TpVal ="PC"
	cQTpCli	+=" 	AND ZP2_ORGAO = '4' "
EndIf
cQTpCli +="			AND ZP2.ZP2_CODTIP = '"+cTipPro+"' "
If Select("QTPCLI") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
	dbSelectArea("QTPCLI")
	dbCloseArea()
Endif
cQTpCli:=ChangeQuery(cQTpCli)
TcQuery cQTpCli New Alias "QTPCLI"
QTPCLI->(DbGotop())
If !Eof()
	_aRet := QTPCLI->ZP0_QTDMAX
EndIf

dbSelectArea("QTPCLI")
dbCloseArea()
Return(_aRet)




/*
*********************************************************************************
*********************************************************************************
*********************************************************************************
*********************************************************************************
** Fun��o    * AFAT008C  * Autor * CHAUS CONSULTORIA  *       Data 18/03/2013  **
*********************************************************************************
*********************************************************************************
** Descri��o * Fun��o Tela de Cadastro ZP1/ZP2                                 **
*********************************************************************************
** Uso       * Projeto Melhorias Licen�a PF e Melhorias Exercito.		       **
*********************************************************************************
*********************************************************************************
*********************************************************************************
*********************************************************************************
*/

User Function AFAT008C()

Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oPanelDown, oFWLayer, oBrowseUp, oBrowseDown, oRelacZP1
Private oDlgPrinc
Private cCadastro := 'Licen�a Policia Federal / Licen�a Exercito'
PRIVATE aRotina := MenuDef()
Define MsDialog oDlgPrinc Title 'Licen�a Policia Federal / Licen�a Exercito' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel


PRIVATE aREOPEN	 	:= {}
PRIVATE _data 		:= DATE()
PRIVATE lexec		:= .F.
Private oProcess  	:= NIL
//PRIVATE oMainWnd
Set Dele On

//
// Cria o conteiner onde ser�o colocados os browses
//

oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )
//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 50, .F. )
// Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

// Pego o objeto desse peda�o do container
//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 50, .F. )
// Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'DOWN' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela

oPanelDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )
// Pego o objeto desse peda�o do container

//
// FWmBrowse Superior Albuns
//
oBrowseUp:= FWmBrowse():New()

oBrowseUp:SetOwner( oPanelUp )
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( 'Tabela Cliente x Licenca x Orgao Responsavel (ZP1).' )
oBrowseUp:DisableDetails()
oBrowseUp:SetAlias( 'ZP1' )
oBrowseUp:SetMenuDef( 'AFAT008C' )
// Define de onde virao os botoes deste browse
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
//oBrowseUp:AddButton( "INCLUIR", U_AFAT008A(),,3,0,.F.,,,)


oBrowseUp:Activate()







//
// Lado Esquerdo Musicas
//
oBrowseDown:= FWMBrowse():New()
oBrowseDown:SetOwner( oPanelDown )
oBrowseDown:SetDescription( 'Tabela Produto x Cliente x Licenca x Orgao Responsavel (ZP2).' )
oBrowseDown:SetMenuDef( '' )
// Referencia vazia para que nao exiba nenhum botao
oBrowseDown:DisableDetails()
oBrowseDown:SetAlias( 'ZP2' )
oBrowseDown:SetProfileID( '2' )
//oBrowseDown:AddButton( "INCLUIR", U_AFAT008B(),,3,0,.F.,,,)
oBrowseDown:Activate()

//
// Relacionamento entre os Paineis
//

oRelacZP1:= FWBrwRelation():New()
oRelacZP1:AddRelation( oBrowseUp  , oBrowseDown , { { 'ZP2_FILIAL', 'xFilial( "ZP2" )' }, { 'ZP2_CODCLI', 'ZP1_CODCLI' }, { 'ZP2_LOJA', 'ZP1_LOJA' }, { 'ZP2_LICENC', 'ZP1_LICENC' }, { 'ZP2_ORGAO', 'ZP1_ORGAO' }} )
//, { 'ZP2_DTVLD', 'ZP1_DTVLD' } } )
//oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, { { 'ZA5_FILIAL', 'xFilial( "ZA5" )' }, { 'ZA5_ALBUM' , 'ZA4_ALBUM'  }, { 'ZA5_MUSICA', 'ZA4_MUSICA' } } )


oRelacZP1:Activate()
Activate MsDialog oDlgPrinc Center
Return NIL
//-------------------------------------------------------------------



Static Function MenuDef()

Local aRotina := {}
//AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})
//AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"U_AxAlt",0,4})
AADD(aRotina,{"Excluir" ,"U_AxDel",0,5})
//AADD(aRotina,{"Copiar " ,"U_AxCop1",0,3})

Return aRotina


Static Function ModelDef()

Local oStruZP1 := FWFormStruct(1,'ZP1')
Local oStruZP2 := FWFormStruct(1,'ZP2')
Local oModel

oModel := MPFormModel():New('MVC_001')


oModel:AddFields('ZP1MASTER',/*cOwner*/,oStruZP1)
oModel:AddGrid('ZP2DETAIL','ZP1MASTER',oStruZP2)

oModel:SetRelation( 'ZP2DETAIL', { { 'ZP2_FILIAL', 'xFilial( "ZP2" )' }, { 'ZP2_CODCLI', 'ZP1_CODCLI' }, { 'ZP2_LOJA', 'ZP1_LOJA' }, { 'ZP2_LICENC', 'ZP1_LICENC' }, { 'ZP2_DTVLD', 'ZP1_DTVLD' }, { 'ZP2_ORGAO', 'ZP1_ORGAO' } }, ZP2->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({'ZP1_FILIAL','ZP1_CODCLI','ZP1_LOJA','ZP1_ORGAO'})
//oModel:SetPrimaryKey({'ZP1_FILIAL','ZP1_CODCLI','ZP1_LOJA','ZP1_LICENC','ZP1_DTVLD','ZP1_ORGAO'})

oModel:SetDescription('Tabela Cliente x Licenca x Orgao Responsavel (ZP1).')

oModel:GetModel('ZP1MASTER'):SetDescription('Tabela Cliente x Licenca x Orgao Responsavel (ZP1).')
oModel:GetModel('ZP2DETAIL'):SetDescription('Tabela Produto x Cliente x Licenca x Orgao Responsavel (ZP2).')

Return oModel

Static Function ViewDef()

Local oModel := FWLoadModel('MVC_001')

Local oStruZP1:= FWFormStruct(2,'ZP1')
Local oStruZP2:= FWFormStruct(2,'ZP2')
Local oViewDef:=FWFormView():New()


oViewDef:SetModel(oModel)

oViewDef:AddField('VIEW_ZP1',oStruZP1,'ZP1MASTER')
oView:AddGrid('VIEW_ZP2',oStruZP2,'ZP2DETAIL' )

oViewDef:CreateHorixontalBox('TELA1',100)
oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'INFERIOR', 85 )

oViewDef:CreateHorixontalBox('TELA2',100)
oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'INFERIOR', 85 )

oViewDef:SetOwnerView('VIEW_ZP1','TELA1')
oViewDef:SetOwnerView('VIEW_ZP2','TELA2')

Return oViewDef


User FUNCTION AxAlt(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cFunc,aButtons,aParam,aAuto,lVirtual,lMaximized,cTela)

Local aArea    := GetArea(cAlias)
Local aPosEnch := {}
Local bCampo   := {|nCPO| Field(nCPO) }
Local bOk      := Nil
Local bOk2     := {|| .T.}
Local cCpoFil  := PrefixoCpo(cAlias)+"_FILIAL"
Local cMemo    := ""
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cAliasMemo
Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
Local oEnc01
Local _cQuery:=""
Private aTELA[0][0]
Private aGETS[0]

DEFAULT lVirtual:= .F.
DEFAULT cTudoOk := ".T."
DEFAULT nReg    := (cAlias)->(RecNO())
DEFAULT bOk := &("{|| "+cTudoOk+"}")
//�������������������������������������������������������������������Ŀ
//� Processamento de codeblock de validacao de confirmacao            �
//���������������������������������������������������������������������
If !Empty(aParam)
	bOk2 := aParam[2]
EndIf
//����������������������������������������������������������������������Ŀ
//�VerIfica se esta' alterando um registro da mesma filial               �
//������������������������������������������������������������������������
DbSelectArea(cAlias)
cCpoFil:="  "
If (cAlias)->(FieldPos(cCpoFil))==0 .Or. (cAlias)->(FieldGet(FieldPos(cCpoFil))) == xFilial(cAlias)
	//��������������������������������������������������������������Ŀ
	//� Monta a entrada de dados do arquivo						     �
	//����������������������������������������������������������������
	If SoftLock(cAlias)
		RegToMemory(cAlias,.F.,lVirtual)
		//�������������������������������������������������������������������Ŀ
		//� Inicializa variaveis para campos Memos Virtuais		 			  �
		//���������������������������������������������������������������������
		If Type("aMemos")=="A"
			For nX:=1 to Len(aMemos)
				cMemo := aMemos[nX][2]
				If ExistIni(cMemo)
					//&cMemo := InitPad(SX3->X3_RELACAO)
				Else
					&cMemo := ""
				EndIf
			Next nX
		EndIf
		//�������������������������������������������������������������������Ŀ
		//� Inicializa variaveis para campos Memos Virtuais		 			  �
		//���������������������������������������������������������������������
		If ( ValType( cFunc ) == 'C' )
			If ( !("(" $ cFunc) )
				cFunc+= "()"
			EndIf
			&cFunc
		EndIf
		//�������������������������������������������������������������������Ŀ
		//� Processamento de codeblock de antes da interface                  �
		//���������������������������������������������������������������������
		If !Empty(aParam)
			Eval(aParam[1],nOpc)
		EndIf
		//������������������������������������������������������Ŀ
		//� Envia para processamento dos Gets				   	 �
		//��������������������������������������������������������
		If aAuto == Nil
			
			If SetMDIChild()
				oMainWnd:ReadClientCoors()
				nTop := 40
				nLeft := 30
				nBottom := oMainWnd:nBottom-80
				nRight := oMainWnd:nRight-70
			Else
				nTop := 135
				nLeft := 0
				nBottom := TranslateBottom(.T.,28)
				nRight := 632
			EndIf
			If FindFunction("ISPDA").and. IsPDA()
				nTop := 0
				nLeft := 0
				nBottom := PDABOTTOM
				nRight  := PDARIGHT
			EndIf
			// Build com corre��o no tratamento dos controles pendentes na dialog ao executar o m�todo End()
			If GetBuild() >= "7.00.060302P"
				bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}
			EndIf
			
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd
			
			If lMaximized <> NIL
				oDlg:lMaximized := lMaximized
			EndIf
			
			If FindFunction("ISPDA").and. IsPDA()
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,     ,"CRA",oemtoansi(STR0004),aAcho,  aPosEnch,aCpos, ,nColMens,If(nColMens != Nil,cMensagem,NIL),cTudoOk,,lVirtual,.t.,,,,,,,,, cTela) //"Quanto �s altera��es?"
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
			Else
				aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}
				If nColMens != Nil
					nOpcA := EnChoice( cAlias, nReg, nOpc, ,"CRA",oemtoansi(STR0004),aAcho,aPosEnch,aCpos,,nColMens,cMensagem,cTudoOk,,lVirtual,,,,,,,,,, cTela) //"Quanto �s altera��es?"
				Else
					nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"CRA",oemtoansi(STR0004),aAcho,aPosEnch,aCpos,,,,cTudoOk,,lVirtual,,,,,,,,,, cTela) //"Quanto �s altera��es?"
				EndIf
			EndIf
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.F.))},{|| nOpcA := 3,oDlg:End()},,aButtons,nReg,cAlias)
		Else
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela) .And. Eval(bOk).And.Eval(bOk2,nOpc)},nOpc,aCpos)
				nOpcA := 1
			EndIf
		EndIf
		(cAlias)->(MsGoTo(nReg))
		If nOpcA == 1
			Begin Transaction
			RecLock(cAlias,.F.)
			For nX := 1 TO FCount()
				FieldPut(nX,M->&(EVAL(bCampo,nX)))
			Next nX
			//�������������������������������������������������������������������Ŀ
			//�Grava os campos Memos Virtuais					  				  �
			//���������������������������������������������������������������������
			If Type("aMemos") == "A"
				For nX := 1 to Len(aMemos)
					cVar := aMemos[nX][2]
					cVar1:= aMemos[nX][1]
					//Inclu�do parametro com o nome da tabela de memos => para m�dulo APT
					cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
					MSMM(&cVar1,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
				Next nX
			EndIf
			If cTransact != Nil
				If !("("$cTransact)
					cTransact+="()"
				EndIf
				&cTransact
			EndIf
			//�������������������������������������������������������������������Ŀ
			//� Processamento de codeblock dentro da transacao                    �
			//���������������������������������������������������������������������
			If !Empty(aParam)
				Eval(aParam[3],nOpc)
			EndIf

			// Verificar se existe registro na ZP2 e faz update da lice�a
			IF cAlias=='ZP1'

				_cQuery := " UPDATE " + RetSqlName("ZP2")
				_cQuery += " SET ZP2_LICENC='"+ZP1->ZP1_LICENC+"', ZP2_DTVLD='"+DTOS(ZP1->ZP1_DTVLD)+"'" 
				_cQuery += " WHERE ZP2_FILIAL ='"+ZP1->ZP1_FILIAL+"' AND ZP2_CODCLI='"+ZP1->ZP1_CODCLI+"' AND ZP2_LOJA='"+ZP1->ZP1_LOJA+"' AND ZP2_ORGAO='"+ZP1->ZP1_ORGAO+"' AND D_E_L_E_T_=' ' "

				TCSQLExec(_cQuery)
				TCSQLExec('COMMIT')

            endif

			End Transaction
			//�������������������������������������������������������������������Ŀ
			//� Processamento de codeblock fora da transacao                      �
			//���������������������������������������������������������������������
			If !Empty(aParam)
				Eval(aParam[4],nOpc)
			EndIf
		EndIf
	Else
		nOpcA := 3
	EndIf
Else
	Help(" ",1,"A000FI")
	nOpcA := 3
EndIf
//�������������������������������������������������������������������Ŀ
//� Restaura a integridade dos dados                                  �
//���������������������������������������������������������������������
MsUnLockAll()
RestArea(aArea)
Return(nOpcA)

User Function AxDel(cAlias,nReg,nOpc,cTransact,aCpos,aButtons,aParam,aAuto,lMaximized,cTela)

Local aArea    := GetArea()
Local aPosEnch := {}
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cMsgError:= ""
Local oEnc01

Private aTELA[0][0]
Private aGETS[0]


// Verificar se existe registro na ZP2
IF cAlias=='ZP1'
	cQueryZP2 :="SELECT COUNT(1) AS TOT "
	cQueryZP2+=  " FROM "+RetSqlName("ZP2")+ " WHERE ZP2_FILIAL ='"+ZP1->ZP1_FILIAL+"' AND ZP2_CODCLI='"+ZP1->ZP1_CODCLI+"' AND ZP2_LOJA='"+ZP1->ZP1_LOJA+"' AND ZP2_LICENC='"+ZP1->ZP1_LICENC+"' AND ZP2_ORGAO='"+ZP1->ZP1_ORGAO+"' AND D_E_L_E_T_=' ' "
	
	If Select("TRBZP2") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
		dbSelectArea("TRBZP2")
		dbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryZP2),'TRBZP2',.F.,.T.)
	nTotRec:=	TRBZP2->TOT
	
	If nTotRec > 0
		msgstop("EXISTE "+STRZERO(nTotrec,6)+" PRODUTOS VINCULADOS A ESTA LICEN�A","Aten��o! N�O FOI POSSIVEL EXCLUIR")
		Return
	EndIf
ENDIF
IF cAlias=='ZP2'

//	_cQuery := " UPDATE " + RetSqlName("ZP4")
//	_cQuery += " SET D_E_L_E_T_='*'" 
//	_cQuery += " WHERE ZP4_FILIAL ='"+ZP2->ZP2_FILIAL+"' AND ZP4_CODTIP='"+ZP2->ZP2_CODTIP+"' AND ZP4_ORGAO='"+ZP4->ZP4_ORGAO+"' AND D_E_L_E_T_=' ' "

//	TCSQLExec(_cQuery)
//	TCSQLExec('COMMIT')


    /*

	cQueryZP2 :="SELECT COUNT(1) AS TOT "
	cQueryZP2+=  " FROM "+RetSqlName("SD2")+ " WHERE D2_FILIAL ='"+xFilial("SD2")+"' AND D2_CLIENTE='"+ZP2->ZP2_CODCLI+"' AND D2_LOJA='"+ZP2->ZP2_LOJA+"' AND D2_COD=(SELECT ZP4_CODPRO FROM ZP4010 WHERE ZP4_CODTIP='"+ZP2->ZP2_CODTIP+"' AND D_E_L_E_T_=' ' )"
//	cQueryZP2+=  " FROM "+RetSqlName("SD2")+ " WHERE D2_FILIAL ='"+xFilial("SD2")+"' AND D2_CLIENTE='"+ZP2->ZP2_CODCLI+"' AND D2_LOJA='"+ZP2->ZP2_LOJA+"' AND D2_COD=(SELECT ZP4_CODPRO FROM ZP4010 WHERE ZP4_CODTIP='"+ZP2->ZP2_CODTIP+"' AND D_E_L_E_T_=' ' LIMIT 1 )"
	
	//SELECT COUNT(1) AS TOT
	//FROM SD2010 WHERE D2_FILIAL ='01' AND D2_CLIENTE='005923' AND D2_LOJA='01' AND D2_COD=(SELECT ZP4_CODPRO FROM ZP4010 WHERE ZP4_CODTIP='"+ZP2->ZP2_CODTIP' AND D_E_L_E_T_=' ' LIMIT 1 )
	
	
	If Select("TRBSD2") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
		dbSelectArea("TRBSD2")
		dbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryZP2),'TRBSD2',.F.,.T.)
	nTotRec:=	TRBSD2->TOT
	
	If nTotRec > 0
		msgstop("EXISTE "+STRZERO(nTotrec,6)+" REGISTROS DE VENDAS VINCULADOS A ESTE PRODUTO","Aten��o! N�O FOI POSSIVEL EXCLUIR")
		Return
	EndIf
	*/
ENDIF
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

DbSelectArea(cAlias)
If SoftLock( cAlias )
	//�������������������������������������������������������������������Ŀ
	//� Processamento de codeblock de antes da interface                  �
	//���������������������������������������������������������������������
	If !Empty(aParam)
		Eval(aParam[1],nOpc)
	EndIf
	//�������������������������������������������������������������������Ŀ
	//� Controle de Interface                                             �
	//���������������������������������������������������������������������
	Do Case
		Case ( Type("__cInternet") # "C" .Or. __cInternet # 'AUTOMATICO' ) .And. aAuto == Nil
			
			If SetMDIChild()
				oMainWnd:ReadClientCoors()
				nTop := 40
				nLeft := 30
				nBottom := oMainWnd:nBottom-80
				nRight := oMainWnd:nRight-70
			Else
				nTop := 135
				nLeft := 0
				nBottom := TranslateBottom(.T.,28)
				nRight := 632
			EndIf
			If FindFunction("ISPDA") .and. IsPDA()
				nTop := 0
				nLeft := 0
				nBottom := PDABOTTOM
				nRight  := PDARIGHT
			EndIf
			
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd
			
			If lMaximized <> NIL
				oDlg:lMaximized := lMaximized
			EndIf
			If FindFunction("ISPDA") .and. IsPDA()
				aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o  espa�o da janela
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,aCpos,aPosEnch,,,,,,,,.t.,,,,,,,,,cTela )
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
			Else
				aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o  espa�o da janela
				nOpcA:=EnChoice( cAlias, nReg, nOpc,,,,aCpos,aPosEnch,,,,,,,,,,,,,,,,,cTela)
			EndIf
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtons)
		Case aAuto <> Nil
			RegToMemory(cAlias,.F.,.F.)
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela)},nOpc,aCpos)
				nOpcA := 2
			EndIf
		OtherWise
			nOpcA := 2
	EndCase
	If nOpcA == 2
		dbSelectArea(cAlias)
		If Type("cDelFunc") != "U" .and. cDelFunc != Nil
			If !&(cDelFunc)
				nOpcA := 0
			EndIf
		EndIf
	EndIf
	//�������������������������������������������������������������������Ŀ
	//� Processamento de codeblock de validacao de confirmacao            �
	//���������������������������������������������������������������������
	If nOpcA == 2 .And. !Empty(aParam)
		If !Eval(aParam[2],nOpc)
			nOpcA := 0
		EndIf
	EndIf
	If nOpcA == 2
		//�������������������������������������������������������������������Ŀ
		//� Atualizacao da tabela                                             �
		//���������������������������������������������������������������������
		Begin Transaction
		DbSelectArea(cAlias)
		If cTransact != Nil .And. ValType(cTransact) == "C"
			If !("("$cTransact)
				cTransact+="()"
			EndIf
			&cTransact
		EndIf
		//�������������������������������������������������������������������Ŀ
		//� Processamento de codeblock dentro da transacao                    �
		//���������������������������������������������������������������������
		If !Empty(aParam)
			Eval(aParam[3],nOpc)
		EndIf
		
		If Type("aMemos")=="A"
			For nX := 1 To Len(aMemos)
				//Inclu�do parametro com o nome da tabela de memos => para m�dulo APT
				cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
				MSMM(&(aMemos[nX][1]),,,,2,,,,,cAliasMemo)
			Next nX
		EndIf
		
		RecLock(cAlias,.F.,.T.)
		IF !FKDelete(@cMsgError)
			RollBackDelTran(cMsgError)
		EndIf
		MsUnLock()
		
		End Transaction
		//�������������������������������������������������������������������Ŀ
		//� Processamento de codeblock fora da transacao                      �
		//���������������������������������������������������������������������
		If !Empty(aParam)
			Eval(aParam[4],nOpc)
		EndIf
	EndIf
EndIf
MsUnLockAll()
RestArea(aArea)
Return(nOpcA)

User Function Axcop1()
Processa({|| U_AxCop() },"Buscando os produtos...","Selecionando os Produtos...")
Return

////*********************************************************

User Function AxCop()

Local _aStruTrb:={}
Local _afields:={}
Local _carq
Local oMark
Local _w 		:= 0
Private nTotRec	:= 0
Private arotina := {}
Private cCadastro
Private aCores := {}
Private cMark:=GetMark()
Private _nOpca:=0

aRotina   := { { "Marcar Todos   " ,"U_MARCAR" , 0, 4},;
{ "Desmarcar Todos" ,"U_DESMAR" , 0, 4},;
{ "Inverter Todos " ,"U_MARKALL" , 0, 4},;
{ "Definir Filtro " ,"U_FILTRA" , 0, 4},;
{ "Copiar Marcados" ,"U_COPYSEL1" , 0, 3} }

cCadastro := "Arquivo Temporario"//� Estrutura da tabela temporaria

aCores := {}
aAdd(aCores,{"ZP3->ZP3_STATUS == '0 '","BR_VERDE"	})
aAdd(aCores,{"ZP3->ZP3_STATUS == '1 '","BR_AMARELO"	})
aAdd(aCores,{"ZP3->ZP3_STATUS == '2 '","BR_VERMELHO"})

//Cria um arquivo de Apoio

//��������������������������������������������������������Ŀ

//� Define campos do TRB �

//����������������������������������������������������������

aadd(_aStruTrb,{"CODPRO" ,"C",6,0})

aadd(_aStruTrb,{"DESCPRO" ,"C",60,0})

aadd(_aStruTrb,{"QTDMES" ,"N",15,2})

aadd(_aStruTrb,{"OK" ,"C",02,0})

AADD(_aStruTrb,{"STATUS" ,"C"	,2		,0		})


//cArqProd:=Criatrab(_aStruTrb,.T.)
//DBUSEAREA(.t.,,carqprod,"TRB")


//_cArqProd := CriaTrab(_aStruTrb)

//dbUseArea(.T.,__LocalDriver,_cArqProd,"TRB")

//Aqui voc� monta sua query que serve para gravar os dados no arquivo temporario...

//LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)

_w:=1
For _w=1 to 2
	If _w = 1
		cQuery := " SELECT COUNT(1) AS TOT   "
	Else
		cQuery := " SELECT ZP0_CODTIP, ZP0_DESCTP, ZP0_ORGAO, ZP0_QTDMIN, ZP0_QTDMAX "
	Endif
	cQuery += " FROM "+RetSqlName("ZP0") "
	cQuery += " WHERE ZP0_FILIAL='"+XFILIAL("ZP0")+"' AND D_E_L_E_T_=' ' AND ZP0_ORGAO='"+ZP1->ZP1_ORGAO+"'"
	
	If _w =	2
		cQuery += " ORDER BY ZP0_DESCTP"
		TCQuery cQuery new Alias (cAlias:=GetNextAlias())
	Else
		TCQuery cQuery new Alias (cAlias:=GetNextAlias())
		nTotRec:=(cAlias)->TOT
		(cAlias)->(DbCloseArea())
	endif
next _w

ProcRegua(nTotRec)
nCnt:=		0
//Alimenta o arquivo de apoio com os registros do cadastro de produtos (SB1)
DbSelectArea("ZP3")
While (cAlias)->(!Eof())
	nCnt++
	IncProc("Buscando os produtos "+(cAlias)->ZP0_DESCTP+"  Taxa de progress�o: "+Transform( (nCnt/nTotRec)*100, "@E 999.99" )+"%")
	RecLock("ZP3",.T.)
	ZP3->ZP3_OK := cMark //ThisMark()
	ZP3->ZP3_CODTIP := cValToChar((cAlias)->ZP0_CODTIP)
	ZP3->ZP3_DESCTP:= (cAlias)->ZP0_DESCTP
	ZP3->ZP3_QTDPER:= IIF((cAlias)->ZP0_ORGAO=='1',(cAlias)->ZP0_QTDMIN,(cAlias)->ZP0_QTDMAX)
	//		ZP3->ZP3_ORGAO:= (cAlias)->ZP0_ORGAO
	//		ZP3->ZP3_TPSALD:= (cAlias)->ZP0_TPSALD
	ZP3->ZP3_STATUS  := "0"    //Verde
	MsUnlock()
	(cAlias)->(DbSkip())
Enddo

(cAlias)->(DbCloseArea())


//Alimenta o arquivo de apoio com os registros do cadastro de produtos (SB1)

/*
LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)
DbSelectArea("SB1")
DbGotop()
While  SB1->(!Eof())
DbSelectArea("TRB")
RecLock("TRB",.T.)
TRB->CODPRO := cValToChar(SB1->B1_COD)
TRB->DESCPRO:= SB1->B1_DESC
TRB->QTDMES:= 0
TRB->STATUS  := "2"    //Verde
MsunLock()
SB1->(DbSkip())
Enddo
*/


//Define quais colunas (campos da TRB) serao exibidas na MarkBrow
_aBrowse:= {{ "ZP3_OK"			,, "Mark"           ,"@!"},;
{ "ZP3_CODTIP"		,, "Codigo"         ,"@!"},;
{ "ZP3_DESCTP"		,, "Descri��o                                                "      ,"@!"},;
{ "ZP3_QTDPER"		,, "Qtde Permitida" ,"@E 99999999999.9999"}}


DbSelectArea("ZP3")
DbGotop()
MarkBrow( 'ZP3', 'ZP3_OK',,_aBrowse,, cMark,'u_MarkAll()',,,,'u_Mark()',,,,aCores,,,,.F.)
//MarkBrow( 'TRB', 'OK',,_aBrowse,, cMark,'u_MarkAll()',,,,'u_Mark()',{|| u_MarkAll()},,,aCores,,,,.F.)
DbCloseArea()
// apaga a tabela tempor�rio
//Iif(File(cArqProd + GetDBExtension()),FErase(cArqProd  + GetDBExtension()) ,Nil)

Return

User Function Marcar()
Local oMark := GetMarkBrow()
DbSelectArea("ZP3")
DbGotop()
While !Eof()
	IF RecLock( 'ZP3', .F. )
		ZP3->ZP3_OK := cMark
		ZP3->ZP3_STATUS := '0'
		MsUnLock()
	EndIf
	dbSkip()
Enddo
MarkBRefresh( )
// for�a o posicionamento do browse no primeiro registro
oMark:oBrowse:Gotop()
return

User Function DesMar()
Local oMark := GetMarkBrow()
DbSelectArea("ZP3")
DbGotop()
While !Eof()
	IF RecLock( 'ZP3', .F. )
		ZP3->ZP3_OK := SPACE(2)
		ZP3->ZP3_STATUS := '1'
		MsUnLock()
	EndIf
	dbSkip()
Enddo
MarkBRefresh( )// for�a o posicionamento do browse no primeiro registro
oMark:oBrowse:Gotop()
Return

// Grava marca no campo

User Function Mark()
If IsMark( 'ZP3_OK', cMark )
	RecLock( 'ZP3', .F. )
	Replace ZP3_OK With Space(2)
	ZP3->ZP3_STATUS := '1'
	MsUnLock()
Else
	RecLock( 'ZP3', .F. )
	Replace ZP3_OK With cMark
	ZP3->ZP3_STATUS := '0'
	MsUnLock()
EndIf
Return // Grava marca em todos os registros validos

User Function MarkAll()
Local oMark := GetMarkBrow()
dbSelectArea('ZP3')
dbGotop()
While !Eof()
	u_Mark()
	dbSkip()
End
MarkBRefresh( )// for�a o posicionamento do browse no primeiro registro
oMark:oBrowse:Gotop()
Return

User Function CopySel1()
Processa({|| U_CopySel() },"Buscando os produtos...","Selecionando os Produtos...")
Return




User Function CopySel()
Local nTotrec:=Lastrec()
ProcRegua(nTotRec)
nCnt:=		0
dbSelectArea("ZP3")
DbGotop()
Do While ZP3->(!Eof())
	If !Empty(ZP3->ZP3_OK)   //se usuario marcou o registro
		nCnt++
		IncProc("Copiando o produtos "+ZP3->ZP3_DESCTP+"  Taxa de progress�o: "+Transform( (nCnt/nTotRec)*100, "@E 999.99" )+"%")
		dbSelectarea("ZP2")
		ZP2->(dbSetOrder(1))
		//	        ZP2->(dbSeek(ZP1->ZP1_FILIAL+ZP1->ZP1_CODCLI+ZP1->ZP1_LOJA+ZP1->ZP1_LICENC+DTOS(ZP1->ZP1_DTVLD)+ZP1->ZP1_ORGAO+TRB->CODPRO))
		MsSeek(ZP1->ZP1_FILIAL+ZP1->ZP1_CODCLI+ZP1->ZP1_LOJA+ZP1->ZP1_ORGAO+ZP3->ZP3_CODTIP)
		IF !FOUND()
			RecLock("ZP2",.T.)
			ZP2->ZP2_FILIAL:=ZP1->ZP1_FILIAL
			ZP2->ZP2_CODCLI:=ZP1->ZP1_CODCLI
			ZP2->ZP2_LOJA:=ZP1->ZP1_LOJA
			ZP2->ZP2_LICENC:=ZP1->ZP1_LICENC
			ZP2->ZP2_DTVLD:=ZP1->ZP1_DTVLD
			ZP2->ZP2_ORGAO:=ZP1->ZP1_ORGAO
			ZP2->ZP2_CODTIP:=ZP3->ZP3_CODTIP
			ZP2->ZP2_DESCTP:=ZP3->ZP3_DESCTP
			ZP2->ZP2_QTDPER:=ZP3->ZP3_QTDPER
			MSUNLOCK()
		ENDIF
	EndIf
	RecLock("ZP3",.F.)
	ZP3->(DbDelete())
	MSUNLOCK()
	ZP3->(DbSkip())
EndDo
Return

User function FILTRA()
MsgAlert("ROTINA EM DESENVOLVIMENTO","CHAUS CONSULTORIA")
RETURN


/*
*********************************************************************************
*********************************************************************************
*********************************************************************************
*********************************************************************************
** Fun��o    * AFAT008D  * Autor * CHAUS CONSULTORIA  *       Data 18/03/2013  **
*********************************************************************************
*********************************************************************************
** Descri��o * Fun��o Tela de Cadastro ZP1/ZP2                                 **
*********************************************************************************
** Uso       * Projeto Melhorias Licen�a PF e Melhorias Exercito.		       **
*********************************************************************************
*********************************************************************************
*********************************************************************************
*********************************************************************************
*/

User Function AFAT008D()

Local aCoors  := FWGetDialogSize( oMainWnd )
Local oPanelUp, oPanelDown, oFWLayer, oBrowseUp, oBrowseDown, oRelacZP1
Private oDlgPrinc
Private cCadastro := 'Tipo Produto / Org�o Respons�vel'
PRIVATE aRotina := MenuDefa()
Define MsDialog oDlgPrinc Title 'Tipo Produto / Org�o Respons�vel' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel


PRIVATE aREOPEN	 	:= {}
PRIVATE _data 		:= DATE()
PRIVATE lexec		:= .F.
Private oProcess  	:= NIL
//PRIVATE oMainWnd
Set Dele On


//
// Cria o conteiner onde ser�o colocados os browses
//

oFWLayer := FWLayer():New()
oFWLayer:Init( oDlgPrinc, .F., .T. )
//
// Define Painel Superior
//
oFWLayer:AddLine( 'UP', 50, .F. )
// Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

// Pego o objeto desse peda�o do container
//
// Painel Inferior
//
oFWLayer:AddLine( 'DOWN', 50, .F. )
// Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'DOWN' )
// Na "linha" criada eu crio uma coluna com 100% da tamanho dela

oPanelDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )
// Pego o objeto desse peda�o do container

//
// FWmBrowse Superior Albuns
//
oBrowseUp:= FWmBrowse():New()

oBrowseUp:SetOwner( oPanelUp )
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetDescription( 'Tabela Tipo Produto x Orgao Responsavel (ZP0).' )
oBrowseUp:DisableDetails()
oBrowseUp:SetAlias( 'ZP0' )
oBrowseUp:SetMenuDef( 'AFAT008D' )
// Define de onde virao os botoes deste browse
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()
//oBrowseUp:AddButton( "INCLUIR", U_AFAT008A(),,3,0,.F.,,,)
oBrowseUp:Activate()

//
// Lado Esquerdo Musicas
//
oBrowseDown:= FWMBrowse():New()
oBrowseDown:SetOwner( oPanelDown )
oBrowseDown:SetDescription( 'Tabela Produto x Tipo Produto x Orgao Responsavel (ZP4).' )
oBrowseDown:SetMenuDef( '' )
// Referencia vazia para que nao exiba nenhum botao
oBrowseDown:DisableDetails()
oBrowseDown:SetAlias( 'ZP4' )
oBrowseDown:SetProfileID( '2' )
//oBrowseDown:AddButton( "INCLUIR", U_AFAT008B(),,3,0,.F.,,,)
oBrowseDown:Activate()

//
// Relacionamento entre os Paineis
//

oRelacZP1:= FWBrwRelation():New()
oRelacZP1:AddRelation( oBrowseUp  , oBrowseDown , { { 'ZP4_FILIAL', 'xFilial( "ZP4" )' }, { 'ZP4_CODTIP', 'ZP0_CODTIP' }, { 'ZP4_ORGAO', 'ZP0_ORGAO' }} )
//, { 'ZP2_DTVLD', 'ZP1_DTVLD' } } )
//oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, { { 'ZA5_FILIAL', 'xFilial( "ZA5" )' }, { 'ZA5_ALBUM' , 'ZA4_ALBUM'  }, { 'ZA5_MUSICA', 'ZA4_MUSICA' } } )


oRelacZP1:Activate()
Activate MsDialog oDlgPrinc Center
Return NIL
//-------------------------------------------------------------------


Static Function MenuDefa()

Local aRotina := {}
//AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})
//AADD(aRotina,{"Visualizar" ,"AxVisual",0,2})
AADD(aRotina,{"Incluir" ,"AxInclui",0,3})
AADD(aRotina,{"Alterar" ,"U_AxAltD",0,4})
AADD(aRotina,{"Excluir" ,"U_AxDelD",0,5})
//AADD(aRotina,{"Copiar " ,"U_Axcop1d",0,3})
AADD(aRotina,{"Fora ZP4" ,"U_Axfzp4",0,3})

Return aRotina


Static Function ModelDefa()

Local oStruZP0 := FWFormStruct(1,'ZP0')
Local oStruZP4 := FWFormStruct(1,'ZP4')
Local oModel

oModel := MPFormModel():New('MVC_001')


oModel:AddFields('ZP0MASTER',/*cOwner*/,oStruZP0)
oModel:AddGrid('ZP4DETAIL','ZP0MASTER',oStruZP4)

oModel:SetRelation( 'ZP4DETAIL', { { 'ZP4_FILIAL', 'xFilial( "ZP4" )' }, { 'ZP4_CODTIP', 'ZP0_CODTIP' },{ 'ZP4_ORGAO', 'ZP0_ORGAO' } }, ZP4->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey({'ZP0_FILIAL','ZP0_CODTIP','ZP0_ORGAO'})

oModel:SetDescription('Tabela Tipo Produto x Orgao Responsavel (ZP0).')

oModel:GetModel('ZP0MASTER'):SetDescription('Tabela Tipo Produto x Orgao Responsavel (ZP0).')
oModel:GetModel('ZP0DETAIL'):SetDescription('Tabela Produto x Tipo Produto x Orgao Responsavel (ZP4).')

Return oModel

Static Function ViewDefa()

Local oModel := FWLoadModel('MVC_001')

Local oStruZP0:= FWFormStruct(2,'ZP0')
Local oStruZP4:= FWFormStruct(2,'ZP4')
Local oViewDef:=FWFormView():New()


oViewDef:SetModel(oModel)

oViewDef:AddField('VIEW_ZP0',oStruZP0,'ZP0MASTER')
oView:AddGrid('VIEW_ZP4',oStruZP4,'ZP4DETAIL' )

oViewDef:CreateHorixontalBox('TELA1',100)
oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'INFERIOR', 85 )

oViewDef:CreateHorixontalBox('TELA2',100)
oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'INFERIOR', 85 )

oViewDef:SetOwnerView('VIEW_ZP0','TELA1')
oViewDef:SetOwnerView('VIEW_ZP4','TELA2')

Return oViewDef


User FUNCTION AxAltd(cAlias,nReg,nOpc,aAcho,aCpos,nColMens,cMensagem,cTudoOk,cTransact,cFunc,aButtons,aParam,aAuto,lVirtual,lMaximized,cTela)

Local aArea    := GetArea(cAlias)
Local aPosEnch := {}
Local bCampo   := {|nCPO| Field(nCPO) }
Local bOk      := Nil
Local bOk2     := {|| .T.}
Local cCpoFil  := PrefixoCpo(cAlias)+"_FILIAL"
Local cMemo    := ""
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cAliasMemo
Local bEndDlg := {|lOk| lOk:=oDlg:End(), nOpcA:=1, lOk}
Local oEnc01
Private aTELA[0][0]
Private aGETS[0]

DEFAULT lVirtual:= .F.
DEFAULT cTudoOk := ".T."
DEFAULT nReg    := (cAlias)->(RecNO())
DEFAULT bOk := &("{|| "+cTudoOk+"}")
//�������������������������������������������������������������������Ŀ
//� Processamento de codeblock de validacao de confirmacao            �
//���������������������������������������������������������������������
If !Empty(aParam)
	bOk2 := aParam[2]
EndIf
//����������������������������������������������������������������������Ŀ
//�VerIfica se esta' alterando um registro da mesma filial               �
//������������������������������������������������������������������������
DbSelectArea(cAlias)
cCpoFil:="  "
If (cAlias)->(FieldPos(cCpoFil))==0 .Or. (cAlias)->(FieldGet(FieldPos(cCpoFil))) == xFilial(cAlias)
	//��������������������������������������������������������������Ŀ
	//� Monta a entrada de dados do arquivo						     �
	//����������������������������������������������������������������
	If SoftLock(cAlias)
		RegToMemory(cAlias,.F.,lVirtual)
		//�������������������������������������������������������������������Ŀ
		//� Inicializa variaveis para campos Memos Virtuais		 			  �
		//���������������������������������������������������������������������
		If Type("aMemos")=="A"
			For nX:=1 to Len(aMemos)
				cMemo := aMemos[nX][2]
				If ExistIni(cMemo)
					//&cMemo := InitPad(SX3->X3_RELACAO)
				Else
					&cMemo := ""
				EndIf
			Next nX
		EndIf
		//�������������������������������������������������������������������Ŀ
		//� Inicializa variaveis para campos Memos Virtuais		 			  �
		//���������������������������������������������������������������������
		If ( ValType( cFunc ) == 'C' )
			If ( !("(" $ cFunc) )
				cFunc+= "()"
			EndIf
			&cFunc
		EndIf
		//�������������������������������������������������������������������Ŀ
		//� Processamento de codeblock de antes da interface                  �
		//���������������������������������������������������������������������
		If !Empty(aParam)
			Eval(aParam[1],nOpc)
		EndIf
		//������������������������������������������������������Ŀ
		//� Envia para processamento dos Gets				   	 �
		//��������������������������������������������������������
		If aAuto == Nil
			
			If SetMDIChild()
				oMainWnd:ReadClientCoors()
				nTop := 40
				nLeft := 30
				nBottom := oMainWnd:nBottom-80
				nRight := oMainWnd:nRight-70
			Else
				nTop := 135
				nLeft := 0
				nBottom := TranslateBottom(.T.,28)
				nRight := 632
			EndIf
			If FindFunction("ISPDA").and. IsPDA()
				nTop := 0
				nLeft := 0
				nBottom := PDABOTTOM
				nRight  := PDARIGHT
			EndIf
			// Build com corre��o no tratamento dos controles pendentes na dialog ao executar o m�todo End()
			If GetBuild() >= "7.00.060302P"
				bEndDlg := {|lOk| If(lOk:=oDlg:End(),nOpcA:=1,nOpcA:=3), lOk}
			EndIf
			
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd
			
			If lMaximized <> NIL
				oDlg:lMaximized := lMaximized
			EndIf
			
			If FindFunction("ISPDA").and. IsPDA()
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,     ,"CRA",oemtoansi(STR0004),aAcho,  aPosEnch,aCpos, ,nColMens,If(nColMens != Nil,cMensagem,NIL),cTudoOk,,lVirtual,.t.,,,,,,,,, cTela) //"Quanto �s altera��es?"
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
			Else
				aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}
				If nColMens != Nil
					nOpcA := EnChoice( cAlias, nReg, nOpc, ,"CRA",oemtoansi(STR0004),aAcho,aPosEnch,aCpos,,nColMens,cMensagem,cTudoOk,,lVirtual,,,,,,,,,, cTela) //"Quanto �s altera��es?"
				Else
					nOpcA:=EnChoice( cAlias, nReg, nOpc, ,"CRA",oemtoansi(STR0004),aAcho,aPosEnch,aCpos,,,,cTudoOk,,lVirtual,,,,,,,,,, cTela) //"Quanto �s altera��es?"
				EndIf
			EndIf
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(Obrigatorio(aGets,aTela).And.Eval(bOk).And.Eval(bOk2,nOpc),Eval(bEndDlg),(nOpcA:=3,.F.))},{|| nOpcA := 3,oDlg:End()},,aButtons,nReg,cAlias)
		Else
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela) .And. Eval(bOk).And.Eval(bOk2,nOpc)},nOpc,aCpos)
				nOpcA := 1
			EndIf
		EndIf
		(cAlias)->(MsGoTo(nReg))
		If nOpcA == 1
			Begin Transaction
			RecLock(cAlias,.F.)
			For nX := 1 TO FCount()
				FieldPut(nX,M->&(EVAL(bCampo,nX)))
			Next nX
			//�������������������������������������������������������������������Ŀ
			//�Grava os campos Memos Virtuais					  				  �
			//���������������������������������������������������������������������
			If Type("aMemos") == "A"
				For nX := 1 to Len(aMemos)
					cVar := aMemos[nX][2]
					cVar1:= aMemos[nX][1]
					//Inclu�do parametro com o nome da tabela de memos => para m�dulo APT
					cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
					MSMM(&cVar1,TamSx3(aMemos[nX][2])[1],,&cVar,1,,,cAlias,aMemos[nX][1],cAliasMemo)
				Next nX
			EndIf
			If cTransact != Nil
				If !("("$cTransact)
					cTransact+="()"
				EndIf
				&cTransact
			EndIf
			//�������������������������������������������������������������������Ŀ
			//� Processamento de codeblock dentro da transacao                    �
			//���������������������������������������������������������������������
			If !Empty(aParam)
				Eval(aParam[3],nOpc)
			EndIf
			End Transaction
			//�������������������������������������������������������������������Ŀ
			//� Processamento de codeblock fora da transacao                      �
			//���������������������������������������������������������������������
			If !Empty(aParam)
				Eval(aParam[4],nOpc)
			EndIf
		EndIf
	Else
		nOpcA := 3
	EndIf
Else
	Help(" ",1,"A000FI")
	nOpcA := 3
EndIf
//�������������������������������������������������������������������Ŀ
//� Restaura a integridade dos dados                                  �
//���������������������������������������������������������������������
MsUnLockAll()
RestArea(aArea)
Return(nOpcA)

User Function AxDeld(cAlias,nReg,nOpc,cTransact,aCpos,aButtons,aParam,aAuto,lMaximized,cTela)

Local aArea    := GetArea()
Local aPosEnch := {}
Local nOpcA    := 0
Local nX       := 0
Local oDlg
Local nTop
Local nLeft
Local nBottom
Local nRight
Local cMsgError:= ""
Local oEnc01

Private aTELA[0][0]
Private aGETS[0]


// Verificar se existe registro na ZP4
IF cAlias=='ZP0'
	cQueryZP2 :="SELECT COUNT(1) AS TOT "
	cQueryZP2+=  " FROM "+RetSqlName("ZP4")+ " WHERE ZP4_FILIAL ='"+ZP0->ZP0_FILIAL+"' AND ZP4_CODTIP='"+ZP0->ZP0_CODTIP+"' AND ZP4_ORGAO='"+ZP0->ZP0_ORGAO+"' AND D_E_L_E_T_=' ' "
	
	If Select("TRBZP4") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
		dbSelectArea("TRBZP4")
		dbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryZP2),'TRBZP4',.F.,.T.)
	nTotRec:=	TRBZP4->TOT
	
	If nTotRec > 0
		//msgstop("EXISTE "+STRZERO(nTotrec,6)+"PRODUTOS VINCULADOS A ESTE TIPO DE PRODUTO","Aten��o! N�O FOI POSSIVEL EXCLUIR")
		msgstop("EXISTE "+STRZERO(nTotrec,6)+"CODTIP X ZP4","ATENCAO: Este CODTIP tem produtos cadastrados na ZP4; primeiro exclua os produtos.")
		Return
	EndIf
ENDIF

// Ticket BRSM-4176 BEGIN
// Verificar se existe registro na ZP1
IF cAlias=='ZP1'
	cQueryZP2 :="SELECT COUNT(1) AS TOT "
	cQueryZP2+=  " FROM "+RetSqlName("ZP2")+ " WHERE ZP2_FILIAL ='"+ZP1->ZP1_FILIAL+"' AND ZP2_CODCLI='"+ZP1->ZP1_CODCLI+"' AND ZP2_LOJA='"+ZP1->ZP1_LOJA+"' AND ZP2_ORGAO='"+ZP1->ZP1_ORGAO+"' AND D_E_L_E_T_=' ' "
	
	If Select("TRBZP2") > 0 // Garante o fechamento da tabela de trabalho para evitar erro de abertura.
		dbSelectArea("TRBZP2")
		dbCloseArea()
	Endif
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryZP2),'TRBZP4',.F.,.T.)
	nTotRec:=	TRBZP4->TOT
	
	If nTotRec > 0
		msgstop("EXISTE "+STRZERO(nTotrec,6)+"CODTIP X ZP2","ATENCAO: Este cliente tem CODTIP associados na ZP2, primeiro exclua as associa��es.")
		Return
	EndIf
ENDIF
// Ticket BRSM-4176 END
//��������������������������������������������������������������Ŀ
//� Monta a entrada de dados do arquivo                          �
//����������������������������������������������������������������

DbSelectArea(cAlias)
If SoftLock( cAlias )
	//�������������������������������������������������������������������Ŀ
	//� Processamento de codeblock de antes da interface                  �
	//���������������������������������������������������������������������
	If !Empty(aParam)
		Eval(aParam[1],nOpc)
	EndIf
	//�������������������������������������������������������������������Ŀ
	//� Controle de Interface                                             �
	//���������������������������������������������������������������������
	Do Case
		Case ( Type("__cInternet") # "C" .Or. __cInternet # 'AUTOMATICO' ) .And. aAuto == Nil
			
			If SetMDIChild()
				oMainWnd:ReadClientCoors()
				nTop := 40
				nLeft := 30
				nBottom := oMainWnd:nBottom-80
				nRight := oMainWnd:nRight-70
			Else
				nTop := 135
				nLeft := 0
				nBottom := TranslateBottom(.T.,28)
				nRight := 632
			EndIf
			If FindFunction("ISPDA") .and. IsPDA()
				nTop := 0
				nLeft := 0
				nBottom := PDABOTTOM
				nRight  := PDARIGHT
			EndIf
			
			DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd
			
			If lMaximized <> NIL
				oDlg:lMaximized := lMaximized
			EndIf
			If FindFunction("ISPDA") .and. IsPDA()
				aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o  espa�o da janela
				oEnc01:= MsMGet():New( cAlias, nReg, nOpc,,,,aCpos,aPosEnch,,,,,,,,.t.,,,,,,,,,cTela )
				oEnc01:oBox:align := CONTROL_ALIGN_ALLCLIENT
			Else
				aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}  // ocupa todo o  espa�o da janela
				nOpcA:=EnChoice( cAlias, nReg, nOpc,,,,aCpos,aPosEnch,,,,,,,,,,,,,,,,,cTela)
			EndIf
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()},,aButtons)
		Case aAuto <> Nil
			RegToMemory(cAlias,.F.,.F.)
			If EnchAuto(cAlias,aAuto,{|| Obrigatorio(aGets,aTela)},nOpc,aCpos)
				nOpcA := 2
			EndIf
		OtherWise
			nOpcA := 2
	EndCase
	If nOpcA == 2
		dbSelectArea(cAlias)
		If Type("cDelFunc") != "U" .and. cDelFunc != Nil
			If !&(cDelFunc)
				nOpcA := 0
			EndIf
		EndIf
	EndIf
	//�������������������������������������������������������������������Ŀ
	//� Processamento de codeblock de validacao de confirmacao            �
	//���������������������������������������������������������������������
	If nOpcA == 2 .And. !Empty(aParam)
		If !Eval(aParam[2],nOpc)
			nOpcA := 0
		EndIf
	EndIf
	If nOpcA == 2
		//�������������������������������������������������������������������Ŀ
		//� Atualizacao da tabela                                             �
		//���������������������������������������������������������������������
		Begin Transaction
		DbSelectArea(cAlias)
		If cTransact != Nil .And. ValType(cTransact) == "C"
			If !("("$cTransact)
				cTransact+="()"
			EndIf
			&cTransact
		EndIf
		//�������������������������������������������������������������������Ŀ
		//� Processamento de codeblock dentro da transacao                    �
		//���������������������������������������������������������������������
		If !Empty(aParam)
			Eval(aParam[3],nOpc)
		EndIf
		
		If Type("aMemos")=="A"
			For nX := 1 To Len(aMemos)
				//Inclu�do parametro com o nome da tabela de memos => para m�dulo APT
				cAliasMemo := If(len(aMemos[nX]) == 3,aMemos[nX][3],Nil)
				MSMM(&(aMemos[nX][1]),,,,2,,,,,cAliasMemo)
			Next nX
		EndIf
		
		RecLock(cAlias,.F.,.T.)
		IF !FKDelete(@cMsgError)
			RollBackDelTran(cMsgError)
		EndIf
		MsUnLock()
		
		End Transaction
		//�������������������������������������������������������������������Ŀ
		//� Processamento de codeblock fora da transacao                      �
		//���������������������������������������������������������������������
		If !Empty(aParam)
			Eval(aParam[4],nOpc)
		EndIf
	EndIf
EndIf
MsUnLockAll()
RestArea(aArea)
Return(nOpcA)

User Function Axcop1d()
Processa({|| U_AxCopd() },"Aguarde...","Selecionando os Produtos...")
Return


User Function Axfzp4()
Processa({|| U_Axfzp4d() },"Aguarde...","Selecionando os Produtos...")
Return



////*********************************************************

User Function AxCopd()

Local _aStruTrb:={}
Local _afields:={}
Local _carq
Local oMark
Private nTotRec	:= 0
Private arotina := {}
Private cCadastro
Private aCores := {}
Private cMark:=GetMark()
Private _nOpca:=0
Private _imark:=.T.
Private cTxtmsg:=Iif(_imark,"Desmarcando os produtos pre-selecionados...","Marcando os produtos pre-selecionados...")
Private cTxtmsgd:=Iif(_imark,"Desmarcando o produto pre-selecionado...","Marcando o produto pre-selecionado...")


/*


{ "Inverter Todos " ,"U_MARKALLd" , 0, 4},;
*/


aRotina   := { { "Marcar Todos   " ,"U_MARCARd" , 0, 4},;
{ "Desmarcar Todos" ,"U_DESMARd" , 0, 4},;
{ "Definir Filtro " ,"U_FILTRAd" , 0, 4},;
{ "Copiar Marcados" ,"U_COPSEL1d" , 0, 3} }


cCadastro := "Arquivo Temporario"//� Estrutura da tabela temporaria

aCores := {}
aAdd(aCores,{"ZP5->ZP5_STATUS == '0 '","BR_VERDE"	})
aAdd(aCores,{"ZP5->ZP5_STATUS == '1 '","BR_AMARELO"	})
aAdd(aCores,{"ZP5->ZP5_STATUS == '2 '","BR_VERMELHO"})

//Cria um arquivo de Apoio

//��������������������������������������������������������Ŀ

//� Define campos do TRB �

//����������������������������������������������������������

aadd(_aStruTrb,{"CODPRO" ,"C",6,0})

aadd(_aStruTrb,{"DESCPRO" ,"C",60,0})

aadd(_aStruTrb,{"QTDMES" ,"N",15,2})

aadd(_aStruTrb,{"OK" ,"C",02,0})

AADD(_aStruTrb,{"STATUS" ,"C"	,2		,0		})


//cArqProd:=Criatrab(_aStruTrb,.T.)
//DBUSEAREA(.t.,,carqprod,"TRB")


//_cArqProd := CriaTrab(_aStruTrb)

//dbUseArea(.T.,__LocalDriver,_cArqProd,"TRB")

//Aqui voc� monta sua query que serve para gravar os dados no arquivo temporario...

//	LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)

_w:=1
For _w=1 to 2
	If _w = 1
		cQuery := " SELECT COUNT(1) AS TOT   "
	Else
		cQuery := " SELECT B1_COD, B1_DESC, B1_XLINHA, B1_GRUPO, B1_ZP4, "
		If ZP0->ZP0_ORGAO=='1'
			cQuery += "B1_CRVPF "
		ElseIf  ZP0->ZP0_ORGAO=='2'
			cQuery += "B1_CRVME  "
		Else
			cQuery += "B1_CRVPF, B1_CRVME "
		Endif
	Endif
	cQuery += " FROM "+RetSqlName("SB1")+ " B1"
	cQuery += " WHERE B1.B1_FILIAL='"+XFILIAL("SB1")+"' AND B1.D_E_L_E_T_=' ' "
	
	If ZP0->ZP0_ORGAO=='1'
		cQuery += " AND B1_CRVPF='S' AND (B1_CRVME=' ' OR B1_CRVME='N') "
	ElseIf  ZP0->ZP0_ORGAO=='2'
		cQuery += " AND B1_CRVME='S' AND (B1_CRVPF=' ' OR B1_CRVPF='N') "
	Else
		cQuery += " AND B1_CRVPF='S' AND B1_CRVME='S' "
	Endif
	
	
	If _w =	2
		cQuery += " ORDER BY B1_DESC"
		TCQuery cQuery new Alias (cAlias:=GetNextAlias())
	Else
		TCQuery cQuery new Alias (cAlias:=GetNextAlias())
		nTotRec:=(cAlias)->TOT
		(cAlias)->(DbCloseArea())
	endif
next _w

ProcRegua(nTotRec)
nCnt:=		0
//Alimenta o arquivo de apoio com os registros do cadastro de produtos (SB1)


//MsgRun("MsgRun","Buscando os produtos para serem selecionados...",{|| LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)  })

cQuery := "DELETE FROM ZP5010 "
TCSQLEXEC(cQuery)


DbSelectArea("ZP5")
While (cAlias)->(!Eof())
	nCnt++
	IncProc("Selecionando o produto "+(cAlias)->B1_DESC+"  Taxa de progress�o: "+Transform( (nCnt/nTotRec)*100, "@E 999.99" )+"%")
	RecLock("ZP5",.T.)
	ZP5->ZP5_OK := cMark //ThisMark()
	ZP5->ZP5_CODPRO := cValToChar((cAlias)->B1_COD)
	ZP5->ZP5_DESCPR:= (cAlias)->B1_DESC
	ZP5->ZP5_TIPOB1:= (cAlias)->B1_XLINHA
	ZP5->ZP5_GRUPO:= (cAlias)->B1_GRUPO
	If ZP0->ZP0_ORGAO=='1'
		ZP5->ZP5_QTDPER:= ZP0->ZP0_QTDMIN
	ElseIf  ZP0->ZP0_ORGAO=='2'
		ZP5->ZP5_QTDPER:= ZP0->ZP0_QTDMAX
	Else
		ZP5->ZP5_QTDPER:= 0
	Endif
	If (cAlias)->B1_ZP4<>'S'
		ZP5->ZP5_STATUS  := "0"    //Verde
	Else
		ZP5->ZP5_STATUS  := "2"    //Vermelho
		Replace ZP5_OK With Space(2)
	EndIf
	MsUnlock()
	(cAlias)->(DbSkip())
Enddo

(cAlias)->(DbCloseArea())


//Alimenta o arquivo de apoio com os registros do cadastro de produtos (SB1)

/*
LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)
DbSelectArea("SB1")
DbGotop()
While  SB1->(!Eof())
DbSelectArea("TRB")
RecLock("TRB",.T.)
TRB->CODPRO := cValToChar(SB1->B1_COD)
TRB->DESCPRO:= SB1->B1_DESC
TRB->QTDMES:= 0
TRB->STATUS  := "2"    //Verde
MsunLock()
SB1->(DbSkip())
Enddo
*/


//Define quais colunas (campos da TRB) serao exibidas na MarkBrow
_aBrowse:= {{ "ZP5_OK"			,, "Mark"           ,"@!"},;
{ "ZP5_CODPRO"		,, "Codigo"         ,"@!"},;
{ "ZP5_DESCPR"		,, "Descri��o                                                "      ,"@!"},;
{ "ZP5_QTDPER"		,, "Qtde Permitida" ,"@E 99999999999.9999"}}


DbSelectArea("ZP5")
Dbsetorder(2)
DbGotop()
cTxtmsg:=Iif(_imark,"Desmarcando os produtos pre-selecionados...","Marcando os produtos pre-selecionados...")
MarkBrow( 'ZP5', 'ZP5_OK',,_aBrowse,, cMark,'MsgRun(cTxtmsg,"Aguarde...",{|| u_MarkAllD()})',,,,'MsgRun(cTxtmsgd,"Aguarde...",{|| u_MarkD()})',,,,aCores,,,,.F.)
//MarkBrow( 'TRB', 'OK',,_aBrowse,, cMark,'u_MarkAll()',,,,'u_Mark()',{|| u_MarkAll()},,,aCores,,,,.F.)
DbCloseArea()
// apaga a tabela tempor�rio
//Iif(File(cArqProd + GetDBExtension()),FErase(cArqProd  + GetDBExtension()) ,Nil)
Return


User Function Axfzp4d()

Local _aStruTrb:={}
Local _afields:={}
Local _carq
Local oMark
Private nTotRec	:= 0
Private arotina := {}
Private cCadastro
Private aCores := {}
Private cMark:=GetMark()
Private _nOpca:=0
Private _imark:=.T.
Private cTxtmsg:=Iif(_imark,"Desmarcando os produtos pre-selecionados...","Marcando os produtos pre-selecionados...")
Private cTxtmsgd:=Iif(_imark,"Desmarcando o produto pre-selecionado...","Marcando o produto pre-selecionado...")


/*


{ "Inverter Todos " ,"U_MARKALLd" , 0, 4},;


aRotina   := { { "Marcar Todos   " ,"U_MARCARd" , 0, 4},;
{ "Desmarcar Todos" ,"U_DESMARd" , 0, 4},;
{ "Definir Filtro " ,"U_FILTRAd" , 0, 4},;
{ "Copiar Marcados" ,"U_COPSEL1d" , 0, 3} }
*/

cCadastro := "Arquivo Temporario"//� Estrutura da tabela temporaria

aCores := {}
aAdd(aCores,{"ZP5->ZP5_STATUS == '0 '","BR_VERDE"	})
aAdd(aCores,{"ZP5->ZP5_STATUS == '1 '","BR_AMARELO"	})
aAdd(aCores,{"ZP5->ZP5_STATUS == '2 '","BR_VERMELHO"})

//Cria um arquivo de Apoio

//��������������������������������������������������������Ŀ

//� Define campos do TRB �

//����������������������������������������������������������

aadd(_aStruTrb,{"CODPRO" ,"C",6,0})

aadd(_aStruTrb,{"DESCPRO" ,"C",60,0})

aadd(_aStruTrb,{"QTDMES" ,"N",15,2})

aadd(_aStruTrb,{"OK" ,"C",02,0})

AADD(_aStruTrb,{"STATUS" ,"C"	,2		,0		})


//cArqProd:=Criatrab(_aStruTrb,.T.)
//DBUSEAREA(.t.,,carqprod,"TRB")


//_cArqProd := CriaTrab(_aStruTrb)

//dbUseArea(.T.,__LocalDriver,_cArqProd,"TRB")

//Aqui voc� monta sua query que serve para gravar os dados no arquivo temporario...

//	LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)

_w:=1
For _w=1 to 2
	If _w = 1
		cQuery := " SELECT COUNT(1) AS TOT   "
	Else
		cQuery := " SELECT B1_COD, B1_DESC, B1_XLINHA, B1_GRUPO, B1_ZP4, "
		If ZP0->ZP0_ORGAO=='1'
			cQuery += "B1_CRVPF "
		ElseIf  ZP0->ZP0_ORGAO=='2'
			cQuery += "B1_CRVME  "
		Else
			cQuery += "B1_CRVPF, B1_CRVME "
		Endif
	Endif
	cQuery += " FROM "+RetSqlName("SB1")+ " B1"
	cQuery += " WHERE B1.B1_FILIAL='"+XFILIAL("SB1")+"' AND B1.D_E_L_E_T_=' ' AND B1.B1_ZP4<>'S'"
	
	If ZP0->ZP0_ORGAO=='1'
		cQuery += " AND B1_CRVPF='S' AND (B1_CRVME=' ' OR B1_CRVME='N') "
	ElseIf  ZP0->ZP0_ORGAO=='2'
		cQuery += " AND B1_CRVME='S' AND (B1_CRVPF=' ' OR B1_CRVPF='N') "
	Else
		cQuery += " AND B1_CRVPF='S' AND B1_CRVME='S' "
	Endif
	
	
	If _w =	2
		cQuery += " ORDER BY B1_DESC"
		TCQuery cQuery new Alias (cAlias:=GetNextAlias())
	Else
		TCQuery cQuery new Alias (cAlias:=GetNextAlias())
		nTotRec:=(cAlias)->TOT
		(cAlias)->(DbCloseArea())
	endif
	TESTE := " "
next _w

ProcRegua(nTotRec)
nCnt:=		0
//Alimenta o arquivo de apoio com os registros do cadastro de produtos (SB1)


//MsgRun("MsgRun","Buscando os produtos para serem selecionados...",{|| LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)  })

cQuery := "DELETE FROM ZP5010 "
TCSQLEXEC(cQuery)


DbSelectArea("ZP5")
/*
while !eof()
RecLock("ZP5",.F.)
ZP5->(DbDelete())
MSUNLOCK()
ZP5->(DbSkip())
EndDo
*/
While (cAlias)->(!Eof())
	nCnt++
	IncProc("Selecionando o produto "+(cAlias)->B1_DESC+"  Taxa de progress�o: "+Transform( (nCnt/nTotRec)*100, "@E 999.99" )+"%")
	RecLock("ZP5",.T.)
	ZP5->ZP5_OK := cMark //ThisMark()
	ZP5->ZP5_CODPRO := cValToChar((cAlias)->B1_COD)
	ZP5->ZP5_DESCPR:= (cAlias)->B1_DESC
	ZP5->ZP5_TIPOB1:= (cAlias)->B1_XLINHA
	ZP5->ZP5_GRUPO:= (cAlias)->B1_GRUPO
	If ZP0->ZP0_ORGAO=='1'
		ZP5->ZP5_QTDPER:= ZP0->ZP0_QTDMIN
	ElseIf  ZP0->ZP0_ORGAO=='2'
		ZP5->ZP5_QTDPER:= ZP0->ZP0_QTDMAX
	Else
		ZP5->ZP5_QTDPER:= 0
	Endif
	If (cAlias)->B1_ZP4='S'
		ZP5->ZP5_STATUS  := "0"    //Verde
	Else
		ZP5->ZP5_STATUS  := "2"    //Vermelho
		Replace ZP5_OK With Space(2)
	EndIf
	MsUnlock()
	(cAlias)->(DbSkip())
Enddo

(cAlias)->(DbCloseArea())


//Alimenta o arquivo de apoio com os registros do cadastro de produtos (SB1)

/*
LJMsgRun("Buscando os produtos para serem selecionados...","Aguarde...",nil)
DbSelectArea("SB1")
DbGotop()
While  SB1->(!Eof())
DbSelectArea("TRB")
RecLock("TRB",.T.)
TRB->CODPRO := cValToChar(SB1->B1_COD)
TRB->DESCPRO:= SB1->B1_DESC
TRB->QTDMES:= 0
TRB->STATUS  := "2"    //Verde
MsunLock()
SB1->(DbSkip())
Enddo
*/


//Define quais colunas (campos da TRB) serao exibidas na MarkBrow
_aBrowse:= {{ "ZP5_OK"			,, "Mark"           ,"@!"},;
{ "ZP5_CODPRO"		,, "Codigo"         ,"@!"},;
{ "ZP5_DESCPR"		,, "Descri��o                                                "      ,"@!"},;
{ "ZP5_QTDPER"		,, "Qtde Permitida" ,"@E 99999999999.9999"}}


DbSelectArea("ZP5")
Dbsetorder(2)
DbGotop()
cTxtmsg:=Iif(_imark,"Desmarcando os produtos pre-selecionados...","Marcando os produtos pre-selecionados...")
MarkBrow( 'ZP5', 'ZP5_OK',,_aBrowse,, cMark,'MsgRun(cTxtmsg,"Aguarde...",{|| u_MarkAllD()})',,,,'MsgRun(cTxtmsgd,"Aguarde...",{|| u_MarkD()})',,,,aCores,,,,.F.)
//MarkBrow( 'TRB', 'OK',,_aBrowse,, cMark,'u_MarkAll()',,,,'u_Mark()',{|| u_MarkAll()},,,aCores,,,,.F.)
DbCloseArea()
// apaga a tabela tempor�rio
//Iif(File(cArqProd + GetDBExtension()),FErase(cArqProd  + GetDBExtension()) ,Nil)
Return



User Function Marcard()
//MsgRun("Marcando todos os produtos...","Aguarde...",{|| U__Marcard()})

U__Marcard()
Return


User Function _Marcard()
Local oMark := GetMarkBrow()
DbSelectArea("ZP5")
DbGotop()
While !Eof()
	IF RecLock( 'ZP5', .F. )
		IF ZP5->ZP5_STATUS<>'2'
			ZP5->ZP5_OK := cMark
			ZP5->ZP5_STATUS := '0'
		ENDIF
		MsUnLock()
	EndIf
	dbSkip()
Enddo

//MarkBRefresh( )
// for�a o posicionamento do browse no primeiro registro
//oMark:oBrowse:Gotop()
return


User Function DesMard()
//MsgRun("Desmarcando todos os produtos...","Aguarde...",{|| U__DesMard()})
U__DesMard()
Return


User Function _DesMard()
Local oMark := GetMarkBrow()
DbSelectArea("ZP5")
DbGotop()
While !Eof()
	IF RecLock( 'ZP5', .F. )
		IF ZP5->ZP5_STATUS<>'2'
			ZP5->ZP5_OK := SPACE(2)
			ZP5->ZP5_STATUS := '1'
		ENDIF
		MsUnLock()
	EndIf
	dbSkip()
Enddo
//MarkBRefresh( )// for�a o posicionamento do browse no primeiro registro
//oMark:oBrowse:Gotop()
Return

// Grava marca no campo

User Function Markd()
If IsMark( 'ZP5_OK', cMark )
	RecLock( 'ZP5', .F. )
	IF ZP5->ZP5_STATUS<>'2'
		Replace ZP5_OK With Space(2)
		_imark:=.F.
		ZP5->ZP5_STATUS := '1'
	ENDIF
	MsUnLock()
Else
	RecLock( 'ZP5', .F. )
	IF ZP5->ZP5_STATUS<>'2'
		Replace ZP5_OK With cMark
		_imark:=.T.
		ZP5->ZP5_STATUS := '0'
	ENDIF
	MsUnLock()
EndIf
cTxtmsgd:=Iif(_imark,"Desmarcando o produto pre-selecionado...","Marcando o produto pre-selecionado...")
Return // Grava marca em todos os registros validos

User Function MarkAlld()
Local oMark := GetMarkBrow()
dbSelectArea('ZP5')
dbGotop()
While !Eof()
	IF RecLock( 'ZP5', .F. )
		IF ZP5->ZP5_STATUS<>'2'
			If ZP5->ZP5_OK==Space(2)
				Replace ZP5->ZP5_OK With cMark
				_imark:=.T.
				ZP5->ZP5_STATUS := '0'
			else
				Replace ZP5->ZP5_OK With Space(2)
				_imark:=.F.
				ZP5->ZP5_STATUS := '1'
			Endif
		ENDIF
		MsUnLock()
	EndIf
	dbSkip()
	
Enddo
cTxtmsg:=Iif(_imark,"Desmarcando os produtos pre-selecionados...","Marcando os produtos pre-selecionados...")
MarkBRefresh( )// for�a o posicionamento do browse no primeiro registro
oMark:oBrowse:Gotop()
Return

User Function CopSel1d()
Processa({|| U_CopSeld() },"Buscando os produtos...","Selecionando os Produtos...")
Return


//Funcao para copiar os registros selecionados

User Function CopSeld()
Local nTotrec:=Lastrec()
ProcRegua(nTotRec)
nCnt:=		0
dbSelectArea("ZP5")
DbGotop()
Do While ZP5->(!Eof())
	If !Empty(ZP5->ZP5_OK)   //se usuario marcou o registro
		nCnt++
		IncProc("Copiando o produtos "+ZP5->ZP5_DESCPR+"  Taxa de progress�o: "+Transform( (nCnt/nTotRec)*100, "@E 999.99" )+"%")
		dbSelectarea("ZP4")
		ZP4->(dbSetOrder(1))
		//	        ZP2->(dbSeek(ZP1->ZP1_FILIAL+ZP1->ZP1_CODCLI+ZP1->ZP1_LOJA+ZP1->ZP1_LICENC+DTOS(ZP1->ZP1_DTVLD)+ZP1->ZP1_ORGAO+TRB->CODPRO))
		MsSeek(ZP0->ZP0_FILIAL+ZP0->ZP0_CODTIP+ZP0->ZP0_ORGAO+ZP5->ZP5_CODPRO)
		IF !FOUND()
			RecLock("ZP4",.T.)
			ZP4->ZP4_FILIAL:=ZP0->ZP0_FILIAL
			ZP4->ZP4_CODTIP:=ZP0->ZP0_CODTIP
			ZP4->ZP4_DESCTP:=ZP0->ZP0_DESCTP
			ZP4->ZP4_ORGAO:=ZP0->ZP0_ORGAO
			ZP4->ZP4_CODPRO:=ZP5->ZP5_CODPRO
			ZP4->ZP4_DESCPR:=ZP5->ZP5_DESCPR
			ZP4->ZP4_QTDPER:=IIF(ZP0->ZP0_ORGAO=='1',ZP0->ZP0_QTDMIN,ZP0->ZP0_QTDMAX)
			MSUNLOCK()
			dbSelectArea("SB1")
			dbSetOrder(1)
			If dbSeek(xFilial("SB1")+ZP5->ZP5_CODPRO)
				Reclock("SB1",.F.)
				SB1->B1_ZP4:="S"
				MSUNLOCK()
			ENDIF
			dbSelectArea("ZP5")
		ENDIF
	EndIf
	RecLock("ZP5",.F.)
	ZP5->(DbDelete())
	MSUNLOCK()
	ZP5->(DbSkip())
EndDo
Return


User function FILTRAd()
Private cPerg       := "MARKCX1"

PutSx1("MARKCX1","01","Produto de ?         "   ,"Produto de ?         "   ,"Produto de ?         "    ,"mv_ch1","C", 15,0,0,"G",""                    ,"SB1PFE"      ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Informe o codigo do produto ","para selecao dos registros ","que serao considerados no processamento","da rotina de copia."},{},{})
PutSx1("MARKCX1","02","Produto ate ?        "   ,"Produto ate ?        "   ,"Produto ate ?        "    ,"mv_ch2","C", 15,0,0,"G","(mv_par02>=mv_par01)","SB1PFE"      ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Informe o codigo do produto ","para selecao dos registros ","que serao considerados no processamento","da rotina de copia."},{},{})
PutSx1("MARKCX1","03","Tipo De ?            "   ,"Tipo De ?            "   ,"Tipo De ?            "    ,"mv_ch3","C", 2,0,0,"G",""                    ,"ZZF"      ,"","","mv_par03","","","","","","","","","","","","","","","","",{"Informe o tipo do produto ","para selecao dos registros ","que serao considerados no processamento","da rotina de copia."},{},{})
PutSx1("MARKCX1","04","Tipo Ate ?           "   ,"Tipo Ate ?           "   ,"Tipo Ate ?           "    ,"mv_ch4","C", 2,0,0,"G",""                    ,"ZZF"      ,"","","mv_par04","","","","","","","","","","","","","","","","",{"Informe o tipo do produto ","para selecao dos registros ","que serao considerados no processamento","da rotina de copia."},{},{})
PutSx1("MARKCX1","05","Grupo De ?           "   ,"Grupo De ?           "   ,"Grupo De ?           "    ,"mv_ch5","C", 4,0,0,"G",""                    ,"SBM"      ,"","","mv_par05","","","","","","","","","","","","","","","","",{"Informe o grupo do produto ","para selecao dos registros ","que serao considerados no processamento","da rotina de copia."},{},{})
PutSx1("MARKCX1","06","Grupo Ate ?          "   ,"Grupo Ate ?          "   ,"Grupo Ate ?          "    ,"mv_ch6","C", 4,0,0,"G",""                    ,"SBM"      ,"","","mv_par06","","","","","","","","","","","","","","","","",{"Informe o grupo do produto ","para selecao dos registros ","que serao considerados no processamento","da rotina de copia."},{},{})
//+----------------------------------------------------------------------------
//| Monta tela de paramentos para usuario, se cancelar sair
//+----------------------------------------------------------------------------
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

//MsgRun("Filtrando os produtos...","Aguarde...",{|| U__Filtrad(mv_par01,mv_par02,mv_par03, mv_par04,mv_par05,mv_par06)})
U__Filtrad(mv_par01,mv_par02,mv_par03, mv_par04,mv_par05,mv_par06)

//MsgAlert("ROTINA EM DESENVOLVIMENTO","CHAUS CONSULTORIA")
RETURN


User Function _Filtrad(DePro, AtePro, DeTipo, AteTipo,DeGrupo, AteGrupo)

Local oMark := GetMarkBrow()
dbSelectArea('ZP5')
dbGotop()
While !Eof()
	
	IF ALLTRIM(DePro)$ZP5->ZP5_DESCPR .AND. ZP5->ZP5_TIPOB1>=DeTipo .AND. ZP5->ZP5_TIPOB1<=AteTipo .AND. ZP5->ZP5_GRUPO>=DeGrupo .AND. ZP5->ZP5_GRUPO<=AteGrupo
		IF RecLock( 'ZP5', .F. )
			If ZP5->ZP5_OK==Space(2)
				Replace ZP5->ZP5_OK With cMark
				_imark:=.T.
				ZP5->ZP5_STATUS := '0'
			else
				Replace ZP5->ZP5_OK With Space(2)
				_imark:=.F.
				ZP5->ZP5_STATUS := '1'
			Endif
			MsUnLock()
		EndIf
	Endif
	dbSkip()
	
Enddo
cTxtmsg:=Iif(_imark,"Desmarcando os produtos pre-selecionados...","Marcando os produtos pre-selecionados...")
MarkBRefresh( )// for�a o posicionamento do browse no primeiro registro
oMark:oBrowse:Gotop()
Return


// Funcao para validar se ja existe a licenca

USER FUNCTION VLDLICEN()

teste := " "

_aAREA:=GetArea()
dbSelectArea("ZP1")
dbSetOrder(1)
//IF DbSeek(XFILIAL("ZP1")+SPACE(LEN(ZP1_FILIAL)-LEN(XFILIAL(ZP1_FILIAL)))+M->ZP1_CODCLI+M->ZP1_LOJA+M->ZP1_ORGAO)
IF DbSeek(XFILIAL("ZP1")+M->ZP1_CODCLI+M->ZP1_LOJA+M->ZP1_ORGAO)
	MsgInfo("Licen�a j� cadastrada!!","Aten��o")
	lRet:=.F.
	M->ZP1_LICENC:=ZP1->ZP1_LICENC
ELSE
	lRet:=.T.
ENDIF
RestArea(_aArea)

Return(lRet)
                                                                   
