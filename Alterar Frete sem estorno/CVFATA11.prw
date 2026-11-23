#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOPCONN.ch'
#Include 'RwMake.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: 
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: CVFATA11
Info: Alteração de Pedido de Vendas 
************************************************************************/
User Function CVFATA11() 

    Local cLinok 	 := "Allwaystrue"
    Local cTudook 	 := "Allwaystrue"
    Local nOpce 	 := 4 	//define modo de alteração para a enchoice
    Local nOpcg 	 := 4 	//define modo de alteração para o grid
    Local nX         := 0
    Local cFieldok 	 := "U_LINPV2()"
    Local lRet 		 := .T.
    Local lVirtual   := .T. //Mostra campos virtuais se houver
    Local nFreeze	 := 0	
    Local nAlturaEnc := 200	//Altura da Enchoice
	Local cUsrId2    := GetMV("XX_USRROT2",.F.,"")
    Local cAltPrc    := GetMV("XX_ALTPRC",.F.,"")
	Local cAltFrete  := GetMV("XX_ALTFRET",.F.,"")

    Private cCadastro	 := "Pedido de Venda"	
    Private cMotivo      := ""
    Private aCols 		 := {}
    Private aHeader 	 := {}
    Private aCpoEnchoice := {}
    Private aAltEnchoice := {"C5_TIPLIB","C5_XFATURA","C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_MENPAD","C5_CONDPAG","C5_XAGLOC","C5_XACFAT","C5_XLIMFAT","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_PRCVEN"}  
    Private cCamposSC5	 := "C5_NUM|C5_CLIENTE|C5_LOJA|C5_XNOME|C5_TIPLIB|C5_XFATURA|C5_MENNOTA|C5_CRVOBS|C5_TRANSP|C5_TPFRETE|C5_MOEDA|C5_MENPAD|C5_CONDPAG|C5_XAGLOC|C5_XACFAT|C5_XLIMFAT|C5_XRESP|C5_XTPPED|C5_XFREQ|C5_XRECOR"
    Private cCamposSC6	 := "C6_PRCVEN|C6_VALOR|C6_XMOTPRC"
    Private cCamposVld   := ""
    Private cTitulo      := "alterar"
    Private aButtons     := {}
    Private lAltPrc      := .F.

    //Verifico se o usuário possui permissão para alterar quantidade também além do preço unitário
    If !Empty(cAltPrc)

        If __cUserId $ cAltPrc

            lAltPrc      := .T.
            cCamposVld   := "C6_PRCVEN"
            aAltEnchoice := {"C5_TIPLIB","C5_XFATURA","C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_MENPAD","C5_CONDPAG","C5_XAGLOC","C5_XACFAT","C5_XLIMFAT","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_PRCVEN"}  
        
        Endif 

    Endif 
    // ---
	
	//Verifico se o usuário possui permissão para alterar o frete
    If !Empty(cAltFrete)

        If __cUserId $ cAltFrete

            aAltEnchoice := {"C5_TIPLIB","C5_XFATURA","C5_MENNOTA","C5_CRVOBS","C5_MOEDA","C5_TRANSP","C5_TPFRETE","C5_MENPAD","C5_CONDPAG","C5_XAGLOC","C5_XACFAT","C5_XLIMFAT","C5_XRESP","C5_XTPPED","C5_XFREQ","C5_XRECOR","C6_PRCVEN"}  
        
        Endif 

    Endif 
    // ---
	
	If Empty(cUsrId2) .Or. __cUserId $ cUsrId2
			
			// Verifica se o pedido já está liberado
			//If !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK == 'E' .And. Empty(SC5->C5_BLQ)

				//MsgStop("Este pedido está encerrado!")

			//Else
            
				RegToMemory("SC5",.F.)
				RegToMemory("SC6",.F.)
			
				DefineCabec()
				DefineaCols(nOpcg)
				
				lRet := Modelo3(cCadastro,"SC5","SC6",aCpoEnchoice,cLinok,cTudook,nOpce,nOpcg,cFieldok,lVirtual,Len(aCols),aAltenchoice,nFreeze,aButtons,,nAlturaEnc)
				
				//retornará como true se clicar no botao confirmar
				If lRet

					If MsgYesNo("Confirma a alteração dos dados?", cCadastro)

                        If lAltPrc

                            cMotivo := FwInputBox("Informe o Motivo da Alteração", cMotivo)

                            If !Empty(cMotivo)		

                                Processa({||Gravar()},cCadastro,"Alterando os dados, aguarde...")

                            Else 

                                MsgAlert("Favor informar o motivo da alteração!","Atenção")

                                For nX := 1 To 500

                                    If Empty(cMotivo)	

                                        If nX > 1
                                            MsgAlert("Favor informar o motivo da alteração!","Atenção")
                                        Endif 
                                        
                                        cMotivo := FwInputBox("Informe o Motivo da Alteração", cMotivo)

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
	
			//Endif
		
	Else 
		MsgAlert("Favor acionar o Luciano ou a Caroline para acesso a esta rotina!","Atenção")		
	Endif 

Return   

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: 
*==================================================================*/ 
User Function LINPV2()

	Local cCPOM   := AllTrim(SubStr(ReadVar(),4))
    Local nQtde   := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_QTDVEN"})
	Local nPrcVen := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_PRCVEN"})
	Local nTotal  := aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_VALOR"}) 
	Local lRet    := .F.

    If lAltPrc

        If aCols[n][nPrcVen] <> M->C6_PRCVEN

            If AllTrim(cCPOM) $ cCamposVld  

                lRet := .T.

                aCols[n][nPrcVen] := M->C6_PRCVEN
                aCols[n][nTotal]  := aCols[n][nQtde] * M->C6_PRCVEN

            Endif 

        Endif 

    Endif 

Return(lRet)

/*=================================================================
Autor: Vinicius N. de Oliveira 
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function DefineCabec() 

    Local cCampos := "C5_NUM|C5_CLIENTE|C5_LOJA|C5_XNOME|C5_TIPLIB|C5_XFATURA|C5_MENNOTA|C5_CRVOBS|C5_TRANSP|C5_TPFRETE|C5_MOEDA|C5_MENPAD|C5_CONDPAG|C5_XAGLOC|C5_XACFAT|C5_XLIMFAT|C5_XRESP|C5_XTPPED|C5_XFREQ|C5_XRECOR|C6_ITEM|C6_PRODUTO|C6_DESCRI|C6_QTDVEN|C6_PRCVEN|C6_VALOR"
	  
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
    //Caso contrário, se quiser todos os campos é necessário trocar o "For" por While, para que este faça a leitura de toda a tabela
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    SX3->(DbSeek("SC6"))
	
    aHeader := {}     
	
    While !EOF() .And. SX3->X3_ARQUIVO == "SC6"
			
        If AllTrim(SX3->X3_CAMPO) $ cCampos   
		
            aAdd(aHeader,{AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT})

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
			
				If aHeader[i,10] == "V" 
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
Data: 18/07/2025
Consultoria: Proativa
Uso: Calibre
Info: 
*==================================================================*/ 
Static Function Gravar()
    
    Local i         := 0
    Local nItem 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_ITEM"})
    Local nProduto 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2])) == "C6_PRODUTO"})
    Local nPosCpo
    Local nCpo
    Local nI
    
    Begin Transaction
    
        //Gravando dados da enchoice
        DbSelectArea("SC5")
        Reclock("SC5",.F.)
		
        For i := 1 To fcount()
		
            incproc()
			
            If "FILIAL" $ FieldName(i)
			
                Fieldput(i,xFilial("SC5"))
				
            Else
                //Grava apenas os campos contidos na variavel cCamposSC5
                If (FieldName(i) $ cCamposSC5)
                    Fieldput(i,M->&(FieldName(i)))
                Endif
				
            Endif
			
        Next i		
		
        SC5->(MsUnlock())
		
		If lAltPrc
    
			//Gravando dados do grid
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			
			For nI := 1 To Len(aCols)
			
				If !(aCols[nI, Len(aHeader)+1])
				
					If SC6->(DbSeek( xFilial("SC6")+M->C5_NUM+aCols[nI,nItem]+aCols[nI,nProduto]))
					
						RecLock("SC6",.F.)
						
						For nCpo := 1 to fCount()
						
							//Grava apenas os campos contidos na variavel $cCamposSC6
							If (FieldName(nCpo)$cCamposSC6)
								
								nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(FieldName(nCpo))})
								
								If nPosCpo >= 0
	
									If AllTrim(FieldName(nCpo)) == "C6_XMOTPRC"
										FieldPut(nCpo,cMotivo)
									Else 
										FieldPut(nCpo,aCols[nI,nPosCpo])
									Endif 
										
								Endif
								
							Endif
							
						Next nCpo
						
						SC6->(MsUnLock())
						
					Endif
					
				Endif
				
			Next nI 

		Endif 
          
        DbSelectArea("SC5")
        
    End Transaction 

    xAtuSC9()   
    
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
	cUpdate += " WHERE C9_FILIAL = '"+SC5->C5_FILIAL+"'"
	cUpdate += "  AND C9_PEDIDO = '"+SC5->C5_NUM+"'"
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

    //Atualizo o campo C9_XFATURA
    DbSelectArea("SC9")
    SC9->(DbGoTop())
    SC9->(DbSetOrder(1))

    If SC9->(DbSeek(SC5->C5_FILIAL + SC5->C5_NUM))

        While !SC9->(EOF()) .And. (AllTrim(SC9->C9_FILIAL) + AllTrim(SC9->C9_PEDIDO) == AllTrim(SC5->C5_FILIAL) + AllTrim(SC5->C5_NUM))

            If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_NFISCAL)

                RecLock("SC9",.F.)
                SC9->C9_XFATURA := SC5->C5_XFATURA
                SC9->(MsUnlock())

            Endif 

            SC9->(DbSkip())

        EndDo 

    Endif 
    // ---

Return
