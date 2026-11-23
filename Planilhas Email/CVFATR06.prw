#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'TopConn.ch'

/*/{Protheus.doc} CVFATR06
POs ou Embarque que vencem em ate 5 dias e vencidos.
@author Nicolas
/*/
User Function CVFATR06()
    Local aEmails  := {}
    Local cTitulo  := ""
    Local cCorpo   := ""
    Local cPath    := ""
    Local cData    := ""
    Local cHora    := ""
    Local cDtHora  := ""
    Local cNomeArq := ""
    Local cQuery   := ""
    Local cAlias   := ""
	Local nX       := 0
    Local nFormato := 0
	Local aLinha   := {}
    Local aHeader  := {}
    Local aCampos  := {} 
    Local aTipos   := {} 
    Local lAbreEnv := .F.
	Local cTabela  := ""
    Local oExcel   := FWMSEXCEL():New()
    
	// Preparação do Ambiente: suporta JOB (sem SX2 ativo) ou execução via Menu
    If IsBlind() .or. Select("SX2") <= 0
		RPCSetEnv("01", "01")
        lAbreEnv := .T.
	Endif

	aEmails  := {}
	cTitulo  := "Relatorio Das Purchase Orders e Embarques"
	cCorpo   := "Segue em anexo a planilha de POs/Embarques (Vencidos e A Vencer em 5 dias)."
	cPath    := GetMV("XX_XARQUI",.F.,"\spool\")
	cData    := StrTran(DToS(Date()),"/","")
	cHora    := StrTran(Time(),":","")
	cDtHora  := AllTrim(cData+"_"+cHora)
	cNomeArq := "Purchase Orders_"+cDtHora+".xml"
	cQuery   := ""
	cAlias   := ""
	nX       := 0
	nFormato := 0
	aLinha   := {}
	aHeader  := {}
	aCampos  := {} 
	aTipos   := {} 
	cTabela  := "XI"
	oExcel   := FWMSEXCEL():New()
    
	aEmails := BuscaEmail(cTabela)

    If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf

    // Obs: Montado sobre a SC7. Alinhar se for usar SW8 (Easy Import Control).
    oExcel:AddworkSheet("POs_Embarques")
    oExcel:AddTable("POs_Embarques", "Dados")
    oExcel:AddColumn("POs_Embarques", "Dados", "Filial", 1, 1)
    oExcel:AddColumn("POs_Embarques", "Dados", "Pedido/PO", 1, 1)
    oExcel:AddColumn("POs_Embarques", "Dados", "Fornecedor", 1, 1)
    oExcel:AddColumn("POs_Embarques", "Dados", "Produto", 1, 1)
    oExcel:AddColumn("POs_Embarques", "Dados", "Dt Entrega", 1, 3)
    oExcel:AddColumn("POs_Embarques", "Dados", "Status", 1, 1)

    cQuery := " SELECT C7_FILIAL, C7_NUM, C7_FORNECE, C7_PRODUTO, C7_DATPRF "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
    cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
    // Vencidos ( < dDataBase) OU Vencem em ate 5 dias ( <= dDataBase + 5)
    cQuery += "   AND SC7.C7_DATPRF <= '" + DTOS(dDataBase + 5) + "' " 
    cQuery += "   AND SC7.C7_DATPRF <> ' ' "
    cQuery += "   AND SC7.C7_QUANT > SC7.C7_QUJE " 
    cQuery += " ORDER BY SC7.C7_DATPRF "
    
    cAlias := MPSysOpenQuery(cQuery)

    While !(cAlias)->(Eof())
        oExcel:AddRow("POs_Embarques", "Dados", { ;
            (cAlias)->C7_FILIAL, ;
            (cAlias)->C7_NUM, ;
            (cAlias)->C7_FORNECE, ;
            (cAlias)->C7_PRODUTO, ;
            STOD((cAlias)->C7_DATPRF), ;
            If((cAlias)->C7_DATPRF < DTOS(dDataBase), "VENCIDO", "VENCE EM <= 5 DIAS") ;
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
