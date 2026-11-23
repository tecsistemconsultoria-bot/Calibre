#INCLUDE "PRTOPDEF.CH"
#INCLUDE "PROTHEUS.CH"
 
User Function MT180GRV()
 
   Local ExpN1 := PARAMIXB[1]
   Local area   := GetArea()

    //Validações do usuário
    IF ExpN1 == 4 .OR. ExpN1 == 3
         U_fWKProTst(SB5->B5_COD)
    ENDIF
   
   RestArea(area)

Return
