#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "FWBROWSE.CH"

/*=================================================================
Autor: Nicolas B. Fernandes
Data: 05/01/2026
Alterado em: 03/03/2026
Uso: Calibre
Fun??o: CVTELACC01
Info: Tela Principal - Dashboard de Custos (CC)
*==================================================================*/
User Function CVTELACC01()
    Local aParam   := {}
    Local cUserLog := AllTrim(RetCodUsr())
    Local cIdsAutor:= GetNewPar("MV_XIDCC", "")
    Local cIdsRGer := GetNewPar("MV_XRGERAL", "")
    Local cQuery   := ""
    Local cAlias   := GetNextAlias()
    Local lTemCC   := .F.

    /*-----------------------------------------------------------------
      Regra 3:
      Se o usuario NAO for gestor de nenhum CC (CTT_XGESTO)
      E NAO estiver no parametro global MV_XIDCC,
      entao nao pode nem abrir o Dialog principal.
    ------------------------------------------------------------------*/

    // Verifica se usuario e gestor de pelo menos um centro de custo
    cQuery := " SELECT CTT_CUSTO FROM " + RetSqlName("CTT")
    cQuery += " WHERE CTT_XGESTO = '" + cUserLog + "' AND D_E_L_E_T_ = ' ' "

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
    lTemCC := !( (cAlias)->(EOF()) )
    (cAlias)->(DbCloseArea())

    // Se nao for gestor de nenhum CC e nao estiver em nenhum parametro global, barra o acesso
    If !lTemCC .And. ;
       ( ( Empty(AllTrim(cIdsAutor)) .Or. !HasUsr(cIdsAutor, cUserLog) ) .And. ;
         ( Empty(AllTrim(cIdsRGer))  .Or. !HasUsr(cIdsRGer,  cUserLog) ) )
        MsgStop("Voce precisa ser ao menos gestor de um centro de custo ou estar no parametro de permissao global.","Acesso Negado")
        Return
    EndIf

    // Dialog abre com tudo (abas, layout); params no cabecalho; ao Confirmar = refresh (sem fechar)
    MontaTela(@aParam)
Return


/*=================================================================
Funcao Auxiliar: DadosToColsRG
Info: Converte array interno para formato aCols da MsNewGetDados
==================================================================*/
Static Function DadosToColsRG(aDados)
    Local aCols := {}
    Local nX    := 0

    For nX := 1 To Len(aDados)
        aAdd(aCols, { ;
            PadR(cValToChar(aDados[nX][1]), 15), ;
            PadR(cValToChar(aDados[nX][2]), 40), ;
            aDados[nX][3], ;
            aDados[nX][4], ;
            aDados[nX][5], ;
            aDados[nX][6], ;
            aDados[nX][7], ;
            aDados[nX][8], ;
            PadR(cValToChar(aDados[nX][9]), 40), ;
            .F. })
    Next

Return aCols

/*=================================================================
Funcao Auxiliar: BuscaMsRG
Info: Filtra a MsNewGetDados do Resumo Geral
==================================================================*/
Static Function BuscaMsRG(oPanelGrid, oBtnBusca, oGetBusca, oMsGrid, ;
                          aDadosFull, aDadosShow, cBuscaCC, aHeadRG)
    Local aColsNovo := {}

    oPanelGrid:SetFocus()
    oBtnBusca:SetFocus()

    FiltReGe(oGetBusca, Nil, aDadosFull, @aDadosShow, cBuscaCC)

    aColsNovo := DadosToColsRG(aDadosShow)
    If Len(aColsNovo) == 0
        aAdd(aColsNovo, {Space(15), Space(40), 0, 0, 0, 0, 0, 0, Space(40), .F.})
    EndIf

    oMsGrid:aCols := aColsNovo
    oMsGrid:oBrowse:Refresh()

Return

/*=================================================================
Funcao Auxiliar: LimpaMsRG
Info: Limpa filtro da MsNewGetDados do Resumo Geral
==================================================================*/
Static Function LimpaMsRG(oGetBusca, oMsGrid, ;
                          aDadosFull, aDadosShow, cBuscaCC, aHeadRG)
    Local aColsNovo := {}

    cBuscaCC := Space(20)
    oGetBusca:SetText(Space(20))

    FiltReGe(oGetBusca, Nil, aDadosFull, @aDadosShow, "")

    aColsNovo := DadosToColsRG(aDadosShow)
    If Len(aColsNovo) == 0
        aAdd(aColsNovo, {Space(15), Space(40), 0, 0, 0, 0, 0, 0, Space(40), .F.})
    EndIf

    oMsGrid:aCols := aColsNovo
    oMsGrid:oBrowse:Refresh()

Return

/*=================================================================
Funcao: ValidaSeguranca
Info (regras 1 e 2):
  1) Se usuario estiver no MV_XIDCC -> acesso liberado a qualquer CC.
  2) Se nao estiver no MV_XIDCC, so pode visualizar o CC do qual e gestor
     (CTT_XGESTO == usuario). Caso contrario, exibe mensagem de acesso negado
     para aquele centro de custo.
*==================================================================*/
Static Function ValidaSeguranca(aParam)
    Local cCCusto   := aParam[3]
    Local cUserLog  := AllTrim(RetCodUsr())
    Local cGestorCC := ""
    Local cQuery    := ""
    Local cAlias    := GetNextAlias()
    Local cIdsAutor := GetNewPar("MV_XIDCC", "")
    Local cIdsRGer  := GetNewPar("MV_XRGERAL", "")

    // Regra 1: se usuario estiver no parametro global, pode ver qualquer CC
    If !Empty(AllTrim(cIdsAutor)) .And. HasUsr(cIdsAutor, cUserLog)
        Return .T.
    EndIf

    // Regra 1b: se usuario estiver no parametro MV_XRGERAL, pode ver qualquer CC
    If !Empty(AllTrim(cIdsRGer)) .And. HasUsr(cIdsRGer, cUserLog)
        Return .T.
    EndIf

    // Busca o Gestor do CC (CTT_XGESTO) para a regra 2
    cQuery := " SELECT CTT_XGESTO FROM " + RetSqlName("CTT")
    cQuery += " WHERE CTT_CUSTO = '" + cCCusto + "' AND D_E_L_E_T_ = ' ' "
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
    If !(cAlias)->(EOF())
        cGestorCC := AllTrim((cAlias)->CTT_XGESTO)
    EndIf
    (cAlias)->(DbCloseArea())

    // Regra 2: se nao estiver no parametro global, so pode ver o CC do qual e gestor
    If cUserLog == cGestorCC
        Return .T.
    EndIf

    MsgStop("Voce nao possui acesso para visualizar este centro de custo.","Acesso Negado")

Return .F.

/*=================================================================
Fun??o: MontaParametros
Info: Tela de configura??o dos filtros
*==================================================================*/
Static Function MontaParametros(aParam)
    Local lRet    := .F.
    Local oDlg, oPanel
    Local dDataDe := FirstDate(Date())
    Local dDataAte := Date()
    Local cCCusto := Iif(Type("CTT->CTT_CUSTO") == "C", CTT->CTT_CUSTO, Space(TamSX3("CTT_CUSTO")[1]))
    Local oDataDe, oDataAte, oCCusto
    Local oBtn1, oBtn2

    DEFINE MSDIALOG oDlg TITLE "Filtros - Consulta Custos" FROM 0,0 TO 200,400 PIXEL

    oPanel := TPanel():New(0, 0, "", oDlg,,,,,, 200, 100, .F., .F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    @ 015,010 SAY "Data De:"      SIZE 040,008 OF oPanel PIXEL
    @ 013,050 MSGET oDataDe  VAR dDataDe  SIZE 060,010 OF oPanel PIXEL VALID !Empty(dDataDe)

    @ 030,010 SAY "Data At?:"     SIZE 040,008 OF oPanel PIXEL
    @ 028,050 MSGET oDataAte VAR dDataAte SIZE 060,010 OF oPanel PIXEL VALID !Empty(dDataAte) .And. dDataAte >= dDataDe

    @ 045,010 SAY "Centro Custo:" SIZE 040,008 OF oPanel PIXEL
    @ 043,050 MSGET oCCusto  VAR cCCusto  SIZE 060,010 OF oPanel PIXEL F3 "CTT" VALID !Empty(cCCusto)

    @ 070,080 BUTTON oBtn1 PROMPT "Confirmar" SIZE 040,012 OF oPanel PIXEL ACTION (lRet := .T., oDlg:End())
    @ 070,125 BUTTON oBtn2 PROMPT "Cancelar"  SIZE 040,012 OF oPanel PIXEL ACTION (lRet := .F., oDlg:End())

    ACTIVATE MSDIALOG oDlg CENTERED

    If lRet
        // Fernando Cerqueira - 05/03/2026
        // Motivo: O VALID do campo Centro de Custo so executa ao sair do campo. Ao clicar em Confirmar
        // sem preencher o Centro de Custo, o programa permitia abrir a tela com o filtro vazio.
        // Validacao apos o fechamento do dialogo para garantir que o Centro de Custo seja sempre obrigatorio.
        If Empty(AllTrim(cCCusto))
            MsgStop("Informe o Centro de Custo para continuar.", "Aten??o")
            Return MontaParametros(@aParam)
        EndIf
        If Year(dDataDe) <> Year(dDataAte)
            MsgAlert("A Data Inicial e Final devem pertencer ao mesmo ano.", "Valida??o")
            Return MontaParametros(@aParam)
        EndIf
        aParam := {dDataDe, dDataAte, AllTrim(cCCusto)}
    EndIf
Return lRet

/*=================================================================
Funcao: ExecutaConfirmar
Info: Valida params, recarrega dados no folder (refresh) sem fechar o dialog.
      Parametros mantidos nos campos para nova consulta.
*==================================================================*/
Static Function ExecutaConfirmar(oDlg,oFolder,aParam,aTitulos,oPanelFolderArea,;
                                 oDataDe,oDataAte,oCCusto,;
                                 dDataDe,dDataAte,cCCusto,;
                                 nTotSC7Per,nTotSD3Per,nTotPOPer,;
                                 nTotSC7Acu,nTotSD3Acu,nTotPOAcu)

    Local cUserLog       := AllTrim(RetCodUsr())
    Local cUsersResGeral := GetNewPar("MV_XRGERAL","")
    Local lResumoGeral   := (!Empty(AllTrim(cUsersResGeral)) .And. HasUsr(cUsersResGeral, cUserLog))
    Local nIdxResumo     := 0
    Local nIdxResGeral   := 0
    Local nIdxPedidos    := 0
    Local nIdxPO         := 0
    Local nIdxMov        := 0
    Local nPaginaAtual   := 1

    If lResumoGeral
        nIdxResGeral := 1
        nIdxResumo   := 2
        nIdxPedidos  := 3
        nIdxPO       := 4
        nIdxMov      := 5
    Else
        nIdxResumo   := 1
        nIdxPedidos  := 2
        nIdxPO       := 3
        nIdxMov      := 4
    EndIf

    /* Atualiza parametros a partir das variaveis ligadas aos GETs */
    aParam := {dDataDe,dDataAte,cCCusto}

    // Data De e Data Ate devem sempre pertencer ao mesmo ano
    If Year(dDataDe) <> Year(dDataAte)
        MsgStop("O intervalo de datas precisa ser dentro de um ano", "Atencao")
        Return
    EndIf

    /*----------------------------------------
      Valida seguranca para o centro de custo informado
      (regras 1 e 2 em ValidaSeguranca)
    -----------------------------------------*/

    If !ValidaSeguranca(aParam)
        Return
    EndIf

    /* Zera totais */

    nTotSC7Per := 0
    nTotSD3Per := 0
    nTotPOPer  := 0
    nTotSC7Acu := 0
    nTotSD3Acu := 0
    nTotPOAcu  := 0

    /*----------------------------------------
      LIMPA FOLDER ANTIGO (evita duplicacao)
      e guarda a aba atualmente selecionada
    -----------------------------------------*/

    If ValType(oFolder) == "O"
        nPaginaAtual := Max(1, oFolder:nOption)
        oFolder:End()
        FreeObj(oFolder)
    EndIf

    /*----------------------------------------
      RECRIA FOLDER
    -----------------------------------------*/

    oFolder := TFolder():New(0,0,aTitulos,{},oPanelFolderArea)
    oFolder:Align := CONTROL_ALIGN_ALLCLIENT

    /*----------------------------------------
      RECRIA ABAS
      IMPORTANTE: a ordem de montagem NAO precisa
      seguir a ordem visual das abas. Primeiro
      montamos Pedidos/PO/Mov (que calculam os
      totais), depois o Resumo (que usa esses
      totais) e por ultimo o Resumo Geral
      (que NAO depende dos filtros nem dos
      totais calculados).
    -----------------------------------------*/

    // 1) Abas que alimentam os totais
    MontaAbaPedidos(oFolder:aDialogs[nIdxPedidos],aParam,@nTotSC7Per,@nTotSC7Acu)
    MontaAbaPO(oFolder:aDialogs[nIdxPO],aParam,@nTotPOPer,@nTotPOAcu)
    MontaAbaMovimentacoes(oFolder:aDialogs[nIdxMov],aParam,@nTotSD3Per,@nTotSD3Acu)

    // 2) Aba Resumo (usa os totais calculados acima)
    MontaAbaResumo(oFolder:aDialogs[nIdxResumo],aParam,;
                   nTotSC7Per,nTotSD3Per,nTotPOPer,;
                   nTotSC7Acu,nTotSD3Acu,nTotPOAcu)

    // 3) Aba Resumo Geral (independente dos filtros)
    If lResumoGeral .And. nIdxResGeral > 0
        MontaResGe(oFolder:aDialogs[nIdxResGeral],aParam)
    EndIf

    /*----------------------------------------
      Restaura a aba selecionada antes do
      Confirmar, para nao forcar o usuario
      para a aba "Resumo Geral"
    -----------------------------------------*/

    If ValType(oFolder) == "O"
        If nPaginaAtual >= 1 .And. nPaginaAtual <= Len(oFolder:aDialogs)
            oFolder:nOption := nPaginaAtual
        EndIf
    EndIf

Return
/*=================================================================
Funcao: MontaTela
Info: Dialog abre com layout completo (4 abas) e campos de params no cabecalho.
      Valores zerados ate o usuario informar filtro e clicar Confirmar.
      Ao Confirmar: refresh dos dados (params mantidos para nova consulta).
*==================================================================*/
Static Function MontaTela(aParam)

    Local oDlg
    Local oFolder
    Local oPanelHead
    Local oPanelFolderArea

    Local aTitulos := {}

    Local cUserLog       := AllTrim(RetCodUsr())
    Local cUsersResGeral := GetNewPar("MV_XRGERAL","")
    Local lResumoGeral   := (!Empty(AllTrim(cUsersResGeral)) .And. HasUsr(cUsersResGeral, cUserLog))

    Local nIdxResumo     := 0
    Local nIdxResGeral   := 0
    Local nIdxPedidos    := 0
    Local nIdxPO         := 0
    Local nIdxMov        := 0

    Local dDataDe  := FirstDate(Date())
    Local dDataAte := Date()
    Local cCCusto  := Iif(Type("CTT->CTT_CUSTO") == "C", CTT->CTT_CUSTO, Space(TamSX3("CTT_CUSTO")[1]))

    Local oDataDe
    Local oDataAte
    Local oCCusto

    Local nTotSC7Per := 0
    Local nTotSD3Per := 0
    Local nTotPOPer  := 0
    Local nTotSC7Acu := 0
    Local nTotSD3Acu := 0
    Local nTotPOAcu  := 0

    If lResumoGeral
        aTitulos     := {"RESUMO GERAL","RESUMO","PEDIDOS DE COMPRA (PC)","PURCHASE ORDER (PO)","MOVIMENTOS (MOV)"}
        nIdxResGeral := 1
        nIdxResumo   := 2
        nIdxPedidos  := 3
        nIdxPO       := 4
        nIdxMov      := 5
    Else
        aTitulos     := {"RESUMO","PEDIDOS DE COMPRA (PC)","PURCHASE ORDER (PO)","MOVIMENTOS (MOV)"}
        nIdxResumo   := 1
        nIdxPedidos  := 2
        nIdxPO       := 3
        nIdxMov      := 4
    EndIf

    //If Len(aParam) >= 3
    If ValType(aParam) == "A" .And. Len(aParam) >= 3
        dDataDe  := aParam[1]
        dDataAte := aParam[2]
        cCCusto  := aParam[3]
    Else
        aParam := {dDataDe,dDataAte,""}
    EndIf

    DEFINE MSDIALOG oDlg ;
        TITLE "Painel de Custos" + Iif(!Empty(aParam[3])," - "+aParam[3],"") ;
        FROM 0,0 TO 800,1200 PIXEL

   /*-----------------------------------------
  PAINEL HEADER (PARAMETROS)
------------------------------------------*/

// Header um pouco mais baixo para reduzir o espaco em branco entre filtros e abas
oPanelHead := TPanel():New(0,0,"",oDlg,,,,,,800,45,.F.,.T.)
oPanelHead:Align := CONTROL_ALIGN_TOP

@ 008,010 SAY "Data De:" SIZE 40,10 OF oPanelHead PIXEL
@ 005,055 MSGET oDataDe VAR dDataDe SIZE 65,12 OF oPanelHead PIXEL

@ 008,130 SAY "Data Ate:" SIZE 45,10 OF oPanelHead PIXEL
@ 005,178 MSGET oDataAte VAR dDataAte SIZE 65,12 OF oPanelHead PIXEL

@ 008,255 SAY "Centro Custo:" SIZE 60,10 OF oPanelHead PIXEL
@ 005,320 MSGET oCCusto VAR cCCusto SIZE 90,12 OF oPanelHead PIXEL F3 "CTT"

@ 002,430 BUTTON "Confirmar" ;
    SIZE 65,16 ;
    OF oPanelHead PIXEL ;
    ACTION ( ExecutaConfirmar(oDlg,@oFolder,@aParam,aTitulos,oPanelFolderArea,oDataDe,oDataAte,oCCusto,@dDataDe,@dDataAte,@cCCusto,@nTotSC7Per,@nTotSD3Per,@nTotPOPer,@nTotSC7Acu,@nTotSD3Acu,@nTotPOAcu) )

/*-----------------------------------------
  AREA DO FOLDER
-----------------------------------------*/

oPanelFolderArea := TPanel():New(0,0,"",oDlg)
oPanelFolderArea:Align := CONTROL_ALIGN_ALLCLIENT

oFolder := TFolder():New(0,0,aTitulos,{},oPanelFolderArea)
oFolder:Align := CONTROL_ALIGN_ALLCLIENT

// Fonte das abas: mesma fonte/tamanho dos titulos principais (ex.: "CENTRO DE CUSTO")
// Aumenta legibilidade das abas no topo
If ValType(oFolder:oFont) == "O"
    oFolder:oFont := TFont():New("Arial",,-14,.T.)
EndIf

    /*-----------------------------------------
      MONTAGEM DAS ABAS
      Ordem de montagem segue a mesma logica do
      ExecutaConfirmar: primeiro as abas que
      calculam totais, depois o Resumo (que usa
      esses totais) e por ultimo o Resumo Geral.
    -----------------------------------------*/

    // 1) Abas que alimentam os totais
    MontaAbaPedidos(oFolder:aDialogs[nIdxPedidos],aParam,@nTotSC7Per,@nTotSC7Acu)
    MontaAbaPO(oFolder:aDialogs[nIdxPO],aParam,@nTotPOPer,@nTotPOAcu)
    MontaAbaMovimentacoes(oFolder:aDialogs[nIdxMov],aParam,@nTotSD3Per,@nTotSD3Acu)

    // 2) Aba Resumo (usa os totais calculados acima)
    MontaAbaResumo(oFolder:aDialogs[nIdxResumo],aParam,;
                   nTotSC7Per,nTotSD3Per,nTotPOPer,;
                   nTotSC7Acu,nTotSD3Acu,nTotPOAcu)

    // 3) Aba Resumo Geral (independente dos filtros)
    If lResumoGeral .And. nIdxResGeral > 0
        MontaResGe(oFolder:aDialogs[nIdxResGeral],aParam)
    EndIf

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*=================================================================
Funcao: MontaResGe
Info: Aba "Resumo Geral" - consolida todos os centros de custo,
      exibindo um grid com um registro por CC e os mesmos blocos
      analiticos da aba "Resumo", porem somando todos os CCs.
      Visivel apenas para usuarios presentes no parametro MV_XRGERAL.
*==================================================================*/
Static Function MontaResGe(oPanel, aParam)

    Local cAliasCTT := GetNextAlias()
    Local cAliasRG  := GetNextAlias()
    Local cQuery    := ""
    Local aDadosCCFull := {}
    Local aDadosCCShow := {}

    Local nTotRealGeral  := 0
    Local nTotSaldoGeral := 0

    Local nAOPAntTot   := 0
    Local nAOPAtuTot   := 0
    Local nRealAcuTot  := 0
    Local nSaldoAcuTot := 0

    Local nSC7Tot      := 0
    Local nSD3Tot      := 0
    Local nPOTot       := 0

    Local dHoje        := Date()
    Local cAnoAnt      := cValToChar(Year(dHoje) - 1)
    Local cAnoAtu      := cValToChar(Year(dHoje))
    Local dDataDe      := CToD("01/01/" + cValToChar(Year(dHoje)))
    Local dDataAte     := dHoje

    Local oFontTit  := TFont():New("Arial",,-14,.T.)
    Local oFontSub  := TFont():New("Arial",,-11,.T.)
    Local oFontLbl  := TFont():New("Arial",,-10,.F.)
    Local oFontBold := TFont():New("Arial Black", , -11)

    Local oPanelTop, oPanelGrid, oPanelBottom
    Local oMsGrid   := Nil
    Local aHeadRG   := {}
    Local aColsRG   := {}

    Local cBuscaCC  := Space(20)
    Local oGetBusca := Nil
    Local oBtnBusca := Nil
    Local oBtnLimpa := Nil

    Local cCCusto, cDescCC, cGestor
    Local nAOPAnt, nAOPAtu
    Local nRealCC, nSaldoCC, nPercReal, nPercSaldo

    Local oSayTotReal, oSayTotSaldo

    Local oPanelAnalise, oPanelAcum, oPanelExec, oScrollExec, oPanelExecCont, oPanelChart
    Local oFWChart, aCorChart := {}
    Local nPercAting, nPercRest, nVarVal, nVarPer, nPercTotReal, nPctSaldoAcu

    // Cache (por dia) para evitar recomputar o Resumo Geral em todo Confirmar
    Static s_dCache := Ctod("")
    Static s_aCache := {}
    Static s_nTotReal := 0
    Static s_nTotSaldo := 0
    Static s_nAOPAntT := 0
    Static s_nAOPAtuT := 0
    Static s_nRealAcuT := 0
    Static s_nSC7T := 0
    Static s_nSD3T := 0
    Static s_nPOT := 0

    oPanelTop    := TPanel():New(0,0,"",oPanel,,,,,,oPanel:nClientWidth,40,.F.,.F.)
    oPanelTop:Align := CONTROL_ALIGN_TOP

    oPanelBottom := TPanel():New(0,0,"",oPanel)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM
    oPanelBottom:nHeight := 280

    oPanelGrid   := TPanel():New(0,0,"",oPanel)
    oPanelGrid:Align := CONTROL_ALIGN_ALLCLIENT

    @ 005,005 SAY "Pesquisar:" SIZE 060,012 OF oPanelGrid PIXEL FONT oFontSub
    @ 003,070 MSGET oGetBusca VAR cBuscaCC SIZE 140,012 OF oPanelGrid PIXEL

    @ 001,220 BUTTON oBtnBusca PROMPT "Buscar" SIZE 050,014 OF oPanelGrid PIXEL
    @ 001,275 BUTTON oBtnLimpa PROMPT "Limpar" SIZE 050,014 OF oPanelGrid PIXEL

    // Monta aHeader no formato MsNewGetDados:
    // {Titulo, Campo, Mascara, Tamanho, Decimal, Valid, Usado, Tipo, F3, Combo}
    aAdd(aHeadRG, {"CC",               "XX_CC",    "",                        15, 0, ".T.", ".T.", "C", "", ""})
    aAdd(aHeadRG, {"Descricao",        "XX_DESC",  "",                        40, 0, ".T.", ".T.", "C", "", ""})
    aAdd(aHeadRG, {"AOP "+cAnoAnt,     "XX_AOPAN", "@E 999,999,999,999.99",  18, 2, ".T.", ".T.", "N", "", ""})
    aAdd(aHeadRG, {"AOP "+cAnoAtu,     "XX_AOPAT", "@E 999,999,999,999.99",  18, 2, ".T.", ".T.", "N", "", ""})
    aAdd(aHeadRG, {"Realizado",        "XX_REAL",  "@E 999,999,999,999.99",  18, 2, ".T.", ".T.", "N", "", ""})
    aAdd(aHeadRG, {"% Realizado",      "XX_PREAL", "@E 999,999.99",          10, 2, ".T.", ".T.", "N", "", ""})
    aAdd(aHeadRG, {"Saldo Disponivel", "XX_SALDO", "@E 999,999,999,999.99",  18, 2, ".T.", ".T.", "N", "", ""})
    aAdd(aHeadRG, {"% Disponivel",     "XX_PDISP", "@E 999,999.99",          10, 2, ".T.", ".T.", "N", "", ""})
    aAdd(aHeadRG, {"Gestor",           "XX_GESTO", "",                        40, 0, ".T.", ".T.", "C", "", ""})

    If s_dCache == dHoje .And. Len(s_aCache) > 0
        aDadosCCFull   := AClone(s_aCache)
        nTotRealGeral  := s_nTotReal
        nTotSaldoGeral := s_nTotSaldo
        nAOPAntTot     := s_nAOPAntT
        nAOPAtuTot     := s_nAOPAtuT
        nRealAcuTot    := s_nRealAcuT
        nSC7Tot        := s_nSC7T
        nSD3Tot        := s_nSD3T
        nPOTot         := s_nPOT
    Else
        // Busca tudo em uma unica query (CTT + somatorios SC7/SD3/PO por CC)
        cQuery := " SELECT "
        cQuery += "   CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_XAOPAN, CTT.CTT_XAOPAT, CTT.CTT_XGESTO, "
        cQuery += "   ISNULL(S.SC7TOT,0) AS SC7TOT, ISNULL(S.SD3TOT,0) AS SD3TOT, ISNULL(S.POTOT,0) AS POTOT "
        cQuery += " FROM " + RetSqlName("CTT") + " CTT "
        cQuery += " LEFT JOIN ( "
        cQuery += "   SELECT CC, "
        cQuery += "          SUM(CASE WHEN TIPO = 'SC7' THEN VALOR ELSE 0 END) AS SC7TOT, "
        cQuery += "          SUM(CASE WHEN TIPO = 'SD3' THEN VALOR ELSE 0 END) AS SD3TOT, "
        cQuery += "          SUM(CASE WHEN TIPO = 'PO'  THEN VALOR ELSE 0 END) AS POTOT "
        cQuery += "   FROM ( "
        cQuery += "     SELECT C7_CC AS CC, 'SC7' AS TIPO, SUM(C7_TOTAL) AS VALOR "
        cQuery += "     FROM " + RetSqlName("SC7") + " SC7 "
        cQuery += "     WHERE SC7.D_E_L_E_T_ = ' ' AND C7_FILIAL = '" + xFilial("SC7") + "' "
        cQuery += "       AND C7_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' "
        cQuery += "       AND (C7_PO_EIC = '' OR C7_PO_EIC = ' ') "
        cQuery += "     GROUP BY C7_CC "
        cQuery += "     UNION ALL "
        cQuery += "     SELECT D3_CC AS CC, 'SD3' AS TIPO, SUM(D3_CUSTO1) AS VALOR "
        cQuery += "     FROM " + RetSqlName("SD3") + " SD3 "
        cQuery += "     WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '" + xFilial("SD3") + "' "
        cQuery += "       AND D3_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' "
        cQuery += "     GROUP BY D3_CC "
        cQuery += "     UNION ALL "
        cQuery += "     SELECT W3_CTCUSTO AS CC, 'PO' AS TIPO, SUM(VALOR_TOT) AS VALOR "
        cQuery += "     FROM ( "
        cQuery += "       SELECT W3_CTCUSTO, (W3_QTDE * W3_PRECO) AS VALOR_TOT, "
        cQuery += "              ROW_NUMBER() OVER (PARTITION BY W2_PO_NUM, W2_PO_DT, W3_POSICAO ORDER BY W3_REG, W3_SEQ) AS RN "
        cQuery += "       FROM " + RetSqlName("SW2") + " SW2 "
        cQuery += "       INNER JOIN " + RetSqlName("SW3") + " SW3 "
        cQuery += "          ON W3_FILIAL = W2_FILIAL AND W3_PO_NUM = W2_PO_NUM "
        cQuery += "         AND SW3.D_E_L_E_T_ = ' ' "
        cQuery += "       WHERE SW2.D_E_L_E_T_ = ' ' AND W2_FILIAL = '" + xFilial("SW2") + "' "
        cQuery += "         AND W2_PO_DT BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' "
        cQuery += "     ) P "
        cQuery += "     WHERE P.RN = 1 "
        cQuery += "     GROUP BY W3_CTCUSTO "
        cQuery += "   ) U "
        cQuery += "   GROUP BY CC "
        cQuery += " ) S ON S.CC = CTT.CTT_CUSTO "
        cQuery += " WHERE CTT.D_E_L_E_T_ = ' ' AND ISNULL(CTT.CTT_XAOPAT,0) <> 0 "
        cQuery += " ORDER BY CTT.CTT_CUSTO "

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasRG, .F., .T.)

        While !(cAliasRG)->(EOF())
            cCCusto := AllTrim((cAliasRG)->CTT_CUSTO)
            cDescCC := AllTrim((cAliasRG)->CTT_DESC01)
            nAOPAnt := Iif(ValType((cAliasRG)->CTT_XAOPAN) == "N", (cAliasRG)->CTT_XAOPAN, ;
                           Val(AllTrim(cValToChar((cAliasRG)->CTT_XAOPAN))))
            nAOPAtu := Iif(ValType((cAliasRG)->CTT_XAOPAT) == "N", (cAliasRG)->CTT_XAOPAT, ;
                           Val(AllTrim(cValToChar((cAliasRG)->CTT_XAOPAT))))

            cGestor := UsrFullName(AllTrim((cAliasRG)->CTT_XGESTO))
            If Empty(cGestor)
                cGestor := AllTrim((cAliasRG)->CTT_XGESTO)
            EndIf

            nRealCC := (cAliasRG)->SC7TOT + (cAliasRG)->SD3TOT + (cAliasRG)->POTOT
            nSaldoCC := nAOPAtu - nRealCC

            nPercReal  := Iif(nAOPAtu > 0, (nRealCC  / nAOPAtu) * 100, 0)
            nPercSaldo := Iif(nAOPAtu > 0, (nSaldoCC / nAOPAtu) * 100, 0)

            aAdd(aDadosCCFull, { cCCusto, ;
                                 cDescCC, ;
                                 nAOPAnt, ;
                                 nAOPAtu, ;
                                 nRealCC, ;
                                 nPercReal, ;
                                 nSaldoCC, ;
                                 nPercSaldo, ;
                                 cGestor })

            nTotRealGeral  += nRealCC
            nTotSaldoGeral += nSaldoCC
            nAOPAntTot     += nAOPAnt
            nAOPAtuTot     += nAOPAtu
            nRealAcuTot    += nRealCC

            nSC7Tot += (cAliasRG)->SC7TOT
            nSD3Tot += (cAliasRG)->SD3TOT
            nPOTot  += (cAliasRG)->POTOT

            (cAliasRG)->(DbSkip())
        End
        (cAliasRG)->(DbCloseArea())

        s_dCache   := dHoje
        s_aCache   := AClone(aDadosCCFull)
        s_nTotReal := nTotRealGeral
        s_nTotSaldo:= nTotSaldoGeral
        s_nAOPAntT := nAOPAntTot
        s_nAOPAtuT := nAOPAtuTot
        s_nRealAcuT:= nRealAcuTot
        s_nSC7T    := nSC7Tot
        s_nSD3T    := nSD3Tot
        s_nPOT     := nPOTot
    EndIf

    nSaldoAcuTot := nAOPAtuTot - nRealAcuTot

    aDadosCCShow := AClone(aDadosCCFull)

    // Converte dados para formato aCols (cada linha termina com .F.)
    aColsRG := DadosToColsRG(aDadosCCShow)

    // Linha em branco caso nao haja dados (MsNewGetDados exige ao menos 1 linha)
    If Len(aColsRG) == 0
        aAdd(aColsRG, {Space(15), Space(40), 0, 0, 0, 0, 0, 0, Space(40), .F.})
    EndIf

    // Grid classica com barra de rolagem nativa
    oMsGrid := MsNewGetDados():New( ;
        040,;
        003,;
        (oPanelGrid:nClientHeight / 2) - 3,;
        (oPanelGrid:nClientWidth  / 2) - 3,;
        0,;
        "AllwaysTrue()",;
        ,;
        "",;
        {},;
        ,;
        9999,;
        ,;
        ,;
        ,;
        oPanelGrid,;
        aHeadRG,;
        aColsRG)

    @ 020,005 SAY "Total Geral Realizado:   " + ;
                 "R$ " + Transform(nTotRealGeral,"@E 999,999,999,999.99") ;
                 SIZE 300,014 OF oPanelGrid PIXEL FONT oFontBold COLOR CLR_BLUE

    @ 020,380 SAY "Total Geral Saldo Disponivel:   " + ;
                 "R$ " + Transform(nTotSaldoGeral,"@E 999,999,999,999.99") ;
                 SIZE 340,014 OF oPanelGrid PIXEL FONT oFontBold COLOR CLR_BLUE

    oBtnBusca:bAction := {|| BuscaMsRG(oPanelGrid, oBtnBusca, oGetBusca, oMsGrid, ;
                               aDadosCCFull, @aDadosCCShow, cBuscaCC, aHeadRG)}

    oBtnLimpa:bAction := {|| LimpaMsRG(oGetBusca, oMsGrid, ;
                               aDadosCCFull, @aDadosCCShow, @cBuscaCC, aHeadRG)}

    oScrollExec    := TScrollBox():New(oPanelBottom, 0, 0, oPanelBottom:nClientHeight, oPanelBottom:nClientWidth, .T., .T., .T.)
    oPanelExecCont := TPanel():New(0, 0, "", oScrollExec,,,,,, oPanelBottom:nClientWidth, 680, .F., .F.)
    oPanelExecCont:Align := CONTROL_ALIGN_NONE

    @ 005,008 GROUP oGrpAG TO 095,330 ;
        PROMPT " ANALISE AOP " + cAnoAnt + " X " + cAnoAtu + " - TODOS OS C.C. " OF oPanelExecCont PIXEL

    nVarVal := nAOPAtuTot - nAOPAntTot
    nVarPer := Iif(nAOPAntTot > 0, (nVarVal / nAOPAntTot) * 100, 0)

    @ 017,018 SAY "AOP " + cAnoAnt + " (Total): " + Transform(nAOPAntTot,"@E 999,999,999,999.99") ;
        SIZE 260,010 OF oPanelExecCont PIXEL FONT oFontLbl
    @ 032,018 SAY "AOP " + cAnoAtu + " (Total): " + Transform(nAOPAtuTot,"@E 999,999,999,999.99") ;
        SIZE 260,010 OF oPanelExecCont PIXEL FONT oFontLbl
    @ 047,018 SAY "Variacao ($): " + Transform(nVarVal,"@E 999,999,999,999.99") ;
        SIZE 260,010 OF oPanelExecCont PIXEL FONT oFontLbl COLOR ;
        Iif(nAOPAtuTot > nAOPAntTot, CLR_HGREEN, Iif(nAOPAtuTot < nAOPAntTot, CLR_HRED, CLR_BLUE))
    @ 062,018 SAY "Variacao (%): " + Transform(nVarPer,"@E 999,999.99") + "%" ;
        SIZE 260,010 OF oPanelExecCont PIXEL FONT oFontLbl COLOR ;
        Iif(nAOPAtuTot > nAOPAntTot, CLR_HGREEN, Iif(nAOPAtuTot < nAOPAntTot, CLR_HRED, CLR_BLUE))

    @ 005,340 GROUP oGrpAC TO 095,660 ;
        PROMPT " ACUMULADO: AOP X DESPESAS REALIZADAS - TODOS OS C.C. " OF oPanelExecCont PIXEL

    nPctSaldoAcu := Iif(nAOPAtuTot > 0, (nSaldoAcuTot / nAOPAtuTot) * 100, 0)

    @ 017,350 SAY "Realizado (SC7):   " + Transform(nSC7Tot,"@E 999,999,999,999.99") ;
        SIZE 280,010 OF oPanelExecCont PIXEL FONT oFontLbl
    @ 031,350 SAY "Realizado (SD3):   " + Transform(nSD3Tot,"@E 999,999,999,999.99") ;
        SIZE 280,010 OF oPanelExecCont PIXEL FONT oFontLbl
    @ 045,350 SAY "Realizado (PO):    " + Transform(nPOTot,"@E 999,999,999,999.99") ;
        SIZE 280,010 OF oPanelExecCont PIXEL FONT oFontLbl
    @ 059,350 SAY "Total Realizado:   " + Transform(nRealAcuTot,"@E 999,999,999,999.99") ;
        SIZE 280,010 OF oPanelExecCont PIXEL FONT oFontBold COLOR CLR_BLACK
    @ 073,350 SAY "Saldo Disponivel (" + Transform(nPctSaldoAcu,"@E 999,999.99") + "%): " + ;
        Transform(nSaldoAcuTot,"@E 999,999,999,999.99") ;
        SIZE 320,010 OF oPanelExecCont PIXEL FONT oFontSub COLOR ;
        Iif(nSaldoAcuTot >= 0, CLR_BLUE, CLR_RED)

    @ 110,008 GROUP oGrpEP TO 220,330 ;
        PROMPT " EXECUCAO NO PERIODO (" + DToC(dDataDe) + " a " + DToC(dDataAte) + ") - TODOS OS C.C. " ;
        OF oPanelExecCont PIXEL

    nPercTotReal := Iif(nAOPAtuTot > 0, (nTotRealGeral / nAOPAtuTot) * 100, 0)

    @ 125,018 SAY "Realizado (SC7):   " + Transform(nSC7Tot,"@E 999,999,999,999.99") ;
        SIZE 320,010 OF oPanelExecCont PIXEL FONT oFontLbl COLOR CLR_BLACK
    @ 139,018 SAY "Realizado (SD3):   " + Transform(nSD3Tot,"@E 999,999,999,999.99") ;
        SIZE 320,010 OF oPanelExecCont PIXEL FONT oFontLbl COLOR CLR_BLACK
    @ 153,018 SAY "Realizado (PO):    " + Transform(nPOTot,"@E 999,999,999,999.99") ;
        SIZE 320,010 OF oPanelExecCont PIXEL FONT oFontLbl COLOR CLR_BLACK
    @ 167,018 SAY "Total Realizado no Periodo: " + Transform(nTotRealGeral,"@E 999,999,999,999.99") ;
        SIZE 320,010 OF oPanelExecCont PIXEL FONT oFontBold COLOR CLR_BLACK
    @ 181,018 SAY "% Total Realizado no Periodo: " + Transform(nPercTotReal,"@E 999,999.99") + "%" ;
        SIZE 320,010 OF oPanelExecCont PIXEL FONT oFontBold COLOR CLR_BLACK

    @ 230,008 GROUP oGrpGR TO 650,660 ;
        PROMPT " GRAFICO - REALIZADO X SALDO DISPONIVEL - TODOS OS C.C. " OF oPanelExecCont PIXEL

    oPanelChart := TPanel():New(245, 018, "", oPanelExecCont,,,,,, 440, 190, .F., .F.)
    oPanelChart:Align := CONTROL_ALIGN_NONE

    nPercAting := Iif(nAOPAtuTot > 0, (nRealAcuTot / nAOPAtuTot) * 100, 0)
    If nPercAting < 0
        nPercAting := 0
    EndIf
    If nPercAting > 100
        nPercAting := 100
    EndIf
    nPercRest := 100 - nPercAting

    oFWChart := FWChartFactory():New()
    oFWChart := oFWChart:getInstance(PIECHART)
    oFWChart:Init(oPanelChart, .T., .F.)
    oFWChart:SetTitle("Progresso - Todos os CCs", CONTROL_ALIGN_CENTER)
    oFWChart:addSerie("Realizado", Round(nPercAting,2))
    oFWChart:addSerie("Saldo Disponivel", Round(nPercRest,2))
    oFWChart:setPicture("@E 999,999.99")
    oFWChart:setMask("*@*%")
    oFWChart:setLegend(CONTROL_ALIGN_BOTTOM)

    aAdd(aCorChart, {"051,102,153", "010,020,030"})
    aAdd(aCorChart, {"192,192,192", "038,038,038"})
    oFWChart:oFWChartColor:aRandom := aCorChart
    oFWChart:oFWChartColor:SetColor("Random")
    oFWChart:Build()

    @ 445,018 SAY "Realizado: " + Transform(nPercAting,"@E 999,999.99") + "%  -  R$ " + ;
                  AllTrim(Transform(nRealAcuTot,"@E 999,999,999,999,999.99")) ;
                  SIZE 380,012 OF oPanelExecCont PIXEL FONT oFontBold COLOR CLR_HBLUE

    @ 445,400 SAY "|  Saldo Disponivel: " + Transform(nPercRest,"@E 999,999.99") + "%  -  R$ " + ;
                  AllTrim(Transform(nSaldoAcuTot,"@E 999,999,999,999,999.99")) ;
                  SIZE 380,012 OF oPanelExecCont PIXEL FONT oFontBold COLOR CLR_GRAY

Return

/*=================================================================
Fun??o: MontaAbaResumo
Info: Painel anal?tico com:
  - Dados cadastrais do CC (descri??o, gestor, bloqueio)
  - An?lise AOP: anterior x atual, varia??o em valor e %
  - Totais por per?odo (filtro)
  - Totais acumulados (01/01 at? database)
  - AOP x Despesas realizadas: valor, % e gr?fico comparativo
*==================================================================*/
Static Function MontaAbaResumo(oPanel, aParam,;
                                nSC7Per, nSD3Per, nPOPer,;
                                nSC7Acu, nSD3Acu, nPOAcu)

    Local cAlias
    Local cQuery
    Local lSemFiltro := (Len(aParam) < 3 .Or. Empty(aParam[3]))
    Local cAnoAnt    := "-"
    Local cAnoAtu    := "-"
    Local nAOPAnt    := 0
    Local nAOPAtu    := 0
    Local cDescCC    := ""
    Local cGestor    := ""
    Local cBloq      := ""
    Local nVarVal    := 0
    Local nVarPer    := 0

    // Totais calculados
    Local nRealizPer    := nSC7Per + nSD3Per + nPOPer   // Realizado no per?odo
    Local nRealizAcu    := nSC7Acu + nSD3Acu + nPOAcu   // Realizado acumulado

    Local nSaldoPer     := 0, nSaldoPerPct := 0
    Local nSaldoAcu     := 0, nSaldoAcuPct := 0, nPctSaldoAcu := 0
    Local nPercTotReal  := 0

    // Fontes
    Local oFontTit := TFont():New("Arial",,-14,.T.)
    Local oFontSub := TFont():New("Arial",,-11,.T.)
    Local oFontLbl := TFont():New("Arial",,-10,.F.)
    Local oFontBold := TFont():New("Arial Black", , -11)  // Arial Black = negrito nativo

    // Percentuais para resumo visual (Atingido x Restante)
    Local nPercAting := 0
    Local nPercRest  := 0

    // Objeto e cores do grafico FWChartFactory
    Local oFWChart
    Local oPanelChart
    Local oScrollBox
    Local oPanelContent
    Local aCorChart := {}

    If !lSemFiltro
        cAlias := GetNextAlias()
        cQuery := " SELECT CTT_DESC01, CTT_BLOQ, CTT_XAOPAN, CTT_XAOPAT, CTT_XGESTO "
        cQuery += " FROM " + RetSqlName("CTT")
        cQuery += " WHERE CTT_CUSTO = '" + aParam[3] + "' AND D_E_L_E_T_ = ' ' "
        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
        If !(cAlias)->(EOF())
            cDescCC := AllTrim((cAlias)->CTT_DESC01)
            cBloq   := Iif((cAlias)->CTT_BLOQ == "1", "SIM", "NAO")
            nAOPAnt := Iif(ValType((cAlias)->CTT_XAOPAN) == "N", (cAlias)->CTT_XAOPAN, Val(AllTrim(cValToChar((cAlias)->CTT_XAOPAN))))
            nAOPAtu := Iif(ValType((cAlias)->CTT_XAOPAT) == "N", (cAlias)->CTT_XAOPAT, Val(AllTrim(cValToChar((cAlias)->CTT_XAOPAT))))
            cGestor := UsrFullName(AllTrim((cAlias)->CTT_XGESTO))
            If Empty(cGestor)
                cGestor := AllTrim((cAlias)->CTT_XGESTO)
            EndIf
        EndIf
        (cAlias)->(DbCloseArea())
        cAnoAnt := cValToChar(Year(aParam[1]) - 1)
        cAnoAtu := cValToChar(Year(aParam[1]))
    Else
        cDescCC := "Informe o filtro no cabecalho e clique em Confirmar"
        cBloq   := "-"
    EndIf

    // ?? C?lculos seguros ?????????????????????????????????????????
    nVarVal := nAOPAtu - nAOPAnt
    nVarPer := Iif(nAOPAnt > 0, (nVarVal / nAOPAnt) * 100, 0)

    // Saldo e % do PER?ODO
    nSaldoPer    := nAOPAtu - nRealizPer
    nSaldoPerPct := Iif(nAOPAtu > 0, (nRealizPer / nAOPAtu) * 100, 0)

    // Saldo e % ACUMULADO (01/01 at? database)
    nSaldoAcu    := nAOPAtu - nRealizAcu
    nSaldoAcuPct := Iif(nAOPAtu > 0, (nRealizAcu / nAOPAtu) * 100, 0)
    // % do Saldo Acumulado sobre o AOP do Ano (ex.: AOP 1000, Saldo 900 = 90%)
    nPctSaldoAcu := Iif(nAOPAtu > 0, (nSaldoAcu / nAOPAtu) * 100, 0)

    // % Total realizado no periodo (para bloco Execucao no Periodo)
    nPercTotReal := Iif(nAOPAtu > 0, (nRealizPer / nAOPAtu) * 100, 0)

    // Percentuais Atingido x Restante para exibi??o
    nPercAting := Iif(nAOPAtu > 0, (nRealizAcu / nAOPAtu) * 100, 0)
    If nPercAting < 0
        nPercAting := 0
    EndIf
    If nPercAting > 100
        nPercAting := 100
    EndIf
    nPercRest := 100 - nPercAting

    // Ajuste para garantir rolagem: viewport menor (400) e conteudo maior (650) para mostrar grafico + textos
    oScrollBox    := TScrollBox():New(oPanel, 0, 0, 400, 1180, .T., .T., .T.)
    oPanelContent := TPanel():New(0, 0, "", oScrollBox,,,,,, 1180, 510, .F., .F.)
    oPanelContent:Align := CONTROL_ALIGN_NONE

    @ 005,008 SAY "CENTRO DE CUSTO: " + Iif(lSemFiltro, "-", aParam[3]) + "   |   " + cDescCC + "   |   Bloqueado? " + cBloq SIZE 700,013 OF oPanelContent PIXEL FONT oFontTit COLOR Iif(cBloq == "SIM", CLR_RED, CLR_BLUE)
    @ 021,008 SAY "Gestor: " + cGestor  SIZE 400,010 OF oPanelContent PIXEL FONT oFontSub
    @ 033,008 SAY "Periodo do Filtro: " + Iif(lSemFiltro, "-", DToC(aParam[1]) + " a " + DToC(aParam[2])) + ;
                  Iif(lSemFiltro, "", "   |   Acumulado: 01/01/" + cValToChar(Year(aParam[2])) + " a " + DToC(aParam[2])) ;
                  SIZE 500,009 OF oPanelContent PIXEL FONT oFontLbl

    @ 045,008 GROUP oGrp1 TO 115,310 PROMPT " Analise AOP (" + cAnoAnt + " x " + cAnoAtu + ") " OF oPanelContent PIXEL
    @ 057,018 SAY "AOP " + cAnoAnt + ":   " + Transform(nAOPAnt, "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 068,018 SAY "AOP " + cAnoAtu + ":   " + Transform(nAOPAtu, "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    // Cor: verde se AOP atual > anterior, vermelho se menor
    @ 079,018 SAY "Variacao ($):   " + Transform(nVarVal, "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl ;
                  COLOR Iif(nAOPAtu > nAOPAnt, CLR_HGREEN, Iif(nAOPAtu < nAOPAnt, CLR_HRED, CLR_BLUE))
    @ 090,018 SAY "Variacao (%):   " + Transform(nVarPer, "@E 999,999.99") + "%" SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl ;
                  COLOR Iif(nAOPAtu > nAOPAnt, CLR_HGREEN, Iif(nAOPAtu < nAOPAnt, CLR_HRED, CLR_BLUE))

    @ 045,315 GROUP oGrp2 TO 116,620 PROMPT " Execucao no Periodo (" + Iif(lSemFiltro, "-", DToC(aParam[1]) + " a " + DToC(aParam[2])) + ") " OF oPanelContent PIXEL
    @ 057,325 SAY "Realizado (SC7):" + Transform(nSC7Per,    "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 069,325 SAY "Realizado (SD3):" + Transform(nSD3Per,    "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 081,325 SAY "Realizado (PO): " + Transform(nPOPer,     "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 093,325 SAY "Total Realizado:" + Transform(nRealizPer, "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontBold COLOR CLR_BLACK
    @ 105,325 SAY "% Total Realizado:" + Transform(nPercTotReal, "@E 999,999.99") + "%" SIZE 250,009 OF oPanelContent PIXEL FONT oFontBold COLOR CLR_BLACK

    @ 120,008 GROUP oGrp3 TO 210,620 PROMPT " Acumulado: AOP x Despesas Realizadas " + Iif(lSemFiltro, "(-)", "01/01/" + cValToChar(Year(aParam[2])) + " ate " + DToC(aParam[2]) + ") ") OF oPanelContent PIXEL

    @ 133,018 SAY "Realizado (SC7):   " + Transform(nSC7Acu,    "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 147,018 SAY "Realizado (SD3):   " + Transform(nSD3Acu,    "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 161,018 SAY "Realizado (PO):    " + Transform(nPOAcu,     "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontLbl
    @ 175,018 SAY "Total Realizado:   " + Transform(nRealizAcu, "@E 999,999,999.99") SIZE 250,009 OF oPanelContent PIXEL FONT oFontBold COLOR CLR_BLACK
    @ 189,018 SAY "Saldo Disponivel (" + Transform(nPctSaldoAcu, "@E 999,999.99") + "%):   " + Transform(nSaldoAcu, "@E 999,999,999.99") SIZE 320,010 OF oPanelContent PIXEL FONT oFontSub COLOR Iif(nSaldoAcu >= 0, CLR_BLUE, CLR_RED)

    // ?? Bloco 4: Grafico - Realizado x Acumulado (Atingido x Restante) ??

    @ 220,008 GROUP oGrp4 TO 500,620 PROMPT " Grafico - Realizado x Acumulado " OF oPanelContent PIXEL
    // Painel filho para limitar o tamanho do grafico (altura maior para caber legenda e textos)
    oPanelChart := TPanel():New(235, 018, "", oPanelContent,,,,,, 440, 190, .F., .F.)
    oPanelChart:Align := CONTROL_ALIGN_NONE

    // Grafico de pizza usando FWChartFactory
    oFWChart := FWChartFactory():New()
    oFWChart := oFWChart:getInstance(PIECHART)

    // Inicializa o grafico (legenda .T., 3D .F. para evitar distorcao de cores)
    oFWChart:Init(oPanelChart, .T., .F.)

    // Titulo centralizado acima do grafico
    oFWChart:SetTitle("Progresso", CONTROL_ALIGN_CENTER)

    // Series: Realizado e Saldo disponivel em percentual (arredondados)
    oFWChart:addSerie("Realizado", Round(nPercAting, 2))
    oFWChart:addSerie("Saldo Disponivel", Round(nPercRest, 2))

    // Mascara / picture dos valores em percentual (tooltip apenas com o valor)
    oFWChart:setPicture("@E 999,999.99")
    oFWChart:setMask("*@*%")

    // Legenda abaixo do grafico (mais proxima ao grafico)
    oFWChart:setLegend(CONTROL_ALIGN_BOTTOM)

    // Cores das fatias (Atingido = azul, Restante = cinza) - valores bem definidos
    aAdd(aCorChart, {"051,102,153", "010,020,030"}) // azul
    aAdd(aCorChart, {"192,192,192", "038,038,038"}) // cinza
    oFWChart:oFWChartColor:aRandom := aCorChart
    oFWChart:oFWChartColor:SetColor("Random")

    // Constroi o grafico
    oFWChart:Build()

    // Percentuais e valores abaixo do grafico (Realizado e Saldo Disponivel em destaque)
    @ 418,018 SAY "Realizado: " + Transform(nPercAting, "@E 999,999.99") + "%  -  R$ " + ;
                  AllTrim(Transform(nRealizAcu, "@E 999,999,999,999,999.99")) ;
                  SIZE 380,012 OF oPanelContent PIXEL FONT oFontBold COLOR CLR_HBLUE

    @ 418,400 SAY "|  Saldo Disponivel: " + Transform(nPercRest, "@E 999,999.99") + "%  -  R$ " + ;
                  AllTrim(Transform(nSaldoAcu, "@E 999,999,999,999,999.99")) ;
                  SIZE 380,012 OF oPanelContent PIXEL FONT oFontBold COLOR CLR_GRAY

Return

/*=================================================================
Fun??o Gen?rica: MontaGridComBusca
Info: Cria grid padr?o com campo de busca e rodap? de total
*==================================================================*/
Static Function MontaGridComBusca(oPanel, aHeader, aColSizes, aDadosCompleto, nTotalGeral, cMascaraTot)
    Local oGrid      := Nil
    Local oGetBusca  := Nil
    Local oSayTotal  := Nil
    Local oBtnBusca  := Nil
    Local oBtnLimpar := Nil
    Local cBusca      := Space(20)
    Local aDadosShow  := AClone(aDadosCompleto)
    Local nTotalShow  := nTotalGeral
    Local cTextoRodape := "Total: R$ " + Transform(nTotalGeral, cMascaraTot)
    Local nGridTop     := 28
    // Usa praticamente toda a altura disponivel do painel para o grid,
    // deixando apenas uma pequena margem inferior.
    Local nGridBottom := oPanel:nClientHeight - 5

    // 1. Cria os componentes de Busca (Topo)
    @ 005,005 SAY "Pesquisar:" SIZE 040,008 OF oPanel PIXEL
    @ 003,047 MSGET oGetBusca VAR cBusca SIZE 130,010 OF oPanel PIXEL

    @ 002,182 BUTTON oBtnBusca  PROMPT "Buscar" SIZE 038,012 OF oPanel PIXEL
    @ 002,224 BUTTON oBtnLimpar PROMPT "Limpar" SIZE 038,012 OF oPanel PIXEL

    // 2. Total dos documentos (linha fixa abaixo da pesquisa); bloco {|| cTextoRodape} para atualizar ao filtrar sem SetAllText
    oSayTotal := TSay():New(18, 5, {|| cTextoRodape}, oPanel, , TFont():New("Arial",,-11,.T.), , , , .T.)
    oSayTotal:nWidth  := 500
    oSayTotal:nHeight := 12
    oSayTotal:SetColor(CLR_BLUE)
    oSayTotal:Refresh()

    // 3. Grid abaixo da linha de total
    oGrid := TWBrowse():New(nGridTop, 05, oPanel:nClientWidth - 5, nGridBottom,, aHeader, aColSizes, oPanel,,,,,,,,,,,, .F.,, .T.,, .F.)
    
    oGrid:SetArray(aDadosShow)
    oGrid:bLine := {|| Iif(Len(aDadosShow) > 0 .And. oGrid:nAt > 0,;
                           aDadosShow[oGrid:nAt],;
                           Array(Len(aHeader)))}
    oGrid:Refresh()

    // Buscar: for?a perda de foco do Get (SetFocus) para cBusca ser atualizado, depois filtra com valor do Get
    oBtnBusca:bAction  := {|| (oPanel:SetFocus(), oBtnBusca:SetFocus(), ;
                               AtualizaFiltro(oGetBusca, oGrid, oSayTotal, aDadosCompleto, @aDadosShow, cMascaraTot, @cTextoRodape, cBusca))}
    oBtnLimpar:bAction := {|| (cBusca := Space(20), oGetBusca:SetText(Space(20)), ;
                               AtualizaFiltro(oGetBusca, oGrid, oSayTotal, aDadosCompleto, @aDadosShow, cMascaraTot, @cTextoRodape, ""))}
    oGetBusca:bChange  := {|| AtualizaFiltro(oGetBusca, oGrid, oSayTotal, aDadosCompleto, @aDadosShow, cMascaraTot, @cTextoRodape, Nil)}

Return
/*=================================================================
Funcao: AtualizaFiltro
Info: Filtra pelo numero do documento (coluna 1). cTextoBusca = valor ao clicar Buscar; Nil = le do Get.
      cTextoRodape = variavel do rodape (atualizada aqui e exibida no SAY com bloco).
*==================================================================*/
Static Function AtualizaFiltro(oGet, oGrid, oSay, aDadosFull, aDadosShow, cMascara, cTextoRodape, cTextoBusca)
    Local cTexto  := Iif(PCount() >= 8 .And. cTextoBusca != Nil, AllTrim(cTextoBusca), AllTrim(oGet:GetText()))
    Local nX      := 0
    Local nTot    := 0
    Local nCols   := 0
    Local cNumDoc := ""

    aSize(aDadosShow, 0)

    If Empty(cTexto)
        aDadosShow := AClone(aDadosFull)
    Else
        // Filtro pelo numero do documento (1a coluna): so exibe linhas cujo documento seja igual ao informado
        cTexto := AllTrim(Upper(cTexto))
        For nX := 1 To Len(aDadosFull)
            cNumDoc := AllTrim(Upper(cValToChar(aDadosFull[nX][1])))
            If cNumDoc == cTexto
                aAdd(aDadosShow, aDadosFull[nX])
            EndIf
        Next
    EndIf

    // Recalcula total (?ltima coluna num?rica)
    For nX := 1 To Len(aDadosShow)
        nCols := Len(aDadosShow[nX])
        If ValType(aDadosShow[nX][nCols]) == "N"
            nTot += aDadosShow[nX][nCols]
        EndIf
    Next

    oGrid:SetArray(aDadosShow)
    oGrid:bLine := {|| Iif(Len(aDadosShow) > 0 .And. oGrid:nAt > 0,;
                           aDadosShow[oGrid:nAt],;
                           Iif(Len(aDadosFull) > 0, Array(Len(aDadosFull[1])), {}))}
    oGrid:Refresh()

    // Total permanece fixo (sempre o total geral); nao exibe quantidade de registros
    If ValType(oSay) == "O"
        oSay:Refresh()
    EndIf

Return .T.

/*=================================================================
Funcao: HasUsr
Info: Verifica se cUser existe na lista (separada por ';')
      evitando match parcial (ex.: 00001 em 000010)
==================================================================*/
Static Function HasUsr(cList, cUser)
    Local cL := ";" + AllTrim(cValToChar(cList))
    Local cU := AllTrim(cValToChar(cUser))

    If Empty(cU)
        Return .F.
    EndIf

    // Garante delimitador final
    If Right(cL,1) <> ";"
        cL += ";"
    EndIf

Return (";" + cU + ";") $ cL

/*=================================================================
Fun??o Auxiliar: BuscaTotalAcumulado
Info: Retorna o total acumulado de SC7, SD3 ou PO
      para o per?odo 01/01/ANO at? aParam[2], por CC
Par?metros:
  cTabela   - "SC7" | "SD3" | "SW2"
  aParam    - array de par?metros (dDe, dAte, cCC)
Retorno:    nTotal (Numeric)
*==================================================================*/
Static Function BuscaTotalAcumulado(cTabela, aParam)
    Local cAlias   := GetNextAlias()
    Local cQuery   := ""
    Local dAcuDe   := CtoD("01/01/" + cValToChar(Year(aParam[2])))  // 1? Jan do ano
    Local nTotal   := 0
    Local cDtAte   := DToS(aParam[2])
    Local cDtDe    := DToS(dAcuDe)
    Local cCC      := aParam[3]

    Do Case
        Case cTabela == "SC7"
            cQuery := " SELECT SUM(C7_TOTAL) AS VTOTAL "
            cQuery += " FROM " + RetSqlName("SC7")
            cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL = '" + xFilial("SC7") + "' "
            cQuery += "   AND C7_EMISSAO BETWEEN '" + cDtDe + "' AND '" + cDtAte + "' "
            cQuery += "   AND (C7_PO_EIC = '' OR C7_PO_EIC = ' ') "
            If !Empty(cCC)
                cQuery += "   AND C7_CC = '" + cCC + "' "
            EndIf

        Case cTabela == "SD3"
            cQuery := " SELECT SUM(D3_CUSTO1) AS VTOTAL "
            cQuery += " FROM " + RetSqlName("SD3")
            cQuery += " WHERE D_E_L_E_T_ = ' ' AND D3_FILIAL = '" + xFilial("SD3") + "' "
            cQuery += "   AND D3_EMISSAO BETWEEN '" + cDtDe + "' AND '" + cDtAte + "' "
            If !Empty(cCC)
                cQuery += "   AND D3_CC = '" + cCC + "' "
            EndIf

        Case cTabela == "SW2"
            // Mesma regra de MontaAbaPO: uma linha por posicao (RN=1) para nao somar parcelas
            cQuery := " SELECT SUM(VALOR_TOT) AS VTOTAL FROM ( "
            cQuery += "   SELECT (W3_QTDE * W3_PRECO) AS VALOR_TOT, "
            cQuery += "          ROW_NUMBER() OVER (PARTITION BY W2_PO_NUM, W2_PO_DT, W3_POSICAO ORDER BY W3_REG, W3_SEQ) AS RN "
            cQuery += "   FROM " + RetSqlName("SW2") + " SW2 "
            cQuery += "   INNER JOIN " + RetSqlName("SW3") + " SW3 "
            cQuery += "      ON W3_FILIAL = W2_FILIAL AND W3_PO_NUM = W2_PO_NUM "
            cQuery += "     AND SW3.D_E_L_E_T_ = ' ' "
            cQuery += "   WHERE SW2.D_E_L_E_T_ = ' ' AND W2_FILIAL = '" + xFilial("SW2") + "' "
            cQuery += "     AND W2_PO_DT BETWEEN '" + cDtDe + "' AND '" + cDtAte + "' "
            If !Empty(cCC)
                cQuery += "     AND W3_CTCUSTO = '" + cCC + "' "
            EndIf
            cQuery += " ) T WHERE T.RN = 1 "

        Otherwise
            Return 0
    EndCase

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
    If !(cAlias)->(EOF())
        nTotal := Iif(ValType((cAlias)->VTOTAL) == "N", (cAlias)->VTOTAL, 0)
    EndIf
    (cAlias)->(DbCloseArea())

Return nTotal

/*=================================================================
Funcao Auxiliar: BscTotCC
Info: Retorna o total acumulado de SC7, SD3 ou PO
      para o periodo 01/01/ANO ate dAte, por centro de custo
Par�metros:
  cTabela   - "SC7" | "SD3" | "SW2"
  dDe      - data inicial do acumulado (normalmente 01/01/ANO)
  dAte     - data final do acumulado
  cCC      - centro de custo
Retorno:    nTotal (Numeric)
*==================================================================*/
Static Function BscTotCC(cTabela, dDe, dAte, cCC)
    Local cAlias   := GetNextAlias()
    Local cQuery   := ""
    Local nTotal   := 0
    Local cDtAte   := DToS(dAte)
    Local cDtDe    := DToS(dDe)

    Do Case
        Case cTabela == "SC7"
            cQuery := " SELECT SUM(C7_TOTAL) AS VTOTAL "
            cQuery += " FROM " + RetSqlName("SC7")
            cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL = '" + xFilial("SC7") + "' "
            cQuery += "   AND C7_EMISSAO BETWEEN '" + cDtDe + "' AND '" + cDtAte + "' "
            cQuery += "   AND (C7_PO_EIC = '' OR C7_PO_EIC = ' ') "
            If !Empty(cCC)
                cQuery += "   AND C7_CC = '" + cCC + "' "
            EndIf

        Case cTabela == "SD3"
            cQuery := " SELECT SUM(D3_CUSTO1) AS VTOTAL "
            cQuery += " FROM " + RetSqlName("SD3")
            cQuery += " WHERE D_E_L_E_T_ = ' ' AND D3_FILIAL = '" + xFilial("SD3") + "' "
            cQuery += "   AND D3_EMISSAO BETWEEN '" + cDtDe + "' AND '" + cDtAte + "' "
            If !Empty(cCC)
                cQuery += "   AND D3_CC = '" + cCC + "' "
            EndIf

        Case cTabela == "SW2"
            cQuery := " SELECT SUM(VALOR_TOT) AS VTOTAL FROM ( "
            cQuery += "   SELECT (W3_QTDE * W3_PRECO) AS VALOR_TOT, "
            cQuery += "          ROW_NUMBER() OVER (PARTITION BY W2_PO_NUM, W2_PO_DT, W3_POSICAO ORDER BY W3_REG, W3_SEQ) AS RN "
            cQuery += "   FROM " + RetSqlName("SW2") + " SW2 "
            cQuery += "   INNER JOIN " + RetSqlName("SW3") + " SW3 "
            cQuery += "      ON W3_FILIAL = W2_FILIAL AND W3_PO_NUM = W2_PO_NUM "
            cQuery += "     AND SW3.D_E_L_E_T_ = ' ' "
            cQuery += "   WHERE SW2.D_E_L_E_T_ = ' ' AND W2_FILIAL = '" + xFilial("SW2") + "' "
            cQuery += "     AND W2_PO_DT BETWEEN '" + cDtDe + "' AND '" + cDtAte + "' "
            If !Empty(cCC)
                cQuery += "     AND W3_CTCUSTO = '" + cCC + "' "
            EndIf
            cQuery += " ) T WHERE T.RN = 1 "

        Otherwise
            Return 0
    EndCase

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
    If !(cAlias)->(EOF())
        nTotal := Iif(ValType((cAlias)->VTOTAL) == "N", (cAlias)->VTOTAL, 0)
    EndIf
    (cAlias)->(DbCloseArea())

Return nTotal

/*=================================================================
Funcao: FiltReGe
Info: Filtro do grid da aba "Resumo Geral" por CC ou descricao
==================================================================*/
Static Function FiltReGe(oGet, oGrid, aDadosFull, aDadosShow, cTextoBusca)
    Local cTexto := ""
    Local nX     := 0
    Local cCC    := ""

    // Se veio texto pelo botao Buscar, usa ele; senao le do GET
    If PCount() >= 5 .And. cTextoBusca != Nil
        cTexto := AllTrim(Upper(cTextoBusca))
    Else
        cTexto := AllTrim(Upper(oGet:GetText()))
    EndIf

    // Normaliza para comparar CC com/sem pontuacao (ex.: 1.3.1.2)
    cTexto := NormCC(cTexto)

    aSize(aDadosShow, 0)

    If Empty(cTexto)
        aDadosShow := AClone(aDadosFull)
    Else
        For nX := 1 To Len(aDadosFull)
            cCC := NormCC(cValToChar(aDadosFull[nX][1]))
            If cCC == cTexto
                aAdd(aDadosShow, aDadosFull[nX])
            EndIf
        Next
    EndIf

Return .T.

/*=================================================================
Funcao: NormCC
Info: Normaliza codigo do CC (remove pontuacao/espacos)
==================================================================*/
Static Function NormCC(cCC)
    Local cRet := AllTrim(Upper(cValToChar(cCC)))
    cRet := StrTran(cRet, ".", "")
    cRet := StrTran(cRet, "-", "")
Return cRet

/*=================================================================
Fun??o: MontaAbaPedidos (SC7)
Par?metros adicionais: nTotalAcuOut ? total acumulado (01/01 at? database)
*==================================================================*/
Static Function MontaAbaPedidos(oPanel, aParam, nTotalOut, nTotalAcuOut)
    Local cQuery, cAlias
    Local aDados := {}
    Local nTotal := 0
    Local oScroll

    // ScrollBox para permitir rolagem vertical quando houver muitos registros
    oScroll := TScrollBox():New(oPanel, 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, .T., .T., .T.)

    If Len(aParam) < 3 .Or. Empty(aParam[3])
        nTotalOut    := 0
        nTotalAcuOut := 0
        MontaGridComBusca(oScroll, {"Pedido", "Item", "Emissao", "Produto", "Descricao", "Qtd", "Valor Total"}, {60, 30, 60, 80, 180, 60, 100}, {}, 0, "@E 999,999,999.99")
        Return
    EndIf

    cAlias := GetNextAlias()
    cQuery := " SELECT C7_NUM, C7_ITEM, C7_EMISSAO, C7_PRODUTO, B1_DESC, C7_QUANT, C7_TOTAL "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
    cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' AND C7_FILIAL = '" + xFilial("SC7") + "' "
    cQuery += " AND C7_EMISSAO BETWEEN '" + DToS(aParam[1]) + "' AND '" + DToS(aParam[2]) + "' "
    cQuery += " AND (C7_PO_EIC = '' OR C7_PO_EIC = ' ') "
    If !Empty(aParam[3])
        cQuery += " AND C7_CC = '" + aParam[3] + "' "
    EndIf
    cQuery += " ORDER BY C7_EMISSAO DESC "

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    While !(cAlias)->(EOF())
        nTotal += (cAlias)->C7_TOTAL
        aAdd(aDados, { AllTrim((cAlias)->C7_NUM),;
                       AllTrim((cAlias)->C7_ITEM),;
                       DToC(SToD((cAlias)->C7_EMISSAO)),;
                       AllTrim((cAlias)->C7_PRODUTO),;
                       AllTrim((cAlias)->B1_DESC),;
                       Transform((cAlias)->C7_QUANT, "@E 999,999.99"),;
                       (cAlias)->C7_TOTAL })
        (cAlias)->(DbSkip())
    End
    (cAlias)->(DbCloseArea())

    nTotalOut    := nTotal
    nTotalAcuOut := BuscaTotalAcumulado("SC7", aParam)

    MontaGridComBusca(oScroll,;
        {"Pedido", "Item", "Emiss?o", "Produto", "Descri??o", "Qtd", "Valor Total"},;
        {60, 30, 60, 80, 180, 60, 100},;
        aDados, nTotal, "@E 999,999,999.99")
Return

/*=================================================================
Fun??o: MontaAbaMovimentacoes (SD3)
*==================================================================*/
Static Function MontaAbaMovimentacoes(oPanel, aParam, nTotalOut, nTotalAcuOut)
    Local cQuery, cAlias
    Local aDados := {}
    Local nTotal := 0
    Local oScroll

    // ScrollBox para permitir rolagem vertical quando houver muitos registros
    oScroll := TScrollBox():New(oPanel, 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, .T., .T., .T.)

    If Len(aParam) < 3 .Or. Empty(aParam[3])
        nTotalOut    := 0
        nTotalAcuOut := 0
        MontaGridComBusca(oScroll, {"Documento", "Emissao", "TM", "Produto", "Descricao", "Qtd", "Custo Total"}, {70, 60, 30, 80, 180, 60, 100}, {}, 0, "@E 999,999,999.99")
        Return
    EndIf

    cAlias := GetNextAlias()
    cQuery := " SELECT D3_DOC, D3_EMISSAO, D3_TM, D3_COD, B1_DESC, D3_QUANT, D3_CUSTO1 "
    cQuery += " FROM " + RetSqlName("SD3") + " SD3 "
    cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D3_COD AND SB1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '" + xFilial("SD3") + "' "
    cQuery += " AND D3_EMISSAO BETWEEN '" + DToS(aParam[1]) + "' AND '" + DToS(aParam[2]) + "' "
    If !Empty(aParam[3])
        cQuery += " AND D3_CC = '" + aParam[3] + "' "
    EndIf
    cQuery += " ORDER BY D3_EMISSAO DESC "

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    While !(cAlias)->(EOF())
        nTotal += (cAlias)->D3_CUSTO1
        aAdd(aDados, { AllTrim((cAlias)->D3_DOC),;
                       DToC(SToD((cAlias)->D3_EMISSAO)),;
                       AllTrim((cAlias)->D3_TM),;
                       AllTrim((cAlias)->D3_COD),;
                       AllTrim((cAlias)->B1_DESC),;
                       Transform((cAlias)->D3_QUANT, "@E 999,999.99"),;
                       (cAlias)->D3_CUSTO1 })
        (cAlias)->(DbSkip())
    End
    (cAlias)->(DbCloseArea())

    nTotalOut    := nTotal
    nTotalAcuOut := BuscaTotalAcumulado("SD3", aParam)

    MontaGridComBusca(oScroll,;
        {"Documento", "Emiss?o", "TM", "Produto", "Descri??o", "Qtd", "Custo Total"},;
        {70, 60, 30, 80, 180, 60, 100},;
        aDados, nTotal, "@E 999,999,999.99")
Return

/*=================================================================
Funcao: MontaAbaPO (SW2/SW3) - Purchase Order (Importacao)
Info: Uma linha por posicao (W3_POSICAO), pegando o registro principal (primeiro por
      W3_REG, W3_SEQ) para qtd e valor baterem com o modulo EIC; nao somar parcelas.
*==================================================================*/
Static Function MontaAbaPO(oPanel, aParam, nTotalOut, nTotalAcuOut)
    Local cQuery, cAlias
    Local aDados := {}
    Local nTotal := 0
    Local oScroll

    // ScrollBox para permitir rolagem vertical quando houver muitos registros
    oScroll := TScrollBox():New(oPanel, 0, 0, oPanel:nClientHeight, oPanel:nClientWidth, .T., .T., .T.)

    If Len(aParam) < 3 .Or. Empty(aParam[3])
        nTotalOut    := 0
        nTotalAcuOut := 0
        MontaGridComBusca(oScroll, {"PO Num", "Seq", "Data Ped.", "Produto", "Qtd", "Valor Total"}, {70, 30, 60, 80, 60, 100}, {}, 0, "@E 999,999,999.99")
        Return
    EndIf

    cAlias := GetNextAlias()
    cQuery := " SELECT W2_PO_NUM, W3_POS, W2_PO_DT, W3_COD_I, W3_QTDE, VALOR_TOT FROM ( "
    cQuery += "   SELECT W2_PO_NUM, W3_POSICAO AS W3_POS, W2_PO_DT, W3_COD_I, W3_QTDE, "
    cQuery += "          (W3_QTDE * W3_PRECO) AS VALOR_TOT, "
    cQuery += "          ROW_NUMBER() OVER (PARTITION BY W2_PO_NUM, W2_PO_DT, W3_POSICAO ORDER BY W3_REG, W3_SEQ) AS RN "
    cQuery += "   FROM " + RetSqlName("SW2") + " SW2 "
    cQuery += "   INNER JOIN " + RetSqlName("SW3") + " SW3 "
    cQuery += "      ON W3_FILIAL = W2_FILIAL AND W3_PO_NUM = W2_PO_NUM "
    cQuery += "     AND SW3.D_E_L_E_T_ = ' ' "
    cQuery += "   WHERE SW2.D_E_L_E_T_ = ' ' AND W2_FILIAL = '" + xFilial("SW2") + "' "
    cQuery += "     AND W2_PO_DT BETWEEN '" + DToS(aParam[1]) + "' AND '" + DToS(aParam[2]) + "' "
    If !Empty(aParam[3])
        cQuery += "     AND W3_CTCUSTO = '" + aParam[3] + "' "
    EndIf
    cQuery += " ) T WHERE T.RN = 1 "
    cQuery += " ORDER BY W2_PO_DT DESC, W2_PO_NUM, W3_POS "

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    While !(cAlias)->(EOF())
        nTotal += (cAlias)->VALOR_TOT
        aAdd(aDados, { AllTrim((cAlias)->W2_PO_NUM),;
                       AllTrim((cAlias)->W3_POS),;
                       DToC(SToD((cAlias)->W2_PO_DT)),;
                       AllTrim((cAlias)->W3_COD_I),;
                       Transform((cAlias)->W3_QTDE,  "@E 999,999.99"),;
                       (cAlias)->VALOR_TOT })
        (cAlias)->(DbSkip())
    End
    (cAlias)->(DbCloseArea())

    nTotalOut    := nTotal
    nTotalAcuOut := BuscaTotalAcumulado("SW2", aParam)

    MontaGridComBusca(oScroll,;
        {"PO Num", "Seq", "Data Ped.", "Produto", "Qtd", "Valor Total"},;
        {70, 30, 60, 80, 60, 100},;
        aDados, nTotal, "@E 999,999,999.99")
Return
