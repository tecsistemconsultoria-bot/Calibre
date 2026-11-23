#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "topdef.ch"
#include "colors.ch"
#INCLUDE "rwmake.ch"
#include "sigawin.ch"
#include "set.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA265I   ºAutor  ³Ricardo Rech        º Data ³  04/19/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto entrada no Endereçamento de Produto                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA265I()
Local _nitem	:=paramixb[1]
Local _nquant	:= aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "DB_QUANT"})
Local _cProduto := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "DB_PRODUTO"})
Local _cLotectl	:= aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "DB_LOTECTL"})
Local _cLocal	:= aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "DB_LOCAL"})
Local _cLocaliz	:= aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "DB_LOCALIZ"})
Local lExecTela := GetMV("XX_XLOTE",.F.,.F.)
Local oDialog2
Local _lok:=0
Private _cLT1:=space(16)
Private _dVL1:=ddatabase
Private _nqt1:=acols[_nitem][_nquant]
Private _cLT2:=space(16)
Private _dVL2:=ddatabase
Private _nqt2:=0
Private _cLT3:=space(16)
Private _dVL3:=ddatabase
Private _nqt3:=0
Private _cLT4:=space(16)
Private _dVL4:=ddatabase
Private _nqt4:=0

If lExecTela

	If ALLTRIM(SDA->DA_LOTECTL) == "0002" .or. ALLTRIM(SDA->DA_LOTECTL) == "002"
	
		If MSGYESNO("Produto com Lote "+ALLTRIM(SDA->DA_LOTECTL)+", deseja transferir lote?")
			
			@ 020,010 To 370,680 Dialog oDialog2 Title "Transfere Lotes"
			
			@ 03,005 Say "Lote 1: " size 70,10
			@ 03,045 Get _cLT1 Picture "@!"  Valid .T. size 60,10
			@ 03,105 Say "Validade: " size 70,10
			@ 03,155 Get _dVL1 Picture "@!"  Valid .T. size 60,10
			@ 03,215 Say "Qtde: " size 70,10
			@ 03,250 Get _nqt1 Picture "@E 999,999,999.99"  Valid .T. size 60,10
			
			@ 23,005 Say "Lote 2: " size 70,10
			@ 23,045 Get _cLT2 Picture "@!"  Valid .T. size 60,10
			@ 23,105 Say "Validade: " size 70,10
			@ 23,155 Get _dVL2 Picture "@!"  Valid .T. size 60,10
			@ 23,215 Say "Qtde: " size 70,10
			@ 23,250 Get _nqt2 Picture "@E 999,999,999.99"  Valid .T. size 60,10
			
			@ 43,005 Say "Lote 3: " size 70,10
			@ 43,045 Get _cLT3 Picture "@!"  Valid .T. size 60,10
			@ 43,105 Say "Validade: " size 70,10
			@ 43,155 Get _dVL3 Picture "@!"  Valid .T. size 60,10
			@ 43,215 Say "Qtde: " size 70,10
			@ 43,250 Get _nqt3 Picture "@E 999,999,999.99"  Valid .T. size 60,10
			
			@ 63,005 Say "Lote 4: " size 70,10
			@ 63,045 Get _cLT4 Picture "@!"  Valid .T. size 60,10
			@ 63,105 Say "Validade: " size 70,10
			@ 63,155 Get _dVL4 Picture "@!"  Valid .T. size 60,10
			@ 63,215 Say "Qtde: " size 70,10
			@ 63,250 Get _nqt4 Picture "@E 999,999,999.99"  Valid .T. size 60,10
			
			@ 85,010 BmpButton Type 1 Action (_lok:=1,oDialog2:End ())
			@ 85,050 BmpButton Type 2 Action oDialog2:End ()
			Activate Dialog oDialog2 Centered
			
			iF _lok == 1
			
				If _nqt1+_nqt2+_nqt3+_nqt4 <> acols[_nitem][_nquant]
					msgalert("Quantidade dos Lotes difere quantidade Endereçada")
				Else
					// GERA TRANSFERENCIA
					
					aItensNew:={}
					_xDOCx:=nextnumero("SD3",2,"D3_DOC",.t.)
					
					aAdd (aItensNew,{ _xDOCx, ddatabase})
					
					aAdd ( aItensNew,{SDA->DA_PRODUTO,;
					LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
					SB1->B1_UM,;
					SDA->DA_LOCAL ,;
					acols[_nitem][_cLocaliz] ,;
					SDA->DA_PRODUTO,;
					LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
					SB1->B1_UM,;
					SDA->DA_LOCAL ,;
					acols[_nitem][_cLocaliz] ,;
					"",;
					SDA->DA_LOTECTL,;
					criavar('D3_NUMLOTE'),;
					criavar('D3_DTVALID'),;
					criavar('D3_POTENCI'),;
					_nqt1 ,;
					criavar("D3_QTSEGUM"),;
					criavar("D3_ESTORNO"),;
					criavar("D3_NUMSEQ"),;
					_cLT1,;
					_dVL1,;
					criavar("D3_ITEMGRD"),;
					""})

					lMsErroAuto := .F.
					
					MSExecAuto({|x| MATA261(x)},aItensNew,3)
					
					// Mostra Erro na geracao de Rotinas automaticas
					If lMsErroAuto
					
						Do While __lSX8
							ConfirmSX8()
						Enddo
						
						Mostraerro()
						
						Alert("ERRO GRAVACAO Transferencia 1")
						
					Else
						Alert("Transferencia 1 concluida.")
					EndIf
					
					If _nqt2>0
						
						aItensNew := {}
						
						_xDOCx := nextnumero("SD3",2,"D3_DOC",.t.)
						
						aAdd (aItensNew,{ _xDOCx, ddatabase})
						
						aAdd ( aItensNew,{SDA->DA_PRODUTO,;
						LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
						SB1->B1_UM,;
						SDA->DA_LOCAL ,;
						acols[_nitem][_cLocaliz] ,;
						SDA->DA_PRODUTO,;
						LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
						SB1->B1_UM,;
						SDA->DA_LOCAL ,;
						acols[_nitem][_cLocaliz] ,;
						"",;
						SDA->DA_LOTECTL,;
						criavar('D3_NUMLOTE'),;
						criavar('D3_DTVALID'),;
						criavar('D3_POTENCI'),;
						_nqt2 ,;
						criavar("D3_QTSEGUM"),;
						criavar("D3_ESTORNO"),;
						criavar("D3_NUMSEQ"),;
						_cLT2,;
						_dVL2,;
					criavar("D3_ITEMGRD"),;
					""})
						
						lMsErroAuto := .F.
						MSExecAuto({|x| MATA261(x)},aItensNew,3)
						
						// Mostra Erro na geracao de Rotinas automaticas
						If lMsErroAuto
							Do While __lSX8
								ConfirmSX8()
							Enddo
							Mostraerro()
							Alert("ERRO GRAVACAO Trasnferencia 2")
						Else
							Alert("Transferencia 2 concluida.")
						EndIf
						
					Endif
					
					If _nqt3 > 0
					
						aItensNew := {}
						
						_xDOCx := nextnumero("SD3",2,"D3_DOC",.t.)
						
						aAdd (aItensNew,{ _xDOCx, ddatabase})
						
						aAdd ( aItensNew,{SDA->DA_PRODUTO,;
						LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
						SB1->B1_UM,;
						SDA->DA_LOCAL ,;
						acols[_nitem][_cLocaliz] ,;
						SDA->DA_PRODUTO,;
						LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
						SB1->B1_UM,;
						SDA->DA_LOCAL ,;
						acols[_nitem][_cLocaliz] ,;
						"",;
						SDA->DA_LOTECTL,;
						criavar('D3_NUMLOTE'),;
						criavar('D3_DTVALID'),;
						criavar('D3_POTENCI'),;
						_nqt3 ,;
						criavar("D3_QTSEGUM"),;
						criavar("D3_ESTORNO"),;
						criavar("D3_NUMSEQ"),;
						_cLT3,;
						_dVL3,;
					criavar("D3_ITEMGRD"),;
					""})
				
						lMsErroAuto := .F.
						
						MSExecAuto({|x| MATA261(x)},aItensNew,3)
						
						// Mostra Erro na geracao de Rotinas automaticas
						If lMsErroAuto
							Do While __lSX8
								ConfirmSX8()
							Enddo
							Mostraerro()
							Alert("ERRO GRAVACAO Trasnferencia 3")
						Else
							Alert("Transferencia 3 concluida.")
						EndIf
					Endif
					
					If _nqt4>0
						aItensNew:={}
						_xDOCx:=nextnumero("SD3",2,"D3_DOC",.t.)
						
						aAdd (aItensNew,{ _xDOCx, ddatabase})
						
						aAdd ( aItensNew,{SDA->DA_PRODUTO,;
						LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
						SB1->B1_UM,;
						SDA->DA_LOCAL ,;
						acols[_nitem][_cLocaliz] ,;
						SDA->DA_PRODUTO,;
						LEFT(POSICIONE("SB1",1,xFILIAL("SB1")+SDA->DA_PRODUTO,"B1_DESC")+SPACE(60),60),;
						SB1->B1_UM,;
						SDA->DA_LOCAL ,;
						acols[_nitem][_cLocaliz] ,;
						criavar('D3_NUMLOTE'),;
						criavar('D3_DTVALID'),;
						criavar('D3_POTENCI'),;
						_nqt4 ,;
						criavar("D3_QTSEGUM"),;
						criavar("D3_ESTORNO"),;
						criavar("D3_NUMSEQ"),;
						_cLT4,;
						_dVL4,;
					criavar("D3_ITEMGRD"),;
					""})
						
						lMsErroAuto := .F.
						
						MSExecAuto({|x| MATA261(x)},aItensNew,3)
						
						// Mostra Erro na geracao de Rotinas automaticas
						If lMsErroAuto
							Do While __lSX8
								ConfirmSX8()
							Enddo
							Mostraerro()
							Alert("ERRO GRAVACAO Trasnferencia 4")
						Else
							Alert("Transferencia 4 concluida.")
						EndIf
						
					Endif
					
				Endif
				
			Endif
			
		Endif
		
	Endif

Endif 

Return
