#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'TopConn.ch'

/*/{Protheus.doc} CVFATR04
Relatório Diário de PVs para Faturar
Autor  : Nicolas B. Fernandes
Descrição: Gera planilha Excel com 3 abas (Prontos para Faturar / Prontos para Faturar / Ainda sem liberação)
           e envia por e-mail. Projetado para rodar como JOB noturno.

Filtros:
  Sem Bloqueios : C5_TIPO='N', F4_ESTOQUE='S',C9_NFISCAL = ''  
                  C9_BLEST='' E todos os outros bloqueios = ''
  Com Bloqueios : C5_TIPO='N', F4_ESTOQUE='S', C9_NFISCAL = '' 
                  C9_BLEST='' E pelo menos um outro bloqueio <> ''
  Carteira(SZV) : ZV_DTFAT = dDatabase+1
/*/
User Function CVFATR04()
    Local aEmails    := {}
    Local cTitulo    := ""
    Local cCorpo     := ""
    Local cPath      := ""
    Local cData      := ""
    Local cHora      := ""
    Local cDtHora    := ""
    Local cNomeArq   := ""
    Local nVlrPronto := 0
    Local nVlrBloq   := 0
    Local nVlrCart   := 0
    Local cTabela    := ""
    Local lAbreEnv   := .F.
    Local nX         := 0

    // Preparação do Ambiente: suporta JOB (sem SX2 ativo) ou execução via Menu
    If IsBlind() .or. Select("SX2") <= 0
		RPCSetEnv("01", "01")
        lAbreEnv := .T.
	Endif

    aEmails  := {}
    cTitulo    := "Relatorio Diario de PVs para Faturar - Protheus"
    cCorpo     := ""
    cPath      := GetMV("XX_XARQUI",.F.,"\spool\")
    cData      := StrTran(DToS(Date()),"/","")
    cHora      := StrTran(Time(),":","")
    cDtHora    := AllTrim(cData+"_"+cHora)
    cNomeArq   := "PVs para Faturar_"+cDtHora+".xml"
    nVlrPronto := 0
    nVlrBloq   := 0
    nVlrCart   := 0
    cTabela    := "XG"
    nX         := 0

    aEmails := BuscaEmail(cTabela)

    If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf

    // Gera o Excel com as 3 abas — totalizadores retornados por referência
    GerarPlanilha(cPath + cNomeArq, @nVlrPronto, @nVlrBloq, @nVlrCart)

    // Montagem do corpo HTML do e-mail
    cCorpo := '<html><body style="font-family: Calibri, sans-serif;">'
    cCorpo += '<h2>Resumo de PVs para Faturar</h2>'
    cCorpo += '<p>Seguem os valores consolidados para faturamento em <b>' + dToC(Date()) + '</b>:</p>'
    cCorpo += '<ul>'
    cCorpo += '  <li><b>R$ ' + Transform(nVlrPronto, "@E 999,999,999.92") + '</b> &ndash; sem bloqueios (pronto para faturar)</li>'
    cCorpo += '  <li><b>R$ ' + Transform(nVlrBloq,   "@E 999,999,999.92") + '</b> &ndash; com bloqueio (mas com estoque)</li>'
    cCorpo += '  <li><b>TOTAL R$ ' + Transform(nVlrPronto + nVlrBloq, "@E 999,999,999.92") + '</b></li>'
    cCorpo += '</ul>'
    cCorpo += '<p><i>Anexo: abas Prontos para Faturar, Com bloqueios e com estoque e Ainda sem liberação.</i></p>'
    cCorpo += '<br><hr><font size="1">Gerado automaticamente pelo Protheus - ' + Time() + '</font>'
    cCorpo += '</body></html>'

    // Envia o e-mail com o arquivo em anexo
    For nX := 1 To Len(aEmails)    
        xEnvMail(cPath + cNomeArq, aEmails[nX], cTitulo, cCorpo)
    Next nX

    // Encerra o ambiente somente se foi esta rotina que o abriu
    If lAbreEnv
        RPCClearEnv()
    EndIf

Return

//--------------------------------------------------------------------
// GerarPlanilha
// Monta o arquivo Excel (.xml) com 3 abas.
// Totalizadores retornados por referência (@).
//--------------------------------------------------------------------
Static Function GerarPlanilha(cFullNome, nVlrPronto, nVlrBloq, nVlrCart)
    Local oExcel     := FWMSEXCEL():New()
    Local cQuery     := ""
    Local cAlias     := ""
    //Local dAmanha    := dDatabase + 1
    Local nTotalItem := 0
    Local nX         := 0
    Local nFormato   := 0
    Local lBloqueado := .F.
    Local aLinha     := {}
    Local aHeader    := {}
    Local aCampos    := {} 
    Local aTipos     := {} 
    Local aTotPronto := {} 
    Local aTotBloq   := {}
    Local aTotCart   := {}
    Local cStatusC9  := ""

    DbSelectArea("SX3")
    SX3->(DbSetOrder(1)) 
    If SX3->(DbSeek("SC9"))
	
        While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SC9"
		
            If AllTrim(SX3->X3_BROWSE) == "S"
			
                aAdd(aCampos, AllTrim(SX3->X3_CAMPO)) 
                aAdd(aHeader, AllTrim(SX3->X3_TITULO))
                aAdd(aTipos,  AllTrim(SX3->X3_TIPO))
				
            EndIf
			
            SX3->(DbSkip())
			
        EndDo
		
    EndIf
    //================================================================
    // QUERY PRINCIPAL – SC9 (Pedidos Liberados)
    //================================================================
    cQuery := " SELECT "
    cQuery += "   SC9.R_E_C_N_O_ AS SC9REC, " // <-- Adicionado para o DbGoto funcionar na UDF
    cQuery += "   SC9.C9_FILIAL, "
    cQuery += "   SC9.C9_PEDIDO, "
    cQuery += "   SC9.C9_ITEM, "
    cQuery += "   SC9.C9_CLIENTE, "
    cQuery += "   SC9.C9_LOJA, "
    cQuery += "   SA1.A1_NOME, "
    cQuery += "   SC5.C5_CONDPAG, "
    
    // --- Campos Virtuais que agora vêm de joins reais ---
    cQuery += "   SC5.C5_TIPO, "
    cQuery += "   SC5.C5_TRANSP, "
    cQuery += "   SA4.A4_NOME AS NOMETRAN, "
    
    cQuery += "   SC9.C9_PRODUTO, "
    cQuery += "   SC9.C9_QTDLIB, "        // Quantidade Liberada         (N,12,2)
    cQuery += "   SC9.C9_PRCVEN, "        // Preço de Venda              (N,14,2)
    cQuery += "   SC9.C9_NFISCAL, "       // Nota Fiscal                 (C,9)
    cQuery += "   SC9.C9_SERIENF, "       // Série da NF                 (C,3)
    cQuery += "   SC9.C9_DATALIB, "       // Data da Liberação           (D,8)  -- STOD() no loop
    cQuery += "   SC9.C9_SEQUEN, "        // Sequência                   (C,2)
    cQuery += "   SC9.C9_CRVENT, "        // Data p/Faturar (custom)     (C,8)  -- STOD() no loop
    cQuery += "   SC9.C9_GRUPO, "         // Grupo de Estoque            (C,4)
    cQuery += "   SC9.C9_AGREG, "         // Agregador de Liberação      (C,4)  ** nativo
    cQuery += "   SC9.C9_ITEMREM, "       // Item do Remito              (C,2)
    cQuery += "   SC9.C9_REMITO, "        // Nº do Remito                (C,9)
    cQuery += "   SC9.C9_LOCAL, "         // Armazém                     (C,2)
    cQuery += "   SC9.C9_LOTECTL, "       // Lote (rastreabilidade)      (C,10) ** nativo
    cQuery += "   SC9.C9_CARGA, "         // Nº da Carga                 (C,6)
    cQuery += "   SC9.C9_SEQCAR, "        // Sequência da Carga          (C,2)
    cQuery += "   SC9.C9_SEQENT, "        // Sequência de Entrega        (C,6)
    cQuery += "   SC9.C9_SERVIC, "        // Tipo de Serviço WMS         (C,3)
    cQuery += "   SC9.C9_ENDPAD, "        // Endereço Envio Padrão       (C,15)
    cQuery += "   SC9.C9_TPESTR, "        // Estrutura Física            (C,6)  ** nativo
    cQuery += "   SC9.C9_QTDLIB2, "       // Qt Liberada 2ª UM           (N,12,2)
    cQuery += "   SC9.C9_RETOPER, "       // Retém PIS/COFINS            (C,1)
    cQuery += "   SC9.C9_TRT, "           // Sequência do Empenho        (C,3)  ** nativo
    cQuery += "   SC6.C6_ENTREG, "        // Data de Entrega (SC6)       (D,8)  -- STOD() no loop
    cQuery += "   SC9.C9_DATENT , "       // Data de Entrega (SC9)       (D,8)  -- STOD() no loop
    // --- Bloqueios nativos ---
    cQuery += "   SC9.C9_BLCRED, "        // Bloqueio de Crédito         (C,2)
    cQuery += "   SC9.C9_BLEST, "         // Bloqueio de Estoque         (C,2)
    cQuery += "   SC9.C9_BLWMS, "         // Bloqueio WMS                (C,2)
    cQuery += "   SC9.C9_BLINF, "         // Informação de Bloqueio      (C,30) ** nativo
    cQuery += "   SC9.C9_BLTMS, "         // Bloqueio TMS                (C,2)
    cQuery += "   SC9.C9_BLOQUEI, "       // Bloqueio do pedido          (C,2)
    // --- Bloqueios customizados do cliente ---
    cQuery += "   SC9.C9_BLQPAG, "
    cQuery += "   SC9.C9_BLQFRT, "
    cQuery += "   SC9.C9_BLQTRAN, "
    cQuery += "   SC9.C9_BLQDESC, "
    cQuery += "   SC9.C9_BLQDTV, "
    cQuery += "   SC9.C9_XBLPVTO, "
    cQuery += "   SC9.C9_XBLQRC "
    cQuery += " FROM "  + RetSqlName("SC9") + " SC9 "
    cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
    cQuery += "         ON SC5.C5_FILIAL  = SC9.C9_FILIAL "
    cQuery += "        AND SC5.C5_NUM     = SC9.C9_PEDIDO "
    cQuery += "        AND SC5.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
    cQuery += "         ON SC6.C6_FILIAL  = SC9.C9_FILIAL "
    cQuery += "        AND SC6.C6_NUM     = SC9.C9_PEDIDO "
    cQuery += "        AND SC6.C6_ITEM    = SC9.C9_ITEM "
    cQuery += "        AND SC6.C6_PRODUTO = SC9.C9_PRODUTO "
    cQuery += "        AND SC6.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
    cQuery += "         ON SF4.F4_CODIGO  = SC6.C6_TES "
    cQuery += "        AND SF4.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT  JOIN " + RetSqlName("SA1") + " SA1 "
    cQuery += "         ON SA1.A1_COD     = SC9.C9_CLIENTE "
    cQuery += "        AND SA1.A1_LOJA    = SC9.C9_LOJA "
    cQuery += "        AND SA1.D_E_L_E_T_ = ' ' "
    
    // <-- Adicionado JOIN com SA4 para pegar o nome da Transportadora
    cQuery += " LEFT  JOIN " + RetSqlName("SA4") + " SA4 "
    cQuery += "         ON SA4.A4_COD     = SC5.C5_TRANSP "
    cQuery += "        AND SA4.D_E_L_E_T_ = ' ' "
    
    cQuery += " WHERE SC9.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SC5.C5_TIPO    = 'N' "                        // Pedido tipo Normal
    cQuery += "   AND SF4.F4_ESTOQUE = 'S' "                        // TES que movimenta estoque
    cQuery += "   AND SC9.C9_NFISCAL = '' "                         // Nota Pendente
    cQuery += "   AND RTRIM(SC9.C9_BLEST) = '' "                    // Sem bloqueio de estoque 
    cQuery += " ORDER BY SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_ITEM "

    cAlias := MPSysOpenQuery(cQuery)

    // Cria as duas abas antes de iniciar o loop
    oExcel:AddworkSheet("Prontos para Faturar")
    oExcel:AddTable("Prontos para Faturar", "Prontos")
    MontaColunasMATA460(oExcel, "Prontos para Faturar", "Prontos",aCampos,aHeader,aTipos)

    oExcel:AddworkSheet("Com bloqueios e com estoque")
    oExcel:AddTable("Com bloqueios e com estoque", "Bloqueados")
    MontaColunasMATA460(oExcel, "Com bloqueios e com estoque", "Bloqueados",aCampos,aHeader,aTipos)

    While !(cAlias)->(Eof())

        // C9_XVLTOT já é este cálculo, guardamos na variável
        nTotalItem := (cAlias)->C9_QTDLIB * (cAlias)->C9_PRCVEN
        lBloqueado := .F.

        If !Empty((cAlias)->C9_BLCRED)  .Or. ;
           !Empty((cAlias)->C9_BLWMS)   .Or. ;
           !Empty((cAlias)->C9_BLINF)   .Or. ;
           !Empty((cAlias)->C9_BLOQUEI) .Or. ;
           !Empty((cAlias)->C9_BLTMS)   .Or. ;
           !Empty((cAlias)->C9_BLQPAG)  .Or. ;
           !Empty((cAlias)->C9_BLQFRT)  .Or. ;
           !Empty((cAlias)->C9_BLQTRAN) .Or. ;
           !Empty((cAlias)->C9_BLQDESC) .Or. ;
           !Empty((cAlias)->C9_BLQDTV)  .Or. ;
           !Empty((cAlias)->C9_XBLPVTO) .Or. ;
           !Empty((cAlias)->C9_XBLQRC)
            lBloqueado := .T.
        EndIf


        // Monta a linha com as novas colunas
        aLinha     := {}

		For nX := 1 To Len(aCampos)

			aAdd(aLinha,(cAlias)->(FieldGet(FieldPos(aCampos[nX]))))

            If aTipos[nX] == "D" .AND. !Empty(aLinha[nX])     //4=Data 
                aLinha[nX] := SToD(aLinha[nX])
            EndIf
						
		Next nX

        // --- C9_XSTATUS: Posiciona fisicamente a SC9 para a sua UDF funcionar ---
        //SC9->(DbGoto( (cAlias)->SC9REC ))
        cStatusC9 := U_LIBCRE01(aLINHA[2], aLINHA[3]) // C9_PEDIDO, C9_ITEM
        
        aAdd(aLinha,(cAlias)->A1_NOME)                  // Nome Cliente
        aAdd(aLinha,(cAlias)->C5_CONDPAG)               // Cond. Pgto
        aAdd(aLinha,(cAlias)->C5_TIPO)                  // Tipo Pedido (C9_XTIPO)
        aAdd(aLinha,(cAlias)->C5_TRANSP)                // Transportadora (C9_XTRANSP)
        aAdd(aLinha,(cAlias)->NOMETRAN)                 // Nome Transp (C9_XNTRANS)
        aAdd(aLinha,cStatusC9)                          // Status (C9_XSTATUS)
        aAdd(aLinha,nTotalItem)                         // R$ Total / C9_XVLTOT
        aAdd(aLinha,STOD((cAlias)->C6_ENTREG))          // Dt Entrega (da SC6)

        If lBloqueado
            oExcel:AddRow("Com bloqueios e com estoque", "Bloqueados", aLinha)
            nVlrBloq += nTotalItem
        Else
            oExcel:AddRow("Prontos para Faturar", "Prontos", aLinha)
            nVlrPronto += nTotalItem
        EndIf

        (cAlias)->(DbSkip())
    End  // While SC9
    (cAlias)->(DbCloseArea())

    // Linhas de TOTAL — Refatoradas para limpar o código e não ter erro de array
    aTotPronto := Array(Len(aLinha))
    AFill(aTotPronto, "")
    aTotPronto[1]  := "TOTAL"
    aTotPronto[Len(aLinha)-1] := nVlrPronto 

    aTotBloq := Array(Len(aLinha))
    AFill(aTotBloq, "")
    aTotBloq[1]  := "TOTAL"
    aTotBloq[Len(aLinha)-1] := nVlrBloq

    oExcel:AddRow("Prontos para Faturar", "Prontos",    aTotPronto)
    oExcel:AddRow("Com bloqueios e com estoque", "Bloqueados", aTotBloq)

    //================================================================
    // ABA 3 – Ainda sem liberação (SZV)
    // Filtro: ZV_DTFAT = dDatabase + 1
    //================================================================
    // Limpando as estruturas para as reutilizar na nova consulta
    aCampos:= {}
    aHeader:= {}
    aLinha := {}
    aTipos := {}    

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

    oExcel:AddworkSheet("Ainda sem liberação")
    oExcel:AddTable("Ainda sem liberação", "SZV")

    For nX := 1 To Len(aCampos)
    
        If aTipos[nX] == "D"     //4=Data  
            nFormato := 4          
        ElseIf aTipos[nX] == "N" //2=Número 
            nFormato := 2
        Else                     //1=Caracter
            nFormato := 1
        EndIf

		oExcel:AddColumn("Ainda sem liberação", "SZV", aHeader[nX],2, nFormato)   
						
	Next nX        
    
    cQuery := " SELECT * "
    cQuery += " FROM " + RetSqlName("SZV") + " SZV "
    cQuery += " WHERE SZV.D_E_L_E_T_ = ' ' "

    // Regra: Somente o que NÃO está na SC9 
    cQuery += " AND NOT EXISTS ( "
    cQuery += "     SELECT 1 "
    cQuery += "     FROM " + RetSqlName("SC9") + " SC9 "
    cQuery += "     WHERE SC9.C9_PEDIDO = SZV.ZV_PEDIDO "
    cQuery += "       AND SC9.C9_ITEM   = SZV.ZV_ITEM "
    cQuery += "       AND SC9.C9_NFISCAL = ' ' "
    cQuery += "       AND SC9.D_E_L_E_T_ = ' ' "
    cQuery += " ) "

    cAlias := MPSysOpenQuery(cQuery)
  
    While !(cAlias)->(Eof())
        aLinha     := {}

        For nX := 1 To Len(aCampos)

            aAdd(aLinha,(cAlias)->(FieldGet(FieldPos(aCampos[nX]))))

            If aTipos[nX] == "D" .AND. !Empty(aLinha[nX])     //4=Data 
                aLinha[nX] := SToD(aLinha[nX])
            EndIf
                            
        Next nX
        
        oExcel:AddRow("Ainda sem liberação", "SZV",aLinha)
        nVlrCart += (cAlias)->ZV_TOTAL
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    aTotCart := Array(Len(aLinha)) 
    AFill(aTotCart, "")
    aTotCart[1]  := "TOTAL"
    aTotCart[17] := nVlrCart

    oExcel:AddRow("Ainda sem liberação", "SZV", aTotCart)

    oExcel:Activate()
    oExcel:GetXMLFile(cFullNome)
    FreeObj(oExcel) 

Return

//--------------------------------------------------------------------
// MontaColunasMATA460
// Cria as 63 colunas que espelham o browse da MATA460A.
// Tipos: 1=Caracter  2=Número  3=Data
//--------------------------------------------------------------------
Static Function MontaColunasMATA460(oExcel, cAba, cTabela, aCampos, aHeader,aTipos)
    Local nX := 0
    Local nFormato := 0
    
    // --- Identificação ---

    For nX := 1 To Len(aCampos)

        If aTipos[nX] == "D"     //4=Data  
            nFormato := 4          
        ElseIf aTipos[nX] == "N" //2=Número 
            nFormato := 2
        Else                     //1=Caracter
            nFormato := 1
        EndIf

		oExcel:AddColumn(cAba, cTabela, aHeader[nX],2, nFormato)   
						
	Next nX
    
    oExcel:AddColumn(cAba, cTabela, "Nome Cliente", 1, 1)   // Nome Cliente
    oExcel:AddColumn(cAba, cTabela, "Cond. Pgto",   2, 1)   // Cond. Pgto
    oExcel:AddColumn(cAba, cTabela, "Tipo Pedido",  2, 1)   // (C9_XTIPO)
    oExcel:AddColumn(cAba, cTabela, "Transp.",      2, 1)   // (C9_XTRANSP)
    oExcel:AddColumn(cAba, cTabela, "Nome Transp.", 2, 1)   // (C9_XNTRANS)
    oExcel:AddColumn(cAba, cTabela, "Status",       2, 1)   // (C9_XSTATUS)
    oExcel:AddColumn(cAba, cTabela, "Vlr Total",    2, 2)   // (C9_XVLTOT)
    oExcel:AddColumn(cAba, cTabela, "Dt Entrega",   2, 3)  // C6_ENTREG (da SC6)

Return


/*=================================================================
   xEnvMail – Envio de e-mail via TMailManager (SMTP)
==================================================================*/
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
