#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'TopConn.ch'

/*/{Protheus.doc} CVFATR07
Licencas dos clientes e produtos anuentes que expirarao em ATE 10 DIAS.
Ignora ZPx_MSBLQL = '1'
@author Nicolas
/*/
User Function CVFATR07()
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
	Local aLinha     := {}
    Local aHeader    := {}
    Local aCampos    := {} 
    Local aTipos     := {}
    Local lAbreEnv   := .F.
    Local cTabela    := ""
    Local oExcel   := FWMSEXCEL():New()


    // Preparação do Ambiente: suporta JOB (sem SX2 ativo) ou execução via Menu
    If IsBlind() .or. Select("SX2") <= 0
		RPCSetEnv("01", "01")
        lAbreEnv := .T.
	Endif

    aEmails    := {}
    cTitulo    := "Licencas a Vencer (Ate 10 Dias)"
    cCorpo     := "Segue em anexo a planilha de licencas de Clientes (ZP1) e Produtos (ZP2) a vencer."
    cPath      := GetMV("XX_XARQUI",.F.,"\spool\")
    cData      := StrTran(DToS(Date()),"/","")
    cHora      := StrTran(Time(),":","")
    cDtHora    := AllTrim(cData+"_"+cHora)
    cNomeArq   := "Licencas_A_Vencer_"+cDtHora+".xml"
    cQuery     := ""
    cAlias     := ""
	nX         := 0
    nFormato   := 0
	aLinha     := {}
    aHeader    := {}
    aCampos    := {} 
    aTipos     := {}
    cTabela    := "XJ"
    oExcel   := FWMSEXCEL():New()

    aEmails := BuscaEmail(cTabela)

    If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf

	// -- ABA 1: CLIENTES (ZP1) --
	DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) 
    If SX3->(DbSeek("ZP1"))
	
        While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "ZP1"
		
            //If AllTrim(SX3->X3_BROWSE) == "S"
			
                aAdd(aCampos, AllTrim(SX3->X3_CAMPO)) 
                aAdd(aHeader, AllTrim(SX3->X3_TITULO))
                aAdd(aTipos,  AllTrim(SX3->X3_TIPO))
				
            //EndIf
			
            SX3->(DbSkip())
			
        EndDo
		
    EndIf
    
    oExcel:AddworkSheet("Clientes_ZP1")
    oExcel:AddTable("Clientes_ZP1", "Dados")

    For nX := 1 To Len(aCampos)
    
        If aTipos[nX] == "D"     //3=Data  
            nFormato := 4          
        ElseIf aTipos[nX] == "N" //2=Número 
            nFormato := 2
        Else                     //1=Caracter
            nFormato := 1
        EndIf

		oExcel:AddColumn("Clientes_ZP1","Dados", aHeader[nX], 2, nFormato)  
						
	Next nX

    cQuery := " SELECT * FROM " + RetSqlName("ZP1") + " ZP1 "
    cQuery += " WHERE ZP1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND ZP1.ZP1_MSBLQL <> '1' "
    cQuery += "   AND ZP1.ZP1_DTVLD >= '" + DTOS(dDataBase) + "' "
    cQuery += "   AND ZP1.ZP1_DTVLD <= '" + DTOS(dDataBase + 10) + "' "
    cAlias := MPSysOpenQuery(cQuery)

	While !(cAlias)->(Eof())
        aLinha     := {}

        For nX := 1 To Len(aCampos)

            aAdd(aLinha,(cAlias)->(FieldGet(FieldPos(aCampos[nX]))))

            If aTipos[nX] == "D" .AND. !Empty(aLinha[nX])     //4=Data 
                aLinha[nX] := SToD(aLinha[nX])
            EndIf

            If  nX == 4 .AND. !Empty(aLinha[2])
                aLinha[nX] := Nomcli(aLinha)
            EndIf 
                            
        Next nX
        
        oExcel:AddRow("Clientes_ZP1", "Dados",aLinha)
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())


    // -- ABA 2: PRODUTOS (ZP2) --
	aHeader    := {}
	aCampos    := {}
	aTipos     := {}

	DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) 
    If SX3->(DbSeek("ZP2"))
	
        While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "ZP2"
		
            //If AllTrim(SX3->X3_BROWSE) == "S"
			
                aAdd(aCampos, AllTrim(SX3->X3_CAMPO)) 
                aAdd(aHeader, AllTrim(SX3->X3_TITULO))
                aAdd(aTipos,  AllTrim(SX3->X3_TIPO))
                
            //EndIf
			
            SX3->(DbSkip())
			
        EndDo
		
    EndIf

    oExcel:AddworkSheet("Produtos_ZP2")
    oExcel:AddTable("Produtos_ZP2", "Dados")

    For nX := 1 To Len(aCampos)
    
        If aTipos[nX] == "D"     //3=Data  
            nFormato := 4          
        ElseIf aTipos[nX] == "N" //2=Número 
            nFormato := 2
        Else                     //1=Caracter
            nFormato := 1
        EndIf

		oExcel:AddColumn("Produtos_ZP2","Dados", aHeader[nX], 2, nFormato)   
						
	Next nX

    cQuery := " SELECT * FROM " + RetSqlName("ZP2") + " ZP2 "
    cQuery += " WHERE ZP2.D_E_L_E_T_ = ' ' "
	//cQuery += "   AND ZP2.ZP2_MSBLQL <> '1' "
    cQuery += "   AND ZP2.ZP2_DTVLD >= '" + DTOS(dDataBase) + "' "
    cQuery += "   AND ZP2.ZP2_DTVLD <= '" + DTOS(dDataBase + 10) + "' "
    cAlias := MPSysOpenQuery(cQuery)

	While !(cAlias)->(Eof())
        aLinha     := {}

        For nX := 1 To Len(aCampos)

            aAdd(aLinha,(cAlias)->(FieldGet(FieldPos(aCampos[nX]))))

            
            If aTipos[nX] == "D" .AND. !Empty(aLinha[nX])     //4=Data 
                aLinha[nX] := SToD(aLinha[nX])
            EndIf

            If  nX == 4 .AND. !Empty(aLinha[2])
                aLinha[nX] := Nomcli(aLinha)
            EndIf 
                            
        Next nX
        
        oExcel:AddRow("Produtos_ZP2", "Dados",aLinha)
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
Info: Pegar Nome do cliente
*==================================================================*/
Static Function Nomcli(aLinha)

    Local cRet := " "

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) 
    If SA1->(DbSeek(XFILIAL('SA1')+aLinha[2]+aLinha[3]))
        cRet := AllTrim(SA1->A1_NOME)
    EndIf

Return cRet


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
