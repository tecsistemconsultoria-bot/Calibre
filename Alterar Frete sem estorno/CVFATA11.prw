#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOPCONN.ch'
#Include 'RwMake.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: 
Uso: Calibre
Tipo: Atualiza??es
Rotina: Faturamento
Fun??o: CVFATA11
Info: Altera??o de Pedido de Vendas 
-----------------------------------------------------------------------
Historico de alteracoes:
06/07/2026 Fernando Pessoa - Tecsistem
- Coluna Status (C6_XSTATUS virtual) no grid
- Edicao de C6_CRVENT e C6_ENTREG com validacao de data
- Sincronizacao grid/aCols (U_CVF11LIN, U_CVF11TOK, U_LINPV2)
- Gravacao SC6 e atualizacao SC9 (todas as sequencias C9_SEQUEN)
- Funcoes auxiliares: xSyncLinhaAcols, xToDate, xFmtChave, xAtuSC9Linha
04/08/2026 Fernando Pessoa - Tecsistem
- Correcao: alteracao apenas de cabecalho (ex.: Fatura?) nao pode alterar C6_CRVENT/C6_ENTREG/C5_TRANSP
- xSyncLinhaAcols so sincroniza datas quando o campo em edicao e data
- Grava SC5 somente campos liberados em aAltEnchoice
- Grava datas SC6 somente se o usuario editou via LINPV2 (aDtEditCRV/aDtEditENT)
- C6_CRVENT alterada: obriga >= dDatabase (campo e confirmacao)
************************************************************************/
User Function CVFATA11() 

    Local cLinok 	 := "U_CVF11LIN()"
    Local cTudook 	 := "U_CVF11TOK()"
    Local nOpce 	 := 4 	//define modo de altera??o para a enchoice
    Local nOpcg 	 := 4 	//define modo de altera??o para o grid
    Local nX         := 0
    Local cFieldok 	 := "U_LINPV2()"
    Local lRet 		 := .T.
    Local lVirtual   := .T. //Mostra campos virtuais se houver
    Local nFreeze	 := 0	
    Local nAlturaEnc := 200	//Altura da Enchoice
	Local cUsrId2    := GetMV("XX_USRROT2",.F.,"")
    Local cAltPrc    := GetMV("XX_ALTPRC",.F.,"")
	Local cAltFrete  := GetMV("XX_ALTFRET",.F.,"")
    Local lRetOS     := .T.
    Local I          := 0

    Private cCadastro	 := "Pedido de Venda"	
    Private cMotivo      := ""
    Private aCols 		 := {}
    Private aHeader 	 := {}
    Private aCpoEnchoice := {}
    Private aAltEnchoice := {"C5_TIPLIB","C5_XFATURA","C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_MENPAD","C5_CONDPAG","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_PRCVEN","C6_CRVENT","C6_ENTREG"}  
    Private cCamposSC5	 := "C5_NUM|C5_CLIENTE|C5_LOJA|C5_XNOME|C5_TIPLIB|C5_XFATURA|C5_MENNOTA|C5_CRVOBS|C5_TRANSP|C5_TPFRETE|C5_MOEDA|C5_MENPAD|C5_CONDPAG|C5_XRESP|C5_XTPPED|C5_XFREQ|C5_XRECOR"
    Private cCamposSC6	 := "C6_PRCVEN|C6_VALOR|C6_XMOTPRC|C6_CRVENT|C6_ENTREG"
    Private cCamposSC6Prc := "C6_PRCVEN|C6_VALOR|C6_XMOTPRC"
    Private cCamposVld   := ""
    Private cTitulo      := "alterar"
    Private aButtons     := {}
    Private lAltPrc      := .F.
    Private aSx3Valid    := {}
    Private aColsSave    := {}
    // Fernando Pessoa - Tecsistem - 04/08/2026
    // Flags por linha: usuario editou C6_CRVENT / C6_ENTREG via U_LINPV2.
    Private aDtEditCRV   := {}
    Private aDtEditENT   := {}
    Private cPedido      := ""

    xSx3GravaValid("C5_CONDPAG", 'EXISTCPO("SE4",M->C5_CONDPAG)')
    xSx3GravaValid("C6_CRVENT", ".T.")
    xSx3GravaValid("C6_ENTREG", ".T.")

    //Verifico se o usu?rio possui permiss?o para alterar quantidade tamb?m al?m do pre?o unit?rio
    If !Empty(cAltPrc)

        If __cUserId $ cAltPrc

            lAltPrc      := .T.
            cCamposVld   := "C6_PRCVEN"
            aAltEnchoice := {"C5_TIPLIB","C5_XFATURA","C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_MENPAD","C5_CONDPAG","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_PRCVEN","C6_CRVENT","C6_ENTREG"}  
        
        Endif 

    Endif 
    // ---
	
	//Verifico se o usu?rio possui permiss?o para alterar o frete
    If !Empty(cAltFrete)

        If __cUserId $ cAltFrete

            aAltEnchoice := {"C5_TIPLIB","C5_XFATURA","C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_TRANSP","C5_TPFRETE","C5_MENPAD","C5_CONDPAG","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_CRVENT","C6_ENTREG"}  
        
        Endif 

    Endif 
    // ---

    lRetOS := .T.
    aOS    := {} 

    DBSELECTAREA("CB8")
    DBSETORDER(2) 
    DBSEEK(XFILIAL("CB8")+SC5->C5_NUM)
    DO WHILE !EOF() .AND. CB8->CB8_PEDIDO == SC5->C5_NUM .AND. CB8->CB8_FILIAL == XFILIAL("CB8")
      IF EMPTY(CB8->CB8_NOTA)
        //MSGSTOP("Pedido ["+CB8->CB8_PEDIDO+"], tem Ordem de Separacao pendente. Entre em contato com a Logistica.")
	    lRetOS := .F.
        EXIT
      ENDIF
      If Ascan( aOS, CB8->CB8_ORDSEP ) == 0
	 	 Aadd( aOS, CB8->CB8_ORDSEP )
	  Endif			
      DBSELECTAREA("CB8")
      DBSKIP()	
    ENDDO

    IF lRetOS
    
      FOR I:=1 TO LEN(aOS)
        DBSELECTAREA("CB8")
        DBSETORDER(1) 
        DBSEEK(XFILIAL("CB8")+aOS[I])
        DO WHILE !EOF() .AND. CB8->CB8_ORDSEP == aOS[I] .AND. CB8->CB8_FILIAL == XFILIAL("CB8")
          IF EMPTY(CB8->CB8_NOTA)
             //MSGSTOP("OS ["+CB8->CB8_ORDSEP+"] Pedido ["+CB8->CB8_PEDIDO+"], tem itens com Ordem de Separacao pendente."+chr(13)+chr(10)+" Entre em contato com a Logistica.")
	         lRetOS := .F.
             EXIT
          ENDIF
          DBSELECTAREA("CB8")
          DBSKIP()	  
        ENDDO
      NEXT I

    ENDIF 

    IF !lRetOS
     
       aAltEnchoice := {"C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_MENPAD","C5_CONDPAG","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_CRVENT","C6_ENTREG"}
 
       MSGSTOP("ATENCAO: Pedido "+SC5->C5_NUM+", tem Ordem de Separacao pendente, por isso apenas alguns campos podem ser alterados.")
    
    ENDIF

    DBSELECTAREA("SC5")

	If (Empty(cUsrId2) .Or. __cUserId $ cUsrId2) 
			
			// Verifica se o pedido j? est? liberado
			If  !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK == 'E' .And. Empty(SC5->C5_BLQ)

				MsgStop("Este pedido est? encerrado!")

			Else
            
				RegToMemory("SC5",.F.)
				RegToMemory("SC6",.F.)
			
				DefineCabec()
				DefineaCols(nOpcg)
				// Fernando Pessoa - Tecsistem - 04/08/2026
				// Flags de edicao de data por linha (marcadas em U_LINPV2).
				aDtEditCRV := Array(Len(aCols))
				aDtEditENT := Array(Len(aCols))
				AFill(aDtEditCRV, .F.)
				AFill(aDtEditENT, .F.)
				cPedido := SC5->C5_NUM
				
				lRet := Modelo3(cCadastro,"SC5","SC6",aCpoEnchoice,cLinok,cTudook,nOpce,nOpcg,cFieldok,lVirtual,Len(aCols),aAltenchoice,nFreeze,aButtons,,nAlturaEnc)
				
				//retornar? como true se clicar no botao confirmar
				If lRet

                    aColsSave := aClone(aCols)

					If MsgYesNo("Confirma a alteracao dos dados?", cCadastro)

                        If lAltPrc

                            cMotivo := FwInputBox("Informe o Motivo da Altera??o", cMotivo)

                            If !Empty(cMotivo)		

                                Processa({||Gravar()},cCadastro,"Alterando os dados, aguarde...")

                            Else 

                                MsgAlert("Favor informar o motivo da altera??o!","Aten??o")

                                For nX := 1 To 500

                                    If Empty(cMotivo)	

                                        If nX > 1
                                            MsgAlert("Favor informar o motivo da altera??o!","Aten??o")
                                        Endif 
                                        
                                        cMotivo := FwInputBox("Informe o Motivo da Altera??o", cMotivo)

                                    Else 

                                        Processa({||Gravar()},cCadastro,"Alterando os dados, aguarde...")

                                        Exit

                                    Endif 

                                Next nX 

                            Endif 

                        Else 
                            Processa({||Gravar()},cCadastro,"Alterando os dados, aguarde...")
                        Endif 
                    
                    Endif

				Else
					RollbackSx8()
				Endif
	
			Endif
		
	Else 
		MsgAlert("Favor acionar Fabiana Fonseca, Luciano Santos ou Caroline Medeiros, para acesso a esta rotina!","Aten??o")		
	Endif

    xSx3RestauraValid()

    DBSELECTAREA("SX3")
    DBSETORDER(1)
   
Return

/*=================================================================
Info: Grava validacao temporaria no SX3 para uso no Modelo3
*==================================================================*/
Static Function xSx3GravaValid(cCampo, cNovaValid)

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))

    If SX3->(DbSeek(cCampo))
        AAdd(aSx3Valid, {cCampo, SX3->X3_VALID})
        RecLock("SX3", .F.)
        SX3->X3_VALID := cNovaValid
        SX3->(MsUnlock())
    Endif

Return

/*=================================================================
Info: Restaura validacoes originais do SX3 alteradas na rotina
*==================================================================*/
Static Function xSx3RestauraValid()

    Local nI := 0

    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))

    For nI := 1 To Len(aSx3Valid)
        If SX3->(DbSeek(aSx3Valid[nI,1]))
            RecLock("SX3", .F.)
            SX3->X3_VALID := aSx3Valid[nI,2]
            SX3->(MsUnlock())
        Endif
    Next nI

    aSx3Valid := {}

Return   

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: Validacao de campos do grid (preco e datas)
-----------------------------------------------------------------------
06/07/2026 Fernando Pessoa - Tecsistem
- Validacao C6_CRVENT (>= dDatabase) e gravacao em aCols
04/08/2026 Fernando Pessoa - Tecsistem
- Marca aDtEditCRV/aDtEditENT ao editar datas (evita gravacao indevida)
- C6_CRVENT: bloqueia data menor que dDatabase com MsgAlert
*==================================================================*/ 
User Function LINPV2()

	Local cVar    := Upper(AllTrim(ReadVar()))
    Local nQtde   := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_QTDVEN"})
	Local nPrcVen := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_PRCVEN"})
	Local nTotal  := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_VALOR"})
	Local nCRVENT := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_CRVENT"})
	Local nENTREG := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_ENTREG"})
	Local lRet    := .T.

    If lAltPrc .And. "C6_PRCVEN" $ cVar

        lRet := .F.

        If nPrcVen > 0 .And. aCols[n][nPrcVen] <> M->C6_PRCVEN .And. "C6_PRCVEN" $ cCamposVld
            lRet := .T.
            aCols[n][nPrcVen] := M->C6_PRCVEN
            aCols[n][nTotal]  := aCols[n][nQtde] * M->C6_PRCVEN
        Endif

    // Fernando Pessoa - Tecsistem - 04/08/2026
    // Ricardo: Data p/faturamento alterada deve ser >= dDatabase.
    ElseIf "C6_CRVENT" $ cVar

        If !Empty(M->C6_CRVENT) .And. xToDate(M->C6_CRVENT) < dDatabase
            MsgAlert("Nao e possivel informar data menor que a data atual (" + DtoC(dDatabase) + ").", "Atencao")
            Return .F.
        Endif

        If nCRVENT > 0
            aCols[n][nCRVENT] := xToDate(M->C6_CRVENT)
            // Fernando Pessoa - Tecsistem - 04/08/2026
            // Marca edicao manual da data de faturamento nesta linha.
            If ValType(aDtEditCRV) == "A" .And. Len(aDtEditCRV) >= n
                aDtEditCRV[n] := .T.
            Endif
        Endif

        lRet := .T.

    // Fernando Pessoa - Tecsistem - 04/08/2026
    ElseIf "C6_ENTREG" $ cVar

        If nENTREG > 0
            aCols[n][nENTREG] := xToDate(M->C6_ENTREG)
            // Fernando Pessoa - Tecsistem - 04/08/2026
            // Marca edicao manual da data de entrega nesta linha.
            If ValType(aDtEditENT) == "A" .And. Len(aDtEditENT) >= n
                aDtEditENT[n] := .T.
            Endif
        Endif

        lRet := .T.

    Endif

Return(lRet)

/*=================================================================
Info: Sincroniza datas da linha atual do grid para o aCols (cLinok)
06/07/2026 Fernando Pessoa - Tecsistem
04/08/2026 Fernando Pessoa - Tecsistem - xSyncLinhaAcols so age se campo em edicao for data
*==================================================================*/
User Function CVF11LIN()

    xSyncLinhaAcols(n)

Return .T.

/*=================================================================
Info: Sincroniza datas do grid para o aCols antes de confirmar
06/07/2026 Fernando Pessoa - Tecsistem
04/08/2026 Fernando Pessoa - Tecsistem
- xSyncLinhaAcols so age se campo em edicao for data
- Valida C6_CRVENT alterada >= dDatabase antes de confirmar
*==================================================================*/
User Function CVF11TOK()

    Local nI
    Local nCRVENT := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_CRVENT"})
    Local dCRVENT := CtoD("")
    Local cItem   := ""
    Local nItem   := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_ITEM"})

    xSyncLinhaAcols(n)

    // Fernando Pessoa - Tecsistem - 04/08/2026
    // Confirma: se o usuario alterou Data p/faturamento, exige >= dDatabase.
    If nCRVENT > 0
        For nI := 1 To Len(aCols)
            If !(aCols[nI, Len(aHeader)+1]) .And. xDataEditada(nI, "C6_CRVENT")
                dCRVENT := xToDate(aCols[nI][nCRVENT])
                If !Empty(dCRVENT) .And. dCRVENT < dDatabase
                    cItem := IIf(nItem > 0, AllTrim(cValToChar(aCols[nI][nItem])), cValToChar(nI))
                    MsgAlert("Item " + cItem + ": nao e possivel informar data menor que a data atual (" + DtoC(dDatabase) + ").", "Atencao")
                    Return .F.
                Endif
            Endif
        Next nI
    Endif

    aColsSave := aClone(aCols)

Return .T.

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function DefineCabec() 

    Local cCampos := "C5_NUM|C5_CLIENTE|C5_LOJA|C5_XNOME|C5_TIPLIB|C5_XFATURA|C5_MENNOTA|C5_CRVOBS|C5_TRANSP|C5_TPFRETE|C5_MOEDA|C5_MENPAD|C5_CONDPAG|C5_XRESP|C5_XTPPED|C5_XFREQ|C5_XRECOR|C6_ITEM|C6_PRODUTO|C6_DESCRI|C6_UM|C6_QTDVEN|C6_PRCVEN|C6_VALOR|C6_XSTATUS|C6_CRVENT|C6_ENTREG|C6_DATFAT"
    Local cValid  := ""
    Local cTitCol := ""
    aHeader		 := {}
    aCpoEnchoice := {}
    
    //Monta a enchoice
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))	
    SX3->(DbSeek("SC5"))
	
    While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "SC5"
	
        If AllTrim(SX3->X3_CAMPO) $ cCampos
            aAdd(aCpoEnchoice,SX3->X3_CAMPO)
        Endif
		
        SX3->(DbSkip())
		
    EndDo

    //Monta o aHeader do grid conforme os campos definidos no array aSC6 (apenas os campos que deseja)
    //Caso contr?rio, se quiser todos os campos ? necess?rio trocar o "For" por While, para que este fa?a a leitura de toda a tabela
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    SX3->(DbSeek("SC6"))
	
    aHeader := {}     
	
    While !EOF() .And. SX3->X3_ARQUIVO == "SC6"
			
        If AllTrim(SX3->X3_CAMPO) $ cCampos   

            cTitCol := IIf(AllTrim(SX3->X3_CAMPO) == "C6_XSTATUS","Status",AllTrim(SX3->X3_TITULO))
            // Modelo3 usa GetSX3Cache quando a validacao do aHeader esta vazia
            cValid  := IIf(AllTrim(SX3->X3_CAMPO) $ "C6_CRVENT|C6_ENTREG", ".T.", "")

            aAdd(aHeader,{cTitCol,SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cValid,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,IIf(AllTrim(SX3->X3_CAMPO) == "C6_XSTATUS","V",SX3->X3_CONTEXT)})

        Endif 
		
        SX3->(DbSkip())
		
    EndDo
 
Return
 
/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: 
*==================================================================*/ 
Static function DefineaCols(nOpc)

    Local nQtdcpo 	:= 0
    Local i			:= 0
    Local nCols 	:= 0

    nQtdcpo 		:= Len(aHeader)
    aCols			:= {}
    
    DbSelectArea("SC6")
    SC6->(DbSetOrder(1))
	
    If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
	
		While !EOF() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM
		
			aAdd(aCols,array(nQtdcpo+1))
			
			nCols++
			
			For i := 1 To nQtdcpo
			
				If AllTrim(aHeader[i,2]) == "C6_XSTATUS"
					aCols[nCols,i] := xStaItemSC6()
				ElseIf aHeader[i,10] == "V" 
					aCols[nCols,i] := Fieldget(Fieldpos(aHeader[i,2]))
				Else
					aCols[nCols,i] := SC6->&(aHeader[i,2])
				Endif
				
			Next i
			
			aCols[nCols,nQtdcpo+1] := .F.
			
			DbSelectArea("SC6")
			SC6->(DbSkip())
			
		EndDo
	
	Endif 
	
Return

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 06/07/2026
Consultoria: Proativa
Uso: Calibre
Info: Retorna status do item conforme X3_RELACAO do campo C6_XSTATUS
*==================================================================*/
Static Function xStaItemSC6()

	Local cStatus := ""

	// SC6->(IF(INCLUI,'',(IF(C6_BLQ='R','ELIMINADO',IF(C6_QTDENT=C6_QTDVEN,'ENCERRADO',IF(C6_QTDENT<>C6_QTDVEN,'PENDENTE',''))))))
	If SC6->C6_BLQ == "R"
		cStatus := "ELIMINADO"
	ElseIf SC6->C6_QTDENT == SC6->C6_QTDVEN
		cStatus := "ENCERRADO"
	ElseIf SC6->C6_QTDENT <> SC6->C6_QTDVEN
		cStatus := "PENDENTE"
	Endif

Return cStatus

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: Gravacao SC5/SC6 e atualizacao SC9
-----------------------------------------------------------------------
06/07/2026 Fernando Pessoa - Tecsistem
- Gravacao C6_CRVENT/C6_ENTREG e atualizacao SC9
04/08/2026 Fernando Pessoa - Tecsistem
- SC5: grava somente campos liberados em aAltEnchoice
- SC6: grava datas somente se usuario editou via LINPV2 (aDtEdit*)
- C6_CRVENT alterada: bloqueia se < dDatabase
*==================================================================*/ 
Static Function Gravar()
    
    Local i         := 0
    Local nItem 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_ITEM"})
    Local nProduto 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_PRODUTO"})
    Local nCRVENT 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_CRVENT"})
    Local nENTREG 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_ENTREG"})
    Local nPosCpo
    Local nCpo
    Local nI
    Local cCampo
    Local cChave
    Local dCRVENT
    Local dENTREG
    Local dCRVOld
    Local dENTOld
    Local lGravaLin
    Local lAtuSC9
    Local aDados    := IIf(Len(aColsSave) > 0, aColsSave, aCols)

    // Fernando Pessoa - Tecsistem - 04/08/2026
    // Pre-validacao: Data p/faturamento alterada nao pode ser < dDatabase.
    If nCRVENT > 0
        For nI := 1 To Len(aDados)
            If !(aDados[nI, Len(aHeader)+1]) .And. xDataEditada(nI, "C6_CRVENT")
                dCRVENT := xToDate(aDados[nI][nCRVENT])
                If !Empty(dCRVENT) .And. dCRVENT < dDatabase
                    MsgAlert("Item " + AllTrim(cValToChar(aDados[nI,nItem])) + ": nao e possivel informar data menor que a data atual (" + DtoC(dDatabase) + ").", "Atencao")
                    Return
                Endif
            Endif
        Next nI
    Endif

    Begin Transaction

        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))

        If SC5->(DbSeek(xFilial("SC5")+cPedido))

            RecLock("SC5",.F.)

            For i := 1 To fCount()

                incproc()

                // Fernando Pessoa - Tecsistem - 04/08/2026
                // Grava somente campos liberados em aAltEnchoice (evita sobrescrever TRANSP etc.).
                If "FILIAL" $ FieldName(i)
                    FieldPut(i, xFilial("SC5"))
                ElseIf FieldName(i) $ cCamposSC5 .And. aScan(aAltEnchoice, {|x| AllTrim(Upper(x)) == AllTrim(Upper(FieldName(i)))}) > 0
                    FieldPut(i, M->&(FieldName(i)))
                Endif

            Next i

            SC5->(MsUnlock())

        Endif

        DbSelectArea("SC6")
        SC6->(DbSetOrder(1))

        For nI := 1 To Len(aDados)

            If !(aDados[nI, Len(aHeader)+1])

                cChave := xChaveSC6(nI, nItem, nProduto, aDados)

                If !SC6->(DbSeek(cChave))
                    SC6->(DbSeek(xFilial("SC6")+xFmtChave(cPedido,"C6_NUM")+xFmtChave(aDados[nI,nItem],"C6_ITEM")))
                    While SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. AllTrim(SC6->C6_NUM) == AllTrim(cPedido) .And. AllTrim(SC6->C6_ITEM) == AllTrim(cValToChar(aDados[nI,nItem]))
                        If AllTrim(SC6->C6_PRODUTO) == AllTrim(cValToChar(aDados[nI,nProduto]))
                            Exit
                        Endif
                        SC6->(DbSkip())
                    EndDo
                Endif

                If SC6->(!Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. AllTrim(SC6->C6_NUM) == AllTrim(cPedido) .And. AllTrim(SC6->C6_ITEM) == AllTrim(cValToChar(aDados[nI,nItem])) .And. AllTrim(SC6->C6_PRODUTO) == AllTrim(cValToChar(aDados[nI,nProduto]))

                    lGravaLin := .F.
                    lAtuSC9   := .F.
                    dCRVENT   := xToDate(IIf(nCRVENT > 0, aDados[nI,nCRVENT], SC6->C6_CRVENT))
                    dENTREG   := xToDate(IIf(nENTREG > 0, aDados[nI,nENTREG], SC6->C6_ENTREG))
                    dCRVOld   := SC6->C6_CRVENT
                    dENTOld   := SC6->C6_ENTREG

                    // Fernando Pessoa - Tecsistem - 04/08/2026
                    // So grava data se o usuario editou o campo na linha (aDtEdit*).
                    //If nCRVENT > 0 .And. ( ( !xCmpCampo(dCRVENT, dCRVOld) .And. xDataEditada(nI, "C6_CRVENT") ) .Or. SC6->C6_CRVENT <> dCRVENT ) 
                    // Aldo - Tecsistem - 25/10/26
                    // caso a linha tenha sido editada manualmente ou se houve a alteração utilizando a opção de gravar todos seguintes 
                    If nCRVENT > 0 .And. ( ( !xCmpCampo(dCRVENT, dCRVOld) .And. xDataEditada(nI, "C6_CRVENT") ) .Or. SC6->C6_CRVENT <> dCRVENT ) 
                        lGravaLin := .T.
                        lAtuSC9   := .T.
                    Else
                        dCRVENT := dCRVOld
                    Endif

                    If nENTREG > 0 .And. !xCmpCampo(dENTREG, dENTOld) .And. xDataEditada(nI, "C6_ENTREG")
                        lGravaLin := .T.
                        lAtuSC9   := .T.
                    Else
                        dENTREG := dENTOld
                    Endif

                    If lAltPrc

                        For nCpo := 1 To fCount()

                            cCampo := AllTrim(FieldName(nCpo))

                            If cCampo $ cCamposSC6Prc

                                nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == cCampo})

                                If nPosCpo > 0 .And. !xCmpCampo(aDados[nI,nPosCpo], SC6->&(cCampo))
                                    lGravaLin := .T.
                                Endif

                            Endif

                        Next nCpo

                    Endif

                    If lGravaLin

                        RecLock("SC6",.F.)

                        If nCRVENT > 0
                            SC6->C6_CRVENT := dCRVENT
                        Endif

                        If nENTREG > 0
                            SC6->C6_ENTREG := dENTREG
                        Endif

                        If lAltPrc

                            For nCpo := 1 To fCount()

                                cCampo := AllTrim(FieldName(nCpo))

                                If cCampo $ cCamposSC6Prc

                                    nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == cCampo})

                                    If nPosCpo > 0
                                        If cCampo == "C6_XMOTPRC"
                                            FieldPut(nCpo, cMotivo)
                                        Else
                                            FieldPut(nCpo, aDados[nI,nPosCpo])
                                        Endif
                                    Endif

                                Endif

                            Next nCpo

                        Endif

                        SC6->(MsUnlock())

                        If lAtuSC9
                            xAtuSC9Linha(aDados[nI,nItem], aDados[nI,nProduto], dCRVENT, dENTREG)
                        Endif

                    Endif

                Endif

            Endif

        Next nI

        DbSelectArea("SC5")

    End Transaction

    xAtuSC9()

Return

/*=================================================================
Info: Sincroniza C6_CRVENT e C6_ENTREG de uma linha do grid para aCols
-----------------------------------------------------------------------
06/07/2026 Fernando Pessoa - Tecsistem - Criacao
04/08/2026 Fernando Pessoa - Tecsistem
- So sincroniza quando o campo em edicao e data (via ReadVar)
- Evita sobrescrever datas ao confirmar apenas alteracao de cabecalho (ex.: Fatura?)
*==================================================================*/
Static Function xSyncLinhaAcols(nLin)

    Local nCRVENT := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_CRVENT"})
    Local nENTREG := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_ENTREG"})
    Local cVar    := ""

    If ValType(nLin) <> "N" .Or. nLin < 1 .Or. nLin > Len(aCols)
        Return
    Endif

    cVar := Upper(AllTrim(ReadVar()))

    // Sem campo de data em edicao: nao toca no aCols (U_LINPV2 ja atualiza na digitacao).
    If !("C6_CRVENT" $ cVar) .And. !("C6_ENTREG" $ cVar)
        Return
    Endif

    If "C6_CRVENT" $ cVar .And. nCRVENT > 0
        aCols[nLin][nCRVENT] := xToDate(M->C6_CRVENT)
    Endif

    If "C6_ENTREG" $ cVar .And. nENTREG > 0
        aCols[nLin][nENTREG] := xToDate(M->C6_ENTREG)
    Endif

Return

/*=================================================================
Info: Indica se o usuario editou a data da linha via U_LINPV2
04/08/2026 Fernando Pessoa - Tecsistem
*==================================================================*/
Static Function xDataEditada(nLin, cCampo)

    Local lEdit := .F.

    Default cCampo := ""

    If nLin < 1
        Return .F.
    Endif

    If Upper(AllTrim(cCampo)) == "C6_CRVENT"
        If ValType(aDtEditCRV) == "A" .And. Len(aDtEditCRV) >= nLin
            lEdit := aDtEditCRV[nLin]
        Endif
    ElseIf Upper(AllTrim(cCampo)) == "C6_ENTREG"
        If ValType(aDtEditENT) == "A" .And. Len(aDtEditENT) >= nLin
            lEdit := aDtEditENT[nLin]
        Endif
    Endif

Return lEdit

/*=================================================================
Info: Converte valor para data
*==================================================================*/
Static Function xToDate(xVal)

    Local dRet := CtoD("")

    If ValType(xVal) == "D"
        dRet := xVal
    ElseIf ValType(xVal) == "C" .And. !Empty(xVal)
        If "/" $ xVal
            dRet := CtoD(xVal)
        Else
            dRet := SToD(xVal)
        Endif
    ElseIf ValType(xVal) == "N" .And. !Empty(xVal)
        dRet := SToD(cValToChar(xVal))
    Endif

Return dRet

/*=================================================================
Info: Formata chave de item/produto conforme SX3
*==================================================================*/
Static Function xFmtChave(xVal, cCampo)

    Local cRet  := ""
    Local nTam  := TamSX3(cCampo)[1]
    Local cTipo := TamSX3(cCampo)[3]

    If cTipo == "N"
        cRet := StrZero(Val(cValToChar(xVal)), nTam)
    Else
        cRet := PadR(AllTrim(cValToChar(xVal)), nTam)
    Endif

Return cRet

/*=================================================================
Info: Compara valores do grid com a SC6 considerando tipo do campo
*==================================================================*/
Static Function xCmpCampo(xVal1, xVal2)

    Local lIgual := .F.

    If ValType(xVal1) == "D" .Or. ValType(xVal2) == "D" .Or. (ValType(xVal1) == "C" .And. "/" $ cValToChar(xVal1)) .Or. (ValType(xVal2) == "C" .And. "/" $ cValToChar(xVal2))
        lIgual := DtoS(xToDate(xVal1)) == DtoS(xToDate(xVal2))
    ElseIf ValType(xVal1) == "N" .Or. ValType(xVal2) == "N"
        lIgual := (xVal1 == xVal2)
    Else
        lIgual := (AllTrim(cValToChar(xVal1)) == AllTrim(cValToChar(xVal2)))
    Endif

Return lIgual

/*=================================================================
Info: Monta chave de busca do item na SC6
*==================================================================*/
Static Function xChaveSC6(nLin, nItem, nProduto, aDados)

    Local cChave := ""

    If aDados == Nil
        aDados := aCols
    Endif

    cChave := xFilial("SC6")
    cChave += xFmtChave(cPedido, "C6_NUM")
    cChave += xFmtChave(aDados[nLin][nItem], "C6_ITEM")
    cChave += xFmtChave(aDados[nLin][nProduto], "C6_PRODUTO")

Return cChave

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 22/08/2025
Consultoria: Proativa
Uso: Calibre
Info: Atualiza C9_CRVENT e C9_DATENT na SC9 conforme item do pedido
*==================================================================*/
Static Function xAtuSC9Linha(cItem, cProduto, dCRVENT, dENTREG)

    Local cItemKey := AllTrim(xFmtChave(cItem, "C6_ITEM"))
    Local cProdKey := AllTrim(xFmtChave(cProduto, "C6_PRODUTO"))

    DbSelectArea("SC9")
    SC9->(DbSetOrder(1))

    If SC9->(DbSeek(xFilial("SC9") + xFmtChave(cPedido, "C6_NUM")))

        While SC9->(!Eof()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. AllTrim(SC9->C9_PEDIDO) == AllTrim(cPedido)

            If AllTrim(SC9->C9_ITEM) == cItemKey .And. AllTrim(SC9->C9_PRODUTO) == cProdKey

                If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_SERIENF)

                    RecLock("SC9", .F.)
                    SC9->C9_CRVENT := dCRVENT
                    SC9->C9_DATENT := dENTREG
                    SC9->(MsUnlock())

                Endif

            Endif

            SC9->(DbSkip())

        EndDo

    Endif

Return

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 22/08/2025
Consultoria: Proativa
Uso: Calibre
Info: Atualiza a tabela SC9
*==================================================================*/
Static Function xAtuSC9()

	Local cUpdate   := ""
	Local cAliasSC9 := RetSQLName("SC9") 
    Local nErro     := 0

    //Atualizo o campo C9_PRCVEN
	cUpdate += " UPDATE "+cAliasSC9
	cUpdate += " SET C9_PRCVEN = ("
	cUpdate += "    SELECT C6_PRCVEN"
	cUpdate += "    FROM "+RetSQLName("SC6")
	cUpdate += "    WHERE" 
	cUpdate += "        C6_FILIAL = "+cAliasSC9+".C9_FILIAL"
	cUpdate += "        AND C6_NUM = "+cAliasSC9+".C9_PEDIDO"
	cUpdate += "        AND C6_ITEM = "+cAliasSC9+".C9_ITEM"
	cUpdate += "        AND C6_PRODUTO = "+cAliasSC9+".C9_PRODUTO"
	cUpdate += "        AND D_E_L_E_T_ <> '*'"
	cUpdate += " )"
	cUpdate += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
	cUpdate += "  AND C9_PEDIDO = '"+cPedido+"'"
	cUpdate += "  AND C9_NFISCAL = ''"
	cUpdate += "  AND C9_SERIENF = ''"
	cUpdate += "  AND C9_PRCVEN <> ("
	cUpdate += "      SELECT C6_PRCVEN"
	cUpdate += "      FROM "+RetSQLName("SC6")
	cUpdate += "      WHERE" 
	cUpdate += "          C6_FILIAL = "+cAliasSC9+".C9_FILIAL"
	cUpdate += "          AND C6_NUM = "+cAliasSC9+".C9_PEDIDO"
	cUpdate += "          AND C6_ITEM = "+cAliasSC9+".C9_ITEM"
	cUpdate += "          AND C6_PRODUTO = "+cAliasSC9+".C9_PRODUTO"
	cUpdate += "          AND D_E_L_E_T_ <> '*'"
	cUpdate += "  )"
	cUpdate += "AND D_E_L_E_T_ <> '*'"

    nErro := TcSqlExec(cUpdate)

	If nErro == 0	
		cUpdate := "COMMIT"		
		TcSqlExec(cUpdate)
	Else	
		cUpdate := "ROLLBACK"		
		TcSqlExec(cUpdate)
	Endif 
    // ---

    //Atualizo C9_CRVENT e C9_DATENT a partir da SC6 (todas as sequencias do item)
	cUpdate := " UPDATE "+cAliasSC9
	cUpdate += " SET C9_CRVENT = ("
	cUpdate += "    SELECT C6_CRVENT"
	cUpdate += "    FROM "+RetSQLName("SC6")
	cUpdate += "    WHERE"
	cUpdate += "        C6_FILIAL = "+cAliasSC9+".C9_FILIAL"
	cUpdate += "        AND C6_NUM = "+cAliasSC9+".C9_PEDIDO"
	cUpdate += "        AND C6_ITEM = "+cAliasSC9+".C9_ITEM"
	cUpdate += "        AND C6_PRODUTO = "+cAliasSC9+".C9_PRODUTO"
	cUpdate += "        AND D_E_L_E_T_ <> '*'"
	cUpdate += " ),"
	cUpdate += " C9_DATENT = ("
	cUpdate += "    SELECT C6_ENTREG"
	cUpdate += "    FROM "+RetSQLName("SC6")
	cUpdate += "    WHERE"
	cUpdate += "        C6_FILIAL = "+cAliasSC9+".C9_FILIAL"
	cUpdate += "        AND C6_NUM = "+cAliasSC9+".C9_PEDIDO"
	cUpdate += "        AND C6_ITEM = "+cAliasSC9+".C9_ITEM"
	cUpdate += "        AND C6_PRODUTO = "+cAliasSC9+".C9_PRODUTO"
	cUpdate += "        AND D_E_L_E_T_ <> '*'"
	cUpdate += " )"
	cUpdate += " WHERE C9_FILIAL = '"+xFilial("SC9")+"'"
	cUpdate += "  AND C9_PEDIDO = '"+cPedido+"'"
	cUpdate += "  AND C9_NFISCAL = ''"
	cUpdate += "  AND C9_SERIENF = ''"
	cUpdate += "  AND D_E_L_E_T_ <> '*'"

    nErro := TcSqlExec(cUpdate)

	If nErro == 0
		TcSqlExec("COMMIT")
	Else
		TcSqlExec("ROLLBACK")
	Endif
    // ---

    //Atualizo o campo C9_XFATURA
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    SC5->(DbSeek(xFilial("SC5")+cPedido))

    DbSelectArea("SC9")
    SC9->(DbGoTop())
    SC9->(DbSetOrder(1))

    If SC9->(DbSeek(xFilial("SC9")+xFmtChave(cPedido,"C6_NUM")))

        While !SC9->(EOF()) .And. SC9->C9_FILIAL == xFilial("SC9") .And. AllTrim(SC9->C9_PEDIDO) == AllTrim(cPedido)

            If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_SERIENF)

                RecLock("SC9",.F.)
                SC9->C9_XFATURA := SC5->C5_XFATURA
                SC9->(MsUnlock())

            Endif 

            SC9->(DbSkip())

        EndDo 

    Endif 
    // ---

Return
