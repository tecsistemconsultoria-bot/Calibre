#Include "Protheus.ch"

User Function xCalCondi()
Local aArea   := GetArea()
Local nRet    := .T.

If M->C5_TIPO $ 'D|B|C' .OR. GDFieldGet("C6_OPER")=='20' .OR. GDFieldGet("C6_XPRCNEG") <> 0
    nRet := .F.
EndIf

RestArea(aArea)

Return nRet
