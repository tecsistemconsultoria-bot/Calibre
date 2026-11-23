#Include 'Protheus.ch'

/*/{Protheus.doc} XTESTMAIL
Painel de Testes para disparo manual das rotinas de e-mail
@author Nicolas
/*/
User Function XTESTMAIL()
    Local oDlg
    Local oBtn1, oBtn2, oBtn3, oBtn4, oBtn5
    Local lAbreEnv := .F.

    If Select("SX2") <= 0
        MsgInfo("Abrindo o ambiente com RPCSetEnv...", "Aviso")
		RPCSetEnv("01", "01")
        lAbreEnv := .T. 
    EndIf

    DEFINE MSDIALOG oDlg TITLE "Painel de Testes - Relatorios" FROM 0,0 TO 300,350 PIXEL
    
    @ 10, 40 SAY "Escolha a rotina que deseja testar:" SIZE 120, 10 OF oDlg PIXEL

    @ 30,  30 BUTTON oBtn1 PROMPT "1. CVFATR04 (PVs para Faturar)"  SIZE 110, 15 OF oDlg ACTION {|| fChamaRotina("CVFATR04") } PIXEL
    @ 50,  30 BUTTON oBtn2 PROMPT "2. CVFATR05 (Pedido De Vendas)" SIZE 110, 15 OF oDlg ACTION {|| fChamaRotina("CVFATR05") } PIXEL
    @ 70,  30 BUTTON oBtn3 PROMPT "3. CVFATR06 (POs/Embarque)"  SIZE 110, 15 OF oDlg ACTION {|| fChamaRotina("CVFATR06") } PIXEL
    @ 90,  30 BUTTON oBtn4 PROMPT "4. CVFATR07 (Licencas Vencer)" SIZE 110, 15 OF oDlg ACTION {|| fChamaRotina("CVFATR07") } PIXEL
    @ 110, 30 BUTTON oBtn5 PROMPT "5. CVFATR08 (Licencas Vencidas)" SIZE 110, 15 OF oDlg ACTION {|| fChamaRotina("CVFATR08") } PIXEL

    ACTIVATE MSDIALOG oDlg CENTER

    If lAbreEnv
        RPCClearEnv()
        MsgInfo("Ambiente encerrado com sucesso.", "Aviso")
    EndIf
Return

Static Function fTesteSimples()
    Local cPara    := "otavio@tecsistemconsultoria.com.br"
    Local cAssunto := "Teste de Envio Protheus"
    Local cCorpo   := "Se recebeu isto, o SMTP do Protheus esta a funcionar!"
    Local cArquivo := ""
    Local lRet     := .F.

    MsgInfo("Iniciando o disparo do e-mail simples...", "Debug")
    lRet := xEnvMail(cArquivo,cPara, cAssunto, cCorpo)

    If lRet
        MsgInfo("SUCESSO: E-mail simples enviado!", "Fim")
    Else
        MsgInfo("FALHA: Verifique o console/log.", "Fim")
    EndIf
Return

Static Function fChamaRotina(cRotina)
    Local cArqLocal    :=  GetMV("XX_XARQUI",.F.,"\spool\")
    Local cNomeArquivo := "Relatorio_" + cRotina + "_" + dToS(Date()) + ".xml"
    
    MsgInfo("A iniciar a rotina " + cRotina + "... Aguarde o processamento.", "Processando")
    
    Do Case
        Case cRotina == "CVFATR04"
            U_CVFATR04()
            cNomeArquivo := "Faturamento_" + dToS(Date()) + ".xml"
        Case cRotina == "CVFATR05"
            U_CVFATR05()
			cNomeArquivo := "PVsAtrasados_" + dToS(Date()) + ".xml"
        Case cRotina == "CVFATR06"
            U_CVFATR06()
            cNomeArquivo := "POs_Embarques_" + dToS(Date()) + ".xml"
        Case cRotina == "CVFATR07"
            U_CVFATR07()
            cNomeArquivo := "Licencas_A_Vencer_" + dToS(Date()) + ".xml"
        Case cRotina == "CVFATR08"
            U_CVFATR08()
            cNomeArquivo := "Licencas_Vencidas_" + dToS(Date()) + ".xml"
    EndCase
    
    If File(cNomeArquivo)
        If CpyS2T(cNomeArquivo, cArqLocal, .T.) 
            MsgInfo("Planilha gerada com sucesso! A abrir o ficheiro...", "Sucesso")
            ShellExecute("open", cArqLocal + cNomeArquivo, "", "", 1)
        Else
            MsgAlert("Falha ao transferir o arquivo para C:\temp.", "Erro")
        EndIf
    EndIf
    
    MsgInfo("Rotina " + cRotina + " finalizada!", "Fim")
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
