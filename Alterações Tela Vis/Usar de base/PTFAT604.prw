#INCLUDE"totvs.ch"



User Function PTFAT604()

	Local aSays 		:={}
	Local aButtons	:={}
	Local nOpca 		:= 0
	Local cPerg      := PadR("PTFAT604",10)
	Local lPergunte  := .F.

	Private oProcess := NIL

	//Teste()

	//ValidPerg(cPerg)
	Pergunte(cPerg,.F.)

	aadd(aSays, 'Essa rotina tem a finalidade de exportar os dados de pedidos')
	aadd(aSays, 'de venda do período informado em uma planilha de Excel.     ')
	aadd(aSays, '                 					                         ')

	aadd(aButtons, {  5,.T.,{|| lPergunte := Pergunte(cPerg,.T.) }} )
	aadd(aButtons, {  1,.T.,{|| nOpca:= 1, FechaBatch() }} )
	aadd(aButtons, {  2,.T.,{|| nOpca:= 0, FechaBatch() }} )

	FormBatch( 'Exporta Pedidos de Venda', aSays, aButtons,, 220, 430 )

	If nOpca == 1
		IF lPergunte .or. Pergunte(cPerg,.T.)
			FWMsgRun(, {|oSay| geraDados(oSay) }, "Processando", "Processando dados aguarde...")
		Endif
	Endif

Return

static Function geraDados(oSay)
	Local oExcel
	Local cWorkSheet:= "Pedidos Pendentes"
	Local cArquivo  := GetTempPath()+'ExpPedPend_'+DtoS(dDatabase)+'_'+StrTran(Time(),":","")+'.rel'

    Local nAtual      := 0
    Local aColunas    := {}
    Local cFonte      := FwPrinterFont():Arial()
    Local nTamFonte   := 12
    Local lItalico    := .F.
    Local lNegrito    := .T.
    Local lSublinhado := .F.
    Local nCpoAtual   := 0
    Local oCellHoriz  := FwXlsxCellAlignment():Horizontal()
    Local oCellVerti  := FwXlsxCellAlignment():Vertical()
    Local cHorAlinha  := ''
    Local cVerAlinha  := ''
    Local lQuebrLin   := .F.
    Local nRotation   := 0
    Local cCustForma  := ''
    Local cCampoAtu   := ''
    Local cTipo       := ''
    Local cCorFundo   := ''
    Local cCorPreto   := '000000'
    Local cCorVerme   := 'FF0000'
    Local cCorBranco  := 'FFFFFF'
    Local cCorTxt     := cCorPreto
    Local cAliasPri   := GetNextAlias()
	Local lPrint 	  := .F.


	oSay:SetText("Obtendo dados no banco de dados...")

	cAliasPri := getQuery('1')
    DbSelectArea((cAliasPri))
    lPrint := !(cAliasPri)->(Eof())

	
	IF lPrint
    		
		aAdd(aColunas, {'ZV_FILIAL',    			'C', 'Filial',      		10,   0, ''})
        aAdd(aColunas, {'ZV_PEDIDO',    			'C', 'Pedido',        		09,   0, ''})
        aAdd(aColunas, {'ZV_EMISSAO', 				'D', 'Data Emissão',     	16,   2, ''})
        aAdd(aColunas, {'ZV_DTFAT',  				'D', 'Data Faturamento',  	18,   2, ''})
        aAdd(aColunas, {'ZV_DTENT',  				'D', 'Data Entrega',  	    18,   2, ''})
        aAdd(aColunas, {'ZV_FATURA',  				'C', 'Fatura?', 			06,   0, ''})
        aAdd(aColunas, {'ZV_CLIENTE',  			    'C', 'Cod. Cliente', 		12,   0, ''})
        aAdd(aColunas, {'ZV_NMCLI',  			    'C', 'Nome Cliente', 		30,   0, ''})
        aAdd(aColunas, {'ZV_ITEM',  				'C', 'Item', 				06,   0, ''})
        aAdd(aColunas, {'ZV_PROD',  			    'C', 'Produto', 			20,   0, ''})
        aAdd(aColunas, {'ZV_DESC',  			    'C', 'Descrição', 			30,   0, ''})
        aAdd(aColunas, {'ZV_FORN',  			    'C', 'Fornecedor', 			20,   0, ''})
        aAdd(aColunas, {'ZV_FABR',  			    'C', 'Fabricante/Marca', 	20,   0, ''})
        aAdd(aColunas, {'ZV_SLDATU',  			    'N', 'Est. Total', 			15,   1, '@E 99,999,999.999999'})
        aAdd(aColunas, {'ZV_SLDDISP',  			    'N', 'Est. Disponivel', 	15,   1, '@E 99,999,999.999999'})
        aAdd(aColunas, {'ZV_QTDSLD',  			    'N', 'Qtd. Pendente',       15,   1, '@E 99,999,999.999999'})
        aAdd(aColunas, {'ZV_QTDVEN',  			    'N', 'Qtd. Venda', 			15,   1, '@E 99,999,999.999999'})
        aAdd(aColunas, {'ZV_PRCUNIT',  			    'N', 'Prc. Unit.', 			15,   1, '@E 99,999,999.99'})
		aAdd(aColunas, {'ZV_TOTPEND',  			    'N', 'Vlr. Pend. c/ IPI', 	15,   1, '@E 99,999,999.99'})
		aAdd(aColunas, {'ZV_TOTAL',  			    'N', 'Vlr. Tot. c/ IPI', 	15,   1, '@E 99,999,999.99'})
        aAdd(aColunas, {'ZV_INTERNO',  			    'C', 'Vend. Interno', 		15,   0, ''})
        aAdd(aColunas, {'ZV_EXTERNO',  			    'C', 'Vend. Externo', 		15,   0, ''})
        aAdd(aColunas, {'ZV_COORD',  				'C', 'Ger/Coord.', 			15,   0, ''})
        aAdd(aColunas, {'ZV_VEND4',  				'C', 'Vendedor 4', 			15,   0, ''})
        aAdd(aColunas, {'ZV_TPFRETE',  		        'C', 'Tp. Frete', 		    10,   0, ''})
        aAdd(aColunas, {'ZV_PEDORI',  			    'C', 'Ped. Origem', 		15,   0, ''})
        aAdd(aColunas, {'ZV_PEDWEB',  				'C', 'Ped. WEB', 			15,   0, ''})
        aAdd(aColunas, {'ZV_PEDCLI',  			    'C', 'Ped. Cliente', 		15,   0, ''})
        aAdd(aColunas, {'ZV_PE',  					'M', 'P.E. Atualizado', 	50,   0, ''})
        aAdd(aColunas, {'ZV_STATUS',  				'C', 'Status', 				50,   0, ''})
        //aAdd(aColunas, {'ZV_XAGLOC',  				'C', 'Aglutina OC', 		03,   0, ''})
        //aAdd(aColunas, {'ZV_XACFAT',  				'C', 'Aceite Fat.',			20,   0, ''})
        aAdd(aColunas, {'ZV_XLIMFAT',  				'N', 'Data Limite Fat.',	02,   0, ''})
        aAdd(aColunas, {'ZV_XRESP',  				'C', 'Dados Resp.', 		60,   0, ''})
        aAdd(aColunas, {'ZV_XTPPED',  				'C', 'Tipo Pedido', 		10,   0, ''})
        aAdd(aColunas, {'ZV_XFREQ',  				'C', 'Frequência', 		    10,   0, ''})
        aAdd(aColunas, {'ZV_XRECOR',  				'N', 'Recorrência', 		02,   0, ''})
        aAdd(aColunas, {'ZV_XIDUF',  				'C', 'ID UF', 				40,   0, ''})
        aAdd(aColunas, {'ZV_ENCER',  				'C', 'Situação', 			01,   0, ''})
        aAdd(aColunas, {'ZV_TRANS',  				'C', 'Cod. Transp.',	    06,   0, ''})
        aAdd(aColunas, {'ZV_NMTRA',  				'C', 'Nome Transp.', 		50,   0, ''})
        aAdd(aColunas, {'ZV_NUMORC',  				'C', 'Num. Orçamento', 		08,   0, ''})
        aAdd(aColunas, {'ZV_DTGER',  				'D', 'Data Geração Dados',  20,   0, ''})
        aAdd(aColunas, {'ZV_HORA',  				'C', 'Hora Geração Dados',  20,   0, ''})

		oPrintXlsx := FwPrinterXlsx():New()
        If oPrintXlsx:Activate(cArquivo)
 
            //Adiciona uma worksheet
            oPrintXlsx:AddSheet(cWorkSheet)
 
            //Depois de imprimir os textos do cabeçalho, vamos colocar a fonte como normal
            nTamFonte := 09
            lNegrito  := .T.
            oPrintXlsx:SetFont(cFonte, nTamFonte, lItalico, lNegrito, lSublinhado)
             
            //Na primeira linha do cabeçalho, vamos definir como tudo centralizado, a cor do texto verde e de fundo branca
            cHorAlinha  := oCellHoriz:Center()
            cVerAlinha  := oCellVerti:Center()
            oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorPreto, cCorBranco, cCustForma)
 
            //Percorre agora as colunas e vem setando o tamanho delas e colocando o nome
            nLinExcel := 1
            For nAtual := 1 To Len(aColunas)
                oPrintXlsx:SetColumnsWidth(nAtual, nAtual, aColunas[nAtual][4])
                oPrintXlsx:SetText(nLinExcel, nAtual, aColunas[nAtual][3])
            Next
 
            //Define que as colunas terão opção de filtrar (da coluna 1 até a quantidade de campos)
            oPrintXlsx:ApplyAutoFilter(nLinExcel, 1, nLinExcel, Len(aColunas))
             
            //Percorrendo os dados da query
            nTamFonte := 09
            lNegrito:= .F.
            oPrintXlsx:ResetFont()
            oPrintXlsx:SetFont(cFonte, nTamFonte, lItalico, lNegrito, lSublinhado)
            nAtual  := 0
            For nAtual := 1 To Len(aColunas)
                oPrintXlsx:SetColumnsWidth(nAtual, nAtual, aColunas[nAtual][4])
            Next

            //nAtual  := 0
			While !(cAliasPri)->(Eof())
                IF (cAliasPri)->RECNO > 0
                    SZV->(DbGoTo((cAliasPri)->RECNO))
                endif
                 
                //Incrementando a regua
               // nAtual++
                //oSay:SetText('Adicionando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
 
                cCorFundo := cCorBranco
                IF (cAliasPri)->ZV_SLDATU == 0
                    cCorTxt := cCorVerme
                else
                    cCorTxt := cCorPreto
                endif
 
                //Incrementa a linha no Excel
                nLinExcel++
 
                //Percorre as colunas
                For nCpoAtual := 1 To Len(aColunas)
                    cCampoAtu := aColunas[nCpoAtual][1]
                    cTipo     := aColunas[nCpoAtual][2]
                    if (cAliasPri)->ZV_ENCER == "S" .AND. cCampoAtu == "ZV_PE"
                        xConteud  := ""
                    elseif (cAliasPri)->RECNO > 0
                        xConteud  := &("SZV->"+cCampoAtu)
                    else
                        xConteud  := &("(cAliasPri)->"+cCampoAtu)
                    endif

                    //Reseta a formatação
                    oPrintXlsx:ResetCellsFormat()
                     
                    If cTipo == 'D'
                        lQuebrLin := .F.
                        cCustForma := "dd/mm/yyyy"
                        cHorAlinha := oCellHoriz:Center()
                        oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorTxt, cCorFundo, cCustForma)
                        oPrintXlsx:SetDate(nLinExcel, nCpoAtual, xConteud)
 
                    ElseIf cTipo == 'N'
                       
                        lQuebrLin := .F.
                        cCustForma := "#,##0.00"
                        cHorAlinha := oCellHoriz:Right()
                        oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorTxt, cCorFundo, cCustForma)
                        oPrintXlsx:SetNumber(nLinExcel, nCpoAtual, xConteud)

                    ElseIf cTipo == 'M'
                       
                        xConteud := Alltrim(xConteud)
                        lQuebrLin := .T.
                        cCustForma := ""
                        cHorAlinha := oCellHoriz:Left()
                        oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorTxt, cCorFundo, cCustForma)
                        oPrintXlsx:SetText(nLinExcel, nCpoAtual, xConteud)
                    Else
                        
                        xConteud := Alltrim(xConteud)
                        lQuebrLin := .F.
                        cCustForma := ""
                        cHorAlinha := oCellHoriz:Left()
                        oPrintXlsx:SetCellsFormat(cHorAlinha, cVerAlinha, lQuebrLin, nRotation, cCorTxt, cCorFundo, cCustForma)

                        oPrintXlsx:SetText(nLinExcel, nCpoAtual, xConteud)
                    EndIf
                Next

				(cAliasPri)->(DbSkip())
            end
 
            //Vamos finalizar o arquivo
            oPrintXlsx:ToXlsx()
            oPrintXlsx:EraseBaseFile()
            oPrintXlsx:DeActivate()
 
            //E agora vamos abrir ele
            cArquivo := Left(cArquivo,Len(cArquivo)-3) + "xlsx"
            If File(cArquivo)
                oExcel := MsExcel():New()
                oExcel:WorkBooks:Open(cArquivo)
                oExcel:SetVisible(.T.)
                oExcel:Destroy()
            EndIf
        EndIf

	else
		FWAlertError("Não foram encontrados dados com os parametros informados.")
		Return
	Endif

Return


static Function getQuery(cTipoQry)
	Local cAliasQry	:= GetNextAlias()

	if cTipoQry == '1'
		BeginSql Alias cAliasQry

            %noParser% 

            COLUMN ZV_EMISSAO AS DATE
            COLUMN ZV_DTFAT AS DATE
            COLUMN ZV_DTENT AS DATE
            COLUMN ZV_DTGER AS DATE

            SELECT ZV_FILIAL, ZV_PEDIDO, ZV_EMISSAO, ZV_DTFAT, ZV_DTENT, ZV_FATURA, ZV_CLIENTE, ZV_NMCLI, ZV_ITEM,  	
                    ZV_PROD, ZV_DESC, ZV_FORN, ZV_FABR, ZV_SLDATU, ZV_SLDDISP, ZV_QTDVEN, ZV_QTDSLD, ZV_PRCUNIT,  
                    ZV_TOTPEND,	
                    ZV_TOTAL, ZV_INTERNO, ZV_EXTERNO, ZV_COORD, ZV_VEND4, ZV_TPFRETE, ZV_PEDORI, ZV_PEDWEB,  	
                    ZV_PEDCLI, ISNULL(CAST(CAST(ZV_PE AS VARBINARY(1000)) AS VARCHAR(1000)),'') AS ZV_PE,  		
                    ZV_STATUS, ZV_XAGLOC, ZV_XACFAT, ZV_XLIMFAT, ZV_XRESP, ZV_XTPPED, ZV_XFREQ, ZV_XRECOR, ZV_XIDUF, 'Pendente' ZV_ENCER,
                    ZV_TRANS, ZV_NMTRA, ZV_NUMORC,
                    ZV_DTGER, ZV_HORA
                    , SZV.R_E_C_N_O_ RECNO
            FROM %Table:SZV% SZV
            INNER JOIN %Table:SB1% SB1 ON SB1.%notdel% AND B1_COD = ZV_PROD
            WHERE SZV.%notdel%
            AND ZV_FILIAL = %Exp:xFilial("SZV")%
            AND ZV_EMISSAO BETWEEN %Exp:DtoS(mv_par01)% AND %Exp:DtoS(mv_par02)%
            AND ZV_DTFAT BETWEEN %Exp:DtoS(mv_par03)% AND %Exp:DtoS(mv_par04)%
            AND (%Exp:mv_par05% = '      ' OR ZV_CODINT = %Exp:mv_par05%)
            AND ZV_PROD BETWEEN %Exp:mv_par06% AND %Exp:mv_par07%
            AND ZV_CLIENTE BETWEEN %Exp:mv_par08% AND %Exp:mv_par09%
            AND ZV_PEDIDO BETWEEN %Exp:mv_par10% AND %Exp:mv_par11%
            AND ZV_UF BETWEEN %Exp:mv_par12% AND %Exp:mv_par13%
            AND B1_GRUPO BETWEEN %Exp:mv_par14% AND %Exp:mv_par15%
            AND ZV_FABR BETWEEN %Exp:mv_par16% AND %Exp:mv_par17%
            AND ((ZV_ENCER = 'Pendente' AND %Exp:mv_par18% = 2) OR %Exp:mv_par18% = 3)
            AND ZV_DTGER + ZV_HORA in (
                SELECT top 1 SZV1.ZV_DTGER + SZV1.ZV_HORA
                FROM %Table:SZV% SZV1
                WHERE SZV1.%notdel%
                AND SZV1.ZV_FILIAL = %Exp:xFilial("SZV")%
                AND SZV1.ZV_OK = 'S'
                ORDER BY SZV1.ZV_DTGER DESC, SZV1.ZV_HORA DESC
            )

            UNION ALL

            SELECT C5_FILIAL, C5_NUM, C5_EMISSAO, C6_CRVENT, C6_ENTREG,
                    CASE WHEN C5_XFATURA = 'S' THEN 'SIM' ELSE 'NÃO' END Fatura,
                    C5_CLIENTE, A1_NOME, C6_ITEM, C6_PRODUTO, C6_DESCRI,
                    COALESCE(A2_NOME,''), B1_FABRIC,
                    COALESCE(SB2.B2_QATU,0) [Saldo_Atual],
                    COALESCE(SB2.B2_QATU-SB2.B2_RESERVA,0) [Saldo_Disponivel],
                    D2_QUANT, 0 , D2_PRCVEN, 0, (D2_QUANT*D2_PRCVEN*(1+(D2_IPI/100))),
                    COALESCE(SA3INT.A3_NREDUZ,'') [Vend_Interno],
                    COALESCE(SA3EXT.A3_NREDUZ,'') [Vend_Externo],
                    COALESCE(SA3GER.A3_NREDUZ,'') [GerCoor],
                    COALESCE(SA3VEN.A3_NREDUZ,'') [Vend4],
                    CASE WHEN C5_TPFRETE = 'C' THEN 'CIF' WHEN C5_TPFRETE = 'F' THEN 'FOB' WHEN C5_TPFRETE = 'T' THEN 'TERCEIROS' WHEN C5_TPFRETE = 'R' THEN 'REMETENTE' WHEN C5_TPFRETE = 'D' THEN 'DESTINATARIO' WHEN C5_TPFRETE = 'S' THEN 'SEM FRETE' END [Tipo_Frete],
                    C6_XNUMOG [Pedido_Origem],
                    C5_XPEDWEB [Pedido_WEB],
                    C6_XPEDCLI [Pedido_Cliente],
                    '' ZV_PE,
                    CASE WHEN F2_CRVROM <> '' THEN '12 - Coletado em ' + CONVERT(VARCHAR,CAST(ZI_DATA AS DATE), 103) + ', NF ' + F2_DOC
		                WHEN F2_CRVROM = '' THEN '11 - Faturado, NF ' + F2_DOC 
                    END AS NovoStatus,
                    CASE WHEN C5_XAGLOC = 'S' THEN 'SIM' WHEN C5_XAGLOC = 'N' THEN 'NÃO' ELSE '' END [Aglutina_OC],
                    CASE WHEN C5_XACFAT = '1' THEN 'Pedido Parcial' WHEN C5_XAGLOC = '2' THEN 'Pedido Completo' ELSE '' END [Aceite_Faturamento],
                    A1_XLIMFAT [Limite_Faturamento],
                    C5_XRESP [Dados_Responsavel],
                    CASE WHEN C5_XTPPED='1' THEN 'Pontual' WHEN C5_XTPPED='2' THEN 'Programado' ELSE '' END [Tipo_Pedido],
                    CASE WHEN C5_XFREQ='P' THEN 'Pontual' WHEN C5_XFREQ='M' THEN 'Mensal' WHEN C5_XFREQ='B' THEN 'Bimestral' WHEN C5_XFREQ='T' THEN 'Trimestral' WHEN C5_XFREQ='S' THEN 'Semestral' WHEN C5_XFREQ='A' THEN 'Anual' ELSE '' END [Frequencia],
                    C5_XRECOR,
                    C5_XIDUF [ID_UF],
                    'Encerrado' [Encerrado],
                    ISNULL(A4_COD,'') [Cod_Transportadora],
                    ISNULL(A4_NOME,'') [Nome_Transportadora],
                    C6_NUMORC, 
                    %Exp:DtoS(MsDate())%,
                    %Exp:Time()%
                    , 0 RECNO
            FROM %Table:SC6% SC6
            INNER JOIN %Table:SC5% SC5 ON SC5.%notdel% AND C5_FILIAL = %Exp:xFilial("SC5")% AND C5_NUM = C6_NUM 
            INNER JOIN %Table:SD2% SD2 ON SD2.%notdel% AND D2_FILIAL = %Exp:xFilial("SD2")% AND D2_PEDIDO = C6_NUM AND D2_ITEMPV = C6_ITEM
            INNER JOIN %Table:SF2% SF2 ON SF2.%notdel% AND F2_FILIAL = %Exp:xFilial("SF2")% AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE
            INNER JOIN %Table:SA1% SA1 ON SA1.%notdel% AND A1_FILIAL = %Exp:xFilial("SA1")% AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI 
            INNER JOIN %Table:SB1% SB1 ON SB1.%notdel% AND B1_FILIAL = %Exp:xFilial("SB1")% AND B1_COD = C6_PRODUTO 
            INNER JOIN %Table:SF4% SF4 ON SF4.%notdel% AND F4_FILIAL = %Exp:xFilial("SF4")% AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S' 
            INNER JOIN %Table:SE4% SE4 ON SE4.%notdel% AND E4_FILIAL = %Exp:xFilial("SE4")% AND E4_CODIGO = C5_CONDPAG 
            LEFT JOIN %Table:SZI% SZI ON SZI.%notdel% AND ZI_FILIAL = %Exp:xFilial("SZI")% AND ZI_NUM = F2_CRVROM
            LEFT JOIN %Table:SA3% SA3INT ON SA3INT.%notdel% AND SA3INT.A3_FILIAL = %Exp:xFilial("SA3")% AND SA3INT.A3_COD = C5_VEND1 
            LEFT JOIN %Table:SA3% SA3EXT ON SA3EXT.%notdel% AND SA3EXT.A3_FILIAL = %Exp:xFilial("SA3")% AND SA3EXT.A3_COD = C5_VEND2 
            LEFT JOIN %Table:SA3% SA3GER ON SA3GER.%notdel% AND SA3GER.A3_FILIAL = %Exp:xFilial("SA3")% AND SA3GER.A3_COD = C5_VEND3 
            LEFT JOIN %Table:SA3% SA3VEN ON SA3VEN.%notdel% AND SA3VEN.A3_FILIAL = %Exp:xFilial("SA3")% AND SA3VEN.A3_COD = C5_VEND4
            LEFT JOIN %Table:SB2% SB2 ON SB2.%notdel% AND B2_FILIAL = %Exp:xFilial("SB2")% AND SB2.B2_COD = C6_PRODUTO AND SB2.B2_LOCAL = SB2.B2_FILIAL 
            LEFT JOIN %Table:SA2% SA2 ON SA2.%notdel% AND A2_FILIAL = %Exp:xFilial("SA2")% AND B1_PROC = A2_COD AND B1_LOJPROC = A2_LOJA 
            LEFT JOIN %Table:SA4% SA4 ON SA4.%notdel% AND A4_FILIAL = %Exp:xFilial("SA4")% AND A4_COD = F2_TRANSP 
            WHERE SC6.%notdel% AND C6_FILIAL = %Exp:xFilial("SC6")%
            AND C5_EMISSAO BETWEEN %Exp:DtoS(mv_par01)% AND %Exp:DtoS(mv_par02)%
            AND C6_CRVENT BETWEEN %Exp:DtoS(mv_par03)% AND %Exp:DtoS(mv_par04)%
            AND (%Exp:mv_par05% = '      ' OR SA3INT.A3_COD = %Exp:mv_par05%)
            AND C6_PRODUTO BETWEEN %Exp:mv_par06% AND %Exp:mv_par07%
            AND C5_CLIENTE BETWEEN %Exp:mv_par08% AND %Exp:mv_par09%
            AND C5_NUM BETWEEN %Exp:mv_par10% AND %Exp:mv_par11%
            AND A1_EST BETWEEN %Exp:mv_par12% AND %Exp:mv_par13%
            AND B1_GRUPO BETWEEN %Exp:mv_par14% AND %Exp:mv_par15%
            AND B1_FABRIC BETWEEN %Exp:mv_par16% AND %Exp:mv_par17%
            AND (%Exp:mv_par18% = 1 OR %Exp:mv_par18% = 3)

            ORDER BY ZV_FILIAL,ZV_PROD,ZV_EMISSAO,ZV_DTFAT,ZV_PEDIDO,ZV_ITEM
		EndSql
	endif

    MemoWrite('PTFAT604.txt',GetLastQuery()[02])

Return cAliasQry

