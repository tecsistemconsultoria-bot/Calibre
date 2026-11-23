#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
  
/*/{Protheus.doc} CAFATI03
    Serviço de Graficos de Barra e Linha
  
    @author Rodrigo dos Santos Brandão
    @since 04/10/2025
    @type class
/*/
WSRESTFUL CAFATI03 DESCRIPTION "Faturamento Mês a Mês - Gráfico Barra"
    WSDATA JsonFilter       AS STRING     OPTIONAL
    WSDATA drillDownFilter  AS STRING     OPTIONAL
    WSDATA Fields           AS STRING     OPTIONAL
    WSDATA Order            AS STRING     OPTIONAL
    WSDATA Page             AS INTEGER    OPTIONAL
    WSDATA PageSize         AS INTEGER    OPTIONAL
  
    WSMETHOD GET form ;
        DESCRIPTION "Formulario de Cadastro do Grafico" ;
        WSSYNTAX "/charts/form/" ;
        PATH "/charts/form";
        PRODUCES APPLICATION_JSON
  
    WSMETHOD POST retDados ;
        DESCRIPTION "Devera retornar as informacoes apresentadas no grafico." ;
        WSSYNTAX "/charts/retDados/{JsonFilter}" ;
        PATH "/charts/retDados";
        PRODUCES APPLICATION_JSON
  
    WSMETHOD POST itemsDetails ;
        DESCRIPTION "Carrega o detalhamento do grafico" ;
        WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
        PATH "/charts/itemsDetails";
        PRODUCES APPLICATION_JSON
ENDWSRESTFUL
  
WSMETHOD GET form WSSERVICE CAFATI03
Local oResponse   := JsonObject():New()
Local oCoreDash   := CoreDash():New()
  
  oCoreDash:SetPOForm("Tipo de Grafico", "charttype"       , 6, "Tipo de Grafico"        , .T., "string" , oCoreDash:SetPOCombo({{"line","Linha"}, {"bar","Barra"}}))
  oCoreDash:SetPOForm("Filtros"        , "dateIni"         , 6, "Data Inicial"           , .T., 'date'   , , .T.)
  oCoreDash:SetPOForm(""               , "dateFim"         , 6, "Data Final"             , .T., 'date'   , , .T.)

  oResponse  := oCoreDash:GetPOForm()

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.
  
WSMETHOD POST retDados WSRECEIVE JsonFilter WSSERVICE CAFATI03
  Local oResponse   := JsonObject():New()
  Local oCoreDash   := CoreDash():New()
  Local oJson       := JsonObject():New()

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  retDados(@oResponse, oCoreDash, oJson)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

  oResponse := Nil
  FreeObj( oResponse )

  oCoreDash:Destroy()
  FreeObj( oCoreDash )
Return .T.
  
Static Function retDados(oResponse, oCoreDash, oJson)
  Local aDataFim := {}
  Local aData1   := {}
  Local aData2   := {}
  Local aData3   := {}
  Local aData4   := {}

  Local aData5   := {}
  Local aData6   := {}
  Local aData7   := {}
  Local aData8   := {}

  Local aCab     := {}
  Local aCores   := oCoreDash:GetColorChart()
  Local cFiltros := ""
  Local dIni     := firstDate( yearSub(dDatabase, 1) )
  Local dFim     := lastDate( dDatabase )
  Local aMeses   := { "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" }
  Local aInterv  := {}
  Local nI
  Local cIAnoAnt
  Local cFAnoAnt

  if ! empty( oJson["dateIni"] )
    dIni := StoD( strTran(oJson["dateIni"], "-", "" ) )
    dFim := StoD( strTran(oJson["dateFim"], "-", "" ) )
  endif

  while dIni <= dFim
    aAdd( aCab, aMeses[ month( dIni ) ] + "." + cValToChar( year( dIni ) ) )
    aAdd( aInterv, { DtoS(dIni), DtoS( lastDate(dIni) ) } )
    dIni := MonthSum(dIni,1)
  endDo

  for nI := 1 to len( aInterv )
    aAdd( aData1, retTotais("qtd_nf"     , cFiltros + " and SF2.F2_EMISSAO between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )
    aAdd( aData2, retTotais("qtd_ped"    , cFiltros + " and SF2.F2_EMISSAO between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )
    aAdd( aData3, retTotais("val_brut"   , cFiltros + " and SF2.F2_EMISSAO between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )
    aAdd( aData4, retTotais("val_liquido", cFiltros + " and SF2.F2_EMISSAO between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )

    cIAnoAnt := DtoS( YearSub( StoD(aInterv[nI,1]), 1 ) )
    cFAnoAnt := DtoS( YearSub( StoD(aInterv[nI,2]), 1 ) )
    aAdd( aData5, retTotais("qtd_nf"     , cFiltros + " and SF2.F2_EMISSAO between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
    aAdd( aData6, retTotais("qtd_ped"    , cFiltros + " and SF2.F2_EMISSAO between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
    aAdd( aData7, retTotais("val_brut"   , cFiltros + " and SF2.F2_EMISSAO between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
    aAdd( aData8, retTotais("val_liquido", cFiltros + " and SF2.F2_EMISSAO between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
  next

  oCoreDash:SetChartInfo( aData5, 'Qtde NF Anterior' , , aCores[8][3] ) //Cor utilizada: OrangeLht
  oCoreDash:SetChartInfo( aData6, 'Qtde PV Anterior' , , aCores[2][3] ) //Cor utilizada: GreenDk
  oCoreDash:SetChartInfo( aData7, 'Val Brut Anterior', , aCores[6][3] ) //Cor utilizada: YellowDk
  oCoreDash:SetChartInfo( aData8, 'Val Liq Anterior' , , aCores[16][3] ) //Cor utilizada: BrowDk

  oCoreDash:SetChartInfo( aData1, 'Qtde NF'     , , aCores[7][3] ) //Cor utilizada: OrangeLht
  oCoreDash:SetChartInfo( aData2, 'Qtde PV'     , , aCores[1][3] ) //Cor utilizada: GreenDk
  oCoreDash:SetChartInfo( aData3, 'Val Bruto'   , , aCores[5][3] ) //Cor utilizada: YellowDk
  oCoreDash:SetChartInfo( aData4, 'Val Liquido' , , aCores[15][3] ) //Cor utilizada: BrowDk

  aAdd(aDataFim, oCoreDash:SetChart(aCab,,.F., ,"Faturamento mes a mes"))

  oResponse["items"] := aDataFim
return nil
  
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL CAFATI03
  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError        := "Erro na Requisicao"
  Local lRet              := .T.
  Local oCoreDash   := CoreDash():New()
  Local oBody       := JsonObject():New()
  Local oJsonFilter := JsonObject():New()
  Local oJsonDD     := JsonObject():New()
  
  If !Empty(cBody)
    oBody:FromJson(cBody)
    If ValType(oBody["chartFilter"]) == "J"
        oJsonFilter := oBody["chartFilter"]
    EndIf
    If ValType(oBody["detailFilter"]) == "A"
        oJsonDD := oBody["detailFilter"]
    EndIf
  EndIf

  aHeader := {;
      {"doc"       , "Documento"},;
      {"serie"     , "Serie"},;
      {"emissao"   , "Emissao"},;
      {"cliente"   , "Cliente"},;
      {"loja"      , "Loja"},;
      {"nome"      , "Nome"},;
      {"item"      , "Item"},;
      {"produto"   , "Produto"},;
      {"descricao" , "Descrição"},;
      {"quant"     , "Quant","number",'1.2-5',.F.},;
      {"prcunit"   , "Preco Unit", "currency","BRL",.F.},;
      {"total"     , "Valor Item", "currency","BRL",.F.},;
      {"valbruto"  , "Val Bruto", "currency","BRL",.F.},;
      {"valliquido", "Val Liquido", "currency","BRL",.F.};
  }
  
  aItems := {;
      {"doc"       , "SF2.F2_DOC"},;
      {"serie"     , "SF2.F2_SERIE"},;
      {"emissao"   , "SF2.F2_EMISSAO"},;
      {"cliente"   , "SF2.F2_CLIENTE"},;
      {"loja"      , "SF2.F2_LOJA"},;
      {"nome"      , "SA1.A1_NOME"},;
      {"item"      , "SD2.D2_ITEM"},;
      {"produto"   , "SD2.D2_COD"},;
      {"descricao" , "SC6.C6_DESCRI"},;
      {"quant"     , "SD2.D2_QUANT"},;
      {"prcunit"   , "SD2.D2_PRCVEN"},;
      {"total"     , "SD2.D2_TOTAL"},;
      {"valbruto"  , "SF2.F2_VALBRUT", "N"},;
      {"valliquido", "SF2.F2_VALMERC", "N"};
  }
  
  aRet := MntQuery1( oJsonFilter )
  
  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  oCoreDash:SetGroupBy(aRet[3])
  oCoreDash:SetFields(aItems)
  oCoreDash:SetApiQstring(Self:aQueryString)
  oCoreDash:BuildJson()
  
  If lRet
    oCoreDash:SetPOHeader(aHeader)
    Self:SetResponse( oCoreDash:ToObjectJson() )
  Else
    cError := oCoreDash:GetJsonError()
    SetRestFault( 500,  EncodeUtf8(cError) )
  EndIf
  
  oCoreDash:Destroy()
  
  FreeObj(oBody)
  FreeObj(oJsonFilter)
  FreeObj(oJsonDD)
  FreeObj(oCoreDash)
  
  aSize(aRet, 0)
  aSize(aItems, 0)
  aSize(aHeader, 0)
Return( lRet )
  
Static Function MntQuery1( oJsonFilter )
  Local   cQuery      := ""
  Local   cWhere      := ""
  Local   cGroup      := ""
  default oJsonFilter := JsonObject():New()

  cQuery := " SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SF2.F2_LOJA, SA1.A1_NOME "
  cQuery += ", SF2.F2_VALBRUT, SF2.F2_VALMERC, D2_ITEM, D2_COD, C6_DESCRI, D2_QUANT, D2_PRCVEN, D2_TOTAL"
  cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
  cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
  cQuery +=   " on  SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
  cQuery +=   " and SA1.A1_COD  = SF2.F2_CLIENTE "
  cQuery +=   " and SA1.A1_LOJA = SF2.F2_LOJA "
  cQuery +=   " and SA1.D_E_L_E_T_ = ' ' "
  cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
  cQuery +=   " on  D2_FILIAL = '"+xFilial("SD2")+"'"
  cQuery +=   " and D2_DOC    = F2_DOC "
  cQuery +=   " and D2_SERIE  = F2_SERIE "
  cQuery +=   " and SD2.D_E_L_E_T_ = ' ' "
  cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
  cQuery +=   " on  C6_FILIAL = '"+xFilial("SC6")+"'"
  cQuery +=   " and C6_NUM    = D2_PEDIDO "
  cQuery +=   " and C6_ITEM   = D2_ITEMPV "
  cQuery +=   " and SC6.D_E_L_E_T_ = ' ' "

  cWhere := " SF2.D_E_L_E_T_ = ' ' "
  cWhere += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
  cWhere += " AND SF2.F2_TIPO = 'N' "

  if ! empty( oJsonFilter["dateIni"] )
    cWhere += " AND F2_EMISSAO between '"+strTran(oJsonFilter["dateIni"],"-","")+"' and '"+strTran(oJsonFilter["dateFim"],"-","")+"'"
  endif

Return {cQuery, cWhere, cGroup}
  
Static Function retTotais( cItem, cFiltro)
  Local aQuery
  Local cQuery  := ""
  Local cTemp   := GetNextAlias()
  Local xRet

  if cItem == "qtd_nf"
    aQuery  := MntQuery3("COUNT(SF2.F2_DOC) TOTAL_REGISTROS", cFiltro)
  elseif cItem == "qtd_ped"
    aQuery  := MntQuery3("COUNT(DISTINCT SD2.D2_PEDIDO) TOTAL_REGISTROS", cFiltro, "SD2")
  elseif cItem == "val_brut"
    aQuery  := MntQuery3("SUM(SF2.F2_VALBRUT) TOTAL_REGISTROS", cFiltro)
  elseif cItem == "val_liquido"
    aQuery  := MntQuery3("SUM(SF2.F2_VALMERC) TOTAL_REGISTROS", cFiltro)
  endif

  cQuery := aQuery[1] + " WHERE " + aQuery[2]

  DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .T., .T. )

  xRet := (cTemp)->TOTAL_REGISTROS

  (cTemp)->( DBCloseArea() )
Return xRet
  
Static Function MntQuery3(cCampos, cFiltro, cTable, cGroupBy)
  Local cQuery
  Local cWhere
  Local cGroup

  Default cCampos  := ""
  Default cFiltro  := ""
  Default cTable   := "SF2"
  Default cGroupBy := ""

  if cTable == "SF2"
    cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SF2") + " SF2 "

    cWhere := " SF2.F2_FILIAL = '" + xFilial("SF2") + "'" + cFiltro
    cWhere += " AND SF2.D_E_L_E_T_ = ' ' "
  else
    cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SD2") + " SD2 "
    cQuery += " join " + RetSqlName("SF2") + " SF2 "
    cQuery += " on  F2_FILIAL = D2_FILIAL"
    cQuery += " and F2_DOC    = D2_DOC"
    cQuery += " and F2_SERIE  = D2_SERIE"
    cQuery += " and SF2.D_E_L_E_T_ = ' ' "

    cWhere := " SD2.D2_FILIAL = '" + xFilial("SD2") + "'" + cFiltro
    cWhere += " AND SD2.D_E_L_E_T_ = ' ' "
  endif

  If !Empty(cGroupBy)
      cGroup := cGroupBy
  EndIf
Return {cQuery, cWhere, cGroup}
