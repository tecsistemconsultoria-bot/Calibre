//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
  
//Posições do Array
Static nPosFil    := 1 //Coluna A no Excel
Static nPosCli    := 2 //Coluna B no Excel
Static nPosLoja   := 3 //Coluna C no Excel
Static nPosProdut := 4 //Coluna D no Excel
Static nPosQuant  := 5 //Coluna E no Excel
Static nPosOper   := 6 //Coluna F no Excel
Static nPosDtFat  := 7 //Coluna G no Excel
Static nPosDtEnt  := 8 //Coluna H no Excel
  
/*=================================================================
Autor: Otávio Barreiro
Data: 21/10/2025
Consultoria: 
Uso: Calibre
Função:CVFATA15
Info: Função para importar orçamento via csv
*==================================================================*/
User Function CVFATA15()

    Local aArea     := GetArea()

    Private cArqOri  := ""
    Private cPasta   := AllTrim(GetMV("XX_XARQUI",.F.,"C:\temp\"))
    Private cData    := StrTran(DToS(Date()),"/","")
    Private cHora    := StrTran(Time(),":","")
    Private cDtHora  := AllTrim(cData+"_"+cHora)
    Private cNomeado := "Log_Orcamento_"+cDtHora+".txt"
    Private cLog     := ""
    
    //Mostra o Prompt para selecionar arquivos
    //cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )
    cArqOri := cGetFile("CSV files (*.csv)|*.csv", "Selecione o arquivo CSV", 0, "", .F., GETF_LOCALHARD + GETF_NETWORKDRIVE)
      
    //Se tiver o arquivo de origem
    If ! Empty(cArqOri)
          
        //Somente se existir o arquivo e for com a extensão CSV
        If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
		
            Processa({|| fImporta() }, "Importando...")
			
        Else
			
            MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
			
        EndIf
		
    EndIf
      
    RestArea(aArea)
	
Return
  
/*=================================================================
Autor: Otávio Barreiro
Data: 21/10/2025
Consultoria: 
Uso: Calibre
Info: Função para importar orçamento via csv
*==================================================================*/
Static Function fImporta()

    Local aArea      := GetArea()
    Local cCli       := ""
	Local cLoja      := ""
    Local cProdut    := ""
    Local cOper      := ""
    Local cDtFat     := ""
    Local cDtEnt     := ""
    Local cLinAtu    := ""
    Local cFil    := ""
    Local nTotLinhas := 0
    Local nLinhaAtu  := 0
    Local nQuant     := 0
	Local oArquivo   := Nil
    Local aLinha     := {}
    Local aLinhas    := {}
	Local aProdutos  := {}
    Local nQtdeLin   := Getmv("XX_QTDELIN",.F.,2) //Quantidade mínima de linhas permitidas no orçamento

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
      
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
  
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
  
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
              
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()
            oArquivo:GetLine() // Ignora a primeira linha

            //Enquanto tiver linhas
            While (oArquivo:HasLine())
  
                //Incrementa na tela a mensagem
                nLinhaAtu++
				
				If nLinhaAtu > 1
				
					IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
					  
					//Pegando a linha atual e transformando em array
					cLinAtu := oArquivo:GetLine()
					aLinha  := StrTokArr(cLinAtu, ";")
                  
                        cFil   := aLinha[nPosFil]
                        cCli      := aLinha[nPosCli]
                        cLoja     := aLinha[nPosLoja]
                        cProdut   := aLinha[nPosProdut]
                        nQuant    := Val(aLinha[nPosQuant])
                        cOper     := aLinha[nPosOper]
                        cDtFat    := aLinha[nPosDtFat]
                        cDtEnt    := aLinha[nPosDtEnt]		
					
					//Itens - Grid
                    aAdd(aProdutos,{cProdut,nQuant,cOper,cDtFat,cDtEnt})
					//---
                      
                EndIf
                  
            EndDo
			
			If Len(aProdutos) >= nQtdeLin
			
				IncProc("Incluindo orçamento...")
			
				xIncOrc(aProdutos,cCli,cLoja,cFil) //Inclusão do orçamento via execauto		
			
			Else 
				
				FWAlertError("Arquivo não tem conteúdo suficiente!")	
				
			EndIf 
            
        EndIf

    If !Empty(cLog)

        MemoWrite(cPasta+cNomeado,cLog)		
        ShellExecute("Open",cPasta+cNomeado,"","",5) //Abertura da pasta local onde consta o arquivo de log de importação
        FWAlertSuccess("Orçamento Criado com Sucesso Númmero: "+cValToChar(SCJ->CJ_NUM))       
    Endif
        
        //Fecha o arquivo
        oArquivo:Close()
		
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
  
    RestArea(aArea)
	
Return

/*=================================================================
Autor: Otávio Barreiro
Data: 21/10/2025
Consultoria: 
Uso: Calibre
Info: Incluir Orçamento
*==================================================================*/
Static Function xIncOrc(aProdutos,cCli,cLoja,cFil)	

	Local aCabec := {}
	Local aItens := {}
	Local aDados := {}
	Local nX     := 0
    Local cChave     := ""
	cLog += CRLF +"-------------------Log_Orçamento---------------------"+ CRLF + CRLF
    
    cFilAnt:= cFil

	Private lMsErroAuto := .F.
	
	//cDoc := GetSxeNum("SCJ","CJ_NUM") |Pego pelo inicialziador padrão execauto,  Essa linha fazia com que o código pulasse de 2 em 2
	//aAdd(aCabec,{"CJ_NUM"   ,cDoc,Nil})
    
    aAdd(aCabec,{"CJ_CLIENTE",StrZero(Val(cCli),6),Nil})

    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) // Índice: A1_COD
    
    SA1->(DbSeek(xFilial("SA1")+cCli+cLoja))

    If Empty(SA1->A1_LOJA)
        aAdd(aCabec,{"CJ_LOJACLI",StrZero(Val(cLoja),2),Nil})
        cLog += CRLF+"Loja do Cliente não informada no cadastro do cliente, utilizando a Loja cadastrada na planilha: "+StrZero(Val(cLoja),2)+CRLF

    ElseIf AllTrim(SA1->A1_LOJA) <> StrZero(Val(cLoja),2)
        cLog += CRLF+"Atenção: Loja do Cliente informada no cadastro do cliente é diferente da Loja cadastrada na planilha. Loja do Cadastro: "+SA1->A1_LOJA+" | Loja da Planilha: "+StrZero(Val(cLoja),2)+" INCONSISTÊNCIA!!!!"+CRLF
    EndIf

    If Empty(SA1->A1_COD)
        aAdd(aCabec,{"CJ_CLIENT",StrZero(Val(cCli),6),Nil})
        cLog += CRLF+"Cliente de Entrega não informada no cadastro do cliente, utilizando o Cliente cadastrada na planilha: "+StrZero(Val(cCli),6)+CRLF
    
    ElseIf AllTrim(SA1->A1_COD) <> StrZero(Val(cCli),6)
        cLog += CRLF+"Atenção: Cliente de Entrega informada no cadastro do cliente é diferente do Cliente cadastrado na planilha. Cliente do Cadastro: "+SA1->A1_COD+" | Cliente da Planilha: "+StrZero(Val(cCli),6)+" INCONSISTÊNCIA!!!!"+CRLF
    EndIf

    If Empty(SA1->A1_LOJA)
        aAdd(aCabec,{"CJ_LOJAENT",StrZero(Val(cLoja),2),Nil})
        cLog += CRLF+"Loja de Entrega não informada no cadastro do cliente, utilizando a Loja cadastrada na planilha: "+StrZero(Val(cLoja),2)+CRLF  
    
    ElseIf AllTrim(SA1->A1_LOJA) <> StrZero(Val(cLoja),2)
        cLog += CRLF+"Atenção: Loja de Entrega informada no cadastro do cliente é diferente da Loja cadastrada na planilha. Loja do Cadastro: "+SA1->A1_LOJA+" | Loja da Planilha: "+StrZero(Val(cLoja),2)+" INCONSISTÊNCIA!!!!"+CRLF 
    EndIf
	
    DbSelectArea("DA1")	
    DA1->(DbSetOrder(1))

	For nX := 1 To Len(aProdutos)
	
        aDados := {}

		aAdd(aDados,{"CK_FILIAL",cFilAnt,Nil})
        aAdd(aDados,{"CK_ITEM",StrZero(nX,2),Nil})
        aAdd(aDados,{"CK_PRODUTO",aProdutos[nX,1],Nil})
        aAdd(aDados,{"CK_OPER",aProdutos[nX,3],Nil})
        aAdd(aDados,{"CK_QTDVEN",aProdutos[nX,2],Nil})

        If !DA1->(DbSeek(xFilial("DA1")+SA1->A1_TABELA+aProdutos[nX,1]))
            aAdd(aDados,{"CK_PRCVEN",0.01,Nil})
            aAdd(aDados,{"CK_PRUNIT",0.01,Nil})
        EndIf

        aAdd(aDados,{"CK_XDTFAT",Ctod(aProdutos[nX,4]),Nil})
        aAdd(aDados,{"CK_ENTREG",Ctod(aProdutos[nX,5]),Nil})
        aAdd(aDados,{"CK_XIMPCSV","S",Nil}) //Indica que o item foi importado via CSV
		
        aAdd(aItens,aDados)
		
    Next nX

	//MATA415(aCabec,aItens,3)
	MSExecAuto({|x, y, z| MATA415(x, y, z)}, aCabec, aItens, 3)
    
	If !lMsErroAuto

        cChave := xFilial("SCJ")+cCli+cLoja+DTOS(CJ_EMISSAO)

        DbSelectArea("SCJ")
        DbSetOrder(3) // índice: CJ_FILIAL + CJ_NUM +CJ_EMISSAO

        SCJ->(DbSeek(cChave))

        // Enquanto não for fim de arquivo E a chave continuar sendo a mesma
        While !SCJ->(Eof()) .And. (SCJ->CJ_FILIAL + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA + DTOS(SCJ->CJ_EMISSAO)) == cChave
            SCJ->(DbSkip())
        EndDo
    
        // Como o While parou no primeiro registro Diferente, voltamos um para o último Igual
        SCJ->(DbSkip(-1))
	
		cLog += CRLF+ "Orçamento incluido com Sucesso Númmero: "+cValToChar(SCJ->CJ_NUM)+CRLF

		ConfirmSx8()
    Else
		
		MostraErro()
		
		cLog += CRLF+ "Erro ao incluir Orçamento"+CRLF

		RollbackSx8()
    EndIf

Return
