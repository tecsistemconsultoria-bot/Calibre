#INCLUDE "PROTHEUS.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "Rwmake.ch"
#INCLUDE "TOPCONN.CH"                               
#INCLUDE "TBICONN.CH" 

User Function M265FIL()

    Local nCount   := 0
    Local aArea    := GetArea()
    Local cQuery   := ""
    Local cTemp    := ""
    Local dHoje    := Date() + 1
    Local dDataIni := Date() - 30

	cTemp := GetNextAlias()

	cQuery := "SELECT * "
	cQuery += " FROM " +RetSqlName("SDA")
    cQuery += " WHERE DA_DATA BETWEEN '"+dDataIni+"' AND '"+dHoje+"'"
    cQuery += " AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
	DbSelectArea(cTemp)

    // Percorre a tabela SDA
    While !(cTemp)->(EOF())
        
        // Exemplo de condição: verificar se o produto é 'PROD001'
        If (cTemp)->DA_XQTDREC == 0 
            
            // Inicia o processo de alteração
            RecLock(cTemp, .F.)
            
            // Altera o campo desejado
            (cTemp)->DA_XQTDREC := (cTemp)->DA_QTDORI
            
            // Finaliza o RecLock
            MsUnlock()
        EndIf

        (cTemp)->(dbSkip())
    EndDo

    RestArea(aArea)

Return Nil

