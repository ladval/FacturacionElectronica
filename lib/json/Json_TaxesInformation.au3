Func _TaxesInformation($aArray, $sDataType = "JSON")
	Local $aExactArray = _IvaDec($aArray)
	Select
		Case $sDataType = "JSON"
			Local $aTaxesArrayJsonResponse = _TaxesArrayJsonResponse($aExactArray)
			Return $aTaxesArrayJsonResponse
		Case $sDataType = "VALUES"
			Return $aExactArray
	EndSelect
EndFunc   ;==>_TaxesInformation
;GENERA UN ARREGLO CON TODOS LOS OBJETOS JSON DE LOS ITEMS GRAVADOS CON SU RESPECTIVA POSICIÓN RELATIVA A LOS ITEMS
Func _TaxesArrayJsonResponse($aArray)
	Local $aTaxesInfoResponse[UBound($aArray)]
	Local $aJsonResponse[0]
	For $i = 0 To UBound($aArray) - 1 Step +1
		Local $iGravado = $aArray[$i][2]
		If $iGravado = 1 Then
			Local $iTotalItem = $aArray[$i][3]
			Local $iIvaDiscriminado = $aArray[$i][4]
			$aTaxesInfoResponse[$i] = _Json_TaxesInformation($iTotalItem, $iIvaDiscriminado)
		Else
			$aTaxesInfoResponse[$i] = 0
		EndIf
	Next
	Return $aTaxesInfoResponse
EndFunc   ;==>_TaxesArrayJsonResponse

;GENERA EL FORMATO JSON DE TAXES INFORMATION, QUE APLICA ACTUALMENTE ÚNICAMENTE PARA IVA.
Func _Json_TaxesInformation($sTaxableAmount, $sTaxAmount)
	Local $sIVA_Id = "01"
	Local $sPercent = "19.00"
	Local $aTaxesInformation[9]
	$aTaxesInformation[0] = '{'
	$aTaxesInformation[1] = '"Id": "' & $sIVA_Id & '",'
	$aTaxesInformation[2] = '"TaxEvidenceIndicator": false,'
	$aTaxesInformation[3] = '"TaxableAmount": ' & $sTaxableAmount & ','
	$aTaxesInformation[4] = '"TaxAmount": ' & $sTaxAmount & ','
	$aTaxesInformation[5] = '"Percent": ' & $sPercent & ','
	$aTaxesInformation[6] = '"BaseUnitMeasure": "",'
	$aTaxesInformation[7] = '"PerUnitAmount": 0.0'
	$aTaxesInformation[8] = '}'
	Return $aTaxesInformation
EndFunc   ;==>_Json_TaxesInformation

;Iguala el valor total del IVA con el del iva discriminado de los ITEMS generados por SIIGO
Func _IvaDec($aArray)
	Local $iVA_TotalItems = 0
	Local $iVA_TotalSum = 0
	Local $iGravado_Count = 0
	For $i = 0 To UBound($aArray) - 1 Step +1
		$iGravado = $aArray[$i][2]
		$iGravado_Count += $aArray[$i][2]
		If $iGravado = 1 Then
			Local $iTotalItem = $aArray[$i][3]
			Local $iIvaDiscriminado = $aArray[$i][4]
			Local $iIvaTotal = $aArray[$i][5]
			$iVA_TotalItems += $iIvaDiscriminado
			$iVA_TotalSum += $iIvaTotal
		EndIf
	Next
	$iIVA_Total_Average = $iVA_TotalSum / $iGravado_Count
	Local $IVA_Diff = $iIVA_Total_Average - $iVA_TotalItems
	Local $iFinalDiff = $aArray[UBound($aArray) - 1][3] + $IVA_Diff
	$aArray[UBound($aArray) - 1][3] = Round($iFinalDiff)
	Return $aArray
EndFunc   ;==>_IvaDec



; #FUNCTION# ===================================================================
; Name ..........: _InvoiceTaxTotal
; Description ...: Function that returns the JSON array with the Invoice tax total data or the total value of the taxes
; Parameters ....: $aArray      		 - [REQUIRED]
; Parameters ....: $sDataType      		 - [OPTIONAL]
; Return values .: On Success 			 -  Returns the JSON array with the Invoice tax total data or the total value of the taxes
; Author ........: Jesús A. Ladino
; ==============================================================================
Func _InvoiceTaxTotal($aArray, $sDataType = "JSON")
	Local $iSum_TaxableAmount = 0
	Local $iSum_TaxAmount = 0
	Local $iCount = 0
	For $i = 1 To UBound($aArray, 2) - 1 Step +1
		$iSum_TaxableAmount += $aArray[50][$i]
		$iSum_TaxAmount += $aArray[51][$i]
		$iCount += 1
	Next
	Local $iTaxableAmount = $iSum_TaxableAmount / $iCount
	Local $iTaxAmount = $iSum_TaxAmount / $iCount
	Local $sIVA_Id = "01"
	Local $sPercent = "19.00"
	Local $sTaxableAmount = 0
	Local $sTaxAmount = 0
	Local $aInvoiceTaxTotal[11]
	$aInvoiceTaxTotal[0] = '"InvoiceTaxTotal": ['
	$aInvoiceTaxTotal[1] = '{'
	$aInvoiceTaxTotal[2] = '"Id": "' & $sIVA_Id & '",'
	$aInvoiceTaxTotal[3] = '"TaxEvidenceIndicator": false,'
	$aInvoiceTaxTotal[4] = '"TaxableAmount": ' & $iTaxableAmount & ','
	$aInvoiceTaxTotal[5] = '"TaxAmount": ' & $iTaxAmount & ','
	$aInvoiceTaxTotal[6] = '"Percent": ' & $sPercent & ','
	$aInvoiceTaxTotal[7] = '"BaseUnitMeasure": "",'
	$aInvoiceTaxTotal[8] = '"PerUnitAmount": 0.0'
	$aInvoiceTaxTotal[9] = '}'
	$aInvoiceTaxTotal[10] = '],'
	Select
		Case $sDataType = "JSON"
			Return $aInvoiceTaxTotal
		Case $sDataType = "TAXABLE"
			Return $iTaxableAmount
		Case $sDataType = "TAX"
			Return $iTaxAmount
	EndSelect
EndFunc   ;==>_InvoiceTaxTotal




