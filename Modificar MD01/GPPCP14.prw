/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPPCP14      ºAutor  ³LUCIANO          º Data ³  28/07/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³   Tela consulta rápida MD01                                º±±
±±º          ³   Apoio para o relatório de cobertura do MRP               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± 23/08/20 - ACRESCIMO DO CAMPO BZ_ZZPLANER E ABATER LOCAL NC             ±±
±± 29/11/21 - TRATATIVA PARA SD4 COM O D4_COD XTIPO == "PA"                ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#INCLUDE "PROTHEUS.CH"
#include "tbiconn.ch"

User Function GPPCP14()
	
Private oLbx2    := Nil
Private oLbx3    := Nil
Private bLbx3    := {}
Private aLbx3    := {"Material","Data","Doc Entrada","Qtde Entrada","Doc Saida","Qtde Saida","Saldo","Status ","SI Vinculada?","Cliente/Fornecedor"}	

Private aItens2   := {'','',0,'','',0,0,'','',''}
Private aItens3   := {'','',0,'','',0,0,'','',''}

Private oTimer
Private cCod     := SPACE(24)

PRIVATE CTMD01   := TIME()

Private nMilissegundos := 0 //EXEPLO 60000 // Disparo será de 1 em 1 segundos

oDlg1 := MSDialog():New( 092,232,700,1487,"Tela de consulta rápida MD01 - "+DTOC(DDATABASE)+" - "+CTMD01,,,.F.,,,,,,.T.,,,.T. )

odlg1:CTOOLTIP := "consulta tela MD01 materiais"

PRIVATE XDESC    := SPACE(40)    
PRIVATE XTIPO    := SPACE(2)
PRIVATE XGRUPO   := SPACE(5)    
PRIVATE XQE      := 0
PRIVATE XPE      := 0
PRIVATE xESTSEG  := 0
PRIVATE xESTMULT := 0
PRIVATE xESTMIN  := 0
PRIVATE xESTATU  := 0    
PRIVATE xEST55   := 0   
PRIVATE xCONMED  := 0  
PRIVATE xCONMES  := 0  
PRIVATE xCUSTO   := 0
PRIVATE xTIPE    := ""
Private xQtdVen  := 0
Private xQtdFat  := 0
Private dDatap   := CTOD("  /  /  ")   
Private cDtini   := ""
Private cDtfim   := ""
Private cQuery   := ""
Private xDescCom := ""
Private aLotes     := {}


     
@ 005,005 SAY "Item:" SIZE 150, 20 OF oDlg1 PIXEL
@ 0.2,003 MSGET cCod F3 "SB1" VALID FOKSB1()
@ 017,005 SAY "Descrição: "+XDESC SIZE 150, 20 OF oDlg1 PIXEL
@ 005,300 SAY "Qtde Embalagem:" SIZE 150, 20 OF oDlg1 PIXEL
@ 005,360 SAY TRANSFORM(xQE,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEL    
@ 005,180 SAY "Tipo  : " SIZE 150, 20 OF oDlg1 PIXEL    
@ 017,180 SAY "Grupo : " SIZE 150, 20 OF oDlg1 PIXEL 
@ 0.2,025 MSGET XTIPO F3 "02" VALID A010Tipo() WHEN .F.                                                                                                                     
@ 1.1,025 MSGET XGRUPO F3 "SBM" VALID A010Grupo() WHEN .F.
@ 017,240 SAY "Lead Time: "+ALLTRIM(TRANSFORM(xPE,"@E 999,999"))+" "+xTIPE  SIZE 150, 20 OF oDlg1 PIXEL
@ 005,400 SAY "Estoque Segurança: " SIZE 150, 20 OF oDlg1 PIXEL
@ 005,460 SAY TRANSFORM(xESTSEG,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEL
@ 005,520 SAY "Lote Mínimo:" SIZE 150, 20 OF oDlg1 PIXEL
@ 005,560 SAY TRANSFORM(xESTMIN,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEL
@ 015,300 SAY "Estoque Disponível:" SIZE 150, 20 OF oDlg1 PIXEL
@ 015,360 SAY TRANSFORM(xESTATU,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEL
@ 015,400 SAY "Saldo Atual no AC:" SIZE 150, 20 OF oDlg1 PIXEL
@ 015,460 SAY TRANSFORM(xEST55,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEl
@ 015,520 SAY "Lote Economico:" SIZE 150, 20 OF oDlg1 PIXEL
@ 015,560 SAY TRANSFORM(xESTMULT,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEL
@ 026,170 SAY "Consumo médio mensal últimos 12 meses: " SIZE 150, 20 OF oDlg1 PIXEL
@ 026,265 SAY TRANSFORM(xCONMED,"@E 99,999,999.999") SIZE 150, 20 OF oDlg1 PIXEL
@ 026,300 SAY "Qtde utilizada no último mês: " SIZE 150, 20 OF oDlg1 PIXEL
@ 026,380 SAY TRANSFORM(xCONMES,"@E 99,999,999.999") SIZE 150, 20 OF oDlg1 PIXEL 
@ 026,480 SAY "Custo médio do item: " SIZE 150, 20 OF oDlg1 PIXEL
@ 026,560 SAY TRANSFORM(xCUSTO,"@E 999,999.999") SIZE 150, 20 OF oDlg1 PIXEL 
@ 036,300 SAY "Qtde vendida nos últimos 30 dias: " SIZE 150, 20 OF oDlg1 PIXEL
@ 036,380 SAY TRANSFORM(xQtdVen,"@E 99,999,999.999") SIZE 150, 20 OF oDlg1 PIXEL 
@ 036,480 SAY "Qtde faturada nos últimos 30 dias: " SIZE 150, 20 OF oDlg1 PIXEL
@ 036,555 SAY TRANSFORM(xQtdFat,"@E 99,999,999.999") SIZE 150, 20 OF oDlg1 PIXEL 
@ 065,005 LISTBOX oLbx3 FIELDS HEADER "" SIZE 510,250  OF oDlg1 PIXEL
oLbx3:aColumns  := aLbx3
oLbx3:aHeaders  := oLbx3:aColumns
oLbx3:lUseDefaultColors := .F.      

ItenMD01(1)

//oBtn1 := TButton():New( 003,530,"Fechar    ",oDlg1,{||oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
oBtn2 := TButton():New( 003,250,"Executar  ",oDlg1,{||itenMD01(2)},037,012,,,,.T.,,"",,,,.F. )
oBtn3 := TButton():New( 003,590,"Refresh...",oDlg1,{||reftime()},030,012,,,,.T.,,"",,,,.F. )
oBtn4 := TButton():New( 040,005,"Desc.Comp.",oDlg1,{||xMemo(xDescCom) },050,012,,,.F.,.T.,.F.,,.F.,,,.F.)
oBtn5 := TButton():New( 040,070,"Lotes Existentes",oDlg1,{|| fMSNewGe3(cCod) },050,012,,,,.T.,,"",,,,.F.)

ACTIVATE MSDIALOG oDlg1 CENTERED
    
Return    

static function reftime()            
 
  PRIVATE nGetTime := 0

  DEFINE MSDIALOG oDlgT TITLE "Tempo de Refresh" FROM 000, 000  TO 100, 230 COLORS 0, 16777215 PIXEL

  @ 013, 068 MSGET oGet1 VAR nGetTime SIZE 031, 010 OF oDlgT PICTURE "@E 9999" COLORS 16711680, 16777215 PIXEL
  @ 013, 010 SAY oSay1 PROMPT "Tempo (Minutos):" SIZE 054, 011 OF oDlgT COLORS 0, 16777215 PIXEL
  DEFINE SBUTTON oSButton1 FROM 031, 044 TYPE 01 OF oDlgT ENABLE ACTION FOKTMP()

  ACTIVATE MSDIALOG oDlgT CENTERED

return

STATIC FUNCTION FOKTMP()

nMilissegundos := nGetTime * 60000

if nMilissegundos == 0 
  IF TYPE("oTimer") == "O"
    ALERT("Refresh desativado...") 
    oTimer:lActive := .F.   
  ENDIF
else  
  alert("Timer ativado para atualizar a cada: "+alltrim(str(nGetTime))+" Minuto(s)")
  oTimer := TTimer():New(nMilissegundos, {|| FOK() }, oDlg1 )
  oTimer:Activate()
endif   

oDlgT:end()

return

static function fok()

//if msgyesno("Atualizar tela ?")
   ItenMD01(2)
//endif

return

/*=================================================================
Autor: Otávio Barreiro
Data: 22/05/2026
Consultoria: TecSistem
Uso: Calibre
Info: FOKSB1 Validação ao inserir o Produto no campo de busca, trazendo as informações principais do produto.
*==================================================================*/
Static Function FOKSB1()

   Local cLocpad := ""

   xDesc    := ""   
   xTipo    := SPACE(2)  
   xGrupo   := SPACE(5)
   xQE          := 0
   xPE          := 0
   xEstseg      := 0
   xEstmult     := 0
   xEstmin      := 0
   xEst55       := 0
   xEstatu      := 0   
   xConmed      := 0  
   xConmes      := 0  
   xCusto       := 0
   xTipe        := ""
   dDatap       := CTOD("  / /  ")
   
   IF EMPTY(cCod)
      
      xDesc    := ""   
      xTipo    := SPACE(2)  
      xGrupo   := SPACE(5)
      xQE      := 0
      xPE      := 0
      xEstseg  := 0
      xEstmult := 0
      xEstmin  := 0
      xEst55   := 0
      xEstatu  := 0   
      xConmed  := 0  
      xConmes  := 0  
      xCusto   := 0
      xTipe    := ""
      dDatap   := CTOD("  / /  ")
      
      Return .T.    
      
   ENDIF    

   DbSelectArea("SB1")
   SB1->(DbSetOrder(1))
   If SB1->(DbSeek(xFilial("SB1")+cCod))

      cQuery := "SELECT B1_DESC, "
      cQuery += "B1_TIPO, "
      cQuery += "B1_GRUPO, "
      cQuery += "B1_QE, "
      cQuery += "B1_PE, "
      cQuery += "B1_ESTSEG, "
      cQuery += "B1_LE, "
      cQuery += "B1_LM, "
      cQuery += "B1_TIPE, "
      cQuery += "B1_LOCPAD, "
      cQuery += "ISNULL(CAST(CAST(B1_CRVDEPO AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS B1_CRVDEPO "
      cQuery += " FROM "+RetSQLName("SB1") + " SB1"
      cQuery += " WHERE B1_COD = '"+cCod+"'"
      cQuery += "   AND B1_FILIAL = '"+xFilial("SB1")+"'"
      cQuery += "   AND D_E_L_E_T_ <> '*'"

      cQuery:=ChangeQuery(cQuery)
      DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAlias", .F., .T.)

      XDesc     := SUBSTR(cAlias->B1_DESC,1,40)   
      XTipo     := cAlias->B1_TIPO        
      XGrupo    := cAlias->B1_GRUPO
      xQE       := cAlias->B1_QE
      xPE       := cAlias->B1_PE
      xEstseg   := cAlias->B1_ESTSEG
      xEstmult  := cAlias->B1_LE
      xEstmin   := cAlias->B1_LM
      cLocpad   := cAlias->B1_LOCPAD
      xDescCom  := cAlias->B1_CRVDEPO

      IF cAlias->B1_TIPE == "H"
         xTIPE  := "Horas"
      ENDIF
      IF cAlias->B1_TIPE == "D"
         xTIPE  := "Dias"   
         IF cAlias->B1_PE > 0
            dDATAP := Datavalida(DaySum(dDatabase,cAlias->B1_PE),.F.) 
         ENDIF 
      ENDIF
      IF cAlias->B1_TIPE == "S"
         xTIPE  := "Semana"  
         IF cAlias->B1_PE > 0
            dDATAP := Datavalida(DaySum(dDatabase,(cAlias->B1_PE*7)),.F.)
         ENDIF
      ENDIF
      IF cAlias->B1_TIPE == "M"
         xTIPE  := "Mes"    
         IF cAlias->B1_PE > 0
            dDATAP := Datavalida(MonthSum(dDatabase,cAlias->B1_PE),.F.) 
         ENDIF 
      ENDIF
      IF cAlias->B1_TIPE == "A"
         xTIPE  := "Ano"  
      ENDIF       

      DbSelectArea("SB2")
      SB2->(DbSetOrder(1))
      If SB2->(DbSeek(xFilial("SB2")+AvKey(cCod,"B2_COD")))
         xEstatu := SB2->B2_QATU
      EndIf
      
      DbSelectArea("SB2")
      SB2->(DbSetOrder(1))
      If SB2->(DbSeek(xFilial("SB2")+AvKey(cCod,"B2_COD")+AvKey("AC","B2_LOCAL")))
         xEst55 := SB2->B2_QATU
      EndIf

      cAlias->(DbCloseArea()) 

      cDtini := Substr(DToS(MonthSub(dDatabase,12)),1,6)+"01"
      cDtfim := DToS(ddatabase)
      
      cQuery := " SELECT ROUND(SUM(D3_QUANT)/12,3) AS QTDE FROM "+RETSQLNAME("SD3")
      cQuery += " WHERE D3_COD = '"+cCod+"'"
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery += " AND D3_ESTORNO <> 'S' "
      cQuery += " AND ( D3_CF = 'RE0' OR D3_CF = 'RE1' ) "       
      cQuery += " AND D3_FILIAL = '"+XFILIAL("SD3")+"'"
      cQuery += " AND D3_EMISSAO >= '"+cDtini+"' AND D3_EMISSAO <= '"+cDtfim+"'"
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAlias", .F., .T.)

      DbSelectArea("cAlias")
      DbGoTop()
      IF !Eof() .AND. !Bof()
         xCONMED := cAlias->QTDE
      ENDIF
      cAlias->(DbCloseArea()) 
      
      cDtini := Substr(DToS(MonthSub(dDatabase,1)),1,6)+"01"
      cDtfim := DToS(Lastday(MonthSub(dDatabase,1)))
      
      cQuery := " SELECT ROUND(SUM(D3_QUANT),3) AS QTDE FROM "+RETSQLNAME("SD3")
      cQuery += " WHERE D3_COD = '"+cCod+"'"
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery += " AND D3_ESTORNO <> 'S' "
      cQuery += " AND ( D3_CF = 'RE0' OR D3_CF = 'RE1' ) "       
      cQuery += " AND D3_FILIAL = '"+XFILIAL("SD3")+"'"
      cQuery += " AND D3_EMISSAO >= '"+cDtini+"' AND D3_EMISSAO <= '"+cDtfim+"'"
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAlias", .F., .T.)

      DbSelectArea("cAlias")
      DbGoTop()
      IF !Eof() .AND. !Bof()
         xCONMES := cAlias->QTDE
      ENDIF
      cAlias->(DbCloseArea()) 

      cDtini := DToS(MonthSub(dDatabase,1))
      cDtfim := DToS(dDatabase)

      DbSelectArea("SC6")

      cQuery := " SELECT COUNT(*) AS QTDEVEN "
      cQuery += " FROM "+RETSQLNAME("SC6")+" SC6 "
      cQuery += " WHERE C6_PRODUTO = '"+cCod+"'"
      cQuery += " AND C6_FILIAL = '"+XFILIAL("SC6")+"'"
      cQuery += " AND C6_XEMISSA >= '"+cDtini+"' AND C6_XEMISSA <= '"+cDtfim+"'"
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAlias", .F., .T.)

      xQtdVen:= cAlias->QTDEVEN
      
      cAlias->(DbCloseArea()) 

      cDtini := DToS(MonthSub(dDatabase,1))
      cDtfim := DToS(dDatabase)

      cQuery := " SELECT COUNT(*) AS QTDEFAT "
      cQuery += " FROM "+RETSQLNAME("SD2")+" SD2 "
      cQuery += " WHERE D2_COD = '"+cCod+"'"
      cQuery += " AND D2_FILIAL = '"+XFILIAL("SD2")+"'"
      cQuery += " AND D2_EMISSAO >= '"+cDtini+"' AND D2_EMISSAO <= '"+cDtfim+"'"
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAlias", .F., .T.)

      xQtdFat:= cAlias->QTDEFAT

      cAlias->(DbCloseArea()) 

      cQuery := " SELECT * "
      cQuery += " FROM "+RETSQLNAME("SB9")+" SB9 "
      cQuery += " WHERE B9_FILIAL = '"+XFILIAL("SB9")+"'" 
      cQuery += " AND B9_COD = '"+cCod+"'"
      cQuery += " AND B9_LOCAL = '"+cLocpad+"'"
      cQuery += " AND B9_CM1 > 0 "
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery += " ORDER BY B9_DATA DESC "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAlias", .F., .T.)

      xCUSTO := cAlias->B9_CM1

      cAlias->(DbCloseArea()) 
   Else
    MsgAlert("Produto nao localizado !", "Atenção")
    Return .F.

   Endif

Return .T.

STATIC Function ItenMD01(xtip)
  
  CTMD01          := TIME()           
  odlg1:CTITLE    := "Tela de consulta rápida MD01 - "+DTOC(DDATABASE)+" - "+CTMD01   
  odlg1:CCAPTION  := "Tela de consulta rápida MD01 - "+DTOC(DDATABASE)+" - "+CTMD01 
  oDlg1:REFRESH()    
  
  processa({ || fokpro(xtip) })
    
return


static function fokpro(xtip)

   LOCAL XRECSB1 := SB1->(RECNO())
   Local xSaldo := 0 

   aItens2 := {}
   aItens3 := {}

   
   if xtip == 1
   
      AAdd(aItens2,{"",;
      "",;
      0,;
      "",;
      "",;
      0,;
      0,;
      "",;
      "",;
      ""})    

      oLbx2 := TCBrowse():New(055,005,610,250,,,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)                
      oLbx2:AddColumn(TCColumn():New("Doc Entrada", {|| aItens2[oLbx2:nAt,01]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Data de Entrega Entrada", {|| aItens2[oLbx2:nAt,02]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Qtde Entrada", {|| aItens2[oLbx2:nAt,03]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Doc Saida", {|| aItens2[oLbx2:nAt,04]},"@!",,,"LEFT", 050,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Data de Entrega Saida", {|| aItens2[oLbx2:nAt,05]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Qtde Saida", {|| aItens2[oLbx2:nAt,06]},"@!",,,"RIGHT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Saldo", {|| aItens2[oLbx2:nAt,07]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Status", {|| aItens2[oLbx2:nAt,08]},"@!",,,"CENTER", 050,.F.,.F.,,,,.F., ) ) 
      oLbx2:AddColumn(TCColumn():New("SI Vinculada?", {|| aItens2[oLbx2:nAt,09]},"@!",,,"CENTER", 050,.F.,.F.,,,,.F., ) )         
      oLbx2:AddColumn(TCColumn():New("Cliente/Fornecedor", {|| aItens2[oLbx2:nAt,10]},"@!",,,"CENTER", 050,.F.,.F.,,,,.F., ) ) 

      oLbx2:SetArray(aItens2)
      oLbx2:bWhen := { || Len(aItens2) > 0 }
      oLbx2:Show()
      oLbx2:Refresh()

      AAdd(aItens3,{"",;
      "",;
      0,;
      "",;
      "",;
      0,;
      0,;
      "",;
      "",;
      ""}) 

      oLbx3:SetArray(aItens3)
      oLbx3:bLine:= {|| { aItens3[oLbx3:nAt,1],;
      aItens3[oLbx3:nAt,2],;
      aItens3[oLbx3:nAt,3],;
      aItens3[oLbx3:nAt,4],;  
      aItens3[oLbx3:nAt,5],;   
      aItens3[oLbx3:nAt,6],;
      aItens3[oLbx3:nAt,7],; 
      aItens3[oLbx3:nAt,8],; 
      aItens3[oLbx3:nAt,9],;
      aItens3[oLbx3:nAt,10]}}
      oLbx3:hide()
      oLbx3:Refresh()
      
      return
      
            
      
   Else

      cQuery := " SELECT C7_NUM+C7_ITEM AS DOC_ENTRADA,C7_DATPRF AS DATA_ENTREGA, C7_QUANT AS QTDE_ENTRADA, C7_PO_EIC AS PO_EIC, C7_FORNECE AS FORNECEDOR, C7_LOJA AS LOJA "
      cQuery += " FROM "+RETSQLNAME("SC7")+" C7 "
      cQuery += " WHERE C7_PRODUTO = '"+cCod+"'"
      cQuery += " AND C7_FILIAL = '"+XFILIAL("SC7")+"'"
      cQuery += " AND C7_DATPRF > '"+DToS(dDatabase)+"' "
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery += " ORDER BY C7_DATPRF "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAliasC7", .F., .T.)

      cQuery := " SELECT C6_NUM+C6_ITEM AS DOC_SAIDA,C6_CRVENT AS DATA_ENTREGA, C6_QTDVEN AS QTDE_SAIDA, C6_XVINSW1 AS SI_VINCULADA, C6_CLI AS CLIENTE, C6_LOJA AS LOJA "
      cQuery += " FROM "+RETSQLNAME("SC6")+" C6 "
      cQuery += " WHERE C6_PRODUTO = '"+cCod+"'"
      cQuery += " AND C6_FILIAL = '"+XFILIAL("SC6")+"'"
      cQuery += " AND C6_CRVENT > '"+DToS(dDatabase)+"' "
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery += " ORDER BY C6_CRVENT "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAliasC6", .F., .T.)

      cQuery := " SELECT B2_QATU AS SALDO "
      cQuery += " FROM "+RETSQLNAME("SB2")+" B2 "
      cQuery += " WHERE B2_COD = '"+cCod+"'"
      cQuery += " AND D_E_L_E_T_ <> '*' "
      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAliasB2", .F., .T.)

      xSaldo := cAliasB2->SALDO

      While !cAliasC7->(EOF()) .OR. !cAliasC6->(EOF())

         If !cAliasC7->(EOF()) .AND. !cAliasC6->(EOF())

            If SToD(cAliasC7->DATA_ENTREGA) < SToD(cAliasC6->DATA_ENTREGA)

               AAdd(aItens2,{IIf(!Empty(cAliasC7->PO_EIC),cAliasC7->PO_EIC,cAliasC7->DOC_ENTRADA),;
               DToC(SToD(cAliasC7->DATA_ENTREGA)),;
               cAliasC7->QTDE_ENTRADA,;
               "",;
               "",;
               "",;
               xSaldo,;
               "",;
               "",;
               Alltrim(Posicione("SA2",1,xFilial("SA2")+cAliasC7->FORNECEDOR+cAliasC7->LOJA,"A2_NOME"))})

               cAliasC7->(DbSkip())
               xSaldo += cAliasC7->QTDE_ENTRADA

            ElseIf SToD(cAliasC7->DATA_ENTREGA) > SToD(cAliasC6->DATA_ENTREGA)

               AAdd(aItens2,{"",;
               "",;
               "",;
               cAliasC6->DOC_SAIDA,;
               DToC(SToD(cAliasC6->DATA_ENTREGA)),;
               cAliasC6->QTDE_SAIDA,;
               xSaldo,;
               "",;
               cAliasC6->SI_VINCULADA,;
               Alltrim(Posicione("SA1",1,xFilial("SA1")+cAliasC6->CLIENTE+cAliasC6->LOJA,"A1_NOME"))})

               cAliasC6->(DbSkip())
               xSaldo -= cAliasC6->QTDE_SAIDA

            ElseIf SToD(cAliasC7->DATA_ENTREGA) == SToD(cAliasC6->DATA_ENTREGA)

               cQuery := " SELECT D1_DOC AS DOCUMENTO, D1_SERIE AS SERIE, D1_FORNECE AS FORNECEDOR, D1_LOJA AS LOJA"
               cQuery += " FROM "+RETSQLNAME("SD1")+" D1 "
               cQuery += " WHERE D1_PEDIDO = '"+cAliasC7->C7_NUM+"'"
               cQuery += " AND D1_ITEMPC = '"+cAliasC7->C7_ITEM+"'"
               cQuery += " AND D_E_L_E_T_ <> '*' "
               cQuery := ChangeQuery(cQuery)
               dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAliasD1", .F., .T.)

               cQuery := " SELECT D2_DOC AS DOCUMENTO, D2_SERIE AS SERIE, D2_CLIENTE AS CLIENTE, D2_LOJA AS LOJA"
               cQuery += " FROM "+RETSQLNAME("SD2")+" D2 "
               cQuery += " WHERE D2_PEDIDO = '"+cAliasC6->C6_NUM+"'"
               cQuery += " AND D2_ITEMPV = '"+cAliasC6->C6_ITEM+"'"
               cQuery += " AND D_E_L_E_T_ <> '*' "
               cQuery := ChangeQuery(cQuery)
               dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "cAliasD2", .F., .T.)


               If Posicione("SF1",1,xFilial("SF1")+cAliasD1->DOCUMENTO+cAliasD1->SERIE+cAliasD1->FORNECEDOR+cAliasD1->LOJA,"F1_HORA") < Posicione("SF2",1,xFilial("SF2")+cAliasD2->DOCUMENTO+cAliasD2->SERIE+cAliasD2->CLIENTE+cAliasD2->LOJA,"F2_HORA")

                  AAdd(aItens2,{IIf(!Empty(cAliasC7->PO_EIC),cAliasC7->PO_EIC,cAliasC7->DOC_ENTRADA),;
                  DToC(SToD(cAliasC7->DATA_ENTREGA)),;
                  cAliasC7->QTDE_ENTRADA,;
                  "",;
                  "",;
                  "",;
                  xSaldo,;
                  "",;
                  "",;
                  Alltrim(Posicione("SA2",1,xFilial("SA2")+cAliasC7->FORNECEDOR+cAliasC7->LOJA,"A2_NOME"))})

                  cAliasC7->(DbSkip())
                  cAliasD1->(DbCloseArea()) 
                  cAliasD2->(DbCloseArea())
                  xSaldo += cAliasC7->QTDE_ENTRADA
   
               ElseIf  Posicione("SF1",1,xFilial("SF1")+cAliasD1->DOCUMENTO+cAliasD1->SERIE+cAliasD1->FORNECEDOR+cAliasD1->LOJA,"F1_HORA") > Posicione("SF2",1,xFilial("SF2")+cAliasD2->DOCUMENTO+cAliasD2->SERIE+cAliasD2->CLIENTE+cAliasD2->LOJA,"F2_HORA")

                  AAdd(aItens2,{"",;
                  "",;
                  "",;
                  cAliasC6->DOC_SAIDA,;
                  DToC(SToD(cAliasC6->DATA_ENTREGA)),;
                  cAliasC6->QTDE_SAIDA,;
                  xSaldo,;
                  "",;
                  cAliasC6->SI_VINCULADA,;
                  Alltrim(Posicione("SA1",1,xFilial("SA1")+cAliasC6->CLIENTE+cAliasC6->LOJA,"A1_NOME"))})

                  cAliasC6->(DbSkip())
                  cAliasD1->(DbCloseArea()) 
                  cAliasD2->(DbCloseArea())  
                  xSaldo -= cAliasC6->QTDE_SAIDA
               EndIf

            EndIf

         ElseIf !cAliasC7->(EOF()) .AND. cAliasC6->(EOF())

            AAdd(aItens2,{IIf(!Empty(cAliasC7->PO_EIC),cAliasC7->PO_EIC,cAliasC7->DOC_ENTRADA),;
            DToC(SToD(cAliasC7->DATA_ENTREGA)),;
            cAliasC7->QTDE_ENTRADA,;
            "",;
            "",;
            "",;
            xSaldo,;
            "",;
            "",;
            Alltrim(Posicione("SA2",1,xFilial("SA2")+cAliasC7->FORNECEDOR+cAliasC7->LOJA,"A2_NOME"))})
            
            cAliasC7->(DbSkip())
            xSaldo += cAliasC7->QTDE_ENTRADA

         ElseIf cAliasC7->(EOF()) .AND. !cAliasC6->(EOF())

            AAdd(aItens2,{"",;
            "",;
            "",;
            cAliasC6->DOC_SAIDA,;
            DToC(SToD(cAliasC6->DATA_ENTREGA)),;
            cAliasC6->QTDE_SAIDA,;
            xSaldo,;
            "",;
            cAliasC6->SI_VINCULADA,;
            Alltrim(Posicione("SA1",1,xFilial("SA1")+cAliasC6->CLIENTE+cAliasC6->LOJA,"A1_NOME"))})

            cAliasC6->(DbSkip())
            xSaldo -= cAliasC6->QTDE_SAIDA
            
         EndIf

      EndDo

      cAliasC7->(DbCloseArea()) 
      cAliasC6->(DbCloseArea()) 
      cAliasB2->(DbCloseArea()) 

      IF Len(aItens2) = 0
      
         AAdd(aItens2,{"",;
         "",;
         0,;
         "",;
         "",;
         0,;
         0,;
         "",;
         "",;
         ""})  
         
         
      ENDIF    
   

      oLbx2 := TCBrowse():New(055,005,610,250,,,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.,,,)                
      oLbx2:AddColumn(TCColumn():New("Doc Entrada", {|| aItens2[oLbx2:nAt,01]},"@!",,,"LEFT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Data de Entrega Entrada", {|| aItens2[oLbx2:nAt,02]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Qtde Entrada", {|| aItens2[oLbx2:nAt,03]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Doc Saida", {|| aItens2[oLbx2:nAt,04]},"@!",,,"LEFT", 050,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Data de Entrega Saida", {|| aItens2[oLbx2:nAt,05]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Qtde Saida", {|| aItens2[oLbx2:nAt,06]},"@!",,,"RIGHT", 040,.F.,.F.,,{|| .F. },,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Saldo", {|| aItens2[oLbx2:nAt,07]},"@!",,,"RIGHT", 010,.F.,.F.,,,,.F., ) )
      oLbx2:AddColumn(TCColumn():New("Status", {|| aItens2[oLbx2:nAt,08]},"@!",,,"CENTER", 050,.F.,.F.,,,,.F., ) ) 
      oLbx2:AddColumn(TCColumn():New("SI Vinculada?", {|| aItens2[oLbx2:nAt,09]},"@!",,,"CENTER", 050,.F.,.F.,,,,.F., ) )         
      oLbx2:AddColumn(TCColumn():New("Cliente/Fornecedor", {|| aItens2[oLbx2:nAt,10]},"@!",,,"CENTER", 050,.F.,.F.,,,,.F., ) ) 

      oLbx2:SetArray(aItens2)
      oLbx2:bWhen := { || Len(aItens2) > 0 }
      oLbx2:Show()
      oLbx3:Hide()
      oLbx2:Refresh()

   EndIf

   DBSELECTAREA("SB1")
   GO XRECSB1

Return       
 
/*=================================================================
Autor: Otávio Barreiro
Data: 22/05/2026
Consultoria: TecSistem
Uso: Calibre
Info: Memo
*==================================================================*/
Static Function xMemo(xDescCom)

	Local oDlgMemo  := Nil 
	Local oMemo     := Nil 
	Local cDescMemo := "Descrição Completa"

	Define MsDialog oDlgMemo Title cDescMemo From 000,000 TO 200,650 Pixel

	oMemo := TMultiget():New(006,006,{|u|IIf(PCount() > 0, xDescCom := u,xDescCom)},oDlgMemo,320,092,,,,,,.T.)

	//Ativação da janela Principal
	oDlgMemo:Activate(,,,.T.)

Return


/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 05/05/2025
Consultoria: Proativa
Uso: Calibre
Info: Filtro os lotes do produto
*==================================================================*/
Static Function xLotes(cProduto)

	Local aArea  := GetArea()
	Local cTemp  := GetNextAlias()
	Local cQuery := ""
   aLotes := {}
	
	cQuery := " SELECT * FROM "+RetSQLName("SB8") 
	cQuery += " WHERE B8_FILIAL = '"+xFilial("SB8")+"'"
	cQuery += " 	AND B8_PRODUTO = '"+cProduto+"'"
	cQuery += "		AND B8_SALDO > 0"
	cQuery += " 	AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY B8_LOTECTL"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
		
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)
		
	While !(cTemp)->(EOF())

		aAdd(aLotes,{SToD((cTemp)->B8_DTVALID),(cTemp)->B8_LOTECTL,((cTemp)->B8_SALDO - (cTemp)->B8_EMPENHO),(cTemp)->B8_SALDO,.F.})

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	RestArea(aArea)

Return 


/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 30/04/2025
Consultoria: Proativa
Uso: Calibre
Info: Grid Lotes Existentes
*==================================================================*/ 
Static Function fMSNewGe3(cProduto)
 
	Local nX           := 0
	Local aHeaderEx    := {}
	Local aFields      := {"B8_DTVALID","B8_LOTECTL","NPH_QTDDIS","B8_SALDO"}
   Local oMSNewGe3    := Nil
   Local oLote        := Nil

	//Populo o array com as informações para preencher a grid
	xLotes(cProduto)
	// ---
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 To Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx,{AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,/*SX3->X3_VALID*/"",SX3->X3_USADO,SX3->X3_TIPO,/*SX3->X3_F3*/"",SX3->X3_CONTEXT,/*SX3->X3_CBOX*/"",/*SX3->X3_RELACAO*/""})
		Endif 
		
	Next nX

   Define MsDialog oMSNewGe3 Title "Lotes Existentes" From 000,000 TO 400,1000 Pixel

	oLote := MsNewGetDados():New(006,006,400,800,,"AllwaysTrue()",,"",{},,9999,,,,oMSNewGe3,aHeaderEx,aLotes)
   	
	//Bloqueio de adição de linha 
	oLote:oBrowse:bAdd := {|| oMSNewGe3:AddLine(.F.,.F.) }

	//Atualização do browse
	oLote:Refresh()

   oMSNewGe3:Activate(,,,.T.)

Return
