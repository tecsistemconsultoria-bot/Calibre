#INCLUDE"totvs.ch"



User Function PTFAT601()

   Local aSays 		:={}
   Local aButtons	:={}
   Local nOpca 		:= 0
   Local cPerg      := PadR("PTFAT601",10)
   Local lPergunte  := .F.

   Private oProcess := NIL                                                                      
   
   //ValidPerg(cPerg)
   Pergunte(cPerg,.F.)
                    
   aadd(aSays, 'Essa rotina tem a finalidade de exportar os dados de faturamento')
   aadd(aSays, 'e devoluções do período informado em uma planilha de Excel.     ')
   aadd(aSays, '                 					                            ')

   aadd(aButtons, {  5,.T.,{|| lPergunte := Pergunte(cPerg,.T.) }} )                  
   aadd(aButtons, {  1,.T.,{|| nOpca:= 1, FechaBatch() }} )
   aadd(aButtons, {  2,.T.,{|| nOpca:= 0, FechaBatch() }} )  

   FormBatch( 'Exporta Faturamento e Devoluções', aSays, aButtons,, 220, 430 )

    If nOpca == 1
        IF lPergunte .or. Pergunte(cPerg,.T.)
            FWMsgRun(, {|oSay| geraDados(oSay) }, "Processando", "Processando dados aguarde...")
 
        Endif
    Endif  

Return

static Function geraDados(oSay)
Local cAliasQry := ""
Local nTotCount := 0
Local nCount    := 0
Local aCampos   := {}
Local xi        := 0

// Excel
Local oExcel    := FWMsExcelEx():New()
Local cWorkSheet:= "WorkSheet"
Local cTable    := "Table"
Local aLinha    := {}
Local cQuebra   := ""
Local cCpoQbra  := ""
Local cArquivo  := GetTempPath()+'ExpFatDev_'+DtoS(dDatabase)+'_'+StrTran(Time(),":","")+'.xml'

//oExcel:SetCelBold(.T.)
oExcel:SetCelFont('Arial')
//oExcel:SetCelItalic(.T.)
//oExcel:SetCelUnderLine(.T.)
oExcel:SetCelSizeFont(12)
oExcel:SetCelFrColor("#FFFFFF")
oExcel:SetCelBgColor("#000333")


oSay:SetText("Obtendo dados no banco de dados...")
cAliasQry := getQuery()


DbSelectArea((cAliasQry))
(cAliasQry)->(DbGoTop())
count to nTotCount
DbSelectArea((cAliasQry))
(cAliasQry)->(DbGoTop())

IF nTotCount == 0
    FWAlertError("Não foram encontrados dados com os parametros informados.","Falha na requisição de Dados.")
    Return
Endif


DbSelectArea((cAliasQry))
While !(cAliasQry)->(Eof())
    nCount++
    oSay:SetText("Montando linhas...")

    if mv_par21 == 1
        cCpoQbra := "WorkSheet"
    elseif mv_par21 == 2
        cCpoQbra := Alltrim((cAliasQry)->(UFCliente))
        IF Empty(cCpoQbra)
            cCpoQbra := "SEM UF"
        Endif
    elseif mv_par21 == 3
        cCpoQbra := Alltrim((cAliasQry)->(Fabricante))
        IF Empty(cCpoQbra)
            cCpoQbra := "SEM FABRICANTE"
        Endif
    Endif

    IF cQuebra != cCpoQbra 
        cQuebra := cCpoQbra
        cWorkSheet := cCpoQbra
        
        oExcel:AddworkSheet(cWorkSheet)
        oExcel:AddTable(cWorkSheet,cTable,.F.)

        aCampos := (cAliasQry)->(DbStruct())
        For xi := 1 to Len(aCampos)
            do case 
                case aCampos[xi,2] == "C"
                    oExcel:AddColumn(cWorkSheet,cTable,aCampos[xi,1],1,1,.F.)
                case aCampos[xi,2] == "N"
                    oExcel:AddColumn(cWorkSheet,cTable,aCampos[xi,1],3,2,.T.)
                case aCampos[xi,2] == "D"
                    oExcel:AddColumn(cWorkSheet,cTable,aCampos[xi,1],2,4,.F.)
            end case
        Next
    Endif
    
    For xi := 1 to Len(aCampos)
        aADD(aLinha,FieldGet(FieldPos(aCampos[xi,1])))
    next

    oExcel:AddRow(cWorkSheet,cTable,aLinha)
    aLinha := {}

   (cAliasQry)->(DbSkip()) 
End

oExcel:Activate()
oExcel:GetXMLFile(cArquivo)
oExcel:DeActivate()
FwFreeObj(oExcel)


//Abrindo o excel e abrindo o arquivo xml
oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
oExcel:SetVisible(.T.)                 //Visualiza a planilha
oExcel:Destroy() 

Return


static Function getQuery()
    Local cAliasQry := GetNextAlias()
    Local cOrdem    := ""

    
    if mv_par21 == 1
        cOrdem := "%Filial, DataEmissao, NumeroNF, SerieNF%"
    elseif mv_par21 == 2
        cOrdem := "%UFCliente, Filial, DataEmissao, NumeroNF, SerieNF%"
    elseif mv_par21 == 3
        cOrdem := "%Fabricante, Filial, DataEmissao, NumeroNF, SerieNF%"
    Endif
    BeginSql Alias cAliasQry
        
        COLUMN DataEmissao AS DATE
        COLUMN EmissaoPedido AS DATE
        
        SELECT F2_FILIAL [Filial]
            , F2_EMISSAO [DataEmissao]
            , F2_DOC [NumeroNF]
            , F2_SERIE [SerieNF]
            , F2_CLIENTE [CodCliente]
            , F2_LOJA [LojaCliente]
            , A1_NOME [NomeCliente]
            , A1_NREDUZ [FantasiaCliente]
            , A1_BAIRRO [BairroCliente]
            , A1_EST [UFCliente]
            , A1_MUN [MunicipioCliente]
            , A1_CGC [CNPJ_CPFCliente]
            , D2_COD [CodProduto]
            , B1_DESC [DescProduto]
            , B1_TIPO [TipoProduto]
            , D2_TES [TES]
            , D2_CF [CFOP]
            , D2_QUANT [Quantidade]
            , D2_PRCVEN [ValorUnitario]
            , D2_TOTAL [ValorMercadoria]
            , (D2_TOTAL+IIF(F2_TIPO='P',0,D2_VALIPI)+D2_VALFRE+D2_DESPESA+D2_SEGURO+D2_ICMSRET) [FaturamentoBruto] 
            , (D2_TOTAL+D2_VALFRE-D2_VALICM-D2_VALIMP5-D2_VALIMP6-D2_VALISS) [FaturamentoLiquido]
            , D2_VALIPI [ValorIPI]
            , D2_VALFRE [ValorFrete]
            , D2_DESPESA [ValorDespesa]
            , D2_SEGURO [ValorSeguro]
            , D2_ICMSRET [ValorICMS_ST]
            , D2_VALICM [ValorICMS]
            , D2_VALIMP6 [ValorPIS]
            , D2_VALIMP5 [ValorCOFINS]
            , D2_VALISS [ValorISS]
            , B1_POSIPI [NCM]
            , D2_PICM [AliqICMS]
            , D2_LOTECTL [Lote]
            , F2_CHVNFE [ChaveNFe]
            , F4_CRVDESC [FinalidadeTES]
            , D2_PEDIDO [Pedido]
            , C5_EMISSAO [EmissaoPedido]
            , B1_FABRIC [Fabricante]
            , B1_PROC [Fornecedor]
            , A2_NOME [NomeFornecedor]
            , SX5.X5_DESCRI [Atividade]
            , SBM.BM_DESC [GrupoProduto]
            , B1_CRVGRUP [GrupoMRP]
            , B1_XGRUPSP [MRP_SP]
            , A1_CONTRIB [Contrib]
            , A1_VEND [CodVend_Int]
            , SA31.A3_NOME [NomeVend_Int]
            , A1_CRVVEN2 [CodVend_Ext]
            , SA32.A3_NOME [NomeVend_Ext]
            , A1_CRVVEN3 [CodGer_Coord]
            , SA33.A3_NOME [NomeGer_Coord]
            , A1_CRVEND4 [CodEsp_Ven]
            , SA34.A3_NOME [NomeEsp_Ven]
            , C5_VEND1 [CodVend_Int_PV]
            , SA311.A3_NOME [NomeVend_Int_PV]
            , C5_VEND2 [CodVend_Ext_PV]
            , SA322.A3_NOME [NomeVend_Ext_PV]
            , C5_VEND3 [CodGer_Coord_PV]
            , SA333.A3_NOME [NomeGer_Coord_PV]
            , C5_VEND4 [CodEsp_Ven_PV]
            , SA344.A3_NOME [NomeEsp_Ven_PV]
            , B1_CRVPF [PF]
            , B1_CRVME [ME]
            , F2_TRANSP [CodTransp]
            , A4_NOME [NomeTransp]
        FROM SF2010 SF2
        INNER JOIN %Table:SD2% SD2 ON SD2.%notdel% AND SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE
        INNER JOIN %Table:SA1% SA1 ON SA1.%notdel% AND SA1.A1_FILIAL = '' AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA
        INNER JOIN %Table:SB1% SB1 ON SB1.%notdel% AND SB1.B1_FILIAL = '' AND SB1.B1_COD = SD2.D2_COD
        INNER JOIN %Table:SF4% SF4 ON SF4.%notdel% AND SF4.F4_FILIAL = SF2.F2_FILIAL AND SF4.F4_CODIGO = SD2.D2_TES
        INNER JOIN %Table:SC5% SC5 ON SC5.%notdel% AND SC5.C5_FILIAL = SF2.F2_FILIAL AND SC5.C5_NUM = SD2.D2_PEDIDO
        LEFT JOIN %Table:SA4% SA4 ON SA4.%notdel% AND SA4.A4_FILIAL = '' AND SA4.A4_COD = SF2.F2_TRANSP
        LEFT JOIN %Table:SBM% SBM ON SBM.%notdel% AND SBM.BM_FILIAL = '' AND SBM.BM_GRUPO = SB1.B1_GRUPO
        LEFT JOIN %Table:SA2% SA2 ON SA2.%notdel% AND SA2.A2_FILIAL = '' AND SA2.A2_COD = SB1.B1_PROC AND SA2.A2_LOJA = SB1.B1_LOJPROC
        LEFT JOIN %Table:SX5% SX5 ON SX5.%notdel% AND SX5.X5_TABELA = 'T3' AND SA1.A1_SATIV1 = SX5.X5_CHAVE
        LEFT JOIN %Table:SA3% SA31 ON SA31.%notdel% AND SA31.A3_FILIAL = '' AND SA31.A3_COD = SA1.A1_VEND
        LEFT JOIN %Table:SA3% SA32 ON SA32.%notdel% AND SA32.A3_FILIAL = '' AND SA32.A3_COD = SA1.A1_CRVVEN2
        LEFT JOIN %Table:SA3% SA33 ON SA33.%notdel% AND SA33.A3_FILIAL = '' AND SA33.A3_COD = SA1.A1_CRVVEN3
        LEFT JOIN %Table:SA3% SA34 ON SA34.%notdel% AND SA34.A3_FILIAL = '' AND SA34.A3_COD = SA1.A1_CRVEND4
        LEFT JOIN %Table:SA3% SA311 ON SA311.%notdel% AND SA311.A3_FILIAL = '' AND SA311.A3_COD = SC5.C5_VEND1
        LEFT JOIN %Table:SA3% SA322 ON SA322.%notdel% AND SA322.A3_FILIAL = '' AND SA322.A3_COD = SC5.C5_VEND2
        LEFT JOIN %Table:SA3% SA333 ON SA333.%notdel% AND SA333.A3_FILIAL = '' AND SA333.A3_COD = SC5.C5_VEND3
        LEFT JOIN %Table:SA3% SA344 ON SA344.%notdel% AND SA344.A3_FILIAL = '' AND SA344.A3_COD = SC5.C5_VEND4

        WHERE SF2.%notdel%
        AND SF2.F2_FILIAL BETWEEN %Exp:MV_PAR03% and %Exp:MV_PAR04%
        AND SF2.F2_TIPO IN ('N','C','P')
        AND SF2.F2_EMISSAO BETWEEN %Exp:DtoS(MV_PAR01)% and %Exp:DtoS(MV_PAR02)%
        AND (SF4.F4_DUPLIC = 'S' OR SD2.D2_CF IN ('5116','6116','5117','6117'))
        AND SD2.D2_CF NOT IN ('5922','6922')
        AND SA1.A1_EST BETWEEN %Exp:MV_PAR05% and %Exp:MV_PAR06% 
        AND SB1.B1_FABRIC BETWEEN %Exp:MV_PAR07% and %Exp:MV_PAR08%
        AND SA1.A1_VEND BETWEEN %Exp:MV_PAR09% and %Exp:MV_PAR10%
        AND SA1.A1_CRVVEN2 BETWEEN %Exp:MV_PAR11% and %Exp:MV_PAR12%
        AND SA1.A1_CRVVEN3 BETWEEN %Exp:MV_PAR13% and %Exp:MV_PAR14% 
        AND SC5.C5_VEND1 BETWEEN %Exp:MV_PAR15% and %Exp:MV_PAR16%
        AND SC5.C5_VEND2 BETWEEN %Exp:MV_PAR17% and %Exp:MV_PAR18%
        AND SC5.C5_VEND3 BETWEEN %Exp:MV_PAR19% and %Exp:MV_PAR20% 

        UNION ALL

        SELECT F1_FILIAL [Filial]
        , F1_DTDIGIT [DataEmissao]
        , F1_DOC [NumeroNF]
        , F1_SERIE [SerieNF]
        , F1_FORNECE [CodCliente]
        , F1_LOJA [LojaCliente]
        , A1_NOME [NomeCliente]
        , A1_NREDUZ [FantasiaCliente]
        , A1_BAIRRO [BairroCliente]
        , A1_EST [UFCliente]
        , A1_MUN [MunicipioCliente]
        , A1_CGC [CNPJ_CPFCliente]
        , D1_COD [CodProduto]
        , B1_DESC [DescProduto]
        , B1_TIPO [TipoProduto]
        , D1_TES [TES]
        , D1_CF [CFOP]
        , D1_QUANT*(-1) [Quantidade]
        , D1_VUNIT*(-1) [ValorUnitario]
        , D1_TOTAL*(-1) [ValorMercadoria]
        , (D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET)*(-1) [FaturamentoBruto] 
        , (D1_TOTAL+D1_VALFRE-D1_VALICM-D1_VALIMP5-D1_VALIMP6)*(-1) [FaturamentoLiquido]
        , D1_VALIPI*(-1) [ValorIPI]
        , D1_VALFRE*(-1) [ValorFrete]
        , D1_DESPESA*(-1) [ValorDespesa]
        , D1_SEGURO*(-1) [ValorSeguro]
        , D1_ICMSRET*(-1) [ValorICMS_ST]
        , D1_VALICM*(-1) [ValorICMS]
        , D1_VALIMP6*(-1) [ValorPIS]
        , D1_VALIMP5*(-1) [ValorCOFINS]
        , 0 [ValorISS]
        , B1_POSIPI [NCM]
        , D1_PICM [AliqICMS]
        , D1_LOTECTL [Lote]
        , F1_CHVNFE [ChaveNFe]
        , F4_CRVDESC [FinalidadeTES]
        , '' [Pedido]
        , '' [EmissaoPedido]
        , B1_FABRIC [Fabricante]
        , B1_PROC [Fornecedor]
        , A2_NOME [NomeFornecedor]
        , SX5.X5_DESCRI [Atividade]
        , SBM.BM_DESC [GrupoProduto]
        , B1_CRVGRUP [GrupoMRP]
        , B1_XGRUPSP [MRP_SP]
        , A1_CONTRIB [Contrib]
        , A1_VEND [CodVend_Int]
        , SA31.A3_NOME [NomeVend_Int]
        , A1_CRVVEN2 [CodVend_Ext]
        , SA32.A3_NOME [NomeVend_Ext]
        , A1_CRVVEN3 [CodGer_Coord]
        , SA33.A3_NOME [NomeGer_Coord]
        , A1_CRVEND4 [CodEsp_Ven]
        , SA34.A3_NOME [NomeEsp_Ven]
        , '' [CodVend_Int_PV]
        , '' [NomeVend_Int_PV]
        , '' [CodVend_Ext_PV]
        , '' [NomeVend_Ext_PV]
        , '' [CodGer_Coord_PV]
        , '' [NomeGer_Coord_PV]
        , '' [CodEsp_Ven_PV]
        , '' [NomeEsp_Ven_PV]
        , B1_CRVPF [PF]
        , B1_CRVME [ME]
        , '' [CodTransp]
        , '' [NomeTransp]
        FROM SF1010 SF1
        INNER JOIN %Table:SD1% SD1 ON SD1.%notdel% AND SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA
        INNER JOIN %Table:SA1% SA1 ON SA1.%notdel% AND SA1.A1_FILIAL = '' AND SA1.A1_COD = SF1.F1_FORNECE AND SA1.A1_LOJA = SF1.F1_LOJA
        INNER JOIN %Table:SB1% SB1 ON SB1.%notdel% AND SB1.B1_FILIAL = '' AND SB1.B1_COD = SD1.D1_COD
        INNER JOIN %Table:SF4% SF4 ON SF4.%notdel% AND SF4.F4_FILIAL = SF1.F1_FILIAL AND SF4.F4_CODIGO = SD1.D1_TES
        LEFT JOIN %Table:SBM% SBM ON SBM.%notdel% AND SBM.BM_FILIAL = '' AND SBM.BM_GRUPO = SB1.B1_GRUPO
        LEFT JOIN %Table:SA2% SA2 ON SA2.%notdel% AND SA2.A2_FILIAL = '' AND SA2.A2_COD = SB1.B1_PROC AND SA2.A2_LOJA = SB1.B1_LOJPROC
        LEFT JOIN %Table:SX5% SX5 ON SX5.%notdel% AND SX5.X5_TABELA = 'T3' AND SA1.A1_SATIV1 = SX5.X5_CHAVE
        LEFT JOIN %Table:SA3% SA31 ON SA31.%notdel% AND SA31.A3_FILIAL = '' AND SA31.A3_COD = SA1.A1_VEND
        LEFT JOIN %Table:SA3% SA32 ON SA32.%notdel% AND SA32.A3_FILIAL = '' AND SA32.A3_COD = SA1.A1_CRVVEN2
        LEFT JOIN %Table:SA3% SA33 ON SA33.%notdel% AND SA33.A3_FILIAL = '' AND SA33.A3_COD = SA1.A1_CRVVEN3
        LEFT JOIN %Table:SA3% SA34 ON SA34.%notdel% AND SA34.A3_FILIAL = '' AND SA34.A3_COD = SA1.A1_CRVEND4

        WHERE SF1.%notdel%
        AND SF1.F1_FILIAL BETWEEN %Exp:MV_PAR03% and %Exp:MV_PAR04%
        AND SF1.F1_TIPO = 'D'
        AND SF1.F1_DTDIGIT BETWEEN %Exp:DtoS(MV_PAR01)% and %Exp:DtoS(MV_PAR02)%
        AND SF4.F4_DUPLIC = 'S'
        AND SA1.A1_EST BETWEEN %Exp:MV_PAR05% and %Exp:MV_PAR06% 
        AND SB1.B1_FABRIC BETWEEN %Exp:MV_PAR07% and %Exp:MV_PAR08%
        AND SA1.A1_VEND BETWEEN %Exp:MV_PAR09% and %Exp:MV_PAR10%
        AND SA1.A1_CRVVEN2 BETWEEN %Exp:MV_PAR11% and %Exp:MV_PAR12%
        AND SA1.A1_CRVVEN3 BETWEEN %Exp:MV_PAR13% and %Exp:MV_PAR14%
        AND SA1.A1_VEND BETWEEN %Exp:MV_PAR15% and %Exp:MV_PAR16%
        AND SA1.A1_CRVVEN2 BETWEEN %Exp:MV_PAR17% and %Exp:MV_PAR18%
        AND SA1.A1_CRVVEN3 BETWEEN %Exp:MV_PAR19% and %Exp:MV_PAR20% 

        ORDER BY %exp:cOrdem%

    EndSql

    MEmoWrite("PTFAT601.txt",GetLastQuery()[02])

Return cAliasQry


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Perguntas no SX1                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ValidPerg(cPerg)
Local cAlias:= Alias()
Local aRegs := {}
Local i     := 0
Local j     := 0

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{cPerg,"01","Emissão de          ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Emissão até         ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Filial de           ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SM0"})
AADD(aRegs,{cPerg,"04","Filial até          ?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SM0"})

DbSelectArea("SX1")
DbSetOrder(1)
For i:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j<=Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

DbSelectArea(cAlias)
Return
