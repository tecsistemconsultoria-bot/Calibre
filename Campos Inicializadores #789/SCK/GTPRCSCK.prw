#INCLUDE "PROTHEUS.CH"
#include "Rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function GTPRCSCK(_Orig)
Local 	_Ret 	:= 0
Local 	_Prod   := AllTrim(TMP1->CK_PRODUTO)
Local 	aArea   := GetArea()
		
If "00880601" == M->CJ_CLIENTE+M->CJ_LOJA .OR. "00256001"== M->CJ_CLIENTE+M->CJ_LOJA                                                                                                                                                                                                                                                
	_Ret := BSCCUST(_Prod)
Else
	_Ret := U_GatPrc("FAT",_Orig,_Prod,M->CJ_CLIENTE,M->CJ_LOJA,M->CJ_TABELA)
Endif

SYSREFRESH()
GetDRefresh()
RestArea(aArea)
Return _Ret


Static Function BSCCUST(_Prod)
Local _cus:=0
Local cQuery:=''

cQuery := "SELECT B9_DATA, B9_CM1 FROM "+RETSQLNAME('SB9')+" WHERE B9_FILIAL='"+xFilial("SB9")+"' AND B9_LOCAL='"+xFilial("SB9")+"' AND B9_VINI1>0 AND D_E_L_E_T_ <> '*' AND B9_COD = '"+_Prod+"'"
cQuery += "ORDER BY B9_DATA DESC"
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QrySB9",.F.,.T.)
DbSelectArea("QrySB9")
DBGoTop()
Do While !Eof()
	_cus  := QrySB9->B9_CM1
	If _cus>0
		EXIT
	Endif
	DbSelectArea("QrySB9")
	DbSkip()
Enddo
DbSelectArea("QrySB9")
DBCloseArea()
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+_Prod)
If Found()
	If _cus>0
		If SB1->B1_ORIGEM $ '1/3/5/8'
			_cus:=ROUND(_cus/0.96,2)
		Else
			_cus:=ROUND(_cus/0.88,2)
		Endif
	Endif
Endif
Return _cus
