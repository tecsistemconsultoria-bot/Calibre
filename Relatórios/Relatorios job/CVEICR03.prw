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
   Local cEmails := ""
   Local nX      := 0

   RPCSetEnv("01","01",,,"EIC")

   cEmails := GetMV("XX_RELPO",.F.,"otavio@tecsistemconsultoria.com.br")
   aEmails := StrToKarr(cEmails,";")

   If Len(aEmails) > 0

      For nX := 1 To Len(aEmails)

         U_CVEICR04(.T.,aEmails[nX]) //Relatório Itens Comprados - Novo

      Next nX 

   Endif

   aEmails := {}

   If Len(aEmails) > 0

      For nX := 1 To Len(aEmails)

         U_CVEICR02(.T.,aEmails[nX]) //Relatório Status PO

      Next nX 

   Endif

   aEmails := {}

   cEmails := AllTrim(GetMV("XX_RELDEM",.F.,"otavio@tecsistemconsultoria.com.br"))
   aEmails := StrToKarr(cEmails,";")

   If Len(aEmails) > 0

      For nX := 1 To Len(aEmails)

         U_CVCOMR01(.T.,aEmails[nX]) //Relatório Demandas

      Next nX 

   Endif

   RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return
