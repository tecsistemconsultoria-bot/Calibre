#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informação
Uso: Calibre
Tipo: Ponto de Entrada
Rotina: Faturamento
Função: CVFATR03
Info: Relatório de Vendas
************************************************************************/
User Function CVFATR03()

	RPCSetEnv("01","01")
	
	xQryVend()

	RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informação
Uso: Calibre
Info: Filtra Vendedores
*==================================================================*/
Static Function xQryVend()

	Local cQuery := ""
	Local cTemp  := GetNextAlias()
	Local aVend  := {}
	Local nX     := 0

	cQuery += " SELECT DISTINCT A3_COD, A3_NOME, A3_END, A3_BAIRRO , A3_MUN, A3_EST, A3_EMAIL" 
	cQuery += " FROM "+RetSQLName("SA3")
	cQuery += " WHERE A3_FILIAL = '"+xFilial("SA3")+"'"
	cQuery += " 	AND A3_MSBLQL <> '1'"
	cQuery += " 	AND D_E_L_E_T_ = ''"  
	cQuery += " ORDER BY A3_COD ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
	
	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		aAdd(aVend,{(cTemp)->A3_COD,(cTemp)->A3_NOME,AllTrim((cTemp)->A3_END),AllTrim((cTemp)->A3_BAIRRO),(cTemp)->A3_MUN,(cTemp)->A3_EST,AllTrim((cTemp)->A3_EMAIL)})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	If Len(aVend) > 0
	
		For nX := 1 To Len(aVend)

			If nX <= 2
		
				xExecRel(aVend[nX])
		
			EndIf

		Next nX 
	
	Endif 

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informação
Uso: Calibre
Info: Inicio a geração do relatório
*==================================================================*/
Static Function xExecRel(aVendedor)

	Local oFWMsExcel := Nil
	Local cData      := StrTran(DToS(Date()),"/","")
	Local cHoraAtu   := Time()
	Local cHora      := StrTran(cHoraAtu,":","")
	Local cDtHora    := AllTrim(cData+"_"+cHora)
    Local cArquivo   := '\spool\VENDAS_'+AllTrim(cDtHora)+'.xlsx'
	Local cTemp      := ""
	Local cQuery     := ""
	Local cEmail     := aVendedor[7]
   
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FwMsExcelXlsx():New()
	
	//========================= CRIANDO A ABA VENDEDOR ================================================
  
    oFWMsExcel:AddworkSheet("Vendas") //Não utilizar número junto com sinal de menos. Ex.: 1-

    //Criando a Tabela
    oFWMsExcel:AddTable("Vendas","Vendedor",.F.)

	oFWMsExcel:SetFont("arial")
	oFWMsExcel:SetFontSize(8)

    //Criando Colunas
    oFWMsExcel:AddColumn("Vendas","Vendedor","Código",1,1) //1
    oFWMsExcel:AddColumn("Vendas","Vendedor","Nome",1,1) //2
    oFWMsExcel:AddColumn("Vendas","Vendedor","Endereço",1,1) //3
	oFWMsExcel:AddColumn("Vendas","Vendedor","Bairro",1,1) //4
    oFWMsExcel:AddColumn("Vendas","Vendedor","Municipio",1,1) //5
    oFWMsExcel:AddColumn("Vendas","Vendedor","Estado",1,1) //6
    oFWMsExcel:AddColumn("Vendas","Vendedor","E-mail",1,1) //7
	
	//Criando as Linhas
	oFWMsExcel:AddRow("Vendas","Vendedor",{;
	aVendedor[1],; //1
	aVendedor[2],; //2
	aVendedor[3],; //3
	aVendedor[4],; //4
	aVendedor[5],; //5
 	aVendedor[6],; //6
	aVendedor[7]; //7
	})
		
	//========================= CRIANDO A ABA PEDIDOS EM ABERTO ================================================
	
	cTemp  := GetNextAlias()
	cQuery := ""
	
	cQuery += " SELECT DISTINCT C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI"
	cQuery += " FROM "+RetSQLName("SC5")
	cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"
	cQuery += " 	AND C5_NOTA = ''"
	cQuery += " 	AND C5_LIBEROK <> 'E'"
	cQuery += "		AND C5_VEND1 = '"+aVendedor[1]+"'"
	cQuery += " 	AND D_E_L_E_T_ = ''"	
	cQuery += " ORDER BY C5_EMISSAO ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	//Aba Pedidos em Aberto
	oFWMsExcel:AddworkSheet("Pedidos_Aberto")

	//Criando a Tabela
	oFWMsExcel:AddTable("Pedidos_Aberto","Pedidos_em_Aberto",.F.)

	oFWMsExcel:AddColumn("Pedidos_Aberto","Pedidos_em_Aberto","Filial",1)
	oFWMsExcel:AddColumn("Pedidos_Aberto","Pedidos_em_Aberto","Pedido",1)
	oFWMsExcel:AddColumn("Pedidos_Aberto","Pedidos_em_Aberto","Emissão",1)
	oFWMsExcel:AddColumn("Pedidos_Aberto","Pedidos_em_Aberto","Cliente",1)
	oFWMsExcel:AddColumn("Pedidos_Aberto","Pedidos_em_Aberto","Loja",1)
	oFWMsExcel:AddColumn("Pedidos_Aberto","Pedidos_em_Aberto","Razão Social",1)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		oFWMsExcel:AddRow("Pedidos_Aberto","Pedidos_em_Aberto",{;
		(cTemp)->C5_FILIAL,;
		(cTemp)->C5_NUM,;
		cValToChar(SToD((cTemp)->C5_EMISSAO)),;
		(cTemp)->C5_CLIENTE,;
		(cTemp)->C5_LOJACLI,;
		AllTrim(Posicione("SA1",1,xFilial("SA1")+(cTemp)->C5_CLIENTE+(cTemp)->C5_LOJACLI,"A1_NOME"));
		})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	//========================= CRIANDO A ABA PEDIDOS INCLUIDOS NO MÊS ================================================
	
	cTemp  := GetNextAlias()
	cQuery := ""
	
	cQuery += " SELECT DISTINCT C5_FILIAL, C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI"
	cQuery += " FROM "+RetSQLName("SC5")
	cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'"
	cQuery += " 	AND C5_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%' "
	cQuery += "		AND C5_VEND1 = '"+aVendedor[1]+"'"
	cQuery += " 	AND D_E_L_E_T_ = ''" 
	cQuery += " ORDER BY C5_EMISSAO ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	//Aba Pedidos em Aberto
	oFWMsExcel:AddworkSheet("Pedidos_Mes")

	//Criando a Tabela
	oFWMsExcel:AddTable("Pedidos_Mes","Pedidos_do_Mes",.F.)

	oFWMsExcel:AddColumn("Pedidos_Mes","Pedidos_do_Mes","Filial",1)
	oFWMsExcel:AddColumn("Pedidos_Mes","Pedidos_do_Mes","Pedido",1)
	oFWMsExcel:AddColumn("Pedidos_Mes","Pedidos_do_Mes","Emissão",1)
	oFWMsExcel:AddColumn("Pedidos_Mes","Pedidos_do_Mes","Cliente",1)
	oFWMsExcel:AddColumn("Pedidos_Mes","Pedidos_do_Mes","Loja",1)
	oFWMsExcel:AddColumn("Pedidos_Mes","Pedidos_do_Mes","Razão Social",1)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		oFWMsExcel:AddRow("Pedidos_Mes","Pedidos_do_Mes",{;
		(cTemp)->C5_FILIAL,;
		(cTemp)->C5_NUM,;
		cValToChar(SToD((cTemp)->C5_EMISSAO)),;
		(cTemp)->C5_CLIENTE,;
		(cTemp)->C5_LOJACLI,;
		AllTrim(Posicione("SA1",1,xFilial("SA1")+(cTemp)->C5_CLIENTE+(cTemp)->C5_LOJACLI,"A1_NOME"));
		})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	//========================= CRIANDO A ABA PEDIDOS FATURADOS NO MÊS ================================================
	
	cTemp  := GetNextAlias()
	cQuery := ""
	
	cQuery += " SELECT DISTINCT D2_FILIAL, D2_PEDIDO, D2_EMISSAO, D2_CLIENTE, D2_LOJA, F2_VEND1"
    cQuery += " FROM "+RetSQLName("SD2")+" SD2"
	cQuery += " INNER JOIN "+RetSQLName("SF2")+" SF2"
	cQuery += "		ON F2_FILIAL = D2_FILIAL"
	cQuery += "		AND F2_DOC = D2_DOC"
	cQuery += "		AND F2_SERIE = D2_SERIE"
	cQuery += "		AND F2_CLIENTE = D2_CLIENTE"
	cQuery += "		AND F2_LOJA = D2_LOJA"
	cQuery += "		AND SF2.D_E_L_E_T_ <> '*'"
    cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += " 	AND D2_PEDIDO <> ''"
	cQuery += " 	AND D2_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%'"
	cQuery += "		AND F2_VEND1 = '"+aVendedor[1]+"'"
	cQuery += " 	AND SD2.D_E_L_E_T_ = ''" 
    cQuery += " ORDER BY D2_EMISSAO ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	//Aba Pedidos em Aberto
	oFWMsExcel:AddworkSheet("Pedidos_Faturados")

	//Criando a Tabela
	oFWMsExcel:AddTable("Pedidos_Faturados","Pedidos_Faturados_Mes",.F.)

	oFWMsExcel:AddColumn("Pedidos_Faturados","Pedidos_Faturados_Mes","Filial",1)
	oFWMsExcel:AddColumn("Pedidos_Faturados","Pedidos_Faturados_Mes","Pedido",1)
	oFWMsExcel:AddColumn("Pedidos_Faturados","Pedidos_Faturados_Mes","Emissão",1)
	oFWMsExcel:AddColumn("Pedidos_Faturados","Pedidos_Faturados_Mes","Cliente",1)
	oFWMsExcel:AddColumn("Pedidos_Faturados","Pedidos_Faturados_Mes","Loja",1)
	oFWMsExcel:AddColumn("Pedidos_Faturados","Pedidos_Faturados_Mes","Razão Social",1)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		oFWMsExcel:AddRow("Pedidos_Faturados","Pedidos_Faturados_Mes",{;
		(cTemp)->D2_FILIAL,;
		(cTemp)->D2_PEDIDO,;
		cValToChar(SToD((cTemp)->D2_EMISSAO)),;
		(cTemp)->D2_CLIENTE,;
		(cTemp)->D2_LOJA,;
		AllTrim(Posicione("SA1",1,xFilial("SA1")+(cTemp)->D2_CLIENTE+(cTemp)->D2_LOJA,"A1_NOME"));
		})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	//========================= CRIANDO A ABA NOTAS FISCAIS DO MÊS ================================================
	
	cTemp  := GetNextAlias()
	cQuery := ""
	
	cQuery += " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA"
    cQuery += " FROM "+RetSQLName("SF2")
    cQuery += " WHERE F2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += " 	AND F2_EMISSAO LIKE FORMAT(GETDATE(), 'yyyyMM') + '%'"
	cQuery += "		AND F2_VEND1 = '"+aVendedor[1]+"'"
	cQuery += " 	AND D_E_L_E_T_ = ''" 
    cQuery += " ORDER BY F2_EMISSAO ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	//Aba Pedidos em Aberto
	oFWMsExcel:AddworkSheet("Notas_Mes")

	//Criando a Tabela
	oFWMsExcel:AddTable("Notas_Mes","Notas_do_Mes",.F.)

	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Filial",1)
	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Nota",1)
	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Série",1)
	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Emissão",1)
	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Cliente",1)
	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Loja",1)
	oFWMsExcel:AddColumn("Notas_Mes","Notas_do_Mes","Razão Social",1)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		oFWMsExcel:AddRow("Notas_Mes","Notas_do_Mes",{;
		(cTemp)->F2_FILIAL,;
		(cTemp)->F2_DOC,;
		(cTemp)->F2_SERIE,;
		cValToChar(SToD((cTemp)->F2_EMISSAO)),;
		(cTemp)->F2_CLIENTE,;
		(cTemp)->F2_LOJA,;
		AllTrim(Posicione("SA1",1,xFilial("SA1")+(cTemp)->F2_CLIENTE+(cTemp)->F2_LOJA,"A1_NOME"));
		})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())
	
	//========================= CRIANDO A ABA NOTAS FISCAIS DO ANO ================================================
	
	cTemp  := GetNextAlias()
	cQuery := ""
	
	cQuery += " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_EMISSAO, F2_CLIENTE, F2_LOJA"
    cQuery += " FROM "+RetSQLName("SF2")
    cQuery += " WHERE F2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += " 	AND F2_EMISSAO LIKE FORMAT(GETDATE(), 'yyyy') + '%'"
	cQuery += "		AND F2_VEND1 = '"+aVendedor[1]+"'"
	cQuery += " 	AND D_E_L_E_T_ = ''" 
    cQuery += " ORDER BY F2_EMISSAO ASC"
	
	//Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	//Aba Pedidos em Aberto
	oFWMsExcel:AddworkSheet("Notas_Ano")

	//Criando a Tabela
	oFWMsExcel:AddTable("Notas_Ano","Notas_do_Ano",.F.)

	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Filial",1)
	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Nota",1)
	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Série",1)
	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Emissão",1)
	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Cliente",1)
	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Loja",1)
	oFWMsExcel:AddColumn("Notas_Ano","Notas_do_Ano","Razão Social",1)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		oFWMsExcel:AddRow("Notas_Ano","Notas_do_Ano",{;
		(cTemp)->F2_FILIAL,;
		(cTemp)->F2_DOC,;
		(cTemp)->F2_SERIE,;
		cValToChar(SToD((cTemp)->F2_EMISSAO)),;
		(cTemp)->F2_CLIENTE,;
		(cTemp)->F2_LOJA,;
		AllTrim(Posicione("SA1",1,xFilial("SA1")+(cTemp)->F2_CLIENTE+(cTemp)->F2_LOJA,"A1_NOME"));
		})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	(cTemp)->(DbCloseArea())

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
	oFWMsExcel:DeActivate()
	
	//Redefinição para teste
	cEmail := "otavio@tecsistemconsultoria.com.br"
	
	//Função para o envio dos e-mails 
	xEnvMail(cArquivo,cEmail)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 04/12/2025
Consultoria: TecSistem Consultoria em Sistemas de Informação
Uso: Calibre
Info: Envio de e-mail 
*==================================================================*/
Static Function xEnvMail(cArquivo,cEmail)

	Local cAssunto  := "RELATORIO DE VENDAS"
	Local lMailAuth	:= GetMV("MV_RELAUTH",.F.,.T.) //Autenticação com server SMTP
	Local nPortSMTP := 587 //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587
	Local nTimeout  := GetMV("MV_RELTIME") //120 //30
	Local xRet
	Local oServer	
	Local oMessage

	//A porta 25, por ser utilizada há mais tempo, possui uma vulnerabilidade maior a
	//ataques e interceptação de mensagens, além de não exigir autenticação para envio
	//das mensagens, ao contrário da 587 que oferece esta segurança a mais.

	Private cMailConta	:= GetMV("MV_RELAUSR") //GetMV("MV_RELACNT") //Conta utilizada para envio do email
	Private cMailServer	:= AllTrim(StrTran(GetMV("MV_RELSERV"),":587",""))       //Servidor SMTP
	Private cMailSenha	:= GetMV("MV_RELAPSW")      //Senha da conta de e-mail utilizada para envio

	oServer := TMailManager():New()
	oServer:SetUseTLS(.T.) //Indica se será utilizará a comunicação segura através de TLS (.T.) ou não (.F.)
	oServer:SetUseSSL(.T.) //Indica se será utilizará a comunicação segura através de SSL (.T.) ou não (.F.)

	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha,, nPortSMTP ) //inicilizar o servidor

	If xRet <> 0
		MsgAlert("O servidor SMTP nao foi inicializado: " + oServer:GetErrorString( xRet ))
		Return
	Else
		MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Server inicializado com sucesso...")
	Endif

	xRet := oServer:SetSMTPTimeout(nTimeout) //Indica o tempo de espera em segundos.

	If xRet <> 0
		MsgAlert(cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	Endif

	xRet := oServer:SMTPConnect()

	If xRet <> 0
		MsgAlert("Não foi possível conectar ao server SMTP: " + oServer:GetErrorString( xRet ))
		Return
	Else
		MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Conexao com o server SMTP realizada com sucesso...")
	Endif

	If lMailAuth

		//O método SMTPAuth ao tentar realizar a autenticação do
		//usuário no servidor de e-mail, verifica a configuração
		//da chave AuthSmtp, na seção [Mail], no arquivo de
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )

		If xRet <> 0
			MsgAlert("Não foi possível autenticar no server SMTP: " + oServer:GetErrorString( xRet ))
			oServer:SMTPDisconnect()
			Return
		Else
			MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Autenticacao no server realizada com sucesso...")
		Endif

	Endif
	
	oMessage := TMailMessage():New()

	oMessage:Clear()

	oMessage:cDate	  := cValToChar(Date())
	oMessage:cFrom 	  := AllTrim(GetMV("MV_RELFROM",.F.,"no-reply@carvalhaes.net"))
	oMessage:cTo 	  := cEmail
	oMessage:cSubject := cAssunto
	oMessage:cBody 	  := "Segue anexo relatório de Vendas."

	xRet := oMessage:AttachFile(cArquivo)
	
	If xRet < 0
		MsgAlert("Não foi possível anexar o arquivo: " + cArquivo)
	Endif

	xRet := oMessage:Send( oServer )

	If xRet <> 0
		MsgAlert("Nao foi possível enviar o relatorio: " + oServer:GetErrorString( xRet ))
	Else
		MsgAlert("Relatorio enviado com sucesso...")
	Endif

	xRet := oServer:SMTPDisconnect()

	If xRet <> 0
		MsgAlert("Nao foi possivel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	Else
		MsgAlert("["+DToc(dDatabase)+"-"+Time()+"] Server desconectado com sucesso...")
	Endif

Return 
