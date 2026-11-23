#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'TopConn.ch'

/*/{Protheus.doc} CVFATR05
PVs com entregas atrasadas (C6_ENTREG < dDatabase) e a vencer em ate 10 dias.
Ignora itens com C6_BLQ = 'R'. Filtra apenas C5_TIPO = 'N'.
@author Nicolas
/*/
User Function CVFATR05()
    Local aEmails    := {}
    Local cTitulo    := ""
    Local cCorpo     := ""
    Local cPath      := ""
    Local cData      := ""
    Local cHora      := ""
    Local cDtHora    := ""
    Local cNomeArq   := ""
    Local cQuery     := ""
    Local cAlias     := ""
    Local nX         := 0
    Local nFormato   := 0
    Local nVlrAtr    := 0
    Local nVlrAvenc  := 0
    Local aTotAtr    := {}
    Local aTotAvenc  := {}
	Local aLinha     := {}
    Local aHeader    := {}
    Local aCampos    := {} 
    Local aTipos     := {} 
    Local cTabela    := ""
    Local lAbreEnv   := .F.
    Local oExcel     := FWMSEXCEL():New()

    // Preparação do Ambiente: suporta JOB (sem SX2 ativo) ou execução via Menu
    If IsBlind() .or. Select("SX2") <= 0
		RPCSetEnv("01", "01")
        lAbreEnv := .T.
	Endif

    aEmails    := {}
    cTitulo    := "Relatorio de Pedidos de Vendas"
    cCorpo     := "Segue em anexo a planilha de Pedidos de Venda com entregas atrasadas e a vencer em ate 10 dias."
    cPath      := GetMV("XX_XARQUI",.F.,"\spool\")
    cData      := StrTran(DToS(Date()),"/","")
    cHora      := StrTran(Time(),":","")
    cDtHora    := AllTrim(cData+"_"+cHora)
    cNomeArq   := "Pedidos de Vendas_"+cDtHora+".xml"
    cQuery     := ""
    cAlias     := ""
    nX         := 0
    nFormato   := 0
    nVlrAtr    := 0
    nVlrAvenc  := 0
    aTotAtr    := {}
    aTotAvenc  := {}
	aLinha     := {}
    aHeader    := {}
    aCampos    := {} 
    aTipos     := {} 
    cTabela    := "XH"
    oExcel     := FWMSEXCEL():New()

    aEmails := BuscaEmail(cTabela)

    If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf

    // -- ABA 1: ATRASADOS (C6_ENTREG < dDatabase) --

    DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) 
    If SX3->(DbSeek("SZV"))
	
        While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SZV"
		
            aAdd(aCampos, AllTrim(SX3->X3_CAMPO)) 
            aAdd(aHeader, AllTrim(SX3->X3_TITULO))
            aAdd(aTipos,  AllTrim(SX3->X3_TIPO))
			
            SX3->(DbSkip())
			
        EndDo
		
    EndIf
    
    oExcel:AddWorkSheet("Atrasados")
    oExcel:AddTable("Atrasados", "Dados")

    For nX := 1 To Len(aCampos)
    
        If aTipos[nX] == "D"     //4=Data  
            nFormato := 4          
        ElseIf aTipos[nX] == "N" //2=Número 
            nFormato := 2
        Else                     //1=Caracter
            nFormato := 1
        EndIf

		oExcel:AddColumn("Atrasados", "Dados", aHeader[nX],2, nFormato)   
						
	Next nX

    cQuery := " SELECT * "
    cQuery += " FROM "  + RetSqlName("SZV") + " "
    cQuery += " WHERE  ZV_DTFAT  < '" + DTOS(dDatabase) + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY ZV_DTFAT DESC "

    cAlias := MPSysOpenQuery(cQuery)
    
    While !(cAlias)->(Eof())
        aLinha     := {}

        For nX := 1 To Len(aCampos)
             
            aAdd(aLinha,(cAlias)->(FieldGet(FieldPos(aCampos[nX]))))

            If aTipos[nX] == "D" .AND. !Empty(aLinha[nX])     //4=Data 
                aLinha[nX] := SToD(aLinha[nX])
            EndIf
                            
        Next nX
        
        oExcel:AddRow("Atrasados", "Dados",aLinha)
        nVlrAtr += (cAlias)->ZV_TOTAL
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    // -- ABA 2: A VENCER (C6_ENTREG entre dDatabase e dDatabase+5) --

    aHeader    := {}
    aCampos    := {}
    aTipos     := {}

    DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) 
    If SX3->(DbSeek("SZV"))
	
        While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SZV"
		
            aAdd(aCampos, AllTrim(SX3->X3_CAMPO)) 
            aAdd(aHeader, AllTrim(SX3->X3_TITULO))
            aAdd(aTipos,  AllTrim(SX3->X3_TIPO))
			
            SX3->(DbSkip())
			
        EndDo
		
    EndIf

    oExcel:AddWorkSheet("A_Vencer")
    oExcel:AddTable("A_Vencer", "Dados")
    
    For nX := 1 To Len(aCampos)
    
        If aTipos[nX] == "D"     //4=Data  
            nFormato := 4          
        ElseIf aTipos[nX] == "N" //2=Número 
            nFormato := 2
        Else                     //1=Caracter
            nFormato := 1
        EndIf

		oExcel:AddColumn("A_Vencer", "Dados", aHeader[nX],2, nFormato)   
						
	Next nX

    cQuery := " SELECT * "
    cQuery += " FROM "  + RetSqlName("SZV") + " "
    cQuery += " WHERE  ZV_DTFAT >= '" + DTOS(dDatabase) + "' "
    cQuery += " AND ZV_DTFAT  <= '" + DTOS(dDatabase + 10) + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY ZV_DTFAT DESC "

    cAlias := MPSysOpenQuery(cQuery)

    While !(cAlias)->(Eof())
        aLinha     := {}

        For nX := 1 To Len(aCampos)

            aAdd(aLinha,(cAlias)->(FieldGet(FieldPos(aCampos[nX]))))

            If aTipos[nX] == "D" .AND. !Empty(aLinha[nX])     //4=Data 
                aLinha[nX] := SToD(aLinha[nX])
            EndIf
                            
        Next nX
        
        oExcel:AddRow("A_Vencer", "Dados",aLinha)
        nVlrAvenc += (cAlias)->ZV_TOTAL
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    aTotAtr   := Array(Len(aLinha))
    aTotAvenc := Array(Len(aLinha))
    
    AFill(aTotAtr, "")
    aTotAtr[1]  := "TOTAL"
    aTotAtr[17] := nVlrAtr

    AFill(aTotAvenc, "")
    aTotAvenc[1]  := "TOTAL"
    aTotAvenc[17] := nVlrAvenc

    oExcel:AddRow("Atrasados", "Dados", aTotAtr)
    oExcel:AddRow("A_Vencer", "Dados", aTotAvenc)

    oExcel:Activate()
    oExcel:GetXMLFile(cPath + cNomeArq)

    For nX := 1 To Len(aEmails)
        xEnvMail(cPath + cNomeArq, aEmails[nX], cTitulo, cCorpo)
    Next nX

    // Encerra o ambiente somente se foi esta rotina que o abriu
    If lAbreEnv
        RPCClearEnv()
    EndIf


Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informacao
Uso: Calibre
Info: Envio de e-mail
*==================================================================*/
Static Function xEnvMail(cArquivo,cEmail,cAssunto,cCorpo)

	Local cAssuntoFinal := If(Empty(cAssunto), "Relatorio", cAssunto)
	Local cBodyFinal    := If(Empty(cCorpo), "Segue em anexo relatorio.", cCorpo)
	Local lMailAuth	:= GetMV("MV_RELAUTH",.F.,.T.)
	Local nPortSMTP := 587
	Local nTimeout  := GetMV("MV_RELTIME")
	Local xRet
	Local oServer	
	Local oMessage

    Private cMailConta  := Alltrim(GetMV("MV_RELACNT"))
	Private cMailServer := AllTrim(GetMV("MV_RELSERV"))
	Private cMailSenha  := Alltrim(GetMV("MV_RELPSW"))
	Private nPosPort    := AT(":", cMailServer)

	If nPosPort > 0
		nPortSMTP   := Val(SubStr(cMailServer, nPosPort+1))
		cMailServer := AllTrim(SubStr(cMailServer, 1, nPosPort-1))
	EndIf

	If Empty(cArquivo) .Or. Empty(cEmail)
		Return .F.
	EndIf

	oServer := TMailManager():New()
	oServer:SetUseTLS(.T.)
	oServer:SetUseSSL(.T.)

    xRet := oServer:Init( "", cMailServer, Alltrim(GetMV("MV_RELFROM",.F.,"noreply@calibrescientific.com.br")), cMailSenha,, nPortSMTP )

	If xRet <> 0
		MsgAlert("O servidor SMTP nao foi inicializado: " + oServer:GetErrorString( xRet ))
		Return .F.
	EndIf

	xRet := oServer:SetSMTPTimeout(nTimeout)

	If xRet <> 0
		MsgAlert("Tempo limite para " + cValToChar( nTimeout ))
	EndIf

	xRet := oServer:SMTPConnect()

	If xRet <> 0
		MsgAlert("Nao foi possivel conectar ao server SMTP: " + oServer:GetErrorString( xRet ))
		Return .F.
	EndIf

	If lMailAuth

		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )

		If xRet <> 0
			MsgAlert("Nao foi possivel autenticar no server SMTP: " + oServer:GetErrorString( xRet ))
			oServer:SMTPDisconnect()
			Return .F.
		EndIf

	EndIf

	oMessage := TMailMessage():New()

	oMessage:Clear()

	oMessage:cDate	  := cValToChar(Date())
	oMessage:cFrom 	  := AllTrim(GetMV("MV_RELFROM",.F.,"noreply@calibrescientific.com.br"))
	oMessage:cTo 	  := cEmail
	oMessage:cSubject := cAssuntoFinal
	oMessage:cBody 	  := cBodyFinal

	xRet := oMessage:AttachFile(cArquivo)

	If xRet < 0
		MsgAlert("Nao foi possivel anexar o arquivo: " + cArquivo)
		oServer:SMTPDisconnect()
		Return .F.
	EndIf

	xRet := oMessage:Send( oServer )

	If xRet <> 0
		MsgAlert("Nao foi possivel enviar o relatorio: " + oServer:GetErrorString( xRet ))
	Else
		//MsgAlert("Relatorio enviado com sucesso...")
	EndIf

	xRet := oServer:SMTPDisconnect()

	If xRet <> 0
		MsgAlert("Nao foi possivel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	Else
		//MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Server desconectado com sucesso...")
	EndIf

Return .T.

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informacao
Uso: Calibre
Info: Buscar Emails para envio dos relatorios
*==================================================================*/

Static Function BuscaEmail(cTabela)
	Local aRet := {}
	Local cQry := ""

	cQry += "SELECT * FROM "+RetSqlName("SX5")+" "
	cQry += " WHERE D_E_L_E_T_ = ' ' AND X5_FILIAL = '"+xFilial("SX5")+"' "
	cQry += "   AND X5_TABELA = '"+cTabela+"' AND X5_DESCRI <> ' ' "
	MpSysOpenQuery(cQry, "TMPB")

	Do While TMPB->( ! Eof())
		if IsEmail(TMPB->X5_DESCRI)
			AAdd(aRet, Lower(Alltrim(TMPB->X5_DESCRI)) )
		Endif	
		TMPB->( Dbskip())
	Enddo

	TMPB->( DbCloseArea())

Return( aRet )
