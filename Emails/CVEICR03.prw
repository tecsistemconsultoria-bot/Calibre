#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 30/06/2025
Uso: Calibre
Tipo: Atualizações
Rotina: Faturamento
Função: CVEICR03
Info: Relatório CVEICR02 em Job
************************************************************************/
User Function CVEICR03()

   Local aEmails := {}
   Local nX      := 0
   Local lVld    := .T.

   RPCSetEnv("01","01",,,"EIC")

   While lVld

      nX++
      DBSelectArea("SX5")
      SX5->(DbSetOrder(1)) // TABELA+CHAVE

      If SX5->(DbSeek(xFilial('SX5')+"XZ"+StrZero(nX,2)))

        AAdd(aEmails, SX5->X5_DESCRI)

      Else

         lVld := .F.

      EndIf

   EndDo

   If Len(aEmails) > 0

      For nX := 1 To Len(aEmails)

         U_CVEICR04(.T.,aEmails[nX]) //Relatório Itens Comprados - Novo

      Next nX 

   Endif

   If Len(aEmails) > 0

      For nX := 1 To Len(aEmails)

         U_CVEICR02(.T.,aEmails[nX]) //Relatório Status PO

      Next nX 

   Endif

   If Len(aEmails) > 0

      For nX := 1 To Len(aEmails)

         U_CVCOMR01(.T.,aEmails[nX]) //Relatório Demandas

      Next nX 

   Endif

   RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return
