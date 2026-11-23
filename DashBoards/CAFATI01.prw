#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

/*/{Protheus.doc} CAFATI01
    Serviço de pedidos em geral
    
    @author Rodrigo dos Santos Brandão
    @since 04/10/2025
    @type class
/*/
WSRESTFUL CAFATI01 DESCRIPTION "EndPoint Pedidos Geral" FORMAT "application/json"
    WSDATA Fields           AS STRING   OPTIONAL
    WSDATA Order            AS STRING   OPTIONAL
    WSDATA Page             AS INTEGER  OPTIONAL
    WSDATA PageSize         AS INTEGER  OPTIONAL

    WSMETHOD POST itemsDetails ;
        DESCRIPTION "Itens Utilizados para Montagem do Painel" ;
        WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
        PATH "/cards/itemsDetails";
        PRODUCES APPLICATION_JSON
   
    WSMETHOD GET cardFilter;
        DESCRIPTION "Disponibiliza os campos que poderao ser utilizados no filtro do Card" ;
        WSSYNTAX "/cards/cardFilter/" ;
        PATH "/cards/cardFilter";
        PRODUCES APPLICATION_JSON
   
    WSMETHOD GET cardInfo;
        DESCRIPTION "Carrega as informacoes do Painel" ;
        WSSYNTAX "/cards/cardInfo/" ;
        PATH "/cards/cardInfo";
        PRODUCES APPLICATION_JSON
   
    WSMETHOD GET fieldsInfo ;
        DESCRIPTION "Carrega os campos que podem que ser utilizados" ;
        WSSYNTAX "/cards/fieldsInfo/" ;
        PATH "/cards/fieldsInfo";
        PRODUCES APPLICATION_JSON
ENDWSRESTFUL

WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CAFATI01
    Local aHeader       := {}
    Local aRet          := {}
    Local aFilter       := {}

    Local cError        := "Erro na Requisicao"
    Local cFilter       := ""
    Local cBody         := DecodeUtf8(Self:GetContent())
    Local cCampos       := ""

    Local lRet          := .T.
    
    Local oCoreDash     := CoreDash():New()
    
    Local nQtdFilter    := 0
    Local nX            := 0
    
    Local oBody         := JsonObject():New()
    Local oJDetails     := JsonObject():New()

    Self:SetContentType("application/json")

    IF !Empty(cBody)
        oBody:FromJson(cBody)
        IF ValType(oBody["detailFilter"]) == "A"
            oJDetails := oBody["detailFilter"]
        EndIF
    EndIF

    aHeader := RetHeader("SC6")
    oCoreDash:SetFields(DePara("SC6"))
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()
    nQtdFilter := Len(aFilter)
    IF nQtdFilter > 0
        For nX := 1 To nQtdFilter
            cFilter += " AND " + aFilter[nX][1]
        Next
    EndIF

    IF cFilter == " AND  C5_EMISSAO >= '        '  AND  C5_EMISSAO <= '        ' "  
        cFilter := " AND  C5_EMISSAO >= '        ' "
    EndIF

    cCampos := "SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_CLI, SC6.C6_LOJA, SA1.A1_NOME"
    cCampos += ", SC5.C5_EMISSAO, SC6.C6_PRODUTO, SC6.C6_DESCRI, SC6.C6_PRCVEN"
    cCampos += ", SC6.C6_QTDVEN, SC6.C6_VALOR, SC6.C6_LOTECTL, SC6.C6_NUMLOTE"
    cCampos += ", SC6.C6_NUMSERI"
    aRet := MntQuery( cCampos, cFilter,,"SC6")

    oCoreDash:SetQuery(aRet[1])
    oCoreDash:SetWhere(aRet[2])
    IF Len(aRet) >= 3
        oCoreDash:SetGroupBy(aRet[3])
    EndIF

    oCoreDash:BuildJson()
    lRet := ValType(oCoreDash:GetJsonObject()['items']) == "A"
   
    IF lRet
        oCoreDash:SetPOHeader(aHeader)
        Self:SetResponse( oCoreDash:ToObjectJson())
    ELSE
        SetRestFault(500,  EncodeUtf8(cError))
    EndIF
   
    oCoreDash:Destroy()
   
    aSize(aRet, 0)
    aSize(aHeader, 0)
Return lRet
  
Static Function MntQuery(cCampos, cFiltro, cGroupBy, cTable)
    Local cQuery
    Local cWhere
    Local cGroup
    DEFAULT cTable := "SC6"
    DEFAULT cCampos := ""

    If cTable == "SC6"
        cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SC5") + " SC5 "
        cQuery += " JOIN " + RetSqlName("SC6") + " SC6 "
        cQuery +=       " ON  C6_FILIAL = C5_FILIAL"
        cQuery +=       " AND C6_NUM    = C5_NUM"
        cQuery +=       " AND SC6.D_E_L_E_T_ = ' '"
        cQuery += " JOIN " + RetSqlName("SA1") + " SA1 "
        cQuery +=       " ON  A1_FILIAL = '"+xFilial("SA1")+"'"
        cQuery +=       " AND A1_COD    = C5_CLIENTE"
        cQuery +=       " AND A1_LOJA   = C5_LOJACLI"
        cQuery +=       " AND SA1.D_E_L_E_T_ = ' '"

        cWhere := " SC5.C5_FILIAL = '" + xFilial("SC5") + "'" + cFiltro
        cWhere += " AND SC5.C5_TIPO = 'N' "
        cWhere += " AND SC5.C5_NOTA = ' ' "
        cWhere += " AND SC5.D_E_L_E_T_ = ' ' "

    ElseIf cTable == "SE1"
        cQuery  := " SELECT " + cCampos + " FROM " + RetSqlName("SE1") + " SE1 "

        cFiltro := strTran( cFiltro, "C5_EMISSAO", "E1_EMISSAO" )
        cFiltro := strTran( cFiltro, "C5_CLIENTE", "E1_CLIENTE" )
        cFiltro := strTran( cFiltro, "C5_LOJACLI", "E1_LOJA" )

        cWhere  := " SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
        cWhere  += " AND SE1.D_E_L_E_T_ = ' ' "
        cWhere  += cFiltro
    EndIf
  
    If !Empty(cGroupBy)
        cGroup := cGroupBy
    EndIf
Return {cQuery, cWhere, cGroup}
  
Static Function DePara(cTable)
    Local aCampos := {}
    Default cTable := "SC6"

    If cTable == "SC6"
        aCampos := {;
        {"num"        , "C6_NUM"},;
        {"item"       , "C6_ITEM"},;
        {"customer"   , "C6_CLI"},;
        {"store"      , "C6_LOJA"},;
        {"name"       , "A1_NOME"},;
        {"emission"   , "C5_EMISSAO"},;
        {"product"    , "C6_PRODUTO"},;
        {"description", "C6_DESCRI"},;
        {"price"      , "C6_PRCVEN"},;
        {"amount"     , "C6_QTDVEN"},;
        {"total"      , "C6_VALOR"},;
        {"lote"       , "C6_LOTECTL"},;
        {"sub-lote"   , "C6_NUMLOTE"},;
        {"serie"      , "C6_NUMSERI"};
        }
    elseif cTable == "SE1"
        aCampos := {;
        {"prefixo" , "E1_PREFIXO"},;
        {"numero"  , "E1_NUM"},;
        {"parcela" , "E1_PARCELA"},;
        {"tipo"    , "E1_TIPO"},;
        {"emission", "E1_EMISSAO"},;
        {"vencto"  , "E1_VENCTO"},;
        {"valor"   , "E1_VALOR"},;
        {"saldo"   , "E1_SALDO"};
        }
    EndIf
Return aCampos

WSMETHOD GET cardInfo WSSERVICE CAFATI01
    Local aFilter       := {}
    Local cWhere        := ""
    Local nFiltro       := 0
    Local oCoreDash     := CoreDash():New()
    Local oResponse     := JsonObject():New()

    oCoreDash:SetFields(DePara())

    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()

    For nFiltro := 1 to Len(aFilter)
        cWhere += " AND " + aFilter[nFiltro][1]
    Next

    RetCardInfo(@oResponse, cWhere)

    self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )

    oResponse := Nil
    FreeObj( oResponse )

    oCoreDash:Destroy()
    FreeObj( oCoreDash )
return .T.

Static Function RetCardInfo(oResponse, cApiFilter)
    Local   oItem      := JsonObject():New()
    Local   aItems     := {}
    Default cApiFilter := ""

    oItem["total_ped"]   := RetCrdInfo("total_ped"  , cApiFilter)
    oItem["total_item"]  := RetCrdInfo("total_item" , cApiFilter)
    oItem["total_dup"]   := RetCrdInfo("total_dup"  , cApiFilter)
    oItem["total_valor"] := RetCrdInfo("total_valor", cApiFilter)
    aAdd(aItems, oItem)
   
    oResponse['hasNext'] := 'false'
    oResponse["items"]   := aItems
Return Nil

Static Function RetCrdInfo( cItem, cFiltro)
    Local aQuery
    Local cQuery  := ""
    Local cTemp   := GetNextAlias()
    Local xRet
    Local cPicture := "@E 999,999,999,999,999.99"

    if cFiltro == " AND  C5_EMISSAO >= '        '  AND  C5_EMISSAO <= '        ' "  
        cFiltro := " AND  C5_EMISSAO >= '        ' "
    endif

    if cItem == "total_ped"
        aQuery  := MntQuery("COUNT(DISTINCT C5_NUM) TOTAL_REGISTROS", cFiltro, , "SC6")
        cPicture := "@E 999,999,999,999"
    elseif cItem == "total_item"
        aQuery  := MntQuery("COUNT(*) TOTAL_REGISTROS"              , cFiltro, , "SC6")
        cPicture := "@E 999,999,999,999"
    elseif cItem == "total_dup"
        aQuery  := MntQuery("SUM(E1_SALDO) TOTAL_REGISTROS"         , cFiltro, , "SE1")
    elseif cItem == "total_valor"
        aQuery  := MntQuery("SUM(C6_VALOR) TOTAL_REGISTROS"         , cFiltro, , "SC6")
    endif

    cQuery := aQuery[1] + " WHERE " + aQuery[2]
    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .T., .T. )

    xRet := (cTemp)->TOTAL_REGISTROS
    xRet := alltrim( transform( xRet, cPicture ) )

    (cTemp)->( DBCloseArea() )
Return xRet
  
WSMETHOD GET fieldsInfo WSSERVICE CAFATI01
    Local aItems        := {} 
    Local oResponse     :=  JsonObject():New()
    Local oCoreDash     := CoreDash():New()
   
    aAdd(aItems, { "total_ped"  , "Total de Pedidos: " })
    aAdd(aItems, { "total_item" , "Total de Itens: " })
    aAdd(aItems, { "total_dup"  , "Total de Duplicata: R$ " })
    aAdd(aItems, { "total_valor", "Valor Total: R$ " })
   
    /*Retorna um Objeto no formato de Value e Label*/
    oResponse["items"] := oCoreDash:SetPOCombo(aItems)
   
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.
  
WSMETHOD GET cardFilter WSSERVICE CAFATI01
    Local aFields       := {}
    Local oCoreDash     := CoreDash():New()
    Local oResponse     := JsonObject():New()

    aFields := {;
        {"code"       , "Codigo"       },;
        {"store"      , "Loja"         },;
        {"emission"   , "Emissao"      };
    }

    oResponse["items"] := oCoreDash:SetPOHeader(aFields)
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.
  
Static Function RetHeader(cTable)
    Local aHeader
    Default cTable := "SC6"

    If cTable == "SC6"
        aHeader := {;
            {"num"        , "Pedido"           ,,,,.T.},;
            {"item"       , "Item"             ,,,,.T.},;
            {"customer"   , "Cliente"          ,,,,.T.},;
            {"store"      , "Loja"             ,,,,.T.},;
            {"name"       , "Nome Cliente"     ,,,,.T.},;
            {"emission"   , "Emissao"          ,,,,.T.},;
            {"product"    , "Produto"          ,,,,.T.},;
            {"description", "Descricao Produto",,,,.T.},;
            {"price"      , "Preco Venda"      ,,,,.T.},;
            {"amount"     , "Quantidade"       ,,,,.T.},;
            {"total"      , "Total"            ,,,,.T.},;
            {"lote"       , "Lote"             ,,,,.T.},;
            {"sub-lote"   , "Sub-lote"         ,,,,.T.},;
            {"serie"      , "Numero de Serie"  ,,,,.T.};
            }
    elseif cTable == "SE1"
        aHeader := {;
            {"prefixo", "Prefixo"   ,,,,.T.},;
            {"numero" , "Numero"    ,,,,.T.},;
            {"parcela", "Parcela"   ,,,,.T.},;
            {"tipo"   , "Tipo"      ,,,,.T.},;
            {"vencto" , "Vencimento",,,,.T.},;
            {"valor"  , "Valor"     ,,,,.T.},;
            {"saldo"  , "Saldo"     ,,,,.T.};
            }
    EndIf
Return aHeader
