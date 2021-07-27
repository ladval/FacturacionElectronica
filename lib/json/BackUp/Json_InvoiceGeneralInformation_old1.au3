;~ _ArrayDisplay($aInvoiceGralInfo_PreinvoiceNumber, "$aInvoiceGralInfo_PreinvoiceNumber")
;~ _ArrayDisplay($aInvoiceGralInfo_InvoiceNumber, "$aInvoiceGralInfo_InvoiceNumber")
;~ _ArrayDisplay($aInvoiceGralInfo_DaysOff, "$aInvoiceGralInfo_DaysOff")
;~ _ArrayDisplay($aInvoiceGralInfo_Currency, "$aInvoiceGralInfo_Currency")
;~ _ArrayDisplay($aInvoiceGralInfo_ExchangeRate, "$aInvoiceGralInfo_ExchangeRate")
;~ _ArrayDisplay($aInvoiceGralInfo_ExchangeRateDate, "$aInvoiceGralInfo_ExchangeRateDate")
;~ _ArrayDisplay($aInvoiceGralInfo_SalesPerson, "$aInvoiceGralInfo_SalesPerson")
;~ _ArrayDisplay($aInvoiceGralInfo_Note, "$aInvoiceGralInfo_Note")
;~ _ArrayDisplay($aInvoiceGralInfo_ExternalGR, "$aInvoiceGralInfo_ExternalGR")


Func _JSON_InvoiceGralInfo($aArray)
	;~ _ArrayDisplay($aArray, '$aArray')
	Local $iDaysOff = $aArray[19][1]
	If $iDaysOff < 0 Then $iDaysOff = 0
	Local $sSelectJSON_Resolutions = "SELECT [InvoiceAuthorizationNumber],[Prefijo],[Fecha_inicio],[Fecha_fin],[NitFacturador],[NumeracionInicia],[NumeracionFin] FROM [BotAbc].[dbo].[tfact_Autorizaciones]"
	Local $aResolutions = _ModuloSQL_SQL_SELECT($sSelectJSON_Resolutions)
	Local $iFE_InvoiceAuthorizationNumber = StringStripWS($aArray[17][1], 8)
	Local $iFE_InvoiceNumber = StringStripWS($aArray[21][1], 8)
	For $i = 1 To UBound($aResolutions) - 1 Step +1
		Local $sInvoiceAuthorizationNumber = StringStripWS($aResolutions[$i][0], 8)
		Local $sPrefijo = StringStripWS($aResolutions[$i][1], 8)
		Local $sFecha_inicio = StringStripWS($aResolutions[$i][2], 8)
		Local $sFecha_fin = StringStripWS($aResolutions[$i][3], 8)
		Local $sNitFacturador = StringStripWS($aResolutions[$i][4], 8)
		Local $sNumeracionInicia = StringStripWS($aResolutions[$i][5], 8)
		Local $sNumeracionFin = StringStripWS($aResolutions[$i][6], 8)
		$aFecha_inicio = StringSplit($sFecha_inicio, "/", 3)
		$sFecha_inicio = $aFecha_inicio[2] & $aFecha_inicio[1] & $aFecha_inicio[0]
		$sFecha_inicio = Number($sFecha_inicio)
		$aFecha_fin = StringSplit($sFecha_fin, "/", 3)
		$sFecha_fin = $aFecha_fin[2] & $aFecha_fin[1] & $aFecha_fin[0]
		$sFecha_fin = Number($sFecha_fin)
		If $iFE_InvoiceAuthorizationNumber == $sInvoiceAuthorizationNumber Then
			ConsoleWrite('RESOLUCION No ' & $iFE_InvoiceAuthorizationNumber & ' encontrada' & @CRLF)
			Local $iDateDiff_Inicio = Number(@YEAR & @MON & @MDAY) - Number($sFecha_inicio)
			Local $iDateDiff_Fin = Number($sFecha_fin) - Number(@YEAR & @MON & @MDAY)

;~ _ArrayDisplay($aResolutions, 'aResolutions')
			ConsoleWrite($iDateDiff_Inicio & @CRLF)
			ConsoleWrite($iDateDiff_Fin & @CRLF)


			If $iDateDiff_Inicio < 0 Or $iDateDiff_Fin < 0 Then Return "Fecha(s) de resolucion incorrecta(s)."
			Local $iFactDiff_Inicia = $iFE_InvoiceNumber - Number($sNumeracionInicia)
			Local $iFactDiff_Fin = Number($sNumeracionFin) - $iFE_InvoiceNumber
			If $iFactDiff_Inicia < 0 Or $iFactDiff_Fin < 0 Then Return "Factura No. " & $iFE_InvoiceNumber & " fuera de rango."
			Local $aInvoiceGralInfo_InvoiceAuthorizationNumber[5]
			$aInvoiceGralInfo_InvoiceAuthorizationNumber[0] = "InvoiceAuthorizationNumber"
			Local $iAuthorizationTesting = Json_Get($oJsonSettings, ".Gnral_Variables.authorization_testing")
			If $iAuthorizationTesting = 1 Then
				Local $sAuthorization_number_testing = Json_Get($oJsonSettings, ".Gnral_Variables.authorization_number_testing")
			Else
				Local $sAuthorization_number_testing = $aArray[17][1]
			EndIf
			$aInvoiceGralInfo_InvoiceAuthorizationNumber[1] = $sAuthorization_number_testing
			$aInvoiceGralInfo_InvoiceAuthorizationNumber[2] = "null"
			$aInvoiceGralInfo_InvoiceAuthorizationNumber[3] = "REQUERIDO"
			$aInvoiceGralInfo_InvoiceAuthorizationNumber[4] = "Número de resolución con la cual se emitirá la factura"
			

			Local $aInvoiceGralInfo_PreinvoiceNumber[5]
			$aInvoiceGralInfo_PreinvoiceNumber[0] = "PreinvoiceNumber"
			$aInvoiceGralInfo_PreinvoiceNumber[1] = $aArray[21][1]
			$aInvoiceGralInfo_PreinvoiceNumber[2] = "0"
			$aInvoiceGralInfo_PreinvoiceNumber[3] = "OPCIONAL"
			$aInvoiceGralInfo_PreinvoiceNumber[4] = "El Número de prefectura si el emisor no maneja la numeración de factura."
			Local $aInvoiceGralInfo_InvoiceNumber[5]
			$aInvoiceGralInfo_InvoiceNumber[0] = "InvoiceNumber"
			$aInvoiceGralInfo_InvoiceNumber[1] = $aArray[21][1]
			$aInvoiceGralInfo_InvoiceNumber[2] = "null"
			$aInvoiceGralInfo_InvoiceNumber[3] = "OPCIONAL"
			$aInvoiceGralInfo_InvoiceNumber[4] = "Si el emisor maneja la numeración, número de la factura asignado por él."
			Local $aInvoiceGralInfo_DaysOff[5]
			$aInvoiceGralInfo_DaysOff[0] = "DaysOff"
			$aInvoiceGralInfo_DaysOff[1] = $iDaysOff
			$aInvoiceGralInfo_DaysOff[2] = "null"
			$aInvoiceGralInfo_DaysOff[3] = "REQUERIDO"
			$aInvoiceGralInfo_DaysOff[4] = "Número de días para el vencimiento"
			Local $aInvoiceGralInfo_Currency[5]
			$aInvoiceGralInfo_Currency[0] = "Currency"
			$aInvoiceGralInfo_Currency[1] = $aArray[69][1]
			$aInvoiceGralInfo_Currency[2] = "null"
			$aInvoiceGralInfo_Currency[3] = "REQUERIDO"
			$aInvoiceGralInfo_Currency[4] = "Moneda en la cual se emite la factura. Tabla de referencia Anexo API V2 1.1.5 Moneda (ISO 4217)"
			Local $aInvoiceGralInfo_ExchangeRate[5]
			$aInvoiceGralInfo_ExchangeRate[0] = "ExchangeRate"
			$aInvoiceGralInfo_ExchangeRate[1] = _FloatValue($aArray[76][1])
			$aInvoiceGralInfo_ExchangeRate[2] = "0.0"
			$aInvoiceGralInfo_ExchangeRate[3] = "OPCIONAL"
			$aInvoiceGralInfo_ExchangeRate[4] = "Tasa de cambio a la que se liquida la moneda en la que se denomina la factura"
			Local $aInvoiceGralInfo_ExchangeRateDate[5]
			$aInvoiceGralInfo_ExchangeRateDate[0] = "ExchangeRateDate"
			$aInvoiceGralInfo_ExchangeRateDate[1] = "NoData"
			$aInvoiceGralInfo_ExchangeRateDate[2] = "0001-01-01T00:00:00"
			$aInvoiceGralInfo_ExchangeRateDate[3] = "OPCIONAL"
			$aInvoiceGralInfo_ExchangeRateDate[4] = "Fecha en la que se toma la tasa de cambio a la que se liquida la moneda en la que se denomina la factura ('0001-01- 01T00:00:00')"
			Local $aInvoiceGralInfo_SalesPerson[5]
			$aInvoiceGralInfo_SalesPerson[0] = "SalesPerson"
			$aInvoiceGralInfo_SalesPerson[1] = "NoData"
			$aInvoiceGralInfo_SalesPerson[2] = "null"
			$aInvoiceGralInfo_SalesPerson[3] = "OPCIONAL"
			$aInvoiceGralInfo_SalesPerson[4] = "Nombre el asesor comercial o de la persona que atiende la venta"
			
			Local $aInvoiceGralInfo_Note[5]
			$aInvoiceGralInfo_Note[0] = "Note"
			$aInvoiceGralInfo_Note[1] = "NoData"
			If StringStripWS($aArray[0][1], 8) = "900402494" Then
				$aInvoiceGralInfo_Note[2] = '"Código CIIU: ' & $aArray[74][1] & '"'
			Else
				$aInvoiceGralInfo_Note[2] = "null"
			EndIf
			$aInvoiceGralInfo_Note[3] = "OPCIONAL"
			$aInvoiceGralInfo_Note[4] = "Nombre y valor de la propiedad adicional"
			
			
			Local $aInvoiceGralInfo_ExternalGR[5]
			$aInvoiceGralInfo_ExternalGR[0] = "ExternalGR"
			$aInvoiceGralInfo_ExternalGR[1] = "NoData"
			
			Local $iNoRGNit = StringRegExpReplace($aArray[0][1], "[^[:digit:]]", "")
			If $iNoRGNit = 900402494 Or $iNoRGNit = 900467836 Then
				$aInvoiceGralInfo_ExternalGR[2] = "false"
				ConsoleWrite("  Esta factura no genera RG" & @CRLF)
			Else
				ConsoleWrite("  Esta factura genera RG" & @CRLF)
				$aInvoiceGralInfo_ExternalGR[2] = "true"
			EndIf
			$aInvoiceGralInfo_ExternalGR[3] = "OPCIONAL"
			$aInvoiceGralInfo_ExternalGR[4] = "Sin datos definitorios"




			If IsArray($aInvoiceGralInfo_InvoiceAuthorizationNumber) Then ConsoleWrite('InvoiceGralInfo_InvoiceAuthorizationNumber: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_PreinvoiceNumber) Then ConsoleWrite('InvoiceGralInfo_PreinvoiceNumber: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_InvoiceNumber) Then ConsoleWrite('InvoiceGralInfo_InvoiceNumber: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_DaysOff) Then ConsoleWrite('InvoiceGralInfo_DaysOff: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_Currency) Then ConsoleWrite('InvoiceGralInfo_Currency: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_ExchangeRate) Then ConsoleWrite('InvoiceGralInfo_ExchangeRate: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_ExchangeRateDate) Then ConsoleWrite('InvoiceGralInfo_ExchangeRateDate: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_SalesPerson) Then ConsoleWrite('InvoiceGralInfo_SalesPerson: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_Note) Then ConsoleWrite('InvoiceGralInfo_Note: ERROR' & @CRLF)
			If IsArray($aInvoiceGralInfo_ExternalGR) Then ConsoleWrite('InvoiceGralInfo_ExternalGR: ERROR' & @CRLF)



			Local $aResultArray[11]
			$aResultArray[0] = StringSplit("InvoiceGeneralInformation|||REQUERIDO|Nodo para registrar información general de la factura", "|", 3)
			$aResultArray[1] = $aInvoiceGralInfo_InvoiceAuthorizationNumber
			$aResultArray[2] = $aInvoiceGralInfo_PreinvoiceNumber
			$aResultArray[3] = $aInvoiceGralInfo_InvoiceNumber
			$aResultArray[4] = $aInvoiceGralInfo_DaysOff
			$aResultArray[5] = $aInvoiceGralInfo_Currency
			$aResultArray[6] = $aInvoiceGralInfo_ExchangeRate
			$aResultArray[7] = $aInvoiceGralInfo_ExchangeRateDate
			$aResultArray[8] = $aInvoiceGralInfo_SalesPerson
			$aResultArray[9] = $aInvoiceGralInfo_Note
			$aResultArray[10] = $aInvoiceGralInfo_ExternalGR


			$aJSON_InvoiceGralInfo_2DArray = _JSON_1Darray($aResultArray)
			$aResultArray = _JSON_JsonData($aJSON_InvoiceGralInfo_2DArray)
			Return $aResultArray
		ElseIf $i = UBound($aResolutions) - 1 And $iFE_InvoiceAuthorizationNumber <> $sInvoiceAuthorizationNumber Then
			Return "Resol. No. " & $iFE_InvoiceAuthorizationNumber & " invalida."
		EndIf
	Next
EndFunc   ;==>_JSON_InvoiceGralInfo

Func _FloatValue($sValue)
	$iValue = Number($sValue) * 1
	If IsFloat($iValue) = 1 Then
		Return $iValue
	Else
		Return $iValue & ".0"
	EndIf
EndFunc   ;==>_FloatValue
