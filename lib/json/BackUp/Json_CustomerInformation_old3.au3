

Func _JSON_CustomerInfo($aArray)
	Local $iIndex = 1
	For $i = 1 To UBound($aArray, 2) - 1 Step +1
		Local $sTipoIngreso = StringStripWS($aArray[102][$i], 8)
		If StringInStr($sTipoIngreso, "propio") Then
			Local $iIndex = $i
			ExitLoop
		ElseIf $i = UBound($aArray, 2) - 1 And StringInStr($sTipoIngreso, "propio") Then
			Local $iIndex = $i
			ExitLoop
		ElseIf $i = UBound($aArray, 2) - 1 And StringInStr($sTipoIngreso, "tercero") Then
			Local $iIndex = $i
		EndIf
	Next
	If StringStripWS($aArray[109][$iIndex], 8) == "CO" Then
		Local $aDivipola = _DIVIPOLA($aArray[11][$iIndex], $aArray[108][$iIndex], $aArray[109][$iIndex])
		If IsArray($aDivipola) Then

			Local $sDivipola_CityCode = $aDivipola[0]
			Local $sDivipola_SubdivisionCode = $aDivipola[1]
			Local $sDivipola_SubdivisioName = $aDivipola[2]
			Local $sDivipola_CityName = $aDivipola[3]
			Local $sDivipola_CountryCode = $aDivipola[4]
			Local $sDivipola_CountryName = $aDivipola[5]
			
		Else

			Local $sDivipola_CityCode = $aArray[11][$iIndex]
			Local $sDivipola_SubdivisionCode = $aArray[12][$iIndex]
			Local $sDivipola_SubdivisioName = ""
			Local $sDivipola_CityName = ""
			Local $sDivipola_CountryCode = $aArray[109][$iIndex]
			Local $sDivipola_CountryName = $aArray[108][$iIndex]
		EndIf
	Else
		
		Local $sDivipola_CityCode = $aArray[11][$iIndex]
		Local $sDivipola_SubdivisionCode = $aArray[12][$iIndex]
		Local $sDivipola_SubdivisioName = ""
		Local $sDivipola_CityName = ""
		Local $sDivipola_CountryCode = $aArray[109][$iIndex]
		Local $sDivipola_CountryName = $aArray[108][$iIndex]
	EndIf


	If StringInStr($aArray[1][$iIndex], "NODATA") > 0 Then
		ConsoleWrite("ERROR: IdentificationType" & @CRLF)
		Return False
	EndIf
	If StringInStr($aArray[2][$iIndex], "NODATA") > 0 Then
		ConsoleWrite("ERROR: Identification" & @CRLF)
		Return False
	EndIf
	If StringInStr($aArray[4][$iIndex], "NODATA") > 0 Then
		ConsoleWrite("ERROR: TaxLevelCodeListName" & @CRLF)
		Return False
	EndIf
	If StringInStr($aArray[5][$iIndex], "NODATA") > 0 Then
		ConsoleWrite("ERROR: AdditionalAccountID" & @CRLF)
		Return False
	EndIf
	If StringInStr($aArray[15][$iIndex], "facturaselectronicas") > 0 And StringInStr($aArray[109][$iIndex], "COLOMBIA") > 0 Then
		ConsoleWrite('Email invalido' & @CRLF)
		Return False
	EndIf

;~ If StringInStr($aArray[108][$iIndex], "NODATA") > 0 Then
;~ 	ConsoleWrite('ERROR: CountryCode' & @CRLF)
;~ 	Return False
;~ EndIf

;~ If StringInStr($aArray[109][$iIndex], "NODATA") > 0 Then
;~ 	ConsoleWrite('ERROR: CountryName' & @CRLF)
;~ 	Return False
;~ EndIf

	Local $sCountryName = $aArray[108][$iIndex]
	Local $sCountryCode = $aArray[109][$iIndex]
	If StringInStr($sCountryName, "colombia") Then
		Local $sCountryCode = "CO"
	EndIf

	
	Local $aResultArray[24]
	$aResultArray[0] = '"CustomerInformation": {'
	$aResultArray[1] = '"IdentificationType": ' & $aArray[1][$iIndex] & ','
	$aResultArray[2] = '"Identification": "' & $aArray[2][$iIndex] & '",'
	


	If StringStripWS($aArray[108][$iIndex], 8) == "COLOMBIA" Then
		$aResultArray[3] = '"DV": "' & NitCV_Calculator($aArray[2][$iIndex]) & '",'
	Else
		$aResultArray[3] = '"DV":"",'
	EndIf

	$aResultArray[4] = '"RegistrationName": "' & $aArray[6][$iIndex] & '",'
	$aResultArray[5] = '"CountryCode": "' & $sCountryCode & '",'
	$aResultArray[6] = '"CountryName": "' & $aArray[108][$iIndex] & '",'
	$aResultArray[7] = '"SubdivisionCode": "' & $sDivipola_SubdivisionCode & '",'
	$aResultArray[8] = '"SubdivisionName": "' & $sDivipola_SubdivisioName & '",'

	If StringLen($sDivipola_CityCode) < 5 Then
		$aResultArray[9] = '"CityCode": "0' & $sDivipola_CityCode & '",'
	Else
		$aResultArray[9] = '"CityCode": "' & $sDivipola_CityCode & '",'
	EndIf
	
	
	
	$aResultArray[10] = '"CityName": "' & $sDivipola_CityName & '",'
	$aResultArray[11] = '"AddressLine": "' & $aArray[13][$iIndex] & '",'
	$aResultArray[12] = '"Telephone": "' & $aArray[14][$iIndex] & '",'
	
	Local $sEmail_CSV = $aArray[15][$iIndex]
	Local $aEmail_CSV = StringSplit($sEmail_CSV, "|", 3)
	Local $sCorreo1 = StringStripWS($aEmail_CSV[0], 8)
	If UBound($aEmail_CSV) > 1 Then
		Local $sCorreo2 = StringStripWS($aEmail_CSV[1], 8)
		If $sCorreo1 = $sCorreo2 Then
			Local $sEmail_Processed = $sCorreo1
		Else
			If StringLen($sCorreo1) > 0 And StringLen($sCorreo2) > 0 Then
				Local $sEmail_Processed = $sCorreo1 & ";" & $sCorreo2
			ElseIf StringLen($sCorreo1) > 0 And StringLen($sCorreo2) <= 0 Then
				Local $sEmail_Processed = $sCorreo1
			ElseIf StringLen($sCorreo1) <= 0 And StringLen($sCorreo2) > 0 Then
				Local $sEmail_Processed = $sCorreo2
			EndIf
		EndIf
	Else
		Local $sEmail_Processed = $sCorreo1
	EndIf

	Local $iAuthorizationTesting = Json_Get($oJsonSettings, ".Gnral_Variables.authorization_testing")
	If $iAuthorizationTesting = 1 Then
		$aResultArray[13] = '"Email":"' & Json_Get($oJsonSettings, ".Gnral_Variables.test_email") & ';facturacion-noreply@abcrepecev.com",'
	Else
		Local $iEmpresaAbcNit = StringRegExpReplace($aArray[0][1], "[^[:digit:]]", "")
		Select
			Case $iEmpresaAbcNit = "900093066"
				$aResultArray[13] = '"Email":"' & StringLower($sEmail_Processed) & ';facturacion-noreply@abcstorage.co",'
			Case $iEmpresaAbcNit = "830136280"
				$aResultArray[13] = '"Email":"' & StringLower($sEmail_Processed) & ';facturacion-noreply@siclogistic.com",'
			Case $iEmpresaAbcNit = "860535640"
				$aResultArray[13] = '"Email":"' & StringLower($sEmail_Processed) & ';facturacion-noreply@abccargolog.com",'
			Case $iEmpresaAbcNit = "860536003"
				$aResultArray[13] = '"Email":"' & StringLower($sEmail_Processed) & ';facturacion-noreply@abcrepecev.com",'
			Case Else
				$aResultArray[13] = '"Email":"' & StringLower($sEmail_Processed) & ';facturacion-noreply@abcrepecev.com",'
		EndSelect
	EndIf
	$aResultArray[14] = '"CustomerCode": "' & $aArray[78][$iIndex] & '",'
	$aResultArray[15] = '"AdditionalAccountID": "' & $aArray[5][$iIndex] & '",'
	Local $aIVA_Data = _TaxLevelCodeListName($aArray[4][$iIndex])
	$aResultArray[16] = '"TaxLevelCodeListName": "' & $aIVA_Data[0] & '",'
	$aResultArray[17] = '"PostalZone": "",'
	$aResultArray[18] = '"TaxSchemeCode": "' & $aIVA_Data[1] & '",'
	$aResultArray[19] = '"TaxSchemeName": "' & $aIVA_Data[2] & '",'
	$aResultArray[20] = '"FiscalResponsabilities": "",'
	$aResultArray[21] = '"PartecipationPercent": "",'
	$aResultArray[22] = '"AdditionalCustomer": []'
	$aResultArray[23] = '},'
	For $i = 0 To UBound($aResultArray) - 1 Step +1
		$aResultArray[$i] = StringReplace($aResultArray[$i], "NoData", "")
	Next

_ArrayDisplay($aResultArray)
	Return $aResultArray
EndFunc   ;==>_JSON_CustomerInfo

Func _TaxLevelCodeListName($iTaxCode)
	If $iTaxCode = 2 Then
		Local $aArray[3] = ["48", "01", "IVA"]
		Return $aArray
	Else
		Local $aArray[3] = ["49", "ZY", "No causa"]
		Return $aArray
	EndIf
EndFunc   ;==>_TaxLevelCodeListName

Func NitCV_Calculator($iNit)
	ConsoleWrite('XXXXXXXXXXXXXXXXXXXXXXXX' & $iNit & @CRLF)
	$iNit = StringRegExpReplace($iNit, "[^[:digit:]]", "")
	Local $x = 0
	Local $y = 0
	Local $z = StringLen($iNit)
	Local $vpri[16] = [Null, 3, 7, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59, 67, 71]
	For $i = 0 To $z Step +1
		$y = StringMid($iNit, ($i + 1), 1)
		$x += ($y * $vpri[$z - $i])
	Next
	$y = Mod($x, 11)
	If $y > 1 Then
		$sResult = 11 - $y
	Else
		$sResult = $y
	EndIf
	Return $sResult
EndFunc   ;==>NitCV_Calculator

Func _DIVIPOLA($iCode, $sCountry, $sCountryCode)
	Local $aResult_Default = [$iCode, StringMid($iCode, 1, 2), "", "", "", ""]
	If StringInStr($iCode, "NODATA") > 0 Or StringInStr($sCountry, "NODATA") > 0 Or StringInStr($sCountryCode, "NODATA") > 0 Then Return 0
	If StringLen($iCode) < 5 Then
		Local $sRest = ""
		For $i = 1 To 5 - StringLen($iCode) Step +1
			$sRest &= "0"
		Next
		$iCode = $sRest & $iCode
	EndIf
	$sCityCode = _INetGetSource("https://geoportal.dane.gov.co/laboratorio/serviciosjson/gdivipola/servicios/tabla_centros_p.php?codigo_dpto_mpio=" & $iCode)
	$aCityCode = StringSplit($sCityCode, ',')
	Local $sDepartment = ""
	Local $sMunicipio = ""
	For $i = 0 To UBound($aCityCode) - 1 Step +1
		If StringInStr($aCityCode[$i], '"NOMBRE_DEPARTAMENTO":') > 0 Then
			$sDepartment = $aCityCode[$i]
			$sDepartment = StringStripWS($sDepartment, 8)
			$sDepartment = StringReplace($sDepartment, '"', '')
			$sDepartment = StringReplace($sDepartment, 'NOMBRE_DEPARTAMENTO', '')
			$sDepartment = StringReplace($sDepartment, '\u00c1', 'A')
			$sDepartment = StringReplace($sDepartment, '\u00cd', 'I')
			$sDepartment = StringReplace($sDepartment, '\u00d3', '0')
			$sDepartment = StringReplace($sDepartment, '\u00dc', 'U')
		EndIf
	Next
	For $i = 0 To UBound($aCityCode) - 1 Step +1
		If StringInStr($aCityCode[$i], '"NOMBRE_MUNICIPIO":') > 0 Then
			$sMunicipio = $aCityCode[$i]
			$sMunicipio = StringStripWS($sMunicipio, 8)
			$sMunicipio = StringReplace($sMunicipio, '"', '')
			$sMunicipio = StringReplace($sMunicipio, 'NOMBRE_MUNICIPIO', '')
			$sMunicipio = StringReplace($sMunicipio, '\u00c1', 'A')
			$sMunicipio = StringReplace($sMunicipio, '\u00cd', 'I')
			$sMunicipio = StringReplace($sMunicipio, '\u00d3', '0')
			$sMunicipio = StringReplace($sMunicipio, '\u00dc', 'U')
		EndIf
	Next
	If StringLen($sDepartment) > 0 And StringLen($sMunicipio) > 0 Then
		Local $aResult = [$iCode, StringMid($iCode, 1, 2), $sDepartment, $sMunicipio, "CO", "COLOMBIA"]
		Return $aResult
	Else
		Local $aResult = ['', '', $sCountry, $sCountry, $sCountryCode, $sCountry]
		Return $aResult
	EndIf
	Return $aResult_Default
EndFunc   ;==>_DIVIPOLA
