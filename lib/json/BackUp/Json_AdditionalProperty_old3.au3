Func _JSON_AdditionalProperty($aArray)
;~ If Not @Compiled Then _ArrayDisplay($aArray)
	Local $aCodigoCIIU[3]
	$aCodigoCIIU[0] = "Codigo CIIU"
	$aCodigoCIIU[1] = '""'
	$aCodigoCIIU[2] = $aArray[74][1]
	Local $aFax[3]
	$aFax[0] = "Fax:"
	$aFax[1] = '""'
	$aFax[2] = $aArray[75][1]
	Local $aTipoCambio[3]
	$aTipoCambio[0] = "Tipo de Cambio"
	$aTipoCambio[1] = '""'
	$aTipoCambio[2] = Number($aArray[76][1])
	Local $aAWLBL[3]
	$aAWLBL[0] = "AWL/BL"
	$aAWLBL[1] = '""'
	$aAWLBL[2] = $aArray[85][1]
	Local $aSUC[3]
	$aSUC[0] = "SUC"
	$aSUC[1] = '""'
	$aSUC[2] = $aArray[79][1]
	Local $aPeso[3]
	$aPeso[0] = "Peso:"
	$aPeso[1] = '""'
	$aPeso[2] = $aArray[80][1]
	Local $aPiezas[3]
	$aPiezas[0] = "Piezas:"
	$aPiezas[1] = '""'
	$aPiezas[2] = Number($aArray[86][1])
	Local $aConceptoReferencia[3]
	$aConceptoReferencia[0] = "Concepto o Referencia:"
	$aConceptoReferencia[1] = '""'
	$aConceptoReferencia[2] = $aArray[84][1]
	Local $aNo[3]
	$aNo[0] = "No"
	$aNo[1] = '""'
	$aNo[2] = $aArray[82][1]
	Local $aValorLetras[3]
	$aValorLetras[0] = "Valor en letras:"
	$aValorLetras[1] = '""'
	$aValorLetras[2] = $aArray[94][1]

	Local $aValorMercancia[3]
	$aValorMercancia[0] = "Valor mercancia:"
	$aValorMercancia[1] = '""'
	$aValorMercancia[2] = $aArray[93][1]

	Local $sObservaciones_Data = StringReplace($aArray[111][1], "'", "?")
	$sObservaciones_Data = StringReplace($sObservaciones_Data, '"', "")
	$sObservaciones_Data = StringReplace($sObservaciones_Data, "|", "?")
	$sObservaciones_Data = _RemoveObsSpaces($sObservaciones_Data)
	Local $aObservaciones_Data = StringSplit($sObservaciones_Data, "?", 3)
	Local $aObservacionesFiltered[UBound($aObservaciones_Data)]

	Local $sObservacionesSamsungEmailFile = @ScriptDir & "\SamsungCorreo.txt"
	Local $sFileObservacionesTipoDO = @ScriptDir & "\TipoDO.txt"
	FileDelete($sFileObservacionesTipoDO)
	FileDelete($sObservacionesSamsungEmailFile)
	For $i = 0 To UBound($aObservaciones_Data) - 1 Step +1
		Local $sObservacionCheck = $aObservaciones_Data[$i]
		If StringInStr($sObservacionCheck, "@") Then
			If $i < UBound($aObservaciones_Data) - 1 Then $sObservacionCheck = $sObservacionCheck & ","
			_files_Append_SaveData($sObservacionesSamsungEmailFile, $sObservacionCheck)
		ElseIf StringUpper($sObservacionCheck) == "EXPO" Then
			_files_Update_SaveData($sFileObservacionesTipoDO, "Expo")
		Else
			$aObservacionesFiltered[$i] = $sObservacionCheck
		EndIf
	Next
	Local $sObservacionesFiltered
	$aObservacionesFiltered = _Array1DDeleteEmptyRows($aObservacionesFiltered)
	For $i = 0 To UBound($aObservacionesFiltered) - 1 Step +1
		$sObservacionesFiltered &= $aObservacionesFiltered[$i] & "?"
	Next
	$sObservacionesFiltered = StringTrimRight($sObservacionesFiltered, 1)
	
	Local $aObservaciones[3]
	$aObservaciones[0] = "Observaciones:"
	$aObservaciones[1] = '""'
	$aObservaciones[2] = $sObservacionesFiltered

	Local $sVencimiento = _Vencimiento(StringStripWS($aArray[110][1], 8))
	Local $aVencimiento[3]
	$aVencimiento[0] = "Vencimiento:"
	$aVencimiento[1] = '""'
	$aVencimiento[2] = $sVencimiento
	Local $aTRM[3]
	$aTRM[0] = "TRM:"
	$aTRM[1] = '""'
	$aTRM[2] = $aArray[91][1]

	Local $aJefeCuenta[3]
	$aJefeCuenta[0] = "JefeCuenta:"
	$aJefeCuenta[1] = '""'
	$aJefeCuenta[2] = _JefeCuenta($aArray)

	Local $aFechaLevante[3]
	$aJefeCuenta[0] = "FechaLevante:"
	$aJefeCuenta[1] = '""'
	$aJefeCuenta[2] = _FechaLevante($aObservaciones)

	Local $aResultArray[16]
	$aResultArray[0] = $aCodigoCIIU
	$aResultArray[1] = $aFax
	$aResultArray[2] = $aTipoCambio
	$aResultArray[3] = $aAWLBL
	$aResultArray[4] = $aSUC
	$aResultArray[5] = $aPeso
	$aResultArray[6] = $aPiezas
	$aResultArray[7] = $aConceptoReferencia
	$aResultArray[8] = $aNo
	$aResultArray[9] = $aValorLetras
	$aResultArray[10] = $aValorMercancia
	$aResultArray[11] = $aObservaciones
	$aResultArray[12] = $aVencimiento
	$aResultArray[13] = $aTRM
	$aResultArray[14] = $aJefeCuenta
	$aResultArray[15] = $aFechaLevante
	Return _JsonConstructor($aResultArray)
EndFunc   ;==>_JSON_AdditionalProperty

Func _JefeCuenta($aJsonDataArray)
_ArrayDisplay($aJsonDataArray,'JesfeCuenta')
	Local $sObservaciones = $aJsonDataArray[111][1]
	Local $sSplitter = "/" ;CARACTER SEPARADOR DE LAS NACIONALIZACIONES EN EL CAMPO DE OBSERVACIONES
	If StringInStr($sObservaciones, "'") = 0 Then
		Local $aObservaciones = [$sObservaciones]
	Else
		Local $aObservaciones = StringSplit($sObservaciones, "'", 3)
	EndIf
	For $i = 0 To UBound($aObservaciones) - 1 Step +1
		Local $sObservacionesLinea = StringStripWS($aObservaciones[$i], 8)
		If StringInStr($sObservacionesLinea, "NAC:") Then
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
						Local $sSQL_QueryJefeCuenta = "EXEC  [Repecev2005].[dbo].Nac_levante_Facturacion " & $sNacionalizacionesLista
						ConsoleWrite($sSQL_QueryJefeCuenta&@CRLF)
						Local $aSQL_QueryJefeCuenta = _ModuloSQL_SQL_SELECT($sSQL_QueryJefeCuenta)
						If UBound($aSQL_QueryJefeCuenta) > 1 Then
							ConsoleWrite("Levante: " & $aSQL_QueryJefeCuenta[1][0] & @CRLF)
							Exit
							Return $aSQL_QueryJefeCuenta[1][0]
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	Next
	Exit
EndFunc   ;==>_JefeCuenta


Func _RemoveObsSpaces($sObservaciones_Data)
	Local $aObservaciones_Data = StringSplit($sObservaciones_Data, "?", 3)
	For $i = 0 To UBound($aObservaciones_Data) - 1 Step +1
		Local $sRow = $aObservaciones_Data[$i]
		Local $aRow = StringSplit($sRow, "", 3)
		Local $sCorrectedString
		For $j = 0 To UBound($aRow) - 1 Step +1
			Local $sUniqueCharacter = $aRow[$j]
			If $sUniqueCharacter <> " " Then
				For $k = $j To UBound($aRow) - 1 Step +1
					$sCorrectedString &= $aRow[$k]
				Next
				$sCorrectedString = $sCorrectedString & "?"
				ExitLoop
			EndIf
		Next
	Next
	ConsoleWrite($sCorrectedString & @CRLF)
	Return $sCorrectedString
EndFunc   ;==>_RemoveObsSpaces

Func _JsonConstructor($aArray)
	Local $aJsonDataResponse[1]
	$aJsonDataResponse[0] = '"AdditionalProperty": ['
	For $i = 0 To UBound($aArray) - 1 Step +1
		Local $aData = $aArray[$i]
		Local $sNameVar = $aData[0]
		Local $sValueVarDefault = $aData[1]
		Local $sValueVar = $aData[2]
		If $i = UBound($aArray) - 1 Then
			If StringInStr($sValueVar, "NoData") Or StringStripWS($sValueVar, 8) = "-1" Then
				Local $sAdditionalProperty = '{|"Name": "' & $sNameVar & '",|"Value" : ' & $sValueVarDefault & '|}'
			Else
				Local $sAdditionalProperty = '{|"Name": "' & $sNameVar & '",|"Value" : "' & $sValueVar & '"|}'
			EndIf
		Else
			If StringInStr($sValueVar, "NoData") > 0 Or StringStripWS($sValueVar, 8) = "-1" Then
				Local $sAdditionalProperty = '{|"Name": "' & $sNameVar & '",|"Value" : ' & $sValueVarDefault & '|},'
			Else
				Local $sAdditionalProperty = '{|"Name": "' & $sNameVar & '",|"Value" : "' & $sValueVar & '"|},'
			EndIf
		EndIf
		Local $aAdditionalProperty = StringSplit($sAdditionalProperty, "|", 3)
		_ArrayConcatenate($aJsonDataResponse, $aAdditionalProperty)
	Next
	_ArrayAdd($aJsonDataResponse, '],')
	Return $aJsonDataResponse
EndFunc   ;==>_JsonConstructor


Func _PiecesNumber($aArray)
	Local $iSum = 0
	For $i = 0 To UBound($aArray, 2) - 1 Step +1
		$iSum += $aArray[25][$i]
	Next
	Return $iSum
EndFunc   ;==>_PiecesNumber

Func _Vencimiento($sFecha)
	If StringLen($sFecha) = 8 Then
		Local $aFecha = StringSplit($sFecha, "", 3)
		Local $sFechaVenc = $aFecha[0] & $aFecha[1] & $aFecha[2] & $aFecha[3] & "-" & $aFecha[4] & $aFecha[5] & "-" & $aFecha[6] & $aFecha[7]
		Return $sFechaVenc
	ElseIf StringLen($sFecha) = 0 Then
		Local $sFechaVenc = @MDAY & "-" & @MON & "-" & @YEAR
		Return $sFechaVenc
	Else
		Return $sFecha
	EndIf
EndFunc   ;==>_Vencimiento




Func _FechaLevante($sObservaciones)
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
				Local $sFechaLevanteQuery = "EXEC Nac_levante_Facturacion " & $aNacionalizacionesLista[0]
				Local $aFechaLevanteQuery = _ModuloSQL_SQL_EXEC($sFechaLevanteQuery)
				_ArrayDisplay($aFechaLevanteQuery)
			Else
				ConsoleWrite("  Formato inválido de nacionalizaciones / Campo vacío" & @CRLF)
			EndIf
		EndIf
	Next
EndFunc   ;==>_FechaLevante
