
Func _ItemTotalsInformation($aJsonDataArray)
	Local $aTaxesGnralData = _TaxesGnralData($aJsonDataArray)
	Local $aJsonDataArrayItemInfoResponse[0]
	_ArrayAdd($aJsonDataArrayItemInfoResponse, '"ItemInformation": [')
	For $j = 1 To UBound($aJsonDataArray, 2) - 1 Step +1
		Local $sItemInfo_ItemReference = StringReplace($aJsonDataArray[23][$j], '"', "''''")
		$sItemInfo_ItemReference = StringReplace($aJsonDataArray[23][$j], "'", "''")
		Local $sItemInfo_Name = _ItemName($aJsonDataArray[24][$j])
		Local $sItemInfo_Quatity = $aJsonDataArray[25][$j]
		Local $sItemInfo_Price = $aTaxesGnralData[$j - 1][3]
		Local $sItemInfo_LineTotalTaxes = $aTaxesGnralData[$j - 1][4]
		Local $sItemInfo_LineTotal = $aTaxesGnralData[$j - 1][3] + $sItemInfo_LineTotalTaxes
		Local $sItemInfo_LineExtensionAmount = $aTaxesGnralData[$j - 1][3]
		Local $sItemInfo_MeasureUnitCode = _MeasureUnitCode($aJsonDataArray[28][$j])
		Local $sItemInfo_FreeOFChargeIndicator = "false"
		Local $sItemInfo_TipoIngreso = $aTaxesGnralData[$j - 1][1]
		Local $sItemInfo_TaxEvidenceIndicator = "01"
		Local $sItemInfo_TaxableAmount = $aTaxesGnralData[$j - 1][3]
		Local $sItemInfo_TaxAmount_IVA = $aTaxesGnralData[$j - 1][4]
		Local $aItemInfo_TaxAmount_RTF = _TaxAmount_RTF($aTaxesGnralData, $j - 1)

		If IsArray($aItemInfo_TaxAmount_RTF) Then
			Local $sItemInfo_TaxPercent_RTF = $aItemInfo_TaxAmount_RTF[0]
			Local $sItemInfo_TaxAmount_RTF = $aItemInfo_TaxAmount_RTF[1]
			Local $iJsonIndRTFgeneration = 1
		Else
			Local $sItemInfo_TaxPercent_RTF = 0
			Local $sItemInfo_TaxAmount_RTF = 0
			Local $iJsonIndRTFgeneration = 0
		EndIf

		Local $sItemInfo_Percent_IVA = "19.00"
		Local $sItemInfo_Percent_RTF = "4.00"
		Local $iGravado = $aTaxesGnralData[$j - 1][2]
		Local $sItemInfoMandate_IdentificationType = ""
		Local $sItemInfoMandate_Identification = ""
		Local $sItemInfoMandate_RegistrationName = ""
		Local $sItemInfoMandate_DV = '""'
		If $iGravado == 1 Then
			Local $sItemInfoMandate_IdentificationType = $aJsonDataArray[1][$j]
			Local $sItemInfoMandate_Identification = $aJsonDataArray[2][$j]
			Local $sItemInfoMandate_RegistrationName = $aJsonDataArray[6][$j]
			Local $sItemInfoMandate_DV = NitCV_Calculator($aJsonDataArray[2][$j])
		EndIf

		Local $aItemInfo[49]

		$aItemInfo[0] = '{'
		$aItemInfo[1] = '"ItemReference": "' & $sItemInfo_ItemReference & '",'
		$aItemInfo[2] = '"Name": "' & $sItemInfo_Name & '",'
		$aItemInfo[3] = '"Quatity": ' & $sItemInfo_Quatity & ','
		$aItemInfo[4] = '"Price": ' & Round($sItemInfo_Price, 2) & ','
		$aItemInfo[5] = '"LineAllowanceTotal": 0.0, '
		$aItemInfo[6] = '"LineChargeTotal": 0.0, '
		$aItemInfo[7] = '"LineTotalTaxes": ' & Round($sItemInfo_LineTotalTaxes, 2) & ','
		$aItemInfo[8] = '"LineTotal": ' & Round($sItemInfo_LineTotal, 2) & ','
		$aItemInfo[9] = '"LineExtensionAmount": ' & Round($sItemInfo_LineExtensionAmount, 2) & ','
		$aItemInfo[10] = '"MeasureUnitCode":"' & Round($sItemInfo_MeasureUnitCode, 2) & '", '
		$aItemInfo[11] = '"FreeOFChargeIndicator": ' & Round($sItemInfo_FreeOFChargeIndicator, 2) & ','
		$aItemInfo[12] = '"AdditionalReference":[],'
		$aItemInfo[13] = '"AdditionalProperty": ['
		$aItemInfo[14] = '{'
		$aItemInfo[15] = '"Name": "Tipo de Ingreso",'
		$aItemInfo[16] = '"Value": "' & _TipoIngreso($sItemInfo_TipoIngreso) & '"'
		$aItemInfo[17] = '}'
		$aItemInfo[18] = '],'
		
		$aItemInfo[19] = '"TaxesInformation": ['

		$aItemInfo[20] = '{'
		$aItemInfo[21] = '"Id": "01",'
		$aItemInfo[22] = '"TaxEvidenceIndicator": false, '
		$aItemInfo[23] = '"TaxableAmount": ' & Round($sItemInfo_TaxableAmount, 2) & ','
		$aItemInfo[24] = '"TaxAmount": ' & Round($sItemInfo_TaxAmount_IVA, 2) & ','
		$aItemInfo[25] = '"Percent": ' & Round($sItemInfo_Percent_IVA, 2) & ','
		$aItemInfo[26] = '"BaseUnitMeasure": "",'
		$aItemInfo[27] = '"PerUnitAmount": ""'

		If $sItemInfo_TaxAmount_RTF = 0 Then
			$aItemInfo[28] = '}'
		Else
			$aItemInfo[28] = '},'
		EndIf
		
		$aItemInfo[29] = '{'
		$aItemInfo[30] = '"Id": "06",'
		$aItemInfo[31] = '"TaxEvidenceIndicator": true, '
		$aItemInfo[32] = '"TaxableAmount": ' & Round($sItemInfo_TaxableAmount, 2) & ','
		$aItemInfo[33] = '"TaxAmount": ' & Round($sItemInfo_TaxAmount_RTF, 2) & ','
		$aItemInfo[34] = '"Percent": ' & $sItemInfo_TaxPercent_RTF & ','
		$aItemInfo[35] = '"BaseUnitMeasure": "",'
		$aItemInfo[36] = '"PerUnitAmount": ""'
		$aItemInfo[37] = '}'
		
		$aItemInfo[38] = '],'

		$aItemInfo[39] = '"AllowanceCharge": [],'
		$aItemInfo[40] = '"InvoiceMandateInformation": {'
		$aItemInfo[41] = '"Mandate": {'
		$aItemInfo[42] = '"IdentificationType": "' & $sItemInfoMandate_IdentificationType & '",'
		$aItemInfo[43] = '"Identification": "' & $sItemInfoMandate_Identification & '",'
		$aItemInfo[44] = '"RegistrationName":"' & $sItemInfoMandate_RegistrationName & '",'
		$aItemInfo[45] = '"DV": ' & $sItemInfoMandate_DV
		$aItemInfo[46] = '}'
		$aItemInfo[47] = '}'

		If $j == UBound($aJsonDataArray, 2) - 1 Then
			$aItemInfo[48] = '}'
		Else
			$aItemInfo[48] = '},'
		EndIf

		Local $iGravado = $aTaxesGnralData[$j - 1][2]

		If $iGravado == 1 Then

			If $sItemInfo_TaxAmount_RTF = 0 Then
				$aExtracted_ItemInformation = _ArrayExtract($aItemInfo, 0, 28)
				$aExtracted_ItemInformation2 = _ArrayExtract($aItemInfo, 38, 48)
				_ArrayConcatenate($aExtracted_ItemInformation, $aExtracted_ItemInformation2)
				Local $aItemInformation = $aExtracted_ItemInformation
			Else
				Local $aItemInformation = $aItemInfo
			EndIf


		Else
			$aExtracted_ItemInformation = _ArrayExtract($aItemInfo, 0, 18)
			_ArrayAdd($aExtracted_ItemInformation, '"TaxesInformation": [],')
			$aExtracted_ItemInformation2 = _ArrayExtract($aItemInfo, 39, 48)
			_ArrayConcatenate($aExtracted_ItemInformation, $aExtracted_ItemInformation2)
			Local $aItemInformation = $aExtracted_ItemInformation
		EndIf
		
		_ArrayConcatenate($aJsonDataArrayItemInfoResponse, $aItemInformation)
	Next
	_ArrayAdd($aJsonDataArrayItemInfoResponse, "],")
	Local $iSum_Gravado, $iSum_Iva
	For $i = 0 To UBound($aTaxesGnralData) - 1 Step +1
		If $aTaxesGnralData[$i][2] == 1 Then
			$iSum_Gravado += $aTaxesGnralData[$i][3]
			$iSum_Iva += $aTaxesGnralData[$i][4]
		EndIf
	Next
	Local $aInvoiceTaxTotal[10]
	$aInvoiceTaxTotal[0] = '"InvoiceTaxTotal" :['
	$aInvoiceTaxTotal[1] = '{'
	$aInvoiceTaxTotal[2] = '"Id" : "01",'
	$aInvoiceTaxTotal[3] = '"TaxEvidenceIndicator" : false,'
	$aInvoiceTaxTotal[4] = '"TaxableAmount" : ' & Round($iSum_Gravado, 2) & ','
	$aInvoiceTaxTotal[5] = '"TaxAmount" : ' & Round($iSum_Iva, 2) & ','
	$aInvoiceTaxTotal[6] = '"Percent" : "19.0",'
	$aInvoiceTaxTotal[7] = '"BaseUnitMeasure" : "",'
	$aInvoiceTaxTotal[8] = '"PerUnitAmount" : ""'

	$aInvoiceAllowanceCharge = _InvoiceAllowanceCharge($aJsonDataArray, $aTaxesGnralData)
	If $sItemInfo_TaxAmount_RTF = 0 And UBound($aInvoiceAllowanceCharge) <= 2 Then
		$aInvoiceTaxTotal[9] = '}'
	Else
		$aInvoiceTaxTotal[9] = '},'
	EndIf
	_ArrayConcatenate($aJsonDataArrayItemInfoResponse, $aInvoiceTaxTotal)
	

	_ArrayConcatenate($aJsonDataArrayItemInfoResponse, $aInvoiceAllowanceCharge)
	$aInvoiceTotals = _InvoiceTotals($aJsonDataArray, $aTaxesGnralData)
	_ArrayConcatenate($aJsonDataArrayItemInfoResponse, $aInvoiceTotals)
	Return $aJsonDataArrayItemInfoResponse
EndFunc   ;==>_ItemTotalsInformation


Func _TaxAmount_RTF($aArray, $iIndex)
	Local $iSumGravableSum = 0 ;Se va aplicar sumatoria únicamente a los valores gravados
	For $i = 0 To UBound($aArray) - 1 Step +1
		Local $iGravIndicator = $aArray[$i][2] ;Columna de TaxesGnralInformation que indica ingresos gravados
		If $iGravIndicator = 1 Then
			Local $iItemValue = $aArray[$i][3] ;Columna de TaxesGnralInformation que indica el valor de cada item
			$iSumGravableSum += $iItemValue
		EndIf
	Next
	If $iSumGravableSum = 0 Then Return False
	Local $iRTF_Percent = Round($aArray[$iIndex][6] / $iSumGravableSum, 2) * 100
	;El index nos indica a que fila exacta del arreglo se va a practicar el cálculo de proporciones de la retefuente en caso de que esta aplique
	Local $iItemParticularValue = $aArray[$iIndex][3]
	Local $iItemValuePercent = $iItemParticularValue / $iSumGravableSum ;Se aplica una proporción que define el porcentaje relativo de cada item
	Local $iItemValueRTF = $iItemValuePercent * $aArray[$iIndex][6] ;Columna que tiene el valor total de la retefuente
	$iItemValueRTF = Round($iItemValueRTF, 2)
	Local $aResponse[2] = [$iRTF_Percent, $iItemValueRTF]
	Return $aResponse
EndFunc   ;==>_TaxAmount_RTF


Func _InvoiceTotals($aJsonDataArray, $aTaxesGnralData)
	Local $iLineExtensionAmount_Own = 0
	Local $iLineExtensionAmount_Others = 0
	Local $iTaxExclusiveAmount = 0
	Local $iTaxExclusiveAmount_Own = 0
	Local $iTaxExclusiveAmount_Others = 0
	Local $iTaxAmount_Own = 0
	Local $iTaxAmount_Others = 0
	Local $iLineExtensionAmount = 0
	Local $iTotalTaxes = 0
	Local $iTaxInclusiveAmount = 0
	Local $iAllowanceTotalAmount = 0
	Local $iChargeTotalAmount = 0
	Local $iPrePaidAmount = 0
	Local $iPayableAmount = 0
	Local $iCount = 0
	Local $iRetefuente = 0
	Local $iReteICA = 0
	Local $iReteIVA = 0
	For $i = 0 To UBound($aTaxesGnralData) - 1 Step +1
		$iLineExtensionAmount += $aTaxesGnralData[$i][3]
		$iTaxExclusiveAmount += $aTaxesGnralData[$i][4]
		If $aTaxesGnralData[$i][2] == 1 Then
			$iCount += $aTaxesGnralData[$i][2]
			$iLineExtensionAmount_Own += $aTaxesGnralData[$i][3]
			$iTaxExclusiveAmount_Own += $aTaxesGnralData[$i][3] * $aTaxesGnralData[$i][2]
			$iTaxAmount_Own += $aTaxesGnralData[$i][4]
			$iRetefuente += $aTaxesGnralData[$i][6]
			$iReteICA += $aTaxesGnralData[$i][7]
			$iReteIVA += $aTaxesGnralData[$i][8]
		Else
			$iLineExtensionAmount_Others += $aTaxesGnralData[$i][3]
			$iTaxExclusiveAmount_Others += $aTaxesGnralData[$i][3] * $aTaxesGnralData[$i][2]
			$iTaxAmount_Others += $aTaxesGnralData[$i][4]
		EndIf
	Next
	Local $iPayableAmount_Own = $iLineExtensionAmount_Own + $iTaxAmount_Own
	Local $iPayableAmount_Others = $iLineExtensionAmount_Others + $iTaxAmount_Others
	If $iCount > 0 Then
		Local $iAllowanceTotalAmount = ($iRetefuente / $iCount) + ($iReteICA / $iCount) + ($iReteIVA / $iCount)
	EndIf
	If $aJsonDataArray[99][$i] <= 0 Then
		Local $iPrePaidAmount = "0.0"
	Else
		Local $iPrePaidAmount = $aJsonDataArray[99][$i] / 100
	EndIf
	Local $iPayableAmount = ($iLineExtensionAmount + $iTaxExclusiveAmount) - $iPrePaidAmount
;~ $iPayableAmount = Abs($iPayableAmount)
	Local $aInvoiceTotals[22]
	$aInvoiceTotals[0] = '"InvoiceTotalOwn": {'
	$aInvoiceTotals[1] = '"LineExtensionAmount":' & Round($iLineExtensionAmount_Own, 2) & ','
	$aInvoiceTotals[2] = '"TaxExclusiveAmount":' & Round($iTaxExclusiveAmount_Own, 2) & ','
	$aInvoiceTotals[3] = '"TaxAmount":' & Round($iTaxAmount_Own, 2) & ','
	$aInvoiceTotals[4] = '"PayableAmount":' & Round($iPayableAmount_Own, 2)
	$aInvoiceTotals[5] = '},'
	$aInvoiceTotals[6] = '"InvoiceTotalOthers": {'
	$aInvoiceTotals[7] = '"LineExtensionAmount":' & Round($iLineExtensionAmount_Others, 2) & ','
	$aInvoiceTotals[8] = '"TaxExclusiveAmount":' & Round($iTaxExclusiveAmount_Others, 2) & ','
	$aInvoiceTotals[9] = '"TaxAmount":' & Round($iTaxAmount_Others, 2) & ','
	$aInvoiceTotals[10] = '"PayableAmount":' & Round($iPayableAmount_Others, 2)
	$aInvoiceTotals[11] = '},'
	$aInvoiceTotals[12] = '"InvoiceTotal": {'
	$aInvoiceTotals[13] = '"LineExtensionAmount":' & Round($iLineExtensionAmount, 2) & ','
	$aInvoiceTotals[14] = '"TaxExclusiveAmount":' & Round($iTaxExclusiveAmount_Own, 2) & ','
	$aInvoiceTotals[15] = '"TaxInclusiveAmount":' & Round($iLineExtensionAmount + $iTaxExclusiveAmount, 2) & ','
	$aInvoiceTotals[16] = '"AllowanceTotalAmount": 0.0,'
	$aInvoiceTotals[17] = '"ChargeTotalAmount": 0.0,'
	$aInvoiceTotals[18] = '"PrePaidAmount":' & Round($iPrePaidAmount, 2) & ','
	$aInvoiceTotals[19] = '"PayableAmount":' & Round($iPayableAmount, 2)
	$aInvoiceTotals[20] = '},'
	$aInvoiceTotals[21] = '"Documents": []'
	Return $aInvoiceTotals
EndFunc   ;==>_InvoiceTotals

;#FUNCTION# ===================================================================
; Name ..........: _TaxesGnralData
; Description ...:
; Parameters ....: $aJsonDataArray      	- [REQUIRED]
; Return values .:
; Author ........: Jesús A. Ladino
; ==============================================================================
Func _TaxesGnralData($aJsonDataArray)
	Local $aIncomingsTaxesIndex[0][11]
	For $m = 1 To UBound($aJsonDataArray, 2) - 1 Step +1
		If StringStripWS(StringUpper($aJsonDataArray[69][$m]), 8) == "COP" Then
			Local $iTasaCambio = 1
		Else
			Local $iTasaCambio = $aJsonDataArray[76][1]
		EndIf
		Local $iAmount = Number($aJsonDataArray[27][$m]) / _CheckNegative(Number($iTasaCambio))
		Local $iIVA_Disc = Number($aJsonDataArray[34][$m]) / _CheckNegative(Number($iTasaCambio))
		Local $iIVA_Total = Number($aJsonDataArray[51][$m]) / _CheckNegative(Number($iTasaCambio))
		Local $iRetefuente = Number($aJsonDataArray[56][$m]) / _CheckNegative(Number($iTasaCambio))
		Local $iReteICA = Number($aJsonDataArray[61][$m]) / _CheckNegative(Number($iTasaCambio))
		Local $iReteIVA = Number($aJsonDataArray[66][$m]) / _CheckNegative(Number($iTasaCambio))
		$iIVA_Disc = _CheckNegative($iIVA_Disc)
		$iIVA_Total = _CheckNegative($iIVA_Total)
		$iRetefuente = _CheckNegative($iRetefuente)
		$iReteICA = _CheckNegative($iReteICA)
		$iReteIVA = _CheckNegative($iReteIVA)
		Local $sIncomingType = $aJsonDataArray[102][$m]
		If StringInStr($sIncomingType, "TER") > 0 Then     ;Ingresos terceros
			_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Terceros" & "|0|" & $iAmount & "|0|0|0|0|0", 0, "|")
		ElseIf StringInStr($sIncomingType, "PRO") Then     ;Ingresos propios
			If Number($aJsonDataArray[34][$m]) > 0 Then
				$sTaxesData = $iAmount & "|" & $iIVA_Disc & "|" & $iIVA_Total & "|" & $iRetefuente & "|" & $iReteICA & "|" & $iReteIVA
				_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $sTaxesData, 0, "|")
			ElseIf StringInStr($aJsonDataArray[0][1], "8xxx60.535.640") Then
				ConsoleWrite("  Caso especial: Cargo" & @CRLF)
				Select
					Case $iRetefuente <= 0 And $iReteICA <= 0 And $iReteIVA <= 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|0|" & $iAmount & "|0|0|0|0|0", 0, "|")
						ConsoleWrite("  Caso impositivo: 000" & @CRLF)
					Case $iRetefuente <= 0 And $iReteICA <= 0 And $iReteIVA > 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|0|0|" & $iReteIVA, 0, "|")
						ConsoleWrite("  Caso impositivo: 001" & @CRLF)
					Case $iRetefuente <= 0 And $iReteICA > 0 And $iReteIVA <= 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|0|" & $iReteICA & "|0", 0, "|")
						ConsoleWrite("  Caso impositivo: 010" & @CRLF)
					Case $iRetefuente <= 0 And $iReteICA > 0 And $iReteIVA > 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|0|" & $iReteICA & "|" & $iReteIVA, 0, "|")
						ConsoleWrite("  Caso impositivo: 011" & @CRLF)
					Case $iRetefuente > 0 And $iReteICA <= 0 And $iReteIVA <= 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|" & $iRetefuente & "|0|0", 0, "|")
						ConsoleWrite("  Caso impositivo: 100" & @CRLF)
					Case $iRetefuente > 0 And $iReteICA <= 0 And $iReteIVA > 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|" & $iRetefuente & "|0|" & $iReteIVA, 0, "|")
						ConsoleWrite("  Caso impositivo: 101" & @CRLF)
					Case $iRetefuente > 0 And $iReteICA > 0 And $iReteIVA <= 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|" & $iRetefuente & "|" & $iReteICA & "|0", 0, "|")
						ConsoleWrite("  Caso impositivo: 110" & @CRLF)
					Case $iRetefuente > 0 And $iReteICA > 0 And $iReteIVA > 0
						_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|1|" & $iAmount & "|0|0|" & $iRetefuente & "|" & $iReteICA & "|" & $iReteIVA, 0, "|")
						ConsoleWrite("  Caso impositivo: 111" & @CRLF)
				EndSelect
			Else
				_ArrayAdd($aIncomingsTaxesIndex, $m & "|" & "Propio" & "|0|" & $iAmount & "|0|0|0|0|0", 0, "|")
			EndIf
		EndIf
	Next
	Local $iAmountLine = 0
	Local $iIVA = 0
	Local $iIVA_Disc = 0
	For $i = 0 To UBound($aIncomingsTaxesIndex) - 1 Step +1
		$iGravado = $aIncomingsTaxesIndex[$i][2]
		If $iGravado = 1 Then
			$iAmountLine += $aIncomingsTaxesIndex[$i][3]
			$iIVA += $aIncomingsTaxesIndex[$i][4]
		EndIf
	Next
	Local $iIVA_Distributed = 0
	For $i = 0 To UBound($aIncomingsTaxesIndex) - 1 Step +1
		$iGravado = $aIncomingsTaxesIndex[$i][2]
		If $iGravado = 1 Then
			$iIVA_Percent = $iIVA / $iAmountLine
			$iIVA_Item = Round($aIncomingsTaxesIndex[$i][3] * $iIVA_Percent, 2)
			$aIncomingsTaxesIndex[$i][4] = $iIVA_Item
			$iIVA_Distributed += $iIVA_Item
		EndIf
	Next
	Local $iFinalIVA = $iIVA - $iIVA_Distributed
	$aIncomingsTaxesIndex[UBound($aIncomingsTaxesIndex) - 1][4] = $aIncomingsTaxesIndex[UBound($aIncomingsTaxesIndex) - 1][4] + $iFinalIVA
	Return $aIncomingsTaxesIndex
EndFunc   ;==>_TaxesGnralData



Func _IVA_Total($aJsonDataArrayTaxes)     ;Array correspondiente a $aTaxesGnralData
	Local $iCount = 0
	Local $iSum = 0
	For $i = 0 To UBound($aJsonDataArrayTaxes) - 1 Step +1
		$iGravado = $aJsonDataArrayTaxes[$i][2]
		If $iGravado = 1 Then
			$iSum += $aJsonDataArrayTaxes[$i][4]
		EndIf
	Next
	Return $iSum
EndFunc   ;==>_IVA_Total


