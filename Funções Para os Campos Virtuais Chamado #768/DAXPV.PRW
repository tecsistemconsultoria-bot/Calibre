#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'
#Include "TopConn.ch"

/*=================================================================
Autor: Otávio Barreiro
Data: 25/06/2026
Consultoria: TecSistem
Uso: Calibre
Info: função para checar se existe um registro da SDA na SVZ
*==================================================================*/
User Function DAXPV()

Local aArea    := GetArea()
Local cQuery   := ""
Local cRet     := ""
Local cTemp    := ""

cTemp := GetNextAlias()

DbSelectArea("SDA")

cQuery := "SELECT SDA.R_E_C_N_O_ AS RECNO, "
cQuery += "DA_PRODUTO, "
cQuery += "DA_LOCAL, "
cQuery += "DA_XCONF, "
cQuery += "ZV_PROD, "
cQuery += "ZV_QTDSLD "
cQuery += "FROM "+ RetSqlName("SDA") + " SDA "
cQuery += "LEFT JOIN "+ RetSqlName("SZV") + " SZV "
cQuery += "ON ZV_PROD = DA_PRODUTO "
cQuery += "   AND ZV_QTDSLD <> 0 "
cQuery += "   AND SZV.D_E_L_E_T_ <> '*' "
cQuery += "WHERE DA_PRODUTO = '" + AllTrim(SDA->DA_PRODUTO) + "' "
cQuery += "AND SDA.R_E_C_N_O_ = "+cValToChar(SDA->(RecNo()))+" "
cQuery += "AND ( "
cQuery += "   (DA_LOCAL = 'AC' AND DA_XCONF = 'F') "
cQuery += "OR (DA_LOCAL <> 'AC' AND DA_SALDO <> 0) "
cQuery += "  ) "
cQuery += "  AND SDA.D_E_L_E_T_ <> '*' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)

If !(cTemp)->(Eof())
    cRet := "Sim"
Else
    cRet := "Nao"
EndIf

(cTemp)->(DbCloseArea())

RestArea(aArea)
Return(cRet)
