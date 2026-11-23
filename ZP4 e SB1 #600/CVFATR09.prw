#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'TopConn.ch'

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/04/2026
Consultoria: TecSistem Consultoria em Sistemas de Informacao
Uso: Calibre
Info: Comparação de produtos das tabelas SB1 e ZP4
*==================================================================*/
User Function CVFATR09()

	RPCSetEnv("01","01",,,"COM")

    Local aEmails  := {}
    Local cTitulo  := "Relatorio de Produtos - SB1 x ZP4"
    Local cCorpo   := "Estes produtos estão no cadastro de produtos, controlam PF ou ME, mas não estão cadastrados na tabela ZP4."
    Local cPath    := GetMV("XX_XARQUI",.F.,"\spool\")
    Local cData    := StrTran(DToS(Date()),"/","")
    Local cHora    := StrTran(Time(),":","")
    Local cDtHora  := AllTrim(cData+"_"+cHora)
    Local cNomeArq := "Comparacao_"+cDtHora+".xml"
    Local cQuery   := ""
    Local cAlias   := ""
	Local cTabela  := "XF"
	Local nX       := 0

	aEmails := BuscaEmail(cTabela)
	
    Local oExcel   := FWMSEXCEL():New()

    oExcel:AddworkSheet("SB1_x_ZP4")
    oExcel:AddTable("SB1_x_ZP4", "Dados")
    oExcel:AddColumn("SB1_x_ZP4", "Dados", "Código", 1, 1)
    oExcel:AddColumn("SB1_x_ZP4", "Dados", "Descrição", 1, 1)
    oExcel:AddColumn("SB1_x_ZP4", "Dados", "Tipo", 1, 1)
    oExcel:AddColumn("SB1_x_ZP4", "Dados", "NCM", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Bloqueio de Tela", 1, 1)
    oExcel:AddColumn("SB1_x_ZP4", "Dados", "Controla PF?", 1, 1)
    oExcel:AddColumn("SB1_x_ZP4", "Dados", "Controla ME?", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Marca", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Anuente?", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Prod. Importado?", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Prod.Perigo?", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "No. ONU", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Classe Risco", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "N° Risco", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Risco Sub.", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "CAS", 1, 1)
	oExcel:AddColumn("SB1_x_ZP4", "Dados", "Data criação", 1, 4)

    cQuery := " "
	cQuery += " SELECT SB1.B1_COD AS Codigo, "
	cQuery += "        SB1.B1_DESC AS Descricao, "
	cQuery += "        SB1.B1_TIPO AS Tipo, "
	cQuery += "        SB1.B1_POSIPI AS NCM, "
	cQuery += "        SB1.B1_MSBLQL AS BLQ, "
	cQuery += "        SB1.B1_CRVPF AS Controla_PF, "
	cQuery += "        SB1.B1_CRVME AS Controla_ME, "
	cQuery += "        SB1.B1_FABRIC AS Marca, "
	cQuery += "        SB1.B1_ANUENTE AS Anuente, "
	cQuery += "        SB1.B1_IMPORT AS Prod_Importado, "
	cQuery += "        SB1.B1_CRVDG AS Prod_Perigo, "
	cQuery += "        SB1.B1_CRVDG05 AS Numero_ONU, "
	cQuery += "        SB1.B1_CRVDG03 AS Classe_Risco, "
	cQuery += "        SB1.B1_CRVDG04 AS Numero_Risco, "
	cQuery += "        SB1.B1_CRVDG06 AS Risco_Sub, "
	cQuery += "        SB1.B1_CRVCAS AS CAS, "
	cQuery += "        SB1.B1_CRVDATA AS Data_Criacao "
	cQuery += " FROM SB1010 SB1 "
	cQuery += " LEFT JOIN ZP4010 ZP4 ON SB1.B1_COD = ZP4.ZP4_CODPRO "
	cQuery += " AND ZP4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND (SB1.B1_CRVPF = 'S' "
	cQuery += "        OR SB1.B1_CRVME = 'S') "
	cQuery += "   AND ZP4.ZP4_CODPRO IS NULL "

    cAlias := MPSysOpenQuery(cQuery)

        While !(cAlias)->(Eof())
        oExcel:AddRow("SB1_x_ZP4", "Dados", { ;
            (cAlias)->Codigo, ;
            (cAlias)->Descricao, ;
            (cAlias)->Tipo, ;
            (cAlias)->NCM, ;
			StrTran(StrTran((cAlias)->BLQ, "1", "SIM"), "2", "NAO"), ;
            StrTran(StrTran((cAlias)->Controla_PF, "S", "SIM"), "N", "NAO"), ;
            StrTran(StrTran((cAlias)->Controla_ME, "S", "SIM"), "N", "NAO"), ;
            (cAlias)->Marca, ;
            StrTran(StrTran((cAlias)->Anuente, "1", "SIM"), "2", "NAO"), ;
            StrTran(StrTran((cAlias)->Prod_Importado, "S", "SIM"), "N", "NAO"), ;
            StrTran(StrTran((cAlias)->Prod_Perigo, "S", "SIM"), "N", "NAO"), ;
            (cAlias)->Numero_ONU, ;
            (cAlias)->Classe_Risco, ;
            (cAlias)->Numero_Risco, ;
            (cAlias)->Risco_Sub, ;
            (cAlias)->CAS, ;
            SToD((cAlias)->Data_Criacao);
        })
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

	oExcel:Activate()
    oExcel:GetXMLFile(cPath + cNomeArq)
	FreeObj(oExcel)

	For nX := 1 To Len(aEmails)
		xEnvMail(cPath + cNomeArq, aEmails[nX], cTitulo, cCorpo)
	Next nX

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informacao
Uso: Calibre
Info: Envio de e-mail 
*==================================================================*/
Static Function xEnvMail(cArquivo,cEmail,cAssunto,cCorpo,nTotal)

	Local cAssuntoFinal := If(Empty(cAssunto), "Relatorio", cAssunto)
	Local cBodyFinal    := If(Empty(cCorpo), "Segue em anexo relatorio.", cCorpo)
	Local lMailAuth	:= GetMV("MV_RELAUTH",.F.,.T.) //Autenticacao com server SMTP
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

    xRet := oServer:Init( "", cMailServer, Alltrim(GetMV("MV_RELFROM",.F.,"no-reply@carvalhaes.net")), cMailSenha,, nPortSMTP )

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
	oMessage:cFrom 	  := AllTrim(GetMV("MV_RELFROM",.F.,"no-reply@carvalhaes.net"))
	oMessage:cTo 	  := cEmail
	oMessage:cSubject := cAssuntoFinal
	oMessage:cBody 	  := cBodyFinal

	xRet := oMessage:AttachFile(cArquivo)
	
	If xRet < 0
		MsgAlert("Nao foi possivel anexar o arquivo: " + cArquivo)
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
