#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=src\img\invoice.ico
#AutoIt3Wrapper_Outfile_x64=main.exe
#AutoIt3Wrapper_Change2CUI=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;===========================================================================
#include <IE.au3>
#include <Date.au3>
#include <File.au3>
#include <Inet.au3>
#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <Timers.au3>
#include <ScreenCapture.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
#include <WindowsConstants.au3>
;===========================================================================
#include "modulo_files.au3"
#include "modulo_misc.au3"
#include "modulo_json.au3"
#include "modulo_taxes.au3"
#include "modulo_sql.au3"
;===========================================================================

;===========================================================================
Local $iVarJson = 112 ;NUMERO DE COLUMNAS DEL ARCHIVO PLANO DELIMITADAS PARA RECORRIDO DE CICLO CREADOR
Local $sJsonFileSettings = @ScriptDir & "\settings\settings.json"
Local $sJsonSettings = _ReadDataFromFile($sJsonFileSettings)
Global $oJsonSettings = Json_Decode($sJsonSettings)
;===================================================6========================
#include "Lib/json/Json_Delivery.au3"
#include "Lib/json/Json_Mandatario.au3"
#include "Lib/json/Json_PaymentSummary.au3"
#include "Lib/json/Json_AllowanceCharge.au3"
#include "Lib/json/Json_TaxesInformation.au3"
#include "Lib/json/Json_AdditionalProperty.au3"
#include "Lib/json/Json_CustomerInformation.au3"
#include "Lib/json/Json_AdditionalDocuments.au3"
#include "Lib/json/Json_InvoiceGeneralInformation.au3"
;===========================================================================
ConsoleWrite(@CRLF)
ConsoleWrite("  FACTURACION ELECTRONICA GRUPO ABC" & @CRLF & @CRLF)
ConsoleWrite("  Ejecutando sistema de procesamiento de facturas" & @CRLF & @CRLF)
Sleep(250)
_FE()
ConsoleWrite(@CRLF & "  Proceso finalizado" & @CRLF)
Sleep(3000)
;===========================================================================
Func _FE()
	Local $sFE_Location = @ScriptDir & "\fe\new\"
	DirCreate($sFE_Location)
	Local $aFacListFiles = _FileListToArrayRec($sFE_Location, "*.txt", $FLTAR_FILES, $FLTAR_RECUR, $FLTAR_SORT)
	If UBound($aFacListFiles) - 1 <= 0 Then
		ConsoleWrite("There's no invoices to process." & @CRLF)
		Return 0
	EndIf
	For $i = 1 To UBound($aFacListFiles) - 1 Step +1
		If StringMid($aFacListFiles[$i], 1, 1) == "F" Then
			ConsoleWrite("  Procesando factura No. " & $aFacListFiles[$i] & @CRLF)
			Local $sFacDir = $sFE_Location & $aFacListFiles[$i]
			Local $aFac = FileReadToArray($sFacDir)
			Local $aJsonDataArray[$iVarJson][UBound($aFac)]
			For $j = 0 To UBound($aFac) - 1 Step +1
				Local $aLine = StringSplit($aFac[$j], ";", 3)
				If UBound($aLine) >= 113 Then
					ConsoleWrite("ERROR CSV - Verificar" & @CRLF)
					Return False
				EndIf
				For $k = 0 To UBound($aLine) - 1 Step +1
					If $j = 0 Then
						$aJsonDataArray[$k][$j] = StringStripWS($aLine[$k], 8)
					Else
						$aJsonDataArray[$k][$j] = _misc_StringFilter($aLine[$k])
						If $k = 82 Then $aJsonDataArray[$k][$j] = $aLine[$k]
						If $k = 85 Then $aJsonDataArray[$k][$j] = $aLine[$k]
					EndIf
				Next
			Next
			
			Local $iArraySample = Json_Get($oJsonSettings, ".Gnral_Variables.array_sample")
			If $iArraySample = 1 Then
				_ArrayDisplay($aJsonDataArray)
			EndIf
			Local $iInvoiceAuthorizationNumber = Number($aJsonDataArray[17][1])
			
			Local $sSQL_QueryInvoiceAuthorizationNumber = "SELECT Prefijo FROM [BotAbc].[dbo].[tfact_Autorizaciones] WHERE [InvoiceAuthorizationNumber] = '" & $iInvoiceAuthorizationNumber & "';"
			Local $aSQL_QueryInvoiceAuthorizationNumber = _ModuloSQL_SQL_SELECT($sSQL_QueryInvoiceAuthorizationNumber)
			
			If IsArray($aSQL_QueryInvoiceAuthorizationNumber) Then
				Local $iInvoiceNumber = Number($aJsonDataArray[21][1])
				Local $sInvoiceNumber = $aSQL_QueryInvoiceAuthorizationNumber[1][0] & $iInvoiceNumber
				Local $iLocalNit = StringRegExpReplace($aJsonDataArray[0][1], "[^[:digit:]]", "")
				Local $sObservaciones = $aJsonDataArray[111][1]
				Local $aJson = _JsonGenerator($aJsonDataArray)
				If IsArray($aJson) Then
					Local $iFolderNit = StringRegExpReplace($aJsonDataArray[0][1], "[^[:digit:]]", "")
					Local $iFactJsonFileName = StringRegExpReplace($aFacListFiles[$i], "[^[:digit:]]", "")
					Local $sProcessedFactFolder = @ScriptDir & "\fe\old\" & $iFolderNit & "\" & @YEAR & "_" & @MON
					DirCreate($sProcessedFactFolder)
					Local $sProcessedJsonFolder = @ScriptDir & "\fe\json\" & $iFolderNit & "\" & @YEAR & "_" & @MON
					DirCreate($sProcessedJsonFolder)
					Local $sProcessedJsonFile = @ScriptDir & "\fe\json\" & $iFolderNit & "\" & @YEAR & "_" & @MON & "\" & Number($iFactJsonFileName) & ".json"
					_FileWriteFromArray($sProcessedJsonFile, $aJson)
					Local $sDataManagement_Response = _Data_Management($aJson, $sInvoiceNumber, $iLocalNit, $sObservaciones)
					FileMove($sFacDir, $sProcessedFactFolder, $FC_OVERWRITE)
					ConsoleWrite("  " & _Now() & "  " & $sDataManagement_Response & @CRLF)
				Else
					ConsoleWrite("  Error de creacion de arreglo" & @CRLF)
				EndIf
			Else
				ConsoleWrite("  " & _Now() & "  " & $aJson & @CRLF)
			EndIf
		EndIf
	Next
EndFunc   ;==>_FE
;===========================================================================
Func _Data_Management($aJson, $sInvoiceNumber, $iLocalNit, $sObservaciones)
	Local $iJsonSample = Json_Get($oJsonSettings, ".Gnral_Variables.json_sample")
	If $iJsonSample = 1 Then
		ConsoleWrite("  Generacion de archivo JSON de muestra activa [json_sample:1]" & @CRLF)
		Local $sJsonSample_FileLocation = @ScriptDir & "\fe\json\samples\" & $sInvoiceNumber & ".json"
		Local $hFileOpen = FileOpen($sJsonSample_FileLocation, $FO_OVERWRITE) ;GENERA JSON
		FileWrite($hFileOpen, _ArrayToString($aJson, @CRLF))
		FileClose($hFileOpen)
		Return "  Se ha generado el archivo JSON: " & $sJsonSample_FileLocation
	EndIf
	Local $sSQL_QueryInvoiceNumber = "SELECT id,status FROM [BotAbc].[dbo].[tfact_ApiProcesos] WHERE InvoiceNumber = '" & $sInvoiceNumber & "' AND Empresa = " & $iLocalNit
	Local $aSQL_Select_Facts = _ModuloSQL_SQL_SELECT($sSQL_QueryInvoiceNumber)
	If IsArray($aSQL_Select_Facts) Then ;EXISTE FACTURA EN LA BASE DE DATOS. POR LO TANTO SE REQUIERE VALIDAR SÍ ACTUALIZA O NO.
		Local $sDeletableStatus = "Error|RechazadaCliente|Rechazada|SinProcesar|Verificado|FaltanDatos|SinCliente|SinAprobar" ;ESTADOS QUE PUEDEN BORRARSE
		Local $sNotDeletableStatus = "Transmitido|Aprobada|PendientePDF|ProcesadoOk|AceptadaCliente|RecibidoCliente|VerificarDatos" ;ESTADOS QUE NO PUEDEN BORRARSE
		For $i = 1 To UBound($aSQL_Select_Facts) - 1 Step +1 ;CICLO QUE VERIFICA SÍ LA FACTURA QUE SE ESTÁ SUBIENDO NUEVAMENTE TIENE UNO DE LOS ESTADOS VÁLIDOS DE BORRADO EN $sDeletableStatus
			Local $iId_Associated = $aSQL_Select_Facts[$i][0]
			Local $sStatus_Associated = $aSQL_Select_Facts[$i][1]
			$sStatus_Associated = StringStripWS($sStatus_Associated, 8)
			If StringInStr($sDeletableStatus, $sStatus_Associated) Then
				Local $sSQL_QueryDeleteInvoice = "DELETE FROM [BotAbc].[dbo].[tfact_ApiProcesos]  WHERE Id = " & $iId_Associated
				Local $sSQL_QueryDeleteFactNac = "DELETE FROM [BotAbc].[dbo].[tfact_FactNac] WHERE id_factura = " & $iId_Associated
				_ModuloSQL_SQL_EXEC($sSQL_QueryDeleteInvoice)
				Sleep(250)
				_ModuloSQL_SQL_EXEC($sSQL_QueryDeleteFactNac)
				Sleep(250)
			EndIf
		Next
		Local $aSQL_Select_FactsVerify = _ModuloSQL_SQL_SELECT($sSQL_QueryInvoiceNumber) ;REPITE LA CONSULTA PARA VALIDAR REGISTROS QUE FUERON BORRADOS
		If IsArray($aSQL_Select_FactsVerify) Then  ;SÍ AÚN DESPUÉS DE HABER BORRADO LAS FACTURAS, SIGUE ENCONTRANDO COINCIDENCIAS, DEBE SER UN ESTADO NO BORRABLE. NO HACER NADA
			ConsoleWrite("  No se recomienda actualizar datos de la factura " & $sInvoiceNumber & "." & @CRLF & "Factura se encuentra en status no borrable" & @CRLF)
			Return False
		Else ;SÍ HABIENDO BORRADO LAS FACTURAS, NO SE ENCUENTRA EL ARREGLO, INSERTAR FACTURA NORMALMENTE
			Local $sFactInsertion = _InsertFactJson($aJson, $iLocalNit, $sInvoiceNumber)
		EndIf
	Else ;INSERTAR FACTURA NORMALMENTE
		Local $sFactInsertion = _InsertFactJson($aJson, $iLocalNit, $sInvoiceNumber)
	EndIf
	ConsoleWrite($sFactInsertion & @CRLF)
	If StringInStr($sFactInsertion, "correctamente") Then
		Local $aSQL_Select_FactsNacId = _ModuloSQL_SQL_SELECT($sSQL_QueryInvoiceNumber) ;REPITE LA CONSULTA PARA IDENTIFICAR ID FACTURA
		If IsArray($aSQL_Select_FactsNacId) Then
			Local $iId_FactNac = $aSQL_Select_FactsNacId[1][0]
			_FactNac($iId_FactNac, $iLocalNit, $sObservaciones)
			_CorreosSamsung($iId_FactNac, $sObservaciones)
			_TipoDOexpo($iId_FactNac, $sObservaciones)
		Else
			ConsoleWrite("  Factura sin coincidencias para relación de nacionalizaciones" & @CRLF)
		EndIf
	EndIf
EndFunc   ;==>_Data_Management

Func _InsertFactJson($aJson, $iLocalNit, $sInvoiceNumber)
	If IsArray($aJson) Then
		Local $sJsonFact = StringReplace(_ArrayToString($aJson, @CRLF), "'", "''")
		Local $aNitTecero = StringSplit($aJson[3], ":", 3)
		Local $sNitTecero = StringReplace($aNitTecero[1], '"', '')
		$sNitTecero = StringReplace($sNitTecero, ',', '')
		Local $sSQL_QueryInsertJson = "INSERT INTO [BotAbc].[dbo].[tfact_ApiProcesos](InvoiceNumber,JsonFact,Empresa,NitTercero) VALUES ('" & $sInvoiceNumber & "','" & $sJsonFact & "','" & $iLocalNit & "','" & $sNitTecero & "')"
		Local $sStatus = " Cargada correctamente."
	Else
		Local $sSQL_QueryInsertJson = "INSERT INTO [BotAbc].[dbo].[tfact_ApiProcesos](InvoiceNumber,Status,ApiStatus) VALUES ('" & $sInvoiceNumber & "','Error','" & $aJson & "','" & $iLocalNit & "')"
		Local $sStatus = "Presenta errores de contenido."
	EndIf
	Local $iAllowSqlDataInsertion = Json_Get($oJsonSettings, ".Gnral_Variables.allow_sql_data_insertion")
	If $iAllowSqlDataInsertion == 1 Then
		_ModuloSQL_SQL_EXEC($sSQL_QueryInsertJson)
		Return "  Factura No. " & $sInvoiceNumber & " ---------> " & $sStatus
	Else
		Return "  Factura No. " & $sInvoiceNumber & " ---------> " & $sStatus & " [Conexión a base de datos desactivada] "
	EndIf
EndFunc   ;==>_InsertFactJson

Func _JsonGenerator($aJsonDataArray)
	Local $aJSON_Invoice[0]
	Local $aJSON_Array[7]
	$aJSON_Array[0] = _JSON_CustomerInfo($aJsonDataArray)
	$aJSON_Array[1] = _JSON_InvoiceGralInfo($aJsonDataArray)
	$aJSON_Array[2] = _JSON_Delivery($aJsonDataArray)
	$aJSON_Array[3] = _JSON_AdditionalDocuments($aJsonDataArray)
	$aJSON_Array[4] = _JSON_AdditionalProperty($aJsonDataArray)
	$aJSON_Array[5] = _JSON_PaymentSummary($aJsonDataArray)
	$aJSON_Array[6] = _JsonItemTaxesData($aJsonDataArray)
	For $i = 0 To UBound($aJSON_Array) - 1 Step +1
		If IsArray($aJSON_Array[$i]) == 0 Then
			ConsoleWrite("Indíce con errores de generación: " & $i & @CRLF)
			Return $aJSON_Array[$i]
		Else
			ConsoleWrite("Indíce correcto de generación: " & $i & @CRLF)
		EndIf
	Next
	_ArrayAdd($aJSON_Invoice, "{")
	For $i = 0 To UBound($aJSON_Array) - 1 Step +1
		_ArrayConcatenate($aJSON_Invoice, $aJSON_Array[$i])
	Next
	_ArrayAdd($aJSON_Invoice, "}")
	Return $aJSON_Invoice
EndFunc   ;==>_JsonGenerator

Func _FactNac($iId, $iLocalNit, $sObservaciones)
	Local $sSplitter = "/" ;CARACTER SEPARADOR DE LAS NACIONALIZACIONES EN EL CAMPO DE OBSERVACIONES
	If StringInStr($sObservaciones, "'") = 0 Then
		Local $aObservaciones = [$sObservaciones]
	Else
		Local $aObservaciones = StringSplit($sObservaciones, "'", 3)
	EndIf
	For $i = 0 To UBound($aObservaciones) - 1 Step +1
		Local $sObservacionesLinea = StringStripWS($aObservaciones[$i], 8)
		If StringInStr($sObservacionesLinea, "NAC:") Then
			ConsoleWrite("  Ejecutando actualizacion de nacionalizaciones" & @CRLF)
			Local $aNacionalizaciones = ""
			Local $aNacionalizaciones1 = _StringBetween(StringStripWS($sObservacionesLinea, 8), "NAC:", "|")
			If IsArray($aNacionalizaciones1) Then
				Local $aNacionalizaciones = $aNacionalizaciones1
			Else
				Local $aNacionalizaciones[1] = [StringRegExpReplace($sObservacionesLinea, "[^[:digit:]]", "")]
			EndIf
			If IsArray($aNacionalizaciones) Then
				Local $sNacionalizaciones = $aNacionalizaciones[0]
				Local $aNacionalizacionesLista = StringSplit($sNacionalizaciones, $sSplitter, 3)
				For $j = 0 To UBound($aNacionalizacionesLista) - 1 Step +1
					Local $sNacionalizacionesLista = StringStripWS($aNacionalizacionesLista[$j], 8)
					If StringLen($sNacionalizacionesLista) > 0 Then
						ConsoleWrite("  Nacionalizacion no. " & $j + 1 & ": " & $sNacionalizacionesLista & @CRLF)
						Local $sSQL_QueryInsertNac = "INSERT INTO [BotAbc].[dbo].[tfact_FactNac](id_factura,OrdenNacId) VALUES ('" & $iId & "','" & $sNacionalizacionesLista & "')"
						_ModuloSQL_SQL_EXEC($sSQL_QueryInsertNac)
					EndIf
				Next


 Local $sFechaLevanteQuery = "EXEC Nac_levante_Facturacion "&$sNacionalizacionesLista
 Local $aFechaLevanteQuery = _ModuloSQL_SQL_EXEC($sFechaLevanteQuery)
 _ArrayDisplay($aFechaLevanteQuery)


				Return True
			Else
				ConsoleWrite("  Formato inválido de nacionalizaciones / Campo vacío" & @CRLF)
			EndIf
		EndIf
	Next
EndFunc   ;==>_FactNac


Func _CorreosSamsung($iIdFact, $sObservaciones)
	Local $sObservacionesSamsungEmailFile = @ScriptDir & "\SamsungCorreo.txt"
	If FileExists($sObservacionesSamsungEmailFile) Then
		Local $sCorreosSamsung = _ReadDataFromFile($sObservacionesSamsungEmailFile)
		Local $sSQL_QueryInsertNac = "UPDATE [BotAbc].[dbo].[tfact_ApiProcesos] SET MailDestinatarios = '" & $sCorreosSamsung & "' WHERE Id = " & $iIdFact
		ConsoleWrite("  " & $sSQL_QueryInsertNac & @CRLF)
		_ModuloSQL_SQL_EXEC($sSQL_QueryInsertNac)
		ConsoleWrite("  Insertando emails asociados a Samsung: " & $sCorreosSamsung & @CRLF)
		FileDelete($sObservacionesSamsungEmailFile)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_CorreosSamsung

Func _TipoDOexpo($iIdFact, $sObservaciones)
	Local $sObservacionesTipoDO = @ScriptDir & "\TipoDO.txt"
	If FileExists($sObservacionesTipoDO) Then
		Local $sTipoDO = _ReadDataFromFile($sObservacionesTipoDO)
		Local $sSQL_QueryInsertNac = "UPDATE [BotAbc].[dbo].[tfact_ApiProcesos] SET TipoDO = '" & $sTipoDO & "' WHERE Id = " & $iIdFact
		_ModuloSQL_SQL_EXEC($sSQL_QueryInsertNac)
		ConsoleWrite("  Insertando TipoDO: " & $sTipoDO & @CRLF)
;~ FileDelete($sObservacionesTipoDO)
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_TipoDOexpo


































