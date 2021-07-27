Func _Array1DDeleteEmptyRows(ByRef $iArray)
	Local $vEmpty = False
	Local $iArrayOut[1], $A = 0
	For $i = 0 To (UBound($iArray, 1) - 1) Step 1
		If $vEmpty = True Then $A += 1
		$vEmpty = False
		If StringCompare(StringStripWS($iArray[$i], 8), "", 0) <> 0 Then
			ReDim $iArrayOut[$A + 1]
			$iArrayOut[$A] = $iArray[$i]
			$vEmpty = True
		EndIf
	Next
	Return $iArrayOut
EndFunc   ;==>_Array1DDeleteEmptyRows


Func _Array2DDeleteEmptyRows(ByRef $iArray)
	Local $vEmpty = False
	$cols = UBound($iArray, 2)
	Local $iArrayOut[1][$cols], $A = 0
	For $i = 0 To (UBound($iArray, 1) - 1) Step 1
		If $vEmpty = True Then $A += 1
		$vEmpty = False
		For $j = 0 To (UBound($iArray, 2) - 1) Step 1
			If StringCompare($iArray[$i][0], "", 0) <> 0 Then
				ReDim $iArrayOut[$A + 1][$cols]
				$iArrayOut[$A][$j] = $iArray[$i][$j]
				$vEmpty = True
			EndIf
		Next
	Next
	Return $iArrayOut
EndFunc   ;==>_Array2DDeleteEmptyRows

Func _misc_StringFilter($sString)
	Local $aString = StringSplit($sString, "", 3)
	Local $aZerosIndicator[0]
	Local $aBlanksIndicator[0]
	For $i = 0 To UBound($aString) - 1 Step +1
		If StringStripWS($aString[$i], 8) = "0" Then
			_ArrayAdd($aZerosIndicator, $i)
		Else
			ExitLoop
		EndIf
	Next
	Local $iZerosIndicator = UBound($aZerosIndicator)
	For $i = UBound($aString) - 1 To 0 Step -1
		If StringStripWS($aString[$i], 8) = "" Then
			_ArrayAdd($aBlanksIndicator, $i)
		Else
			ExitLoop
		EndIf
	Next
	Local $iBlanksIndicator = UBound($aString) - UBound($aBlanksIndicator) - 1
	Local $aArrayExtracted = _ArrayExtract($aString, $iZerosIndicator, $iBlanksIndicator)
	If UBound($aArrayExtracted) = UBound($aString) + ($iBlanksIndicator + 1) Then
		Return "NoData"
	Else
		Local $sResultString = _ArrayToString($aArrayExtracted, "")
		Return $sResultString
	EndIf
EndFunc   ;==>_misc_StringFilter

Func _MeasureUnitCode($sUnitCode)
	If StringInStr($sUnitCode, "NPT") Then $sUnitCode = "94"
	Return $sUnitCode
EndFunc   ;==>_MeasureUnitCode

Func _CheckNegative($iNum)
	If $iNum <= 0 Then Return 0
	Return $iNum
EndFunc   ;==>_CheckNegative

Func _ItemName($sName)
	$sName = StringReplace($sName, "IngTer-", "")
	$sName = StringReplace($sName, "IngPro-", "")
	$sName = StringReplace($sName, '"', "''")
	$sName = StringReplace($sName, '"', "''")
	$sName = StringReplace($sName, "'", "")
	Return $sName
EndFunc   ;==>_ItemName

Func _TipoIngreso($sIngreso)
	If StringInStr($sIngreso, "Terce") > 0 Then
		$sIngreso = "TERCERO"
		Return $sIngreso
	ElseIf StringInStr($sIngreso, "Propi") > 0 Then
		$sIngreso = "PROPIO"
		Return $sIngreso
	EndIf
EndFunc   ;==>_TipoIngreso

Func _ZeroString($iNum)
	If $iNum <= 0 Then $iNum = "0.0"
	Return $iNum
EndFunc   ;==>_ZeroString
; #FUNCTION# ===================================================================
; Name ..........: _JSON_1Darray
; Description ...:
; Parameters ....: $aArray      	- [REQUIRED]
; Return values .:
; Author ........: Jesús A. Ladino
; ==============================================================================
Func _JSON_1Darray($aArray)
	Local $a2Darray[0][5]
	For $i = 0 To UBound($aArray) - 1 Step +1
		_ArrayTranspose($aArray[$i])
		_ArrayAdd($a2Darray, $aArray[$i])
	Next
	Return $a2Darray
EndFunc   ;==>_JSON_1Darray
; #FUNCTION# ===================================================================
; Name ..........: _JSON_JsonData
; Description ...:
; Parameters ....: $aArray      	- [REQUIRED]
; Return values .:
; Author ........: Jesús A. Ladino
; ==============================================================================
Func _JSON_JsonData($aArray)
	Local $sResult
	For $i = 0 To UBound($aArray) - 1 Step +1
		Local $sVarName = $aArray[$i][0]
		Local $sVarValue = $aArray[$i][1]
		Local $sVarDefaultValue = $aArray[$i][2]
		Local $sVarName_quotation = '"' & $sVarName & '": '
		Select
			Case $sVarDefaultValue = "0"
				Local $sVarValue_quotation = $sVarValue
			Case $sVarDefaultValue = "null"
				$sVarDefaultValue = '""'
				Local $sVarValue_quotation = '"' & $sVarValue & '"'
			Case $sVarDefaultValue = "0001-01-01T00:00:00"
				$sVarDefaultValue = '""'
				Local $sVarValue_quotation = '"' & $sVarValue & '"'
			Case $sVarDefaultValue = "0.0"
				Local $sVarValue_quotation = $sVarValue
			Case $sVarDefaultValue = "false"
				Local $sVarValue_quotation = $sVarValue
			Case $sVarDefaultValue = "[]"
				$sVarDefaultValue = '[]'
			Case Else
				Local $sVarValue_quotation = '"' & $sVarValue & '"'
		EndSelect
		Select
			Case $i = 0
				$sResult &= $sVarName_quotation & "{" & "|"
			Case $i = UBound($aArray) - 1 And StringInStr($sVarValue_quotation, "NoData") = 0
				$sResult &= $sVarName_quotation & $sVarValue_quotation & '|'
				$sResult &= "},"
			Case $i = UBound($aArray) - 1 And StringInStr($sVarValue_quotation, "NoData") > 0
				$sResult &= $sVarName_quotation & $sVarDefaultValue & '|'
				$sResult &= "},"
			Case StringInStr($sVarValue_quotation, "NoData") > 0
				$sResult &= $sVarName_quotation & $sVarDefaultValue & ',' & "|"
			Case Else
				$sResult &= $sVarName_quotation & $sVarValue_quotation & ',' & "|"
		EndSelect
	Next
	Return StringSplit($sResult, "|", 3)
EndFunc   ;==>_JSON_JsonData



