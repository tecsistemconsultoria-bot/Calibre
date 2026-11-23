#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
  
/*/{Protheus.doc} CAFATI02
    Serviço de Graficos de Barra e Linha
  
    @author Rodrigo dos Santos Brandão
    @since 04/10/2025
    @type class
/*/
WSRESTFUL CAFATI02 DESCRIPTION "Devoluções Mês a Mês - Gráfico Barra"
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
  
WSMETHOD GET form WSSERVICE CAFATI02
  Local oResponse   := JsonObject():New()
  Local oCoreDash   := CoreDash():New()

  oCoreDash:SetPOForm("Tipo de Grafico", "charttype"       , 6, "Tipo de Grafico"        , .T., "string" , oCoreDash:SetPOCombo({{"line","Linha"}, {"bar","Barra"}}))
  oCoreDash:SetPOForm("Filtros"        , "dateIni"         , 6, "Data Inicial"           , .T., 'date'   , , .T.)
  oCoreDash:SetPOForm(""               , "dateFim"         , 6, "Data Final"             , .T., 'date'   , , .T.)

  oResponse  := oCoreDash:GetPOForm()

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.
  
WSMETHOD POST retDados WSRECEIVE JsonFilter WSSERVICE CAFATI02
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
    aAdd( aData1, retTotais("qtd_nf"     , cFiltros + " and SF1.F1_DTDIGIT between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )
    aAdd( aData2, retTotais("val_brut"   , cFiltros + " and SF1.F1_DTDIGIT between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )
    aAdd( aData3, retTotais("val_liquido", cFiltros + " and SF1.F1_DTDIGIT between '"+aInterv[nI,1]+"' and '"+aInterv[nI,2]+"'") )

    cIAnoAnt := DtoS( YearSub( StoD(aInterv[nI,1]), 1 ) )
    cFAnoAnt := DtoS( YearSub( StoD(aInterv[nI,2]), 1 ) )

    aAdd( aData4, retTotais("qtd_nf"     , cFiltros + " and SF1.F1_DTDIGIT between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
    aAdd( aData5, retTotais("val_brut"   , cFiltros + " and SF1.F1_DTDIGIT between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
    aAdd( aData6, retTotais("val_liquido", cFiltros + " and SF1.F1_DTDIGIT between '"+cIAnoAnt+"' and '"+cFAnoAnt+"'") )
  next

  oCoreDash:SetChartInfo( aData4, 'Qtde NF Anterior'    , , aCores[8][3] ) //Cor utilizada: OrangeLht
  oCoreDash:SetChartInfo( aData5, 'Val Bruto Anterior'  , , aCores[6][3] ) //Cor utilizada: YellowDk
  oCoreDash:SetChartInfo( aData6, 'Val Liquido Anterior', , aCores[16][3] ) //Cor utilizada: BrowDk

  oCoreDash:SetChartInfo( aData1, 'Qtde NF'    , , aCores[7][3] ) //Cor utilizada: OrangeLht
  oCoreDash:SetChartInfo( aData2, 'Val Bruto'  , , aCores[5][3] ) //Cor utilizada: YellowDk
  oCoreDash:SetChartInfo( aData3, 'Val Liquido', , aCores[15][3] ) //Cor utilizada: BrowDk

  aAdd(aDataFim, oCoreDash:SetChart(aCab,,.F., ,"Devolucoes mes a mes"))

  oResponse["items"] := aDataFim
return nil
  
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL CAFATI02
  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError      := "Erro na Requisicao"
  Local lRet        := .T.
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
  
  Self:SetContentType("application/json")

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
      {"doc"       , "F1_DOC"},;
      {"serie"     , "F1_SERIE"},;
      {"emissao"   , "F1_DTDIGIT"},;
      {"cliente"   , "F1_FORNECE"},;
      {"loja"      , "F1_LOJA"},;
      {"nome"      , "A1_NOME"},;
      {"item"      , "D1_ITEM"},;
      {"produto"   , "D1_COD"},;
      {"descricao" , "B1_DESC"},;
      {"quant"     , "D1_QUANT", "N"},;
      {"prcunit"   , "D1_VUNIT", "N"},;
      {"total"     , "D1_TOTAL", "N"},;
      {"valbruto"  , "F1_VALBRUT", "N"},;
      {"valliquido", "F1_VALMERC", "N"};
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

  cQuery := " SELECT F1_DOC, F1_SERIE, F1_DTDIGIT, F1_FORNECE, F1_LOJA, SA1.A1_NOME "
  cQuery += ", F1_VALBRUT, F1_VALMERC, D1_ITEM, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL"
  cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
  cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
  cQuery +=   " on  SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
  cQuery +=   " and SA1.A1_COD  = F1_FORNECE "
  cQuery +=   " and SA1.A1_LOJA = F1_LOJA "
  cQuery +=   " and SA1.D_E_L_E_T_ = ' ' "
  cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1 "
  cQuery +=   " on  D1_FILIAL  = '"+xFilial("SD1")+"'"
  cQuery +=   " and D1_DOC     = F1_DOC "
  cQuery +=   " and D1_SERIE   = F1_SERIE "
  cQuery +=   " and D1_FORNECE = F1_FORNECE "
  cQuery +=   " and D1_LOJA    = F1_LOJA "
  cQuery +=   " and SD1.D_E_L_E_T_ = ' ' "
  cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
  cQuery +=   " on  B1_FILIAL = '"+xFilial("SB1")+"'"
  cQuery +=   " and B1_COD    = D1_COD "
  cQuery +=   " and SB1.D_E_L_E_T_ = ' ' "

  cWhere := " SF1.D_E_L_E_T_ = ' ' "
  cWhere += " AND F1_FILIAL = '" + xFilial("SF1") + "' "
  cWhere += " AND F1_TIPO = 'D' "

  if ! empty( oJsonFilter["dateIni"] )
    cWhere += " AND F1_DTDIGIT between '"+strTran(oJsonFilter["dateIni"],"-","")+"' and '"+strTran(oJsonFilter["dateFim"],"-","")+"'"
  endif

Return {cQuery, cWhere, cGroup}
  
Static Function retTotais( cItem, cFiltro)
  Local aQuery
  Local cQuery  := ""
  Local cTemp   := GetNextAlias()
  Local xRet

  if cItem == "qtd_nf"
    aQuery  := MntQuery3("COUNT(DISTINCT F1_DOC) TOTAL_REGISTROS", cFiltro)
  elseif cItem == "val_brut"
    aQuery  := MntQuery3("SUM(F1_VALBRUT) TOTAL_REGISTROS", cFiltro)
  elseif cItem == "val_liquido"
    aQuery  := MntQuery3("SUM(F1_VALMERC) TOTAL_REGISTROS", cFiltro)
  endif

  cQuery := aQuery[1] + " WHERE " + aQuery[2]

  DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .T., .T. )

  xRet := (cTemp)->TOTAL_REGISTROS

  (cTemp)->( DBCloseArea() )
Return xRet
  
Static Function MntQuery3(cCampos, cFiltro, cGroupBy)
  Local cQuery
  Local cWhere
  Local cGroup

  Default cCampos  := ""
  Default cFiltro  := ""
  Default cGroupBy := ""

  cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SF1") + " SF1 "

  cWhere := " F1_FILIAL = '" + xFilial("SF1") + "'" + cFiltro
  cWhere += " AND F1_TIPO = 'D' "
  cWhere += " AND SF1.D_E_L_E_T_ = ' ' "

  If !Empty(cGroupBy)
      cGroup := cGroupBy
  EndIf
Return {cQuery, cWhere, cGroup}
